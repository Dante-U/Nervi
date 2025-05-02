include <constants.scad>
use <2D.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: curves.scad
// Includes:
//   include <_core/curves.scad>;
// FileGroup: Geometry
// FileSummary: Curves
//////////////////////////////////////////////////////////////////////

// Function: sineWave()
//
// Synopsis: Generates a 2D path for a sinusoidal wave.
// Topics: Geometry, Parametric Curves
// Description:
//   Creates a series of 2D points representing a sinusoidal wave with specified length,
//   amplitude, wavelength, and period. The wave can be shifted along the Y-axis or phase-shifted.
// Arguments:
//   length = Total length of the wave along the X-axis (in mm). Must be provided.
//   amplitude = Height of the wave from the centerline (in mm).
//   wavelength = Distance between consecutive peaks of the wave (in mm). If undefined, calculated as length / period.
//   period = Number of wave cycles over the total length. Required if wavelength is undefined.
//   resolution = Distance between consecutive points along the X-axis (in mm). Default: 1.
//   phase_shift = Horizontal shift of the wave (in mm). Default: 0.
//   y_move = Vertical shift of the wave (in mm). Default: 0.
// Example(2D,ColorScheme=Nature): Renders a sinusoidal wave
//   path = sineWave( length=100, amplitude=10, wavelength=25, period=5 );
//   stroke(path);
function sineWave(
    length,
    amplitude,
    wavelength,
    period,
    resolution 	= 1,  // Default resolution
    phase_shift = 0,
    y_move 		= 0
) =
	assert(!is_undef(length), "[sineWave] length must be defined") // Ensure length is defined
    let(
        
        // Calculate wavelength: use provided value or derive from length/period
        wavelength = is_undef(wavelength) ? length / period : wavelength,
        // Calculate number of points based on length and resolution
        num_points = floor(length / resolution) + 1,
        // Convert phase shift from distance to angle (degrees)
        phase_angle = 360 * phase_shift / wavelength,
        // Generate the array of points
        points = [
            for (i = [0 : num_points - 1])
                let(
                    x = i * resolution,
                    // Apply phase shift in the sine calculation
                    y = amplitude * sin(360 * x / wavelength + phase_angle) + y_move
                )
                [x, y]
        ]
    )
    points;

	
// Function: sine_formula()
//
// Synopsis: Calculates the y-value for a specific sine curve formula.
// Topics: Math, Trigonometry, Curves
// Description:
//   Implements the mathematical formula `m * sin(x * (2 * PI * p - PI))`
//   which defines a sine wave. The parameters control the amplitude (`m`)
//   and influence the frequency/period (`p`) over the normalized domain `x` [0, 1].
// Arguments:
//   x = The input value, expected to be in the range [0, 1].
//   m = The multiplier (amplitude) of the sine wave.
//   p = The period control parameter. Affects the frequency within the x range.
function sine_formula(x, m, p) = m * sin(2 * PI * p * x);

