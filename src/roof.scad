include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: roof.scad
// Includes:
//   include <roof.scad>
// FileGroup: Superstructure
// FileSummary: Architecture, Roofs
//////////////////////////////////////////////////////////////////////
include <_materials/wood.scad>
include <BOSL2/rounding.scad>
use <_core/3D.scad>
use <_core/distribute.scad>
use <_core/debug.scad>

// Module: gableRoof()
//
// Synopsis: Creates a gabled roof structure with adjustable pitch and dimensions.
// Topics: Architecture, Geometry, Roofing
// Usage:
//   gableRoof(pitch,axis,l,w,h,wall,thickness);
// Description:
//   Generates a gabled roof by forming a triangular prism atop a base structure.
//   The module uses global variables ($space_length, $space_width, $space_height, $space_wall)
//   for defaults, supporting flexible architectural prototyping. The gable can be oriented
//   along the X or Y axis with a specified pitch angle.
// Arguments:
//   pitch      = Roof pitch angle in degrees [default: 30].
//   axis       = Gable orientation axis (RIGHT for X, BACK for Y) [default: RIGHT].
//   l          = Length of the roof base [default: $space_length].
//   w          = Width of the roof base [default: $space_width].
//   h          = Height of the base structure [default: $space_height].
//   wall       = Wall thickness [default: $space_wall].
//   debug      = Enable debug mode for visualization [default: false].
// Example(3D,ColorScheme=Tomorrow): Gable along Y-axis
//   include <space.scad>
//   space(10,8,5,debug=true) 
//      gableRoof(pitch=30, axis=RIGHT, debug=true);
// Example(3D,ColorScheme=Tomorrow): Gable along X-axis
//   include <space.scad>
//   space(2,2,1.7,except=[LEFT,RIGHT],debug=true)    
//      gableRoof(pitch=25,axis=BACK, closed = false); 
// Example(3D,ColorScheme=Tomorrow): Gable roof closed
//   include <space.scad>
//   space(2,2,1.7,except=[LEFT,RIGHT],debug=true)    
//      gableRoof( axis=BACK, pitch=25, closed = true); 
module gableRoof(
    pitch   ,
    axis    = RIGHT,
    l       = is_undef($space_length) ? undef : $space_length,
    w       = is_undef($space_width)  ? undef : $space_width,
    h       = is_undef($space_height) ? undef : $space_height,
    wall    = is_undef($space_wall)   ? undef : $space_wall,
	thickness,
	material= "Brick",
    debug   = false,
	closed  = true,
	anchor  ,
	spin ,
	orient,	
	info,
	// IFC parameters
    ifc_guid
) {
	assert( is_meters (l) 			, "[gableRoof] Length (l) undefined. Provide value or set $space_length.");
	assert( is_meters (w) 			, "[gableRoof] Width (w) undefined. Provide value or set $space_width.");
	assert( is_meters (h) 			, "[gableRoof] Height (h) undefined. Provide value or set $space_height.");
	assert( is_num_positive (wall) 	, "[gableRoof] Wall thickness (wall) undefined. Provide value or set $space_wall.");
	assert( is_between(pitch, 0, 90), "[gableRoof] Pitch angle must be between 0 and 90 degrees.");
    // Constants and calculated dimensions
	thickness = is_def(thickness) ? thickness : is_def($space_wall) ? ang_hyp_to_opp(pitch,$space_wall) : 100;
	
    base_l      = meters(l) + 2 * wall;
    base_w      = meters(w) + 2 * wall;
    base_h      = meters(h);
    gable_h     = axis == RIGHT ? adj_ang_to_opp(base_w, pitch) : adj_ang_to_opp(base_l, pitch) ;
    roof_l      = axis == RIGHT ? base_l : adj_ang_to_hyp(base_l, pitch);
    roof_w      = axis == RIGHT ? adj_ang_to_hyp(base_w, pitch) : base_w;

    // Define bounding box for attachment
	attachable(size=[roof_l, roof_w, 2], anchor=anchor, spin=spin, orient=orient, cp=[0,0,0]) {	
		union() {
			up(base_h/2)
				material(material)
					gableShape(
						length=base_l, 
						width=base_w, 
						pitch=pitch, 
						thickness=thickness,
						closed = closed,
						anchor=BOT,
						spin = axis[Y] * 90
					);
		}
		children();
	}
	if (provideMeta(info)) {
		_ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
		$meta = [
            ["ifc_class",   "IfcRoof"   ],
            ["ifc_type",    "ROOF"    ],
            ["ifc_guid",    _ifc_guid   ],				
			["ifc_properties",   
				["IfcRoofType","GABLE_ROOF" ]
			],				
		];	
		info();
	}
}

