### What is this thing designed for ?
The `FSensor` class consists of fast preforming traces object oriented
instance that is designed to be `@persist`and initialized in expression
`first() || dupefinished()`. That way you create the tracer instance once
and you can use it as many times you need, without creating a new one.

### How to create an instance then ?
You can create local trace sensor object by attaching it to a base entity. When sampled
locally, it will use this attachment entity to orient its direction and length in pure Lua.
You can also call the class constructor without an entity to make it world-space based.

### Do you have an example by any chance ?
The internal type of the class is `xfs` and internal expression type `fsensor`, so to create 
a tracer sensor instance you can take a [look at the example](https://github.com/dvdvideo1234/ControlSystemsE2/blob/master/data/Expression2/e2_code_test_fsensor.txt).

### Can you show me the methods of the class ?
The description of the API is provided in the table below.

| Instance creator | Description |
|---|---|
| copyFSensor(xfs:) | Returns flash sensor copy instance of the current object |
| newFSensor() | Returns flash sensor relative to the world by zero origin position, zero direction vector, zero length distance |
| newFSensor(v) | Returns flash sensor relative to the world by origin position, zero direction vector, zero length distance |
| newFSensor(vv) | Returns flash sensor relative to the world by origin position, direction vector, zero length distance |
| newFSensor(vvn) | Returns flash sensor relative to the world by origin position, direction vector, length distance |
| noFSensor() | Returns invalid flash sensor object |
| setFSensor(e:) | Returns flash sensor local to the entity by zero origin position, zero direction vector, zero length distance |
| setFSensor(e:v) | Returns flash sensor local to the entity by origin position, zero direction vector, zero length distance |
| setFSensor(e:vv) | Returns flash sensor local to the entity by origin position, direction vector, zero length distance |
| setFSensor(e:vvn) | Returns flash sensor local to the entity by origin position, direction vector, length distance |

| Method/Function | Description |
|---|---|
| addEntityHitOnly(xfs:e) | Adds the entity to the flash sensor internal only hit list |
| addEntityHitSkip(xfs:e) | Adds the entity to the flash sensor internal ignore hit list |
| addHitOnly(xfs:sn) | Adds the option to the flash sensor internal hit only list |
| addHitOnly(xfs:ss) | Adds the option to the flash sensor internal hit only list |
| addHitSkip(xfs:sn) | Adds the option to the flash sensor internal ignore hit list |
| addHitSkip(xfs:ss) | Adds the option to the flash sensor internal ignore hit list |
| getAttachEntity(xfs:) | Returns the attachment entity of the flash sensor |
| getCollisionGroup(xfs:) | Returns flash sensor trace collision group enums [COLLISION_GROUP](https://wiki.garrysmod.com/page/Enums/COLLISION_GROUP) |
| getDirection(xfs:) | Returns flash sensor direction vector |
| getDirectionLocal(xfs:) | Returns flash sensor world direction vector converted to attachment entity local axis |
| getDirectionLocal(xfs:a) | Returns flash sensor world direction vector converted to angle local axis |
| getDirectionLocal(xfs:e) | Returns flash sensor world direction vector converted to entity local axis |
| getDirectionWorld(xfs:) | Returns flash sensor local direction vector converted to attachment entity world axis |
| getDirectionWorld(xfs:a) | Returns flash sensor local direction vector converted to angle world axis |
| getDirectionWorld(xfs:e) | Returns flash sensor local direction vector converted to entity world axis |
| getEntity(xfs:) | Returns the flash sensor sampled trace `Entity` entity |
| getFraction(xfs:) | Returns the flash sensor sampled trace `Fraction` in the interval [0-1] number |
| getFractionLeftSolid(xfs:) | Returns the flash sensor sampled trace `FractionLeftSolid` in the interval [0-1] number |
| getFractionLeftSolidLength(xfs:) | Returns the flash sensor sampled trace `FractionLeftSolid` multiplied by its length distance number |
| getFractionLength(xfs:) | Returns the flash sensor sampled trace `Fraction` multiplied by its length distance number |
| getHitBox(xfs:) | Returns the flash sensor sampled trace `HitBox` number |
| getHitGroup(xfs:) | Returns the flash sensor sampled trace `HitGroup` group ID number |
| getHitNormal(xfs:) | Returns flash sensor the sampled trace surface `HitNormal` vector |
| getHitPos(xfs:) | Returns the flash sensor sampled trace `HitPos` location vector |
| getHitTexture(xfs:) | Returns the flash sensor sampled trace `HitTexture` string |
| getIgnoreWorld(xfs:) | Returns the ignore world flag of the flash sensor |
| getLength(xfs:) | Returns flash sensor length distance |
| getMask(xfs:) | Returns flash sensor trace hit mask enums [MASK](https://wiki.garrysmod.com/page/Enums/MASK) |
| getMatType(xfs:) | Returns the flash sensor sampled trace `MatType` material type number |
| getNormal(xfs:) | Returns the flash sensor sampled trace `Normal` aim vector |
| getOrigin(xfs:) | Returns flash sensor origin position |
| getOriginLocal(xfs:) | Returns flash sensor world origin position converted to attachment entity local axis |
| getOriginLocal(xfs:e) | Returns flash sensor world origin position converted to entity local axis |
| getOriginLocal(xfs:va) | Returns flash sensor world origin position converted to position`angle local axis |
| getOriginWorld(xfs:) | Returns flash sensor local origin position converted to attachment entity world axis |
| getOriginWorld(xfs:e) | Returns flash sensor local origin position converted to entity world axis |
| getOriginWorld(xfs:va) | Returns flash sensor local origin position converted to position`angle world axis |
| getPhysicsBone(xfs:) | Returns the flash sensor sampled trace `PhysicsBone` ID number |
| getStartPos(xfs:) | Returns the flash sensor sampled trace `StartPos` vector |
| getSurfaceProps(xfs:) | Returns the flash sensor sampled trace `SurfaceProps` ID type number |
| getSurfacePropsName(xfs:) | Returns the flash sensor sampled trace `SurfaceProps` ID type name string |
| isAllSolid(xfs:) | Returns the flash sensor sampled trace `AllSolid` flag |
| isHit(xfs:) | Returns the flash sensor sampled trace `Hit` flag |
| isHitNoDraw(xfs:) | Returns the flash sensor sampled trace `HitNoDraw` flag |
| isHitNonWorld(xfs:) | Returns the flash sensor sampled trace `HitNonWorld` flag |
| isHitSky(xfs:) | Returns the flash sensor sampled trace `HitSky` flag |
| isHitWorld(xfs:) | Returns the flash sensor sampled trace `HitWorld` flag |
| isStartSolid(xfs:) | Returns the flash sensor sampled trace `StartSolid` flag |
| remEntityHitOnly(xfs:e) | Removes the entity from the flash sensor internal only hit list |
| remEntityHitSkip(xfs:e) | Removes the entity from the flash sensor internal ignore hit list |
| remHit(xfs:s) | Removes the option from the flash sensor internal hit preferences |
| remHitOnly(xfs:sn) | Removes the option from the flash sensor internal only hit list |
| remHitOnly(xfs:ss) | Removes the option from the flash sensor internal only hit list |
| remHitSkip(xfs:sn) | Removes the option from the flash sensor internal ignore hit list |
| remHitSkip(xfs:ss) | Removes the option from the flash sensor internal ignore hit list |
| setAttachEntity(xfs:e) | Updates the attachment entity of the flash sensor |
| setAttachEntity(xfs:n) | Updates the ignore world flag of the flash sensor |
| setCollisionGroup(xfs:n) | Updates flash sensor trace collision group enums [COLLISION_GROUP](https://wiki.garrysmod.com/page/Enums/COLLISION_GROUP) |
| setDirection(xfs:v) | Updates the flash sensor direction vector |
| setLength(xfs:n) | Updates flash sensor length distance |
| setMask(xfs:n) | Updates flash sensor trace hit mask enums [MASK](https://wiki.garrysmod.com/page/Enums/MASK) |
| setOrigin(xfs:v) | Updates the flash sensor origin position |
| smpLocal(xfs:) | Samples the flash sensor and updates the trace result according to attachment entity local axis |
| smpWorld(xfs:) | Samples the flash sensor and updates the trace result according to the world axis |