// Function: sawtoothWave()
// 
// Synopsis: Generates a sawtooth wave path with specified parameters.
// Topics: Geometry, Waves, Mathematics
// Description:
//    Creates a sawtooth wave as a list of 2D points or a rendered 3D object, defined
//    by total length, amplitude, wavelength, and optional phase shift and vertical
//    offset. The wave rises linearly from -amplitude to +amplitude over half the
//    wavelength, then falls back to -amplitude. Uses BOSL2’s path_sweep() for
//    efficient rendering when render=true. Ideal for architectural or design
//    elements like jagged edges or rhythmic patterns.
// Arguments:
//    total_length = Total horizontal length of the wave [required].
//    amplitude = Vertical amplitude of the wave (peak-to-peak is 2*amplitude) [required].
//    wavelength = Length of one complete wave cycle [required].
//    interval = Distance between points along the x-axis [default: 1].
//    phase_shift = Horizontal shift of the wave (distance) [default: 0].
//    y_move = Vertical offset of the wave [default: 0].
//    render = Render the wave as a 3D object [default: false].
//    anchor = Anchor point (BOSL2 style) [default: BOTTOM].
//    spin = Rotation angle in degrees around Z (BOSL2 style) [default: 0].
// DefineHeader(Generic):Returns:
//    If render=false: List of 2D points [[x0,y0], [x1,y1], ...].
//    If render=true: A 3D sawtooth wave object, attachable to children.
// Usage:
//    points = sawtoothWave(total_length=100, amplitude=10, wavelength=20);
//    sawtoothWave(total_length=50, amplitude=5, wavelength=15, render=true);
// Example(3D,ColorScheme=Nature,NoAxes): Rendered sawtooth wave
//    stroke(sawtoothWave( total_length=100, amplitude=30, wavelength=15,interval=10 ));	
// Example(3D,ColorScheme=Nature,NoAxes): Sawtooth wave with phase shift
//    stroke(sawtoothWave( total_length=100, amplitude=30, wavelength=15,interval=10,phase_shift=10 ));	
// Example(3D,ColorScheme=Nature,NoAxes): Sawtooth wave with y move
//    stroke(sawtoothWave( total_length=100, amplitude=30, wavelength=15,interval=10,y_move=10 ));	
function sawtoothWave(total_length, amplitude, wavelength, interval, phase_shift = 0, y_move = 0) = 
    let(
        // Calculate number of points based on total length and interval
        num_points = floor(total_length / interval) + 1,
        // Generate the array of points
        points = [
            for (i = [0 : num_points - 1])
                let(
                    x = i * interval,
                    // Calculate position within the current wavelength (accounting for phase shift)
                    pos_in_wave = (x + phase_shift) % wavelength,
                    
					// Calculate y value based on position in wave
                    // First half: rise from -amplitude to +amplitude
                    // Second half: fall from +amplitude to -amplitude
                    y = (pos_in_wave <= wavelength/2) ?
                        // Rising part (linear mapping from -amp to +amp)
                        (-amplitude + (2 * amplitude * pos_in_wave / (wavelength/2))) :
                        // Falling part (linear mapping from +amp to -amp)
                        (amplitude - (2 * amplitude * (pos_in_wave - wavelength/2) / (wavelength/2)))
                )
                [x, y + y_move]
        ]
    )
    points;

