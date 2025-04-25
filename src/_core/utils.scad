include <constants.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: utils.scad
//   Utility core libraries
// Includes:
//   include <Nervi/_core/utils.scad>
// FileGroup: Core
// FileSummary: Architecture, Clearing zone
//////////////////////////////////////////////////////////////////////

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
// Example(3D,ColorScheme=Nature)
//    cuboid([20, 20, 10], anchor=CENTER);
//    	stack() cuboid([10, 10, 5], anchor=CENTER);
module stack() {
	align(TOP, CENTER) children();
}	