// Module: roofCut()
//
// Synopsis: Creates a slanted roof cutout with configurable rotation and dimensions.
// Topics: Architecture, Geometry, Modification
// Usage:
//   roofCut(angle,rot_axis,rot_anchor,axis,[height_cut]);
// Description:
//   Generates a roof cutout by applying a wedge-shaped subtraction along a specified axis.
//   The module supports rotation around X or Y axes, with adjustable angles and anchor points.
//   It uses global variables ($space_length, $space_width, $space_wall, $space_height) as defaults,
//   ensuring flexibility in architectural designs.
// Arguments:
//   angle      = Roof slant angle in degrees [default: 0].
//   rot_axis   = Axis of rotation (e.g., RIGHT for X, UP for Y) [default: RIGHT].
//   rot_anchor = Anchor point for rotation (-1, 0, 1 for left/center/right) [default: CENTER].
//   axis       = Unused parameter (reserved for future expansion).
//   height_cut = Vertical height to subtract from $space_height [default: 0].
//   l          = Length of the roof base [default: $space_length].
//   w          = Width of the roof base [default: $space_width].
//   wall       = Wall thickness [default: $space_wall].
// Example(3D,ColorScheme=Tomorrow):
//   include <space.scad>
//   space(l=2,w=2,h=3,debug=true) 
//       roofCut(angle=45, rot_axis=RIGHT) cuboid([10, 8, 5], chamfer=0.5);
// Example(3D,ColorScheme=Tomorrow):
//   include <space.scad>
//   space(l=2,w=2,h=3,debug=true) roofCut( angle = 20, rot_axis = FWD,rot_anchor = RIGHT ) simpleRoof();
// Example(3D,ColorScheme=Tomorrow): Axis FWD and Anchor LEFT
//   include <space.scad>
//   space(l=2,w=2,h=3,debug=true) {
//      roofCut( angle = 20, rot_axis = FWD,rot_anchor = LEFT ) simpleRoof();
//   };
// Example(3D,ColorScheme=Tomorrow): Axis LEFT and Anchor BACK
//   include <space.scad>
//   space(l=2,w=2,h=3,debug=true) {
//      roofCut( angle = 20, rot_axis = LEFT,rot_anchor = BACK ) simpleRoof();
//   };
module roofCut( 
		angle	  	= 0,
		rot_axis	= RIGHT,
		rot_anchor 	= CENTER, 
		axis	  , 
		height_cut  =0 ,     	
		l 		  	= is_undef( $space_length ) ? undef : $space_length, 
		w 		  	= is_undef( $space_width  ) ? undef : $space_width,  
		wall 		= is_undef( $space_wall   ) ? undef : $space_wall,
		debug		= false
	){
	assert(is_meters(l),				"[roofCut] [l] is undefined. Provide length or define variable $space_length");
	assert(is_meters(w),				"[roofCut] [w] is undefined. Provide length or define variable $space_width");
	assert(is_num( wall ),				"[roofCut] [wall] parameter is undefined. Provide thickness or variable $space_wall");
	assert(is_meters($space_height),	"[roofCut] $space_height parameter is undefined.");
	
	_l = meters(l) + 2 * (wall ) ;
	_w = meters(w) + 2 * (wall ) ;
	_h = $space_height - height_cut;

	union() {
		if (rot_axis[X] != 0 ) { // Rotation on X
			$roof_length 	= _l/1000;
			$roof_width 	= adj_ang_to_hyp(w+2*wall/1000,angle);
			z_delta 		= adj_ang_to_opp(_w,angle);
			bounding 		= [meters($roof_length),_w,2];	
			up(meters($space_height/2)-z_delta/2) xrot(-angle * rot_anchor[Y])
			attachable( size = bounding )  {
				tag("keep")	ghost() cuboid(bounding); 
				children();
			}
			tag("roofCut") up(meters(_h/2) -z_delta/2 + 5 )
				wedge([	_l++2*CLEARANCE, _w+2*CLEARANCE, z_delta ], 
					center=true,
					spin= 90 + rot_anchor[Y] * 90,
					orient=DOWN,
				);				
			
		} else if (rot_axis[Y] != 0 ) { // Rotation on Y
			$roof_length 	= adj_ang_to_hyp(l+2*wall/1000,angle);
			$roof_width 	= _w/1000;
			z_delta 		= adj_ang_to_opp(_l,angle);
			bounding 		= [meters($roof_length),_w,2];	
			up(meters($space_height/2)-z_delta/2) yrot(-angle * rot_anchor[X])
			attachable( size = bounding )  {
				tag("keep")	ghost() cuboid(bounding); 
				children();
			}	
			tag("roofCut") up(meters(_h)-z_delta/2 + 5 )
				wedge([_w+2*CLEARANCE, _l++2*CLEARANCE, z_delta ], 
					center=true,
					spin=90 * rot_anchor[X],
					orient=DOWN,
				);
		}
	}
}

