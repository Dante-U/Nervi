include <../src/stairs.scad>
include <../src/masonry-structure.scad>


//test_handrails();

ydistribute(meters(5.2)) {

	test_mount_standard();
	test_mount_flush();

	test_u_shaped("Masonry");

	test_u_shaped("Wood");
	
	test_l_shaped("Wood");
	test_l_shaped("Masonry");
	test_straight("Masonry");	
	test_straight("Wood");	
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
				family			= "Masonry",
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
				family			= "Masonry",
				slab_thickness 	= 150,
				mount			= FLUSH_MOUNT,
				anchor			= RIGHT,
			);
	};

}

module test_straight(family="Masonry") {
	space(l=5, w=1.2, h=2.8, wall=200, except=[FRONT,LEFT],debug=true) {
		slab();
		position(RIGHT)
			reddish()
				stairs(w=1.2,type=STRAIGHT,family=family,slab_thickness=150,anchor=RIGHT);
	};  

}

module test_l_shaped(family="Masonry") {
	space(l=5, w=1.2, h=2.8, wall=200, except=[FRONT,LEFT],debug=true) {
		slab();
		position(LEFT+BACK)
			reddish()
				stairs(w=1.2,type=L_SHAPED,family=family,slab_thickness=150,anchor=LEFT+BACK);
	};  
}

module test_u_shaped(family="Masonry") {
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
		