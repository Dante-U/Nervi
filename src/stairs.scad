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
// Example(3D,ColorScheme=Tomorrow): Simple Straight Staircase
//   stairs(w=1, total_rise=2.8, handrails=[RIGHT]);
// Example(3D,ColorScheme=Tomorrow): L-Shaped Staircase with 15 steps
//   stairs(w=.9, total_rise=2.6, type=L_SHAPED, steps=15);
// Example(3D,ColorScheme=Tomorrow): U-Shaped Staircase without handrails
//   stairs(w=1.2, total_rise=3, type=U_SHAPED);
module stairs(
    type 		= STRAIGHT,
	w  			= first_defined([is_undef(w) 			? undef : w ,$thread_width			]),
	total_rise  = first_defined([is_undef(total_rise) 	? undef : total_rise ,$space_height	]),
    steps,
	family		= WOOD,	
    rise 		= 170,
    run 		= 250,
    thickness 	= 40,
	slab_thickness, 
    handrails 	= [],	/// Array: [RIGHT], [LEFT], or [RIGHT, LEFT]
    rail_height = 900,
    rail_width 	= 40,
    landing_size,
    anchor 		= BOTTOM,
	mount 		= STANDARD_MOUNT, // Could be standard or flush mount  
	material,
    spin 		= 0,
	debug 		= false,
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
		if ( is_in(family,[WOOD,METAL]) ) {	
			//translate([-steps/2 * $thread_run, 0,-steps/2 * $thread_rise])
			translate([ 0,-steps/2 * $thread_run, -steps/2 * $thread_rise])
				for (i = [0:steps-1])
					let (
						y = i * $thread_run,	
						z = i * $thread_rise,	
					)
					translate([ 0, y, z]) tread();		
		}		
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
//    total_rise   = Total height of the staircase (required or uses $space_height).
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
    total_rise		= is_undef($space_height) ? undef : $space_height,
    steps 			= 16,
    turns 			= 1,
    ccw 			= false,
    thickness 		= 40,
	mount 			= STANDARD_MOUNT, // Could be standard or flush mount  
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
	size = [radius*2, radius*2, total_rise];
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
    
    attachable(anchor, spin, orient=UP, size=size,cp=[0,0,total_rise/2]) {
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
//    handrail( w,total_rise,[l],[rise],[run],[sides],mount,[rail_height],[rail_width],[post_diam],[post_interval],[material_rail],[material_post] );
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
	l				= is_undef($handrail_length) ? undef : $handrail_length,
    //total_rise 		=     is_undef( $space_height ) ? 0 : $space_height,
	total_rise 		= first_defined([ is_undef($stairs_rise) ? undef : $stairs_rise, is_undef( $space_height ) ? 0 : $space_height ]),
	
	
    rise 			= first_defined([is_undef(rise) ? undef : rise , is_undef($thread_rise) ? 170 : $thread_rise	]),
    run 			= first_defined([is_undef(run) 	? undef : run  , is_undef($thread_run) 	? 250 : $thread_run		]),
    sides 			= [CENTER],
	mount 			= first_defined([is_undef(mount) ? undef : mount , is_undef($stairs_mount) ? STANDARD_MOUNT : $stairs_mount	]),
    rail_height		= 900,
    rail_width 		= 80,	//50,
	post_diam  		= 30,
	post_interval 	= first_defined([is_undef(post_interval) ? undef : post_interval , is_undef($thread_run) ? 250 : $thread_run ]),
	slab_thickness	= first_defined([is_undef(slab_thickness) ? undef : slab_thickness , is_undef($stairs_slab_thickness) ? 0 : $stairs_slab_thickness ]),
	//family			= WOOD,
	family 			= first_defined([is_undef(family) ? undef : family , is_undef($stairs_family) ? WOOD : $stairs_family ]),
	material_rail 	= "Pine",
	material_post 	= "Oak",
    anchor 			,
    spin 			= 0,
	debug 			= false,
) {

	echo ("handrail + total_rise",total_rise);

    // Input validation
	assert(is_def(total_rise) || is_meters(l),	"[handrail] [l] is undefined");
	assert(w==0 || is_meters(w),				"[handrail] [w] is undefined");
    assert(is_num(total_rise), 					"[handrail] total_rise must be a positive number");
	assert(total_rise > 0 || is_num(l), 		"[handrail] If total rise is 0 then the length should be provided");
    assert(is_num(run) 			&& run > 0, 	"[handrail] run must be a positive number");
    assert(is_list(sides) 		&& all([for (s = sides) s == LEFT || s == RIGHT|| s == CENTER]), 
												"[handrail] sides must be LEFT, RIGHT, CENTER or a list of both LEFT and RIGHT");
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
	echo ( "effective_post_interval",	effective_post_interval );
	echo ( "post_count",	post_count );
	echo ( "post_rise",	post_rise );
	echo ( "rail_angle",	rail_angle );

	attachable(anchor=anchor, spin=spin, orient=UP, size=size /*, cp=[0, length/2, total_rise/2] */) {
        union() { // Pine color (BurlyWood)
			if (debug) ghost() cuboid(size);
            for (side = sides) {
				//side_offset = -(( side[X] * _w/2 ) - rail_width / 2); 
				
				
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

include <space.scad>
//include <Nervi/stairs.scad>
include <masonry-structure.scad>

//handrail( l = 5, total_rise = 2 ) show_anchors(200);

//if (false) 
space(l=5, w=1.2, h=2.8, wall=200, except=[FRONT,LEFT],debug=true)
{
	slab();
	position(RIGHT+BACK+BOT) 
		primary()
		stairs(
			w					= 1.2,
			type				= U_SHAPED,
			//type				= L_SHAPED,
			//type				= STRAIGHT,
			family				= MASONRY,
			//family				= WOOD,
			slab_thickness		= 150,
			anchor				= RIGHT+BACK+BOT,
			handrails			= [RIGHT]
		) //show_anchors(800)
		;
};	


/*
stairs(w=1, total_rise=2.8, handrails=[RIGHT] ,family=MASONRY);
*/


module placeHandrails( sides ) {
	position(BOT) handrail (w = $thread_width/1000,l = $parent_size.x / 1000,sides=sides,spin=90,anchor=BOT);
	children();		

}