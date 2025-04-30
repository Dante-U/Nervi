include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <_common.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: metal.scad
// Includes:
//   include <_materials/metal.scad>
// FileGroup: Materials
// FileSummary: Architecture, Metal
//////////////////////////////////////////////////////////////////////

metal_sections = struct_set([], [
	"pipe",        	 [ "Pipe",			function() pipeProfile()	],
	"square",        [ "Square Tube",	function() hssProfile()		],
	"corner",        [ "Corner",		function() cornerProfile()	],
	"channel",       [ "Channel",		function() channelProfile()	],
	"ibeam",       	 [ "IBeam",			function() iBeamProfile()	],
	"tbeam",       	 [ "TBeam",			function() tBeamProfile()	],
	"rail",       	 [ "Rail",			function() railProfile()	],
]);

/*
function metalSection( section_name ) =
	let (
		spec = struct_val(metal_sections, section_name),
	)
	spec;
*/	

function metalSectionPath( section_name ) =
	assert(is_def(section_name), "[metalSectionPath] Missing section_name argument")
	let (
		spec = struct_val(metal_sections, section_name),
		
	)
	assert(is_def(spec), str("[metalSectionPath] Unknown metal profile type: ", section_name))
	spec[1];	
	



// Function: hssProfile()
//
// Synopsis: Generates a 2D path for a hollow structural section (HSS) profile.
// Topics: Materials, Structural, Metal Profiles
// Usage:
//   path = hssProfile(width, height, thickness,rounding, anchor);
// Description:
//   Creates a closed 2D path for a rectangular or square hollow structural section (HSS).
//   The anchor point defines the path’s origin (e.g., center, corner).
// Arguments:
//   width = Section width in mm (default: 100).
//   height = Section height in mm (default: 100).
//   thickness = Wall thickness in mm (default: 5).
//   rounding = Fillet radius for corners in mm (default: 0).
//   anchor = Anchor point for the path origin (default: CENTER).
// Returns:
//   Closed list of 2D points forming the HSS’s cross-section.
// Example(2D):
function hssProfile(
	width		= first_defined([is_undef(width) 	? undef : width ,		is_undef($profile_width) 	? 0 : $profile_width] ), 
	height		= first_defined([is_undef(height) 	? undef : height ,		is_undef($profile_height) 	? 0 : $profile_height]), 
	thickness	= first_defined([is_undef(thickness)? undef : thickness ,	is_undef($profile_thickness)? 0 : $profile_thickness]), 
	rounding	= first_defined([is_undef(rounding) ? undef : rounding ,	is_undef($profile_rounding) ? 0 : $profile_rounding]),  
	anchor		= CENTER
) =
    assert(is_num(width) && width > 2*thickness, 	str("[hssProfile] width must be greater than 2*thickness. width =  "	,width	))
    assert(is_num(height) && height > 2*thickness, 	str("[hssProfile] height must be greater than 2*thickness. height = "	,height	))
    assert(is_num(thickness) && thickness > 0, 		str("[hssProfile] thickness must be positive"))
    assert(is_num(rounding) && rounding >= 0 && rounding <= thickness/2, 
													str("[hssProfile] rounding must be non-negative and <= thickness/2. value =",rounding))	
    let (
        w = width, h = height, t = thickness,
		outer = rect([width,height],rounding=rounding),
		inner = rect([width-2*t,height-2*t],rounding=rounding),
		path = make_region([outer,inner]),
        offset = -resolveAnchor(anchor, [w, h])
    )
    move(offset, path);	



	
