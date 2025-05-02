include <constants.scad>
include <geometry.scad>
include <colors.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: utils.scad
//   Utility core libraries
// Includes:
//   include <_core/utils.scad>
// FileGroup: Core
// FileSummary: Architecture, Clearing zone
//////////////////////////////////////////////////////////////////////

// Module: extrude()
//
// Synopsis: Extrudes a 2D path along a specified BOSL2 direction.
// Topics: Geometry, Extrusion
// Usage:
//   extrude(length,[dir],[path],[center]); 
// Description:
//   Extrudes a 2D path along a specified direction (using BOSL2 direction constants like RIGHT, LEFT, FWD, BACK, UP, DOWN)
//   by a given length. The path is assumed to lie in a plane perpendicular to the extrusion direction.
//   The module aligns the 2D path appropriately based on the direction and performs a linear extrusion along the specified axis.
// Arguments:
//   length 	= Length of the extrusion (in mm).
//   dir 		= BOSL2 direction vector (e.g., RIGHT, LEFT, FWD, BACK, UP, DOWN). Default: UP.
//   path 		= Optional 2D path (list of [x, y] points). If not provided, the children() geometry is used.
//   center		= Center the geometry Default : false
// Example(3D,ColorScheme=Nature):
//   path 		= square([10, 5], center=true);
//   extrude(length=20, dir=RIGHT, path=path);
//   // Extrudes a 10x5 square 20 mm along the X-axis
// Example(3D,ColorScheme=Nature):
//   extrude(length=15, dir=FWD) {
//     circle(r=5, $fn=32);
//   }
//   // Extrudes a circle 15 mm along the negative Y-axis
// Example(3D,ColorScheme=Nature) : Extruded Right and Centered  
//   extrude(length=15, dir=RIGHT, center=true) {
//     circle(r=5);
//   }
//   // Extrudes a circle 15 mm along the negative X-axis and center 
module extrude(length, dir=UP, path=undef,center = false,anchor,spin) {
    assert(is_num(length) && length > 0, "length must be a positive number");
    assert(is_vector(dir) && norm(dir) > 0, "direction must be a valid BOSL2 direction vector");
    // Normalize direction to ensure it's a unit vector
    _dir = unit(dir);
	rot = 
		_dir == DOWN	? [180,0,0] : 
		_dir == RIGHT 	? [0,90,0] 	:
		_dir == LEFT 	? [0,-90,0] :
		_dir == RIGHT 	? [0,-90,0] :
		_dir == FWD 	? [90,0,0] 	:
		_dir == BACK 	? [-90,0,0] :
		CENTER ;
	centering = center ? -_dir * length /2 : CENTER;
	//move(centering)
	//rotate( rot ) apply_color() linear_extrude( height=length, center=false ) 
	{
		if (!is_undef(path)) {
			//size 	= boundingSize(path,length);
			size 	= v_abs(rot(rot,p=boundingSize(path,length)));
			attachable( anchor = anchor, spin = spin, size = size /*,cp = -centering*/ ) { 
				move(centering)
				rotate( rot ) apply_color() 
					linear_extrude( height=length, center=false )
						polygon(path);
				children();
			}
		} else {
			move(centering)
			rotate( rot ) apply_color() linear_extrude( height=length, center=false ) children();
		}
	}
}

/*
extrude(length=15, direction=FWD) circle(r=5, $fn=32); // ok
extrude(length=15, direction=BACK) circle(r=5, $fn=32); // ok
extrude(length=15, direction=RIGHT) circle(r=5, $fn=32); // ok
extrude(length=15, direction=LEFT) circle(r=5, $fn=32); // ko still right
extrude(length=15, direction=UP) circle(r=5, $fn=32); // ok
extrude(length=15, direction=DOWN) circle(r=5, $fn=32); // ko still up


extrude(length=15, direction=FWD, center=true) circle(r=5, $fn=32); // ok
extrude(length=15, direction=BACK, center=true) circle(r=5, $fn=32); // ok
extrude(length=15, direction=RIGHT, center=true) circle(r=5, $fn=32); // ok
extrude(length=15, direction=LEFT, center=true) circle(r=5, $fn=32); // ko still right
extrude(length=15, direction=UP, center=true) circle(r=5, $fn=32); // ok
extrude(length=15, direction=DOWN, center=true) circle(r=5, $fn=32); // ko still up


module yExtrude( height ) {
	assert($children > 0, 				"[xExtrude] required a 2d children polygon to extrude");
	assert(is_num(height) && height >0,	"[xExtrude] Extrusion height should be define and bigger than 0 " )
	path_extrude2d(yLine( length = height)) children();
}
*/
/*
color ("Red") extrude(length=15, direction=FWD,center = true) circle(r=5, $fn=32); // ok
right(5)
yExtrude(15) circle(r=5, $fn=32); 	
*/



