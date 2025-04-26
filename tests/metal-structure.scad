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