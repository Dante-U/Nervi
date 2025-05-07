include <constants.scad>
include <geometry.scad>
include <debug.scad>
include <geometry.scad>
include <metadata.scad>
include <../_materials/multi_material.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: distribute.scad
// Includes:
//   include <_core/distribute.scad>
// FileGroup: Utils
// FileSummary: Geometry distribution helpers
//////////////////////////////////////////////////////////////////////

// Function: segmentsCrossing
//
// Synopsis: Generates line segments intersecting a 2D polygon at regular intervals.
// Topics: Geometry, Paths, Intersections
// Description:
//   Computes a list of 2D line segments that intersect a given polygon (mask),
//   spaced at regular intervals along a specified direction (HORIZONTAL or
//   VERTICAL). The origin parameter determines the starting point of the lines:
//   - For HORIZONTAL, origin can be CENTER, BACK, or FWD.
//   - For VERTICAL, origin can be CENTER, LEFT, or RIGHT.
//   Each segment spans the polygon’s width (for HORIZONTAL) or height (for
//   VERTICAL), centered or offset based on origin. The mask is assumed to be a
//   2D path, which is centered internally for calculations. Only valid
//   intersections (non-empty, proper segments) are included in the output.
// Arguments:
//   origin 	= Starting point for lines: CENTER, BACK, FWD (for HORIZONTAL); CENTER, LEFT, RIGHT (for VERTICAL) [default: CENTER].
//   mask 		= 2D polygon path to intersect.
//   spacing 	= Distance between consecutive lines.
//   dir 		= Direction of lines: HORIZONTAL or VERTICAL [default: HORIZONTAL].
// Example(2D,ColorScheme=Tomorrow):
//   mask = circle(r=5, $fn=32);
//   segs = segmentsCrossing(mask=mask, spacing=2, dir=HORIZONTAL);
//   #stroke(segs, width=0.2);
// Example(2D,ColorScheme=Tomorrow):
//   mask = square([10, 6], center=true);
//   segs = segmentsCrossing(origin=LEFT, mask=mask, spacing=1.5, dir=VERTICAL);
//   #stroke(segs, width=0.2);
function segmentsCrossing( origin = CENTER, mask, spacing, dir = HORIZONTAL ) =
	assert( in_list(dir,[ HORIZONTAL,VERTICAL ])							,"Wrong [dir] parameter")
	assert( spacing															,"Missing [spacing] argument")
	assert( dir == HORIZONTAL 	? in_list(origin,[CENTER,BACK,FWD]) : true	,"When [dir] is HORIZONTAL then [origin] should be CENTER,BACK or FWD" )
	assert( dir == VERTICAL 	? in_list(origin,[CENTER,LEFT,RIGHT]) : true,"When [dir] is VERTICAL then [origin] should be CENTER,LEFT or RIGHT" )
	let (
		// Polygon dimensions	
		bounds 		= point2d(boundingSize(mask)),
		width 		= bounds.x,
		height 		= bounds.y,
		// Centered mask
		cmask 	= centerPath(mask),	  // Modified to centerPath
		// Origin offset
		origin_offset = v_mul(point2d(origin),bounds) /2,
		// Line parameters
		length  = (dir == HORIZONTAL ? width  : height),
		line  	= line( -dir*length/2, +dir*length/2 ),
		
		half_count  = ceil((dir == HORIZONTAL ? height  : width) / spacing /2) ,
		offset_dir = reverse(dir),
		start   = origin == CENTER ? -half_count : 0,
		end   	= origin == CENTER ? +half_count : 2* half_count,
		axis_origin = v_mul(origin_offset,offset_dir),
		polarity = origin == CENTER ? [1,1] : v_mul(-point2d(origin),offset_dir),
	)[
			for (i = [start:end])
				let (
					offset	= v_mul(polarity,v_mul([spacing,spacing], offset_dir * i )),
					_line 		= move( (offset+axis_origin), line ),
					intersect 	= linePolygonIntersection( _line, cmask ),
				)
				if (isLine(intersect)) intersect
	];
	
