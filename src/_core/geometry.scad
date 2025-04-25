include <constants.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: geometry.scad
// Includes:
//   include <Nervi/_core/geometry.scad>
// FileGroup: Geometry
// FileSummary: Geometry,3D,2D
//////////////////////////////////////////////////////////////////////

// Function: centerPath()
// 
// Synopsis: Centers a 2D or 3D path around the origin.
// Topics: Geometry, Path Manipulation, Transformation
// Description:
//    Translates a path (list of 2D or 3D points) so its centroid—calculated as the
//    midpoint of its bounding box—is at the origin [0, 0] or [0, 0, 0]. This is
//    ideal for aligning paths symmetrically for subsequent operations like rotation
//    or scaling. Requires BOSL2 library for path validation and movement.
// Arguments:
//    path = List of 2D or 3D points (e.g., [[x1, y1], [x2, y2]] or [[x1, y1, z1], ...]).
// DefineHeader(Generic):Returns:
//    A new path with all points translated to center the path at the origin.
// See Also: boundingSize()
// Usage:
//    centered_path = centerPath([[0, 0], [10, 0], [10, 10]]);  // Centers a 2D triangle
// Example(NORENDER,NoAxes): 2D path centering
//    path = [[0, 0], [10, 0], [10, 10], [0, 10]];
//    centered = centerPath(path);
//    echo(centered);  // Outputs: [[-5, -5], [5, -5], [5, 5], [-5, 5]]
// Example(NORENDER): 3D path centering
//    path = [[0, 0, 0], [10, 0, 0], [5, 10, 5]];
//    centered = centerPath(path);
//    echo(centered);  // Outputs: shifted to center at [0, 0, 0]
// Example(2D,NoAxes): Centering red square and green triangle
//    triangle_path 	= [[5, 5], [15, 5], [10, 15]];       // Green triangle offset
//    triangle_centered 	= centerPath(triangle_path);
//    %stroke(triangle_path, $color="red", $ls="--",closed=true);
//    stroke(triangle_centered, $color="green", $lw=2,closed=true);
function centerPath( path ) = 
	assert(is_def(path),"[centerPath] : Path argument not defined in centerPath")
	let(
		bounds = is_path(path,[2,3]) ?  pointlist_bounds( path ) : undef,
		x = is_def(bounds) ? (bounds[0][X]+bounds[1][X]) /2 : 0,
		y = is_def(bounds) ? (bounds[0][Y]+bounds[1][Y]) /2 : 0,
	) 
		move([-x,-y],path);

// Function: midpoint()
//
// Synopsis: Calculates the midpoint between two points.
// Topics: Geometry, Vectors
// Description:
//   Computes the midpoint between two points by averaging their coordinates.
//   If only one argument (line) is provided, it is treated as a pre-formed
//   line (a list of two points), and the midpoint of that line is calculated.
//   The function validates that the points are 2D or 3D vectors with matching
//   dimensions and numeric coordinates.
// Arguments:
//   p1 = First point (or a pre-formed line if p2 is undefined).
//   p2 = Second point [default: undef].
// Example(2D,ColorScheme=Nature)
//   line = line([-10, -10], [10, 10]);
//   mid = midpoint(line);
//   stroke(line, width=1, color="green");
//   move(mid) circle(r=2, $fn=32, color="red");
function midpoint(p1, p2=undef) = let(
    // Helper: Validate a point is a 2D or 3D vector with numeric coordinates
    //valid_point = function(pt) is_list(pt) && (len(pt) == 2 || len(pt) == 3) && all([for (coord = pt) is_num(coord)]),
    // Get the two points to calculate midpoint from
    points = is_undef(p2) ? 
        let(
            valid = is_list(p1) && len(p1) == 2 && isPoint(p1[0]) && isPoint(p1[1]) && len(p1[0]) == len(p1[1])
        )
        assert(valid, "[midpoint] When p2 is undefined, p1 must be a list of two 2D or 3D points with matching dimensions.")
        p1 
        : 
        let(
            valid = isPoint(p1) && isPoint(p2) && len(p1) == len(p2)
        )
        assert(valid, str("[midpoint] p1 and p2 must be 2D or 3D points with matching dimensions.","p1 :",p1," p2 : ",p2))
        [p1, p2],
    
    // Calculate midpoint
    result = (points[0] + points[1]) / 2
) result;		

