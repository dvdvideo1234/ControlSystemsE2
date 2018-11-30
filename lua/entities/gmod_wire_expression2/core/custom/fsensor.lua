--[[ ******************************************************************************
 My custom flash sensor tracer type ( Based on wire rangers )
****************************************************************************** ]]--

local next = next
local Angle = Angle
local Vector = Vector
local tostring = tostring
local tonumber = tonumber
local LocalToWorld = LocalToWorld
local WorldToLocal = WorldToLocal
local bitBor = bit.bor
local mathAbs = math.abs
local mathClamp = math.Clamp
local tableRemove = table.remove
local utilTraceLine = util.TraceLine
local utilGetSurfacePropName = util.GetSurfacePropName
local outError = error -- The function which generates error and prints it out
local outPrint = print -- The function that outputs a string into the console

local gtSet = {
  TYP = {"fsensor", "xfs"},
  VAR = "wire_expression2_",
  ID  = {__top = 0, __all = 0}, -- TOP > ID of the last taken. ALL > Total objects
  ZER = {
    S = "",            -- Empty string to use instead of creating one everywhere
    A = Angle (0,0,0), -- Dummy zero angle for transformations
    V = Vector(0,0,0)  -- Dummy zero vector for transformations
  },
  MXL = 50000, -- The tracer maximum length just about one cube map
  CBN = {[true]=1,[false]=0}, -- This is used to convert between GLua boolean and wire boolean
  ECH = {["#empty"]=true} -- Variable being set to empty string
}
-- Pre-processing
gtSet.VAR = gtSet.VAR..gtSet.TYP[1]
gtSet.ECH[gtSet.ZER.S] = true

-- Register the type up here before the extension registration so that the fsensor still works
registerType(gtSet.TYP[1], gtSet.TYP[2], nil,
  nil,
  nil,
  function(retval)
    if(retval == nil) then return end
    if(not istable(retval)) then outError("Return value is neither nil nor a table, but a "..type(retval).."!",0) end
  end,
  function(v)
    return (not istable(v)) or (not v.StartPos)
  end
)

--[[ ****************************************************************************** ]]

E2Lib.RegisterExtension(gtSet.TYP[1], true, "Lets E2 chips trace ray attachments and check for hits.")

local gtMethList  = {} -- Placeholder for blacklist and convar prefix
local gnServContr = bitBor(FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_PRINTABLEONLY)
local varMethSkip = CreateConVar(gtSet.VAR.."_skip", gtSet.ZER.S, gnServContr, "E2 FSensor entity method black list")
local varMethOnly = CreateConVar(gtSet.VAR.."_only", gtSet.ZER.S, gnServContr, "E2 FSensor entity method white list")
local varMaxTotal = CreateConVar(gtSet.VAR.."_max" , 30, gnServContr, "E2 FSensor maximum count")
local gsVNS, gsVNO = varMethSkip:GetName(), varMethOnly:GetName()

local function isEntity(vE)
  return (vE and vE:IsValid())
end

local function isHere(vV)
  return (vV ~= nil)
end

local function remValue(tSrc, aKey)
  tSrc[aKey] = nil; collectgarbage();
end

local function logError(sM, ...)
  outError("E2:fsensor:"..tostring(sM)); return ...
end

local function logStatus(sM, ...)
  outPrint("E2:fsensor:"..tostring(sM)); return ...
end

local function convArrayKeys(tA)
  if(not tA) then return nil end
  if(not next(tA)) then return nil end
  local nE = #tA; for ID = 1, #tA do local key = tA[ID]
    if(not gtSet.ECH[key]) then
      tA[key] = true end; remValue(tA, ID)
  end; return ((tA and next(tA)) and tA or nil)
end

cvars.RemoveChangeCallback(gsVNS, gsVNS.."_call")
cvars.AddChangeCallback(gsVNS, function(sVar, vOld, vNew)
  gtMethList.SKIP = convArrayKeys(("/"):Explode(tostring(vNew or gtSet.ZER.S)))
end, gsVNS.."_call")

