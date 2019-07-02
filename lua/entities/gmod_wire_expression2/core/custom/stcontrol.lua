--[[ ******************************************************************************
 My custom state LQ-PID control type handling process variables
****************************************************************************** ]]--

local pairs = pairs
local tostring = tostring
local tonumber = tonumber
local bitBor = bit.bor
local mathAbs = math.abs
local mathModf = math.modf
local tableConcat = table.concat
local tableInsert = table.insert
local tableRemove = table.remove
local getTime = CurTime -- Using this as time benchmarking supporting game pause
local outError = error -- The function which generates error and prints it out
local outPrint = print -- The function that outputs a string into the console

-- Register the type up here before the extension registration so that the state control still works
registerType("stcontrol", "xsc", nil,
  nil,
  nil,
  function(retval)
    if(retval == nil) then return end
    if(not istable(retval)) then outError("Return value is neither nil nor a table, but a "..type(retval).."!",0) end
  end,
  function(v)
    return (not istable(v))
  end
)

--[[ ****************************************************************************** ]]

E2Lib.RegisterExtension("stcontrol", true, "Lets E2 chips have dedicated state control objects")

local gtComponent = {"P", "I", "D"} -- The names of each term. This is used for indexing and checking
local gsFormatPID = "(%s%s%s)" -- The general type format for the control power setup
local gtMissName  = {"Xx", "X", "Nr"} -- This is a placeholder for missing/default type
local gtStoreOOP  = {} -- Store state controllers here linked to the entity of the E2
local gsVarPrefx  = "wire_expression2_stcontrol" -- This is used for variable prefix
local gnServContr = bitBor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_PRINTABLEONLY)
local varMaxTotal = CreateConVar(gsVarPrefx.."_max" , 20, gnServContr, "E2 StControl maximum count")

local function getSign(nV) return ((nV > 0 and 1) or (nV < 0 and -1) or 0) end
local function getValue(kV,eV,pV) return (kV*getSign(eV)*mathAbs(eV)^pV) end

local function remValue(tSrc, aKey, bCall)
  tSrc[aKey] = nil; if(bCall) then collectgarbage() end
end

local function logError(sM, ...)
  outError("E2:stcontrol:"..tostring(sM)); return ...
end

local function logStatus(sM, ...)
  outPrint("E2:stcontrol:"..tostring(sM)); return ...
end

local function getControllersTotal() local nAll = 0
  for ent, con in pairs(gtStoreOOP) do nAll = nAll + #con end; return nAll
end

local function remControllersEntity(eChip)
  if(not (eChip and eChip:IsValid())) then return end
  local tCon = gtStoreOOP[eChip]; if(not next(tCon)) then return end
  local mCon = #tCon; for ID = 1, mCon do tableRemove(tCon) end
  logStatus("Clear ["..tostring(mCon).."] items for "..tostring(eChip))
end

local function setGains(oStCon, vP, vI, vD, bZ)
  if(not oStCon) then return logError("Object missing", nil) end
  local nP, nI = (tonumber(vP) or 0), (tonumber(vI) or 0)
  local nD, sT = (tonumber(vD) or 0), "" -- Store control type
  if(vP and ((nP > 0) or (bZ and nP >= 0))) then oStCon.mkP = nP end
  if(vI and ((nI > 0) or (bZ and nI >= 0))) then oStCon.mkI = (nI / 2)
    if(oStCon.mbCmb) then oStCon.mkI = oStCon.mkI * oStCon.mkP end
  end -- Available settings with non-zero coefficients
  if(vD and ((nD > 0) or (bZ and nD >= 0))) then oStCon.mkD = nD
    if(oStCon.mbCmb) then oStCon.mkD = oStCon.mkD * oStCon.mkP end
  end -- Build control type
  for key, val in pairs(gtComponent) do
    if(oStCon["mk"..val] > 0) then sT = sT..val end end
  if(sT:len() == 0) then sT = gtMissName[2]:rep(3) end -- Check for invalid control
  oStCon.mType[2] = sT; collectgarbage(); return oStCon
end

