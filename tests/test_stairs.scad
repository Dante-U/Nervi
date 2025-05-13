include <../src/stairs.scad>
include <../src/masonry-structure.scad>


//test_handrails();

ydistribute(meters(5.2)) {

	test_mount_standard();
	test_mount_flush();

	test_u_shaped(MASONRY);

	test_u_shaped(WOOD);
	
	test_l_shaped(WOOD);
	test_l_shaped(MASONRY);
	test_straight(MASONRY);	
	test_straight(WOOD);	
	test_isValidType();
	test_mountTypes();
	test_tread();
}	


module test_mount_standard() {

	$space_height	= 0.4;
	$space_length	= 0.6;
	$space_width	= 1.2;

	space(except=[FWD,LEFT],debug=true)
	{
		slab();
		position(RIGHT)
			reddish()
			stairs(
				w				= 1.2,
				type			= STRAIGHT,
				family			= MASONRY,
				slab_thickness 	= 150,
				mount			= STANDARD_MOUNT,
				anchor			= RIGHT,
			);
	};

}

module test_mount_flush() {

	$space_height	= 0.4;
	$space_length	= 0.6;
	$space_width	= 1.2;

	space(except=[FWD,LEFT],debug=true)
	{
		slab();
		position(RIGHT)
			reddish()
			stairs(
				w				= 1.2,
				type			= STRAIGHT,
				family			= MASONRY,
				slab_thickness 	= 150,
				mount			= FLUSH_MOUNT,
				anchor			= RIGHT,
			);
	};

}

module test_straight(family=MASONRY) {
	space(l=5, w=1.2, h=2.8, wall=200, except=[FRONT,LEFT],debug=true) {
		slab();
		position(RIGHT)
			reddish()
				stairs(w=1.2,type=STRAIGHT,family=family,slab_thickness=150,anchor=RIGHT);
	};  

}

module test_l_shaped(family=MASONRY) {
	space(l=5, w=1.2, h=2.8, wall=200, except=[FRONT,LEFT],debug=true) {
		slab();
		position(LEFT+BACK)
			reddish()
				stairs(w=1.2,type=L_SHAPED,family=family,slab_thickness=150,anchor=LEFT+BACK);
	};  
}

module test_u_shaped(family=MASONRY) {
	space(l=5, w=3.2, h=2.8, wall=200, except=[FRONT,LEFT],debug=true) {
		slab();
		position(LEFT+BACK)
			reddish()
				stairs(w=1.2,type=U_SHAPED,family=family,slab_thickness=150,anchor=LEFT+BACK);
	};  
}


module test_handrails() {
	ydistribute(2000) {

		slab(l = 2.3, w = 1,anchor = TOP)
			handrail(w=1, total_rise=1.5, sides=[RIGHT,LEFT],debug = false);

		slab(l = 2.3, w = 1,anchor = TOP)
				handrail(w=1, total_rise=1.5, sides=[LEFT]);
		
		slab(l = 2.3, w = 1,anchor = TOP)
				handrail(w=1, total_rise=1.5, sides=[RIGHT]);	

		slab(l = 2.3, w = 1,anchor = TOP)			
			handrail( l = 2 );
	}		
}

module test_isValidType() {
	assert (isValidType(STRAIGHT));
	assert (isValidType(L_SHAPED));
	assert (isValidType(U_SHAPED));
	assert (!isValidType(-1));
}		

/*
module test_mountTypes() {
	assert_equal (mountTypes,[ STANDARD_MOUNT, FLUSH_MOUNT ]);
}
*/

module test_mountTypes() {
    types = mountTypes();
    assert(is_list(types), "[test_mountTypes] Output must be a list");
    assert(len(types) == 2, "[test_mountTypes] List should contain 2 mount types");
    assert(types == [STANDARD_MOUNT, FLUSH_MOUNT], "[test_mountTypes] Incorrect mount types");

    // Test: Edge case (ensure constants are defined)
    assert(is_num(STANDARD_MOUNT) && STANDARD_MOUNT == 1, "[test_mountTypes] STANDARD_MOUNT should be 1");
    assert(is_num(FLUSH_MOUNT) && FLUSH_MOUNT == 0, "[test_mountTypes] FLUSH_MOUNT should be 0");
}


module test_tread(){
	tread( w = 800,r = 200,h =180,t=30); 
}


