


# Space

Nervi introduce the concept of [space](./space.scad). Space allow you to define a volume who can correspond to a room a logical space or anything you want to define as a space.

> [!IMPORTANT]  
> By default a space is not visible. To view a space you need to set debug to **True**


```openscad-3D;ColorScheme=Tomorrow
include <Nervi/space.scad>
space(l=3,w=2,h=2.3,debug=true);
```

Space can be defined using scoped variables : 

```openscad-3D;ColorScheme=Tomorrow
include <Nervi/space.scad>
$space_length = 4;
$space_width  = 3;
$space_height = 2;
$space_wall   = 300;
space( debug=true );
```

Space can exclude walls using exclude arguments. To exlude wall provide direction to except like **FRONT** and **RIGHT** in the following example :   

```openscad-3D;ColorScheme=Tomorrow
include <Nervi/space.scad>
space(l=3,w=2,h=2.3,debug=true,except=[FRONT,RIGHT]);
```

## Metrics

Nervi provide metrics for several main modules. When provided the module has a info flag argument to trigger display of metrics like : 

```
include <Nervi/space.scad>
space (2,2,2,debug=true,info=true);
********************
        Info        
********************
              Volume: 8 m³ 
                Area: 4 m² 
           IFC Class: IfcSpace 
            IFC Type: SPACE 
            IFC GUID: 09CB35AE-1D46-5BAB-85C8-88BC31408230 
********************
```
 
## Walls 

Nervi provide a way to attach any kind of objects to walls. 

You can attach any children to wall using [`attachWalls()`](./space.scad#module-attachwalls).

```openscad-3D;ColorScheme=Tomorrow;Huge
include <Nervi/space.scad>
space(3,3,3,debug=true)
	attachWalls( faces = FRONT)
		text($anchor,halign="center",size=200,$color="Red");
```

If you don't provide faces it will take all wall excluding the sides defined in space **except** argument. You can force to attach to all walls by switching argument **force** to true.

```openscad-3D;ColorScheme=Tomorrow;Huge
include <Nervi/space.scad>
space(3,3,3,debug=true,except=[FRONT])
	attachWalls()
		color("IndianRed")
		linear_extrude(100)
		text("OK",halign="center",valign="center",size=1200,$color="Red");
```




[`attachWalls()`](./space.scad#module-attachwalls) provides wall length,height,thickness,orientation and an inside flag scope variables : 

|Variable|Definition|
|---|---|
|$wall_length| Length of the corresponding wall taking into account wall except|
|$wall_height| Height of the corresponding wall in meters|
|$wall_inside| Flag defining true for inside wall and false for outside|
|$wall_orient| Normal vector of the face|

```openscad-3D;ColorScheme=Tomorrow;Big
include <Nervi/space.scad>
$space_length = 4;
$space_width = 3;
$space_height = 2;
$space_wall = 100;
space(debug=true)
	attachWalls( faces = FRONT)
		text(str($wall_length," m x ",$wall_height," m"),halign="center",valign="center",size=400,$color="Red");
```		
> [!NOTE]  
> External wall length would be the space length plus 2 times the wall size. If all walls are present.


## Wall surface

Wall surface is provided by [`space()`](./space.scad#module-space) and [`attachWalls()`](./space.scad#module-attachwalls).  You can retrieve the geometry using [`anchorInfo()`](./utils.scad#function-anchorInfo).

```openscad-3D;ColorScheme=Tomorrow;Huge
include <Nervi/space.scad>
$space_length = 4;
$space_width = 3;
$space_height = 2;
$space_wall = 500;
space(debug=true,except=[FRONT,RIGHT])
	attachWalls( placement="inside" )
		color("indianRed")
		linear_extrude(200)	polygon(anchorInfo("geom"));
```

Technicaly localization of walls are defined using anchors. 

|Side|placement|Name|   
|---|---|---|
|Left|Inside|LEFT_INSIDE|
||Outside|LEFT_OUTSIDE|
|Right|Inside|RIGHT_INSIDE|
||Outside|RIGHT_OUTSIDE|
|Front|Inside|FRONT_INSIDE|
||Outside|FRONT_OUTSIDE|
|Back|Inside|BACK_INSIDE|
||Outside|BACK_OUTSIDE|


## Slab 

Creates a monolithic [`slab()`](./space.scad#module-slab) with dimensions derived from the parent `space()` (./space.scad#module-space) or specified parameters. Automatically aligns to the bottom of a space when a direct child, with an optional vertical offset. Uses `masonrySpecs()` (./masonry.scad#function-masonrySpecs) for material properties and calculates cost as volume * unit_price. Metadata supports IFC export as IfcSlab.

### Example 1: Slab with Cost Estimation

Create a slab under a space with cost informations.

```openscad-3D;Huge
include <Nervi/space.scad>
space(l=3, w=3, h=2, debug=true, except=[FRONT, RIGHT]) {
    slab(thickness=200, material="Concrete", unit_price=120,info=true);
}
```


### IFC Mapping

Maps to IfcSlab with PredefinedType=BASESLAB. Material properties (e.g., "Concrete") are assigned via IfcMaterial, with $meta providing volume, weight, and cost for BIM cost analysis.

> [! IMPORTANT]  
> Use "Concrete" from `masonrySpecs()` (./masonry.scad#function-masonrySpecs) for slabs, not "Concrete Block", which is for modular walls.

### Notes

> [!TIP]
> Adjust __unit_price__ based on local concrete costs (e.g., $120/m³) for accurate estimates.


> [!NOTE]  
> Highlights information that users should take into account, even when skimming.

> [!IMPORTANT]  
> Ensure material matches a key in `masonrySpecs()` (./masonry.scad#function-masonrySpecs) (e.g., "Concrete") to avoid density lookup errors.



















