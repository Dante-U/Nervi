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
// Example(2D,NoAxes): Centering red square and green triangle
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

	
	