// Module: hippedRoof()
//
// Synopsis: Creates a hipped roof structure with adjustable dimensions and pitch.
// Topics: Architecture, Geometry, Roofing
// Usage:
//   hippedRoof(pitch, l, w, h, wall, extension, debug, anchor, spin, orient);
// Description:
//   Generates a hipped roof with four sloping faces, formed as a prismoid. Supports global variables
//   ($space_length, $space_width, $space_height, $space_wall) for defaults. Named anchors allow
//   attachment to slopes (front-slope, back-slope, left-slope, right-slope) and standard positions
//   (CENTER, TOP, BOTTOM, etc.). Stores metadata in $meta for BIM integration, mapping to IfcRoof
//   with PredefinedType=HIP_ROOF.
// Arguments:
//   pitch 		= Roof pitch angle in degrees (default: 30).
//   l 			= Length of the roof base in meters (default: $space_length).
//   w 			= Width of the roof base in meters (default: $space_width).
//   h 			= Height of the base structure in meters (default: $space_height).
//   wall 		= Wall thickness in mm (default: $space_wall).
//   extension 	= Overhang extension in mm (default: 0).
//   debug 		= Enable debug mode for wireframe visualization (default: false).
//   anchor 	= Anchor point for attachment (default: BOTTOM).
//   spin 		= Spin angle for orientation in degrees (default: 0).
//   orient 	= Orientation direction (default: UP).
// Side Effects:
//   $roof_type = Set to "hipped".
//   $roof_pitch = Set to pitch value.
//   $roof_edges = Stores ridge and hip edges for external use.
// Example(3D,ColorScheme=Tomorrow):
//   include <space.scad>	
//   space(3,2,2.4,200,debug=true) 
//      attach(TOP) highlight()
//         hippedRoof(pitch=30, debug=true);
// Example(3D,ColorScheme=Tomorrow): Attach to a named anchor
//   include <space.scad>	
//   space(3,2,2.4,200,debug=true) 
//      attach(TOP) highlight_this()
//         hippedRoof(pitch=30, debug=true)
//               attach("front-slope")
//                   cuboid([500,500,800],anchor=BOT);
module hippedRoof(
    pitch,
    l       	= is_undef($space_length) ? undef : $space_length,
    w       	= is_undef($space_width)  ? undef : $space_width,
    h       	= is_undef($space_height) ? undef : $space_height,
    wall    	= is_undef($space_wall)   ? undef : $space_wall,
    debug   	= false,
	extension 	= 0,
    spin    	= 0,
) {
	assert( is_between(pitch, 0, 90), "[hippedRoof] Pitch angle must be between 0 and 90 degrees");
	assert( is_meters(l) 			, "[hippedRoof] Length (l) undefined. Provide value or set $space_length");
	assert( is_meters(w) 			, "[hippedRoof] Width (w) undefined. Provide value or set $space_width");
	assert( is_meters(h)			, "[hippedRoof] Height (h) undefined. Provide value or set $space_height");
	assert( is_num_positive(wall)	, "[hippedRoof] Wall thickness (wall) undefined. Provide value or set $space_wall");

	$roof_type 	= "hipped";
	$roof_pitch	= pitch;
	
	zExtension = extension > 0 ?  adj_ang_to_opp( extension , pitch) : 0 ;
	
	base = [ 
		meters(l) + 2 * wall + 2*extension, 
		meters(w) + 2 * wall + 2*extension
	];
    _h      = adj_ang_to_opp(min(base.x, base.y) / 2, pitch);  // Height based on pitch
	ridge = [
		base.x - 2 * opp_ang_to_adj(_h, pitch) , // ridge_l
		base.y - 2 * opp_ang_to_adj(_h, pitch)	// ridge_w
	];
	// 2d Geometry
	front_h = sqrt(((base.y - ridge.y) / 2)^2 + _h^2) ;
	side_h  = sqrt(((base.x - ridge.x) / 2)^2 + _h^2);
	
	front_geom= centerPath( trapezoid( h=front_h,	w1=base.x, 	w2=ridge.x) );
	side_geom = centerPath( trapezoid( h=side_h, 	w1=base.y, 	w2=ridge.y) );

    anchors = [
        named_anchor("front-slope", [0, -(base.y + ridge.y) / 4, _h / 2]	,xrot(+pitch,UP), 0 , 	info=["geom",front_geom,		"edges",extractEdges(front_geom)	]),
        named_anchor("back-slope",  [0, +(base.y + ridge.y) / 4, _h / 2]	,xrot(-pitch,UP), 0 , 	info=["geom",yflip(front_geom),	"edges",extractEdges(front_geom)	]),
        named_anchor("left-slope",	[-(base.x + ridge.x) / 4, 0, _h / 2]	,yrot(-pitch,UP), -90, 	info=["geom",side_geom,			"edges",extractEdges(side_geom)		]),
		named_anchor("right-slope", [+(base.x + ridge.x) / 4, 0, _h / 2]	,yrot(+pitch,UP), +90 ,	info=["geom",side_geom,			"edges",extractEdges(side_geom)		]),
    ];
	
	// Edges
	$roof_edges = [
		"ridge", 
			flatten(
				[
				 if (ridge.x > 0) [[ridge.x/2,0,_h],[-ridge.x/2,0,_h]],
				 if (ridge.y > 0) [[0,ridge.y/2,_h],[0,-ridge.y/2,_h]]			 
				]
			),
		"hips",
			[
				[ [ -base.x /2 ,-base.y/2, 0 ], [ -ridge.x/2 , -ridge.y/2, _h  ] ], // Left front Hips
				[ [ +base.x /2 ,-base.y/2, 0 ], [ +ridge.x/2 , -ridge.y/2, _h  ] ], // Right front Hips
				[ [ -base.x /2 ,+base.y/2, 0 ], [ -ridge.x/2 , +ridge.y/2, _h  ] ], // Left Back Hips
				[ [ +base.x /2 ,+base.y/2, 0 ], [ +ridge.x/2 , +ridge.y/2, _h  ] ], // Right Back Hips
			]
	];
	down(zExtension)
    attachable(size=[base.x, base.y, _h], anchor=BOT, spin=spin, anchors=anchors, cp=[0, 0, _h/2]) {
        union() {
			if (debug)// Position the roof at the top of the base structure
            up(h) prismoid(size1=[base.x, base.y],size2=[ridge.x, ridge.y],h=_h);
        }
        children();
    }
}