// Function: fibonacciSpiral()
// 
// Synopsis: Generates a Fibonacci (golden) spiral path with optional bounds and centering.
// Topics: Geometry, Spirals, Mathematics
// Description:
//    Creates a golden spiral path based on the golden ratio (phi ≈ 1.618), scaled to fit
//    within specified max_width or max_height bounds. The spiral grows exponentially
//    with angle, using the radius formula 10 * phi^(angle/90). Can return points or
//    render a 3D object, with an option to center the spiral at the origin. Uses BOSL2
//    for efficient path generation and rendering.
// Arguments:
//    max_width = Maximum width of the spiral bounding box (optional).
//    max_height = Maximum height of the spiral bounding box (optional).
//    points = Number of angle steps for the spiral [default: 360].
//    angle_step = Angle increment between points in degrees [default: 1].
//    center = Center the spiral at [0,0] if true [default: false].
//    anchor = Anchor point (BOSL2 style) [default: BOTTOM].
//    spin = Rotation angle in degrees around Z (BOSL2 style) [default: 0].
// DefineHeader(Generic):Returns:
//    If render=false: List of 2D points [[x0,y0], [x1,y1], ...].
//    If render=true: A 3D spiral object, attachable to children.
// Usage:
//    points = fibonacciSpiral(max_width=100);
//    fibonacciSpiral(max_height=80, render=true);
// Example(2D,ColorScheme=Nature): Centered spiral with max width
//    stroke(fibonacciSpiral(max_width=100, center=true));
// Example(2D,ColorScheme=Nature): Uncentered spiral with max height
//    stroke(fibonacciSpiral(max_height=61.8, points=540 ));
function fibonacciSpiral( max_width, max_height, points=360, angle_step=1, center = false ) = 
    let (
        phi = phi(),
        // Generate unscaled points
        unscaled_points = [
            for (i = [0 : angle_step : points * angle_step])
                let (
                    radius = 10 * pow(phi, (i / 90)),
                    x = cos(i) * radius,
                    y = -sin(i) * radius
                )
                [x, y]
        ],
        // Calculate natural extents
        xs = [for (p = unscaled_points) p.x],
        ys = [for (p = unscaled_points) p.y],
        min_x = min(xs),
        max_x = max(xs),
        min_y = min(ys),
        max_y = max(ys),
        natural_width 	= max_x - min_x,
        natural_height 	= max_y - min_y,
        // Determine scaling factor
        scale_factor = 
            // If both max_width and max_height are provided, use the stricter constraint
            is_num(max_width) && is_num(max_height) ?
                min(max_width / natural_width, max_height / natural_height) :
            // If only max_width is provided
            is_num(max_width) ?
                max_width / natural_width :
            // If only max_height is provided
            is_num(max_height) ?
                max_height / natural_height :
                1, // No scaling if neither is provided
        // Scale the points
        scaled_points = [ for (p = unscaled_points) p * scale_factor ],
		bounds	= pointlist_bounds(scaled_points),
		slide 	= [ -bounds[0].x,-bounds[0].y,0 ],
		points 	= center ? scaled_points : move( slide, scaled_points ),
    )
	points;

// Function: dropletWave()
// 
// Synopsis: Calculates the height of a damped sinusoidal wave emanating from a point.
// Topics: Mathematics, Waves, Animation
// Description:
//    Computes the amplitude of a wave at a given radial distance and time, simulating
//    a droplet ripple effect. The wave features configurable amplitude, wavelength,
//    speed, and damping, with a clean cutoff when the wave front hasn't yet reached
//    the point. Ideal for animations or procedural wave patterns.
// Arguments:
//    r         = Radial distance from the wave origin.
//    t         = Time parameter for wave propagation.
//    amplitude = Maximum wave height [default: 1].
//    length    = Wavelength of the wave [default: 10].
//    speed     = Wave propagation speed [default: 5].
//    damping   = Damping factor to reduce amplitude over distance [default: 0.5].
// Returns:
//    The wave height at the specified distance and time, or 0 if the wave hasn't arrived.
// Example(3D,ColorScheme=Nature)
//    // Simple wave at a fixed time
//    t=1;
//    points = [
//       for (r = [0:0.2:10]) 
//          let (h = dropletWave(r, t, amplitude = 10,damping=0.8,speed=5))
//          [r,-h]
//    ];
//    stroke(points, width=0.05);
//	
function dropletWave( r, t, amplitude = 1, length = 10, speed = 5, damping = 0.5 ) =
    // Check if wave has reached this point
    (r > speed * t) ? 0 :
    // Wave calculation with damping
    amplitude * exp(-damping * r) * sin(360 * (r - speed * t) / length);


// Function: clothoid()
//
// Synopsis: Generates a point on a clothoid (Euler spiral) curve.
// Topics: Geometry, Parametric Curves
// See Also: generalizedClothoid()
// Description:
//   Computes the coordinates of a point on a clothoid curve (Euler spiral) based on a parameter t,
//   a radius of curvature r, and a length l. The clothoid is defined using Fresnel integrals
//   approximated by power series, scaled by the clothoid parameter A = sqrt(r * l).
// Arguments:
//   t = Scalar parameter along the curve, typically in the range [0, 1].
//   r = Radius of curvature at the start of the clothoid (in mm).
//   l = Length of the clothoid curve (in mm).
// Example(2D,ColorScheme=Nature)
//   path = [for (t = [0:0.1:1]) clothoid(t, 10, 50)];
//   stroke(path); // Renders a clothoid curve
function clothoid(t, r, l) = 
    let(
        // Clothoid parameter
        A = sqrt(r * l),
        // Parameter along the clothoid
        s = t * l,
        // Scaled parameter for series approximation
        u = s / A,
        // Fresnel integrals approximation (power series)
        C = u * (1 - pow(u, 2)/10 + pow(u, 4)/216),
        S = pow(u, 3)/3 * (1 - pow(u, 2)/14 + pow(u, 4)/336)
    )
    [A * C, A * S];
	


	
	
