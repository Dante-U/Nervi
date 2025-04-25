include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: wood-structure.scad
// Includes:
//   include <wood-structure.scad>
// FileGroup: Superstructure
// FileSummary: Architecture, Building, Project
//////////////////////////////////////////////////////////////////////
//use <_core/3D.scad>
include <_materials/wood.scad>

// Module: studWallFrame()
// 
// Synopsis: Generates a wood-framed wall with vertical studs.
// Topics: Construction, Framing, Geometry
// Description:
//    Creates a parametric wall frame with top and bottom plates and vertical studs,
//    spaced according to standard construction practices (e.g., 16" or 24" on-center).
//    Studs are placed starting from one end, with the last space adjusted to fit the
//    wall length. Uses 2x4 lumber dimensions by default, with options for customization.
// Arguments:
//    l      		= Wall length in m.
//    h      		= Wall height in m .
//    stud_spacing 	= Spacing between studs in mm [default: 406.4 mm (16")].
//    stud_size   	= Stud dimensions [width, depth] in mm [default: [38.1, 88.9] (2x4)].
//    plate_size  	= Plate dimensions [width, depth] in mm [default: [38.1, 88.9] (2x4)].
//
// See Also: stack()
// Example(3D,ColorScheme=Nature)
//    studWallFrame(l=4, h=2.438, stud_spacing=406.4);
// Example(3D,ColorScheme=Nature)
//	  include <spaces.scad>	
//    space (3,1,2,debug=true)
//       attachWalls([FWD],placement="outside") 
//           studWallFrame( stud_spacing=406.4); 
module studWallFrame(
	l       		= first_defined([is_undef(l) ? undef: l ,$wall_length]),
	h       		= first_defined([is_undef(h) ? undef: w ,$wall_height]),
	wall			= is_undef( $space_wall   ) ? 0 : $space_wall,
    stud_spacing 	= 16 * INCH,    // 16" on-center
    stud_size 		= [1.5*INCH, 3.5*INCH],// 2x4 nominal (1.5" x 3.5" actual)
    plate_size 		= [1.5*INCH, 3.5*INCH],// 2x4 for top/bottom plates,
	stud_material  	= "Plywood",
	plate_material 	= "Pine",
	info 			= false,	
	stud_linear_price	= 8,
	plate_linear_price  = 8,
	direction       = LEFT,
	anchor	        = BOT,
	orient,			
	spin	
) {

	dummy1 = 
		assert(!is_undef( l ) || is_num( l ),	"[studWallFrame] [l] parameter is undefined. You should provide length or define variable $space_length")
		assert(!is_undef( h ) || is_num( h ),	"[studWallFrame] [h] parameter is undefined. You should provide height or define variable $space_height");

    assert(stud_spacing > stud_size.x, "Stud spacing must exceed stud width!");

	// Extra length for LEFT+RIGHT orientation 
	extra_length = 0;
	inside_polarity = is_undef($wall_inside) ? 1 : $wall_inside ? -1 : 1; // Extend or retract if inside or outside
	_l = meters(l) + inside_polarity * extra_length ;
	$wall_length = _l / 1000;	
	_h 		= meters(h);
	_dir 	= sign(direction.x);
	
    // Constants
    stud_width 	= stud_size.x;   	// Along wall length (X-axis)
    stud_depth 	= stud_size.y;   	// Wall thickness (Y-axis)
    plate_width = plate_size.x; 	// Along wall length (X-axis)
    plate_depth = plate_size.y; 	// Wall thickness (Y-axis)

    // Calculate stud count and spacing
    num_spaces 	= floor(_l / stud_spacing);
    num_studs 	= num_spaces + 1; // Includes end stud
    last_space 	= _l - (num_spaces * stud_spacing);

	bounding_size = [_l,_h,stud_depth];  
	
	attachable( anchor = anchor, spin=spin, orient = orient,size = bounding_size,cp=[0,0,+stud_depth/2])  {
		
		union() xrot(-90) down(+_h/2){
			//showAxis();
			// Bottom plate
			material(plate_material)
			translate([0, 0, 0])
				cuboid([_l, plate_depth, plate_width],anchor=BOT+BACK /*, anchor=BOTTOM+FRONT+LEFT*/);
			// Top plate
			material(plate_material)
			translate([0, 0, _h - plate_width * 0])
				cuboid([_l, plate_depth, plate_width],anchor=TOP+BACK /*anchor=BOTTOM+FRONT+LEFT*/);
			// Vertical studs
			material(stud_material)
				for (i = [0:num_studs]) 
					let (
						x0 		= _dir * _l/2 -_dir * stud_size.x/2,
						last	= i == num_studs,
						x 		= last ? -x0 : x0 -_dir* i * stud_spacing		
					)
					right(x) up(plate_width) 
						cuboid([stud_width, stud_depth, _h - 2 * plate_width],anchor=BACK+BOT );
		}
		//up(stud_size.y) 
		children();
	}
	if (provideMeta(info)) {
		stud_total_length 	= ceil(_h * num_studs / 1000);
		plate_total_length 	= ceil(_l * 2 / 1000);
		
		
		$meta = [
			["name"				, "Stud wall"],
			["orientation"		, dirAsName($wall_orient)],
			["Materials"		,
					[
						materialSpecs( 
							"Studs",
							price	= stud_linear_price,
							qty		= stud_total_length,
							type	= stud_material
							),
						materialSpecs( 
							"Plates",
							price	= plate_linear_price,
							qty		= plate_total_length,
							type	= plate_material
							)	
	
					]	
				
			],
			["value", stud_linear_price* stud_total_length+ plate_linear_price * plate_total_length ]
		];
		info();
	}	
}

