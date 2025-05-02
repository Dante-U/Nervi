include <_core/main.scad>
include <_materials/masonry.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: space.scad
// Includes:
//   include <space.scad>
// FileGroup: Superstructure
// FileSummary: Architecture, Building, Furniture, BIM
//////////////////////////////////////////////////////////////////////

// Constant: WALL_DEFAULT
// Description: Wall default thickness
WALL_DEFAULT 	= 180;

// Module: space()
// 
// Synopsis: Creates a 3D architectural space with walls and optional metadata.
// SynTags: Geom, Attachable, BIM
// Topics: Architecture, Geometry, IFC
// See Also: slab(),hasSpaceParent()
// Usage:
//    space(l, w, h, wall,[except], [wall_material], [debug], [spin], [info], [name]);
// Description:
//    Generates a rectangular space defined by length, width, height, and wall thickness.
//    Supports custom anchors, exclusions, and IFC metadata for architectural modeling.
//    Renders walls in 3D views or outlines in 2D plan views, with optional room name
//    and area text. Uses context variables for defaults and supports attachments.
//    ifcWall 
// Arguments:
//    l      = Length of the space (m) [default: $space_length].
//    w      = Width of the space (m) [default: $space_width].
//    h      = Height of the space (m) [default: $space_height].
//    wall   = Wall thickness (m) [default: $space_wall or 0.2].
//    wall_material = Wall material name [default: "Plaster"].
//    debug  = Enable debug visualization [default: false].
//    except = List of sides to exclude (e.g., ["FRONT"]) [default: []].
//    anchor = Anchor point for positioning [default: BOTTOM].
//    spin   = Rotation angle (degrees) [default: 0].
//    info   = Enable metadata output [default: false].
//    name   = Room name for plan view [default: undef].
//    ifc_guid = IFC global unique ID [default: auto-generated].
// Context Variables:
//    $space_length = Default length (m). Optional.
//    $space_width  = Default width (m). Optional.
//    $space_height = Default height (m). Optional.
//    $space_wall   = Default wall thickness (m). Optional.
// Example(3D,ColorScheme=Nature):
//    space(l=3, w=2, h=2.5, wall=200, name="Room", except=["FRONT"],debug=true);
// See Also: wallGeometry()
module space( 
		l       = first_defined([is_undef(l) 	? undef : l ,$space_length]),
		w       = first_defined([is_undef(w) 	? undef : w ,$space_width]),
		h       = first_defined([is_undef(h) 	? undef : h ,$space_height]),
		wall    = first_defined([is_undef(wall) ? undef : w ,is_undef($space_wall) ? undef : $space_wall ,WALL_DEFAULT ]),
		wall_material = "Plaster",
		debug   = false,
		except	= [], 
		anchor 	= BOTTOM,
		spin,
		info = false,
		name,
        ifc_guid	// IFC parameters	
	){
	assert(is_meters(l),			"[space] [l] is undefined. Provide length or define variable $space_length");
	assert(is_meters(w),			"[space] [w] is undefined. Provide width or define variable $space_width");
	assert(is_meters(h),			"[space] [h] is undefined. You should provide height or define variable $space_height");
	assert(is_num_positive(wall),	"[space] [wall] parameter is undefined. Provide wall thickness or define variable $space_wall");

	$space_length	= l;
	$space_width 	= w;
	$space_height 	= h;
	$space_wall 	= wall;
	$space_except	= except;
	
	assert($space_length<100,"Space length is probably in milimeters");
	_length = meters( $space_length ) 	+ 2 * wall;
	_width 	= meters( $space_width )	+ 2 * wall;
	_height = meters( $space_height ); 
	bounding = [meters( $space_length ),meters( $space_width ),meters( $space_height )]; 
	
	_wall = wall > 0 ? wall : 10; 
	
	if (provideMeta(info)) {
		// Generate a GUID if not provided
		_ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
		$meta = info ?  [
			["volume",		l * w * h	]	,
			["area",		l * w		]	,
			if (name) 
			["name",		name		]	,
			// Add IFC metadata
            ["ifc_class",   "IfcSpace"   ],
            ["ifc_type",    "SPACE"    ],
            ["ifc_guid",    _ifc_guid   ],			
		] : undef;
		info();
	}
	sides = [
		[FRONT,  [0, -(meters($space_width)+wall)/2, 0], [_length,	_wall, 	_height], BACK  ],
		[BACK,   [0, +(meters($space_width)+wall)/2, 0], [_length, 	_wall, 	_height], FRONT ],
		[LEFT,   [-(meters($space_length)+wall)/2,0, 0], [_wall, 	_width,	_height], RIGHT ],
		[RIGHT,  [+(meters($space_length)+wall)/2,0, 0], [_wall, 	_width,	_height], LEFT  ]
	];
	anchors = [
		for (_anchor = SIDES) for (inside = [true,false])
			let (
				//name		= str(dirAsName(_anchor),"_",inside ? "INSIDE" : "OUTSIDE"),
				size 		= inside ? bounding/2 : bounding/2 + [ wall, wall , 0 ] , 
				orient  	= inside ? -_anchor : _anchor,
				geom    	= wallGeometry(_anchor,inside),
				shift      	= sum(centroid(geom)) * point2d( vector_axis( orient,UP ) 	),
				pos 		= v_mul(_anchor,size) + shift  ,
				spin		= v_theta(_anchor)+(inside?-90:90),
			)
			named_anchor (wallAnchor(_anchor,inside), pos, orient, spin=spin, info = ["geom",centerPath(geom)] )   
    ];
	booleanDiff("opening roofCut")	
	attachable( anchor = anchor, spin = spin, size = bounding, anchors = anchors ) { 
		union()  {
			if ( isView3D()) {
				if (debug) 
					for ( s = sides) if (!in_list(s[0], except)) 
						translate(s[1]) 
							//ghost() 
							material("Template")
							cuboid(s[2]);
			}	
			else if (isViewPlan()) {
				down(_height/2) {
					for ( s = sides) if (!in_list(s[0], except)) {
						dim = s[2];
						translate(s[1])	rect([dim.x,dim.y]);
					}
					if (name) {
						fontSize = clamp(_length /20,0,400);
						echo ("text",name);
						text (name,halign="center",size=fontSize);
						fwd(fontSize/2)
						text (str("A:",format_area( l* w ) ),valign="top",halign="center",size=fontSize/2);
					}	
				}
			}	
		}
		children();
	}
}

