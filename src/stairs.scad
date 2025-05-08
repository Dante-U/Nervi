include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: stairs.scad
//   A library for creating parametric staircases in OpenSCAD, designed for superstructure and interior design.
//   Provides modules for straight, L-shaped, U-shaped, and spiral staircases, with configurable steps, handrails,
//   and materials (wood, metal, masonry). Supports BOSL2 for geometry, attachments, and rendering. Includes
//   a standalone handrail module for custom configurations. Uses meters for large dimensions, millimeters for
//   small ones, with robust assertions for validation.
// Includes:
//   include <stairs.scad>
// FileGroup: Superstructure
// FileSummary: Parametric staircase with handrails
//////////////////////////////////////////////////////////////////////
include <_materials/multi_material.scad>


MOUNT_TYPES = ["standard","flush"];


// Module: stairs()
// 
// Synopsis: Creates a parametric staircase with customizable dimensions.
// Topics: Architecture, Stairs, Interior Design
// Description:  
//    Generates a staircase structure with configurable width, rise, run,
//    number of steps, and other properties. Supports different stair types
//    and optional handrails.
// Arguments:  
//    type         		= Type of stairs ("straight", "l_shaped", "u_shaped") (default: "straight").
//    w       	   		= Total width of the staircase in meters (default: 0.9).
//    total_rise   		= Total height of the staircase in meters (required or uses $space_height).
//    l       	   		= Total horizontal length of the staircase in meters (calculated from run*steps if not provided).
//    steps        		= Number of steps (calculated from height/rise if not provided).
//    rise         		= Theoretical Height of each step (default: 170). 
//    run          		= Depth of each step (default: 250).
//    mount				= 
//    family	   		= Material family	
//    thickness    		= Thickness of each step (default: 40).
//    slab_thickness 	= Slab thickness when family is "Masonry" 
//    handrails    		= Include handrails (default: no). Could be empty , [LEFT] or [RIGHT] or both [ LEFT , RIGHT ] 
//    rail_height  		= Height of handrail from step (default: 900).
//    rail_width   		= Width of handrail (default: 40).
//    landing_size 		= Size of landing for L or U shaped stairs (default: width).
//    anchor       		= Attachment anchor point (default: BOTTOM).
//    spin         		= Rotation in degrees (default: 0).
//
// DefineHeader:Returns:  
//    A staircase model with defined dimensions and properties.
// Example(3D,ColorScheme=Tomorrow): Simple Straight Staircase
//   stairs(w=1, total_rise=2800, handrails=[RIGHT]);
// Example(3D,ColorScheme=Tomorrow): L-Shaped Staircase with 15 steps
//   stairs(w=.9, total_rise=2600, type="l_shaped", steps=15);
// Example(3D,ColorScheme=Tomorrow): U-Shaped Staircase without handrails
//   stairs(w=1.2, total_rise=3000, type="u_shaped");


//stairs(w=1.2, total_rise=3000, type="straight",debug=true,anchor=BOT+LEFT);
//right(800)

/*
include <space.scad>
include <masonry-structure.scad>
space(l=5, w=1.2, h=2.8, wall=200, name="Room", except=[FRONT,LEFT],debug=true)
{
	slab();
	position(RIGHT)
		reddish()
		stairs(w=1.2,type="straight",family="Metal",slab_thickness = 150,anchor=RIGHT);
}

*/	

/*
include <space.scad>
include <masonry-structure.scad>
$space_height	= 0.4;
$space_length	= 0.6;
$space_width	= 1.2;
//$space_width	= 1.2;

space(except=[FRONT,LEFT],debug=true)
{
	slab();
	position(RIGHT)
		reddish()
		stairs(
			w=1.2,
			type="straight",
			family="Wood",
			slab_thickness = 150,
			mount="standard",
			//mount="flush",
			anchor=RIGHT
		);
}
back (1500) 
space(except=[FRONT,LEFT],debug=true)
{
	slab();
	position(RIGHT)
		reddish()
		stairs(
			w=1.2,
			type="straight",
			family="Masonry",
			slab_thickness = 150,
			mount="standard",
			//mount="flush",
			anchor=RIGHT
		);
}
*/


