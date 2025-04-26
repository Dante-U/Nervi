include <constants.scad>
include <geometry.scad>
include <debug.scad>
include <geometry.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: distribute.scad
// Includes:
//   include <_core/distribute.scad>
// FileGroup: Utils
// FileSummary: Architecture, Distribute
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
// Example(2D,ColorScheme=Nature):
//   mask = circle(r=5, $fn=32);
//   segs = segmentsCrossing(mask=mask, spacing=2, dir=HORIZONTAL);
//   #stroke(segs, width=0.2);
// Example(2D,ColorScheme=Nature):
//   mask = square([10, 6], center=true);
//   segs = segmentsCrossing(origin=LEFT, mask=mask, spacing=1.5, dir=VERTICAL);
//   #stroke(segs, width=0.2);
   mask = circle(r=5, $fn=32);
   segs = segmentsCrossing(mask=mask, spacing=2, dir=HORIZONTAL);
   #stroke(segs, width=0.2);

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