// Module: attachWalls()
// 
// Synopsis: Attaches geometry to walls of a space defined by the space module.
// Topics: Architecture, Attachment, Geometry
// Description:
//    Attaches child geometry to specified walls of a space, using BOSL2 anchors
//    from the space module. Supports inside or outside placement, respecting
//    exclusions unless forced. Requires space module's context variables.
// Arguments:
//    faces     = Wall sides to attach to (BACK, RIGHT, FORWARD, LEFT, or list) [default: SIDES].
//    placement = Attachment placement ("inside", "outside", or "both") [default: "outside"].
//    force     = Ignore $space_except exclusions [default: false].
// Side Effects:
//    `$wall_length` is set to the length of the wall 
//    `$wall_height` is set to the height of the wall 
//    `$wall_inside` is set to true if it's inside walls
//    `$wall_orient` is set to define the wall orientation
// Context Variables:
//    $space_except = List of excluded sides from space module. Optional.
//    $space_length = Space length (m). Required.
//    $space_width  = Space width (m). Required.
//    $space_height = Space height (m). Required.
//    $space_wall   = Wall thickness (m). Required.
// Example(3D,ColorScheme=Nature):
//    space(3,2,2.5,debug=true)
//       attachWalls(faces=[LEFT,FRONT], placement="outside")
//          material("Brick") cuboid(500,anchor=DOWN);
// Example(3D,ColorScheme=Nature):
//    space(3,2,2.5,debug=true,except=[FRONT,LEFT]) 
//       attachWalls(faces=[BACK,RIGHT], placement="inside")
//          material("Brick") cuboid(500,anchor=DOWN);
// See Also: space(), wallAnchor()
module attachWalls( faces = SIDES , child, placement = "outside", force = false ) {
	sides = placement == "outside" ? [false] : placement == "inside" ? [true] : [false,true];
	_anchors = is_vector(faces) || is_string(faces) ? [faces] : faces;
	anchors = is_undef( $space_except) || force ? _anchors : set_difference(_anchors,$space_except) ;
	for ( anchor = anchors ) for (inside = sides) {
		$wall_inside 	= inside; 
		$wall_orient	= ($wall_inside ? -1 : 1) * anchor;
		attach( wallAnchor( anchor, inside)/*,align=[LEFT]*/ ) 
		let( 
			size  			= boundingSize(anchorInfo("geom")),
			$wall_length 	= size.x / 1000, 
			$wall_height 	= size.y / 1000 
			)
		{
			children(0);
			if ($children > 1) children([1:$children-1]);
		}	
	}	
}

