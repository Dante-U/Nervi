include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: metal-structure.scad
// Includes:
//   include <wood-structure.scad>
// FileGroup: Superstructure
// FileSummary: Architecture, Building, Project, Metal
//////////////////////////////////////////////////////////////////////
include <BOSL2/rounding.scad>

profiles = [
	"pipe",
	"corner",
	"channel",
	"I-beam",
	"rail"
];

if (false) {
	stroke(cornerProfile());// Corner profile should have rounding
	//region (pipeProfile());	

	stroke(pipeProfile(),closed=true);// pipe is not closed 
	
	echo (channelProfile());
	
	//stroke(channelProfile());
	// channelProfile ERROR: Assertion '(is_vector(v) && ((len(v) == 3) || (len(v) == 2)))' failed: "Invalid value for `v`"
	iBeamProfile(); // ERROR: Assertion '(is_vector(v) && ((len(v) == 3) || (len(v) == 2)))' failed: "Invalid value for `v`" in file ../../../../../../usr/local/share/openscad/libraries/BOSL2/transforms.scad, line 15
	stroke(railProfile());	//ERROR: Assertion '(is_vector(v) && ((len(v) == 3) || (len(v) == 2)))' failed: "Invalid value for `v`" in file ../../../../../../usr/local/share/openscad/libraries/BOSL2/transforms.scad, line 152
	stroke(tBeamProfile()); // ERROR: Assertion '(is_vector(v) && ((len(v) == 3) || (len(v) == 2)))' failed: "Invalid value for `v`" in file ../../../../../../usr/local/share/openscad/libraries/BOSL2/transforms.scad, line 152
}

// Function: resolveAnchor()
// Synopsis: Converts named or numeric anchors to 2D vectors.
// Topics: Utilities, Anchoring
// Usage:
//   vec = resolveAnchor(anchor, size);
// Description:
//   Converts a named anchor (e.g., CENTER, LEFT) or numeric vector to a 2D vector,
//   scaled by the profile size [width, height].
// Arguments:
//   anchor = Anchor point (vector or named anchor).
//   size = Profile size [width, height] in mm.
// Returns:
//   2D vector for the anchor position.
function resolveAnchor(anchor, size) =
    let (
        a = is_vector(anchor) ? anchor :
            anchor == CENTER ? [0, 0] :
            anchor == LEFT ? [-size[0]/2, 0] :
            anchor == RIGHT ? [size[0]/2, 0] :
            anchor == TOP ? [0, size[1]/2] :
            anchor == BOTTOM ? [0, -size[1]/2] :
            [0, 0] // Default to origin
    )
    [a.x, a.y];
	
// Function: pipeProfile()
//
// Synopsis: Generates a 2D path for a circular pipe profile.
// Topics: Materials, Structural, Metal Profiles
// Usage:
//   path = pipeProfile(diam, wall,rounding, anchor);
// Description:
//   Creates a closed 2D path for a hollow circular pipe, defined by outer diameter and
//   wall thickness. The anchor point defines the path’s origin (e.g., center, edge).
// Arguments:
//   diam 		= Outer diameter in mm (default: 50).
//   wall 		= Wall thickness in mm (default: 5).
//   anchor 	= Anchor point for the path origin (default: CENTER).
// Returns:
//   Closed list of 2D points forming the pipe’s cross-section.
// Example(3D,Big,ColorScheme=Nature):
//   region(pipeProfile(diam=50, wall=5, anchor=CENTER));	
function pipeProfile(diam=50, wall=5, anchor=CENTER) =
    assert(is_num(diam) && diam > 0, 					"[pipeProfile] diam must be positive")
    assert(is_num(wall) && wall > 0 && wall <= diam/2, 	"[pipeProfile] wall must be positive and <= diam/2")
    let (
        r_outer = diam / 2,
        r_inner = r_outer - wall,
        outer = circle(r=r_outer, $fn=64),
        inner = reverse(circle(r=r_inner, $fn=64)),
        path2 = concat(outer, inner, [outer[0]]), // Close path
		path = difference(outer,inner),
        offset = -resolveAnchor(anchor, [diam, diam])
    )
    move(offset, path);
	
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

