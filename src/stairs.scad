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

function mountTypes() = ["standard","flush"];

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
//   stairs(w=1, total_rise=2.8, handrails=[RIGHT]);
// Example(3D,ColorScheme=Tomorrow): L-Shaped Staircase with 15 steps
//   stairs(w=.9, total_rise=2.6, type="l_shaped", steps=15);
// Example(3D,ColorScheme=Tomorrow): U-Shaped Staircase without handrails
//   stairs(w=1.2, total_rise=3, type="u_shaped");

//back(2000) color ("Green")stairs(w=1, total_rise=2.8);

//stairs(w=.9, total_rise=2.6, type="l_shaped", steps=15);



include <space.scad>
include <masonry-structure.scad>


//back(meters(0)) l_shaped();
//test_u_shaped( family="Masonry" );


module test_u_shaped( family="Masonry" ) {
	space(l=5, w=1.2, h=2.8, wall=200, except=[FRONT,LEFT],debug=true) {
		slab();
		position(LEFT)
			reddish()
				stairs(w=1.2,type="u_shaped",family=family,slab_thickness=150,anchor=LEFT)
					show_anchors(300)
				
				;
	};  
}




module stairs(
    type 		= "straight",
	w  			= first_defined([is_undef(w) 			? undef : w ,$thread_width			]),
	total_rise  = first_defined([is_undef(total_rise) 	? undef : total_rise ,$space_height	]),
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

    assert(is_meters(total_rise), 				"[stairs] [total_rise] parameter is undefined. Provide height or define variable $room_height");
	assert( is_in(mount,mountTypes()),			"[stairs] 'mount' must be either 'flush' or 'standard'"	);
	assert(isValidMaterialFamilies(family),		"[stairs] family (material) must be 'Wood', 'Metal', or 'Masonry'");
	
	_total_rise = meters(total_rise);
	_w			= meters(w);
    _landing 	= landing_size ? landing_size : _w;
    _steps 		= steps ? steps : mount == "flush" ? ceil( _total_rise / rise ) : ceil( _total_rise / rise ) -1;
	_rise 		= mount == "flush" ? round(_total_rise/(_steps)) : round(_total_rise/(_steps+1))	;
	
	$thread_width		= meters(w);
	$thread_run 		= run;
	$thread_rise 		= _rise;
	$thread_thickness 	= thickness;
	
	
	mount_vertical_shift = mount == "flush" ? 0 : $thread_rise/2;
	
	sections = 
		let (
			total = _steps,
			half  = ceil(total/2),
			third = ceil(total/3),
		)
		type == "l_shaped" ? [ half	 , total-half-1	] : 
		type == "u_shaped" ? [ third , third-1 		, total - 2 * third  - 1] : 
		[ total ];
	
    _length 	= sections[0] * run + ( type != "straight" ? _landing : 0 );
	_width    = 
				type == "l_shaped" ? _w 	+ sections[1] * run :		 
				type == "u_shaped" ? _w * 2 + sections[1] * run : 
				_w;	// Straight	 
	_angle 		= adj_opp_to_ang (_steps * run,_steps * _rise);
	
	$stairs_angle 			= _angle;
	$stairs_slab_thickness 	= slab_thickness;
	$stairs_material 		= material;
	$stairs_mount 			= mount;
	$stairs_landing 		= is_def(landing_size) ? landing_size : $thread_width;

	size = [ _length, _width, _total_rise ];
	
	
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
	
	origin = [ -size.x/2, (_width-_w)/2, -size.z/2	];
    
    attachable( anchor, spin, size=size ) {
		if ( type == "straight" ) {
			/*****************
			 * Straight
			 *****************/
			down( mount_vertical_shift ) _straightStairs (sections[0], family);
		} else if (type == "l_shaped") {
			/*****************
			 * L Shaped
			 *****************/
			translate( origin )  // Move to lower origin
			// Lower stairs
			_straightStairs (sections[0], family , anchor = LEFT+BOT) 
			// ************************
			//  First landing
			// ************************
			position(TOP+RIGHT)	landing(anchor=LEFT+BOT)
			// ************************
			// Upper section 
			// ************************
			position(FWD+TOP)
				_straightStairs (sections[1], family , anchor = LEFT+BOT,spin=-90) ;						
		} else if (type == "u_shaped") {
			/*****************
			 * U Shaped
			 *****************/
			last_landing    = (sections[0] - sections[2] +1) * run;
			translate( origin )  // Move to lower origin
			// ************************
			//  First straight section
			// ************************
			_straightStairs (sections[0], family , anchor = LEFT+BOT) 
			// ************************
			//  First landing
			// ************************
			position(TOP+RIGHT)
				landing(anchor=LEFT+BOT)
			// ************************
			// Middle straight section 
			// ************************
			position(FWD+TOP)
				_straightStairs (sections[1], family , anchor = LEFT+BOT,spin=-90) 
			// ************************
			//  Second landing
			// ************************
			position(TOP+RIGHT)	
				landing(anchor=LEFT+BOT)
			// ************************
			// Third straight section 
			// ************************								
			position(TOP+FWD)									
				_straightStairs (sections[2], family , anchor = LEFT+BOT,spin=-90)
			// ************************
			//  Third landing
			// ************************
			position(TOP+RIGHT)	
				landing(length = last_landing, anchor=LEFT+BOT);	
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
							i*run+rail_width/2, 
							_rise + i* _rise
						])
                    cuboid([rail_width, rail_width, rail_height], anchor=BOTTOM);
			// *******************
            // * Horizontal rail *
			// *******************
			railLength = adj_opp_to_hyp (size.x,_total_rise);
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


module _straightStairs( steps, family, anchor, spin ) {
	
	//frame_ref(200);
	size = [ steps * $thread_run, $thread_width, steps * $thread_rise ];
	attachable( size = size , anchor = anchor , spin ) {
		if ( is_in(family,["Wood","Metal"])) {	
			translate([-steps/2 * $thread_run, 0,-steps/2 * $thread_rise])
				for (i = [0:steps-1])
					let (
						x = i * $thread_run,	
						z = i * $thread_rise,	
					)
					//translate([x, 0, z]) tread();		
					translate([x, 0, z]) cached_tread();		
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
				extrude($thread_width,dir=FRONT, path=path,/* anchor=anchor,*/ center=true);
		
		}	
		children();
	}	
		
}

module landing( 
		length = first_defined([ is_undef(length) ? undef : length, $stairs_landing ]), 
		anchor = TOP 
	){
	size = [ length, $thread_width, $thread_rise ];
	attachable (size = size, anchor=anchor) {
		material("Wood") cuboid( size );
		children();
	}
	
}	


module cached_tread() {
	render() tread();
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