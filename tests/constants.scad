include <../src/_core/constants.scad>

test_rendering_detailed($RD = RENDER_DETAILED);

module test_rendering_detailed() {
	assert_equal( valueByRendering("low","middle","high") , "high" );
	assert_equal( valueByRendering("low","middle") , "middle" ,"Detailed should fallback on standard if detailed is not provided" );
} 