// Function: boundingSize() 
// 
// Synopsis: Computes the total bounding size of a given path in 3D space. 
// Topics: Geometry, Bounding Box, Size 
// Description: 
//    This function takes a path consisting of points and calculates the 
//    total size of the bounding box that encompasses the path. The size is 
//    determined by finding the minimum and maximum coordinates for each axis 
//    and calculating the dimensions in the X, Y, and Z directions.
// Arguments: 
//    path = An array of points where each point is an array of coordinates [X, Y, Z](3D) or [X,Y](2D) .
//	  z    = IF provided is overrides the z bounding value	
// Returns: 
//    An array where the first element is the width (X axis size), the 
//    second element is the height (Y axis size), and the third element 
//    is the depth (Z axis size) of the bounding box. If a 2D path is provided 
// 	  then the Z axis size will be 0. 	
// Usage:
//    size = boundingSize(path,z); // Total size
// Example: 
//    path = [[1, 2, 3], [4, 5, 6], [-1, -2, -3]];
//    size = boundingSize(path);
//    echo("Bounding Size: ", size);
// Example(2D): Centering red square and green triangle
//    triangle_path 	= [[5, 5], [15, 5], [10, 15]];       // Green triangle offset
//    triangle_centered 	= centerPath(triangle_path);
//    %stroke(triangle_path, $color="red", $ls="--",closed=true);
//    stroke(triangle_centered, $color="green", $lw=2,closed=true);
function boundingSize( path, z ) = 
	let( b = pointlist_bounds(is_path ( path,dim=2 ) ? path3d(path) : path ) )
	[
		abs(b[0][X]) + abs(b[1][X]),
		abs(b[0][Y]) + abs(b[1][Y]),
		is_undef(z) ? abs(b[0][Z]) + abs(b[1][Z]) : z
	];		
	
	
// Function: circleArea() 	
// Synopsis: Computes circle area using  radius or diameter
function circleArea(r,d) = 
	assert(r != undef || d != undef,"[circleArea] r or d should be defined")
	let (r = is_undef(r) ? d/2 : r) pow(r,2) * PI ;


// Function: line()
// 
// Synopsis: Creates a line segment from two points.
// Topics: Geometry, Vectors
// Description:
//   Constructs a line segment as a list of two points. If only one argument
//   (p1) is provided, it is treated as a pre-formed line (a list of two points).
//   If both p1 and p2 are provided, they are used as the endpoints of the line.
//   The function validates that the points are 2D or 3D vectors with matching
//   dimensions and numeric coordinates.
// Arguments:
//   p1 = First point (or a pre-formed line if p2 is undefined).
//   p2 = Second point [default: undef].
// Example(2D,ColorScheme=Nature)
//   line = line([-10, -10], [10, 10]);
//   stroke(line, width=1, color="green");
//   move(line[0]) circle(r=2, $fn=32);
//   move(line[1]) circle(r=2, $fn=32);
function line(p1, p2=undef) =
    let(
        // Helper: Validate a point is a 2D or 3D vector with numeric coordinates
        valid_point = function(pt) 
            is_list(pt) && (len(pt) == 2 || len(pt) == 3) && 
            all([for (coord = pt) is_num(coord)]),
        // Case 1: p2 is undefined, treat p1 as a pre-formed line
        result = is_undef(p2) 
            ? let(
                valid = is_list(p1) && len(p1) == 2 && 
                        valid_point(p1[0]) && valid_point(p1[1]) && 
                        len(p1[0]) == len(p1[1])
              )
              assert(valid, "When p2 is undefined, p1 must be a list of two 2D or 3D points with matching dimensions.")
              p1
            : // Case 2: p2 is defined, create a line from p1 and p2
              let(
                valid = valid_point(p1) && valid_point(p2) && len(p1) == len(p2)
              )
              assert(valid, "p1 and p2 must be 2D or 3D points with matching dimensions.")
              [p1, p2]
    )
    result;	
	
