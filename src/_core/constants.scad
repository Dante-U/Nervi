include <BOSL2/std.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: constants.scad
// Includes:
//   include <_core/constants.scad>
// FileGroup: Core
// FileSummary: Architecture and geometry constants
//////////////////////////////////////////////////////////////////////

// Constant: X
// Description: X index for vectors
// Example: To get the X component of a vector
//   x = anchor[X];
X = 0;
// Constant: Y
// Description: Y index for vectors
// Example: To get the Y component of a vector
//   y = anchor[Y];
Y = 1;
// Constant: Z
// Description: Z index for vectors
// Example: To get the Z component of a vector
//   z = anchor[Z];
Z = 2;


// Constant: HORIZONTAL
// Description: Define a horizontal orientation
HORIZONTAL 	= [1,0];

// Constant: VERTICAL
// Description: Define a vertical orientation
VERTICAL 	= [0,1];

// Constant: SIDES
// Description: All cardinals directions
SIDES = [BACK, RIGHT,FORWARD, LEFT ];


// Constant: INCH
// Synopsis: A constant containing the  number of millimeters in an inch. `25.4`
// Topics: Constants
// Description:
//   The number of millimeters in an inch.
// Example(2D):
//   square(2*INCH, center=true);
// Example(3D):
//   cube([4,3,2.5]*INCH, center=true);
INCH = 25.4;

FEET = 12 * INCH; 

MM2_TO_M2 = 1e-6;  // Conversion factor: 1 mm² = 1e-6 m²
MM3_TO_M3 = 1e-9;  // Conversion factor: 1 mm³ = 1e-9 m³

// Constant: OFFSET
// Description: Minimum offset 
OFFSET=0.02;

// Constant: CLEARANCE
// Description: Boolean operation clearance
CLEARANCE 		= 0.201;

// Constant: EPSILON
// Synopsis: A tiny value to compare floating point values.  `1e-9`
// Topics: Constants, Math
// Description: A really small value useful in comparing floating point numbers.  ie: abs(a-b)<EPSILON  `1e-9`
//EPSILON = 1e-9;

// Function: meters()
// 
// Synopsis: Converts lengths from meters to millimeters.
// Topics: Units, Geometry
// See Also: asMeters()
// Description:
//    Converts a scalar or list of lengths from meters to millimeters by multiplying
//    by 1000, for use with the space module's geometry calculations. Returns undef
//    for undefined inputs. Essential for aligning space module's meter-based inputs
//    with OpenSCAD's millimeter-based rendering.
// Arguments:
//    value = Scalar or list of lengths in meters. No default.
// Example:
//    $space_length = 3;
//    $space_width  = 2;
//    mm = meters([$space_length, $space_width]); // Returns [3000, 2000]
//    scalar_mm = meters(1.5); // Returns 1500
function meters( value ) = 
	assert(is_num(value) || is_list(value), "[meters] value must be a number or list")
	is_list (value) ? [ for (v = value) meters(v)] : is_def(value) ? 1000 * value : undef;

// Function: asMeters()
// 
// Synopsis: Converts lengths from meters to millimeters.
// Topics: Units, Geometry
// See Also: meters()
// Description:
//    Converts a scalar or list of lengths from meters to millimeters by multiplying
//    by 1000, for use with the space module's meter-based context variables.
//    Returns undef for undefined inputs. Useful for converting OpenSCAD's
//    millimeter-based geometry to meter-based inputs for space module parameters.
// Arguments:
//    value = Scalar or list of lengths in millimeters. No default.
// Example:
//    scalar_m = asMeters(1500); // Returns 1.5	
function asMeters( value ) = 
	assert(is_num(value) || is_list(value), "[meters] value must be a number or list")
	is_list (value) ? [ for (v = value) meters(v)] : is_def(value) ? value/1000 : undef;
	
// Function: mm2_to_m2()
// 
// Synopsis: Converts an area from square millimeters to square meters.
// Topics: Construction, Unit Conversion
// Description:
//   Converts a given area value from square millimeters (mm²) to square meters (m²).
//   Uses the conversion factor 1 mm² = 1e-6 m² for precision.
// Arguments:
//   mm2 = Area in square millimeters (mm²).
// Example:
//   area_mm2 = 1645578.24;
//   area_m2 = mm2_to_m2(area_mm2);
//   echo(area_m2); // Outputs: 1.64557824
function mm2_to_m2(mm2) = 
	//is_num( mm2 ) ?  mm2 * MM2_TO_M2 : 
	is_vector(mm2) ?  mm2.x * mm2.y * MM2_TO_M2 : 
	mm2 * MM2_TO_M2;	

