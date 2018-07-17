local API = {
  MAKE = {},
  APPLY = {},
  NAME = "FSensor"
}
      
local E2Helper = {}, {}, {}
E2Helper.Descriptions = {}
local re = {
  gs_key_link = "###", -- 
  ["MASK"] = "[###](https://wiki.garrysmod.com/page/Enums/###)",
  ["COLLISION_GROUP"] = "[COLLISION_GROUP](https://wiki.garrysmod.com/page/Enums/###)"
}
------------------------------------------------------PUT E2 DESCRIPTION HERE------------------------------------------------------


------------------------------------------------------PUT E2 DESCRIPTION HERE------------------------------------------------------
if(DSC) then
local t = API.MAKE
for n in pairs(DSC) do
  if(n:find(API.NAME)) then t = API.MAKE else t = API.APPLY end
  DSC[n] = DSC[n]:gsub("/","`")
  for k in pairs(re) do
    if(DSC[n]:find(k)) then
      DSC[n] = DSC[n]:gsub(k, re[k]:gsub(re.gs_key_link, k))
    end
  end
  table.insert(t, n)
end

table.sort(API.MAKE); table.sort(API.APPLY)
print("\n| Instance creator | Description |")
print("|---|---|")
for i, n in ipairs(API.MAKE) do print("| "..n.." | "..DSC[n].." |") end
print("\n| Method/Function | Description |")
print("|---|---|")
for i, n in ipairs(API.APPLY) do print("| "..n.." | "..DSC[n].." |") end
else
  print("Only God can create something from nothing. Do not expect this script to be God :P")
end