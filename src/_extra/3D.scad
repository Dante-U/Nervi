include <../_core/constants.scad>
use <../_core/2D.scad>
use <../_core/utils.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: 3D.scad
// Includes:
//   include <_core/3D.scad>
// FileGroup: Geometry
// FileSummary: 3D, Shapes 
//////////////////////////////////////////////////////////////////////


// Function: tracePoint()
// 
// Synopsis: Defines a point on a trace path with Bezier control information.
// Topics: Path Generation, Bezier Curves
// See Also: trace2Bezier(), trace2BezierPath()
// Description:
//    Creates a trace point with a name, position, and Bezier control handles.
//    Each point can have one or two handles, depending on its role in the path (start, end, or joint).
// Arguments:
//    name 		= A string identifier for the point [default: "unnamed"].
//    pt 		= The 2D position of the point [x, y].
//    angle1 	= The angle of the first Bezier handle in degrees.
//    handle1 	= The length of the first Bezier handle.
//    angle2 	= The angle of the second Bezier handle in degrees (optional, for joints).
//    handle2 	= The length of the second Bezier handle (optional, for joints).
// Returns:
//    A list [name, pt, angle1, handle1, angle2, handle2], with angle2 and handle2 as undef if not provided.
// Example:
//    pt = tracePoint("start", [0, 0], 0, 5, undef, undef);  // Start point
function tracePoint(name="unnamed", pt, angle1, handle1, angle2=undef, handle2=undef) =
    assert(is_vector(pt) && len(pt) >= 2, 		"[tracePoint] pt must be a 2D or 3d point [x, y].")
    assert(is_num(angle1), 						"[tracePoint] angle1 must be a number.")
    assert(is_num(handle1) && handle1 >= 0, 	"[tracePoint] handle1 must be a non-negative number.")
    assert(is_undef(angle2) || is_num(angle2), 	"[tracePoint] angle2 must be a number if provided.")
    assert(is_undef(handle2) || (is_num(handle2) && handle2 >= 0), "[tracePoint] handle2 must be a non-negative number if provided.")
    [name, pt, angle1, handle1, angle2, handle2];		
	
// Function: trace2BezierPath()
// 
// Synopsis: Converts a trace path into a Bezier path specification.
// Topics: Path Generation, Bezier Curves
// See Also: tracePoint(), trace2Bezier()
// Description:
//    Converts a list of trace points into a Bezier path specification using BOSL2 Bezier functions.
//    Handles start, end, and joint points appropriately based on the presence of second handles.
// Arguments:
//    tracePath = A list of trace points created by tracePoint().
// Returns:
//    A flattened list of Bezier control points suitable for bezpath_curve().
// Example:
//    path = [
//        tracePoint("start", [0, 0], 0, 5),
//        tracePoint("mid", [10, 5], 0, 5, 90, 5),
//        tracePoint("end", [20, 0], 180, 5)
//    ];
//    bez_path = trace2BezierPath(path);
function trace2BezierPath(tracePath,meters = true) =
    assert(is_list(tracePath) && len(tracePath) >= 2, "[trace2BezierPath] tracePath must be a list with at least 2 points.")
    let(count = len(tracePath))
    flatten([
        for (i = [0:count-1])
        let(
            item = tracePath[i],
            pt = meters ? meters(item[1]) : item[1] ,
            first = i == 0,
            last = i == count-1,
            a1 = item[2],
            h1 = meters ? meters(item[3]): item[3],
            a2 = item[4],
            h2 = item[5],
            joint = is_def(a2) && is_def(h2)
        )
        first ? bez_begin(pt, a1, h1) :
        last ? bez_end(pt, a1, h1) :
        joint ? bez_joint(pt, a1, h1, a2, h2) :
        bez_tang(pt, a1, h1)
    ]);
	
