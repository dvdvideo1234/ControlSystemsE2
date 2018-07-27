local common = require('common')
common.addPathLibrary("E:/Documents/Lua-Projs/ZeroBraineIDE/myprograms/wiki-extract","*.lua")
local wikilib = require('wikilib')

local API = {
  NAME = "StControl",
  SETS = {
    __err = true
  },
  POOL = {
    {name="MAKE",cols={"Instance.creator", "Out", "Description"},size={50,5,13}},
    {name="APPLY",cols={"Class.methods", "Out", "Description"},size={50,5,13}},
  },
  FILE = {
    base = "E:/Documents/Lua-Projs/SVN/ControlSystemsE2/",
    path = "data/wiki",
    slua = "lua/entities/gmod_wire_expression2/core/custom"
  },
  TYPE = {
    E2 = "stcontrol",
    __obj = "xsc",
    __pic = false,
    __tfm = "type-%s.jpg",
    __rty = "ref-%s",
    __rbr = "[ref-%s]: %s",
    __ref = "![ref-%s]: %s",
    __img = "![image][%s]",
    link = "https://raw.githubusercontent.com/dvdvideo1234/ControlSystemsE2/master/data/pictures/types/%s",
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
  },

  REPLACE = {
    __key = "###", -- The key tells what patternis to be raplaced
    ["MASK"] = "[###](https://wiki.garrysmod.com/page/Enums/###)",
    ["COLLISION_GROUP"] = "[COLLISION_GROUP](https://wiki.garrysmod.com/page/Enums/###)"
  }
}

API.RETURN = {
  PREF = {
    ["dump"] = API.TYPE.__obj,
    ["res"] = API.TYPE.__obj,
    ["set"] = API.TYPE.__obj,
    ["upd"] = API.TYPE.__obj,
    ["smp"] = API.TYPE.__obj,
    ["add"] = API.TYPE.__obj,
    ["rem"] = API.TYPE.__obj,
    ["no"]  = API.TYPE.__obj,
    ["new"] = API.TYPE.__obj,
    ["is"] = "n"
  },
  MATCH = {}
}

local E2Helper = {}
E2Helper.Descriptions = {}

------------------------------------------------------PUT E2 DESCRIPTION HERE------------------------------------------------------


------------------------------------------------------PUT E2 DESCRIPTION HERE------------------------------------------------------

wikilib.updateAPI(API, DSC)
wikilib.makeReturnValues(API)
wikilib.printDescriptionTable(API, DSC, 1)
wikilib.printDescriptionTable(API, DSC, 2)
wikilib.printTypeReference(API)
wikilib.printTypeTable(API)
