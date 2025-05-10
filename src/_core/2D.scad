include <BOSL2/rounding.scad>
include <constants.scad>
//use <curves.scad>
use <assert.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: 2D.scad
// Includes:
//   include <_core/2D.scad>
// FileGroup: Geometry
// FileSummary: 2D, Geometry 
//////////////////////////////////////////////////////////////////////


// Function: radius()
//
// Synopsis: Calculates radius of golden spiral at a given angle
//
// Topics: Fibonacci, Golden Ratio, Spirals, Mathematics
//
// Description:
//   Calculates the radius of a golden spiral at a specific angle. The radius
//   grows exponentially according to the golden ratio (φ), with the radius increasing
//   by a factor of φ for every 90° of rotation.
//
// Arguments:
//   angle 	= The angle in degrees where the radius is calculated
//   base 	= The starting radius at angle 0 [default: 10]
//
// Examples(2D, ColorScheme=Tomorrow): Basic golden spiral for 2 full rotations
//   polygon([for(a = [0:5:720])[radius(a) * cos(a), radius(a) * sin(a)]], convexity=10);
// Examples(2D, ColorScheme=Tomorrow): Golden spiral with custom base size
//   color("darkgreen") polygon([for(a = [0:5:540]) [radius(a) * cos(a), radius(a) * sin(a)]], convexity=10);
function radius( angle ) = 10 * pow(phi(), (angle / 90));

// Function: phi()
//
// Synopsis: Returns the golden ratio (φ or phi)
//
// Topics: Mathematics, Golden Ratio, Constants
//
// Description:
//   Calculates and returns the golden ratio (φ or phi), an irrational mathematical constant
//   approximately equal to 1.618033988749895. The golden ratio appears in many areas of mathematics,
//   science, art, and design due to its unique properties and aesthetic appeal.
//
//   The golden ratio is defined as (1 + √5)/2 and is represented by the Greek letter phi (φ).
//   It is sometimes called the divine proportion, golden mean, or golden section.
//
// Arguments:
//   No arguments
//
//
// Example: Display the value of phi
//   echo("Golden ratio (φ):", phi()); // Outputs approximately 1.618033988749895
// Examples(2D, ColorScheme=Tomorrow): Draw a golden rectangle (width:height ratio = φ:1)
//   square([50, 50/phi()]);
//
function phi() = (1 + sqrt(5)) / 2;	


// Module: arc()
// 
// Synopsis: Creates a 2D arc with specified radius, thickness, and angle range.
// Topics: Geometry, Curves, Shapes
// Description:
//    Generates a 2D arc (a ring segment) with a given outer radius and thickness,
//    spanning from start_angle to end_angle. Uses BOSL2’s arc() function for
//    efficient path generation, extruded into a 2D shape. Ideal for architectural
//    elements like curved walls or decorative features.
// Arguments:
//    radius 		= Outer radius of the arc [required].
//    thickness 	= Radial thickness of the arc [required].
//    start_angle 	= Starting angle in degrees [default: 0].
//    end_angle 	= Ending angle in degrees [default: 90].
//    anchor 		= Anchor point (BOSL2 style) [default: CENTER].
//    spin 			= Rotation angle in degrees around Z (BOSL2 style) [default: 0].
// Usage:
//    arc(radius=50, thickness=10, start_angle=0, end_angle=180);
// Example(3D,ColorScheme=Tomorrow,NoAxes): Half-circle arc
//    linear_extrude(height=2) arc( radius=50, thickness=5, start_angle=0, end_angle=180);
// Example(3D,ColorScheme=Tomorrow,NoAxes): Quarter-circle arc
//    linear_extrude(height=3) arc( radius=30, thickness=8, end_angle=90);
module arc(radius, thickness, start_angle = 0, end_angle) {
    difference() {
        // Outer circle
        circle(r = radius);
        // Inner circle
        circle(r = radius - thickness);
        // Cut out the part we don't want
        rotate([0, 0, end_angle])
            translate([0, -radius * 2])
                square(radius * 4, center=true);
        rotate([0, 0, start_angle])
            mirror([0, 1, 0])
                translate([0, -radius * 2])
                    square(radius * 4, center=true);
    }
}