//echo ("wallAnchor",wallAnchor(FRONT,true));

// Function: wallAnchor()
// Synopsis: Generates a wall anchor name.
// Topics: Geometry, Helpers
// Description:
//    Creates a string name for a wall anchor based on side and inside flag.
// Arguments:
//    anchor = Wall side (BACK, RIGHT, FORWARD, LEFT). No default.
//    inside = Inside surface [default: false].
// Example:
//    name = wallAnchor(BACK, true); // Returns "BACK_INSIDE"
function wallAnchor(anchor, inside ) = str(dirAsName(anchor), "_", inside ? "INSIDE" : "OUTSIDE");


// Function: wallGeometry()
// Synopsis: Generates 2D points for a wall's surface in a space.
// Topics: Architecture, Geometry
// Description:
//    Returns a list of 2D points defining the surface of a wall in a space, for use with
//    the space module. Points form a rectangle adjusted for wall thickness and exclusions.
//    Supports inside or outside surfaces, accounting for adjacent excluded walls.
// Arguments:
//    side   = Wall side (BACK, RIGHT, FORWARD, LEFT). No default.
//    inside = Inside surface [default: false].
// Context Variables:
//    $space_length = Space length (m). Required.
//    $space_width  = Space width (m). Required.
//    $space_height = Space height (m). Required.
//    $space_wall   = Wall thickness (m). Required.
//    $space_except = List of excluded sides [default: []].
// See Also: space(), wallAnchor()
function wallGeometry(side, inside = false) =
    let (
        length 			= assert(is_num($space_length), 	"Missing $space_length") $space_length,
        width 			= assert(is_num($space_width), 		"Missing $space_width") $space_width,
        height 			= assert(is_num($space_height), 	"Missing $space_height") $space_height,
        wall_thickness 	= assert(is_num($space_wall), 		"Missing $space_wall") $space_wall,
        except 			= is_def($space_except) ? $space_except : [],
		
        // Determine wall orientation and dimensions based on side
		is_horizontal 	= isVertical(side),  				// FRONT/BACK walls span length (x)
        wall_length 	= is_horizontal ? length : width,   // Length along wall
        wall_height 	= height,                           // Height of wall
        half_length 	= meters(wall_length) / 2,          // Half-length in meters
        half_height 	= meters(wall_height) / 2,          // Half-height in meters

        // Determine if adjacent sides are excluded (for inside surface)
        right_adjacent 	= is_horizontal ? ( side == FRONT ? RIGHT : LEFT) : (side == LEFT ? FRONT : BACK),  // Adjacent side to the right
        left_adjacent 	= is_horizontal ? ( side == FRONT ? LEFT : RIGHT) : (side == LEFT ? BACK : FRONT),   // Adjacent side to the left

        right_excluded 	= in_list( right_adjacent, 	except ),
        left_excluded 	= in_list( left_adjacent, 	except ),

        // Wall thickness extensions for left and right ends
        left_extension 	= !inside ? wall_thickness : (inside && left_excluded ? wall_thickness : 0),
        right_extension = !inside ? wall_thickness : (inside && right_excluded ? wall_thickness : 0),

        // Define 2D points for the wall surface (bottom-left, bottom-right, top-right, top-left)
        points = [
            [-half_length - left_extension,  -half_height],  // Bottom-left
            [+half_length + right_extension, -half_height], // Bottom-right
            [+half_length + right_extension, +half_height], // Top-right
            [-half_length - left_extension,  +half_height]   // Top-left
        ]
    )
    points;	

// Module: spaceWrapper()
// 
// Synopsis: Wraps a space with attachment capabilities.
// Topics: Architecture, Attachment, Geometry
// Description:
//    Wraps a space defined by the space module, providing a bounding box for
//    attachments and passing children for further processing. Ensures context
//    variables are set and positions children at the space's center height.
//    Used to encapsulate architectural elements like walls, furniture, or openings.
// Arguments:
//    None.
// Context Variables:
//    $space_length = Space length (m). Required.
//    $space_width  = Space width (m). Required.
//    $space_height = Space height (m). Required.
// See Also: space(), attachWalls(), wallAnchor()
module spaceWrapper() {
    assert(is_num($space_length), 	"Missing $space_length");
    assert(is_num($space_width), 	"Missing $space_width");
    assert(is_num($space_height), 	"Missing $space_height");
    assert($children > 0, "At least one child is required");
    let (
        size	= meters([$space_length, $space_width, $space_height]),
        cp 		= [0, 0, size.z / 2]
    ) attachable( size = size, cp = cp) {
        children(0);
        if ($children > 1) children([1:$children-1]);
    }
}