// Function: pipeProfile()
//
// Synopsis: Generates a 2D path for a circular pipe profile.
// Topics: Materials, Structural, Metal Profiles
// Usage:
//   path = pipeProfile(diameter, thickness,rounding, anchor);
// Description:
//   Creates a closed 2D path for a hollow circular pipe, defined by outer diameter and
//   wall thickness. The anchor point defines the path’s origin (e.g., center, edge).
// Arguments:
//   diameter 		= Outer diameter in mm.
//   thickness 		= Wall thickness in mm.
//   anchor 		= Anchor point for the path origin (default: CENTER).
// Returns:
//   Closed list of 2D points forming the pipe’s cross-section.
// Example(3D,Big,ColorScheme=Nature):
//   region(pipeProfile(diameter=50, thickness=5, anchor=CENTER));	
function pipeProfile( 
	diameter	= first_defined([is_undef(diameter) ? undef : diameter  ,	is_undef($profile_diameter)	? 0 : $profile_diameter] ), 
	thickness	= first_defined([is_undef(thickness)? undef : thickness ,	is_undef($profile_thickness)? 0 : $profile_thickness]), 
	anchor=CENTER 
) =
	
    assert(is_num(diameter) && diameter > 0, 								"[pipeProfile] diameter must be positive")
    assert(is_num(thickness) && thickness > 0 && thickness <= diameter/2, 	"[pipeProfile] thickness must be positive and <= diam/2")
    let (
        r_outer = diameter / 2,
        r_inner = r_outer - thickness,
        outer = circle(r=r_outer, $fn=64),
        inner = reverse(circle(r=r_inner, $fn=64)),
        path2 = concat(outer, inner, [outer[0]]), // Close path
		path = difference(outer,inner),
        offset = -resolveAnchor(anchor, [diameter, diameter])
    )
    move(offset, path);
	



// Function: cornerProfile()
//
// Synopsis: Generates a 2D path for an L-shaped corner (angle) profile with optional rounding.
// Topics: Materials, Structural, Metal Profiles
// Usage:
//   path = cornerProfile(leg1, leg2, thickness, rounding, anchor);
// Description:
//   Creates a closed 2D path for an L-shaped corner profile with two legs, uniform thickness,
//   and optional corner rounding. The anchor point defines the path’s origin (e.g., inner corner).
// Arguments:
//   leg1 = Length of first leg in mm (default: 50).
//   leg2 = Length of second leg in mm (default: 50).
//   thickness = Profile thickness in mm (default: 5).
//   rounding = Fillet radius for corners in mm (default: 0).
//   anchor = Anchor point for the path origin (default: [0, 0]).
// Returns:
//   Closed list of 2D points forming the corner’s cross-section.
// Example(2D):
//   region(cornerProfile(width = 100,height=100,thickness=10,rounding=3));  
function cornerProfile(
		width		= first_defined([is_undef(width) 	? undef : width ,		is_undef($profile_width) 	? 0 : $profile_width] 		), 
		height		= first_defined([is_undef(height) 	? undef : height ,		is_undef($profile_height) 	? 0 : $profile_height]		), 
		thickness	= first_defined([is_undef(thickness)? undef : thickness ,	is_undef($profile_thickness)? 0 : $profile_thickness]	),
		/*
		leg1=50, 
		leg2=50, 
		thickness=5, 
		*/
		rounding	= first_defined([is_undef(rounding) ? undef : rounding ,	is_undef($profile_rounding) ? 0 : $profile_rounding]),  
		//anchor = [0,0]
		anchor = CENTER
	) =
	let (
		leg1 = width,
		leg2 = height,
	)
	
    assert(is_num(leg1) && leg1 > thickness, 	str("[cornerProfile] leg1 must be greater than thickness. value = ",leg1))
    assert(is_num(leg2) && leg2 > thickness, 	str("[cornerProfile] leg2 must be greater than thickness. value = ",leg2))
    assert(is_num(thickness) && thickness > 0, 	str("[cornerProfile] thickness must be positive"))
    assert(is_num(rounding) && rounding >= 0 && rounding <= thickness/2, 
												str("[cornerProfile] rounding must be non-negative and <= thickness/2"))
    let (
        p = [ [0, 0], [leg1, 0], [leg1, thickness], [thickness, thickness], [thickness, leg2], [0, leg2] ],
		base_path = move([-width/2,-height/2],p),
        offset = -resolveAnchor(anchor, [leg1, leg2]),
		_path = rounding < 0 ? base_path : round_corners(base_path,cut=[0,0,rounding,rounding,rounding,0],method="circle"),
    )
    move(offset, _path);
	