cvars.RemoveChangeCallback(gsVNO, gsVNO.."_call")
cvars.AddChangeCallback(gsVNO, function(sVar, vOld, vNew)
  gtMethList.ONLY = convArrayKeys(("/"):Explode(tostring(vNew or gtSet.ZER.S)))
end, gsVNO.."_call")

local function convDirLocal(oFSen, vE, vA)
  if(not oFSen) then return {0,0,0} end
  local oD, oE = oFSen.Dir, (vE or oFSen.Ent)
  if(not (isEntity(oE) or vA)) then return {oD[1], oD[2], oD[3]} end
  local oV, oA = Vector(oD[1], oD[2], oD[3]), (vA and vA or oE:GetAngles())
  return {oV:Dot(oA:Forward()), -oV:Dot(oA:Right()), oV:Dot(oA:Up())}
end

local function convDirWorld(oFSen, vE, vA)
  if(not oFSen) then return {0,0,0} end
  local oD, oE = oFSen.Dir, (vE or oFSen.Ent)
  if(not (isEntity(oE) or vA)) then return {oD[1], oD[2], oD[3]} end
  local oV, oA = Vector(oD[1], oD[2], oD[3]), (vA and vA or oE:GetAngles())
  oV:Rotate(oA); return {oV[1], oV[2], oV[3]}
end

local function convOrgEnt(oFSen, sF, vE)
  if(not oFSen) then return {0,0,0} end
  local oO, oE = oFSen.Pos, (vE or oFSen.Ent)
  if(not isEntity(oE)) then return {oO[1], oO[2], oO[3]} end
  local oV = Vector(oO[1], oO[2], oO[3])
  oV:Set(oE[sF](oE, oV)); return {oV[1], oV[2], oV[3]}
end

local function convOrgUCS(oFSen, sF, vP, vA)
  if(not oFSen) then return {0,0,0} end
  local oO, oE = oFSen.Pos, (vE or oFSen.Ent)
  if(not isEntity(oE)) then return {oO[1], oO[2], oO[3]} end
  local oV, vN, aN = Vector(oO[1], oO[2], oO[3])
  if(sF == "LocalToWorld") then
    vN, aN = LocalToWorld(oV, gtSet.ZER.A, vP, vA); oV:Set(vN)
  elseif(sF == "WorldToLocal") then
    vN, aN = WorldToLocal(oV, gtSet.ZER.A, vP, vA); oV:Set(vN)
  end; return {oV[1], oV[2], oV[3]}
end

--[[ Returns the hit status based on filter parameters
 * oF > The filter to be checked
 * vK > Value key to be checked
 * Returns:
 * 1) The status of the filter (1,2,3)
 * 2) The value to return for the status
]] local vHit, vSkp, vNop = true, nil, nil
local function getHitStatus(oF, vK)
  -- Skip current setting on empty data type
  if(not oF.TYPE) then return 1, vNop end
  local tO, tS = oF.ONLY, oF.SKIP
  if(tO and isHere(next(tO))) then if(tO[vK]) then
    return 3, vHit else return 2, vSkp end end
  if(tS and isHere(next(tS))) then if(tS[vK]) then
    return 2, vSkp else return 1, vNop end end
  return 1, vNop -- Check next setting on empty table
end

local function newHitFilter(oFSen, oChip, sM)
  if(not oFSen) then return 0 end -- Check for available method
  if(sM:sub(1,3) ~= "Get" and sM:sub(1,2) ~= "Is" and sM ~= gtSet.ZER.S) then
    return logError("Method <"..sM.."> disabled", 0) end
  local tO = gtMethList.ONLY; if(tO and isHere(next(tO)) and not tO[sM]) then
    return logError("Method <"..sM.."> use only", 0) end
  local tS = gtMethList.SKIP; if(tS and isHere(next(tS)) and tS[sM]) then
    return logError("Method <"..sM.."> use skip", 0) end
  if(not oChip.entity[sM]) then -- Check for available method
    return logError("Method <"..sM.."> mismatch", 0) end
  local tHit = oFSen.Hit; if(tHit.__ID[sM]) then -- Check for available method
    return logError("Method <"..sM.."> exists", 0) end
  tHit.__top = (tHit.__top + 1); tHit[tHit.__top] = {CALL=sM}
  tHit.__ID[sM] = tHit.__top; collectgarbage(); return (tHit.__top)