// Function: mm3_to_m3()
// Synopsis: Converts volume from cubic millimeters to cubic meters.
// Topics: Utilities, Units, Volume
// Usage:
//   volume_m3 = mm3_to_m3(volume_mm3);
// Description:
//   Converts a volume from cubic millimeters (mm³) to cubic meters (m³) by dividing by 1,000,000,000.
//   Useful for calculating material volumes in cost and weight estimations.
// Arguments:
//   volume_mm3 = Volume in cubic millimeters (scalar).
// Returns: Volume in cubic meters.
// Example(3D,Small,ColorScheme=Tomorrow):
//   volume_mm3 = 3000 * 3000 * 200; // 3m x 3m x 200mm slab
//   volume_m3 = mm3_to_m3(volume_mm3);
//   echo("Volume:", volume_m3, "m³"); // Outputs: Volume: 1.8 m³
//   highlight() cuboid([3000, 3000, 200]); // Visualize slab
function mm3_to_m3(mm3) =
	is_vector(mm3) ?  mm3.x * mm3.y * mm3.z * MM3_TO_M3 : 
	mm3 * MM3_TO_M3;	


// Constant: GRAVITY
// Description: Gravity 
GRAVITY=9.81;


$align_msg = false; // remove align message from BOSL2

// Rendering level

// Constant: RENDER_SIMPLIFIED
// Topics: Constants
// Description: Rendering detail simplified
// See Also: RENDER_STANDARD, RENDER_DETAILED
// Example: Usage to define a simplified rendering:
//   $RD = RENDER_SIMPLIFIED;
RENDER_SIMPLIFIED = -1;

// Constant: RENDER_STANDARD
// Topics: Constants
// Description: Rendering standard
// See Also: RENDER_SIMPLIFIED, RENDER_DETAILED
// Example: Usage to define a standard rendering:
//   $RD = RENDER_STANDARD;

RENDER_STANDARD = 0;

// Constant: RENDER_DETAILED
// Topics: Constants
// Description: Rendering detailed
// See Also: RENDER_SIMPLIFIED, RENDER_STANDARD
// Example: Usage to define a detailed rendering:
//   $RD = RENDER_DETAILED;
RENDER_DETAILED = 1;


// Constant: VIEW_3D
// Topics: Constants
// Description: Rendering view in 3D
// See Also: VIEW_ELEVATION, VIEW_PLAN
// Example: Usage to define rendering in 3D
//   $viewType = RENDER_DETAILED;
VIEW_3D = 0;



// Constant: VIEW_PLAN
// Topics: Constants
// Description: Rendering view in plan
// See Also: VIEW_3D, VIEW_ELEVATION
// Example: Usage to define rendering in plan
//   $viewType = VIEW_PLAN;
VIEW_PLAN = 1;

// Constant: VIEW_ELEVATION
// Topics: Constants
// Description: Rendering view in elevation
// See Also: VIEW_3D, VIEW_PLAN
// Example: Usage to define rendering in elevation
//   $viewType = VIEW_ELEVATION;
VIEW_ELEVATION = 2;

function isViewPlan() 		= is_undef( $viewType ) ? false : $viewType == VIEW_PLAN;
function isViewElevation() 	= is_undef( $viewType ) ? false : $viewType == VIEW_ELEVATION;
function isView3D() 		= is_undef( $viewType ) ? true  : $viewType == VIEW_3D;

function isHorizontal( dir ) 	= dir.y == 0;
function isVertical( dir ) 		= dir.x == 0;


// Function: rendering()
// Synopsis: Returns the current rendering detail level.
// Topics: Rendering, Functions
// See Also: RENDER_SIMPLIFIED, RENDER_STANDARD, RENDER_DETAILED, valueByRendering()
// Description:
//   Retrieves the rendering detail level from the $RD special variable, defaulting to
//   RENDER_STANDARD if undefined. Use this to control rendering behavior in modules.
// DefineHeader(Generic):Returns:
//   The current rendering level (-1, 0, or 1).
// Usage:
//   level = rendering(); // Get current rendering level
// Example: Conditional rendering based on level
//   ColorScheme=Tomorrow
//   level = rendering();
//   if (level == RENDER_SIMPLIFIED) {
//       cube(10, center=true);
//   } else if (level == RENDER_STANDARD) {
//       cylinder(r=5, h=10, center=true);
//   } else {
//       sphere(r=5, $fn=100);
//   }
function rendering() = is_undef($RD) ? RENDER_STANDARD : $RD ;