module stairs(
    type 		= "straight",
	w  			= first_defined([is_undef(w) 			? undef : w ,$thread_width			]),
	total_rise  = first_defined([is_undef(total_rise) 	? undef : total_rise ,$space_height	]),
    l,
    steps,
	family		= "Wood",	
    rise 		= 170,
    run 		= 250,
    thickness 	= 40,
	slab_thickness, 
    handrails 	= [],	/// Array: [RIGHT], [LEFT], or [RIGHT, LEFT]
    rail_height = 900,
    rail_width 	= 40,
    landing_size,
    anchor 		= BOTTOM,
	mount 		= "standard", // Could be standard or flush mount  
	material,
    spin 		= 0,
	debug 		= false,
) {

    assert(is_meters(total_rise), 					"[stairs] [total_rise] parameter is undefined. Provide height or define variable $room_height");
	assert( mount == "flush" || mount == "standard" || is_undef(mount),	"[stairs] 'mount' must be either 'flush' or 'standard'"
	);
	assert(isValidMaterialFamilies(family),			"[stairs] family (material) must be 'Wood', 'Metal', or 'Masonry'");
	assert(isValidMaterialFamilies(family),					"[beam] family must be 'Wood', 'Metal', or 'Masonry'");
	
	_total_rise = meters(total_rise);
    _landing 	= landing_size ? landing_size : w;
    _steps 		= steps ? steps : mount == "flush" ? ceil( _total_rise / rise ) : ceil( _total_rise / rise ) -1
				;
	_rise 		= mount == "flush" ? round(_total_rise/(_steps))	: round(_total_rise/(_steps+1))	;
    _run 		= run;
	_w			= meters(w);

	$thread_width		= meters(w);
	$thread_run 		= run;
	$thread_rise 		= _rise;
	$thread_thickness 	= thickness;

	
    _length 	= l ? meters(l) : 
             (type == "straight" ? _run*_steps : 
             (type == "l_shaped" ? _run*ceil(_steps/2) + _landing : 
             (type == "u_shaped" ? _run*ceil(_steps/3) + _landing : _run*_steps)));
	_angle 		= adj_opp_to_ang (_steps * _run,_steps * _rise);
	
	$stairs_angle 			= _angle;
	$stairs_slab_thickness 	= slab_thickness;
	$stairs_material 		= material;
	$stairs_mount 			= mount;
	
    //bounding_size = [ w, _length, _total_rise ];
	bounding_size = [ _length, _w,  _total_rise ];
	
	if (debug) {
		echo ("*********************");
		echo ("**     Stairs      **");
		echo ("*********************");
		echo (str(" - type    :",type	));
		echo (str(" - mount  :",mount	));
		echo (str(" - _total_rise  :",_total_rise	));
		echo (str(" - rise (Theoretical)  :",rise	));
		echo (str(" - steps  :",_steps	));
		echo (str(" - rise (Effective)   :",_rise	));
		echo (str(" - angle   :",_angle	));
	}	
    //
	// module : tread()
	//
	/*
    module tread( w = _w, r= _run, h=_rise, t = thickness,anchor = TOP,spin = 0) {
		echo (str(" _step ; ", "w=",w, " r=",r, " h=",h, " t=",t));
        translate([0, r/2, h]) 
			material("Wood") cuboid([w, r, t], anchor = anchor,spin=spin);
    }
	*/
	
	module landing( anchor = TOP+FRONT ){
		material("Wood") cuboid( [ _landing, _landing, thickness ], anchor=anchor);
	}	
    
    attachable(anchor, spin, orient=UP, size=bounding_size /*, cp=[_length/2*0,-_w/2*0,_total_rise/2*0]*/ ) {
        union() {
			{
				/*****************
				 * Straight
				 *****************/
                if ( type == "straight" ) {
					down( mount == "flush" ? 0 : $thread_rise/2)
					_straightStairs (_steps, family/*,anchor = anchor*/ );
                } else if (type == "l_shaped") {
					/*****************
					 * L Shaped
					 *****************/
				
                    // First straight section
                    half_steps = ceil(_steps/2);
                    for (i = [0:half_steps-1]) 
                        translate([0, i*_run, i*_rise])
                            tread();
                    // Landing
                    translate([
							_w/2-_landing/2, 
							half_steps * _run, 
							//half_steps * _rise + _steps +half_steps
							(half_steps + 1) * _rise // + _steps +half_steps
						])
						landing();
                        //cuboid([_landing, _landing, thickness], anchor=BOTTOM+FRONT);
                    // Second straight section (perpendicular)
					for (i = [0:_steps-half_steps-2]) {
                        translate(
							[
								_w/2*2-_landing/2+(i+1)*_run, // OK
								half_steps*_run - _run/2 , 	// 2 FIX
								(half_steps+i+1)*_rise //+ _steps
							])
								tread( spin=90,anchor=TOP+FRONT+LEFT);
								//cuboid([_run, _landing, thickness], anchor=BOTTOM+LEFT);
                    }
                } else if (type == "u_shaped") {
					/*****************
					 * U Shaped
					 *****************/
				
					//anchor_arrow(500);
					// ************************
                    //  First straight section
					// ************************
                    third_steps = ceil(_steps/3);
					
					echo ("**** third_steps ****",third_steps);
                    for ( n = [0:third_steps-1] ) 
                        translate([0, n * _run, n * _rise])
							tread();
                    // ************************
                    //  First landing
					// ************************
                    translate(
						[
							_w/2 - _landing/2, 
							third_steps*_run, 
							(third_steps+1) * _rise
						]) 
							landing();
							//cuboid( [ _landing, _landing, thickness ], anchor=TOP+FRONT);
                    
					// ************************
                    // Middle straight section 
					//     (perpendicular)
					// ************************
					middle_steps = ceil(_steps/3)-1;
                    for ( i = [ 0 : middle_steps-2 ] ) material("Wood") {
                        translate(
							[
								_w/2 - _landing/2+ (i+2) * _run , 
								third_steps*_run-run/2, 
								(third_steps+i+1)*_rise
							])
							tread( spin=90,anchor=TOP+BACK+LEFT);
                    }
					x1 = (middle_steps-1) * _run;
					//echo ("middle_steps" ,middle_steps);
					// ************************
                    // Second landing
					// ************************
                    translate([
							_w/2+_landing/2 + x1 ,  
							third_steps*_run , 
							(third_steps+middle_steps+1)*_rise *1
						]) 
							landing();
					// ************************
					// Third straight section 
					//   (parallel to first)
					// ************************
					remain_steps = _steps - third_steps - middle_steps - ((mount == "flush") ?  2 : 2);
					for (i = [0:remain_steps]) {
						translate(
						[
							//0+500, 
							_w/2+_landing/2 + x1 ,
							(third_steps-i-1)*_run, 
							(third_steps+middle_steps+i+1)*_rise
						])
							tread(_w, _run, _rise);
					}
                }
                // Add handrails if enabled
				if (len(handrails) > 0) { 
					if (type == "straight") for (side = handrails) _handrail(side);
					
				}
				/*
                if (handrail) {
                    if (type == "straight") {
                        _handrail(RIGHT); // Left side
                        _handrail(LEFT); // Right side
                    } else if (type == "l_shaped") {
                        // Would add more complex handrail logic here
                    } else if (type == "u_shaped") {
                        // Would add more complex handrail logic here
                    }
                }
				*/
            }
        }
        children();
    }
	module _handrail( side=RIGHT ) {
		rail_offset = -side[X] * (-_w/2  +rail_width/2);			 
        if ( type == "straight" ) {
			// ******************
            // * Vertical posts *
			// ******************
            for (i = [0:2:_steps]) material("Aluminium") 
				translate([
							rail_offset, 
							i*_run+rail_width/2, 
							_rise + i* _rise
						])
                    cuboid([rail_width, rail_width, rail_height], anchor=BOTTOM);
			// *******************
            // * Horizontal rail *
			// *******************
			railLength = adj_opp_to_hyp (_length,_total_rise);
			translate(
				[
					rail_offset,
					0,
					_rise + rail_height
				])
			material("Wood")
					xrot(_angle)
						cyl( 
							h		= railLength,
							d		= rail_width,
							orient	= BACK,
							anchor	= BOT
						);
			
        }
        // Similar logic for L and U shaped stairs would go here
    }
}