// Function: generalizedClothoid()
//
// Synopsis: Generates a 2D path for a generalized clothoid curve.
// Topics: Geometry, Parametric Curves, Numerical Integration
// See Also: clothoid()
// Description:
//   Computes a series of points along a generalized clothoid (Euler spiral) curve using numerical integration.
//   The curve is defined by the maximum arc length, curvature derivative, initial curvature, initial angle,
//   and number of points. The x and y coordinates are calculated by integrating the cosine and sine of the
//   orientation angle using the trapezoidal rule.
// Arguments:
//   s_max 			= Maximum arc length of the clothoid curve (in mm).
//   kappa_prime 	= Curvature derivative (rate of change of curvature with respect to arc length, in 1/mm²).
//   kappa_0 		= Initial curvature at the start of the curve (in 1/mm).
//   theta_0 		= Initial orientation angle of the curve (in radians).
//   num_points 	= Number of points to generate along the curve.
// Example(2D,ColorScheme=Nature)
//   path = generalizedClothoid(s_max=50, kappa_prime=0.01, kappa_0=0, theta_0=0, num_points=100);
//   stroke(path); // Renders a generalized clothoid curve
function generalizedClothoid(s_max, kappa_prime, kappa_0, theta_0, num_points) =
    let(
        ds = s_max / num_points,  // Step size for numerical integration
        points = [
            for (i = [0:num_points])
            let(
                s = i * ds,  // Current arc length
                // Integrate from 0 to s using the trapezoidal rule (approximation)
                x = sum([
                    for (j = [0:i])
                    let(
                        tau = j * ds,
                        theta = (1/2) * kappa_prime * tau * tau + kappa_0 * tau + theta_0
                    )
                    ds * cos(theta)
                ]),
                y = sum([
                    for (j = [0:i])
                    let(
                        tau = j * ds,
                        theta = (1/2) * kappa_prime * tau * tau + kappa_0 * tau + theta_0
                    )
                    ds * sin(theta)
                ])
            )
            [x, y]
        ]
    )
    points;

/*
 * Function: ballistic()
 *
 * Synopsis: Calculates a point on a parabolic ballistic curve.
 * Topics: Curves, Trajectories, Mathematics
 * Description:
 *   Computes a 3D point [x, y, z] on a parabolic ballistic trajectory for a given x-coordinate.
 *   The curve is defined by a specified range (total horizontal distance) and maximum height.
 *   The y-coordinate is fixed at 0, and the z-coordinate follows a parabolic profile.
 * Arguments:
 *   x         = X-coordinate for which to compute estilos de puntos en la curva (mm).
 *   range     = Total horizontal range of the trajectory (mm) [default: 4000].
 *   height    = Maximum height of the trajectory at x=0 (mm) [default: 1000].
 * Returns:
 *   A 3D vector [x, 0, z] representing a point on the ballistic curve.
 * Example(3D,ColorScheme=Nature):
 *   path = [for (x = [-2000:100:2000]) ballistic(x, 4000, 1000)];
 *   stroke(path, width=30);
 */
function ballistic(	x, range  = 4000, height = 1000	) = 
	let (
		half_range = range / 2
	) 
	[x ,0, height * (1 - pow(x / half_range, 2) ) ];		
	

	

	
	