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
use <_extra/3D.scad>

// Constant: STANDARD_MOUNT
// Description: Stairs standard mount
STANDARD_MOUNT 	= 1;

// Constant: FLUSH_MOUNT
// Description: Stairs flush mount
FLUSH_MOUNT 	= 0;

function mountTypes() = [ STANDARD_MOUNT, FLUSH_MOUNT ];

// Bitwise constants for stair types


// Constant: STRAIGHT
// Description : Straight stairs type
STRAIGHT = 1;  // 001

// Constant: L_SHAPED
// Description : L shaped stairs type
L_SHAPED = 2;  // 010

// Constant: U_SHAPED
// Description : U shaped stairs type
U_SHAPED = 4;  // 100

function isValidType(t) = t == STRAIGHT || t == L_SHAPED || t == U_SHAPED;

// Module: stairs()
// 
// Synopsis: Creates a parametric staircase with customizable dimensions.
// Topics: Architecture, Stairs, Interior Design
// Description:  
//    Generates a staircase structure with configurable width, rise, run,
//    number of steps, and other properties. Supports different stair types
//    and optional handrails.
// Arguments:  
//    type         		= Type of stairs (STRAIGHT, L_SHAPED, U_SHAPED) (default: STRAIGHT).
//    w       	   		= Total width of the staircase in meters (default: 0.9).
//    total_rise   		= Total height of the staircase in meters (required or uses $space_height).
//    steps        		= Number of steps (calculated from height/rise if not provided).
//    rise         		= Theoretical Height of each step (default: 170). 
//    run          		= Depth of each step (default: 250).
//    mount				= The mount could be STANDARD_MOUNT or FLUSH_MOUNT
//    family	   		= Material family	
//    thickness    		= Thickness of each step (default: 40).
//    slab_thickness 	= Slab thickness when family is MASONRY 
//    handrails    		= Include handrails (default: no). Could be empty , [LEFT] or [RIGHT] or both [ LEFT , RIGHT ] 
//    rail_height  		= Height of handrail from step (default: 900).
//    rail_width   		= Width of handrail (default: 40).
//    landing_size 		= Size of landing for L or U shaped stairs (default: width).
//    anchor       		= Attachment anchor point (default: BOTTOM).
//    spin         		= Rotation in degrees (default: 0).
//
// DefineHeader:Returns:  
//    A staircase model with defined dimensions and properties.
// Example(3D;Huge): Simple Straight Staircase
//   include <space.scad>
//   include <masonry-structure.scad>
//   space(l=5, w=1.2, h=2.8, except=[FRONT,LEFT],debug=true) {
//      slab();
//      position(RIGHT+TOP) primary()
//         stairs(w=1, handrails=[RIGHT], anchor=RIGHT+TOP);
//   }
// Example(3D;Huge): Simple Straight Staircase in concrete with right handrail
//   include <space.scad>
//   include <masonry-structure.scad>
//   zrot(90) space(l=5, w=1.2, h=2.8, except=[FRONT,LEFT],debug=true) {
//      slab();
//      position(RIGHT+TOP) primary()
//         stairs(w=1, handrails=[RIGHT], family = MASONRY, anchor=RIGHT+TOP);
//   }
// Example(3D;Huge): L-Shaped Staircase 
//   include <space.scad>
//   include <masonry-structure.scad>
//   zrot(90) space(l=4, w=2.7, h=2.8, except=[FRONT,LEFT],debug=true) {
//      slab();
//      position(RIGHT+FRONT+TOP) primary()
//         stairs(w=1, type = L_SHAPED, handrails=[RIGHT], anchor=FRONT+RIGHT+TOP);
//   }
// Example(3D;Huge): L-Shaped Staircase in concrete 
//   include <space.scad>
//   include <masonry-structure.scad>
//   zrot(90) space(l=4, w=2.7, h=2.8, except=[FRONT,LEFT],debug=true) {
//      slab();
//      position(RIGHT+FRONT+TOP) primary()
//         stairs(w=1, type = L_SHAPED, family = MASONRY, handrails=[RIGHT], anchor=FRONT+RIGHT+TOP);
//   }
// Example(3D;Huge): U-Shaped Staircase 
//   include <space.scad>
//   include <masonry-structure.scad>
//   zrot(90) space(l=4, w=2.7, h=2.8, except=[FRONT,LEFT],debug=true) {
//      slab();
//      position(RIGHT+FRONT+TOP) primary()
//         stairs(w=1, type = U_SHAPED, handrails=[RIGHT], anchor=FRONT+RIGHT+TOP);
//   }
// Example(3D;Huge): U-Shaped Staircase in concrete 
//   include <space.scad>
//   include <masonry-structure.scad>
//   zrot(90) space(l=4, w=2.7, h=2.8, except=[FRONT,LEFT],debug=true) {
//      slab();
//      position(RIGHT+BACK+TOP) primary()
//         stairs(w=1, type = U_SHAPED, family = MASONRY, handrails=[RIGHT], anchor=RIGHT+BACK+TOP);
//   }
module stairs(
    type 			= STRAIGHT,
	w  				= first_defined([is_undef(w) 		  ? undef : w ,$thread_width			]),
	total_rise  	= first_defined([is_undef(total_rise) ? undef : total_rise ,is_undef($space_height) ? undef : $space_height	]),
    steps,
	family			= WOOD,	
    rise 			= 170,
    run 			= 250,
    thickness 		= 40,
	slab_thickness 	= 0, 
    handrails 		= [],	/// Array: [RIGHT], [LEFT], or [RIGHT, LEFT]
    rail_height 	= 900,
    rail_width 		= 40,
    landing_size,
    anchor 			= BOTTOM,
	mount 			= STANDARD_MOUNT, // Could be standard or flush mount  
	material,
    spin 			= 0,
	debug 			= false,
) {

    assert(is_meters(total_rise), 				"[stairs] [total_rise] parameter is undefined. Provide height or $room_height");
	assert( is_in(mount,mountTypes()),			"[stairs] 'mount' must be either FLUSH_MOUNT or STANDARD_MOUNT"	);
	assert(isValidMaterialFamilies(family),		"[stairs] family (material) must be 'Wood', 'Metal', or 'Masonry'");
	
	_total_rise = meters(total_rise);
	_w			= meters(w);
	_landing 	= first_defined([landing_size,_w]);
    _steps 		= steps ? steps : mount == FLUSH_MOUNT ? ceil( _total_rise / rise ) : ceil( _total_rise / rise ) -1;
	_rise 		= round( _total_rise / (_steps+ (mount == FLUSH_MOUNT ? 0 : 1)));
	
	$thread_width		= meters(w);
	$thread_run 		= run;
	$thread_rise 		= _rise;
	$thread_thickness 	= thickness;
	
	mount_vertical_shift = mount == FLUSH_MOUNT ? 0 : $thread_rise/2;
	
	sections = 
		let (
			total = _steps,
			half  = ceil(total/2),
			third = ceil(total/3),
		)
		type == L_SHAPED ? [ half	, total-half-1	] : 
		type == U_SHAPED ? [ third  , third-1 		, total - 2 * third  - 1] : 
		[ total ];
	
    _length = sections[0] * run + ( type != STRAIGHT ? _landing : 0 );
	_width  = 
				type == L_SHAPED ? _w 	+ sections[1] * run :		 
				type == U_SHAPED ? _w*2 + sections[1] * run : 
				_w;	// Straight	 
	_angle 		= adj_opp_to_ang (_steps * run,_steps * _rise);
	
	$stairs_angle 			= _angle;
	$stairs_slab_thickness 	= slab_thickness;
	$stairs_material 		= material;
	$stairs_mount 			= mount;
	$stairs_landing 		= _landing;
	$stairs_family 			= family;

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
	
	//origin = [ -size.x/2, (+_width+_w)/2, -size.z/2	];
	origin = [ -size.x/2, +_width /2, -size.z/2	];
    
    attachable( anchor, spin, size=size ) {
		if ( type == STRAIGHT ) {
			/*****************
			 * Straight
			 *****************/
			down( mount_vertical_shift ) 
				_straightStairs (sections[0], family, spin=-90) placeHandrails(handrails);
		} else if (type == L_SHAPED) {
			/*****************
			 * L Shaped
			 *****************/
			translate( origin )  // Move to lower origin
			// Lower stairs
			_straightStairs (sections[0], family , spin= -90, anchor = FWD+BOT+LEFT) placeHandrails(handrails)  
			// ************************
			//  First landing
			// ************************
			position(TOP+BACK) landing(anchor=BOT+FWD)
			// ************************
			// Upper section 
			// ************************
			position(BACK+TOP)
				_straightStairs (sections[1], family , anchor = FWD+BOT,spin=0) placeHandrails(handrails);						
		} else if (type == U_SHAPED) {
			/*****************
			 * U Shaped
			 *****************/
			last_landing    = (sections[0] - sections[2] +1) * run;
			translate( origin )  // Move to lower origin
			// ************************
			//  First straight section
			// ************************
			_straightStairs (sections[0], family , anchor = FWD+BOT+LEFT,spin=-90) 
				placeHandrails(handrails)  
			// ************************
			//  First landing
			// ************************
			position(TOP+BACK) landing(anchor=BOT+FWD) /*up(300) frame_ref(500)*/
			// ************************
			// Middle straight section 
			// ************************
			position(BACK+TOP)
				_straightStairs (sections[1], family , anchor = FWD+BOT) 
					placeHandrails(handrails)  
			// ************************
			//  Second landing
			// ************************
			position(TOP+BACK)	
				landing(anchor=FWD+BOT)
			// ************************
			// Third straight section 
			// ************************								
			position(BACK+TOP)									
				_straightStairs (sections[2], family , anchor = BOT+FWD)
					placeHandrails(handrails)  
			// ************************
			//  Third landing
			// ************************
			position(TOP+BACK)	
				landing(length = last_landing, anchor=BOT+LEFT,spin = 90)  {
				
				
					$handrail_length = last_landing /1000;
					$stairs_rise	 = 0;		
					echo ("$handrail_length",$handrail_length);
					//up(300)
					//frame_ref(500)
					placeHandrails(handrails) ; 
				}	
				
				;	
		}	
        children();
    }
}


