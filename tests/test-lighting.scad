include <../src/lighting.scad>
include <../src/space.scad>
include <../src/masonry-structure.scad>


//test_spots();

xdistribute(meters(3)) {
	test_spots();

}

module test_spots() {
	space(l=5,w=3, h=2.8,except=[FRONT,LEFT],debug=true ) {
		slab();	
		position(BACK+TOP)
			spots(count=15 ,spacing=200);
		position(RIGHT+TOP)
			spots(count=3 , ang=30, spacing=800, spin=90 );
			
	}
}




debugging_light = false;

if (debugging_light) {

	fwd(500) ledStrip(2000) ;

	left(3000)
	diff() 
	
	cuboid([ 2000, 200, 2000 ],anchor=BOT) {
		align(CENTER+FRONT,inside=true,shiftout=10)
			cuboid([1000,120,200]) {
				if (true) align(TOP,BACK,inside=true)
					tag("keep")
					ghost_this()
					ledStrip(800,radius=100,$color="Yellow",anchor=CENTER) show_anchors(100);
					
			
			}
	
	}
		// Ceiling
	right(3000)	
	up(2500)
		ghost() cuboid([2000,1000,2],anchor=BOT+BACK)
			align(BOT)
				pendantLight(type="conic") show_anchors(300)
		;
	

	
}