local common = require('common')

local wikilib = {}

local wikiMatch = {}
local wikiType = {
  list = {
    {"a", "Angle"},
    {"e", "Entity"},
    {"n", "Number"},
    {"r", "Array"},
    {"s", "String"},
    {"v", "Vector 3D"},
    {"xv2", "Vactor 2D"},
    {"xfs", "Flash sensor class"},
    {"xsc", "State controller class"},
    {"xxx", "Void value "}
  },
  idx = {
    ["angle"]     = 1,
    ["entity"]    = 2,
    ["number"]    = 3,
    ["array"]     = 4,
    ["string"]    = 5,
    ["vector"]    = 6,
    ["vector2"]   = 7,
    ["fsensor"]   = 8,
    ["stcontrol"] = 9,
    ["void"]      = 10
  }
}

local wikiFormat = {
  __tfm = "type-%s.jpg",
  __rty = "ref-%s",
  __rbr = "[ref-%s]: %s",
  __ref = "![ref-%s]: %s",
  __img = "![image][%s]"
}

local wikiRefer = { ["is"] = "n",
  __this = {"dump","res","set","upd","smp","add","rem","no","new"}
}

local function apiSortFinctionParam(a, b)
  if(table.concat(a.par) < table.concat(b.par)) then return true end
  return false
end

local function sorttMatch(tM)
  table.sort(tM, apiSortFinctionParam)
end

local function apiGetValue(API, sTab, sKey, vDef)
  local tTab = API[sTab]
  local bTab = common.isTable(tTab)
  return (bTab and tTab[sKey] or vDef)
end

function wikilib.setInternalType(API)
  local aT = wikiRefer.__this
  for ID = 1, #aT do local key = aT[ID]
    wikiRefer[key] = tostring(API.TYPE.OBJ or "xxx")
  end
end

function wikilib.updateAPI(API, DSC)
  local t = API.POOL[1]
  for n in pairs(DSC) do
    if(n:find(API.NAME)) then t = API.POOL[1] else t = API.POOL[2] end
    DSC[n] = DSC[n]:gsub("/","`")
    for k in pairs(API.REPLACE) do
      if(DSC[n]:find(k)) then
        DSC[n] = DSC[n]:gsub(k, API.REPLACE[k]:gsub(API.REPLACE.__key, k))
      end
    end
    table.insert(t, n)
  end
end

function wikilib.printTypeReference(API)
  local tT = wikiType.list
  local sL = API.TYPE.LNK
  local sT = wikiFormat.__tfm
  local fR = wikiFormat.__rbr
  for ID = 1, #tT do
    io.write(fR:format(tT[ID][1], sL:format(sT:format(tT[ID][1]))).."\n")
  end; io.write("\n")
end

function wikilib.printRow(tT)
  io.write("|"..table.concat(tT, "|").."|\n")
end

--[[
  sT > Text to process
  bP > Enable pictures
  bD > Dicable and return empry string
]]--
function wikilib.concatType(API, sT, bP, bD)
  if(bD) then return "" end; local sV = tostring(sT)
  if(sV:sub(1,1) == "/") then sV = sV:sub(2,-1) end
  local bIco = apiGetValue(API, "SETS", "icon")
  local bU = common.getPick(bP ~= nil, bP, bIco)
  if(bU) then
    local sL = apiGetValue(API,"TYPE","LNK")
    local sI = wikiFormat.__img
    local sR = wikiFormat.__rty
    local exp = common.stringExplode(sV, "/")
    for iN = 1, #exp do
      exp[iN] = sI:format(sR:format(exp[iN]))
    end
    return table.concat(exp, ",")
  else
    return sV
  end
end