// Module: trunkPlatform()
// 
// Synopsis: Creates a foundational platform supported by vertical and horizontal logs.
// Topics: Furniture, Architecture, Foundations
// Description:
//    Generates a customizable platform for a terrace or timber house floor, supported by vertical logs (trunks)
//    and horizontal beams made of logs. The vertical logs are placed at regular intervals defined by spacing,
//    and horizontal logs span between them to support the deck.
// Arguments:
//    l   = Platform length in meters (default: 2 m). 
//    w   = Platform width in meters (default: 3 m). 
//    h   = Platform height in meters (elevation from ground, default: 0.5m). 
//    spacing       = [x_spacing, y_spacing] Distance between vertical logs in X and Y directions in meters (default: [1, 1] m).
//    log_diam  	= Diameter of the logs (default: 200 mm).
//    anchor        = Anchor point for the module (default: BOT).
//    spin          = Rotation around the Z-axis (optional).
// Side Effects:
//    `$floor_length` is set to the floor length in meters.
//    `$floor_width` is set to the floor width in meters.
// Example(3D,Big,ColorScheme=Nature): Simple 3x2 trunk platform
//   trunkPlatform( l=2, w =3 , h = 0.5, spacing= [1,1], log_diam = 200 );
module trunkPlatform( 
    l	= 3,    
    w	= 2,
    h	= 0.5,
    spacing          	= [1,1],   
    burial_depth_factor = 1.5,   
    beam_dir        	= RIGHT,
    log_diam     		= 150,     
    anchor          	= BOT,
	material			= "Eucalyptus saligna",
	groundedMaterial	= "Tar",
	debug 				= false,
	info,
    spin
) {
	_l = meters( l );
	_w = meters( w );
	_h = meters( h );
	_s = meters(spacing);
    bounding_size = [_l, _w, _h];
    
    $floor_length   = l;
    $floor_width    = w;
    
    burial_depth = burial_depth_factor * _h;
    // Calculate the number of logs in X and Y directions based on spacing
    num_logs_x = ceil(_l / _s[0]) + 1;  // Number of vertical logs along length
    num_logs_y = ceil(_w / _s[1]) + 1;   // Number of vertical logs along width
    
    // Adjust spacing to evenly distribute logs within the platform dimensions
    actual_spacing_x = _l / ( num_logs_x - 1);
    actual_spacing_y = _w / ( num_logs_y - 1);
    
    // Attach the entire structure with BOSL2's attachable
    attachable( anchor = anchor, spin = spin, /*orient=UP,*/ size = bounding_size, cp=[0,0,_h/2]) {
        union() {
            // Ghosted bounding box for reference (optional)
            if ( debug ) ghost() cuboid(size=bounding_size, anchor=BOTTOM);
            // Vertical posts
            grid_copies (size=[_l-log_diam,_w-log_diam],n = [ num_logs_x,num_logs_y ] )
                {
					material("Wood") 
						cylinder(d=log_diam,h=_h-log_diam/2,anchor=BOT);
                    ghost() cylinder( d = log_diam, h = burial_depth , anchor=TOP);
                }
            // Beams
			material("Wood") beams( beam_dir );    
        }
        children();
    }
    module beams(dir) {
        if ( dir == BACK ) 
            xcopies(n=num_logs_x,l=_l-log_diam)
                up(_h)
                    cylinder(d=log_diam,h=_w,orient=dir,anchor=CENTER+FWD);
        else if (dir == RIGHT) 
            ycopies(n=num_logs_y,l=_w-log_diam)
                up(_h)
                    cylinder(d=log_diam,h=_l,orient=dir,anchor=CENTER+LEFT);
    
    }
	if (provideMeta(info)) {
		$meta = [
            ["ifc_class",   "IfcElementAssembly"   ],
		];	
			
	}
}