// Module: goldenRectangle()
// 
// Synopsis: Creates a golden rectangle with an inscribed Fibonacci spiral.
// Topics: Geometry, Spirals, Mathematics
// See Also: fibonacciSpiral()
// Description:
//    Generates a 3D object consisting of a golden spiral (based on fibonacciSpiral())
//    inscribed within its bounding rectangle (from boundingRect()). The spiral and
//    rectangle are rendered with separate thicknesses, using BOSL2 for efficient
//    path generation and extrusion. Either max_width or max_height must be specified
//    to define the spiral’s bounds.
// Arguments:
//    max_width = Maximum width of the rectangle and spiral (optional).
//    max_height = Maximum height of the rectangle and spiral (optional).
//    center = Center the spiral and rectangle at [0,0] [default: false].
//    spiral_thickness = Diameter of the spiral extrusion [default: 2].
//    rect_thickness = Height of the rectangle extrusion [default: 1].
//    anchor = Anchor point (BOSL2 style) [default: BOTTOM].
//    spin = Rotation angle in degrees around Z (BOSL2 style) [default: 0].
// DefineHeader(Generic):Returns:
//    A 3D object combining a golden spiral and its bounding rectangle, attachable to children.
// Usage:
//    goldenRectangle(max_width, max_height,[center],[spiral_thickness],[rect_thickness],[anchor],[spin]);
// Example(3D,ColorScheme=Tomorrow,NoAxes): Rectangle with spiral (max width)
//    goldenRectangle(max_width=100, spiral_thickness=3, rect_thickness=2);
// Example(3D,ColorScheme=Tomorrow,NoAxes): Centered with max height
//    goldenRectangle(max_height=61.8, center=true, spiral_thickness=2);	
module goldenRectangle(
    max_width,
    max_height,
    center 				= false,
    spiral_thickness 	= 2,
    rect_thickness 		= 1,
    anchor 				= BOTTOM,
    spin 				= 0
) {
    // Input validation
    assert((is_num(max_width) || is_num(max_height)), "At least one of max_width or max_height must be specified");
    assert(is_bool(center), "center must be a boolean");
    assert(is_num(spiral_thickness) && spiral_thickness > 0, "spiral_thickness must be positive");
    assert(is_num(rect_thickness) && rect_thickness > 0, "rect_thickness must be positive");

    // Generate spiral points (using previously defined fibonacciSpiral)
    spiral_points = fibonacciSpiral(max_width=max_width, max_height=max_height, center=center);

    // Generate bounding rectangle points (using previously defined boundingRect)
    rect_points = boundingRect(points=spiral_points);

    // Calculate bounding box
    bounds = pointlist_bounds(spiral_points); // Same for both spiral and rect
    bounding = [
        bounds[1][X] - bounds[0][X],
        bounds[1][Y] - bounds[0][Y],
        max(spiral_thickness, rect_thickness)
    ];

    // Render the combined object
    attachable(size=bounding, anchor=anchor, spin=spin, cp=[bounding[0]/2, bounding[1]/2, 0]) {
		union(){
			// Rectangle
			color("BurlyWood") // Pine color for ColorScheme=Tomorrow
				linear_extrude(height=rect_thickness)
					stroke(rect_points, closed=true, width=rect_thickness/2);

			// Spiral
			color("DarkOliveGreen") // Nature scheme color
				path_sweep(
					circle(d=spiral_thickness),
					spiral_points,
					closed=false
			);
		}
        children();
    }
}


// Module: vesicaPiscis()
//
// Synopsis: Creates a 2D Vesica Piscis shape.
// Topics: Geometry, 2D Shapes
// Description:
//   Generates a 2D Vesica Piscis shape, formed by the intersection of two circles
//   with equal radius, where each circle's center lies on the other's circumference.
//   The shape is symmetric along the X-axis, with adjustable resolution ($fn).
// Arguments:
//   r = Radius of the two circles. No default.
// DefineHeader(Generic):Children:
//   Optional 2D children to combine with the shape.
// Usage:
//   vesicaPiscis(r); 
// Example(2D,ColorScheme=Tomorrow,NoAxes): Simple Vesica Piscis
//   stroke(vesicaPiscis(r=20));
// Example(2D,ColorScheme=Tomorrow,NoAxes): Vesica piscis with width 100  and height 50
//   stroke(vesicaPiscis(w=100,h=50));
function vesicaPiscis(r,ratio = 2, w,h ,plain = false,fn=100) =
	let(
		r = is_def(r) ? r : radiusFromLineDistance(w,h/2), 
		s = is_undef(h) ? r/ratio : r-h/2,
		c1 = move([0,-s],circle(r=r, $fn=fn)),
		c2 = move([0,+s],circle(r=r, $fn=fn)),
	)
	force_path(intersection([c1,c2]));

