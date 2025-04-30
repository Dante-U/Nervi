include <../src/roof.scad>
include <../src/space.scad>
include <../src/pillars.scad>

$space_width  	= 2.0;
$space_height	= 2.8;


xdistribute (meters(3)) {

	test_roof_cut_20deg_fwd_around_right();
	test_roof_cut_20deg_fwd_around_left();
	test_roof_cut_20deg_left_around_back();
	test_roof_cut_20deg_left_around_fwd();	
	test_gable_roof();
	test_hipped_roof();
	
	test_hipped_roof_frames_x();
	test_hipped_roof_frames_y();
}

module test_roof_cut_20deg_fwd_around_right(){
	space(l=2,w=2,h=3,debug=true) 
		roofCut( angle = 20, rot_axis = FWD,rot_anchor = RIGHT ) simpleRoof();
}
module test_roof_cut_20deg_fwd_around_left(){
	space(l=2,w=2,h=3,debug=true) 
		roofCut( angle = 20, rot_axis = FWD,rot_anchor = LEFT ) simpleRoof();
}

module test_roof_cut_20deg_left_around_back(){
	space(l=2,w=2,h=3,debug=true) 
		roofCut( angle = 20, rot_axis = LEFT,rot_anchor = BACK ) simpleRoof();
}

module test_roof_cut_20deg_left_around_fwd(){
	space(l=2,w=2,h=3,debug=true) 
		roofCut( angle = 20, rot_axis = LEFT,rot_anchor = FWD ) simpleRoof();
}

module test_gable_roof() {
	space(l=2,w=2,h=3,debug=true,info=true) 
		gableRoof(pitch=20, axis=UP, debug=false) 
			//cuboid([10, 8, 5], chamfer=0.5)
	;
}

module test_hipped_roof(){
	space(3,2,2.4,200,debug=true) 
		attach(TOP)
			hippedRoof(pitch=30, debug=true) //show_anchors(300)
				attach("front-slope")
					cuboid([500,500,800],anchor=BOT);
}

module test_hipped_roof_frames_x() {


	space(2,3,2,200,debug=true) 
		attach(TOP)
			hippedRoof(pitch=30, extension=400, debug=false) { //show_anchors(300)
				attach("front-slope")	roofFrame(); 
				attach("back-slope"	) 	roofFrame();
				attach("left-slope"	) 	roofFrame();
				attach("right-slope") 	roofFrame();				
				ridgeBeam();	
				hipsBeam();
	}
}

module test_hipped_roof_frames_y() {


	space(3,2,2,200,debug=true) 
		attach(TOP)
			hippedRoof(pitch=30, extension=400, debug=false) { //show_anchors(300)
				/*
				attach("front-slope")	roofFrame(); 
				attach("back-slope"	) 	roofFrame();
				attach("left-slope"	) 	roofFrame();
				attach("right-slope") 	roofFrame();				
				ridgeBeam();	
				*/
				hipsBeam();
	}
}



