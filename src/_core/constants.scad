include <BOSL2/std.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: constants.scad
//   A library of constants and utility functions for unit conversions, physics,
//   rendering, view management, and material specifications in OpenSCAD, designed
//   for building information modeling (BIM) and structural engineering applications.
//   Provides a robust set of constants for units (e.g., INCH, MM3_TO_M3), physics
//   (e.g., GRAVITY), rendering levels (e.g., RENDER_SIMPLIFIED), view types (e.g.,
//   VIEW_3D), and material families (e.g., WOOD, METAL, MASONRY), alongside functions
//   for conversions (e.g., meters(), mm2_to_m2()), rendering control (e.g., rendering(),
//   valueByRendering()), and material validation (e.g., isValidMaterialFamilies()).
//   Leverages BOSL2 for vector operations, geometric utilities, and attachment mechanisms,
//   ensuring efficient and modular code. Supports consistent unit handling (meters for
//   large dimensions, millimeters for small ones) with assertions for validation.
//
//   Ideal for architectural and structural designs, including superstructures, staircases,
//   and concrete components, with metadata support for IFC (Industry Foundation Classes)
//   integration. Includes utilities for vector indexing, orientation, and face anchoring.
// Includes:
//   include <_core/constants.scad>
// FileGroup: Core
// FileSummary: Constants and utilities for units, physics, rendering, and materials
//////////////////////////////////////////////////////////////////////

// Constant: X
// Synopsis: X index for vectors
// Example: To get the X component of a vector
//   x = anchor[X];
X = 0;

// Constant: Y
// Synopsis: Y index for vectors
// Example: To get the Y component of a vector
//   y = anchor[Y];
Y = 1;

// Constant: Z
// Synopsis: Z index for vectors
// Example: To get the Z component of a vector
//   z = anchor[Z];
Z = 2;


// Constant: HORIZONTAL
// Synopsis: Define a horizontal orientation
HORIZONTAL 	= [1,0];

// Constant: VERTICAL
// Synopsis: Define a vertical orientation
VERTICAL 	= [0,1];

// Constant: SIDES
// Synopsis: All cardinals directions
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

// Constant: FEET
//
// Synopsis: Defines the length of one foot in millimeters.
// Topics: Units, Conversion
// See Also: INCH
// Usage:
//   length = FEET; // Use as a unit multiplier (e.g., 2 * FEET)
// Description:
//   Represents the length of one foot, defined as 12 inches, where each inch is 25.4 mm.
//   This constant facilitates unit conversions for dimensions in feet, ensuring consistency
//   in metric-based OpenSCAD designs.
// Example:
//   INCH = 25.4; // mm
//   FEET = 12 * INCH; // 304.8 mm
//   cube([FEET, FEET, FEET]); // 1x1x1 ft cube
FEET = 12 * INCH; 

// Constant: MM2_TO_M2
//
// Synopsis: Conversion factor from square millimeters to square meters.
// Topics: Units, Conversion, Area
// See Also: MM3_TO_M3
// Usage:
//   area_m2 = area_mm2 * MM2_TO_M2; // Convert mm² to m²
// Description:
//   Defines the conversion factor for transforming an area from square millimeters (mm²)
//   to square meters (m²). The value 1e-6 (0.000001) reflects that 1 mm² = 0.000001 m²,
//   facilitating accurate area calculations in metric-based OpenSCAD designs.
// Example:
//   MM2_TO_M2 = 1e-6;
//   area_mm2 = 1000 * 1000; // 1 m² in mm²
//   area_m2 = area_mm2 * MM2_TO_M2; // Convert to m²
//   echo(area_m2); // Outputs: 1
//   cube([1000, 1000, 1]); // 1x1 m base for visualization
MM2_TO_M2 = 1e-6;  // Conversion factor: 1 mm² = 1e-6 m²

