include <_core/main.scad>
/*
include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <BOSL2/skin.scad>

include <_core/utils.scad>
*/


//////////////////////////////////////////////////////////////////////
// LibFile: furniture.scad
// Includes:
//   include <furniture.scad>
// FileGroup: Interior Equipment
// FileSummary: Architecture, Building, Furniture, BIM, Furniture, IfcFurniture
//////////////////////////////////////////////////////////////////////

debugging_furniture = false;


// Function&Module: placeFurniture()
//
// Synopsis: Positions furniture at specified anchor points within a space
// Topics: Interior Systems, Furniture, Positioning, Architecture
// Usage: As a Function
//   shifts = placeFurniture(anchors, inset, vAlign);
// Usage: As a Module
//   placeFurniture(anchors, inset, debug, info ) { children(); }
// Description:
//   As function computes translation vectors to position furniture at specified anchor points within a space,
//   adjusted by an inset and vertical alignment. Uses space dimensions ($space_length, $space_width,
//   $space_height) to calculate positions relative to the space’s bounding box.
//   As module translates child geometry (e.g., furniture) to positions calculated by the placeFurniture function,
//   based on anchor points within a parent space. Supports debugging visualization and stores metadata
//   in $meta for BIM integration.  
// Arguments:
//   anchors 	= Anchor points (vector, string, or list of vectors/strings, e.g., [FRONT, RIGHT]).
//   inset 		= 2D inset [x, y] in mm to offset from edges (default: [0, 0]).
//   vAlign 	= Vertical alignment vector (default: BOT).
// Example(NORENDER):
//   shifts = placeFurniture([FRONT, RIGHT], inset=[100, 100], vAlign=BOT);
//   echo(shifts); // Outputs translation vectors
// Example(3D,Big,ColorScheme=Tomorrow):
//   include <Nervi/space.scad>
//   space(l=3, w=3, h=2, debug=true, except=[FRONT, RIGHT]) {
//     placeFurniture(anchors=[FRONT, RIGHT], inset=[100, 100]) {
//       cuboid([500, 500, 800]); // Chair placeholder
//     }
//   }
function placeFurniture(anchors, inset=[0, 0], vAlign=BOT) =
    assert(is_def(anchors), "[placeFurniture] anchors must be defined (vector, string, or list)")
    assert(is_list(inset) && len(inset)==2 && all_nonnegative(inset), "[placeFurniture] inset must be a 2D list [x, y] with non-negative values")
    assert(is_vector(vAlign), "[placeFurniture] vAlign must be a vector")
    let (
        orient = desc_dir(),
        bounding = meters([$space_length, $space_width, $space_height]) / 2
    )
    [ for (anchor = list_wrap(anchors)) v_mul(bounding - point3d(inset), anchor + vAlign) ];
	
module placeFurniture(anchors, inset=[0, 0], debug=false, info=true ) {
    assert(is_def(anchors), "[placeFurniture] anchors must be defined (vector, string, or list)");
    assert(is_list(inset) && len(inset)==2 && all_nonnegative(inset), "[placeFurniture] inset must be a 2D list [x, y] with non-negative values");
    assert(is_bool(debug), "[placeFurniture] debug must be a boolean");
    assert(is_bool(info), "[placeFurniture] info must be a boolean");

    shifts = placeFurniture(anchors, inset);
    unMutable()
    for (shift = shifts) {
        if (debug) translate(shift) sphere(r=50, $color="Red"); // Debug markers
        translate(shift) children();
    }
}

/*	
module place_furniture2(
    furniture_type = "table",  // Type of furniture (e.g., "table")
    x = 0,                    // X-coordinate in meters
    y = 0,                    // Y-coordinate in meters
    angle = 0,                // Rotation angle in degrees
    material = "Oak",         // Wood material from wood.scad
    length = 2,               // Length in meters (for table)
    width = 0.85,             // Width in meters (for table)
    anchor = "center"         // Anchor point (e.g., "center", "bottom-left")
) {
    // Implementation details
}
*/	
	