module _handrail( side = RIGHT ) {
		rail_offset = -side[X] * (-_w/2  +rail_width/2);			 
        if ( type == STRAIGHT ) {
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

module _straightStairs( steps, family, anchor, spin ) {
	size = [ $thread_width, steps * $thread_run, steps * $thread_rise ];
	$stairs_rise = (steps+1) * $thread_rise / 1000;
	attachable( size = size , anchor = anchor , spin ) {
		material( $stairs_material , default = materialFamilyToMaterial(family))
		if ( is_in(family,[WOOD,METAL]) ) 	
			translate([ 0,-steps/2 * $thread_run, -steps/2 * $thread_rise])
				for (i = [0:steps-1])
					let (
						y = i * $thread_run,	
						z = i * $thread_rise,	
					)
					translate([ 0, y, z]) tread();		
		else if (family == MASONRY)	 
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
			
				extrude($thread_width,dir=LEFT, path=xflip(path),/* anchor=anchor,*/ center=true);
		}	
		children();
	}	
}







module landing( 
		length = first_defined([ is_undef(length) ? undef : length, is_undef($stairs_landing) ? undef : $stairs_landing ]), 
		family = first_defined([ is_undef(family) ? undef : family, is_undef($stairs_family)  ? undef : $stairs_family 	]),
		anchor = TOP,
		spin	
	){
	size = [ length, $thread_width, $thread_rise ];
	attachable (size = size, anchor = anchor, spin = spin ) {
		material( $stairs_material , default = materialFamilyToMaterial(family))
		//material("Wood") 
		cuboid( size );
		zrot(-90)
		children();
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
	translate([0 ,r/2, h]) cuboid([w, r, t], anchor = anchor,spin=spin);
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
//    total_rise   = Total height of the staircase in meters (required or uses $space_height).
//    steps        = Number of steps for a full 360° rotation (default: 16).
//    turns        = Number of turns/rotations (default: 1).
//    ccw          = Counter-clockwise rotation if true (default: false).
//    family	   = Material family	
//    thickness    = Thickness of each step (default: 40).
//    handrail     = Include handrails (default: true).
//    rail_height  = Height of handrail from step (default: 900).
//    anchor       = Attachment anchor point (default: BOTTOM).
//    spin         = Rotation in degrees (default: 0).
//
// DefineHeader:Returns:  
//    A spiral staircase model with defined dimensions and properties.
// Example(3D,Huge): Spiral Staircase in wood
//   include <space.scad>
//   include <masonry-structure.scad>
//   space(l=2, w=2, h=2.8, except=[FRONT,LEFT],debug=true) {
//      slab(); // Ground slab
//      position(RIGHT+BACK+BOT) primary()
//      spiralStairs(
//          family				= WOOD,
//          mount				= STANDARD_MOUNT,
//          guard_diam			= 150,
//          anchor				= RIGHT+BACK,
//      );
//      position(RIGHT+BACK+TOP)
//         slab(l=0.75,w=0.75,anchor=RIGHT+BACK+TOP); // Top platform
//   }
// Example(3D,Huge): Spiral stairs in concreate with handlrail
//   include <space.scad>
//   include <masonry-structure.scad>
//   space(l=2, w=2, h=2.8, except=[FRONT,LEFT],debug=true) {
//      slab(); // Ground slab
//      position(RIGHT+BACK+BOT) primary()
//      spiralStairs(
//          family				= MASONRY,
//          mount				= STANDARD_MOUNT,
//          guard_diam			= 150,
//          anchor				= RIGHT+BACK,
//      );
//      position(RIGHT+BACK+TOP)
//         slab(l=0.75,w=0.75,anchor=RIGHT+BACK+TOP); // Top platform
//   }	
module spiralStairs(
    radius 			= 1000,
    inner_radius 	= 100,
	total_rise  	= first_defined([is_undef(total_rise) ? undef : total_rise ,is_undef($space_height) ? undef : $space_height	]),
    steps 			= 16,
    turns 			= 1,
    ccw 			= false,
    thickness 		= 40,
	mount 			= STANDARD_MOUNT, // Could be standard or flush mount  
	family			= WOOD,
    handrail 		= true,
	baluster_diam	= 60,
	guard_diam		= 60,
    rail_height 	= 900,
    anchor 			= BOTTOM,
	material_column,  
	material_tread,  
	material_guard ,  
	material_baluster,
    spin 			= 0,
	debug 			= false,
) {
    //assert(is_num_positive(total_rise), "[spiralStairs] total_rise is invalid");
	assert(is_meters(total_rise), "[spiralStairs] total_rise is invalid");
    
	mount_step 		= mount == FLUSH_MOUNT ? 0 : 1;
	iteration		= ceil( steps * turns );
	_steps          = iteration - mount_step;
	step_angle 		= 360 / (steps - mount_step ) * (ccw ? -1 : 1);
	_h 				= meters(total_rise);
    _rise 			= _h / iteration;
	size 			= [ (radius+guard_diam)*2 , (radius+guard_diam)*2 , _h ];
	_tickness		= family == WOOD ? thickness : _rise;
	precision 		= valueByRendering(simple=1, standard=0.5, detailed=0.8);
	fn 				= valueByRendering(simple=16, standard=32, detailed=64);
	da 				= 20;
    
    module tread( angle ) {
		zrot(angle)
			pieSlice(angle=360/steps+4, radius=radius, height=_tickness, anchor=TOP );
    }

    attachable(anchor, spin, orient=UP, size=size) {
        union() {
			// Central column
			material(material_column,family=family) cylinder(r=inner_radius, h=_h);
			if ( is_in(family,[WOOD,METAL]) ) {	
				material( material_tread, family = family )
					for (i = [ 0:_steps-1 ] ) 
						let ( 
							z = ( i+1 ) * _rise, 
							a = i * step_angle
						)
						up(z) tread( a );
                // Handrail
                if (handrail) {
                    // Vertical posts at regular intervals (steps)
					material( material_baluster, family = family )
					for (i = [ 0 : _steps ]) 
						let (
	                        angle = i * step_angle,
							z = i * _rise,
						)	
						zrot(angle)
                            translate([radius-da, 0, z])
                                cylinder( d = baluster_diam, h = rail_height );
                    // Helical rail
					rail_points = [for (i = [ 0 : precision : _steps ]) 
						let (
							a  = i*step_angle,
							r  = radius-da,
							z  = i*_rise+rail_height
						)
                        [ cos(a)*r, sin(a)*r, z ]
					];
					material( material_guard, family = family )
						path_sweep( circle( d=guard_diam ), rail_points );
                }
			} 
			else if (family == MASONRY)	{
				material( material_column, family = family )
					cylinder( r = inner_radius, h = _h );
				material( material_tread, family = family )
					for (i = [ 0:_steps-1 ] ) 
						let ( 
							z = ( i+1 ) * _rise, 
							a = i * step_angle
						)
						up(z) tread( a );					
				if (handrail) {
					 // Helical rail
					rail_points = [for (i = [ 0 : precision : _steps ]) 
						let (
							a  = i*step_angle,
							r  = radius-da,
							z  = i*_rise+rail_height/2
						)
                        [ cos(a)*r, sin(a)*r, z ]
					];
					material( material_baluster, family = family )
						up(rail_height/2-_rise)
							spiral_sweep(
								rect( [guard_diam,rail_height+_rise ] ), 
								h		= _h, 
								r		= radius+guard_diam/2, 
								turns	= turns, 
								anchor	= BOT,
								$fn		= fn
							);
						
				}	
			} 
        }
        children();
    }
	
	if (debug) {
		echo ("**************************");
		echo ("**     Spiral Stairs    **");
		echo ("**************************");	
		echo (str(" - mount     :", mount== FLUSH_MOUNT ? "Flush" : "Standard"	));
		echo (str(" - mount_step     :", mount_step	));
		echo (str(" - total_rise     :",total_rise," m"	));
		echo (str(" - _steps    :",_steps	));
		echo (str(" - step_angle     :",step_angle	));
		echo (str(" - _rise      :",_rise	));
		echo (str(" - thickness      :",thickness	));
		echo ("**************************");
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
//    sides 		= Sides to place handrails (LEFT, RIGHT,CENTER or [LEFT,RIGHT]) [default: [RIGHT]].
//    rail_height 	= Height of handrail above steps (default: 900).
//    rail_width 	= Width/thickness of handrail and posts (default: 40).
//    post_interval = Max step interval for vertical posts (default: 200 mm ).
//    anchor 		= Attachment anchor point (BOSL2 style) [default: BOTTOM].
//    spin 			= Rotation angle in degrees around Z-axis (BOSL2 style) [default: 0].
// Usage:
//    handrail( w,total_rise,[l],[rise],[run],[sides],mount,[rail_height],[rail_width],[post_diam],[post_interval],[material_rail],[material_post] );
// Example(3D;Huge): Handrail on both side
//    include <masonry-structure.scad>
//    slab(l = 2, w = 1,anchor = TOP) 
//       handrail(l=2, w=1, total_rise=0, sides=[RIGHT,LEFT],anchor=BOT);
// Example(3D;Huge): Handrails on left side
//    include <masonry-structure.scad>
//    slab(l = 2, w = 1,anchor = TOP) 
//       handrail(w=1, l=2, total_rise=0, sides=[LEFT] ,anchor=BOT);
//
module handrail(
    w 				= 0,
	l				= is_undef($handrail_length) ? undef : $handrail_length,
	total_rise 		= first_defined([is_undef($stairs_rise) ? undef : $stairs_rise, is_undef( $space_height ) ? 0 : $space_height ]),
    rise 			= first_defined([is_undef(rise) ? undef : rise , is_undef($thread_rise) ? 170 : $thread_rise	]),
    run 			= first_defined([is_undef(run) 	? undef : run  , is_undef($thread_run) 	? 250 : $thread_run		]),
    sides 			= [RIGHT],
	mount 			= first_defined([is_undef(mount) ? undef : mount , is_undef($stairs_mount) ? STANDARD_MOUNT : $stairs_mount	]),
    rail_height		= 900,
    rail_width 		= 80,
	post_diam  		= 30,
	post_interval 	= first_defined([is_undef(post_interval) ? undef : post_interval , is_undef($thread_run) ? 250 : $thread_run ]),
	slab_thickness	= first_defined([is_undef(slab_thickness) ? undef : slab_thickness , is_undef($stairs_slab_thickness) ? 0 : $stairs_slab_thickness ]),
	family 			= first_defined([is_undef(family) ? undef : family , is_undef($stairs_family) ? WOOD : $stairs_family ]),
	material_rail 	= "Pine",
	material_post 	= "Oak",
    anchor 			,
    spin 			= 0,
	debug 			= false,
) {
    // Input validation
	assert(is_def(total_rise) || is_meters(l),	"[handrail] [l] is undefined");
	assert(w==0 || is_meters(w),				"[handrail] [w] is undefined");
    assert(is_num(total_rise), 					"[handrail] total_rise must be a positive number");
	assert(total_rise > 0 || is_num(l), 		"[handrail] If total rise is 0 then the length should be provided");
    assert(is_num(run) 			&& run > 0, 	"[handrail] run must be a positive number");
    assert(is_list(sides) 		&& all([for (s = sides) s == LEFT || s == RIGHT|| s == CENTER]), "[handrail] side should be LEFT,RIGHT or CENTER");
	_w 			= meters( w );
	_total_rise	= meters(total_rise);
	steps = mount == STANDARD_MOUNT ? ceil(_total_rise/rise) -1 : ceil(_total_rise/rise);
	_l = _total_rise > 0 ? steps * run : meters( l );
    // Calculate properties
    size	= [_l,_w,_total_rise + rail_height];
    rail_angle 		= _total_rise > 0 ? adj_opp_to_ang( _l, _total_rise ) : 0 ; // Angle of the rail
    rail_length 	= _total_rise > 0 ? adj_opp_to_hyp( _l, _total_rise ) : _l; // Hypotenuse length of rail
	
	//post_count = (_l / post_interval) +1; 
	post_count = ceil(_l / post_interval) +1; 
	post_rise  = _total_rise / ( post_count - 1 );
	effective_post_interval = _l / post_count;
	if (debug) {
		echo ( "effective_post_interval",	effective_post_interval );
		echo ( "post_count",	post_count );
		echo ( "post_rise",	post_rise );
		echo ( "rail_angle",	rail_angle );
	}
	attachable(anchor=anchor, spin=spin, orient=UP, size=size /*, cp=[0, length/2, total_rise/2] */) {
        union() { // Pine color (BurlyWood)
			if (debug) ghost() cuboid(size);
            for (side = sides) {
				if ( is_in(family,[WOOD,METAL]) ) {	
					side_offset = (_w/2 - rail_width / 2) * -side.x;
					// Posts
					translate([0,side_offset,-size.z/2])
						xcopies ( n=post_count,l = _l - post_diam  ) {
								up( $idx * post_rise )
								material(material_post)
									cyl (d=post_diam,h=rail_height,anchor=BOT);
						}			
					// Horizontal rail (angled to match stairs)
					translate([-size.x/2, side_offset * 1, -size.z/2+rail_height])
						yrot(-rail_angle)
							material(material_rail)
								cyl(h=rail_length, d=rail_width, orient=RIGHT, anchor=BOT);
				}		
				else if (family == MASONRY)	{	
					side_offset = (_w/2 + rail_width / 2) * -side.x;				
					xOrigin = $thread_run /2*0;
					x0 = ang_opp_to_hyp($stairs_angle,$stairs_slab_thickness);
					y0 = ang_adj_to_hyp($stairs_angle,$stairs_slab_thickness);
					path = total_rise > 0 ? [
						[xOrigin+x0,0],[xOrigin,0] ,
						[xOrigin,rail_height],	
						[steps*$thread_run,steps*$thread_rise+rail_height],	
						[steps*$thread_run,steps*$thread_rise-y0] 	
					] : [
						[0,0], [0,rail_height],
						[_l,rail_height] ,[_l,0] 
					]
					;
					translate([0,side_offset,-size.z/2])
						material( $stairs_material , default = materialFamilyToMaterial(family))
						extrude(rail_width,dir=FWD, path=path,/* anchor=anchor,*/ center=true ,anchor=BOT);
				}
			}	
        }
        children(); 
    }
}


module placeHandrails( sides ) {
	position(BOT) handrail (w = $thread_width/1000,l = $parent_size.x / 1000,sides=sides,spin=90,anchor=BOT);
	children();		

}