// Constant: MM3_TO_M3
//
// Synopsis: Conversion factor from cubic millimeters to cubic meters.
// Topics: Units, Conversion, Volume
// See Also: MM2_TO_M2
// Usage:
//   volume_m3 = volume_mm3 * MM3_TO_M3; // Convert mm³ to m³
// Description:
//   Defines the conversion factor for transforming a volume from cubic millimeters (mm³)
//   to cubic meters (m³). The value 1e-9 (0.000000001) reflects that 1 mm³ = 0.000000001 m³,
//   facilitating accurate volume calculations in metric-based OpenSCAD designs, such as
//   for concrete cost estimation.
// Example:
//   MM3_TO_M3 = 1e-9;
//   volume_mm3 = 1000 * 1000 * 1000; // 1 m³ in mm³
//   volume_m3 = volume_mm3 * MM3_TO_M3; // Convert to m³
//   echo(volume_m3); // Outputs: 1
MM3_TO_M3 = 1e-9;  // Conversion factor: 1 mm³ = 1e-9 m³

// Constant: OFFSET
// Synopsis: Minimum offset 
OFFSET=0.02;

// Constant: CLEARANCE
// Synopsis: Boolean operation clearance
CLEARANCE 		= 0.201;

// Constant: CR
// Synopsis: Carriage return 
CR = "\n";

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
// Example(3D,Small):
//   volume_mm3 = 3000 * 3000 * 200; // 3m x 3m x 200mm slab
//   volume_m3 = mm3_to_m3(volume_mm3);
//   echo("Volume:", volume_m3, "m³"); // Outputs: Volume: 1.8 m³
//   highlight() cuboid([3000, 3000, 200]); // Visualize slab
function mm3_to_m3(mm3) =
	is_vector(mm3) ?  mm3.x * mm3.y * mm3.z * MM3_TO_M3 : 
	mm3 * MM3_TO_M3;	


// Constant: GRAVITY
//
// Synopsis: Standard gravitational acceleration in meters per second squared.
// Topics: Physics, Structural, Calculations
// See Also: MM3_TO_M3
// Usage:
//   force = mass * GRAVITY; // Calculate force in Newtons
// Description:
//   Defines the standard gravitational acceleration on Earth, 9.81 m/s², used for
//   physics-based calculations such as weight or structural load analysis.
// Example:
//   GRAVITY = 9.81; // m/s²
//   MM3_TO_M3 = 1e-9; // m³/mm³
//   volume_mm3 = 1000 * 1000 * 1000; // 1 m³ in mm³
//   volume_m3 = volume_mm3 * MM3_TO_M3; // 1 m³
//   density = 2400; // kg/m³ (concrete)
//   mass = volume_m3 * density; // kg
//   weight = mass * GRAVITY; // N
//   echo(weight); // Outputs: 23544 N
//   cube([1000, 1000, 1000]); // 1x1x1 m cube
GRAVITY=9.81;


$align_msg = false; // remove align message from BOSL2

// Rendering level

// Constant: RENDER_SIMPLIFIED
// Topics: Constants
// Synopsis: Rendering detail simplified
// See Also: RENDER_STANDARD, RENDER_DETAILED
// Example: Usage to define a simplified rendering:
//   $RD = RENDER_SIMPLIFIED;
RENDER_SIMPLIFIED = -1;

// Constant: RENDER_STANDARD
// Topics: Constants
// Synopsis: Rendering standard
// See Also: RENDER_SIMPLIFIED, RENDER_DETAILED
// Example: Usage to define a standard rendering:
//   $RD = RENDER_STANDARD;

RENDER_STANDARD = 0;

// Constant: RENDER_DETAILED
// Topics: Constants
// Synopsis: Rendering detailed
// See Also: RENDER_SIMPLIFIED, RENDER_STANDARD
// Example: Usage to define a detailed rendering:
//   $RD = RENDER_DETAILED;
RENDER_DETAILED = 1;


// Constant: VIEW_3D
// Topics: Constants
// Synopsis: Rendering view in 3D
// See Also: VIEW_ELEVATION, VIEW_PLAN
// Example: Usage to define rendering in 3D
//   $viewType = RENDER_DETAILED;
VIEW_3D = 0;