end

local function remHitFilter(oFSen, sM)
  if(not oFSen) then return nil end
  local tHit = oFSen.Hit; tHit.__top = (tHit.__top - 1)
  tableRemove(tHit, tHit.__ID[sM]); remValue(tHit.__ID,sM); return oFSen
end

local function setHitFilter(oFSen, oChip, sM, sO, vV, bS)
  if(not oFSen) then return nil end
  local tHit, sTyp = oFSen.Hit, type(vV) -- Obtain hit filter location
  local nID = tHit.__ID[sM]; if(not isHere(nID)) then 
    nID = newHitFilter(oFSen, oChip, sM)
  end -- Obtain the current data index
  local tID = tHit[nID]; if(not tID.TYPE) then tID.TYPE = type(vV) end
  if(tID.TYPE ~= sTyp) then -- Check the current data type and prevent the user from messing up
    return logError("Type "..sTyp.." mismatch <"..tID.TYPE.."@"..sM..">", oFSen) end
  if(not tID[sO]) then tID[sO] = {} end
  if(sM:sub(1,2) == "Is" and sTyp == "number") then 
    tID[sO][((vV ~= 0) and 1 or 0)] = bS
  else tID[sO][vV] = bS end; collectgarbage(); return oFSen
end

local function convHitValue(oEnt, sM) local vV = oEnt[sM](oEnt)
  if(sM:sub(1,2) == "Is") then vV = gtSet.CBN[vV] end; return vV
end

local function newItem(vEnt, vPos, vDir, nLen)
  local nTop, nAll = gtSet.ID.__top, gtSet.ID.__all
  if(nAll >= varMaxTotal:GetInt()) then 
    return logError("Count reached ["..nAll.."]", nil) end
  local oFSen = {Hit = {__top=0, __ID={}}}
  if(isEntity(vEnt)) then oFSen.Ent = vEnt -- Store attachment entity to manage local sampling
    oFSen.Hit.Ent = {SKIP={[vEnt]=true},ONLY={}} -- Store the base entity for ignore
  else oFSen.Hit.Ent, oFSen.Ent = {SKIP={},ONLY={}}, nil end -- Make sure the entity is cleared
  oFSen.Len = mathClamp(tonumber(nLen or 0),-gtSet.MXL,gtSet.MXL) -- How long the length is
  -- Local tracer position the trace starts from
  oFSen.Pos = Vector(vPos[1],vPos[2],vPos[3])
  -- Local tracer direction to read the data of
  oFSen.Dir = Vector(vDir[1],vDir[2],vDir[3])
  oFSen.Dir:Normalize() -- Normalize the direction
  oFSen.Dir:Mul(oFSen.Len) -- Multiply to add in real-time
  oFSen.Len = mathAbs(oFSen.Len) -- Length absolute
  -- http://wiki.garrysmod.com/page/Structures/TraceResult
  oFSen.TrO = {} -- Trace output parameters
  -- http://wiki.garrysmod.com/page/Structures/Trace
  oFSen.TrI = { -- Trace input parameters
    mask = MASK_SOLID, -- Mask telling the trace what to hit
    start = Vector(), -- The start position of the trace
    output = oFSen.TrO, -- Provide output place holder table
    endpos = Vector(), -- The end position of the trace
    filter = function(oEnt) local tHit, nS, vV = oFSen.Hit
      if(not isEntity(oEnt)) then return end
      nS, vV = getHitStatus(tHit.Ent, oEnt)
      if(nS > 1) then return vV end -- Entity found/skipped
      local nT = tHit.__top; if(nT > 0) then
        for ID = 1, nT do local sFoo = tHit[ID].CALL
          nS, vV = getHitStatus(tHit[ID], convHitValue(oEnt, sFoo))
          if(nS > 1) then return vV end -- Option skipped/selected
        end -- All options are checked then trace hit notmally
      end; return true -- Finally we register the trace hit enabled
    end, ignoreworld = false, -- Should the trace ignore world or not
    collisiongroup = COLLISION_GROUP_NONE } -- Collision group control
  nTop = (nTop + 1); oFSen.ID = nTop; gtSet.ID[nTop] = oFSen;
  nAll = (nAll + 1); gtSet.ID.__top, gtSet.ID.__all = nTop, nAll
  collectgarbage(); return oFSen