module _straightStairs( steps, family,anchor ) {
	
	//frame_ref(200);
	
	if ( is_in(family,["Wood","Metal"])) {	
		translate([-steps/2 * $thread_run, 0,-steps/2 * $thread_rise])
			for (i = [0:steps-1])
				let (
					x = i * $thread_run,	
					z = i * $thread_rise,	
				)
				translate([x, 0, z]) tread();		
	}		
	else if (family == "Masonry")	 
	{
		x0 = ang_opp_to_hyp($stairs_angle,$stairs_slab_thickness);
		y0 = ang_adj_to_hyp($stairs_angle,$stairs_slab_thickness);
		path = flatten([
			[ [x0,0],[0,0] ],
			for (i = [0:steps-1])
				let ( 
					x	= i 	* $thread_run,
					y 	= (i+1) * $thread_rise, 
				)
				[ [ x ,y ] , [ x + $thread_run ,y ] ],
			[ [ steps*$thread_run,steps*$thread_rise-y0] ]	
		]);
		material( $stairs_material , default = materialFamilyToMaterial(family))
			extrude($thread_width,dir=FRONT, path=path, anchor=anchor, center=true);
	
	}	
		
}


module tread( 
	w = first_defined([is_undef(w) 	? undef : w ,$thread_width]),
	r = first_defined([is_undef(r) 	? undef : r ,$thread_run]),
	h = first_defined([is_undef(h) 	? undef : h ,$thread_rise]),
	t = first_defined([is_undef(t) 	? undef : t ,$thread_thickness]),
	anchor = TOP,
	spin = 0
) {
	translate([r/2 ,0, h]) cuboid([r, w, t], anchor = anchor,spin=spin);
}


