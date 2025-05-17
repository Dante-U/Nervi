include <constants.scad>
use <geometry.scad>
use <assert.scad>
use <colors.scad>

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
// Example(3D,ColorScheme=Tomorrow): Extrudes a 10x5 square 20 mm along the X-axis
//   path 		= square([10, 5], center=true);
//   extrude(height=20, dir=RIGHT, path=path);
// Example(3D,ColorScheme=Tomorrow): Extrudes a circle 15 mm along the negative Y-axis
//   extrude(height=15, dir=FWD) 
//     circle(r=5, $fn=32);
// Example(3D,ColorScheme=Tomorrow) : Extruded Right and Centered  
//   extrude(height=15, dir=RIGHT, center=true) circle(r=5);
module extrude(height, dir=UP, path, center=false, path_centering = true, anchor, spin) {
    assert(is_num_positive(height), 			"[extrude] height must be a positive number");
    assert(is_vector(dir) && norm(dir) > 0, 	"[extrude] direction must be a valid BOSL2 direction vector");
	if (is_def(anchor)) assert(is_def(path), 	"[extrude] anchor works only with path");
	flip = 	dir == DOWN 	? RIGHT : 
			dir == RIGHT 	? BACK : 
			dir == BACK 	? UP : 
			CTR;
	rot = abs(dir.x) * 90;	
	shift = center ? dir * height /2 : CTR;
	move(-shift)	
	if (is_def(path)) {
		_path = path_centering ? centerPath( path ) : path;
		tmat =  (flip == CTR ? 1 : mirror(flip)) *     xrot(rot) * tilt(dir);
		size = boundingSize(_path,height);
		_size = v_abs(apply(tmat,size)); // Work with RIGHT,LEFT,UP,DOWN 
		attachable(anchor=anchor, spin=spin, size=_size) {
			mirror(flip) xrot(rot) tilt(dir) applyColor()  
				linear_extrude( height=height, center=false ) polygon(_path);
			children();		
		}	

	} else {
		mirror(flip) xrot(rot) tilt(dir) applyColor()  
			linear_extrude( height, center=false ) children();
	}
}

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
// Example: 
//    echo(dirAsName(TOP));	
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
							 //if ( dir * d[0] ) > 0) // Positive contribution only
                             d[1]
                     ]
                 )
                 len(components) > 0 ? str_join(components, "+") : "Unknown"
    )
    result;	

function dot(v1, v2) = v1 * v2;
	
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
// Example(3D,ColorScheme=Tomorrow):
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
// Example(3D,ColorScheme=Tomorrow,Small): Top angle clockwise
//   diff() cuboid([50,20,80]) attach(TOP) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Tomorrow,Small): Top angle counter clockwise
//   diff() cuboid([50,20,80]) attach(TOP) miterCut([20,50],angle=-20);
// Example(3D,ColorScheme=Tomorrow,Small): Bottom angle clockwise
//   diff() cuboid([50,20,80]) attach(BOT) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Tomorrow,Small): Bottom angle counter clockwise
//   diff() cuboid([50,20,80]) attach(BOT) miterCut([20,50],angle=-20);
// Example(3D,ColorScheme=Tomorrow,Small): Right angle clockwise
//   diff() cuboid([80,20,50]) attach(RIGHT) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Tomorrow,Small): Right angle counter clockwise
//   diff() cuboid([80,20,50]) attach(RIGHT) miterCut([20,50],angle=-20);
// Example(3D,ColorScheme=Tomorrow,Small): Left angle clockwise
//   diff() cuboid([80,20,50]) attach(LEFT) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Tomorrow,Small): Left angle counter clockwise
//   diff() cuboid([80,20,50]) attach(LEFT) miterCut([20,50],angle=-20);
// Example(3D,ColorScheme=Tomorrow,Small): Front angle clockwise
//   diff() cuboid([20,80,50]) attach(FRONT) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Tomorrow,Small): Front angle counter clockwise
//   diff() cuboid([20,80,50]) attach(FRONT) miterCut([20,50],angle=-20);
// Example(3D,ColorScheme=Tomorrow,Small): Back angle clockwise
//   diff() cuboid([20,80,50]) attach(BACK) miterCut([20,50],angle=+20);
// Example(3D,ColorScheme=Tomorrow,Small): Back angle counter clockwise
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
// Example(3D,ColorScheme=Tomorrow):
//   alignWith([[0,0,0], [10,5,5]], twist=false)
//       cuboid([$align_length, 2, 3], anchor=LEFT);
// Example(3D,ColorScheme=Tomorrow):
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