// Function: parallelogram()
// 
// Synopsis: Generates a 2D parallelogram path with optional skew and rounded corners.
// Topics: Shapes, 2D Geometry
// Description:
//    Creates a 2D parallelogram defined by base widths, height, and an optional skew.
//    Supports rounded corners if a rounding radius is provided. The resulting path is
//    closed by repeating the starting point.
// Arguments:
//    width  = Default width for both base edges if width1 or width2 are undefined.
//    width1 = Width of the bottom edge. [default: width]
//    width2 = Width of the top edge. [default: width]
//    height = Height of the parallelogram. [default: 5]
//    skew   = Horizontal offset (skew) applied to the top edge. [default: 5]
//    rounding = Radius for rounded corners, if defined and > 0. [default: undef]
// Returns:
//    A list of 2D points representing the closed parallelogram path.
// Example(2D,ColorScheme=Tomorrow)
//    polygon(parallelogram(width=20, width1=25, width2=15, height=10, skew=5, rounding=2));
function parallelogram(width,width1,width2, height=5, skew=5, rounding) = 
	let (
		w1 = first_defined([ width1 , width ] ), 
		w2 = first_defined([ width2 , width ] ), 
		// Define the four vertices of the parallelogram
		points = [
			[0, 0],              	// Bottom-left
			[w1, 0],     			// Bottom-right
			[w2 + skew, height], 	// Top-right (skewed)
			[skew, height],       	// Top-left (skewed)
		],
		path = is_def(rounding) && rounding > 0 ? round_corners(points,radius = rounding) : points 
	)
	path;

// Function: boundingRect()
//
// Synopsis: Converts bounding box corners to a rectangle's 4 corner points
// Topics: Points, Bounds, Geometry, Rectangle
//
// Description:
//   Takes a list of points and returns the four corners of the minimum bounding rectangle
//   in clockwise order, starting from the bottom-left corner.
//
// Arguments:
//   points = List of 2D points
//
// Examples(2D, ColorScheme=Tomorrow): Calculate bounding rectangle of an irregular shape
//   polygon(boundingRect([[10,10], [20,30], [40,15], [30,5]]));
function boundingRect(points) = 
	let ( b = pointlist_bounds( points))
	[
		[b[0][X],b[0][Y]],
		[b[1][X],b[0][Y]],
		[b[1][X],b[1][Y]],
		[b[0][X],b[1][Y]],
	];	
	
// Function: radiusFromChord()
//
// Synopsis: Calculates the radius of a circle from a chord length and y-coordinate.
// Topics: Geometry, Mathematics
// Description:
//   Computes the radius of a circle given the length of a horizontal chord at a
//   specific y-coordinate. The circle is assumed to be centered at (0, 0).
// Arguments:
//   L = Length of the horizontal chord. No default.
//   h = Y-coordinate of the chord (distance from center). No default.
// DefineHeader(Generic):Returns:
//   The radius of the circle.
// Usage:
//   r = radiusFromChord(L=10, h=3); // Radius of circle with chord length 10 at y=3
// Example: Calculate radius for a chord
//   L = 10;
//   h = 3;
//   r = radiusFromChord(L=L, h=h);
//   echo("Radius:", r); // ECHO: "Radius:", 5.83095
// Example: Use in a circle
//   r = radiusFromChord(L=8, h=2);
//   circle(r=r);
function radiusFromChord(L, h) =
    assert(is_num(L) && L > 0, "L must be a positive number")
    assert(is_num(h), "h must be a number")
    let (
        a = L / 2, // Half the chord length
        r = sqrt(a * a + h * h) // Radius from Pythagorean theorem
    )
    r;	

// Function: radiusFromLineDistance() 
// 
// Synopsis: Computes the radius of a circle from a chord length and the sagitta (distance to the circle's perimeter). 
// Topics: Geometry, Circle, Radius 
// Description: 
//    Given the length of a horizontal chord and the distance from this chord 
//    to the circle's perimeter, this function calculates the radius of the circle 
//    using the formula derived from circle geometry. 
// Arguments: 
//    chord   = Length of the horizontal chord.
//    sagitta = Distance from the chord to the circle's perimeter.
// Returns: 
//    The computed radius of the circle.
// Example: Compute radius from line distance
//   radius = radiusFromLineDistance(10, 3);
//   echo("Radius: ", radius);
function radiusFromLineDistance (chord,sagitta) = 
	pow(chord,2)/(8*sagitta)+(sagitta/2);
	

