# Stairs in Nervi

The [stairs.scad](./stairs.scad) library is a powerful tool for creating parametric staircases in Nervi for OpenSCAD, tailored for architectural and interior design applications. Whether you’re designing a sleek modern staircase for a building superstructure or a compact spiral staircase for a space-conscious interior, this library offers flexible, customizable solutions. 

By leveraging the BOSL2 library for geometry, attachments, and rendering, stairs.scad enables users to generate **straight**, **L-shaped**, **U-shaped**, and **spiral** staircases with precise control over dimensions, materials, and features like handrails.

## Key Features

- **Versatile Stair Types**: Supports four staircase configurations:
Straight: Simple, linear staircases for direct ascents.
- **L-Shaped**: Corner staircases with a single landing for space efficiency.
- **U-Shaped**: Double-landing staircases for compact, multi-level designs.
- **Spiral**: Elegant, space-saving staircases with customizable turns and radii.
- **Customizable Parameters**: Adjust width, total height, step count, rise, run, thickness, and landing size to match specific design requirements.
- **Material Options**: Choose from wood, metal, or masonry, with realistic rendering using a multi-material system.
- **Handrail Support**: Add parametric handrails to one or both sides, with configurable height, width, and post intervals.
- **Mounting Options**: Select “standard” or “flush” mounting to align with floor or slab interfaces.
- **Robust Validation**: Includes assertions to ensure valid inputs (e.g., total rise, material family), preventing design errors.
- **Units Flexibility**: Uses meters for large dimensions (e.g., width, height) and millimeters for smaller ones (e.g., rise, run), with automatic conversions.
- **BOSL2 Integration**: Leverages BOSL2’s attachable module for precise anchoring and orientation, ensuring compatibility with complex assemblies.
- **Debug Mode**: Provides detailed console output for troubleshooting dimensions, angles, and step counts.

## Library Structure

The library includes three main modules:

1. [stairs()](./stairs.scad#module-stairs): Generates straight, L-shaped, or U-shaped staircases with optional handrails. It calculates step counts, rise, and run based on total height and supports wood, metal, or masonry materials.
 
2. [spiralStairs()](./stairs.scad#module-spiralStairs)spiralStairs(): Creates spiral staircases with a central column, configurable steps per rotation, and optional helical handrails.
 
3. [handrail()](./stairs.scad#module-handrail): A standalone module for adding handrails to staircases or other structures, with customizable post intervals and materials.


## Getting Started
To use the library, include it in your OpenSCAD script:

```scad
include <Nervi/stairs.scad>
```

Define a staircase with minimal parameters, letting the library calculate defaults, or specify every detail for precise control. For example:

```scad
// Simple straight staircase with a right handrail
stairs(w=1, total_rise=2800, handrails=[RIGHT]);
```

## Why Use stairs.scad?

This library simplifies the complex geometry of staircase design by automating calculations for step dimensions, angles, and landings. Its parametric nature allows rapid iteration, making it ideal for architects, interior designers, and hobbyists. The integration with BOSL2 ensures compatibility with other OpenSCAD libraries, while the material system adds visual realism to renders. Whether you’re modeling a grand masonry staircase or a minimalist wooden spiral, [stairs.scad](./stairs.scad) provides the tools to bring your vision to life.

## Tips for Success

- **Define Total Rise**: Always specify total_rise or set $space_height to avoid assertion errors.
- **Use Debug Mode**: Enable debug=true to inspect calculated parameters like step count, rise, and angle.
- **Test Materials**: Experiment with “Wood,” “Metal,” or “Masonry” to achieve the desired aesthetic and structural properties.
- **Anchor Carefully**: Use BOSL2’s anchor system (e.g., BOTTOM, RIGHT) to position staircases accurately within your model.
- **Optimize Handrails**: Adjust rail_height and post_interval for safety and style, especially for spiral or long straight staircases.


## Next Steps

Explore the library by starting with the provided examples, then customize parameters to suit your project. Combine [stairs.scad](./stairs.scad) with other libraries like [space.scad](./space.scad) for room layouts or masonry-structure.scad for structural elements. For advanced users, extend the library by adding support for curved staircases or custom handrail profiles.
With stairs.scad, designing parametric staircases is both intuitive and precise, empowering you to create architectural models that are functional, beautiful, and ready for 3D rendering or fabrication.

With [stairs.scad](./stairs.scad), designing parametric staircases is both intuitive and precise, empowering you to create architectural models that are functional, beautiful, and ready for 3D rendering or fabrication.


## Concrete straight stairs

In the following example we will use a [space](./space.scad) module to define the room using debug true to show the limit of the space as wall. We will add a slab then position our [stairs](./stairs.scad) at on the right wall. When the **total_rise** is not provided the stairs module will try to check if a **\$space_height** has been defined which is the case when parent is a [space](./space.scad) module.

```openscad-3D;ColorScheme=Tomorrow;Huge
include <Nervi/space.scad>
include <Nervi/stairs.scad>
include <Nervi/masonry-structure.scad>

space(l=5, w=1.2, h=2.8, wall=200, except=[FRONT,LEFT],debug=true)
{
	slab();
	position(RIGHT) primary()
		stairs(
			w					= 1.2,
			type				= STRAIGHT,
			family				= "Masonry",
			slab_thickness	= 150,
			anchor				= RIGHT
		);
};	
```


## Wood or Metal straight stairs

This example with demonstrate how to align and spin a stairs in wood or metal.

```openscad-3D;ColorScheme=Tomorrow;Big
include <Nervi/stairs.scad>
include <Nervi/space.scad>
include <Nervi/masonry-structure.scad>

space(l=3, w=3, h=2.8, wall=200, except=[FRONT,RIGHT],debug=true) {
	slab();
	position(LEFT) primary()
		stairs( 
			w 		= 1.2, 
			type	= STRAIGHT, 
			family	= "Wood", 
			anchor	= RIGHT, 
			spin	= 180 
		);
};
```

## L-Shaped Stairs

L-shaped staircases, characterized by a single **90-degree** turn, provide a space-efficient and visually appealing solution for connecting multiple levels in residential and commercial spaces. The Nervi Stairs Library, offers a parametric approach to designing L-shaped staircases in OpenSCAD. 

### Understanding L-Shaped Stairs

The stairs() module with type=L_SHAPED generates a staircase with two straight sections connected by a landing, forming a 90-degree turn. Key features include:

* Configurable Dimensions: Set width, total rise, number of steps, and landing size.
* Material Support: Choose from "Wood", "Metal", or "Masonry" families.
* Handrails: Optional handrails on one or both sides.
* Mounting Options: Standard or flush mount for integration with floors or slabs.
* BOSL2 Integration: Uses attachable() for positioning and attachments.

The staircase is divided into a lower section (first set of steps), a landing, and an upper section (second set of steps). The landing size defaults to the staircase width but can be customized.

### Basic Example: Simple L-Shaped Staircase

Let's create a basic L-shaped staircase with a width of 1.2 meter, a total rise of 2.8 meters, and handrails on the right side.

```openscad-3D;ColorScheme=Tomorrow;Big
include <Nervi/stairs.scad>
include <Nervi/space.scad>
include <Nervi/masonry-structure.scad>

zrot(90) space(l=5, w=1.2, h=2.8, wall=200, except=[FRONT,LEFT],debug=true) {
		slab();
		position(LEFT+BACK)
			primary()
				stairs(
					w					= 1.2,
					type				= L_SHAPED,
					family				= "Masonry",
					handrails 		= [RIGHT],
					slab_thickness 	= 150,
					anchor				= LEFT+BACK
				);
	};  
```

> [!NOTE] 
> The staircase consists of two sections of steps (split approximately evenly) and a landing at the turn. The steps 
> are calculated based on the total rise, ensuring compliance with standard stair dimensions.

### Stairs mount

When discussing stair construction, **mound flush** or **flush mount** refers to the way the stairs connect to the deck or flooring, while "standard" refers to a more traditional method. 

A flush mount stair connection sits directly against the deck or flooring, creating a level surface, while a standard mount uses the deck or flooring as an extra step, resulting in a staircase one step lower than the total rise. 

<!--

```openscad-3D;Hide;ColorScheme=Tomorrow;Med;NoAxes
include <Nervi/stairs.scad>
include <Nervi/space.scad>
include <Nervi/masonry-structure.scad>

$space_height	= 0.4;
$space_length	= 0.6;
$space_width	= 1.2;

space(except=[FRONT,RIGHT],debug=true)
{
	slab();
	position(LEFT)
		reddish()
		stairs(
			w					= 1.2,
			type				= STRAIGHT,
			family				= "Masonry",
			slab_thickness 	= 150,
			mount				= STANDARD_MOUNT,
			anchor				= RIGHT,
			spin				= 180
		);
};
```

```openscad-3D;Hide;ColorScheme=Tomorrow;Med;NoAxes
include <Nervi/stairs.scad>
include <Nervi/space.scad>
include <Nervi/masonry-structure.scad>

$space_height	= 0.4;
$space_length	= 0.6;
$space_width	= 1.2;

space(except=[FRONT,RIGHT],debug=true)
{
	slab();
	position(LEFT)
		reddish()
		stairs(
			w					= 1.2,
			type				= STRAIGHT,
			family				= "Masonry",
			slab_thickness	= 150,
			mount				= FLUSH_MOUNT,
			anchor				= RIGHT,
			spin				= 180
		);
}
```

-->

|Standard Mount|Flush Mount|
|---|---|
|![](./images/tutorials/stairs_4.png)|![](./images/tutorials/stairs_5.png)|
|```mount = STANDARD_MOUNT```|```mount = FLUSH_MOUNT```|