local function getCode(nN)
  local nW, nF = mathModf(nN, 1)
  if(nN == 1) then return gtMissName[3] end -- [Natural conventional][y=k*x]
  if(nN ==-1) then return "Rr" end -- [Reciprocal relation][y=1/k*x]
  if(nN == 0) then return "Sr" end -- [Sign function relay term][y=k*sign(x)]
  if(nF ~= 0) then
    if(nW ~= 0) then
      if(nF > 0) then return "Gs" end -- [Power positive fractional][y=x^( n); n> 1]
      if(nF < 0) then return "Gn" end -- [Power negative fractional][y=x^(-n); n<-1]
    else
      if(nF > 0) then return "Fs" end -- [Power positive fractional][y=x^( n); 0<n< 1]
      if(nF < 0) then return "Fn" end -- [Power negative fractional][y=x^(-n); 0>n>-1]
    end
  else
    if(nN > 0) then return "Ex" end -- [Exponential relation][y=x^n]
    if(nN < 0) then return "Er" end -- [Reciprocal-exp relation][y=1/x^n]
  end; return gtMissName[1] -- [Invalid settings][N/A]
end

local function setPower(oStCon, vP, vI, vD)
  if(not oStCon) then return logError("Object missing", nil) end
  oStCon.mpP, oStCon.mpI, oStCon.mpD = (tonumber(vP) or 1), (tonumber(vI) or 1), (tonumber(vD) or 1)
  oStCon.mType[1] = gsFormatPID:format(getCode(oStCon.mpP), getCode(oStCon.mpI), getCode(oStCon.mpD))
  return oStCon
end

local function resState(oStCon)
  if(not oStCon) then return logError("Object missing", nil) end
  oStCon.mErrO, oStCon.mErrN = 0, 0 -- Reset the error
  oStCon.mvCon, oStCon.meInt = 0, true -- Control value and integral enabled
  oStCon.mvP, oStCon.mvI, oStCon.mvD = 0, 0, 0 -- Term values
  oStCon.mTimN = getTime(); oStCon.mTimO = oStCon.mTimN; -- Update clock
  return oStCon
end

local function getType(oStCon)
  if(not oStCon) then local mP, mT = gtMissName[1], gtMissName[2]
    return (gsFormatPID:format(mP,mP,mP).."-"..mT:rep(3))
  end; return tableConcat(oStCon.mType, "-")
end

local function newItem(eChip, nTo)
  if(not (eChip and eChip:IsValid())) then
    return logError("Entity invalid", nil) end
  local nTot, nMax = getControllersTotal(), varMaxTotal:GetInt()
  if(nMax <= 0) then remControllersEntity(eChip)
    return logError("Limit invalid ["..tostring(nMax).."]", nil) end  
  if(nTot >= nMax) then remControllersEntity(eChip)
    return logError("Count reached ["..tostring(nMax).."]", nil) end
  local oStCon = {}; oStCon.mnTo = tonumber(nTo) -- Place to store the object
  if(oStCon.mnTo and oStCon.mnTo <= 0) then remControllersEntity(eChip)
    return logError("Delta mismatch ["..tostring(oStCon.mnTo).."]", nil) end
  local sT = gsFormatPID:format(gtMissName[3], gtMissName[3], gtMissName[3])
  oStCon.mTimN = getTime(); oStCon.mTimO = oStCon.mTimN; -- Reset clock
  oStCon.mErrO, oStCon.mErrN, oStCon.mType = 0, 0, {sT,gtMissName[2]:rep(3)} -- Error state values
  oStCon.mvCon, oStCon.mTimB, oStCon.meInt = 0, 0, true -- Control value and integral enabled
  oStCon.mBias, oStCon.mSatD, oStCon.mSatU = 0, nil, nil -- Saturation limits and settings
  oStCon.mvP, oStCon.mvI, oStCon.mvD = 0, 0, 0 -- Term values
  oStCon.mkP, oStCon.mkI, oStCon.mkD = 0, 0, 0 -- P, I and D term gains
  oStCon.mpP, oStCon.mpI, oStCon.mpD = 1, 1, 1 -- Raise the error to power of that much
  oStCon.mbCmb, oStCon.mbInv, oStCon.mbOn, oStCon.mbMan = false, false, false, false
  oStCon.mvMan, oStCon.mID = 0, eChip -- Configure manual mode and store indexing
  local tCon = gtStoreOOP[eChip]; if(not tCon) then gtStoreOOP[eChip] = {}; tCon = gtStoreOOP[eChip] end
  eChip:CallOnRemove("stcontrol_remove_ent", remControllersEntity)
  tableInsert(tCon, oStCon); collectgarbage(); return oStCon
