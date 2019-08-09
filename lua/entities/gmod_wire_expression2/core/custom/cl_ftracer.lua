--[[ ******************************************************************************
 My custom flash tracer type ( Based on wire rangers )
****************************************************************************** ]]--

local DSC = E2Helper.Descriptions
local xnm, xtp = "flash tracer", "xft"
local act = {"Returns","Adds","Removes","Updates","Samples","Dumps"}
local par = {"base attachment entity", "origin position", "direction vector", "length distance"}
DSC["noFTracer()"] = act[1].." invalid "..xnm.." object"
DSC["setFTracer(e:vvn)"] = act[1].." "..xnm.." local to the entity by "..par[2]..", "..par[3]..", "..par[4]
DSC["newFTracer(vvn)"] = act[1].." "..xnm.." relative to the world by "..par[2]..", "..par[3]..", "..par[4]
DSC["setFTracer(e:vv)"] = act[1].." "..xnm.." local to the entity by "..par[2]..", "..par[3]..", "..par[4].. " from "..par[3]
DSC["newFTracer(vv)"] = act[1].." "..xnm.." relative to the world by "..par[2]..", "..par[3]..", "..par[4].. " from "..par[3]
DSC["setFTracer(e:vn)"] = act[1].." "..xnm.." relative to the entity by "..par[2]..", "..par[3].. " from up, "..par[4]
DSC["newFTracer(vn)"] = act[1].." "..xnm.." relative to the world by "..par[2]..", "..par[3].. " from up, "..par[4]
DSC["setFTracer(e:v)"] = act[1].." "..xnm.." local to the entity by "..par[2]..", zero "..par[3]..", zero "..par[4]
DSC["newFTracer(v)"] = act[1].." "..xnm.." relative to the world by "..par[2]..", zero "..par[3]..", zero "..par[4]
DSC["setFTracer(e:n)"] = act[1].." "..xnm.." relative to the entity by "..par[4]..", "..par[3]..", zero "..par[4]
DSC["newFTracer(n)"] = act[1].." "..xnm.." relative to the world by "..par[4]..", "..par[3]..", zero "..par[4]
DSC["setFTracer(e:)"] = act[1].." "..xnm.." local to the entity by zero "..par[2]..", zero "..par[3]..", zero "..par[4]
DSC["newFTracer()"] = act[1].." "..xnm.." relative to the world by zero "..par[2]..", zero "..par[3]..", zero "..par[4]
DSC["sumFTracers()"] = act[1].." the used "..xnm.." count"
DSC["maxFTracers()"] = act[1].." the upper "..xnm.." count"
DSC["remSelf("..xtp..":)"] = act[3].." the "..xnm.." from the list"
DSC["getCopy("..xtp..":)"] = act[1].." "..xnm.." copy instance of the current object"
DSC["addEntHitSkip("..xtp..":e)"] = act[2].." the entity to the "..xnm.." internal ignore hit list"
DSC["remEntHitSkip("..xtp..":e)"] = act[3].." the entity from the "..xnm.." internal ignore hit list"
DSC["addEntHitOnly("..xtp..":e)"] = act[2].." the entity to the "..xnm.." internal only hit list"
DSC["remEntHitOnly("..xtp..":e)"] = act[3].." the entity from the "..xnm.." internal only hit list"
DSC["remHit("..xtp..":)"] = act[3].." all the options from the "..xnm.." internal hit preferences"
DSC["remHit("..xtp..":s)"] = act[3].." the option from the "..xnm.." internal hit preferences"
DSC["addHitSkip("..xtp..":sn)"] = act[2].." the option to the "..xnm.." internal ignore hit list"
DSC["remHitSkip("..xtp..":sn)"] = act[3].." the option from the "..xnm.." internal ignore hit list"
DSC["addHitOnly("..xtp..":sn)"] = act[2].." the option to the "..xnm.." internal hit only list"
DSC["remHitOnly("..xtp..":sn)"] = act[3].." the option from the "..xnm.." internal only hit list"
DSC["addHitSkip("..xtp..":ss)"] = act[2].." the option to the "..xnm.." internal ignore hit list"
DSC["remHitSkip("..xtp..":ss)"] = act[3].." the option from the "..xnm.." internal ignore hit list"
DSC["addHitOnly("..xtp..":ss)"] = act[2].." the option to the "..xnm.." internal hit only list"
DSC["remHitOnly("..xtp..":ss)"] = act[3].." the option from the "..xnm.." internal only hit list"
DSC["getBase("..xtp..":)" ] = act[1].." the "..par[1].." of the "..xnm
DSC["remBase("..xtp..":)" ] = act[3].." the "..par[1].." of the "..xnm
DSC["setBase("..xtp..":e)"] = act[4].." the "..par[1].." of the "..xnm
DSC["getPos("..xtp..":)"] = act[1].." "..xnm.." "..par[2]
DSC["getPosLocal("..xtp..":)"] = act[1].." "..xnm.." world "..par[2].." converted to "..par[1].." local axis"
DSC["getPosLocal("..xtp..":e)"] = act[1].." "..xnm.." world "..par[2].." converted to entity local axis"
DSC["getPosLocal("..xtp..":va)"] = act[1].." "..xnm.." world "..par[2].." converted to position/angle local axis"
DSC["getPosWorld("..xtp..":)"] = act[1].." "..xnm.." local "..par[2].." converted to "..par[1].." world axis"
DSC["getPosWorld("..xtp..":e)"] = act[1].." "..xnm.." local "..par[2].." converted to entity world axis"
DSC["getPosWorld("..xtp..":va)"] = act[1].." "..xnm.." local "..par[2].." converted to position/angle world axis"
DSC["setPos("..xtp..":v)"] = act[4].." the "..xnm.." "..par[2]
DSC["getDir("..xtp..":)"] = act[1].." "..xnm.." "..par[3]
DSC["getDirLocal("..xtp..":)"] = act[1].." "..xnm.." world "..par[3].." converted to "..par[1].." local axis"
DSC["getDirLocal("..xtp..":e)"] = act[1].." "..xnm.." world "..par[3].." converted to entity local axis"
DSC["getDirLocal("..xtp..":a)"] = act[1].." "..xnm.." world "..par[3].." converted to angle local axis"
DSC["getDirWorld("..xtp..":)"] = act[1].." "..xnm.." local "..par[3].." converted to "..par[1].." world axis"
DSC["getDirWorld("..xtp..":e)"] = act[1].." "..xnm.." local "..par[3].." converted to entity world axis"
DSC["getDirWorld("..xtp..":a)"] = act[1].." "..xnm.." local "..par[3].." converted to angle world axis"
DSC["setDir("..xtp..":v)"] = act[4].." the "..xnm.." "..par[3]
DSC["getLen("..xtp..":)"] = act[1].." "..xnm.." "..par[4]
DSC["setLen("..xtp..":n)"] = act[4].." "..xnm.." "..par[4]
DSC["getMask("..xtp..":)"] = act[1].." "..xnm.." trace hit mask enums MASK"
DSC["setMask("..xtp..":n)"] = act[4].." "..xnm.." trace hit mask enums MASK"
DSC["getStart("..xtp..":)"] = act[1].." "..xnm.." trace start poisition sent to trace-line"
DSC["getStop("..xtp..":)"] = act[1].." "..xnm.." trace stop poisition sent to trace-line"
DSC["getCollideGroup("..xtp..":)"] = act[1].." "..xnm.." trace collision group enums COLLISION_GROUP"
DSC["setCollideGroup("..xtp..":n)"] = act[4].." "..xnm.." trace collision group enums COLLISION_GROUP"
DSC["isIgnoreWorld("..xtp..":)"] = act[1].." the "..xnm.." trace `IgnoreWorld` flag"
DSC["setIsIgnoreWorld("..xtp..":n)"] = act[4].." the "..xnm.." trace `IgnoreWorld` flag"
DSC["smpLocal("..xtp..":)"  ] = act[5].." the "..xnm.." and updates the trace-result by "..par[1].." local axis"
DSC["smpLocal("..xtp..":e)" ] = act[5].." the "..xnm.." and updates the trace-result by entity position and forward vectors"
DSC["smpLocal("..xtp..":a)" ] = act[5].." the "..xnm.." and updates the trace-result by [base position | argument angle]"
DSC["smpLocal("..xtp..":v)" ] = act[5].." the "..xnm.." and updates the trace-result by [argument position | base angle]"
DSC["smpLocal("..xtp..":va)"] = act[5].." the "..xnm.." and updates the trace-result by argument [position | angle]"
DSC["smpLocal("..xtp..":ea)"] = act[5].." the "..xnm.." and updates the trace-result by argument [entity position | angle]"
DSC["smpLocal("..xtp..":ev)"] = act[5].." the "..xnm.." and updates the trace-result by argument [position | entity angle]"
DSC["smpWorld("..xtp..":)"  ] = act[5].." the "..xnm.." and updates the trace-result by the world axis"
DSC["smpWorld("..xtp..":e)" ] = act[5].." the "..xnm.." and updates the trace-result by entity position and forward vectors"
DSC["smpWorld("..xtp..":a)" ] = act[5].." the "..xnm.." and updates the trace-result by entity position and angle forward"
DSC["smpWorld("..xtp..":v)" ] = act[5].." the "..xnm.." and updates the trace-result by position vector and entity forward"
DSC["smpWorld("..xtp..":va)"] = act[5].." the "..xnm.." and updates the trace-result by argument [position | angle]"
DSC["smpWorld("..xtp..":ea)"] = act[5].." the "..xnm.." and updates the trace-result by argument [entity position | angle]"
DSC["smpWorld("..xtp..":ev)"] = act[5].." the "..xnm.." and updates the trace-result by argument [position | entity angle]"
DSC["isHitNoDraw("..xtp..":)"] = act[1].." the "..xnm.." trace-result `HitNoDraw` flag"
DSC["isHitNonWorld("..xtp..":)"] = act[1].." the "..xnm.." trace-result `HitNonWorld` flag"
DSC["isHit("..xtp..":)"] = act[1].." the "..xnm.." trace-result `Hit` flag"
DSC["isHitSky("..xtp..":)"] = act[1].." the "..xnm.." trace-result `HitSky` flag"
DSC["isHitWorld("..xtp..":)"] = act[1].." the "..xnm.." trace-result `HitWorld` flag"
DSC["getHitBox("..xtp..":)"] = act[1].." the "..xnm.." trace-result `HitBox` number"
DSC["getMatType("..xtp..":)"] = act[1].." the "..xnm.." trace-result `MatType` material type number"
DSC["getHitGroup("..xtp..":)"] = act[1].." the "..xnm.." trace-result `HitGroup` group ID number"
DSC["getHitPos("..xtp..":)"] = act[1].." the "..xnm.." trace-result `HitPos` location vector"
DSC["getHitNormal("..xtp..":)"] = act[1].." "..xnm.." trace-result surface `HitNormal` vector"
DSC["getNormal("..xtp..":)"] = act[1].." the "..xnm.." trace-result `Normal` aim vector"
DSC["getHitTexture("..xtp..":)"] = act[1].." the "..xnm.." trace-result `HitTexture` string"
DSC["getStartPos("..xtp..":)"] = act[1].." the "..xnm.." trace-result `StartPos` vector"
DSC["getSurfPropsID("..xtp..":)"] = act[1].." the "..xnm.." trace-result `SurfaceProps` ID type number"
DSC["getSurfPropsName("..xtp..":)"] = act[1].." the "..xnm.." trace-result `SurfaceProps` ID type name string"
DSC["getBone("..xtp..":)"] = act[1].." the "..xnm.." trace-result `PhysicsBone` ID number"
DSC["getFraction("..xtp..":)"] = act[1].." the "..xnm.." trace-result `Fraction` in the interval [0-1] number"
DSC["getFractionLen("..xtp..":)"] = act[1].." the "..xnm.." trace-result `Fraction` multiplied by its "..par[4].." number"
DSC["isStartSolid("..xtp..":)"] = act[1].." the "..xnm.." trace-result `StartSolid` flag"
DSC["isAllSolid("..xtp..":)"] = act[1].." the "..xnm.." trace-result `AllSolid` flag"
DSC["getFractionLS("..xtp..":)"] = act[1].." the "..xnm.." trace-result `FractionLeftSolid` in the interval [0-1] number"
DSC["getFractionLenLS("..xtp..":)"] = act[1].." the "..xnm.." trace-result `FractionLeftSolid` multiplied by its "..par[4].." number"
DSC["getEntity("..xtp..":)"] = act[1].." the "..xnm.." trace-result `Entity` entity"
DSC["dumpItem("..xtp..":n)"] = act[6].." the "..xnm.." to the chat area by number identifier"
DSC["dumpItem("..xtp..":s)"] = act[6].." the "..xnm.." to the chat area by string identifier"
DSC["dumpItem("..xtp..":sn)"] = act[6].." the "..xnm.." by number identifier in the specified area by first argument"
DSC["dumpItem("..xtp..":ss)"] = act[6].." the "..xnm.." by string identifier in the specified area by first argument"