// Function: channelProfile()
//
// Synopsis: Generates a 2D path for a C-shaped channel profile.
// Topics: Materials, Structural, Metal Profiles
// Usage:
//   path = channelProfile(width, height, thickness,rounding, anchor);
// Description:
//   Creates a closed 2D path for a C-shaped channel with specified width, height, and thickness.
//   The anchor point defines the path’s origin (e.g., center, web center).
// Arguments:
//   width 		= Channel width (flange length) in mm (default: 100).
//   height 	= Channel height (web height) in mm (default: 50).
//   thickness 	= Profile thickness in mm (default: 5).
//   rounding 	= Fillet radius for corners in mm (default: 0).
//   anchor 	= Anchor point for the path origin (default: CENTER).
// Returns:
//   Closed list of 2D points forming the channel’s cross-section.
// Example(2D):
//   region(channelProfile( width = 50, height = 50, thickness= 6,rounding = 1));  	
function channelProfile(
	width		= first_defined([is_undef(width) 	? undef : width ,		is_undef($profile_width) 	? 0 : $profile_width] ), 
	height		= first_defined([is_undef(height) 	? undef : height ,		is_undef($profile_height) 	? 0 : $profile_height]), 
	thickness	= first_defined([is_undef(thickness)? undef : thickness ,	is_undef($profile_thickness)? 0 : $profile_thickness]), 
	rounding	= first_defined([is_undef(rounding) ? undef : rounding ,	is_undef($profile_rounding) ? 0 : $profile_rounding]),  
	anchor=CENTER
) =
    assert(is_num(width) && width > 2*thickness, 	"[channelProfile] width must be greater than 2*thickness")
    assert(is_num(height) && height > thickness, 	"[channelProfile] height must be greater than thickness")
    assert(is_num(thickness) && thickness > 0, 		"[channelProfile] thickness must be positive")
    assert(is_num(rounding) && rounding >= 0 && rounding <= thickness/2, 
													"[channelProfile] rounding must be non-negative and <= thickness/2")	
    let (
        w = width, h = height, t = thickness,
        p = [
            [0, 0], [w, 0], [w, t], [t, t], [t, h-t], [w, h-t],
            [w, h], [0, h], [0, h-t], [t-t, h-t], [t-t, t], [0, t]
        ],
		path = move([-width/2,-height/2],p),
		_r = rounding,
        offset = -resolveAnchor(anchor, [w, h]),
		_path = rounding < 0 ? path : round_corners(path,cut=[_r,0,0,_r,_r,0,0,_r,0,0,0,0],method="circle"),
    )
    move(offset, _path);

// Function: iBeamProfile()
//
// Synopsis: Generates a 2D path for an I-beam profile.
// Topics: Materials, Structural, Metal Profiles
// Usage:
//   path = iBeamProfile(width, height, web_thickness, flange_thickness,rounding, anchor);
// Description:
//   Creates a closed 2D path for an I-beam with specified flange width, web height, and thicknesses.
//   The anchor point defines the path’s origin (e.g., center, flange edge).
// Arguments:
//   width 				= Flange width in mm (default: 100).
//   height 			= Web height in mm (default: 150).
//   web_thickness 		= Web thickness in mm (default: 5).
//   flange_thickness 	= Flange thickness in mm (default: 8).
//   rounding = Fillet radius for corners in mm (default: 0).
//   anchor 			= Anchor point for the path origin (default: CENTER).
// Returns:
//   Closed list of 2D points forming the I-beam’s cross-section.
// Example(2D):
//   region(iBeamProfile(height=50,width=50,web_thickness =3,flange_thickness = 5 ,rounding=2));
function iBeamProfile(
	width		  = first_defined([is_undef(width) 			? undef : width ,		is_undef($profile_width) 	? 0 : $profile_width] ), 
	height		  = first_defined([is_undef(height) 		? undef : height ,		is_undef($profile_height) 	? 0 : $profile_height]), 
	web_thickness = first_defined([is_undef(web_thickness)	? undef : web_thickness,is_undef($profile_web_thickness)? 0 : $profile_web_thickness]), 
	flange_thickness = first_defined([is_undef(flange_thickness)	? undef : flange_thickness,is_undef($profile_flange_thickness)? 0 : $profile_flange_thickness]), 
	rounding	  = first_defined([is_undef(rounding) 		? undef : rounding ,	is_undef($profile_rounding) ? 0 : $profile_rounding]),  
	anchor=CENTER
) =
    assert(is_num(width) && width > web_thickness, 				"[iBeamProfile] width must be greater than web_thickness")
    assert(is_num(height) && height > 2*flange_thickness, 		"[iBeamProfile] height must be greater than 2*flange_thickness")
    assert(is_num(web_thickness) && web_thickness > 0, 			"[iBeamProfile] web_thickness must be positive")
    assert(is_num(flange_thickness) && flange_thickness > 0, 	"[iBeamProfile] flange_thickness must be positive")
    assert(is_num(rounding) && rounding >= 0 && rounding <= flange_thickness/2, 
																"[iBeamProfile] rounding must be non-negative and <= thickness/2")	
    let (
        w = width, h = height, tw = web_thickness, tf = flange_thickness,
        p = [
            [0, 0], [w, 0], [w, tf], [(w+tw)/2, tf], [(w+tw)/2, h-tf],
            [w, h-tf], [w, h], [0, h], [0, h-tf], [(w-tw)/2, h-tf],
            [(w-tw)/2, tf], [0, tf]
        ],
		path = move([-width/2,-height/2],p),
		_r = rounding,
        offset = -resolveAnchor(anchor, [w, h]),
		_path = rounding < 0 ? path : round_corners(path,cut=[0,0,0,_r,_r,0,0,0,0,_r,_r,0],method="circle"),
    )
    move(offset, _path);	
	