end

--[[ **************************** TRACER **************************** ]]

registerOperator("ass", gtSet.TYP[2], gtSet.TYP[2], function(self, args)
  local lhs, op2, scope = args[2], args[3], args[4]
  local rhs = op2[1](self, op2)
  self.Scopes[scope][lhs] = rhs
  self.Scopes[scope].vclk[lhs] = true
  return rhs
end)

__e2setcost(1)
e2function fsensor noFSensor()
  return nil
end

__e2setcost(20)
e2function fsensor entity:setFSensor(vector vP, vector vD, number nL)
  return newItem(this, vP, vD, nL)
end

__e2setcost(20)
e2function fsensor newFSensor(vector vP, vector vD, number nL)
  return newItem(nil, vP, vD, nL)
end

__e2setcost(20)
e2function fsensor entity:setFSensor(vector vP, vector vD)
  return newItem(this, vP, vD, 0)
end

__e2setcost(20)
e2function fsensor newFSensor(vector vP, vector vD)
  return newItem(nil, vP, vD, 0)
end

__e2setcost(20)
e2function fsensor entity:setFSensor(vector vP)
  return newItem(this, vP, {0,0,0}, 0)
end

__e2setcost(20)
e2function fsensor newFSensor(vector vP)
  return newItem(nil, vP, {0,0,0}, 0)
end

__e2setcost(20)
e2function fsensor entity:setFSensor()
  return newItem(this, {0,0,0}, {0,0,0}, 0)
end

__e2setcost(20)
e2function fsensor newFSensor()
  return newItem(nil, {0,0,0}, {0,0,0}, 0)
end

__e2setcost(1)
e2function number maxFSensor()
  return varMaxTotal:GetInt()
end

__e2setcost(1)
e2function number allFSensor()
  return gtSet.ID.__all
end

__e2setcost(15)
e2function number fsensor:remove()
  if(not this) then return 0 end
  local nTop, nAll = gtSet.ID.__top, gtSet.ID.__all
  if(this.ID == nTop) then nTop = (nTop - 1)
    while(not gtSet.ID[nTop]) do nTop = (nTop - 1) end end
  nAll = (nAll - 1); remValue(gtSet.ID, this.ID)
  gtSet.ID.__top, gtSet.ID.__all = nTop, nAll; return 1
end


__e2setcost(20)
e2function fsensor fsensor:copy()
  return newItem(this.Ent, this.Pos, this.Dir, this.Len)
end

--[[ **************************** ENTITY **************************** ]]

__e2setcost(3)
e2function fsensor fsensor:addEntityHitSkip(entity vE)
  if(not this) then return nil end
  if(not isEntity(vE)) then return nil end
  this.Hit.Ent.SKIP[vE] = true; return this
end

__e2setcost(3)
e2function fsensor fsensor:remEntityHitSkip(entity vE)
  if(not this) then return nil end
  if(not isEntity(vE)) then return nil end
  remValue(this.Hit.Ent.SKIP, vE); return this
end

__e2setcost(3)
e2function fsensor fsensor:addEntityHitOnly(entity vE)
  if(not this) then return nil end
  if(not isEntity(vE)) then return nil end
  this.Hit.Ent.ONLY[vE] = true; return this
end

__e2setcost(3)
e2function fsensor fsensor:remEntityHitOnly(entity vE)
  if(not this) then return nil end
  if(not isEntity(vE)) then return nil end
  remValue(this.Hit.Ent.ONLY, vE); return this