// Module: spiralStairs()
// 
// Synopsis: Creates a parametric spiral staircase.
// Topics: Architecture, Stairs, Interior Design
// Description:  
//    Generates a spiral staircase with configurable dimensions, number of steps,
//    and rotation. Supports optional central column and handrails.
// 
// Arguments:  
//    radius       = Outer radius of the staircase (default: 1000).
//    inner_radius = Inner radius/column radius (default: 150).
//    total_rise   = Total height of the staircase (required or uses $room_height).
//    steps        = Number of steps for a full 360° rotation (default: 16).
//    turns        = Number of turns/rotations (default: 1).
//    ccw          = Counter-clockwise rotation if true (default: false).
//    thickness    = Thickness of each step (default: 40).
//    handrail     = Include handrails (default: true).
//    rail_height  = Height of handrail from step (default: 900).
//    anchor       = Attachment anchor point (default: BOTTOM).
//    spin         = Rotation in degrees (default: 0).
//
// DefineHeader:Returns:  
//    A spiral staircase model with defined dimensions and properties.
// Example(3D,ColorScheme=Tomorrow): Simple Spiral Staircase
//   spiralStairs(radius=1200, total_rise=2800);
// Example(3D,ColorScheme=Tomorrow): Tight Spiral With 1.5 Turns
//   spiralStairs(radius=800, total_rise=3000, turns=1.5, steps=12);
module spiralStairs(
    radius 			= 1000,
    inner_radius 	= 150,
    total_rise		= is_undef($room_height) ? undef : $room_height,
    steps 			= 16,
    turns 			= 1,
    ccw 			= false,
    thickness 		= 40,
	mount 			= "standard", // Could be standard or flush mount  
    handrail 		= true,
    rail_height 	= 900,
    anchor 			= BOTTOM,
    spin 			= 0,
	debug 			= false,
) {
    assert(!is_undef(total_rise) || is_num(total_rise), 
        "[spiralStairs] Spiral stairs [total_rise] parameter is undefined. You should provide height or define variable $room_height");
    
    total_steps	= ceil(steps * turns);
    step_angle 	= 360 / (steps + (mount == "flush" ? 0 : -1 )) * (ccw ? -1 : 1);
    step_rise 	= total_rise / total_steps;
	bounding_size = [radius*2, radius*2, total_rise];
	if (debug) {
		echo ("**************************");
		echo ("**     Spiral Stairs    **");
		echo ("**************************");	
		echo (str(" - total_steps    :",total_steps	));
		echo (str(" - step_angle     :",step_angle	));
		echo (str(" - step_rise      :",step_rise	));
		echo (str(" - thickness      :",thickness	));
		echo ("**************************");
	}	
    
    module tread(angle, z) {
		echo (str(" step angle:",angle," z : ",z));
		rotate([0, 0, angle])
			pieSlice(angle=360/steps-2, radius=radius, height=thickness,anchor=TOP);
    }
    
    attachable(anchor, spin, orient=UP, size=bounding_size,cp=[0,0,total_rise/2]) {
        union() {
            material("Wood") {
                // Central column
				material("Plaster")
                cylinder(r=inner_radius, h=total_rise);
                // Steps
				for (i = [0:total_steps-(mount == "flush" ? 1 : 2 )]) {
                    translate([0, 0, (i+1 )*step_rise]) tread(i*step_angle, step_rise);
                }
                // Handrail
                if (handrail) {
                    // Vertical posts at regular intervals
                    post_interval = max(1, floor(steps/6));
                    for (i = [0:post_interval:total_steps-1]) {
                        angle = i * step_angle;
                        z = i * step_rise;
                        rotate([0, 0, angle]) 
                            translate([radius-20, 0, z])
                                cylinder(r=10, h=rail_height);
                    }
                    // Helical rail
                    rail_points = [for (i = [0:0.5:total_steps]) 
                        [cos(i*step_angle)*(radius-20), sin(i*step_angle)*(radius-20), i*step_rise+rail_height]];
                    
                    path_sweep(circle(r=10), rail_points);
                }
            }
        }
        children();
    }
}