// Module: joist()
// 
// Synopsis: Creates a floor joist system with rim boards in a specified direction.
// Topics: Geometry, Construction, Flooring
// Description:
//    Generates a joist system consisting of evenly spaced joists and rim boards,
//    aligned along a specified direction (BACK or RIGHT). Joist spacing, section
//    size, and material are customizable, with optional anchoring and coloring.
//    Uses BOSL2 for efficient replication and attachment. Default dimensions can
//    be inherited from global variables `$floor_length` and `$floor_width`.
// Arguments:
//    l 	= Length of the joist system in meters(X-axis if dir=BACK) [default: $floor_length].
//    w 	= Width of the joist system in meteres (Y-axis if dir=BACK) [default: $floor_width].
//    section 	= [height, width] of each joist and rim board in mm [default: [150, 50]].
//    spacing 	= Minimum Center-to-center spacing between joists in mm [default: 400].
//    dir 		= Direction of joist alignment (BACK or RIGHT) [default: BACK].
//    material 	= Material name [default: "Wood"].
//    anchor = Anchor point for positioning (BOSL2 style) [default: BOT].
//    spin = Rotation angle in degrees around Z-axis (BOSL2 style) [default: undef].
// Usage:
//    joist(l=2, w=1, spacing=400, dir=BACK);
// Example(3D,ColorScheme=Nature,NoAxes): Joists along length
//    joist(l=2, w=1, spacing=400, section=[120, 40], dir=BACK);
// Example(3D,ColorScheme=Nature,NoAxes): Joists along width
//    joist(l=2, w=1, spacing=400, section=[150, 50], dir=RIGHT);
module joist(
    l 		= is_undef($floor_length) ? undef : $floor_length,
    w  		= is_undef($floor_width)  ? undef : $floor_width,
    spacing 	= 400,
    dir 		= BACK,
    section 	= [150, 50],
    material 	= "Wood",
    anchor 		= BOT,
    spin
) {
    // Input validation
    assert(is_num(l) && l > 0, "length must be a positive number");
    assert(is_num(w) && w > 0, "width must be a positive number");
    assert(is_num(spacing) && spacing > section[Y], "spacing must be greater than section width");
    assert(dir == BACK || dir == RIGHT, "dir must be BACK or RIGHT");
    assert(is_vector(section, 2) && section[X] > 0 && section[Y] > 0, "section must be a [height, width] vector with positive values");
	
    _l = meters( l );
	_w = meters( w );
	
    // Calculate properties
    bounding_size	= [_l, _w, section[X]];
    joist_count 	= ceil((dir == BACK ? _l : _w) / spacing ) + 1;
    joist_span 		= (joist_count - 1) * spacing -section[Y];

    // BOSL2 attachable for modularity
    attachable(anchor=anchor, spin=spin, size=bounding_size, cp=[0, 0, section[0]/2]) {
		union()
            if (dir == BACK) {
                // Joists along X-axis
				material(material)
					xcopies( n = joist_count, l = _l-section[Y] )
						cuboid([section[Y], section[X], _w - section[Y]*2], orient=BACK, anchor=BACK);
                // Rim boards along Y-axis
				material("Wood2")
					ycopies( n=2, l=_w - section[Y] )
						cuboid([_l, section[Y], section[X]], /*orient=RIGHT,*/ anchor=BOT);
            } else { // dir == RIGHT
				material(material)
					ycopies(n=joist_count, l=_w-section[Y])
						cuboid([section[X], section[Y], _l - section[Y]*2], orient=RIGHT , anchor=RIGHT);
                // Rim boards along X-axis
				material("Wood2")
					xcopies(n=2, l=_l - section[Y])
						cuboid([section[Y], _w, section[X]], /*orient=FWD,*/ anchor=BOT);
            }
        children();
    }
}