end

--[[ **************************** FILTER **************************** ]]

__e2setcost(3)
e2function fsensor fsensor:remHit(string sM)
  return remHitFilter(this, sM)
end

--[[ **************************** NUMBER **************************** ]]

__e2setcost(3)
e2function fsensor fsensor:addHitSkip(string sM, number vN)
  return setHitFilter(this, self, sM, "SKIP", vN, true)
end

__e2setcost(3)
e2function fsensor fsensor:remHitSkip(string sM, number vN)
  return setHitFilter(this, self, sM, "SKIP", vN, nil)
end

__e2setcost(3)
e2function fsensor fsensor:addHitOnly(string sM, number vN)
  return setHitFilter(this, self, sM, "ONLY", vN, true)
end

__e2setcost(3)
e2function fsensor fsensor:remHitOnly(string sM, number vN)
  return setHitFilter(this, self, sM, "ONLY", vN, nil)
end

--[[ **************************** STRING **************************** ]]

__e2setcost(3)
e2function fsensor fsensor:addHitSkip(string sM, string vS)
  return setHitFilter(this, self, sM, "SKIP", vS, true)
end

__e2setcost(3)
e2function fsensor fsensor:remHitSkip(string sM, string vS)
  return setHitFilter(this, self, sM, "SKIP", vS, nil)
end

__e2setcost(3)
e2function fsensor fsensor:addHitOnly(string sM, string vS)
  return setHitFilter(this, self, sM, "ONLY", vS, true)
end

__e2setcost(3)
e2function fsensor fsensor:remHitOnly(string sM, string vS)
  return setHitFilter(this, self, sM, "ONLY", vS, nil)
end

-------------------------------------------------------------------------------

__e2setcost(3)
e2function entity fsensor:getAttachEntity()
  if(not this) then return nil end; local vE = this.Ent
  if(not isEntity(vE)) then return nil end; return vE
end

__e2setcost(3)
e2function fsensor fsensor:setAttachEntity(entity eE)
  if(not this) then return nil end; local vE = this.Ent
  if(not isEntity(eE)) then return this end
  if(isEntity(vE)) then remValue(this.HEnt.SKIP, vE) end
  this.Ent = eE; this.HEnt.SKIP[eE] = true; return this
end

__e2setcost(3)
e2function number fsensor:isIgnoreWorld()
  if(not this) then return 0 end
  return (this.TrI.ignoreworld or 0)
end

__e2setcost(3)
e2function fsensor fsensor:setIsIgnoreWorld(number nN)
  if(not this) then return nil end
  this.TrI.ignoreworld = (nN ~= 0); return this
end

__e2setcost(3)
e2function vector fsensor:getOrigin()
  if(not this) then return {0,0,0} end
  return {this.Pos[1], this.Pos[2], this.Pos[3]}
end

__e2setcost(3)
e2function vector fsensor:getOriginLocal()
  return convOrgEnt(this, "WorldToLocal", nil)
end

__e2setcost(3)
e2function vector fsensor:getOriginWorld()
  return convOrgEnt(this, "LocalToWorld", nil)
end

__e2setcost(3)
e2function vector fsensor:getOriginLocal(entity vE)
  return convOrgEnt(this, "WorldToLocal", vE)
end

__e2setcost(3)
e2function vector fsensor:getOriginWorld(entity vE)
  return convOrgEnt(this, "LocalToWorld", vE)
end

__e2setcost(7)
e2function vector fsensor:getOriginLocal(vector vP, angle vA)
  return convOrgUCS(this, "WorldToLocal", vP, vA)
end

__e2setcost(7)
e2function vector fsensor:getOriginWorld(vector vP, angle vA)
  return convOrgUCS(this, "LocalToWorld", vP, vA)
end

__e2setcost(3)
e2function fsensor fsensor:setOrigin(vector vO)
  if(not this) then return nil end
  this.Pos[1], this.Pos[2], this.Pos[3] = vO[1], vO[2], vO[3]
  return this
