include <BOSL2/std.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: constants.scad
// Includes:
//   include <_core/constants.scad>
// FileGroup: Core
// FileSummary: Architecture constants
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
// See Also: millimeters()
function meters( value ) = 
	assert(is_num(value) || is_list(value), "[meters] value must be a number or list")
	is_list (value) ? [ for (v = value) meters(v)] : is_def(value) ? 1000 * value : undef;

// Function: millimeters()
// 
// Synopsis: Converts lengths from meters to millimeters.
// Topics: Units, Geometry
// Description:
//    Converts a scalar or list of lengths from meters to millimeters by multiplying
//    by 1000, for use with the space module's meter-based context variables.
//    Returns undef for undefined inputs. Useful for converting OpenSCAD's
//    millimeter-based geometry to meter-based inputs for space module parameters.
// Arguments:
//    value = Scalar or list of lengths in millimeters. No default.
// Example:
//    scalar_m = millimeters(1.500); // Returns 1500
// See Also: meters()
function millimeters(value) =
	assert(is_num(value) || is_list(value), "[millimeters] value must be a number or list")
    is_list(value) ? [for (v = value) millimeters(v)] : is_def(value) ? value / 1000 : undef;	


GRAVITY=9.81;


HORIZONTAL 	= [1,0];
VERTICAL 	= [0,1];


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
// See Also: RENDER_SIMPLIFIED, RENDER_STANDARD, RENDER_DETAILED
// Description:
//   Retrieves the rendering detail level from the $RD special variable, defaulting to
//   RENDER_STANDARD if undefined. Use this to control rendering behavior in modules.
// DefineHeader(Generic):Returns:
//   The current rendering level (-1, 0, or 1).
// Usage:
//   level = rendering(); // Get current rendering level
// Example: Conditional rendering based on level
//   ColorScheme=Nature
//   level = rendering();
//   if (level == RENDER_SIMPLIFIED) {
//       cube(10, center=true);
//   } else if (level == RENDER_STANDARD) {
//       cylinder(r=5, h=10, center=true);
//   } else {
//       sphere(r=5, $fn=100);
//   }
function rendering() = is_undef($RD) ? RENDER_STANDARD : $RD ;