// Module: deck()
// 
// Synopsis: Creates a deck with evenly spaced planks in a specified direction.
// Topics: Geometry, Construction, Flooring
// Description:
//    Generates a deck surface composed of rectangular planks (sections) arranged
//    along a specified direction (BACK or RIGHT). Plank spacing and size are
//    customizable, with optional anchoring and coloring. Uses BOSL2 for efficient
//    attachment and replication of planks. Default dimensions can be inherited
//    from global variables `$floor_length` and `$floor_width` if defined.
// Arguments:
//    length 	= Length of the deck in meters (X-axis if dir=BACK, Y-axis if dir=RIGHT) [default: $floor_length].
//    width 	= Width of the deck in meters (Y-axis if dir=BACK, X-axis if dir=RIGHT) [default: $floor_width].
//    section 	= [width, height] of each plank in mm [default: [150, 20]].
//    material 	= Material name [default: "Wood"].
//    gap 		= Spacing between planks in mm [default: 20].
//    dir 		= Direction of plank alignment (BACK or RIGHT) [default: BACK].
//    anchor 	= Anchor point for positioning (BOSL2 style) [default: BOT].
//    color 	= Color of the planks (name or RGB 0-1) [default: "Burlywood"].
//    spin 		= Rotation angle in degrees around Z-axis (BOSL2 style) [default: undef].
// See Also: trunkPlatform()
// Usage:
//    deck(l=1, w=1.5, section=[100, 10], gap=10, dir=BACK);
// Example(3D): Deck with planks along length
//    deck(l=0.6, w=0.3, section=[120, 15], gap=25, dir=BACK, material="Wood");
// Example(3D,NoAxes): Deck with planks along width
//    deck(l=0.6, w=0.3, section=[150, 20], gap=20, dir=RIGHT);
module deck(
    l 		= is_undef( $floor_length ) ? undef : $floor_length,
    w  		= is_undef( $floor_width  ) ? undef : $floor_width,
    section 	= [150, 20],
    gap 		= 20,
    dir 		= BACK,
    anchor 		= BOT,
    material 	= "Wood",
    spin
) {
    // Validate inputs
    assert( is_num(l) && l > 0, "length must be a positive number");
    assert( is_num(w) && w > 0, "width must be a positive number");
    assert( is_vector(section, 2) && section[0] > 0 && section[1] > 0, "section must be a [width, height] vector with positive values");
    assert( gap >= 0, "gap must be non-negative");
    assert( dir == BACK || dir == RIGHT, "dir must be BACK or RIGHT");

	_l = meters( l );
	_w = meters( w );
	
    // Calculate deck properties
    bounding_size = [_l, _w, section[1]];
    plank_count = ceil( ( dir == BACK ? _l : _w) / (section[X] + gap));
    plank_span = ( plank_count - 1 ) * ( section[0] + gap );

    // BOSL2 attachable for modularity and child attachment
    attachable( anchor = anchor, spin = spin, size=bounding_size, cp=[0, 0, section[1]/2] ) {
        //union() 
		material("Wood")
			intersection() 
			{	
				{
				if (dir == RIGHT) 
					ycopies(n=plank_count, l=plank_span)
						cuboid([_l, section[X], section[Y]], anchor=BOT);
				 else // dir == BACK
					xcopies(n=plank_count, l=plank_span)
						cuboid([section[X], _w, section[Y]], anchor=BOT);
				}		
				down (section[Y]/2) 
					cuboid([_l,_w,section[Y] * 2],anchor=BOT); // Gabarit		
			}		
        children();
    }
}