end

__e2setcost(3)
e2function vector fsensor:getDirection()
  if(not this) then return nil end
  return {this.Dir[1], this.Dir[2], this.Dir[3]}
end

__e2setcost(3)
e2function vector fsensor:getDirectionLocal()
  return convDirLocal(this, nil, nil)
end

__e2setcost(3)
e2function vector fsensor:getDirectionWorld()
  return convDirWorld(this, nil, nil)
end

__e2setcost(3)
e2function vector fsensor:getDirectionLocal(entity vE)
  return convDirLocal(this, vE, nil)
end

__e2setcost(3)
e2function vector fsensor:getDirectionWorld(entity vE)
  return convDirWorld(this, vE, nil)
end

__e2setcost(3)
e2function vector fsensor:getDirectionLocal(angle vA)
  return convDirLocal(this, nil, vA)
end

__e2setcost(3)
e2function vector fsensor:getDirectionWorld(angle vA)
  return convDirWorld(this, nil, vA)
end

__e2setcost(3)
e2function fsensor fsensor:setDirection(vector vD)
  if(not this) then return nil end
  this.Dir[1], this.Dir[2], this.Dir[3] = vD[1], vD[2], vD[3]
  this.Dir:Normalize(); this.Dir:Mul(this.Len or 0)
  return this
end

__e2setcost(3)
e2function number fsensor:getLength()
  if(not this) then return nil end
  return (this.Len or 0)
end

__e2setcost(3)
e2function fsensor fsensor:setLength(number nL)
  if(not this) then return nil end
  this.Len = mathClamp(nL,-gtSet.MXL,gtSet.MXL)
  this.Dir:Normalize(); this.Dir:Mul(this.Len)
  this.Len = mathAbs(this.Len); return this
end

__e2setcost(3)
e2function number fsensor:getMask()
  if(not this) then return 0 end
  return (this.TrI.mask or 0)
end

__e2setcost(3)
e2function fsensor fsensor:setMask(number nN)
  if(not this) then return nil end
  this.TrI.mask = nN; return this
end

__e2setcost(3)
e2function number fsensor:getCollisionGroup()
  if(not this) then return nil end
  return (this.TrI.collisiongroup or 0)
end

__e2setcost(3)
e2function fsensor fsensor:setCollisionGroup(number nN)
  if(not this) then return nil end
  this.TrI.collisiongroup = nN; return this
end

__e2setcost(12)
e2function fsensor fsensor:smpLocal()
  if(not this) then return nil end; local eE = this.Ent
  if(not isEntity(eE)) then return this end
  local eP, eA = eE:GetPos(), eE:GetAngles()
  local trS, trE = this.TrI.start, this.TrI.endpos
  trS:Set(this.Pos); trS:Rotate(eA); trS:Add(eP)
  trE:Set(this.Dir); trE:Rotate(eA); trE:Add(trS)
  -- http://wiki.garrysmod.com/page/util/TraceLine
  utilTraceLine(this.TrI); return this
end

__e2setcost(8)
e2function fsensor fsensor:smpWorld()
  if(not this) then return nil end
  local trS, trE = this.TrI.start, this.TrI.endpos
  trS:Set(this.Pos); trE:Set(this.Dir); trE:Add(trS)
  -- http://wiki.garrysmod.com/page/util/TraceLine
  utilTraceLine(this.TrI); return this
end

__e2setcost(3)
e2function number fsensor:isHitNoDraw()
  if(not this) then return 0 end
  local trV = this.TrO.HitNoDraw
  return (trV and 1 or 0)
end

__e2setcost(3)
e2function number fsensor:isHitNonWorld()
  if(not this) then return 0 end
  local trV = this.TrO.HitNonWorld
  return (trV and 1 or 0)
end

__e2setcost(3)
e2function number fsensor:isHit()
  if(not this) then return 0 end
  local trV = this.TrO.Hit
  return (trV and 1 or 0)
end