function wikilib.readReturnValues(API)
  local sBas = apiGetValue(API,"FILE","base")
  local sPth = apiGetValue(API,"FILE","path")
  local sE2  = apiGetValue(API,"TYPE","E2")
  local sN = tostring(sBas)..tostring(sPth)
  if(sN:sub(-1,-1) ~= "/") then sN = sN.."/" end
  sN = sN..sE2:lower().."_rt.txt"
  local fR = io.open(sN, "r")
  if(not fR) then return end
  local sL = fR:read("*line")
  while(sL ~= nil) do
    local sT = common.stringTrim(sL)
    if(sL ~= "") then
      local tT = common.stringExplode(sT, ":")
      tT[1] = common.stringTrim(tostring(tT[1]))
      tT[2] = common.stringTrim(tostring(tT[2]))
      print("wikilib.readReturnValues", tT[1], tT[2])
      wikiMatch[tT[1]] = tT[2]
    end
    sL = fR:read("*line")
  end
end

function wikilib.convTypeE2Description(API, sT)
  return wikiType.list[wikiType.idx[sT]]
end

-- e2function stcontrol stcontrol:setPower(number nP, number nI, number nD)
function wikilib.convApiE2Description(API, sE2)
  local sE = common.stringTrim(sE2)
  if(sE:sub(1,10) == "e2function") then
    local tInfo, tTyp = {}, API.TYPE; tInfo.row = sE2
    sE = common.stringTrim(sE:sub(11, -1))
    iS = sE:find("%s", 1)
    tInfo.ret = wikilib.convTypeE2Description(API,common.stringTrim(sE:sub(1, iS)))[1]
    sE = common.stringTrim(sE:sub(iS, -1))
    iS = sE:find(":", 1, true)
    if(iS) then
      tInfo.obj = wikilib.convTypeE2Description(API,common.stringTrim(sE:sub(1, iS-1)))[1]
      sE   = common.stringTrim(sE:sub(iS+1, -1))     
    end
    iS = sE:find("(", 1, true)
    tInfo.foo = common.stringTrim(sE:sub(1, iS-1))
    sE = common.stringTrim(sE:match("%(.-%)")):sub(2,-2)
    tInfo.par = common.stringExplode(sE, ",")
    for ID = 1, #tInfo.par do
      tInfo.par[ID] = common.stringTrim(tInfo.par[ID])
      iS = tInfo.par[ID]:find(" ", 1, true)
      if(not iS) then break end
      tInfo.par[ID] = wikilib.convTypeE2Description(API,tInfo.par[ID]:sub(1, iS-1))[1]
    end; tInfo.com = tInfo.foo.."("
    if(tInfo.obj) then
      tInfo.com = tInfo.com..tInfo.obj..":" end
    for ID = 1, #tInfo.par do
      tInfo.com = tInfo.com..tInfo.par[ID]
    end; tInfo.com = tInfo.com..")"; return tInfo
  end; return nil
end

function wikilib.isValidMatch(tM)
  if(tM.__nam:sub(1,3) ~= "set") then return true end
  local tL = {}; for ID = 1, tM.__top do local vM = tM[ID]
    if(not tL[vM.com]) then tL[vM.com] = {} end
    table.insert(tL[vM.com], ID)
  end
  for api, val in pairs(tL) do
    local all = #val; if(all  > 1) then
      return common.logStatus("wikilib.isValidMatch: API <"..api.."> doubled", false)
    end
  end; return true
end

function wikilib.makeReturnValues(API)
  local sE2  = apiGetValue(API,"TYPE","E2")
  local sBas = apiGetValue(API,"FILE","base")
  local sLua = apiGetValue(API,"FILE","slua")
  local sN = tostring(sBas)..tostring(sLua)
  if(sN:sub(-1,-1) ~= "/") then
    sN = sN.."/" end; sN = sN..sE2:lower()..".lua"
  local fR = io.open(sN, "r")
  if(not fR) then return logStatus("wikilib.makeReturnValues: No file <"..sN..">") end
  local sL, tF = fR:read("*line"), wikiMatch
  while(sL ~= nil) do
    local sT = common.stringTrim(sL)
    if(sL:find("e2function")) then
      local tL = common.stringExplode(sL, " ")
      local typ, foo = tL[2], tL[3]
      local mth = (foo:find(":") or  0)
      local brk = (foo:find("%(") or -1)
      foo = foo:sub(mth+1, brk-1)
      local tP = tF[foo]; if(not tP) then
        tF[foo] = {__top = 0, __key = {}, __nam = foo}; tP = tF[foo] end
      tP.__top = tP.__top + 1
      local tInfo = wikilib.convApiE2Description(API, sL)
      tP.__key[tInfo.com] = tP.__top; tP[tP.__top] = tInfo
    end; sL = fR:read("*line")
  end; return tF