end

local function tuneZieglerNichols(oStCon, uK, uT, sM)
  if(not oStCon) then return logError("Object missing", nil) end
  local sM, sT = tostring(sM or ""), oStCon.mType[2]
  local uK, uT = (tonumber(uK) or 0), (tonumber(uT) or 0)
  if(uK <= 0 or uT <= 0) then return oStCon end
  if(sT == "P") then return setGains(oStCon, (0.5*uK), 0, 0, true)
  elseif(sT == "PI") then return setGains(oStCon, (0.45*uK), (1.2/uT), 0, true)
  elseif(sT == "PD") then return setGains(oStCon, (0.80*uK), 0, (uT/8), true)
  elseif(sT == "PID") then
    if    (sM == "classic") then return setGains(oStCon, 0.60 * uK, 2.0 / uT, uT / 8.0)
    elseif(sM == "pessen" ) then return setGains(oStCon, (7*uK)/10, 5/(2*uT), (3*uT)/20)
    elseif(sM == "sovershoot") then return setGains(oStCon, (uK/3), (2/uT), (uT/3))
    elseif(sM == "novershoot") then return setGains(oStCon, (uK/5), (2/uT), (uT/3))
    else return logError("PID tuning method unsuppoerted <"..sM..">", oStCon) end
  else return logError("Controller type unsuppoerted <"..sT..">", oStCon) end
end

local function tuneAstromHagglund()
  -- TODO
end


--[[ **************************** CONTROLLER **************************** ]]

registerOperator("ass", "xsc", "xsc", function(self, args)
  local lhs, op2, scope = args[2], args[3], args[4]
  local rhs = op2[1](self, op2)
  self.Scopes[scope][lhs] = rhs
  self.Scopes[scope].vclk[lhs] = true
  return rhs
end)

__e2setcost(1)
e2function stcontrol noStControl()
  return nil
end

__e2setcost(20)
e2function stcontrol newStControl()
  return newItem(self.entity)
end

__e2setcost(20)
e2function stcontrol newStControl(number nTo)
  return newItem(self.entity, nTo)
end

__e2setcost(1)
e2function number maxStControl()
  return varMaxTotal:GetInt()
end

__e2setcost(1)
e2function number allStControl()
  return getControllersTotal()
end

__e2setcost(15)
e2function number stcontrol:remSelf()
  if(not this) then return 0 end
  local tCon = gtStoreOOP[this.mID]; if(not tCon) then return 0 end
  for ID = 1, #tCon do if(tCon[ID] == this) then tableRemove(tCon, ID); break end
  end; return 1
end

__e2setcost(20)
e2function stcontrol stcontrol:getCopy()
  return newItem(self, this.mnTo)
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainP(number nP)
  return setGains(this, nP, nil, nil)
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainI(number nI)
  return setGains(this, nil, nI, nil)
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainD(number nD)
  return setGains(this, nil, nil, nD)
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainPI(number nP, number nI)
  return setGains(this, nP, nI, nil)
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainPI(vector2 vV)
  return setGains(this, vV[1], vV[2], nil)
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainPI(array aA)
  return setGains(this, aA[1], aA[2], nil)
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainPD(number nP, number nD)
  return setGains(this, nP, nil, nD)
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainPD(vector2 vV)
  return setGains(this, vV[1], nil, vV[2])
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainPD(array aA)
  return setGains(this, aA[1], nil, aA[2])
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainID(number nI, number nD)
  return setGains(this, nil, nI, nD)
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainID(vector2 vV)
  return setGains(this, nil, vV[1], vV[2])
end

__e2setcost(7)
e2function stcontrol stcontrol:setGainID(array aA)
  return setGains(this, nil, aA[1], aA[2])
end

__e2setcost(7)
e2function stcontrol stcontrol:setGain(number nP, number nI, number nD)
  return setGains(this, nP, nI, nD)
end

__e2setcost(7)
e2function stcontrol stcontrol:setGain(array aA)
  return setGains(this, aA[1], aA[2], aA[3])
