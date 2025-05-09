# Electronic devices tutorial


## Television

Creates a television with a frame (20 mm) and screen, positioned on a stand at the specified height. Supports predefined sizes or custom dimensions. Calculates volume and weight for BIM metadata, using an estimated density (1200 kg/m³). Maps to IfcElectricAppliance in IFC workflows.

### Syntax

```python
television(size, height, anchor, spin, orient, info, ifc_guid)
```

Parameters : 

- size (number or list): Diagonal screen size in inches (32, 49, 55, 65, 75, 88) or custom [width, depth, height] in mm (default: 32).
- height (number): Stand height in mm (default: 1500).
- anchor (vector): Anchor point (default: BOTTOM).
- spin (number): Rotation around Z-axis in degrees (optional).
- orient (vector): Orientation vector (default: UP).
- info (boolean): If true, generates metadata (default: true).
- ifc_guid (string): IFC global unique identifier (optional).

### Example 1: 55-Inch Television

Create a 55-inch television with a 1600 mm stand.

```openscad-3D;ColorScheme=Tomorrow
include <Nervi/electronic.scad>
television(size=55, height=1600);
```

> [!IMPORTANT]  
> By default televisions are oriented up to be easily attached to walls

### Example 2: 

Place a 75-inch television on the back wall of a space

```openscad-3D;ColorScheme=Tomorrow
include <Nervi/space.scad>
include <Nervi/masonry-structure.scad>
include <Nervi/electronic.scad>

space(3,2,2,debug=true,except=[FRONT,RIGHT]){
	slab();
	attachWalls(faces=[BACK], placement="inside" )
		television(size=75,height=200);
}
```