// Constant: VIEW_PLAN
// Topics: Constants
// Synopsis: Rendering view in plan
// See Also: VIEW_3D, VIEW_ELEVATION
// Example: Usage to define rendering in plan
//   $viewType = VIEW_PLAN;
VIEW_PLAN = 1;

// Constant: VIEW_ELEVATION
// Topics: Constants
// Synopsis: Rendering view in elevation
// See Also: VIEW_3D, VIEW_PLAN
// Example: Usage to define rendering in elevation
//   $viewType = VIEW_ELEVATION;
VIEW_ELEVATION = 2;

// Function: isViewPlan()
//
// Synopsis: Checks if the current view is a plan view.
// Topics: ViewManagement
// See Also: isViewElevation(), isView3D()
// Usage:
//   bool = isViewPlan();
// Description:
//   Returns true if the special variable $viewType is defined and equals VIEW_PLAN,
//   indicating a 2D top-down view. Returns false otherwise.
// Example:
//   $viewType = VIEW_PLAN;
//   if (isViewPlan()) {
//       echo("Plan view active");
//       square([1000, 1000]); // 1x1 m square for plan view
//   }
// Context Variables:
//   $viewType = String indicating the view type (e.g., VIEW_PLAN, VIEW_ELEVATION, VIEW_3D).
function isViewPlan() 		= is_undef( $viewType ) ? false : $viewType == VIEW_PLAN;

// Function: isViewElevation()
//
// Synopsis: Checks if the current view is an elevation view.
// Topics: ViewManagement
// See Also: isViewPlan(), isView3D()
// Usage:
//   bool = isViewElevation();
// Description:
//   Returns true if the special variable $viewType is defined and equals VIEW_ELEVATION,
//   indicating a 2D side view. Returns false otherwise.
// Example:
//   $viewType = VIEW_ELEVATION;
//   if (isViewElevation()) {
//       echo("Elevation view active");
//       square([1000, 100]); // 1 m wide, 100 mm tall for elevation
//   }
// Context Variables:
//   $viewType = String indicating the view type (e.g., VIEW_PLAN, VIEW_ELEVATION, VIEW_3D).
function isViewElevation() 	= is_undef( $viewType ) ? false : $viewType == VIEW_ELEVATION;

// Function: isView3D()
//
// Synopsis: Checks if the current view is a 3D view.
// Topics: ViewManagement
// See Also: isViewPlan(), isViewElevation()
// Usage:
//   bool = isView3D();
// Description:
//   Returns true if the special variable $viewType is undefined (defaulting to 3D view)
//   or equals VIEW_3D, indicating a 3D perspective view. Returns false otherwise.
// Example:
//   $viewType = VIEW_3D;
//   if (isView3D()) {
//       echo("3D view active");
//       cube([1000, 1000, 100]); // 1x1 m, 100 mm tall cube
//   }
// Context Variables:
//   $viewType = String indicating the view type (e.g., VIEW_PLAN, VIEW_ELEVATION, VIEW_3D).
function isView3D() = is_undef( $viewType ) ? true  : $viewType == VIEW_3D;

// Function: isHorizontal()
//
// Synopsis: Checks if a direction vector is horizontal.
// Topics: Geometry, Orientation
// See Also: isVertical()
// Usage:
//   bool = isHorizontal(dir);
// Description:
//   Returns true if the input direction vector has a zero y-component (dir.y == 0),
//   indicating it lies in the horizontal plane (e.g., along the x-axis in 2D or xz-plane
//   in 3D). Used for orientation checks in geometric designs.
// Arguments:
//   dir = 2D or 3D vector to check (e.g., [x, y] or [x, y, z]). No default.
// Example:
//   dir = [1, 0, 0]; // x-axis
//   if (isHorizontal(dir)) {
//       echo("Direction is horizontal");
//       translate([0, 0, 500]) cube([1000, 10, 10]); // 1 m long along x
//   }
function isHorizontal( dir ) 	= dir.y == 0;