end

__e2setcost(7)
e2function stcontrol stcontrol:setGain(vector vV)
  return setGains(this, vV[1], vV[2], vV[3])
end

__e2setcost(7)
e2function stcontrol stcontrol:remGainP()
  return setGains(this, 0, nil, nil, true)
end

__e2setcost(7)
e2function stcontrol stcontrol:remGainI()
  return setGains(this, nil, 0, nil, true)
end

__e2setcost(7)
e2function stcontrol stcontrol:remGainD()
  return setGains(this, nil, nil, 0, true)
end

__e2setcost(7)
e2function stcontrol stcontrol:remGainPI()
  return setGains(this, 0, 0, nil, true)
end

__e2setcost(7)
e2function stcontrol stcontrol:remGainPD()
  return setGains(this, 0, nil, 0, true)
end

__e2setcost(7)
e2function stcontrol stcontrol:remGainID()
  return setGains(this, nil, 0, 0, true)
end

__e2setcost(7)
e2function stcontrol stcontrol:remGain()
  return setGains(this, 0, 0, 0, true)
end

__e2setcost(3)
e2function array stcontrol:getGain()
  if(not this) then return {0,0,0} end
  return {this.mkP, this.mkI, this.mkD}
end

__e2setcost(3)
e2function vector stcontrol:getGain()
  if(not this) then return {0,0,0} end
  return {this.mkP, this.mkI, this.mkD}
end

__e2setcost(3)
e2function array stcontrol:getGainPI()
  if(not this) then return {0,0} end
  return {this.mkP, this.mkI}
end

__e2setcost(3)
e2function vector2 stcontrol:getGainPI()
  if(not this) then return {0,0} end
  return {this.mkP, this.mkI}
end

__e2setcost(3)
e2function array stcontrol:getGainPD()
  if(not this) then return {0,0} end
  return {this.mkP, this.mkD}
end

__e2setcost(3)
e2function vector2 stcontrol:getGainPD()
  if(not this) then return {0,0} end
  return {this.mkP, this.mkD}
end

__e2setcost(3)
e2function array stcontrol:getGainID()
  if(not this) then return {0,0} end
  return {this.mkI, this.mkD}
end

__e2setcost(3)
e2function vector2 stcontrol:getGainID()
  if(not this) then return {0,0} end
  return {this.mkI, this.mkD}
end

__e2setcost(3)
e2function number stcontrol:getGainP()
  if(not this) then return 0 end
  return (this.mkP or 0)
end

__e2setcost(3)
e2function number stcontrol:getGainI()
  if(not this) then return 0 end
  return (this.mkI or 0)
end

__e2setcost(3)
e2function number stcontrol:getGainD()
  if(not this) then return 0 end
  return (this.mkD or 0)
end

__e2setcost(3)
e2function stcontrol stcontrol:setBias(number nN)
  if(not this) then return nil end
  this.mBias = nN; return this
end

__e2setcost(3)
e2function number stcontrol:getBias()
  if(not this) then return 0 end
  return (this.mBias or 0)
end

__e2setcost(3)
e2function string stcontrol:getType()
  return getType(this)
end

__e2setcost(3)
e2function stcontrol stcontrol:setWindup(number nD, number nU)
  if(not this) then return nil end
  if(nD < nU) then this.mSatD, this.mSatU = nD, nU end
  return this
end

__e2setcost(3)
e2function stcontrol stcontrol:setWindup(array aA)
  if(not this) then return nil end
  if(aA[1] < aA[2]) then this.mSatD, this.mSatU = aA[1], aA[2] end
  return this
end

__e2setcost(3)
e2function stcontrol stcontrol:setWindup(vector2 vV)
  if(not this) then return nil end
  if(vV[1] < vV[2]) then this.mSatD, this.mSatU = vV[1], vV[2] end
  return this
end

__e2setcost(3)
e2function stcontrol stcontrol:setWindupD(number nD)
  if(not this) then return nil end
  this.mSatD = nD; return this
end

__e2setcost(3)
e2function stcontrol stcontrol:setWindupU(number nU)
  if(not this) then return nil end
  this.mSatU = nU; return this
end