// Module: handrail()
// 
// Synopsis: Creates a parametric handrail for staircases.
// Topics: Architecture, Stairs, Safety
// See Also: stairs()
// Description:
//    Generates a handrail structure with vertical posts and a horizontal rail,
//    configurable for one or both sides of a staircase. Designed to pair with
//    the stairs() module, supporting straight staircases with plans for L- and
//    U-shaped extensions.
// Arguments:
//    w 			= Width of the staircase in meters (default: 0).
//    total_rise 	= Total height of the staircase (required or uses $room_height).
//    l 	    	= Length of the rail when total_rise is 0 in meters.
//    length 		= Total horizontal length of the staircase (required).
//    steps 		= Number of steps (required).
//    rise 			= Height of each step (default: 170).
//    run 			= Depth of each step (default: 250).
//    sides 		= Sides to place handrails ("LEFT", "RIGHT", or ["LEFT", "RIGHT"]) [default: ["RIGHT"]].
//    rail_height 	= Height of handrail above steps (default: 900).
//    rail_width 	= Width/thickness of handrail and posts (default: 40).
//    post_interval = Max step interval for vertical posts (default: 200 mm ).
//    anchor 		= Attachment anchor point (BOSL2 style) [default: BOTTOM].
//    spin 			= Rotation angle in degrees around Z-axis (BOSL2 style) [default: 0].
// Usage:
//    handrail( w,total_rise,[l],[rise],[run],[sides],mount,[rail_height],[rail_diam],[post_diam],[post_interval],[material_rail],[material_post] );
// Example(3D,ColorScheme=Tomorrow): Handrail on both side
//    include <masonry-structure.scad>
//    slab(l = 2.3, w = 1,anchor = TOP);
//       handrail(w=1, total_rise=1.5, sides=[RIGHT,LEFT],debug = false);
// Example(3D,ColorScheme=Tomorrow): Handrails on left side
//    include <masonry-structure.scad>
//	  slab(l = 2.3, w = 1,anchor = TOP);
//	     handrail(w=1, total_rise=1.5, sides=[LEFT]);
// Example(3D,ColorScheme=Tomorrow): Flat Handrail
//    handrail( l = 2 );
module handrail(
    w 				= 0,
	l				= undef,
    total_rise 		= is_undef( $room_height ) ? 0 : $room_height,
    rise 			= 170,
    run 			= 250,
    sides 			= [CENTER],
	mount 			= "standard", // Could be standard or flush mount  
    rail_height		= 900,
    rail_diam 		= 50,
	post_diam  		= 30,
    post_interval 	= 200, // Should be same as rise when used for a stair	
	material_rail 	= "Pine",
	material_post 	= "Oak",
    anchor 			= BOT,
    spin 			= 0,
	debug 			= false,
) {
    // Input validation
	assert(is_def(total_rise) || is_meters(l),	"[handrail] [l] is undefined");
	assert(w==0 || is_meters(w),				"[handrail] [w] is undefined");
    assert(is_num(total_rise), 			"[handrail] total_rise must be a positive number");
	assert(total_rise > 0 || is_num(l), "[handrail] If total rise is 0 then the length should be provided");
    assert(is_num(run) 			&& run > 0, "[handrail] run must be a positive number");
    assert(is_list(sides) 		&& all([for (s = sides) s == LEFT || s == RIGHT|| s == CENTER]), 
									"[handrail] sides must be LEFT, RIGHT, CENTER or a list of both LEFT and RIGHT");
	_w 			= meters( w );
	_total_rise	= meters(total_rise);
	steps = mount == "standard" ? ceil(_total_rise/rise) -1 : ceil(_total_rise/rise);
	_l = _total_rise > 0 ? steps * run : meters( l );
    // Calculate properties
    bounding_size	= [_l,_w,_total_rise + rail_height];
    rail_angle 		= _total_rise > 0 ? adj_opp_to_ang( _l, _total_rise ) : 0 ; // Angle of the rail
    rail_length 	= _total_rise > 0 ? adj_opp_to_hyp( _l, _total_rise ) : _l; // Hypotenuse length of rail
	
	//post_count = (_l / post_interval) +1; 
	post_count = ceil(_l / post_interval) +1; 
	post_rise  = _total_rise / ( post_count - 1 );
	effective_post_interval = _l / post_count;
	echo ( "effective_post_interval",	effective_post_interval );
	echo ( "post_count",	post_count );
	echo ( "post_rise",	post_rise );
	echo ( "rail_angle",	rail_angle );

	attachable(anchor=anchor, spin=spin, orient=UP, size=bounding_size /*, cp=[0, length/2, total_rise/2] */) {
        union() { // Pine color (BurlyWood)
			if (debug) ghost() cuboid(bounding_size);
            for (side = sides) {
				//side_offset = -(( side[X] * _w/2 ) - rail_width / 2); 
				side_offset = (_w/2 - rail_diam / 2) * side[X];
				// Posts
				translate([0,side_offset,-bounding_size[Z]/2])
					xcopies ( n=post_count,l = _l - post_diam  ) {
							up( $idx * post_rise )
							material(material_post)
								cyl (d=post_diam,h=rail_height,anchor=BOT);
					}			
                // Horizontal rail (angled to match stairs)
				translate([-bounding_size[X]/2, side_offset * 1, -bounding_size[Z]/2+rail_height])
                    yrot(-rail_angle)
						material(material_rail)
							cyl(h=rail_length, d=rail_diam, orient=RIGHT, anchor=BOT);
            }
        }
        children(); 
    }
}