// Function: valueByRendering()
// 
// Synopsis: Returns a value based on the current rendering level.
// Topics: Rendering, Geometry
// See Also: RENDER_SIMPLIFIED, RENDER_STANDARD, RENDER_DETAILED
// Usage:
//   value = valueByRendering(simple, standard, detailed);
// Description:
//   Selects a value based on the rendering level returned by rendering(), typically used to adjust geometric detail
//   (e.g., $fn for circular geometry or text). Returns 'simple' for RENDER_SIMPLIFIED, 'standard' for RENDER_STANDARD,
//   and 'detailed' (falling back to 'standard' if undefined) for RENDER_DETAILED. Assumes rendering() returns one of
//   RENDER_SIMPLIFIED, RENDER_STANDARD, or RENDER_DETAILED. Commonly used to balance rendering performance and quality
//   in modules like pillar() or beam().
// Arguments:
//   simple   = Value for simplified rendering (e.g., low $fn like 16).
//   standard = Value for standard rendering (e.g., moderate $fn like 32).
//   detailed = Value for detailed rendering (e.g., high $fn like 64). Default: undef (falls back to standard)
// Returns:
//   The selected value based on the rendering level.
// Example(NORENDER):
//   fn = valueByRendering(simple=16, standard=32, detailed=64); // Returns 16, 32, or 64 based on rendering()
// Example(3D,Small,ColorScheme=Tomorrow): Simplified rendered cylinder
//   $RD = RENDER_SIMPLIFIED;
//   cyl(d=100,length=100,$fn=valueByRendering(simple=16, standard=32, detailed=64));
// Example(3D,Small,ColorScheme=Tomorrow): Standard rendered cylinder
//   $RD = RENDER_STANDARD;
//   cyl(d=100,length=100,$fn=valueByRendering(simple=16, standard=32, detailed=64));
// Example(3D,Small,ColorScheme=Tomorrow): Detailes rendered cylinder
//   $RD = RENDER_DETAILED;
//   cyl(d=100,length=100,$fn=valueByRendering(simple=16, standard=32, detailed=64));
function valueByRendering( simple,standard,detailed ) =
	let(
		level = rendering()
	)
	level == RENDER_SIMPLIFIED 	? simple 	: 
	level == RENDER_DETAILED 	? first_defined([detailed,standard]) : //  	detailed  : //
	standard;
	
// Function: corners()
//
// Synopsis: Returns the four corner anchors of a specified face.
// Topics: Geometry, Anchors, Utilities
// Description:
//   Given a face anchor (e.g., BOT, TOP, FWD), returns a list of four corner anchors
//   combining directional vectors (e.g., BACK+LEFT). Useful for attaching objects to
//   the corners of a face on a 3D object. Returns undef for invalid faces.
// Arguments:
//   face = The face anchor (e.g., BOT, TOP, FWD, BACK, RIGHT, LEFT). No default.
// Usage:
//   corners(face); // Returns bottom face corners
// Example(3D,ColorScheme=Tomorrow): Attaching cuboid to top corners
//    cuboid(50) attach(TOP, BOT,align=corners(TOP)) cuboid(10,$color="Blue");
// Example(3D,ColorScheme=Tomorrow): Attaching cuboid to right corners
//    cuboid(50) attach(RIGHT,LEFT, align=corners(RIGHT)) cuboid(10,$color="Red");
// Example(3D,ColorScheme=Tomorrow): Attaching cuboid to front corners
//    cuboid(50) attach(FRONT,BACK, align=corners(FRONT)) cuboid(10,$color="Green");
function corners(face) =
    let(
        face_map = [ // [faces, corner list]
            [ [ BOT, 	TOP		], [ BACK+LEFT,	BACK+RIGHT,	FWD+LEFT,	FWD+RIGHT 	] ],
            [ [ FWD, 	BACK	], [ TOP+LEFT, 	TOP+RIGHT, 	BOT+LEFT,	BOT+RIGHT 	] ],
            [ [ RIGHT, 	LEFT	], [ BACK+TOP, 	BACK+BOT, 	FWD+TOP, 	FWD+BOT  	] ]
        ]
    )
    [for (entry = face_map) if (in_list(face, entry[0])) entry[1]][0];	