// Function: tBeamProfile()
//
// Synopsis: Generates a 2D path for a T-beam profile.
// Topics: Materials, Structural, Metal Profiles
// Usage:
//   path = tBeamProfile(width, height, flange_thickness, web_thickness,rounding, anchor);
// Description:
//   Creates a closed 2D path for a T-beam with specified flange width, web height, and thicknesses.
//   The anchor point defines the path’s origin (e.g., center, flange top).
// Arguments:
//   width 				= Flange width in mm (default: 100).
//   height 			= Web height in mm (default: 100).
//   flange_thickness 	= Flange thickness in mm (default: 8).
//   web_thickness 		= Web thickness in mm (default: 5).
//   rounding 			= Fillet radius for corners in mm (default: 0).
//   anchor 			= Anchor point for the path origin (default: CENTER).
// Returns:
//   Closed list of 2D points forming the T-beam’s cross-section.
// Example(2D):
//   region(tBeamProfile(height=50,width=50,web_thickness =4,flange_thickness = 5 ,rounding=2));
function tBeamProfile(
	width		  = first_defined([is_undef(width) 			? undef : width ,		is_undef($profile_width) 	? 0 : $profile_width] ), 
	height		  = first_defined([is_undef(height) 		? undef : height ,		is_undef($profile_height) 	? 0 : $profile_height]), 
	web_thickness = first_defined([is_undef(web_thickness)	? undef : web_thickness,is_undef($profile_web_thickness)? 0 : $profile_web_thickness]), 
	flange_thickness = first_defined([is_undef(flange_thickness)	? undef : flange_thickness,is_undef($profile_flange_thickness)? 0 : $profile_flange_thickness]), 
	rounding	  = first_defined([is_undef(rounding) 		? undef : rounding ,	is_undef($profile_rounding) ? 0 : $profile_rounding]), 
	//width=100, height=100, flange_thickness=8, web_thickness=5, rounding=0, 
	
	anchor=CENTER
) =
    assert(is_num(width) && width > web_thickness, 				"[tBeamProfile] width must be greater than web_thickness")
    assert(is_num(height) && height > flange_thickness, 		"[tBeamProfile] height must be greater than flange_thickness")
    assert(is_num(flange_thickness) && flange_thickness > 0, 	"[tBeamProfile] flange_thickness must be positive")
    assert(is_num(web_thickness) && web_thickness > 0, 			"[tBeamProfile] web_thickness must be positive")
    assert(is_num(rounding) && rounding >= 0 && rounding <= web_thickness/2, 
													"[tBeamProfile] rounding must be non-negative and <= thickness/2")	
	
    let (
        w = width, h = height, tf = flange_thickness, tw = web_thickness,
        p = [
            [0, 0], [w, 0], [w, tf], [(w+tw)/2, tf], [(w+tw)/2, h],
            [(w-tw)/2, h], [(w-tw)/2, tf], [0, tf]
        ],
		path = move([-width/2,-height/2],p),
		_r = rounding,
        offset = -resolveAnchor(anchor, [w, h]),
		_path = rounding < 0 ? path : round_corners(path,cut=[0,0,0,_r,0,0,_r,0],method="circle"),
    )
    move(offset, _path);