// Function: xLine()
//
// Synopsis: Generates a 2D path for a horizontal line segment.
// Topics: Geometry, Paths
// Description:
//   Creates a 2D path representing a horizontal line segment centered at the origin,
//   extending along the X-axis from -length/2 to +length/2.
// Arguments:
//   length = Total length of the line segment (in mm).
// Example(2D,ColorScheme=Nature)
//   path = xLine(length=10);
//   stroke(path); // Renders a horizontal line from [-5, 0] to [5, 0]	
function xLine( length ) = 	line ([-length/2,0],[+length/2,0]);

// Function: yLine()
//
// Synopsis: Generates a 2D path for a vertical line segment.
// Topics: Geometry, Paths
// Description:
//   Creates a 2D path representing a vertical line segment centered at the origin,
//   extending along the Y-axis from -length/2 to +length/2.
// Arguments:
//   length = Total length of the line segment (in mm).
// Example(2D,ColorScheme=Nature)
//   path = yLine(length=10);
//   stroke(path); // Renders a vertical line from [0, -5] to [0, 5]
function yLine( length ) = 	line ([0,-length/2],[0,+length/2]);	
	
// Function: lineLength()
// 
// Synopsis: Computes the length of a line segment.
// Topics: Geometry, Vectors
// Description:
//   Calculates the Euclidean length of a line segment defined by two points.
//   The line segment must be a list of two 2D or 3D points, as produced by the
//   line() function. Returns the distance between the two points using the
//   Euclidean distance formula. Works for both 2D and 3D lines.
// Arguments:
//   line = Line segment as a list of two 2D or 3D points.
// Example(2D,ColorScheme=Nature)
//   line_seg = line([-10, -10], [10, 10]);  // Diagonal line
//   length = lineLength(line_seg);  // Should be ~28.28
//   stroke(line_seg, width=1, color="green");
//   move(line_seg[0]) circle(r=2, $fn=32);
//   move(line_seg[1]) circle(r=2, $fn=32);
//   move(mean(line_seg)) text(str("Length: ", round(length, 2)), size=5, halign="center", valign="center");
function lineLength( line ) =
	/*
    let( // Validate input
        valid_point = function(pt) 
            is_list(pt) && (len(pt) == 2 || len(pt) == 3) && 
            all([for (coord = pt) is_num(coord)]),
        valid = is_list(line) && len(line) == 2 && 
                valid_point(line[0]) && valid_point(line[1]) && 
                len(line[0]) == len(line[1])
    )
	*/
    assert( isLine( line ), "Line must be a list of two 2D or 3D points with matching dimensions.")
    let(
        // Compute the difference vector between the two points
        diff = line[1] - line[0],
        // Euclidean distance: sqrt(sum of squared differences)
        length = sqrt(sum([for (i = [0:len(diff)-1]) pow(diff[i], 2)]))
    )
    length;	
	