// Module: ridgeBeam()
//
// Synopsis: Places a rafter along the ridge line of a roof structure.
// Topics: Architecture, Geometry, Structures
// See Also: rafter(), hipsBeam(), roofFrame()
// Description:
//   Generates a ridge beam by placing a rafter along a 3D line segment defined
//   in the $roof_edges structure under the "ridge" key. The rafter is aligned
//   using alignWith, with its length set to $align_length, cross-section defined
//   by section, and material properties applied via material(). The module is
//   designed for roof designs, complementing modules like hipsBeam and roofFrame.
//   If $roof_edges is undefined or lacks a ridge, no geometry is generated.
// Arguments:
//   section = 2D vector [x, y] for rafter cross-section width (Y) and height (Z) [default: [3*INCH, 4*INCH]].
//   material = Material name for properties (e.g., "Wood2") [default: "Wood2"].
/*
// Example(3D,ColorScheme=Tomorrow):
//   $roof_edges = struct_set([], ["ridge", [[-100, 0, 50], [100, 0, 50]]]);
//   ridgeBeam(section=[50, 100], material="Oak");
// Example(3D,ColorScheme=Tomorrow):
//   $roof_edges = struct_set([], ["ridge", [[0, -50, 60], [0, 50, 60]]]);
//   ridgeBeam();
// Example(3D,ColorScheme=Tomorrow):
//   $roof_edges = struct_set([], ["ridge", undef]);
//   ridgeBeam(section=[75, 150], material="Pine");
*/
module ridgeBeam(section = [ 3*INCH, 4*INCH ],material="Wood2"){
	struct 	= struct_set([], $roof_edges);
	ridge 	= struct_val(struct,"ridge");
	if (ridge) 
		material(material) 
			alignWith(ridge) 
				rafter( section,length = $align_length );
}