// Module: cladding()
//
// Synopsis: Generates a cladding structure with battens and blades.
// Topics: Construction, Cladding, Geometry
// Description:
//    Creates a cladding system with horizontal or vertical battens and blades,
//    supporting rectangular or custom blade sections. Utilizes BOSL2 for
//    efficient copying and positioning.
// Arguments:
//    l 			= Total length of the cladding in mm [default: 3100].
//    h 			= Total height of the cladding in mm [default: 2200].
//    section 		= [width, depth] or list of 2D points for blade cross-section [default: [60, 15]].
//    spacing 		= Gap between blades in mm [default: 15].
//    batten 		= [width, depth] of battens in mm [default: [50, 30]].
//    battens_spacing = Spacing between battens in mm [default: 600].
//    direction 	= Cladding direction (RIGHT or UP) [default: RIGHT].
//    anchor 		= Anchor point (BOSL2 style) [default: BOT].
//    spin 			= Rotation angle in degrees (BOSL2 style) [default: undef].
//    debug 		= If true, renders ghost geometry [default: false].
// See Also: stack()
// Example(3D,NoAxes): Space with front cladding
//   include <spaces.scad>
//   space(3,2,2.4,debug=true)
//   	attachWalls([FWD],inside=false) 
//         cladding();
//   include <spaces.scad>
//   space(3,1,2.4,debug=true)
//      attachWalls([FWD])
//         studWallFrame() 
//            attach(CENTER)
//               cladding();
module cladding( 
		l          		= is_def($wall_length) ? $wall_length : undef,    
		h		        = is_undef( $wall_height ) ? 0.5 : $wall_height, 
        section         = [60,15],
        spacing         = 15,
        batten          = [50,30],
        battens_spacing = 600,
		blade_material  = "Wood",
		batten_material = "Wood",
        direction       = RIGHT,
		anchor	        = BOT,
		orient,			
		spin,
		info
		
	){
    // Constants and validation
    assert(is_list(section) && (len(section) == 2 || is_path(section, 2)),
           "section must be a 2D vector [width, depth] or a 2D path");
    assert(is_num(spacing) && spacing >= 0, "spacing must be a non-negative number");
	assert(is_num(h) && h >= 0, "h must be a non-negative number");
    assert(is_vector(batten, 2) && all([for (v = batten) is_num(v) && v > 0]),
           "batten must be a 2D vector [width, depth] with positive values");
    assert(direction == RIGHT || direction == UP, "direction must be RIGHT or UP");    
	
	_l= meters(l);
	_h= meters(h);
    
    blade_width = len(section) == 2 ? section[0] : abs(pointlist_bounds(section)[0][0]) + abs(pointlist_bounds(section)[1][0]);
    blade_depth = len(section) == 2 ? section[1] : abs(pointlist_bounds(section)[0][1]) + abs(pointlist_bounds(section)[1][1]);
    
    depth = batten[1] + blade_depth;
	bounding_size = [_l,_h,depth];    	
    _dir = abs(direction[0]) == 1 ? RIGHT : abs(direction[2]) == 1 ? UP : undef;
	// Main geometry		
	attachable( anchor = anchor, spin=spin, orient = orient,size = bounding_size,cp=[0,_h/2*0,depth/2])  {
		xrot(-90) down(_h/2)
		union() {
			//ghost() cuboid( size = bounding_size , anchor=BOTTOM );
            // Determine direction and generate cladding
            if (_dir == RIGHT) {
                batten_count = floor(_l/battens_spacing) +1;
                xcopies(l=_l-batten[0],n=batten_count)
                    batten(l=_h,dir=UP,anchor=BOT+BACK);
                    
                blade_count = floor(_h/(spacing+blade_width)) +1;
                fwd(batten[1])
                    zcopies(l=_h-blade_width,n=blade_count,sp=[-_l/2*0,0,+spacing])
                        render() blade(l=_l,dir=RIGHT,anchor=BACK+RIGHT);
            } else if (_dir == UP) {
                batten_count = floor(_h/battens_spacing) +1;
                zcopies(l=_h-batten[0],n=batten_count,sp=[0,0,batten[0]/2])
                    batten(l=_l,dir=RIGHT,anchor=BACK);
                blade_count = floor(_l/(spacing+blade_width)) +1;
                fwd(batten[1])
                    xcopies(l=_l-blade_width,n=blade_count,sp=[-l/2+blade_width,0,+spacing])
                        render() blade(l=_h,dir=UP,anchor=BACK+BOT);
            
            } else {
                assert(false,"Direction not supported");
            }
		}
		up(section.y+batten.y)
		children();
	}
	// Nested module for battens
    module batten(l,dir,anchor) {
		material( batten_material ) cuboid([batten[0],batten[1],l],orient=dir,anchor=anchor);
    }
    // Nested module for blades
    module blade( l, dir, anchor ) {
		material( blade_material )
        if (len(section) == 2)
            cuboid([batten[0],batten[1],l],orient=dir,anchor=anchor);
        else {
            if (dir == RIGHT)
                left(l/2) 
                    fwd(blade_depth)
                        orient(dir)
                            linear_extrude(l)  polygon(zrot(90,section));
            else                         
                fwd(blade_depth)
                        orient(dir)
                            linear_extrude(l)  polygon(zrot(0,section));
        }    
    }
	if (provideMeta(info)) {
		$meta = [
			["ifc_class",   "IfcCovering"   ],
		];
	}	
}