// Function: lineIntersection()
// 
// Synopsis: Computes the intersection point of two 2D line segments.
// Topics: Geometry, Intersections
// Description:
//   Calculates the intersection point of two finite line segments in 2D space.
//   Each line segment is defined by two points (e.g., [[x1, y1], [x2, y2]]).
//   Returns the intersection point if it exists within the bounds of both segments,
//   or undef if the segments do not intersect or are parallel.
//   The eps parameter handles numerical precision for parallel line checks.
// Arguments:
//   l1  = First line segment as a list of two 2D points.
//   l2  = Second line segment as a list of two 2D points.
//   eps = Tolerance for parallel line checks [default: 1e-6].
// Example(2D,ColorScheme=Nature)
//   l1 = [[-50, -30], [30, 40]];
//   l2 = [[-50, 0], [50, 0]];
//   inter = lineIntersection(l1, l2);
//   stroke(l1, width=1, color="green");
//   stroke(l2, width=1, color="blue");
//   move(l1[0]) circle(r=2, $fn=32);
//   move(l1[1]) circle(r=2, $fn=32);
//   move(l2[0]) circle(r=2, $fn=32);
//   move(l2[1]) circle(r=2, $fn=32);
//   if (inter != undef) move(inter) color("yellow") circle(r=3, $fn=32);
function lineIntersection(l1, l2, eps=1e-6,check=true) =
	/*
    let(
        //valid_point = function(pt) is_list(pt) && len(pt) == 2 && all([for (c = pt) is_num(c)]),
        //valid_line 	= function(l) is_list(l) && len(l) == 2 && valid_point(l[0]) && valid_point(l[1]),
        valid 		= valid_line(l1) && valid_line(l2) && (l1[0] != l1[1]) && (l2[0] != l2[1])
    )
	*/
	//if (check)
	assert(!check ? true : (isLine(l1) && isLine(l2)), str("[lineIntersection] Each line must be a list of two distinct 2D points with numeric coordinates.","l1:",l1," l2:",l2))
		//assert(!check ? true : valid, str("Each line must be a list of two distinct 2D points with numeric coordinates.","l1:",l1," l2:",l2))
    let(
        dir1 = l1[1] - l1[0],
        dir2 = l2[1] - l2[0],
        denom = dir1[0] * dir2[1] - dir1[1] * dir2[0]
    )
    abs(denom) < eps ? undef :
    let(
        delta = l2[0] - l1[0],
        t = (delta[0] * dir2[1] - delta[1] * dir2[0]) / denom,
        u = (delta[0] * dir1[1] - delta[1] * dir1[0]) / denom
    )
    t >= 0 && t <= 1 && u >= 0 && u <= 1 ?
        l1[0] + t * dir1 :
        undef;	

// Function: linePolygonIntersection()
// 
// Synopsis: Finds all intersection points between a 2D line segment and a polygon.
// Topics: Geometry, Intersections
// Description:
//   Computes the intersection points between a finite 2D line segment and a closed
//   2D polygon defined by a path. The line segment is defined by two points, and the
//   path is a list of 2D points forming a closed polygon. Returns a list of intersection
//   points, with duplicates (e.g., at vertices) removed. Returns an empty list if there
//   are no intersections.
// Arguments:
//   line 	= Line segment as a list of two 2D points.
//   path 	= List of 2D points defining a closed polygon.
//   eps  	= Tolerance for point comparison to remove duplicates [default: 1e-6].
// Example(2D,ColorScheme=Nature)
//   path = [[-50, 0], [50, 0], [30, 40], [-30, 40]];  // Trapezoid
//   line = [[-50, -30], [30, 40]];
//   inters = linePolygonIntersection(line, path);
//   color("blue") polygon(path);
//   stroke(line, width=1, color="green");
//   move(line[0]) circle(r=2, $fn=32);
//   move(line[1]) circle(r=2, $fn=32);
//   for (pt = inters) move(pt) color("yellow") circle(r=3, $fn=32);
function linePolygonIntersection(line, path, eps=1e-6) =
	/*
    let(
        valid_point	= function(pt) is_list(pt) && len(pt) == 2 && all([for (c = pt) is_num(c)]),
        valid_line 	= function(l) is_list(l) && len(l) == 2 && valid_point(l[0]) && valid_point(l[1]),
        valid_path 	= is_list(path) && len(path) >= 3 && all([for (pt = path) valid_point(pt)]),
        valid 		= valid_line(line) && valid_path
    )
	*/
    assert(isLine(line) && is_path(path), "[linePolygonIntersection] Line must be two 2D points, and path must be a list of at least three 2D points.")
    let(
        n = len(path),
        segments = [for (i = [0:n-1]) [path[i], path[(i+1)%n]]],
        intersections = [for (seg = segments) let(isect = lineIntersection(line, seg, check=false )) if (isect != undef) isect],
        unique = [
            for (i = [0:len(intersections)-1])
            let(pt = intersections[i])
            if (!any([for (j = [0:i-1]) norm(intersections[j] - pt) < eps]))
            pt
        ]
    )
    unique;