// Module: bed()
// 
// Synopsis: Creates a parametric bed with adjustable size and features.
// Topics: Furniture, Bed, Interior Design
// See Also: placeFurniture()
// Description:
//    Generates a customizable bed model with options for type, height, mattress thickness,
//    and cushion placement. Supports predefined bed sizes (King, Single) and custom dimensions.
// Arguments:
//    type      = Predefined bed type ["KingSize", "Single"] (default: "KingSize").
//    height    = Bed frame height (default: 400).
//    materass  = Mattress thickness (default: 250).
//    width     = Custom bed width (default: 700, ignored if type is set).
//    length    = Custom bed length (default: 2000, ignored if type is set).
//    place     = Number of cushions [1 = Single, 2 = Double] (default: 1).
// DefineHeader:Returns:
//    A 3D model of a bed with adjustable size and cushion placement.
// Example(3D,Big,ColorScheme=Tomorrow): King Size bed
//   bed( type = "KingSize" );
// Example(3D,Big,ColorScheme=Tomorrow): Single bed
//   bed( type = "Single" );
// Example(3D,Big,ColorScheme=Tomorrow): Custom size
//   bed( type = "Custom" , width = 800, length = 2100 );
// Example(3D,Big,ColorScheme=Tomorrow): Bed with headboard
//   bed( type = "KingSize", headboard = true );
module bed(
    type      = "KingSize", 
    height    = 400, 
    materass  = 250, 
    width     = 700, 
    length    = 2000, 
    place     = 1,
	headboard = false,
	anchor	  = BACK,
	spin
) {
    // Define standard bed sizes
    bed_sizes = struct_set([], [
        "KingSize", [1830, 2030, 2], 
        "Single",   [700, 2000, 1]  
    ]);
    
    // Fetch bed specs based on type, fallback to custom width/length
    specs = struct_val(bed_sizes, type, default = [width, length, place]);
    bed_width  		= specs[0];
    bed_length 		= specs[1];
    cushion_count 	= specs[2];

    // Cushion specifications
    cushion_size = [700, 450, 150];
	
	bounding_size = [bed_width,bed_length,height];

	tag("keep") attachable(anchor, spin, orient = UP, size = bounding_size)  {
		union() {
			// Base bed frame
			up(height) 
			//material("Wood",deep=false) 
			//color_this("Red")
			cuboid([bed_width, bed_length, 60],$color=matColor("Wood")) {
				
				// Bed legs
				align(BOT, [RIGHT+FRONT, LEFT+FRONT, RIGHT+BACK, LEFT+BACK], inset=50)
					material("Wood")
					cuboid([80, 80, height]);
				
				// Mattress
				align(TOP)
				material("Fabric") 
				cuboid([bed_width, bed_length, materass], rounding=50) {
					// Cushion placement
					if (cushion_count == 2)  {
						align(TOP, [RIGHT+BACK, LEFT+BACK], inset=100)
							material("Fabric") 
							xrot(10) cuboid(cushion_size, rounding=40, $color="orange");
					} else { 
						align(TOP, [BACK], inset=100)
							material("Fabric") 
							xrot(10) cuboid(cushion_size, rounding=40, $color="orange");
					}
				}
				if (headboard)
					align(BACK+TOP)
						xrot(-10)
						translate([0,-100,materass*1.5])
							zcopies(n=2,200) cuboid([bed_width,30,200],rounding=10);
				
			}
		}
		children();
	}	
}
//
// Module: squareTable()
// 
// Synopsis: Creates a square table with customizable size and height based on the number of seats. 
// Topics: Furniture, Tables, Modular Design
// See Also: placeFurniture()
// Description: 
//    This module generates a square table with the ability to specify its dimensions, 
//    height, and the number of people it can seat. It supports customizable sizes 
//    and automatically adjusts based on the selected number of seats.
// Arguments: 
//    length        = Table length 	(default: 2000 mm). 
//    width         = Table width 	(default: 850 mm). 
//    height        = Table height 	(default: 780 mm). 
//    place         = Number of seats for the table (default: undefined, falls back to default size).
// DefineHeader(Generic): Returns:
//    A table with adjustable dimensions and height, suitable for various seat configurations.
//
// Example(3D,Big,ColorScheme=Tomorrow): Table for 12 persons
//   squareTable( place = 12 );	
// Example(3D,Big,ColorScheme=Tomorrow): Custom table size 
//   squareTable( length=2000,width=800 );	
module squareTable (
	length    	= 2000, 
	width  		= 850, 
    height    	= 780, 
    place       = undef, 
) {
    table_sizes = struct_set([], [
		2, [    800,  800],  // Small square table for 2
		4, [   1200,  800],  // Standard 4-person table
		6, [   1800,  900],  // Standard 6-person table
		8, [   2400, 1000],  // Large 8-person table
		10,[  3000, 1100],  // Extra-large 10-person table
		12,[  3600, 1200],  // Banquet-size 12-person table
		14,[  4200, 1300],  // Extended 14-person table
		16,[  4800, 1400]   // Oversized 16-person table
    ]);
	specs = struct_val(table_sizes, place ? place : 0, default = [length, width]);
	 // Create the table top
	up(height) material("Wood") cuboid([specs[0], specs[1], 80], rounding=5, $color="Silver") {
		// Legs
        align(BOT, [RIGHT+FRONT, LEFT+FRONT, RIGHT+BACK, LEFT+BACK], inset=50)
            cuboid([80, 80, height]);
	}
}