// Function: dirAsName()
// 
// Synopsis: Converts a direction vector or constant to its string name.
// Topics: Utilities, Directions, Geometry
// Description:
//    Takes a BOSL2 direction vector or constant (e.g., RIGHT, LEFT, FWD) and returns
//    its corresponding string name (e.g., "RIGHT", "LEFT", "FORWARD"). Returns
//    "Unknown" for unrecognized inputs. Useful for debugging, labeling, or
//    generating human-readable output in architectural models.
// Arguments:
//    dir = Direction vector or constant (e.g., RIGHT, [1,0,0]) [required].
// DefineHeader(Generic):Returns:
//    A string representing the direction name, or "Unknown" if not recognized.
function dirAsName( dir ) =
	is_path(dir ) ? join([for ( d = dir) dirAsName(d)],",") : 
    assert(is_def(dir), "dir must be defined")
    assert(is_vector(dir) && len(dir) == 3, str("dir must be a 3D vector dir =",dir))
	
    let (
        dirs = [ // BOSL2 standard direction vectors and their names
            [RIGHT,  "RIGHT"],
            [LEFT,   "LEFT"],
            [FWD,    "FRONT"],
            [BACK,   "BACK"],
            [TOP,    "TOP"],
            [BOT,    "BOT"],
            [CENTER, "CENTER"]
        ],
        // Check for exact match with a single direction
        single_match = [for (d = dirs) if (dir == d[0]) d[1]],
        // If single match found, return it
        result = len(single_match) > 0 ? single_match[0] :
                 // Otherwise, decompose into components
                 let (
                     components = [
                         for (d = dirs)
                             if (dot(dir, d[0]) > 0) // Positive contribution only
                             d[1]
                     ]
                 )
                 len(components) > 0 ? str_join(components, "+") : "Unknown"
    )
    result;	
	
// Module: booleanDiff()
// 
// Synopsis: Performs a boolean difference with tagged geometry.
// Topics: Geometry, Boolean Operations
// Description:
//    Executes a boolean difference operation between tagged geometry, using BOSL2's
//    tagging system, for use with the space module. The 'keep' tagged geometry is
//    retained, while 'remove' tagged geometry is subtracted. Sets $multi_pass to true
//    to indicate a multi-pass operation for blocks executed once, such as in space
//    module's wall and opening configurations. Requires at least one child.
// Arguments:
//    remove = Tag for geometry to subtract [default: "remove"].
//    keep   = Tag for geometry to retain [default: "keep"].
// Context Variables:
//    $multi_pass = Indicates multi-pass operation (set to true).
module booleanDiff(remove="remove", keep="keep") {
    // Validate inputs
    assert(is_string(remove), 	"[booleanDiff] remove must be a string of tags");
    assert(is_string(keep), 	"[booleanDiff] keep must be a string of tags");
    req_children($children); // BOSL2 function to ensure children exist

    if (_is_shown()) {
        $multi_pass = true;
        difference() {
            hide(str(remove, " ", keep)) children();
            show_only(remove) children();
        }
    }
    show_int(keep) children();
}	

// Function&Module: unMutable()
//
// Synopsis: Checks if rendering is in single-pass mode for immutable objects.
// Topics: Rendering, Tagging
// Usage: As a Module
//   unMutable() { ...  };
// Usage: As a Function
//   if (unMutable) { ...};
// Description:
//   When called as function returns true if the rendering context is in single-pass mode (i.e., `$multi_pass` is
//   undefined or false). Identical to `singlePass()` but semantically distinct for objects
//   that are explicitly immutable (not subject to boolean operations).
//   When called as function renders children only if the rendering context is in single-pass mode, as determined
//   by the `unMutable()` function. Designed for objects that should remain unaffected by
//   boolean operations, ensuring they are rendered as-is.
function unMutable() = is_undef($multi_pass) || $multi_pass == false ;
module unMutable() { if (unMutable()) children(); }