// Function: trace2Bezier()
// 
// Synopsis: Converts a trace path into a Bezier curve of points.
// Topics: Path Generation, Bezier Curves
// See Also: tracePoint(), trace2BezierPath()
// Description:
//    Converts a list of trace points into a Bezier curve by generating a Bezier path and converting it to points.
//    The resolution parameter controls the number of points in the resulting curve.
// Arguments:
//    tracePath = A list of trace points created by tracePoint().
//    resolution = Number of points to generate along the Bezier curve [default: 50].
// Returns:
//    A list of 2D points representing the Bezier curve.
// Example:
//    path = [
//        tracePoint("start", [0, 0], 0, 5),
//        tracePoint("mid", [10, 5], 0, 5, 90, 5),
//        tracePoint("end", [20, 0], 180, 5)
//    ];
//    bez_curve = trace2Bezier(path, resolution=100);
function trace2Bezier(tracePath, resolution=3,meters = true) =
    assert(is_num(resolution) && resolution >= 3, "[trace2Bezier] resolution must be a number >= 3.")
    bezpath_curve(trace2BezierPath(tracePath,meters=meters), N=resolution);	
	

// Module: parallelepiped()
// 
// Synopsis: Extrudes a parallelogram into a 3D parallelepiped with specified depth.
// Topics: Shapes, 3D Geometry
// See Also: parallelogram()
// Description:
//    Creates a 3D parallelepiped by extruding a 2D parallelogram along the Z-axis.
//    The base shape is defined by width, height, and skew parameters, with optional
//    rounding inherited from parallelogram().
// Arguments:
//    width  = Default width for both base edges if width1 or width2 are undefined.
//    width1 = Width of the bottom edge. [default: width]
//    width2 = Width of the top edge. [default: width]
//    height = Height of the parallelogram base. [default: 5]
//    skew   = Horizontal offset (skew) applied to the top edge. [default: 5]
//    depth  = Extrusion depth along the Z-axis.
// Example(3D,ColorScheme=Tomorrow) :  Simple 
//    parallelepiped( width=20, height=10, skew=5, depth=8);
// Example(3D,ColorScheme=Tomorrow) :  With bottom and top width
//    parallelepiped( width1=25, width2=15, height=10, skew=5, depth=8);
// Example(3D,ColorScheme=Tomorrow) :  Rounded
//    parallelepiped( width=20, height=10, skew=5, depth=8, rounding = 3);
module parallelepiped( 
	width,
	width1,
	width2, 
	height, 
	skew,
	depth,
    rounding,
	anchor = CENTER,
	spin = 0,
	orient,	
) {
	dummy = 
		assert (is_num(width) || is_num(width1), "[parallelepiped] Width or Width1 is not defined")
		assert (is_num(width) || is_num(width2), "[parallelepiped] Width or Width2 is not defined")
		;
	path = parallelogram (
			width = width,
			width1 = width1,
			width2 = width2,
			height = height,
			skew = skew,
			rounding = rounding
		);	
	bounding = boundingSize(path,z=depth);
		echo (bounding);
		
	center = centroid(path);	
	echo ("cp",center);

	attachable(size=bounding, anchor=anchor, spin=spin, orient=orient, cp=[center[X],center[Y],depth/2]) {	
		linear_extrude (height = depth)
			polygon(path);	
		children();	
	}	
}