// Function: isVertical()
//
// Synopsis: Checks if a direction vector is vertical.
// Topics: Geometry, Orientation
// See Also: isHorizontal()
// Usage:
//   bool = isVertical(dir);
// Description:
//   Returns true if the input direction vector has a zero x-component (dir.x == 0),
//   indicating it lies in the vertical plane (e.g., along the y-axis in 2D or yz-plane
//   in 3D). Used for orientation checks in geometric designs.
// Arguments:
//   dir = 2D or 3D vector to check (e.g., [x, y] or [x, y, z]). No default.
// Example:
//   dir = [0, 1, 0]; // y-axis
//   if (isVertical(dir)) {
//       echo("Direction is vertical");
//       translate([500, 0, 0]) cube([10, 1000, 10]); // 1 m tall along y
//   }
function isVertical( dir ) 		= dir.x == 0;

// Function: rendering()
//
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
// Example(3D,Small): Simplified rendered cylinder
//   $RD = RENDER_SIMPLIFIED;
//   cyl(d=100,length=100,$fn=valueByRendering(simple=16, standard=32, detailed=64));
// Example(3D,Small): Standard rendered cylinder
//   $RD = RENDER_STANDARD;
//   cyl(d=100,length=100,$fn=valueByRendering(simple=16, standard=32, detailed=64));
// Example(3D,Small): Detailes rendered cylinder
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
// Example(3D): Attaching cuboid to top corners
//    cuboid(50) attach(TOP, BOT,align=corners(TOP)) cuboid(10,$color="Blue");
// Example(3D): Attaching cuboid to right corners
//    cuboid(50) attach(RIGHT,LEFT, align=corners(RIGHT)) cuboid(10,$color="Red");
// Example(3D): Attaching cuboid to front corners
//    cuboid(50) attach(FRONT,BACK, align=corners(FRONT)) cuboid(10,$color="Green");
// Log : corners(TOP)
//   use <utils.scad>
//   echo(str("[",dirAsName(corners(TOP)),"]") );
// Log : corners(BOT)
//   use <utils.scad>
//   echo(str("[",dirAsName(corners(BOT)),"]") );
// Log : corners(RIGHT)
//   use <utils.scad>
//   echo(str("[",dirAsName(corners(RIGHT)),"]") );
// Log : corners(FWD)
//   use <utils.scad>
//   echo(str("[",dirAsName(corners(FWD)),"]") );
function corners(face) =
    let(
        face_map = [ // [faces, corner list]
            [ [ BOT, 	TOP		], [ BACK+LEFT,	BACK+RIGHT,	FWD+LEFT,	FWD+RIGHT 	] ],
            [ [ FWD, 	BACK	], [ TOP+LEFT, 	TOP+RIGHT, 	BOT+LEFT,	BOT+RIGHT 	] ],
            [ [ RIGHT, 	LEFT	], [ BACK+TOP, 	BACK+BOT, 	FWD+TOP, 	FWD+BOT  	] ]
        ]
    )
    [for (entry = face_map) if (in_list(face, entry[0])) entry[1]][0];	
	
	
// Constant: MATERIAL_DENSITY
// Synopsis: Index for material density value (kg/m³)
MATERIAL_DENSITY 				= 0;

// Constant: MATERIAL_COMPRESSIVE_STRENGTH
// Synopsis: Index for material compressive strength (MPa)
MATERIAL_COMPRESSIVE_STRENGTH 	= 1;

// Constant: MATERIAL_ELASTICITY
// Synopsis: Index for material elasticity/modulus of elasticity (GPa)
MATERIAL_ELASTICITY 			= 2;

// Constant: MATERIAL_STRENGTH_CLASS
// Synopsis: Index for material strength classification
MATERIAL_STRENGTH_CLASS 		= 3;

// Constant: MATERIAL_APPLICATION
// Synopsis: Index for recommended applications
MATERIAL_APPLICATION 			= 4;

// Constant: MATERIAL_DESCRIPTION
// Synopsis: Index for general description of the material
MATERIAL_DESCRIPTION 			= 5;

// Constant: WOOD
//
// Synopsis: Material type identifier for wood.
// Topics: Materials, Structural
// See Also: METAL, MASONRY
// Usage:
//   material = WOOD; // Set material type to wood
// Description:
//   Defines the material type identifier for wood, assigned the value 1. Used in
//   structural or engineering designs to specify wood as a material, enabling material-specific
//   calculations such as density, cost, or weight.
WOOD    = 1;