__e2setcost(3)
e2function stcontrol stcontrol:remWindup()
  if(not this) then return nil end
  remValue(this, "mSatD"); remValue(this, "mSatU", true); return this
end

__e2setcost(3)
e2function stcontrol stcontrol:remWindupD()
  if(not this) then return nil end
  remValue(this, "mSatD", true); return this
end

__e2setcost(3)
e2function stcontrol stcontrol:remWindupU()
  if(not this) then return nil end
  remValue(this, "mSatU", true); return this
end

__e2setcost(3)
e2function array stcontrol:getWindup()
  if(not this) then return {0,0} end
  return {this.mSatD, this.mSatU}
end

__e2setcost(3)
e2function vector2 stcontrol:getWindup()
  if(not this) then return {0,0} end
  return {this.mSatD, this.mSatU}
end

__e2setcost(3)
e2function number stcontrol:getWindupD()
  if(not this) then return 0 end
  return (this.mSatD or 0)
end

__e2setcost(3)
e2function number stcontrol:getWindupU()
  if(not this) then return 0 end
  return (this.mSatU or 0)
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerP(number nP)
  return setPower(this, nP, nil, nil)
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerI(number nI)
  return setPower(this, nil, nI, nil)
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerD(number nD)
  return setPower(this, nil, nil, nD)
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerPI(number nP, number nI)
  return setPower(this, nP, nI, nil)
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerPI(vector2 vV)
  return setPower(this, vV[1], vV[2], nil)
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerPI(array aA)
  return setPower(this, aA[1], aA[2], nil)
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerPD(number nP, number nD)
  return setPower(this, nP, nil, nD)
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerPD(vector2 vV)
  return setPower(this, vV[1], nil, vV[2])
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerPD(array aA)
  return setPower(this, aA[1], nil, aA[2])
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerID(number nI, number nD)
  return setPower(this, nil, nI, nD)
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerID(vector2 vV)
  return setPower(this, nil, vV[1], vV[2])
end

__e2setcost(8)
e2function stcontrol stcontrol:setPowerID(array aA)
  return setPower(this, nil, aA[1], aA[2])
end

__e2setcost(8)
e2function stcontrol stcontrol:setPower(number nP, number nI, number nD)
  return setPower(this, nP, nI, nD)
end

__e2setcost(8)
e2function stcontrol stcontrol:setPower(array aA)
  return setPower(this, aA[1], aA[2], aA[3])
end

__e2setcost(8)
e2function stcontrol stcontrol:setPower(vector vV)
  return setPower(this, vV[1], vV[2], vV[3])
end

__e2setcost(3)
e2function array stcontrol:getPower()
  if(not this) then return {0,0,0} end
  return {this.mpP, this.mpI, this.mpD}
end

__e2setcost(3)
e2function vector stcontrol:getPower()
  if(not this) then return {0,0,0} end
  return {this.mpP, this.mpI, this.mpD}
end

__e2setcost(3)
e2function number stcontrol:getPowerP()
  if(not this) then return 0 end
  return (this.mpP or 0)
end

__e2setcost(3)
e2function number stcontrol:getPowerI()
  if(not this) then return 0 end
  return (this.mpI or 0)
end

__e2setcost(3)
e2function number stcontrol:getPowerD()
  if(not this) then return 0 end
  return (this.mpD or 0)
end

__e2setcost(3)
e2function array stcontrol:getPowerPI()
  if(not this) then return {0,0} end
  return {this.mpP, this.mpI}
end

__e2setcost(3)
e2function vector2 stcontrol:getPowerPI()
  if(not this) then return {0,0} end
  return {this.mpP, this.mpI}
end

__e2setcost(3)
e2function array stcontrol:getPowerPD()
  if(not this) then return {0,0} end
  return {this.mpP, this.mpD}
end

__e2setcost(3)
e2function vector2 stcontrol:getPowerPD()
  if(not this) then return {0,0} end
  return {this.mpP, this.mpD}
end

__e2setcost(3)
e2function array stcontrol:getPowerID()
  if(not this) then return {0,0} end
  return {this.mpI, this.mpD}
end

__e2setcost(3)
e2function vector2 stcontrol:getPowerID()
  if(not this) then return {0,0} end
  return {this.mpI, this.mpD}
end


