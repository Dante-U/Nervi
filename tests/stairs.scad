include <../src/stairs.scad>
include <../src/masonry-structure.scad>


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
		