// Module: vPanels()
// 
// Synopsis: Creates a grid of V-shaped panels between horizontal beams.
// Topics: Structures, Patterns
// Description:
//   Constructs a series of horizontal beams with V-shaped cross-braces between them,
//   arranged in a grid pattern. Each V is formed by two slanted parallelepipeds.
//   The structure is customizable in size, grid density, and material.
// Arguments:
//   length = The total length of the panel structure (in meters). [default: 6]
//   height = The total height of the panel structure (in meters). [default: 3]
//   beam_section = The cross-section [width, depth] of the horizontal beams. [default: [100, 100]]
//   cross_section = The cross-section [width, depth] of the V-shaped cross-braces. [default: [120, 30]]
//   grid = The number of V units in [x, y] directions. [default: [5, 3]]
//   beam_material = Material for the horizontal beams. [default: "Wood2"]
//   blade_material = Material for the V-shaped cross-braces. [default: "Wood"]
//   direction = Direction to orient the structure. [default: RIGHT]
//   anchor = Anchor point for positioning. [default: BOT]
//   orient = Orientation of the structure. [default: UP]
//   spin = Rotation around the orientation axis. [default: 0]
// Example(3D,ColorScheme=Nature)
//   vPanels(l=6, h=4, grid=[5,3]);
module vPanels( 
		l          		= is_def($wall_length) ? $wall_length : undef,    
		h		        = is_undef( $wall_height ) ? 0.5 : $wall_height, 
		beam_section    = [100,100],
        cross_section  	= [120,30],
        grid            = [5,3],
		blade_material  = "Wood",
		beam_material 	= "Wood2",
        direction       = RIGHT,
		anchor	        = BOT,
		orient,			
		spin
	){
	_l= meters(l);
	_h= meters(h);		
	
	material(beam_material)
	ycopies (n=grid[Y]+1,l=_h)
		cuboid([_l,beam_section[X],beam_section[Y]]);
	vSize= [_l/grid[X],_h/grid[Y]];	
	
	// Angle of each plank from vertical
    theta = atan2(vSize[X]/2, vSize[Y]);
	// Bottom position depends on plank thickness and angle
    bottom_half_width = cross_section[X] * cos(theta); // Horizontal contribution of plank width
    base_width = 2 * bottom_half_width; // Total base width (outer edges)	
	material(blade_material)
	grid_copies(n = grid ,spacing = vSize )	{
		mirror_copy([1,0,0])
			up( bipolar($orig) * beam_section[Y] * 1)
				left(base_width/2*1)
				parallelepiped(
					width=base_width,
					height=vSize[Y]+beam_section[X],
					skew=vSize[X]/2-base_width/2,
					depth=cross_section[Y],
					anchor=LEFT
				);
	
	}
}	