// Constant: METAL
//
// Synopsis: Material type identifier for metal.
// Topics: Materials, Structural
// See Also: WOOD, MASONRY
// Usage:
//   material = METAL; // Set material type to metal
// Description:
//   Defines the material type identifier for metal, assigned the value 2. Used in
//   structural or engineering designs to specify metal as a material, enabling material-specific
//   calculations such as density, cost, or weight.
METAL   = 2;

// Constant: MASONRY
//
// Synopsis: Material type identifier for masonry.
// Topics: Materials, Structural
// See Also: WOOD, METAL
// Usage:
//   material = MASONRY; // Set material type to masonry
// Description:
//   Defines the material type identifier for masonry (e.g., concrete, brick), assigned the
//   value 3. Used in structural or engineering designs to specify masonry as a material,
//   enabling material-specific calculations such as density, cost, or weight.
MASONRY = 3;

// Constant: STRUCTURE_MATERIAL_FAMILIES
//
// Synopsis: Defines the list of valid material families for staircase components.
// Topics: Materials, Validation
// See Also: isValidMaterialFamilies(), materialFamilyToMaterial(), stairs(), handrail()
// Description:
//   A list of strings representing the supported material families for staircase-related modules.
//   Includes WOOD, METAL, and MASONRY. Used by validation functions like
//   isValidMaterialFamilies() to ensure the `family` argument is valid, and by
//   materialFamilyToMaterial() to map families to specific materials (e.g., WOOD to "Pine").
// Example(ColorScheme=Nature):
//   // Check if a material family is valid
//   valid = isValidMaterialFamilies(WOOD);  // Returns true
//   echo("Is Wood valid?", valid);
//   // Map a family to a material
//   material = materialFamilyToMaterial(METAL);  // Returns "Steel"
//   echo("Material for Metal:", material);
STRUCTURE_MATERIAL_FAMILIES = [ WOOD, METAL, MASONRY ];

// Function: isValidMaterialFamilies()
//
// Synopsis: Validates if a material family is defined and supported.
// Topics: Materials, Validation
// See Also: stairs(), handrail()
// Usage:
//   valid = isValidMaterialFamilies(value);
// Description:
//   Checks if the provided value is a defined string and exists in the list of supported material families
//   (e.g., WOOD, METAL, MASONRY). Used to validate the `family` argument in staircase-related modules.
// Arguments:
//   value = The material family to validate (e.g., WOOD).
// Example:
//   valid = isValidMaterialFamilies(WOOD);  // Returns true
//   valid = isValidMaterialFamilies("Plastic"); // Returns false
//   echo("Is Wood valid?", valid);
function isValidMaterialFamilies ( value ) = 
	is_def(value)  && in_list(value,STRUCTURE_MATERIAL_FAMILIES);

// Function: materialFamilyToMaterial()
//
// Synopsis: Maps a material family to a default material name.
// Topics: Materials, Mapping
// See Also: isValidMaterialFamilies(), stairs(), handrail()
// Usage:
//   material = materialFamilyToMaterial(family);
// Description:
//   Converts a material family (e.g., WOOD, METAL, MASONRY) to a specific default material name
//   (e.g., "Pine", "Steel", "Concrete"). Returns undef for invalid families. Used to set default materials
//   in staircase-related modules for rendering or metadata.
// Arguments:
//   family = The material family to map (e.g., WOOD).
// Example:
//   material = materialFamilyToMaterial(WOOD);  // Returns "Pine"
//   material = materialFamilyToMaterial(METAL); // Returns "Steel"
//   material = materialFamilyToMaterial("Plastic"); // Returns undef
//   echo("Material for Wood:", material);	
function materialFamilyToMaterial( family  ) =
	assert (isValidMaterialFamilies(family),"[materialFamilyToMaterial] is not a valid family name")
	family == WOOD 		? "Pine" : 	
	family == METAL 	? "Steel" : 	
	family == MASONRY	? "Concrete" : 	
	undef;		