// Module: gableShape()
//
// Synopsis: Creates a gable-shaped prism with adjustable pitch and thickness.
// Topics: Architecture, Geometry, Roofing
// Description:
//   Generates a gable-shaped triangular prism with optional hollowing based on thickness.
//   The module calculates height from pitch or vice versa if one is unspecified. It supports
//   an open or closed base and provides attachment points for further modifications.
// Arguments:
//   length    = Length of the gable base along the X-axis.
//   width     = Width of the gable base along the Y-axis.
//   height    = Height of the gable peak [default: calculated from pitch and width].
//   pitch     = Roof pitch angle in degrees [default: calculated from height and width].
//   thickness = Wall thickness of the gable [default: 0, no hollowing].
//   closed    = If true, closes the ends of the gable [default: false].
//   anchor    = Anchor point for positioning [default: CENTER].
//   spin      = Rotation angle around the Z-axis in degrees [default: 0].
//   orient    = Orientation of the gable [default: UP].
// Usage:
//   gableShape(length=10, width=8, pitch=30, thickness=1);
// Example(3D,ColorScheme=Tomorrow): Gable shape closed
//   gableShape(length=10, width=8, pitch=45, thickness=1, closed=true);
// Example(3D,ColorScheme=Tomorrow): Open gable with height specified
//   gableShape(length=12, width=10, height=5, thickness=0.5, closed=false);
// Example(3D,ColorScheme=Tomorrow): Gable spinned
//   gableShape(length=12, width=10, height=5, thickness=0.5, closed=true, spin=90 );
module gableShape(
    length,
    width,
    height    = undef,
    pitch     = undef,
    thickness = 0,
    closed    = false,
    anchor    = CENTER,
    spin      = 0,
    orient    = UP
) {
    // Constants
    CLEARANCE = 0.01;  // Small offset to prevent z-fighting

    // Input validation
    assert(is_num(length), "[gableShape] Length must be a number.");
    assert(is_num(width),  "[gableShape] Width must be a number.");
    assert(is_num(thickness) && thickness >= 0, "[gableShape] Thickness must be a non-negative number.");
    assert(is_bool(closed), "[gableShape] Closed must be a boolean.");

    // Calculate height or pitch if one is undefined
    effective_height = is_def(height) ? height : adj_ang_to_opp(width / 2, pitch);
    effective_pitch  = is_def(pitch)  ? pitch  : opp_adj_to_ang(effective_height, width / 2);

    // Validate calculated values
    assert(effective_pitch >= 0 && effective_pitch < 90, "[gableShape] Pitch must be between 0 and 90 degrees.");
    assert(effective_height >= 0, "[gableShape] Height must be non-negative.");

    // Dimensions for inner subtraction (if thickness > 0)
    inner_width_adj = 2 * ang_opp_to_hyp(effective_pitch, thickness);
    inner_height    = effective_height - ang_opp_to_hyp(90 - effective_pitch, thickness);
    length_offset   = closed ? 2 * thickness : 0;

    // Bounding box for attachment
    bounding = [length, width, effective_height];

    // Main geometry
    attachable(size=bounding, anchor=anchor, spin=spin, orient=orient, cp=[0, 0,effective_height/2 /*, effective_height / 2*/]) {
        union() {
            difference() {
                // Outer gable shape
                prismoid(
                    size1 = [length, width],
                    size2 = [length, 0],
                    h     = effective_height
                );
                // Inner subtraction for hollowing (if thickness > 0)
                if (thickness > 0) {
                    down(CLEARANCE)
                    prismoid(
                        size1 = [length - length_offset, width - inner_width_adj],
                        size2 = [length - length_offset, 0],
                        h     = inner_height + CLEARANCE
                    );
                }
            }
        }
        children();
    }
}

// Module: pieSlice()
//
// Synopsis: Creates a 3D pie slice (cylindrical sector) with specified dimensions
// Topics: Shapes, Geometry, 3D, Cylinders
// Description:
//   Creates a 3D pie slice by extruding a 2D sector of a circle.
//   The slice starts at 0 degrees and extends counterclockwise by the specified angle.
//   The shape includes the center point and creates a solid piece with flat sides.
//
// Arguments:
//   radius 	= Radius of the pie slice from center to outer edge
//   angle  	= Angle of the slice in degrees (0 to 360)
//   height 	= Height/thickness of the slice
//   anchor 	= Position anchor for the slice. Default: CENTER
//   spin   	= Rotation angle in degrees. Default: 0
//
// Example(3D,ColorScheme=Tomorrow): Quarter circle slice
//   pieSlice(radius=50, angle=90, height=20);  
//
// Example(3D,ColorScheme=Tomorrow): Third of a circle
//   pieSlice(radius=30, angle=120, height=15);  
module pieSlice( radius,angle = 90, height=5 , anchor, spin ,orient ) {
	bounding_size = [radius*2,radius*2,height];
	attachable(anchor, spin, orient = orient, size = bounding_size,cp=[0,0,height/2] )   {
		// Generate points for the curved edge
		points = [ for (a = [0 : 1 : angle]) [ radius * cos(a), radius * sin(a) ] ];
		// Create the complete set of points including center
		full_shape = concat([[0, 0]], points);
		// Extrude the 2D shape to create 3D pie slice
		linear_extrude(height=height) polygon(points=full_shape);
		children();
	}		
}