// Function: anchorInfo()
//
// Synopsis: Retrieves a property or sub-property from $attach_anchor.
// Topics: Data Structures, Geometry, Metadata
// Description:
//   Queries the global $attach_anchor structure to retrieve a specified property
//   or a sub-property within it. If only property is provided, returns its value
//   (e.g., a geometry path for "geom"). If sub_property is provided, treats the
//   property’s value as a struct and retrieves the sub_property value. Returns
//   undef if $attach_anchor, property, or sub_property is undefined or not found.
//   Used in structural modules like roofFrame to access contextual data such as
//   mask geometry or anchor metadata.
// Arguments:
//   property 		= Key to query in $attach_anchor (e.g., "geom").
//   sub_property 	= Optional sub-key to query within property’s value [default: undef].
// Example:
//   $attach_anchor = [["geom", circle(100)], ["meta", [["type", "roof"]]]];
//   geom = anchorInfo("geom"); // Returns square(100, center=true)
//   type = anchorInfo("meta", "type"); // Returns "roof"
function anchorInfo( property , sub_property ) =	
	let(
		data 		= flatten($attach_anchor), 
		_data		= is_struct(data) ? data : $attach_anchor[4],
		struct 		= struct_set([], _data),
		result 		= struct_val(struct,property),
		sub_struct 	= sub_property ? struct_set([], flatten(result)) : undef
	)
	is_undef(sub_property) ? struct_val(struct,property) : struct_val(sub_struct,sub_property);

	
// Module: stack()
// 
// Synopsis: Stacks a child geometry on top of a parent, centered in x-y.
// Topics: Geometry, Alignment, Architecture
// Description:
//    Positions a child geometry on top of a parent geometry, aligning the
//    child’s center to the parent’s top face center. This is useful for
//    stacking layers, such as cladding or additional wall sections, in
//    architectural models. The module relies on BOSL2’s alignment system
//    and requires a parent geometry to be defined.
// Arguments:
//    ---
//    No arguments are required; the module operates on the parent and child
//    geometries directly.
// Usage:
//    parent_geometry() stack() child_geometry();
// Example(3D,ColorScheme=Nature):
//    cuboid([20, 20, 10], anchor=CENTER)
//       stack() cuboid([10, 10, 5], anchor=CENTER);
module stack() {
	align(TOP, CENTER) children();
}	

// Module: miterCut()
//
// Synopsis: Creates a miter cut for profiles,tubes or any geometry using BOSL2 attach
// Topics: Geometry
// Description:
//   Generates a miter cut at a specified angle for use in profiles or tubes.
//   Positive angle start the cut from the bottom while negative start by the top    
//   
// Arguments:
//   section 	= Height and depth of the profile/tube
//   angle 		= Miter angle in degrees clock wize (default: 45). 
//
// Example(3D,ColorScheme=Nature,Small): Top angle clockwise
//   diff() cuboid([50,20,80]) attach(TOP) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Nature,Small): Top angle counter clockwise
//   diff() cuboid([50,20,80]) attach(TOP) miterCut([20,50],angle=-20);
// Example(3D,ColorScheme=Nature,Small): Bottom angle clockwise
//   diff() cuboid([50,20,80]) attach(BOT) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Nature,Small): Bottom angle counter clockwise
//   diff() cuboid([50,20,80]) attach(BOT) miterCut([20,50],angle=-20);
// Example(3D,ColorScheme=Nature,Small): Right angle clockwise
//   diff() cuboid([80,20,50]) attach(RIGHT) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Nature,Small): Right angle counter clockwise
//   diff() cuboid([80,20,50]) attach(RIGHT) miterCut([20,50],angle=-20);
// Example(3D,ColorScheme=Nature,Small): Left angle clockwise
//   diff() cuboid([80,20,50]) attach(LEFT) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Nature,Small): Left angle counter clockwise
//   diff() cuboid([80,20,50]) attach(LEFT) miterCut([20,50],angle=-20);
// Example(3D,ColorScheme=Nature,Small): Front angle clockwise
//   diff() cuboid([20,80,50]) attach(FRONT) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Nature,Small): Front angle counter clockwise
//   diff() cuboid([20,80,50]) attach(FRONT) miterCut([20,50],angle=-20);
// Example(3D,ColorScheme=Nature,Small): Back angle clockwise
//   diff() cuboid([20,80,50]) attach(BACK) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Nature,Small): Back angle counter clockwise
//   diff() cuboid([20,80,50]) attach(BACK) miterCut([20,50],angle=-20);