// Module: hipsBeam()
//
// Synopsis: Places rafters along hip edges of a roof structure.
// Topics: Architecture, Geometry, Structures
// See Also: rafter(), roofFrame()
// Description:
//   Generates hip beams by placing rafters along 3D line segments (hips) defined
//   in the $roof_edges structure under the "hips" key. Each rafter is aligned
//   using alignWith, with its length set to $align_length, cross-section defined
//   by section, and material properties applied via material(). The module is
//   designed for roof designs, complementing modules like roofFrame for complete
//   structural assemblies. If $roof_edges is undefined or lacks hips, no geometry
//   is generated.
// Arguments:
//   section = 2D vector [x, y] for rafter cross-section width (Y) and height (Z) [default: [3*INCH, 4*INCH]].
//   material = Material name for properties (e.g., "Wood2") [default: "Wood2"].

/*
// Example(3D,ColorScheme=Tomorrow):
//   $roof_edges = struct_set([], ["hips", [[[0,0,0], [100,100,50]], [[100,0,0], [0,100,50]]]]);
//   hipsBeam(section=[50, 100], material="Oak");
// Example(3D,ColorScheme=Tomorrow):
//   $roof_edges = struct_set([], ["hips", [[[0,0,0], [200,200,100]]]]);
//   hipsBeam();
// Example(3D,ColorScheme=Tomorrow):
//   $roof_edges = struct_set([], ["hips", []]);
//   hipsBeam(section=[75, 150], material="Pine");
*/
module hipsBeam(section = [ 3*INCH, 4*INCH ],material="Wood2"){
	struct 	= struct_set([], $roof_edges);
	hips 	= struct_val(struct,"hips");
	for (hip = hips) 
		material(material)	
			alignWith(hip) 
				rafter( section,length = $align_length );
}

// Module: roofFrame()
//
// Synopsis: Generates a roof frame with rafters along a 2D mask.
// Topics: Architecture, Geometry, Structures
// See Also: rafter()
// Description:
//   Creates a roof frame by placing rafters along line segments that intersect
//   a 2D mask polygon, defined by anchorInfo("geom"). Rafters are spaced at
//   regular intervals (spacing) in the specified direction (VERTICAL or
//   HORIZONTAL). Each rafter uses the given section dimensions and material
//   properties (e.g., Pine). If info is true, computes metadata including total
//   length, volume, weight, and cost, stored in $meta. If debug is true,
//   visualizes the 2D mask polygon instead of the frame. The module supports
//   architectural designs with customizable rafter placement and cost estimation.
// Arguments:
//   rafter_section	= 2D vector [x, y] for rafter cross-section width (Y) and height (Z) [default: [2*INCH, 4*INCH]].
//   spacing 		= Distance between rafter centerlines [default: 400].
//   material 		= Material name (e.g., "Pine") for density and properties [default: "Pine"].
//   debug 			= If true, shows 2D mask polygon instead of frame [default: false].
//   dir 			= Direction of rafter alignment: VERTICAL or HORIZONTAL [default: VERTICAL].
//   info 			= If true, computes and stores metadata in $meta [default: true].
//   unit_price 	= Cost per linear meter of rafter [default: 100].
// Example(3D,Huge,ColorScheme=Tomorrow):
//   include <space.scad>
//   space(2,3,2,200,debug=true) 
//      attach(TOP)
//         hippedRoof(pitch=30, extension=400, debug=false) {
//              attach("front-slope")	roofFrame(); 
//              attach("back-slope"	) 	roofFrame();
//              attach("left-slope"	) 	roofFrame();
//              attach("right-slope") 	roofFrame();				
//              ridgeBeam();	
//              hipsBeam();
//         }
module roofFrame(rafter_section = [ 2*INCH, 4*INCH ], spacing = 400 ,material="Pine",debug = false, 
		dir = VERTICAL,
		info = true,
		unit_price = 100,
		// IFC parameters
        ifc_guid		
)  {
	mask = anchorInfo("geom");
	if (debug) polygon(mask);
	segments = segmentsCrossing( mask = mask, spacing = spacing,dir = dir);	
	for ( line = segments )
		material( material )
			alignWith( path3d(line) ) 
				rafter( section = rafter_section,length = $align_length );
	if (provideMeta(info)) {
		cumulative_length = sum([for (seg = segments) lineLength(seg) ]) / 1000;  	
		density = woodSpecs(material,MATERIAL_DENSITY);
		
		volume  = mm3_to_m3( rafter_section.x * rafter_section.y * cumulative_length*1000); 
		_ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
		$meta = [
			["name"		, str("Roof frame '",$anchor ? $anchor : "" ,"' (",dir == VERTICAL ? "Vertical" : "Horizontal",")"  )],
			["section"	, rafter_section ],
			["linear_meters",cumulative_length],
			["unit_price", unit_price ],
			["volume", volume ],
			["weight"	, volume * density ],
			["value"	, unit_price * cumulative_length ],
            ["ifc_class",   "IfcRoofFrame"   ],
            ["ifc_type",    "ROOF-FRAME"    ],
            ["ifc_guid",    _ifc_guid   ],				
		];	
		info();
	}				
}