__e2setcost(3)
e2function number fsensor:isHitSky()
  if(not this) then return 0 end
  local trV = this.TrO.HitSky
  return (trV and 1 or 0)
end

__e2setcost(3)
e2function number fsensor:isHitWorld()
  if(not this) then return 0 end
  local trV = this.TrO.HitWorld
  return (trV and 1 or 0)
end

__e2setcost(3)
e2function number fsensor:getHitBox()
  if(not this) then return 0 end
  local trV = this.TrO.HitBox
  return (trV and trV or 0)
end

__e2setcost(3)
e2function number fsensor:getMatType()
  if(not this) then return 0 end
  local trV = this.TrO.MatType
  return (trV and trV or 0)
end

__e2setcost(3)
e2function number fsensor:getHitGroup()
  if(not this) then return 0 end
  local trV = this.TrO.HitGroup
  return (trV and trV or 0)
end

__e2setcost(8)
e2function vector fsensor:getHitPos()
  if(not this) then return {0,0,0} end
  local trV = this.TrO.HitPos
  return (trV and {trV[1], trV[2], trV[3]} or {0,0,0})
end

__e2setcost(8)
e2function vector fsensor:getHitNormal()
  if(not this) then return {0,0,0} end
  local trV = this.TrO.HitNormal
  return (trV and {trV[1], trV[2], trV[3]} or {0,0,0})
end

__e2setcost(8)
e2function vector fsensor:getNormal()
  if(not this) then return {0,0,0} end
  local trV = this.TrO.Normal
  return (trV and {trV[1], trV[2], trV[3]} or {0,0,0})
end

__e2setcost(8)
e2function string fsensor:getHitTexture()
  if(not this) then return gtSet.ZER.S end
  local trV = this.TrO.HitTexture
  return tostring(trV or gtSet.ZER.S)
end

__e2setcost(8)
e2function vector fsensor:getStartPos()
  if(not this) then return {0,0,0} end
  local trV = this.TrO.StartPos
  return (trV and {trV[1], trV[2], trV[3]} or {0,0,0})
end

__e2setcost(3)
e2function number fsensor:getSurfaceProps()
  if(not this) then return 0 end
  local trV = this.TrO.SurfaceProps
  return (trV and trV or 0)
end

__e2setcost(3)
e2function string fsensor:getSurfacePropsName()
  if(not this) then return gtSet.ZER.S end
  local trV = this.TrO.SurfaceProps
  return (trV and utilGetSurfacePropName(trV) or gtSet.ZER.S)
end

__e2setcost(3)
e2function number fsensor:getPhysicsBone()
  if(not this) then return 0 end
  local trV = this.TrO.PhysicsBone
  return (trV and trV or 0)
end

__e2setcost(3)
e2function number fsensor:getFraction()
  if(not this) then return 0 end
  local trV = this.TrO.Fraction
  return (trV and trV or 0)
end

__e2setcost(3)
e2function number fsensor:getFractionLength()
  if(not this) then return 0 end
  local trV = this.TrO.Fraction
  return (trV and (trV * this.Len) or 0)
end

__e2setcost(3)
e2function number fsensor:isStartSolid()
  if(not this) then return 0 end
  local trV = this.TrO.StartSolid
  return (trV and 1 or 0)
end

__e2setcost(3)
e2function number fsensor:isAllSolid()
  if(not this) then return 0 end
  local trV = this.TrO.AllSolid
  return (trV and 1 or 0)
end

__e2setcost(3)
e2function number fsensor:getFractionLeftSolid()
  if(not this) then return 0 end
  local trV = this.TrO.FractionLeftSolid
  return (trV and trV or 0)
end

__e2setcost(3)
e2function number fsensor:getFractionLeftSolidLength()
  if(not this) then return 0 end
  local trV = this.TrO.FractionLeftSolid
  return (trV and (trV * this.Len) or 0)
end

__e2setcost(3)
e2function entity fsensor:getEntity()
  if(not this) then return nil end
  local trV = this.TrO.Entity
  return (trV and trV or nil)
end