end

function wikilib.printTypeTable(API)
  local tT = wikiType.list
  local fR = wikiFormat.__img
  local sR = wikiFormat.__rty
  wikilib.printRow({"Icon", "Description"})
  wikilib.printRow({"---", "---"})
  for ID = 1, #tT do
    wikilib.printRow({fR:format(sR:format(tT[ID][1])), tT[ID][2]})
  end; io.write("\n")
end

function wikilib.printDescriptionTable(API, DSC, iN)
  local tPool = API.POOL[iN]
  if(not tPool) then return end   
  local nC, tC = #tPool.cols, {}
  local tH = {}; for ID = 1, nC do 
    tH[ID] = ("-"):rep(common.getClamp((tPool.size[ID] or tPool.cols[ID]:len()), 3))
    tC[ID] = common.stringCenter(tPool.cols[ID],tPool.size[ID],".")
  end; table.sort(tPool); tPool.data = {}
  wikilib.printRow(tC); wikilib.printRow(tH)
  local bIco = apiGetValue(API, "SETS", "icon")
  local bErr = apiGetValue(API, "SETS", "erro")
  local sObj = apiGetValue(API, "TYPE", "OBJ")
  local sV = wikilib.convTypeE2Description(API,"void")[1]
  for i, n in ipairs(tPool) do
    local arg, vars, obj = n:match("%(.-%)"), "", ""
    if(arg) then arg = arg:sub(2,-2)
      local tsk = common.stringExplode(arg,":")
      if(not arg:find(":")) then
        tsk[2], tsk[1] = tsk[1], sV end
      if(tsk[2] == "") then tsk[2] = sV end
      tsk[1], tsk[2] = common.stringTrim(tsk[1]), common.stringTrim(tsk[2])
      local k, len = 1, tsk[2]:len(); obj = "/"..tsk[1]
      while(k <= len) do local sbc = tsk[2]:sub(k,k)
        if(sbc == "x") then
          sbc = tsk[2]:sub(k, k+2); k = (k + 2) -- The end of the current type
        end; k = (k + 1)
        vars = vars.."/"..sbc
      end
    end
      
    for rmk, rmv in pairs(wikiMatch) do
      if(n:find(rmk.."%(") and rmv.__top > 0) then
        if(not wikilib.isValidMatch(rmv)) then
          if(bErr) then
            error("wikilib.printDescriptionTable: Duplicated function !") end
        end
        local ret = ""; sorttMatch(rmv)
        for ID = 1, rmv.__top do
          local api = rmv[ID]; ret = api.ret
          if(not DSC[api.com]) then
            common.logStatus("wikilib.printDescriptionTable: Description missing <"..api.row..">")
            if(bErr) then
              error("wikilib.printDescriptionTable: Description missing !") end
          end
          if(n == api.com) then
            if(ret == "") then local cap = rmk:find("%L", 1)
              if(n:find(API.NAME)) then
                ret = "/"..sObj
              elseif(cap and wikiRefer[n:sub(1,cap-1)]) then
                ret = "/"..wikiRefer[n:sub(1,cap-1)]
              else ret = "/"..sV end
            end
            
            if(obj:find(sV)) then
              wikilib.printRow({n:gsub("%(.-%)", "("..wikilib.concatType(API, vars, true)
                    ..")"), wikilib.concatType(API, ret, true), DSC[n]})      
            else
              wikilib.printRow({wikilib.concatType(API, obj , true)..":"..n:gsub("%(.-%)", "("
                      ..wikilib.concatType(API, vars, true)..")"), wikilib.concatType(API, ret, true), DSC[n]})
            end
          end
        end
      end
    end
  end
  io.write("\n")
end

return wikilib