// Module: rafter()
//
// Synopsis: Creates a 3D rafter with optional pitched ends.
// Topics: Architecture, Geometry, Extrusion
// See Also: hipsBeam(), ridgeBeam()
// Description:
//   Generates a rafter by extruding a 2D trapezoidal or rectangular profile
//   along the Y-axis. The profile’s length (X-axis) is defined by length,
//   with optional pitches (angles in degrees) at both ends to create sloped
//   edges. The cross-section’s width (Y) and height (Z) are set by section.x
//   and section.y. Supports anchoring, rotation, and corner rounding for
//   smooth edges. The debug parameter visualizes the 2D profile for inspection.
//   The rafter is centered by default, with BOT anchor aligning the bottom face.
// Arguments:
//   section 	= 2D vector or struct [x, y] for cross-section width (Y) and height (Z).
//   length 	= Length of the rafter along X-axis.
//   pitch1 	= Pitch angle (degrees) at left end (X=-length/2) [default: 0].
//   pitch2 	= Pitch angle (degrees) at right end (X=length/2) [default: 0].
//   anchor 	= Anchor point for positioning [default: BOT].
//   spin 		= Rotation angle (degrees) around Z-axis [default: 0].
//   rounding 	= Corner radius for smoothing edges [default: 0].
//   debug 		= If true, shows 2D profile instead of 3D extrusion [default: false].
// Example(3D,ColorScheme=Tomorrow):
//   rafter(section=[2, 4], length=10, pitch1=30, pitch2=30, rounding=0.5);
// Example(3D,ColorScheme=Tomorrow):
//   rafter(section=[2, 4], length=8, anchor=CENTER, debug=true);
// Example(3D,ColorScheme=Tomorrow):
//   rafter(section=[3, 5], length=12, pitch1=-45, spin=45);
module rafter(section,length,pitch1 = 0,pitch2 = 0,anchor = BOT,material = "Wood",spin,rounding = 0,debug = false) {
	bounding = [ length ,section.x, section.y ];
	x 	= bounding.x/2;
	y 	= section.y/2;
	x1 	= pitch1 > 0 ? sign( pitch1 ) * adj_ang_to_opp(y,abs( pitch1 )) : 0;
	x2 	= pitch2 > 0 ? sign( pitch2 ) * adj_ang_to_opp(y,abs( pitch2 )) : 0;
	path = [
		[ -x-x1*2, -y ],
		[ -x+x1*0, +y ],
		[ +x+x2*2, +y ],
		[ +x-x2*0, -y ],
	];		
	attachable( size = bounding, anchor=anchor, spin=spin ) {
		union() {
			material(material) 
				extrude(section.x,dir=FWD,center=true) polygon(round_corners(path,radius=rounding));
		}
		children();
	}		
}

// Module : simpleRoof()
//
// Synopsis: Creates a simple roof cover for test purpose
module simpleRoof(
	l 		  	= is_undef( $roof_length ) ? undef : $roof_length, 
	w 		  	= is_undef( $roof_width  ) ? undef : $roof_width,  
	thickness   = 10
) {
	if (is_def(l)) {
		tag("keep") cuboid([ meters(l),  meters(w), thickness ],anchor=BOT);
	} 
}

function extractEdges( geom ) = 
	let ( count = len(geom))
	[
		["fascia"		,[geom[0],geom[1]]],
		["left-hip"		,[geom[1],geom[2]]],
		["right-hip"	,[geom[count-1],geom[0]]],
		if (count > 3) 
		["ridge"		,[geom[2],geom[3]]],
	];