function hssProfile(width=100, height=100, thickness=5, rounding=0, anchor=CENTER) =
    assert(is_num(width) && width > 2*thickness, 	"[hssProfile] width must be greater than 2*thickness")
    assert(is_num(height) && height > 2*thickness, 	"[hssProfile] height must be greater than 2*thickness")
    assert(is_num(thickness) && thickness > 0, 		"[hssProfile] thickness must be positive")
    assert(is_num(rounding) && rounding >= 0 && rounding <= thickness/2, 
													"[hssProfile] rounding must be non-negative and <= thickness/2")	
    let (
        w = width, h = height, t = thickness,
		outer = rect([width,height],rounding=rounding),
        //outer = [[0, 0], [w, 0], [w, h], [0, h], [0, 0]],
        //inner = [[t, t], [w-t, t], [w-t, h-t], [t, h-t], [t, t]],
		//inner = reverse(rect([width-2*t,height-2*t])),
		inner = rect([width-2*t,height-2*t],rounding=rounding),
        //path = concat(outer, inner),
		path = make_region([outer,inner]),
		//path = difference(outer,inner),
        offset = -resolveAnchor(anchor, [w, h])
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
//   region(cornerProfile(leg1 = 100,leg2=100,thickness=10,rounding=3));  
function cornerProfile(leg1=50, leg2=50, thickness=5, rounding=0, anchor=[0, 0]) =
    assert(is_num(leg1) && leg1 > thickness, 	"[cornerProfile] leg1 must be greater than thickness")
    assert(is_num(leg2) && leg2 > thickness, 	"[cornerProfile] leg2 must be greater than thickness")
    assert(is_num(thickness) && thickness > 0, 	"[cornerProfile] thickness must be positive")
    assert(is_num(rounding) && rounding >= 0 && rounding <= thickness/2, 
												"[cornerProfile] rounding must be non-negative and <= thickness/2")
    let (
        base_path = [ [0, 0], [leg1, 0], [leg1, thickness], [thickness, thickness], [thickness, leg2], [0, leg2] ],
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
//   width = Channel width (flange length) in mm (default: 100).
//   height = Channel height (web height) in mm (default: 50).
//   thickness = Profile thickness in mm (default: 5).
//   rounding = Fillet radius for corners in mm (default: 0).
//   anchor = Anchor point for the path origin (default: CENTER).
// Returns:
//   Closed list of 2D points forming the channel’s cross-section.
// Example(2D):
//   region(channelProfile());  
function channelProfile(width=100, height=50, thickness=5, rounding=0, anchor=CENTER) =
    assert(is_num(width) && width > 2*thickness, 	"[channelProfile] width must be greater than 2*thickness")
    assert(is_num(height) && height > thickness, 	"[channelProfile] height must be greater than thickness")
    assert(is_num(thickness) && thickness > 0, 		"[channelProfile] thickness must be positive")
    assert(is_num(rounding) && rounding >= 0 && rounding <= thickness/2, 
												"[channelProfile] rounding must be non-negative and <= thickness/2")	
    let (
        w = width, h = height, t = thickness,
        path = [
            [0, 0], [w, 0], [w, t], [t, t], [t, h-t], [w, h-t],
            [w, h], [0, h], [0, h-t], [t-t, h-t], [t-t, t], [0, t]
        ],
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
//   region(iBeamProfile(rounding=3),size=6);	
function iBeamProfile(width=100, height=150, web_thickness=5, flange_thickness=8, rounding=0, anchor=CENTER) =
    assert(is_num(width) && width > web_thickness, 				"[iBeamProfile] width must be greater than web_thickness")
    assert(is_num(height) && height > 2*flange_thickness, 		"[iBeamProfile] height must be greater than 2*flange_thickness")
    assert(is_num(web_thickness) && web_thickness > 0, 			"[iBeamProfile] web_thickness must be positive")
    assert(is_num(flange_thickness) && flange_thickness > 0, 	"[iBeamProfile] flange_thickness must be positive")
    assert(is_num(rounding) && rounding >= 0 && rounding <= flange_thickness/2, 
																"[iBeamProfile] rounding must be non-negative and <= thickness/2")	
    let (
        w = width, h = height, tw = web_thickness, tf = flange_thickness,
        path = [
            [0, 0], [w, 0], [w, tf], [(w+tw)/2, tf], [(w+tw)/2, h-tf],
            [w, h-tf], [w, h], [0, h], [0, h-tf], [(w-tw)/2, h-tf],
            [(w-tw)/2, tf], [0, tf]
        ],
		_r = rounding,
        offset = -resolveAnchor(anchor, [w, h]),
		_path = rounding < 0 ? path : round_corners(path,cut=[0,0,0,_r,_r,0,0,0,0,_r,_r,0],method="circle"),
    )
    move(offset, _path);	
	
// Function: railProfile()
//
// Synopsis: Generates a 2D path for a rail profile (simplified I-shape).
// Topics: Materials, Structural, Metal Profiles
// Usage:
//   path = railProfile(width, height, thickness,rounding, anchor);
// Description:
//   Creates a closed 2D path for a rail profile, simplified as a compact I-shape with uniform thickness.
//   The anchor point defines the path’s origin (e.g., center, base).
// Arguments:
//   width = Base width in mm (default: 80).
//   height = Rail height in mm (default: 100).
//   thickness = Profile thickness in mm (default: 10).
//   rounding = Fillet radius for corners in mm (default: 0).
//   anchor = Anchor point for the path origin (default: CENTER).
// Returns:
//   Closed list of 2D points forming the rail’s cross-section.
// Example(2D):
//   region(railProfile(width=50,height=50,rounding=3,anchor=CENTER));
function railProfile(width=80, height=100, thickness=10, rounding=0, anchor=CENTER) =
    assert(is_num(width) && width > thickness, 		"[railProfile] width must be greater than thickness")
    assert(is_num(height) && height > thickness, 	"[railProfile] height must be greater than thickness")
    assert(is_num(thickness) && thickness > 0, 		"[railProfile] thickness must be positive")
    assert(is_num(rounding) && rounding >= 0 && rounding <= thickness/2, 
													"[railProfile] rounding must be non-negative and <= thickness/2")	
    let (
        w = width, h = height, t = thickness,
        path = [
            [0, 0], [w, 0], [w, t], [(w+t)/2, t], [(w+t)/2, h-t],
            [w, h-t], [w, h], [0, h], [0, h-t], [(w-t)/2, h-t],
            [(w-t)/2, t], [0, t]
        ],
		_r = rounding,
        offset = -resolveAnchor(anchor, [w, h]),
		_path = rounding < 0 ? path : round_corners(path,cut=[0,0,0,_r,_r,0,0,0,0,_r,_r,0],method="circle"),
    )
    move(offset, _path);

// Function: tBeamProfile()
// Synopsis: Generates a 2D path for a T-beam profile.
// Topics: Materials, Structural, Metal Profiles
// Usage:
//   path = tBeamProfile(width, height, flange_thickness, web_thickness,rounding, anchor);
// Description:
//   Creates a closed 2D path for a T-beam with specified flange width, web height, and thicknesses.
//   The anchor point defines the path’s origin (e.g., center, flange top).
// Arguments:
//   width = Flange width in mm (default: 100).
//   height = Web height in mm (default: 100).
//   flange_thickness = Flange thickness in mm (default: 8).
//   web_thickness = Web thickness in mm (default: 5).
//   rounding = Fillet radius for corners in mm (default: 0).
//   anchor = Anchor point for the path origin (default: CENTER).
// Returns:
//   Closed list of 2D points forming the T-beam’s cross-section.
// Example(2D):
//   region(tBeamProfile(width=50,height=50,rounding=2,anchor=CENTER));
function tBeamProfile(width=100, height=100, flange_thickness=8, web_thickness=5, rounding=0, anchor=CENTER) =
    assert(is_num(width) && width > web_thickness, 				"[tBeamProfile] width must be greater than web_thickness")
    assert(is_num(height) && height > flange_thickness, 		"[tBeamProfile] height must be greater than flange_thickness")
    assert(is_num(flange_thickness) && flange_thickness > 0, 	"[tBeamProfile] flange_thickness must be positive")
    assert(is_num(web_thickness) && web_thickness > 0, 			"[tBeamProfile] web_thickness must be positive")
    assert(is_num(rounding) && rounding >= 0 && rounding <= web_thickness/2, 
													"[tBeamProfile] rounding must be non-negative and <= thickness/2")	
	
    let (
        w = width, h = height, tf = flange_thickness, tw = web_thickness,
        path = [
            [0, 0], [w, 0], [w, tf], [(w+tw)/2, tf], [(w+tw)/2, h],
            [(w-tw)/2, h], [(w-tw)/2, tf], [0, tf]
        ],
		_r = rounding,
        offset = -resolveAnchor(anchor, [w, h]),
		_path = rounding < 0 ? path : round_corners(path,cut=[0,0,0,_r,0,0,_r,0],method="circle"),
    )
    move(offset, _path);