module bendExtrude( size, thickness, angle, frags = 24 ) {
    x = size.x;
    y = size.y;
    frag_width = x / frags ;
    frag_angle = angle / frags;
    half_frag_width = 0.5 * frag_width;
    half_frag_angle = 0.5 * frag_angle;
    r = half_frag_width / sin(half_frag_angle);
    s =  (r - thickness) / r;
    
    scale 	= [s, 1];
    transX 	= [x, 0, 0];
    mirrorX = [1, 0, 0];
    sq_size = [frag_width, y];
    module get_frag(i) {
        offsetX = i * frag_width;
        linear_extrude(thickness, scale = scale) 
        translate([-offsetX - half_frag_width, 0, 0]) 
        intersection() {
            translate(transX) 
            mirror(mirrorX) 
                children();
            translate([offsetX, 0, 0]) 
                square(sq_size);
        }
    }

    offsetY = [0, -r * cos(half_frag_angle), 0];
    rotXn90 = [-90, 0, 0];

    rotate(angle - 90)
    mirror([0, 1, 0])
    mirror([0, 0, 1])
    for(i = [0 : frags - 1]) {
        rotate(i * frag_angle + half_frag_angle) 
        translate(offsetY)
        rotate(rotXn90) 
        get_frag(i) 
            children();  
    }
}

module ellipse_extrude(semi_minor_axis, height, center = false, convexity = 10, twist = 0, slices = 20) {
    h = is_undef(height) ? semi_minor_axis : (
        // `semi_minor_axis` is always equal to or greater than `height`.
        height > semi_minor_axis ? semi_minor_axis : height
    );
    angle = asin(h / semi_minor_axis) / slices; 

    f_extrude = [
        for(i = 1; i <= slices; i = i + 1) 
        [
            cos(angle * i) / cos(angle * (i - 1)), 
            semi_minor_axis * sin(angle * i)
        ]
    ]; 
    len_f_extrude = len(f_extrude);

    accm_fs =
        [
            for(i = 0, pre_f = 1; i < len_f_extrude; pre_f = pre_f * f_extrude[i][0], i = i + 1)
                pre_f * f_extrude[i][0]
        ];

    child_fs = [1, each accm_fs];
    pre_zs = [0, each [for(i = 0; i < len_f_extrude; i = i + 1) f_extrude[i][1]]];

    module extrude() {
        for(i = [0:len_f_extrude - 1]) {
            f = f_extrude[i][0];
            z = f_extrude[i][1];

            translate([0, 0, pre_zs[i]]) 
            rotate(-twist / slices * i) 
            linear_extrude(
                z - pre_zs[i], 
                convexity = convexity,
                twist = twist / slices, 
                slices = 1,
                scale = f 
            ) 
            scale(child_fs[i]) 
                children();
        }
    }
    
    center_offset = [0, 0, center ? -h / 2 : 0];
    translate(center_offset) 
    extrude() 
        children();


}


// Module to create a cuboid along a line segment defined by two 3D points
module line_cuboid( p1, p2, section, spin=true, up=[0,0,1] ) {
    // Calculate the length of the line segment (X dimension)
    len = norm(p2 - p1);
    
    // Extract Y and Z dimensions from section
    y_dim = is_num(section.y) ? section.y : section[1];
    z_dim = is_num(section.z) ? section.z : section[2];
    
    // Calculate the direction vector
    dir = p2 - p1;
    axis = norm(dir) > 0 ? dir : [1, 0, 0]; // Avoid zero vector
    
    // Position and orient the cuboid
    translate(p1)
    if (spin) {
        // Original behavior: align with line, possible spin
        angle = vector_angle([1, 0, 0], axis);
        rot_axis = norm(cross([1, 0, 0], axis)) > 0 ? cross([1, 0, 0], axis) : [0, 0, 1];
        rotate(angle, rot_axis)
            cuboid([len, y_dim, z_dim], anchor=LEFT);
    } else {
        // No spin: align with line, keep cross-section consistent with 'up'
        rot(from=[1,0,0], to=axis, a=0, v=up)
            cuboid([len, y_dim, z_dim], anchor=LEFT);
    }
}