// Function: sheet_count()
// 
// Synopsis: Calculates the number of sheets needed to cover an area.
// Topics: Construction, Material Planning
// Description:
//   Determines the minimum number of sheets required to cover a given area
//   based on the sheet dimensions. Returns a vector [x_count, y_count]
//   representing the number of sheets along each axis.
// Arguments:
//   area = Vector [width, height] of the area to cover (in mm).
//   sheet = Vector [width, height] of a single sheet (in mm).
// Example: Sheet count for an area of 4m x 3m
//   area = [4000, 3000];
//   sheet = [4 * FEET, 8 * FEET];
//   count = sheet_count(area, sheet);
//   echo(count); // Outputs: [4, 2]
function sheet_count( area, sheet ) =
    let (
        x_count = ceil(area.x / sheet.x),
        y_count = ceil(area.y / sheet.y)
    )
    [x_count, y_count];

// Function: sheetWasteAreaByAxis()
// 
// Synopsis: Calculates the effective edge waste when covering an area with sheets.
// Topics: Construction, Material Efficiency
// Description:
//   Computes the effective waste area (in square mm) as the product of unused
//   portions along each axis when covering a specified area with sheets. This
//   represents waste from sheet edges rather than total unused area.
// Arguments:
//   area = Vector [width, height] of the area to cover (in mm).
//   sheet = Vector [width, height] of a single sheet (in mm).
// Example(2D,ColorScheme=Tomorrow):
//   area = [4000, 3000];
//   sheet = [4 * FEET, 8 * FEET];
//   waste = sheetWasteAreaByAxis(area, sheet);
//   echo(waste / (1000 * 1000)); // Outputs waste in square meters
function sheetWasteAreaByAxis(area, sheet) =
	assert(is_dim_pair(area),	"[sheetWasteAreaByAxis] area dimensions missing")
	assert(is_dim_pair(sheet),	"[sheetWasteAreaByAxis] sheet dimensions missing") 
    let (
        x_remains = ceil(area.x / sheet.x) - area.x / sheet.x,
        y_remains = ceil(area.y / sheet.y) - area.y / sheet.y,
        x_waste = x_remains * sheet.y,
        y_waste = y_remains * sheet.x
    )
    x_waste * y_waste;
	
	
// Function: isSheetOrientedBest()
// 
// Synopsis: Determines if the sheet orientation minimizes waste.
// Topics: Construction, Material Optimization
// Description:
//   Checks if the given sheet orientation results in less or equal waste compared
//   to the flipped orientation. Returns true if the current orientation is optimal.
// Arguments:
//   area = Vector [width, height] of the area to cover (in mm).
//   sheet = Vector [width, height] of a single sheet (in mm).
// Example(2D,ColorScheme=Tomorrow):
//   area = [4000, 3000];
//   sheet = [8 * FEET, 4 * FEET];
//   is_best = isSheetOrientedBest(area, sheet);
//   echo(is_best); // Outputs: true
function isSheetOrientedBest(area, sheet) =
	assert(is_dim_pair(area),	"[isSheetOrientedBest] area dimensions missing")
	assert(is_dim_pair(sheet),	"[isSheetOrientedBest] sheet dimensions missing") 
    let (
        current_waste = sheetWasteAreaByAxis(area, sheet),
        flipped_waste = sheetWasteAreaByAxis(area, [sheet.y, sheet.x])
    )
    current_waste <= flipped_waste;	
	

// Function: yMirrorPath()
//
// Synopsis: Mirrors a 2D path across the Y-axis.
// Topics: Geometry, Path Manipulation
// Description:
//   Creates a mirrored version of a 2D path by reflecting points with positive X-coordinates
//   across the Y-axis and concatenating them to the original path in reverse order.
// Arguments:
//   path = List of 2D points, where each point is a vector [x, y].
// Example(2D,ColorScheme=Tomorrow):
//   path = [[1, 0], [2, 1], [1, 2], [0, 1]];
//   mirrored = yMirrorPath(path);
//   echo(mirrored); // Outputs: [[1, 0], [2, 1], [1, 2], [0, 1], [-1, 2], [-2, 1], [-1, 0]]
function yMirrorPath( path ) =
	let (
		reflected = [
			for (pt = reverse(path)) 
				if (pt[X] > 0  ) [-pt[X],pt[Y]]
		]
	)
	concat(path,reflected);	