// Module: placeOpening()
// 
// Synopsis: Places openings (e.g., doors, windows) on space walls.
// Topics: Architecture, Geometry, Openings
// Description:
//    Positions a cuboidal opening (e.g., for doors or windows) on specified wall anchors
//    of a space, with optional inset and debug visualization. Applies a boolean difference
//    to cut the opening from the wall and supports child geometry (e.g., door frames).
//    Requires space module's context variables and works with attachWalls.
//    ifcOpening
// Arguments:
//    anchors = Wall anchor(s) for placement (LEFT, RIGHT, CENTER, or list). No default.
//    w       = Opening width (m). No default.
//    h       = Opening height (m). No default.
//    inset   = [x, y] inset from wall edge and bottom (m) [default: [0, 0]].
//    debug   = Enable debug visualization [default: false].
//    opening = Opening thickness ratio [default: 1].
// Context Variables:
//    $wall_length = Wall length (m). Required.
//    $wall_height = Wall height (m). Required.
//    $wall_orient = Wall orientation vector. Required.
// Example(3D,ColorScheme=Nature,NoAxis):
//    space(3,3,2.3,debug=true) 
//       attachWalls(faces=[FRONT], placement="both") 
//          cuboid(meters([$wall_length,$wall_height,0.10]))
//             placeOpening(anchors=[CENTER], w=1.2, h=1.8, opening=0.5);
// See Also: space(), attachWalls(), wallAnchor()
module placeOpening(anchors,w,h,inset=[ 0,0 ],debug = false, opening = 1) {
    assert(is_def(anchors),	"[placeOpening] anchors must be defined (vector, string, or list)");
    assert(is_meters(w), 	"[placeOpening] w must be a positive number (meters)");
    assert(is_meters(h), 	"[placeOpening] h must be a positive number (meters)");
    // Restrict anchors to LEFT, RIGHT, CENTER
    valid_anchors 	= [LEFT, RIGHT, CENTER];
    anchor_list 	= is_list(anchors) ? anchors : [anchors];
    assert(all([for (a = anchor_list) any([for (v = valid_anchors) a == v])]),
           "anchors must be LEFT, RIGHT, CENTER, or a list of these");	
	
	_w = meters(w);
	_h = meters(h);
	$opening_width = w;
	$opening_height = h;
	$opening_ratio  = opening;
	clearance = 0.01;
	
	for ( anchor = anchors ) {
		orient = -desc_dir();
		bottomShift	= orient[Y] * (meters($wall_height) / 2 -inset[Y] -_h/2 ) -CLEARANCE ;
		sideShift 	= orient[Y] * (meters($wall_length) / 2 -inset[X] - OFFSET ) ;
	
		translate([
			anchor[X] * ( meters( $wall_length 	/ 2  ) ) -anchor[X] * (inset[X]+_w/2) , 
			bottomShift,
			-meters( $wall_height ) / 2 *0 
		]){	
			if (debug) frame_ref(1500);
			tag(debug ? "keep" : "opening")
				cuboid([_w,_h,600]);
			tag("keep")	
				children();
		}
	}
}

		
// Function: hasSpaceParent()
//
// Synopsis: Checks if the space module is a direct parent in the call stack.
// Topics: Architecture, Utilities
// Description:
//   Returns true if the space module is the parent module 6 levels up in the call stack.
//   Useful for context-aware behavior in modules nested within a space.
// Returns: Boolean indicating if space is the parent.
// Example(3D,Big,ColorScheme=Nature):
//   space(l=3, w=3, h=2, debug=true, except=[FRONT, RIGHT]) {
//     if (hasSpaceParent()) cuboid([1000, 1000, 100], anchor=BOT);
//   }
function hasSpaceParent()  = $parent_modules > 6 && parent_module(6) == "space";