// Module: rectangularFrame
//
// Synopsis: Creates a rectangular frame of beams for structural applications
// SynTags: Geom, Attachable, BIM
// Topics: Structural, Framing, Beams
// See Also: beam()
// Description:
//   Generates a perimeter frame composed of beams arranged along the X and Y axes,
//   suitable for roofing, flooring, or other structural frameworks. The frame’s outer
//   or inner dimensions are specified in meters, with beams distributed to form the
//   top, bottom, left, and right edges. Beams are oriented based on a prioritization
//   axis (X or Y), with Y-axis beams rotated 90 degrees. The module supports debugging
//   with a ghosted bounding box and provides metadata (volume, weight, cost, IFC class)
//   via the info argument. Special variables $frame_length and $frame_section pass beam
//   parameters to child modules.
// Usage:
//   rectangularFrame(iSize,oSize,section,[prioritize],[material],[anchor],[spin],[debug],[info])
//
// Arguments:
//   iSize      = Inner dimensions [width, depth] in meters (optional; one of iSize or oSize required).
//   oSize      = Outer dimensions [width, depth] in meters (optional; takes precedence over iSize).
//   section    = Beam cross-section [width, height] in millimeters.
//   prioritize = Axis to prioritize for beam length (X=[1,0,0] or Y=[0,1,0]) [default: X].
//   material   = Beam material (e.g., "Wood", "Steel") [default: "Wood"].
//   anchor     = Anchor point for positioning (used by attachable) [default: undef].
//   spin       = Rotation angle in degrees around Z-axis (used by attachable) [default: undef].
//   debug      = If true, renders a ghosted bounding box [default: true].
//   info       = If defined, returns metadata instead of geometry [default: undef].
//
// Context Variables:
//   $frame_length  = Beam length in millimeters for the current child call.
//   $frame_section = Beam cross-section [width, height] in millimeters.
//
// Named Anchors:
//   "front-left" 	= front left assembly anchor for x prioritized
//   "front-right" 	= front right assembly anchor for x prioritized
//   "back-left" 	= back left assembly anchor for x prioritized
//   "back-right" 	= back right assembly anchor for x prioritized
//   "left-back" 	= left back assembly anchor for y prioritized
//   "left-fwd" 	= left forward assembly anchor for y prioritized
//   "right-back" 	= right back assembly anchor for y prioritized
//   "right-fwd" 	= right fordard assembly anchor for y prioritized
//
// Example(3D,ColorScheme=Tomorrow): Beam reactangular frame with default priorization on X axis
//   include <structure.scad>
//   rectangularFrame(oSize=[.4, .4], section=[50, 80]) 
//       beam(l=$frame_length, section=$frame_section, family="Wood");
// Example(3D,ColorScheme=Tomorrow): Beam reactangular frame with priorization on Y axis
//   include <structure.scad>
//   rectangularFrame(oSize=[.4, .4], section=[50, 80],prioritize = Y) 
//       beam(l=$frame_length, section=$frame_section, family="Wood");
// Example(3D,ColorScheme=Tomorrow): Beam reactangular with assembly anchors
//   include <structure.scad>
//   diff() rectangularFrame(oSize=[.4, .4], section=[50, 80], prioritize = Y) {
//      beam(l=$frame_length, section=$frame_section, family="Wood");
//      attach(["left-back","left-fwd","right-back","right-fwd"],CTR,inside=true) cyl(d=20,l=15);
//   }
//
module rectangularFrame(
    iSize,
    oSize,
    prioritize = X,
    section,
	family 			= "Wood",
    material   		= "Pine",
	cubic_price		= 0,
    anchor,
    spin,
    debug      		= false,
    info
) {
    // Validate inputs
    assert(any_defined([iSize, oSize]), 			"[rectangularFrame] Must define at least iSize or oSize");
    assert(is_undef(iSize) || is_meters(iSize)  , 	"[rectangularFrame] iSize must be a valid [width, depth] in meters");
    assert(is_undef(oSize) || is_meters(oSize)  , 	"[rectangularFrame] oSize must be a valid [width, depth] in meters");
    //assert(is_vector(prioritize) && in_list(prioritize, [X, Y]), "[RectangularFrame] prioritize must be X or Y");
	assert(in_list(prioritize, [X, Y]), 			"[rectangularFrame] prioritize must be X or Y");
    assert(is_vector(section) && len(section) == 2 && all_positive(section), "[rectangularFrame] section must be a valid [width, height] in mm");
    assert(info == false || is_string(material), 	"[rectangularFrame] material must be a string");
	assert(info == false || is_string(family), 		"[rectangularFrame] family must be a string");
	
	dw = 2*section.x; // Double width
	hw = section.x/2; // Half width
    // Calculate outer dimensions (in millimeters)
    outer_size = is_def(oSize) ? meters(oSize) : meters(iSize) + [dw,dw];

    $frame_section = section;	// Set beam section for children

    // Calculate shortening for beam length (in mm) to avoid overlaps
    shortening = prioritize == X ? [0,dw] : [dw, 0];
    bounding = [outer_size.x, outer_size.y, section.y];
	
	
	anchors = prioritize == X ? [
			named_anchor("front-left",	pos=[ -bounding.x/2+hw	, -bounding.y/2, 0 ],orient=FWD),
			named_anchor("front-right",	pos=[ +bounding.x/2-hw	, -bounding.y/2, 0 ],orient=FWD),
			named_anchor("back-left",	pos=[ -bounding.x/2+hw	, +bounding.y/2, 0 ],orient=BACK),
			named_anchor("back-right",	pos=[ +bounding.x/2-hw	, +bounding.y/2, 0 ],orient=BACK),
			
		] : 
		[
			named_anchor("left-back",	pos=[ -bounding.x/2		, +bounding.y/2 -hw , 0 ],orient=LEFT),
			named_anchor("left-fwd",	pos=[ -bounding.x/2		, -bounding.y/2 +hw , 0 ],orient=LEFT),
			named_anchor("right-back",	pos=[ +bounding.x/2		, +bounding.y/2 -hw , 0 ],orient=RIGHT),
			named_anchor("right-fwd",	pos=[ +bounding.x/2		, -bounding.y/2 +hw , 0 ],orient=RIGHT),
		];

    // Metadata calculation
    if (provideMeta(info)) {
        // Estimate volume: 2 X-axis beams + 2 Y-axis beams
        x_beam_length = outer_size.x - shortening.x;
        y_beam_length = outer_size.y - shortening.y;
        beam_volume = (2 * x_beam_length * section.x * section.y +
                       2 * y_beam_length * section.x * section.y) / 1e9; // mm³ to m³
		density = materialSpec( family,material,MATERIAL_DENSITY); // kg/m³
        _ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
        $meta = [
            ["name",        str("Frame(", material, ")")],
            ["volume",      beam_volume					],
            ["weight",      beam_volume * density		],
            ["unit_price",  cubic_price					],
            ["cost",        beam_volume * cubic_price	],
            ["ifc_class",   "IfcMember"					],
            ["ifc_type",    "BEAM"						],
            ["ifc_guid",    _ifc_guid					]
        ];
        info();
    } else {
        attachable( anchor=anchor, spin=spin, size=bounding, anchors = anchors ) {
            union() {
                // X-axis beams (top and bottom)
                ycopies(outer_size.y - section.x) {
                    $frame_length = asMeters(outer_size.x - shortening.x);
					children(0);
                }
                // Y-axis beams (left and right, rotated 90°)
                xcopies(outer_size.x - section.x) {
                    $frame_length = asMeters(outer_size.y - shortening.y);
                    zrot(90) children(0);
                }
            }
			union() {
				if ($children > 1) children([1 : $children-1]);  
				if (debug) ghost() cuboid(bounding);
			}
        }
    }
}

