include <../src/metal-structure.scad>




xdistribute(60) {
	region(pipeProfile(diam=50, wall=5, anchor=CENTER));
	region(cornerProfile(anchor=CENTER));
	region(channelProfile(width=50,height=50,anchor=CENTER));
	region(iBeamProfile(width=50,height=50,rounding=3,anchor=CENTER));	
	region(railProfile(width=50,height=50,rounding=3,anchor=CENTER));
	region(tBeamProfile(width=50,height=50,rounding=2,anchor=CENTER));
	region(hssProfile(width=50,height=50,rounding=2,anchor=CENTER));
}


xdistribute(60) {

	height = 100;

	extrudeMetalProfile("square",
		length 	= 60,
		width 	= 50,
		height 	= 100,
		thickness = 3,
		
	) show_anchors();
	extrudeMetalProfile("pipe",
		length 	  = 60,
		diameter  = 50,
		thickness = 3,
		
	) show_anchors();
	
	extrudeMetalProfile("corner",
		length 	  = 60,
		width  	  = 50,
		height    = 100,
		thickness = 3,
	) show_anchors();

	extrudeMetalProfile("channel",
		length 	= 60,
		width 	= 50,
		height 	= 100,
		thickness = 3,
	) show_anchors();
	extrudeMetalProfile("ibeam",
		length 	= 60,
		width 	= 50,
		height 	= 100,
		web_thickness = 3,
		flange_thickness = 3,
	) show_anchors();
	extrudeMetalProfile("tbeam",
		length 	= 60,
		width 	= 50,
		height 	= 100,
		web_thickness = 3,
		flange_thickness = 3,
	) show_anchors();
}