// Module: divider()
// 
// Synopsis: Creates a divider wall within a space.
// Topics: Architecture, Geometry, Walls
// Description:
//    Generates a rectangular divider wall with specified length, thickness, and height,
//    typically used within a space to partition areas. Aligns with the space module's
//    context for wall thickness and supports BOSL2-style attachments. Applies a material
//    tag for rendering and positions the divider relative to a specified anchor.
// Arguments:
//    l    		= Divider length (mm).
//    h    		= Divider height (mm).
//    wall 		= Divider thickness (mm) [default: $space_wall or WALL_DEFAULT].
//    anchor    = Anchor point for positioning [default: BOTTOM].
//    spin      = Rotation angle (degrees) [default: 0].
// Context Variables:
//    $space_wall = Wall thickness (mm) from space module. Optional.
// Example(3D,ColorScheme=Nature,NoAxis):
//    include <masonry-structure.scad>
//    space(4,3,2.2,debug=true,except=[FRONT,LEFT]){
//       slab();
//       align(BACK+BOT,inside=true)
//          divider( l=2, h=1.5, wall=200,spin=-90,material="Brick" );
//    }
module divider( 
		l, 		
		h,
		wall	= is_undef( $space_wall ) ? WALL_DEFAULT : $space_wall,
		anchor	= BOT,
		material = "plaster",
		spin
	) {
	size = meters([l,wall/1000, h ]); 
	tag("keep") attachable( size = size/* ,cp = [0,0,size.z/2*0]*/, spin = spin, anchor = anchor ) {
		material(material)
			cuboid([size.x,size.y,size.z]/* ,anchor=BOT*/);
		children();
	}
}

// Function: roomBound()
// 
// Synopsis: Calculates the bounding box of a room including wall thickness.
// Topics: Architecture, Geometry
// Description:
//    Returns a 3D vector representing the bounding box dimensions of a room, 
//    including the wall thickness added to length and width, based on the space 
//    module's context variables. Used to define the external dimensions of a space 
//    for positioning or attachment purposes.
// Arguments:
//    length = Room length (m) [default: $space_length].
//    width  = Room width (m) [default: $space_width].
//    height = Room height (m) [default: $space_height].
//    wall   = Wall thickness (m) [default: $space_wall].
// Context Variables:
//    $space_length = Default room length (m). Optional.
//    $space_width  = Default room width (m). Optional.
//    $space_height = Default room height (m). Optional.
//    $space_wall   = Default wall thickness (m). Optional.
// Example:
//    $space_length = 3;
//    $space_width  = 2;
//    $space_height = 2.5;
//    $space_wall   = 200;
//    bounds = roomBound();
//    echo(bounds); // Outputs: [3.2, 2.2, 2.5]
// See Also: space(), spaceWrapper()
function roomBound(length=$space_length, width=$space_width, height=$space_height, wall=$space_wall) =
	assert(is_num(length), 	"[roomBound] length must be a number (m)")
    assert(is_num(width), 	"[roomBound] width must be a number (m)")
    assert(is_num(height), 	"[roomBound] height must be a number (m)")
    assert(is_num(wall), 	"[roomBound] wall must be a number (m)")
    [length + wall/1000, width + wall/1000, height];
	

// Module: graduatedWall()
// 
// Synopsis: Creates a wall with alternating colored segments.
// Topics: Architecture, Geometry, Visualization
// Description:
//    Constructs a wall of specified length, height, and thickness, divided into segments of
//    a given mark height. Segments alternate between two colors (default: Black and White).
//    If the remaining height after full segments is non-zero, a final segment is added with
//    the remaining height, continuing the color alternation. All dimensions are in millimeters.
// Arguments:
//    h         = Height of the wall (m).
//    l         = Length of the wall (m).
//    mark      = Height of each segment (mm) [default: 170].
//    thickness = Thickness of the wall (mm) [default: 200].
// Example(3D,ColorScheme=Nature):
//    graduatedWall(h=1, l=0.8, mark=200, thickness=100);
module graduatedWall(h, l, mark =170, thickness = 200) {
    _h = assert(is_num(h) && h > 0, 			"[graduatedWall] h must be a positive number (mm)") meters(h);
    _l = assert(is_num(l) && l > 0, 			"[graduatedWall] l must be a positive number (mm)") meters(l);
    assert(is_num(mark) && mark > 0, 			"[graduatedWall] mark must be a positive number (mm)");
    assert(is_num(thickness) && thickness > 0, 	"[graduatedWall] thickness must be a positive number (mm)");
	count = floor(_h / mark);
	remain = _h- mark * count;
	for ( i = [0 : count-1] ) {
		color = (i % 2) == 1 ? "White" : "Black";
		up(i * mark)
			cuboid([_l,thickness,mark],anchor=BOT,$color = color );
	}	
	if (remain > 0 ) {
		color = (count % 2) == 1 ? "White" : "Black";
		up(count*mark)
			cuboid([_l,thickness,remain],anchor=BOT,$color = color );
	}
}