// Function: isLineIntersectsPolygon()
// 
// Synopsis: Checks if a 2D line segment intersects a polygon.
// Topics: Geometry, Intersections
// Description:
//   Determines whether a finite 2D line segment intersects a closed 2D polygon.
//   The line segment is defined by two points, and the polygon is defined by a path
//   (a list of 2D points). Returns true if there is at least one intersection, false
//   otherwise. Optimized to stop checking after the first intersection is found.
// Arguments:
//   line = Line segment as a list of two 2D points.
//   path = List of 2D points defining a closed polygon.
//   eps  = Tolerance for point comparison in intersection checks [default: 1e-6].
// Example(2D,ColorScheme=Nature)
//   path = [[-50, 0], [50, 0], [30, 40], [-30, 40]];  // Trapezoid
//   line1 = [[-50, -30], [30, 40]];  // Intersects
//   line2 = [[0, 50], [10, 50]];     // Does not intersect
//   inter1 = isLineIntersectsPolygon(line1, path);
//   inter2 = isLineIntersectsPolygon(line2, path);
//   color("blue") polygon(path);
//   stroke(line1, width=1, color=inter1 ? "green" : "red");
//   stroke(line2, width=1, color=inter2 ? "green" : "red");
//   move(line1[0]) circle(r=2, $fn=32);
//   move(line1[1]) circle(r=2, $fn=32);
//   move(line2[0]) circle(r=2, $fn=32);
//   move(line2[1]) circle(r=2, $fn=32);
function isLineIntersectsPolygon(line, path, eps=1e-6) =
	/*
    let(     // Validate inputs
        //valid_point = function(pt) is_list(pt) && len(pt) == 2 && all([for (c = pt) is_num(c)]),
        //valid_line 	= function(l) is_list(l) && len(l) == 2 && valid_point(l[0]) && valid_point(l[1]),
        //valid_path 	= is_list(path) && len(path) >= 3 && all([for (pt = path) valid_point(pt)]),
        //valid 		= valid_line(line) && valid_path
		valid 		= isLine(line) && is_path(path)
    )
	*/
    assert(isLine(line) && is_path(path), "Line must be two 2D points, and path must be a list of at least three 2D points.")
    let(
        // Convert path to list of line segments (closed polygon)
        n = len(path),
        segments = [for (i = [0:n-1]) [path[i], path[(i+1)%n]]]
    )
    // Check for the first intersection (short-circuit)
    any([for (seg = segments) lineIntersection(line, seg) != undef]);	

// Function: isLine()
//
// Synopsis: Checks if a list represents a valid 2D line segment.
// Topics: Geometry, Validation
// Description:
//   Determines if the input is a valid 2D line segment, defined as a list of exactly two distinct points,
//   where each point is a valid 2D point (checked via isValidPoint).
// Arguments:
//   l = List representing a line segment, expected to contain two 2D points ([x1, y1], [x2, y2]).
// Example
//   line = [[0, 0], [1, 1]];
//   echo(isLine(line)); // Outputs: true
//   echo(isLine([[0, 0], [0, 0]])); // Outputs: false		
function isLine(l) = 
	is_list(l) && 			// is a list
	len(l) == 2 && 			// has 2 points
	isPoint(l[0]) && 	// point 1 is valid
	isPoint(l[1]) && 	// point 2 is valid
	(l[0] != l[1])			// point 1 is not point 2
	;

	
// Function: isPoint()
//
// Synopsis: Checks if a value is a valid 2D point.
// Topics: Geometry, Validation
// Description:
//   Determines if the input is a valid 2D point, defined as a list of exactly two numeric coordinates [x, y].
// Arguments:
//   pt = Value to check, expected to be a list of two numbers representing a 2D point.
// Example
//   point = [1, 2];
//   echo(isPoint(point)); // Outputs: true
//   echo(isPoint([1, "2"])); // Outputs: false	
function isPoint(pt) = is_list(pt) && len(pt) == 2 && all([for (c = pt) is_num(c)]); 		


	