// Module: stool()
// 
// Synopsis: Creates a customizable stool with a seat and four legs.
// Topics: Furniture, Stools, Modular Design
// See Also: placeFurniture()
// Description: 
//    This module generates a simple stool with customizable seat dimensions and height.
//    The stool includes a seat and four legs, all adjustable through parameters.
// Arguments: 
//    width    = Stool seat width (default: 400 mm). 
//    depth    = Stool seat depth (default: 400 mm). 
//    height   = Stool height (default: 400 mm). 
// DefineHeader(Generic): Returns:
//    A stool with a seat and four legs.
// Example(3D,Big,ColorScheme=Tomorrow): Simple chair
//   stool();
module stool (
    width    = 400, 
    depth    = 400, 
    height   = 400
) {
    // Create the stool seat
    up(height) material("Wood") {
        cuboid([width, depth, 50], rounding=5, $color="Silver") {
            // Create the legs
            align(BOT, [RIGHT+FRONT, LEFT+FRONT, RIGHT+BACK, LEFT+BACK], inset=0) {
                cuboid([40, 40, height]);  // Leg dimensions
            }
        }
    }
}


// Module: diningChair()
// 
// Synopsis: Creates a customizable dining chair with specified seat dimensions, backrest, and height.
// Topics: Furniture, Chairs, Modular Design
// See Also: placeFurniture()
// Description: 
//    This module generates a dining chair with a customizable width, depth, height, and backrest height.
//    The chair includes a seat, four legs, and a backrest, all configurable through parameters.
// Arguments: 
//    width    = Chair seat width (default: 400 mm). 
//    depth    = Chair seat depth (default: 400 mm). 
//    height   = Chair height (default: 400 mm). 
//    back     = Backrest height (default: 500 mm). 
// DefineHeader(Generic): Returns:
//    A dining chair with a seat, legs, and a backrest.
// Example(3D,Big,ColorScheme=Tomorrow): Simple chair
//   diningChair();	

module diningChair (
    width    = 400, 
    depth    = 400, 
    height   = 400, 
    back     = 500
) {
    // Create the seat
    up(height) {
		material("Wood")
        cuboid([width, depth, 50], rounding=5) { //$color="Silver"
            // Create the legs
            align(BOT, [RIGHT+FRONT, LEFT+FRONT, RIGHT+BACK, LEFT+BACK], inset=0) {
                cuboid([40, 40, height]);  // Leg dimensions
            }
			
            // Create the backrest
            align(TOP, [BACK], inset=0) {
                cuboid([width, 40, back]);  // Backrest dimensions
            }
        }
    }
}

module couch(length,depth = 980,height = 800,users,anchor,spin ) {

	unit_length = 700;
	seat_height = 450;
	thickness 	= 200;
	armrest_width 	= 150;
	armrest_height 	= 700;
	
	back_width 	= 100;
	_length = (users ? users * unit_length : unit_length ) + 2 * armrest_width;

	
	bounding_size = [_length,980,800];
	%material("Fabric") 
	attachable(anchor, spin, orient = UP, size = bounding_size)  {
		union(){
			// Arm rests
			xcopies (_length-armrest_width,n=2)
				cuboid([armrest_width,depth,armrest_height],rounding=30,anchor=BOT);
			// Base
			cuboid([_length-2*armrest_width,depth,seat_height-thickness],rounding=30,anchor=BOT);
			// Back
			back(depth/2-back_width/2)
			cuboid([_length-2*armrest_width,back_width,armrest_height],rounding=30,anchor=BOT);
			// Seats
			up(seat_height-thickness)
				fwd(thickness/2)
				xcopies ((_length-2*armrest_width)/users,n=users)
					cuboid([unit_length,depth-thickness,thickness],rounding=30,anchor=BOT);
			// Back Seats		
			up(seat_height-thickness+depth/3)
				back(thickness*1.8)
				xcopies ((_length-2*armrest_width)/users,n=users)
					xrot(80)
					cuboid([unit_length,depth-thickness*3,thickness],rounding=30,anchor=BOT);
		}
		children();
	}
}