module woodSheathing(
	l       		= first_defined([is_undef(l) ? undef: l ,$wall_length]),
	h       		= first_defined([is_undef(h) ? undef: w ,$wall_height]),
	wall			= is_undef( $space_wall   ) ? 0 : $space_wall,
    panel 			= [ 8*FEET, 4*FEET ], // 4x8 ft (1220x2440 mm)
    thickness		= 18,
	material  		= "OSB",
	info 			= false,	
	square_price	= 55,
	unit_price		,//= 160,
	direction       = LEFT,
	anchor	        = BOT,
	numbering 		= true, 
	//density			= 640,
	orient,			
	spin	
) {

	dummy1 = 
		assert(!is_undef( l ) || is_num( l ),	"[studWallFrame] [l] parameter is undefined. You should provide length or define variable $space_length")
		assert(!is_undef( h ) || is_num( h ),	"[studWallFrame] [h] parameter is undefined. You should provide height or define variable $space_height");
		
	_l 		= meters(l) ;
	_h 		= meters(h);
	_dir 	= sign( direction.x );
	_panel 	= is_sheet_oriented_best ([_l,_h],panel) ? panel : [panel.y,panel.x];
	
	sheet_count = sheet_count([_l,_h],_panel);
	rows = sheet_count.x;
	cols = sheet_count.y;
	spacing = 10; //Sheet spacing 
	
	num_planks = _l / panel.y ;
	bounding_size = [_l,_h,thickness];  
	
	shortened_length = _panel.x - ( _panel.x * rows - _l );
	shortened_height = _panel.y - ( _panel.y * cols - _h );
	
	
	
	attachable( anchor = anchor, spin=spin, orient = orient,size = bounding_size /*,cp=[0,_h/2,thickness/2] */)  {
		material( material ) for (u = [0:rows-1]) 
			let (
				y0      = -_h/2 + _panel.y/2,
				x0 		= _dir * _l/2 -_dir* _panel.x/2,
				lastX	= u == rows-1,
				//length 	= !lastX ? _panel.x :  _panel.x - ( _panel.x * rows - _l ),
				length 	= !lastX ? _panel.x : shortened_length,
				x 		=  x0 -_dir* u * _panel.x +_dir * ( !lastX ? 0 : (_panel.x-length)/2  ),  	
				idx 	= numbering ? u+1 : undef
			)
			translate([ x, y0, thickness ]) { // Horizontal Sheathing
				plank(length-spacing, _panel.y-spacing, thickness,index = idx);
				for (v = [ 1 : cols - 1 ]) 
					let (
						lastY  = v == cols-1,
						height = !lastY ? 
							_panel.y :  
							//_panel.y - ( _panel.y * cols - _h ),
							shortened_height,
						y =   !lastY ? 
								v * _panel.y : 
								v * _panel.y - ( !lastY ? 0 : (_panel.y-height)/2  ), 
						idx = v * rows + u +1		
					)
				back( y ) plank(length-spacing,height-spacing, thickness,index = idx);
			}
		children();
	}
	if (provideMeta(info)) {
		assert(num_defined([square_price,unit_price]) == 1, "[woodSheathing] You should define ONE price per unit or sqm2 ");
		density = woodSpecs(material,MATERIAL_DENSITY);
		planks 	= rows * cols;
		price	= first_defined([ unit_price, square_price ]);
		qty 	= is_def( unit_price ) ? planks : mm2_to_m2(panel) * planks;
		value 	= price * qty;
		volume  = mm3_to_m3( [panel.x,panel.y,thickness]) * planks; 
		
		nails_distance = 600;
		perimeters = 
			(cols-1) * (rows -1) * perimeter(_panel)
			+ rows * perimeter([_panel.x,shortened_height])
			+ cols * perimeter([shortened_length,_panel.y])
			;
			
		echo ("perimeters",perimeters);	
		nails = ceil(perimeters / nails_distance);
		
		
		$meta = [
			["name"				, "Wood Sheating"],
			["orientation"		, dirAsName($wall_orient)],
			["Materials"		,
				[
					materialSpecs( 
						"Planks",
						price	= price,
						qty		= qty ,
						type	= material,
						units	= planks
						),
					materialSpecs( 
						"Nails",
						units	= nails
						)						
				]	
			],
			["value"	, value ],
			["volume"	, volume ],
			["weight"	, volume * density ]
		];
		info();
	}	

}


module plank( length,height,thickness,index, rounding = 5 ,material, textSize = 200,textColor = "White" ) {
	cuboid([ length, height, thickness], anchor=CENTER, rounding = rounding );
	if (index)
		color( textColor ) linear_extrude (textSize/10) text (str(index),size = textSize ,valign="center" );
		
}










	
