include <../src/wood-structure.scad>
include <../src/spaces.scad>


$currency = "R$";

/*
left(100) cuboid([100,100,80],anchor=BOT);

%cuboid([100,100,30],anchor=BOT)
	stackWall() 
		cuboid([80,80,30],$color="Red")
			stackWall() 
				cuboid([60,60,20],$color="Green")
		
//			stackWall() 
//				cuboid([60,60,10])
		
;
*/


if (true) space (3,2,2,debug=true,except=[FWD,RIGHT]) {
	attachWalls([BACK],placement="inside")
		studWallFrame()
		//show_anchors(300)
		//attach(CENTER)

//		align(TOP,CENTER)
		//left(50)
		//back(150)
		left(50)
		stack()
		cladding()
		showAxis()
		;

	/*	
	attachWalls([LEFT],placement="inside")
		cladding()
		//studWallFrame()
		showAxis();
	*/	
}
;




//studWallFrame(l=4.000, h=2.438, stud_spacing=406.4);


if (false) xdistribute(meters(8)) {

	
	vPanels(l=6, h=4, grid=[5,3]);
	test_cladding_in_space_with_opening();
	test_stud_walls();



}


module test_cladding_in_space_with_opening() {


	$space_length = 4;
	$space_width = 4;
	$space_height = 2.8;
	
	space(debug=true) {
			//applyOpenings([LEFT]);
			
			attachWalls([FWD],inside=false) 
				cladding () {
						placeOpening ([CENTER,RIGHT],w=8,h=1.2,inset=[100,0]){
							echo ("$opening_width",$opening_width);
							echo ("$opening_height",$opening_height);
							//up ($opening_height/2)
							//tag("keep")
							//kneeDoor(opening = 0.9/*,orient=desc_dir()*/);
						}
				
				}			

			attachWalls([LEFT],inside=false) 
				cladding () {
					placeOpening ([LEFT,CENTER,RIGHT],w=0.8,h=1.2,inset=[100,800]) {
						echo ("Create opening door")
						//tag("keep")
						ghost()
							cuboid([meters($opening_width),200,meters($opening_height)],orient=desc_dir(),anchor=CENTER);
					
					}
				
				}
			

			attachWalls([BACK],inside=false) 
				cladding () {
						placeOpening ([LEFT,CENTER,RIGHT],w=0.8,h=1.2,inset=[100,800]);
				
				}				
		}
}



module test_stud_walls() {

	space(l=6,w=4,h=2.5,debug=true) {

		//attachWalls([FWD],inside=false) 
		//	studWallFrame( direction = LEFT);
		//attachWalls(inside=false) 
		attachWalls([FWD],inside=false) 
			studWallFrame( direction = LEFT, info = false) 
				
				//show_anchors(300)
				attach(TOP)
					woodSheathing( info = true );
			
			/*
			{
				woodSheathing();
			}
			*/
			;
			
		
	}
}	



//include <spaces.scad>
//include <doors.scad>


debugging_wood_structure = false;

if (debugging_wood_structure) {



	right(meters(10)) /*orient(UP)*/  
		//diff("opening")
		
	
	if (false) right(meters(25)) /*orient(UP)*/  
		cladding (l=5,h=3,orient=BACK,anchor=UP) //show_anchors(300)
		;



	if (false) ground(5000,5000);
	
//	deck( length = 1, width= 1.5,
//		dir=RIGHT) show_anchors(300);

	{
		$floor_length   = 3;
		$floor_width    = 2;
		cuboid ( [ meters($floor_length),meters($floor_width) , 30 ]) {
			joist() 
				position(TOP)
					deck()
						position(TOP+BACK)
							cladding(l = $floor_length);

		}
	}
	



	if (false) {
	
		joist(l=2,w=1,dir=BACK) show_anchors(100);
		
		fwd (1500)
		
		joist(l=2,w=1,dir=RIGHT) show_anchors(100);
	}


	

	// Render the platform
	if (false)  trunkPlatform() show_anchors(300)
	//	position(TOP) 
	//	joist(dir=BACK) //show_anchors(300);
	//		position(TOP) deck(dir=RIGHT) show_anchors(300)
			;
}	