// Module: dresser()
// 
// Synopsis: Creates a dresser
// Topics: Furniture, Dresser
// See Also: placeFurniture()
// Description:
//    Generates a customizable dresser
// Arguments:
//    length        = Dresser length. 
//    depth         = Dresser depth 	(default: 370 mm). 
//    height        = Dresser height. 
//    rows			= Rows
//    cols			= Cols
// DefineHeader:Returns:
//    A 3D model of a dresser
// Example(3D,Big,ColorScheme=Tomorrow): Simple 2 rows 3 columns dresser
//   dresser( rows = 2,cols = 3 );
module dresser( 
		length    ,    
		height    ,
		depth     = 370,
		anchor	  = BOT,
		thickness = 20,
		rows	  = 2,
		cols	  = 2,
		spin
	){
	base_clearing 	= 35;
	
	unit_width 		= 720;
	unit_height 	= height ? (height-base_clearing)/rows : 360;
	legs_section	= 80;
	clearing		= 5;
	
	_length = length ? length : cols * unit_width	;
	_height = height ? height : rows * unit_height	;
	
	bounding_size = [_length,depth,_height];
	
	attachable(anchor, spin, orient = UP, size = bounding_size)  {
		translate([0,-depth/2,0]) 
			rect_tube( 
				size = [ _length,_height ], 
				h = depth, 
				wall = thickness, 
				orient = BACK,
				anchor= BOTTOM,
				$color=matColor("Wood")	
			) {
				// Bed legs
				align(BACK, [RIGHT+BOT,RIGHT+UP,LEFT+BOT,LEFT+UP] , inset=20)
					material("Wood")
						cuboid([legs_section, base_clearing, legs_section]);
						
				//Cells	
				w = unit_width	- 4 * clearing;
				h = unit_height - 4 * clearing;
				dc = 2 * clearing;
				//if (true) up(10) grid_copies(n=[2,2],size=[w,h])
				if (true) up(10) grid_copies(n=[cols,rows],spacing=[w+cols*1*clearing,h+rows * 1*clearing])
					//color_this("Red") 
					material("Fabric") 
						cuboid([ 
							unit_width 	- dc , 
							unit_height - dc , 
							depth ],
							rounding = 5
						);	
			}
		children();
	}

}



// Module: curtain()
//
// Synopsis: Creates a 3D curtain with configurable draping and folds
// Topics: Decoration, Interior, Fabric
// Description:
//   Creates a curtain with customizable width, height, and fold patterns.
//   Simulates fabric draping using sinusoidal waves for a realistic appearance.
//   Can be configured for different hanging styles and fold densities.
//
// Arguments:
//   length    = Total length of the curtain. Default: 200
//   height    = Height of the curtain. Default: 300
//   anchor    = Position anchor for the curtain. Default: TOP
//   spin      = Rotation angle in degrees. Default: 0
//
// Example(3D,ColorScheme = Nature): 2 meters curtain 
//   curtain(length = 2000 );
module curtain( 
			length				= 3000,
			height 				= 2000, 
			fabric_thickness	= 3, 
			pleat_count			= 10, 
			pleat_depth 		= 15, 
			precision			= 6,
			wall_offset			= 100,
			anchor	  			= BOT,
			spin			
		){
	randomsY = rands(0.6,1,pleat_count)	;
	randomsX = rands(0.6,1,pleat_count)	;
	pleat_width = length / pleat_count;	
	shift = 5/6 * pleat_width;
	middle_points = flatten([
		for ( i = [ 0 : pleat_count -1 ] ) [
			bez_tang( [ (randomsX[i] * pleat_width) *0.3 + ( i * shift ), + randomsY[i] * pleat_depth] , 0, pleat_width/5 ),
			bez_tang( [ (randomsX[i] * pleat_width) *0.8 + ( i * shift ), - randomsY[i] * pleat_depth] , 0, pleat_width/5 ),
		]	
	]);
	x = last(flatten(middle_points))[0];
	_length = x+pleat_width / 5;
	handle = pleat_width / 5;
	points = 
		flatten([
			bez_begin([0,0],30,handle),
			flatten(middle_points),
			bez_end([_length,0],-180,handle)    
		]);	
	curve = bezpath_curve(points, splinesteps=precision);

	contour = move([-_length/2,0,0],concat (  
		curve,
		reverse(move([0,fabric_thickness,0],curve)),
		[[0,0]]
		)
	);
	
	
	material("Curtain") tag("keep") attachable(anchor, spin, orient = UP, size = [_length, pleat_depth*2, height],cp=[0*length/2,0,height/2])  {
		//down(height/2) 
		union() {
			//cuboid([length,20,500],anchor=BOT);
			fwd( wall_offset + pleat_depth ) linear_extrude( height ) polygon( contour );
		}	
		children();
	}	
}
// Module: desk()
// 
// Synopsis: Creates a desk 
// Topics: Furniture, Office
// See Also: placeFurniture()
// Description:
//    Generates a customizable desk
//
// Arguments:
//    length        = Desk length 	(default: 1900 mm). 
//    height        = Desk height 	(default: 750 mm). 
//    depth         = Desk depth 	(default: 800 mm). 
//
// Example(3D,Big,ColorScheme=Tomorrow): Simple
//   desk();
module desk( 
		length    = 1900,    
		height    = 750,
		depth     = 800,
		anchor	  = BOT,
		spin	  = 0	
	){
	section = 50;
	bounding_size = [length,depth,height];
	tag("keep") attachable(anchor, spin, orient = UP, size = bounding_size,cp=[0,0,height/2])    {
		union() {
			//ghost() cuboid( size = bounding_size , anchor=BOTTOM );
			up(height) 
				cuboid( size = [length,depth,30] , anchor=TOP, $color=matColor("Wood") ) material("Aluminium") {
					align (BOT,[LEFT,RIGHT])
						cuboid([50,depth,50],rounding=2)
					align (BOT,[LEFT+BACK,RIGHT+BACK])
						cuboid([50,50,height-30-2*section],rounding=2)
							align(BOT,BACK)
								cuboid([section,depth,section],anchor=BACK)
						;
			}
		}
		children();
	}
}