__e2setcost(3)
e2function number stcontrol:getErrorNow()
  if(not this) then return 0 end
  return (this.mErrN or 0)
end

__e2setcost(3)
e2function number stcontrol:getErrorOld()
  if(not this) then return 0 end
  return (this.mErrO or 0)
end

__e2setcost(3)
e2function number stcontrol:getErrorDelta()
  if(not this) then return 0 end
  return (this.mErrN - this.mErrO)
end

__e2setcost(3)
e2function number stcontrol:getTimeNow()
  if(not this) then return 0 end
  return (this.mTimN or 0)
end

__e2setcost(3)
e2function number stcontrol:getTimeOld()
  if(not this) then return 0 end
  return (this.mTimO or 0)
end

__e2setcost(3)
e2function number stcontrol:getTimeDelta()
  if(not this) then return 0 end
  return ((this.mTimN or 0) - (this.mTimO or 0))
end

__e2setcost(3)
e2function number stcontrol:getTimeSample()
  if(not this) then return 0 end; local nT = this.mnTo
  return ((nT and nT > 0) and nT or 0)
end

__e2setcost(3)
e2function stcontrol stcontrol:setTimeSample(number nT)
  if(not this) then return 0 end
  this.mnTo = ((nT and nT > 0) and nT or nil)
  return this
end

__e2setcost(3)
e2function stcontrol stcontrol:remTimeSample()
  if(not this) then return 0 end
  remValue(this, "mnTo", true); return this
end

__e2setcost(3)
e2function number stcontrol:getTimeBench()
  if(not this) then return 0 end
  return (this.mTimB or 0)
end

__e2setcost(3)
e2function number stcontrol:getTimeRatio()
  if(not this) then return 0 end
  local timDt = (this.mTimN - this.mTimO)
  if(timDt == 0) then return 0 end
  return ((this.mTimB or 0) / timDt)
end

__e2setcost(3)
e2function stcontrol stcontrol:setIsIntegrating(number nN)
  if(not this) then return nil end
  this.meInt = (nN ~= 0); return this
end

__e2setcost(3)
e2function number stcontrol:isIntegrating()
  if(not this) then return 0 end
  return (this.meInt and 1 or 0)
end

__e2setcost(3)
e2function stcontrol stcontrol:setIsCombined(number nN)
  if(not this) then return nil end
  this.mbCmb = (nN ~= 0); return this
end

__e2setcost(3)
e2function number stcontrol:isCombined()
  if(not this) then return 0 end
  return (this.mbCmb and 1 or 0)
end

__e2setcost(3)
e2function stcontrol stcontrol:setIsManual(number nN)
  if(not this) then return nil end
  this.mbMan = (nN ~= 0); return this
end

__e2setcost(3)
e2function number stcontrol:isManual()
  if(not this) then return 0 end
  return (this.mbMan and 1 or 0)
end

__e2setcost(3)
e2function stcontrol stcontrol:setManual(number nN)
  if(not this) then return nil end
  this.mvMan = nN; return this
end

__e2setcost(3)
e2function number stcontrol:getManual()
  if(not this) then return 0 end
  return (this.mvMan or 0)
end

__e2setcost(3)
e2function stcontrol stcontrol:setIsInverted(number nN)
  if(not this) then return nil end
  this.mbInv = (nN ~= 0); return this
end

__e2setcost(3)
e2function number stcontrol:isInverted()
  if(not this) then return 0 end
  return (this.mbInv and 1 or 0)
end

__e2setcost(3)
e2function stcontrol stcontrol:setIsActive(number nN)
  if(not this) then return nil end
  this.mbOn = (nN ~= 0); return this
end

__e2setcost(3)
e2function number stcontrol:isActive()
  if(not this) then return 0 end
  return (this.mbOn and 1 or 0)
end

__e2setcost(3)
e2function number stcontrol:getControl()
  if(not this) then return 0 end
  return (this.mvCon or 0)
end

__e2setcost(3)
e2function array stcontrol:getControlTerm()
  if(not this) then return {0,0,0} end
  return {this.mvP, this.mvI, this.mvD}
end

__e2setcost(3)
e2function vector stcontrol:getControlTerm()
  if(not this) then return {0,0,0} end
  return {this.mvP, this.mvI, this.mvD}
