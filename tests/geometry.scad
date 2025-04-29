include <../src/_core/geometry.scad>
include <../src/_materials/metal.scad>


test_bounding_size();

module test_bounding_size() {
	path = rect([50,40]);

	//assert_equal(boundingSize(path),[50,40,0],"Bounding size rect failed");	
	
	pipe = pipeProfile(20,2);
	assert_equal(boundingSize(pipe),[20,20,0],"Bounding size pipe failed");	
	
	hss = hssProfile(60,40,5,2);
	assert_equal(boundingSize(hss),[60,40,0],"Bounding size hss failed");	

	corner = cornerProfile(60,40,5,2);
	assert_equal(boundingSize(corner),[60,40,0],"Bounding size corner failed");	
	
	channel = channelProfile(60,40,5,2);
	assert_equal(boundingSize(channel),[60,40,0],"Bounding size channel failed");	
	
	iBeeam = iBeamProfile(60,40,10,5,2);
	assert_equal(boundingSize(iBeeam),[60,40,0],"Bounding size iBeeam failed");	
}