module officeChair( 
		width    	= 550,    
		height    	= 900,
		depth     	= 500,
		seatHeight 	= 500,
		anchor	  	= BOT,
		spin	  	= 0	
	){
	section = 50;
	seatTickness = 80;
	bounding_size = [width,depth,height];
	attachable(anchor, spin, orient = UP, size = bounding_size,cp=[0,0,height/2])  {
		union() {
			//ghost() cuboid( size = bounding_size , anchor=BOTTOM );
			up(seatHeight) 
				// Seat
				cuboid([width,depth,seatTickness],rounding=14,/*except=[TOP,BOTTOM,BACK],*/anchor=TOP,$color=matColor("Fabric") ){
				
					// Back
					align(TOP,BACK)
						fwd(40)
						xrot(-10)
						cuboid([width*0.9,height-seatHeight,100],rounding=14,anchor=TOP,orient=BACK) 
						{
							// Accoudoir
							xrot(10)
							align([RIGHT,LEFT],BACK,inset=100)
								down(0.2*depth)
								cuboid(
									[0.6*depth,50,50]   
									,orient=LEFT
									,chamfer=10
									,$color=matColor("Wood")	
									
								);
						};
					// Support
					align(BOT)
						material("Aluminium")
						cyl(h=(seatHeight-seatTickness) * 0.7 ,d=80) {
							position(BOT) {
								rot_copies(n=5)
									yrot(10)
									cuboid([width*0.5,50,50],anchor=LEFT,rounding=5) {
										position(BOT+RIGHT)
											sphere(d=54,anchor=TOP);
									};
							}
						
						}
			}				
		}
		children();
	}
}

// Module: shelf()
// 
// Synopsis: Creates a parametric furniture
// Topics: Furniture, Shelf
// See Also: placeFurniture()
// Description:
//    Generates a customizable 
//
// Arguments:
//    type      = Predefined bed type ["AAA", "BBB"] (default: "AAA").
//    length        = Table length 	(default: 2000 mm). 
//    width         = Table width 	(default: 850 mm). 
//    height        = Table height 	(default: 780 mm). 
// DefineHeader:Returns:
//    A 3D model of a ...
// Example(3D,Big,ColorScheme=Tomorrow): Simple
//   shelf();
module shelf( 
		width     = 1000,
		depth     = 400,    
		height    = 2000,
		count     = 6,
		anchor	  = BOT,
		spin
	){
	bounding_size = [width,depth,height];
	thickness=20;
	section=[30,20];
	tag("keep") attachable(anchor, spin, orient = UP, size = bounding_size,cp=[0,0,height/2])  {
		union() {
			//ghost() 
			up(height/2)
			zcopies(n=count,l=height-thickness)
				material("Wood") cuboid([width,depth,thickness]); 
			grid_copies(spacing=[width,depth],n=2,)
				material("Aluminium") cuboid([30,20,height],anchor=BOT);
		}
		children();
	}
}