end

__e2setcost(3)
e2function number stcontrol:getControlTermP()
  if(not this) then return 0 end
  return (this.mvP or 0)
end

__e2setcost(3)
e2function number stcontrol:getControlTermI()
  if(not this) then return 0 end
  return (this.mvI or 0)
end

__e2setcost(3)
e2function number stcontrol:getControlTermD()
  if(not this) then return 0 end
  return (this.mvD or 0)
end

__e2setcost(3)
e2function stcontrol stcontrol:resState()
  return resState(this)
end

__e2setcost(20)
e2function stcontrol stcontrol:setState(number nR, number nY)
  if(not this) then return nil end
  if(this.mbOn) then
    if(this.mbMan) then this.mvCon = (this.mvMan + this.mBias); return this end
    this.mTimO = this.mTimN; this.mTimN = getTime()
    this.mErrO = this.mErrN; this.mErrN = (this.mbInv and (nY-nR) or (nR-nY))
    local timDt = (this.mnTo and this.mnTo or (this.mTimN - this.mTimO))
    if(this.mkP > 0) then -- This does not get affected by the time and just multiplies
      this.mvP = getValue(this.mkP, this.mErrN, this.mpP) end
    if((this.mkI > 0) and (this.mErrN ~= 0) and this.meInt and (timDt > 0)) then -- I-Term
      local arInt = (this.mErrN + this.mErrO) * timDt -- Integral error function area
      this.mvI = getValue(this.mkI * timDt, arInt, this.mpI) + this.mvI end
    if((this.mkD > 0) and (this.mErrN ~= this.mErrO) and (timDt > 0)) then -- D-Term
      local arDif = (this.mErrN - this.mErrO) / timDt -- Derivative dY/dT
      this.mvD = getValue(this.mkD * timDt, arDif, this.mpD) else this.mvD = 0 end
    this.mvCon = this.mvP + this.mvI + this.mvD -- Calculate the control signal
    if(this.mSatD and this.mvCon < this.mSatD) then -- Saturate lower limit
      this.mvCon, this.meInt = this.mSatD, false -- Integral is disabled
    elseif(this.mSatU and this.mvCon > this.mSatU) then -- Saturate upper limit
      this.mvCon, this.meInt = this.mSatU, false -- Integral is disabled
    else this.meInt = true end -- Saturation disables the integrator
    this.mvCon = (this.mvCon + this.mBias) -- Apply the saturated signal bias
    this.mTimB = (getTime() - this.mTimN) -- Benchmark the process
  else return resState(this) end; return this
end

__e2setcost(7)
e2function stcontrol stcontrol:tuneZN(number uK, number, uT)
  return tuneZieglerNichols(this, uK, uT)
end

__e2setcost(7)
e2function stcontrol stcontrol:tuneZN(number uK, number, uT, string sM)
  return tuneZieglerNichols(this, uK, uT, sM)
end

__e2setcost(15)
e2function stcontrol stcontrol:dumpConsole(string sI)
  logStatus("["..sI.."]["..tostring(this.mnTo or gtMissName[2]).."]["..getType(this).."]["..tostring(this.mTimN).."] Data:")
  logStatus(" Human: ["..tostring(this.mbMan).."] {V="..tostring(this.mvMan)..", B="..tostring(this.mBias).."}" )
  logStatus(" Gains: {P="..tostring(this.mkP)..", I="..tostring(this.mkI)..", D="..tostring(this.mkD).."}")
  logStatus(" Power: {P="..tostring(this.mpP)..", I="..tostring(this.mpI)..", D="..tostring(this.mpD).."}")
  logStatus(" Limit: {D="..tostring(this.mSatD)..", U="..tostring(this.mSatU).."}")
  logStatus(" Error: {O="..tostring(this.mErrO)..", N="..tostring(this.mErrN).."}")
  logStatus(" Value: ["..tostring(this.mvCon).."] {P="..tostring(this.mvP)..", I="..tostring(this.mvI)..", D=" ..tostring(this.mvD).."}")
  logStatus(" Flags: ["..tostring(this.mbOn).."] {C="..tostring(this.mbCmb)..", R=" ..tostring(this.mbInv)..", I="..tostring(this.meInt).."}")
  return this -- The dump method
end