module miterCut( section, angle=45,debug=false) {
	shift 	= ang_adj_to_opp(abs(angle),section.y);
	
	anchorSign = sum($anchor);
	vertical =  $anchor.z != 0;
	_orient = vertical ? -anchorSign* $anchor : FWD;
	
	spinV = angle  > 0 ? -90 : +90;
	spinH = angle  > 0 ? -180 :-180 ; // ko : OK
	
	_spin = vertical ? spinV : spinH; 
	_wedgeOrient = vertical? UP : BACK;
	_wedgespin = vertical? 0 : (angle  > 0 ? 0 : 180);
	
	size 		= [ section.y,section.x,shift];
	wedgeSize 	= [ section.x,section.y,shift ];
	
	move = v_mul(UP,-wedgeSize)/2;
	
	move(move)
	tag(debug ? "keep" : "remove")
	attachable( size=wedgeSize,orient=_orient,spin=_spin /*,cp=[0,section.x/2,section.y] */ ) {
		union() {
			wedge(
				wedgeSize+4*[CLEARANCE,CLEARANCE,CLEARANCE],
				center=true,/*,orient=orient*/
				orient=_wedgeOrient,
				spin=_wedgespin,
			);		
		}
		children();
	}	
}

// Module: alignWith
//
// Synopsis: Aligns child geometry along a line segment between two 3D points.
// Topics: Transformations, Geometry, Alignment
// Usage: 
//   alignWith( segment, twist ) { ...  };
// Description:
//   Positions and orients child geometry along the line from p1 to p2, with the
//   geometry’s local X-axis aligned to the line direction. The length of the line
//   is stored in $align_length for use by children (e.g., to set a cuboid’s length).
//   The twist parameter controls the cross-section’s orientation:
//   - twist=true: Applies minimal rotation, which may result in arbitrary rotation
//     of the Y-Z plane (twist).
//   - twist=false: Orients the local Z-axis toward the global up direction [0,0,1],
//     preventing twist in the cross-section.
//   The module translates the geometry to p1, ensuring the start of the line is at
//   the geometry’s local origin (e.g., LEFT anchor for cuboids).
// Arguments:
//   p1 	= Starting point of the line segment [x, y, z].
//   p2 	= Ending point of the line segment [x, y, z].
//   twist 	= Boolean to allow cross-section twist [default: false].
//
// Example(3D,ColorScheme=Nature):
//   alignWith([[0,0,0], [10,5,5]], twist=false)
//       cuboid([$align_length, 2, 3], anchor=LEFT);
// Example(3D,ColorScheme=Nature):
//   alignWith([[0,0,0], [0,10,0]], twist=true)
//       cylinder(h=$align_length, r=1);
module alignWith( segment , twist = false ) {
	unit = unit(segment[1] - segment[0]);
	$align_length = norm(segment[1] - segment[0]);
	midpoint = midpoint(segment);
	translate( midpoint ) 
	{
		if (twist) {
			angle = acos( RIGHT * unit);
			rotation = let(c = cross(RIGHT, unit)) norm(c) > 1e-6 ? unit(c) : UP;
			rotate(angle, rotation)	children();
		} else {
			proj_up	= UP - UP * unit* unit; // Dot product for projection
			zAxis 	= norm(proj_up) > EPSILON ? unit(proj_up) : BACK; // Local Z-axis
			yAxis 	= unit(cross(zAxis, unit));
			rot_matrix = [
				[unit.x, yAxis.x, zAxis.x],
				[unit.y, yAxis.y, zAxis.y],
				[unit.z, yAxis.z, zAxis.z]
			];
			multmatrix(rot_matrix) children();
		}
	}	
}