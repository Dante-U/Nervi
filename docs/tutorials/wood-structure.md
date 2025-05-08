# Wood Structure



## Wood-framed wall

The following module creates wall frame with top and bottom plates and vertical studs.

```openscad-3D;ColorScheme=Tomorrow;Huge
include <Nervi/space.scad>
include <Nervi/wood-structure.scad>
space (3.20,1,2,debug=true)
	attachWalls([FWD],placement="outside") 
   		studWallFrame(); 
```

The spacing is defined with the **stud_spacing** argument in mm. Direction argument is defining if the remaining space should be defined LEFT or RIGHT.
<!--

```openscad-3D;ColorScheme=Tomorrow;Big
include <Nervi/space.scad>
include <Nervi/wood-structure.scad>
    space (1.10,0.3,1,debug=true) attachWalls([FWD],placement="outside") studWallFrame(direction=LEFT); 
```

```openscad-3D;ColorScheme=Tomorrow;Big
include <Nervi/space.scad>
include <Nervi/wood-structure.scad>
    space (1.10,0.3,1,debug=true) attachWalls([FWD],placement="outside") studWallFrame(direction=RIGHT); 
```

-->

The spacing can start from the LEFT or from the RIGHT.

|Direction LEFT|Direction RIGHT|
|---|---|
|![](./images/tutorials/wood-structure_2.png)|![](./images/tutorials/wood-structure_3.png)|

### Info 

Info can be generated using price and material specs : 

```openscad-3D
include <Nervi/space.scad>
include <Nervi/wood-structure.scad>
space(3,3,2)
	attachWalls( placement="outside" ) 
		studWallFrame(
			stud_material		= "Pine",
			plate_material		= "Pine",
			stud_linear_price 	= 0,
			plate_linear_price	= 0,
			info = true); 
```

```
****************************************
                  Info                  
****************************************
                Name: Stud wall 
         Orientation: LEFT 
   Studs:
          Unit Price: $0.00 
            Quantity: 2 Unit
               Value: $0.00 
            Material: Pine 
   Plates:
          Unit Price: $0.00 
            Quantity: 2 Unit
               Value: $0.00 
            Material: Pine 
               Value: $0.00 
****************************************
```


## Trunk platform


```openscad-3D
include <Nervi/wood-structure.scad>
trunkPlatform( l=2, w =3 , h = 0.5, spacing= [1,1], log_diam = 200 );
```

## trunkPlatform Module

The [`trunkPlatform()`](./wood-structure.scad#module-trunkPlatform) module generates a customizable platform for terraces or timber house floors, supported by vertical logs (trunks) and horizontal beams. Vertical logs are placed at regular intervals, and horizontal logs span between them to form the deck. The module supports material selection from wood.scad and debugging visualization.

```openscad-3D;Huge
include <Nervi/wood-structure.scad>
trunkPlatform(
    l = 3,
    w = 2,
    h = 0.5,
    spacing = [1, 1],
    burial_depth_factor = 1.5,
    beam_dir = RIGHT,
    log_diam = 150,
    anchor = BOT,
    material = "Wood",
    groundedMaterial = "Tar",
);
```

### Parameters

- l (number): Platform length in meters (default: 3).
- w (number): Platform width in meters (default: 2).
- h (number): Platform height in meters (elevation from ground, default: 0.5).
- spacing (vector): [x_spacing, y_spacing] Distance between vertical logs in meters (default: [1, 1]).
- burial_depth_factor (number): Multiplier for burial depth of vertical logs (default: 1.5).
- beam_dir (vector): Direction of horizontal beams (RIGHT or BACK, default: RIGHT).
- log_diam (number): Diameter of logs in millimeters (default: 150).
- anchor (vector): Anchor point for positioning (default: BOT).
- material (string): Wood material from wood.scad (default: "Wood").
- groundedMaterial (string): Material for buried log portions (default: "Tar").
- debug (boolean): If true, shows ghosted bounding box and buried logs (default: false).
- spin (number): Rotation around Z-axis in degrees (optional).

### Side Effects

- $floor_length: Set to platform length in meters.
- $floor_width: Set to platform width in meters.

### Description
Generates a 3D platform with vertical logs arranged in a grid and horizontal beams forming the deck. Vertical logs are buried below ground (depth = h * burial_depth_factor), and horizontal beams are oriented along beam_dir. The module uses BOSL2 for positioning and supports material-based rendering from wood.scad.


 






  