// Function: railProfile()
//
// Synopsis: Generates a 2D path for a rail profile (T-shaped with wider head).
// Topics: Materials, Structural, Metal Profiles
// Usage:
//   path = railProfile(width, height, thickness, head_width, head_height, foot_width, rounding, anchor);
// Description:
//   Creates a closed 2D path for a standard rail profile with a wider head, narrower web,
//   and a foot at the bottom. The anchor point defines the path's origin (e.g., center, base).
// Arguments:
//   width = Overall base width in mm (default: 80).
//   height = Total rail height in mm (default: 100).
//   thickness = Web thickness in mm (default: 10).
//   head_width = Width of the rail head in mm (default: 60).
//   head_height = Height of the rail head in mm (default: 20).
//   foot_width = Width of the rail foot in mm (default: 80).
//   rounding = Fillet radius for corners in mm (default: 0).
//   anchor = Anchor point for the path origin (default: CENTER).
// Returns:
//   Closed list of 2D points forming the rail's cross-section.
// Example(2D):
//   region(railProfile(width=80, height=100, thickness=10, head_width=40, head_height=20, foot_width=80, rounding=3, anchor=CENTER));
function railProfile(
	width = first_defined([is_undef(width) ? undef : width, is_undef($profile_width) ? 80 : $profile_width]),
	height = first_defined([is_undef(height) ? undef : height, is_undef($profile_height) ? 100 : $profile_height]),
	thickness = first_defined([is_undef(thickness) ? undef : thickness, is_undef($profile_thickness) ? 10 : $profile_thickness]),
	head_width = first_defined([is_undef(head_width) ? undef : head_width, is_undef($profile_head_width) ? 60 : $profile_head_width]),
	head_height = first_defined([is_undef(head_height) ? undef : head_height, is_undef($profile_head_height) ? 20 : $profile_head_height]),
	foot_width = first_defined([is_undef(foot_width) ? undef : foot_width, is_undef($profile_foot_width) ? 80 : $profile_foot_width]),
	rounding = first_defined([is_undef(rounding) ? undef : rounding, is_undef($profile_rounding) ? 0 : $profile_rounding]),
	anchor = CENTER
) =
    assert(is_num(width) && width > thickness, "[railProfile] width must be greater than thickness")
    assert(is_num(height) && height > thickness, "[railProfile] height must be greater than thickness")
    assert(is_num(thickness) && thickness > 0, "[railProfile] thickness must be positive")
    assert(is_num(head_width) && head_width >= thickness, "[railProfile] head_width must be greater than or equal to thickness")
    assert(is_num(head_height) && head_height > 0, "[railProfile] head_height must be positive")
    assert(is_num(foot_width) && foot_width >= thickness, "[railProfile] foot_width must be greater than or equal to thickness")
    assert(is_num(rounding) && rounding >= 0 && rounding <= thickness/2, 
                                 "[railProfile] rounding must be non-negative and <= thickness/2")	
    let (
        w = width,
        h = height,
        t = thickness,
        hw = head_width,
        hh = head_height,
        fw = foot_width,
        web_offset = t/2,
        
        // Create the rail profile path - starting from bottom left, going clockwise
        path = [
            // Foot
            [-(fw/2), 0],           // Bottom left corner
            [fw/2, 0],              // Bottom right corner
            [fw/2, hh],             // Top right of foot
            [web_offset, hh],       // Step in to web
            
            // Web
            [web_offset, h-hh],     // Up the web to below head
            [hw/2, h-hh],           // Step out to head width
            
            // Head
            [hw/2, h],              // Top right corner
            [-(hw/2), h],           // Top left corner
            [-(hw/2), h-hh],        // Down to left side of head
            [-web_offset, h-hh],    // Step in to web
            
            // Back down the web to foot
            [-web_offset, hh],      // Bottom of web left side
            [-(fw/2), hh]           // Back to starting edge of foot
        ],
        
        r = rounding,
        offset = -resolveAnchor(anchor, [w, h]),
        _path = r > 0 ? round_corners(path, cut=[0,0,r,r,r,r,r,r,r,r,r,r], method="circle") : path
    )
    move(offset, _path);	


	
// Function: resolveAnchor()
//
// Synopsis: Converts named or numeric anchors to 2D/3D vectors.
// Topics: Utilities, Anchoring
// Usage:
//   vec = resolveAnchor(anchor, size);
// Description:
//   Converts a named anchor (e.g., CENTER, LEFT) or numeric vector to a 2D/3D vector,
//   scaled by the profile size [width, height].
// Arguments:
//   anchor 	= Anchor point (vector or named anchor).
//   size 		= Profile size [width, height] in mm.
// Returns:
//   2D vector for the anchor position.
function resolveAnchor(anchor, size) =
	let (
		_anchor = len(size) == 2 ? point2d(anchor) : anchor
	)
	v_mul(_anchor,size)/2;	