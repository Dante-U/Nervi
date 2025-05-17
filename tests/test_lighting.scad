include <../src/lighting.scad>
include <../src/space.scad>
include <../src/masonry-structure.scad>


//test_spots();

xdistribute(meters(3)) {
	test_spots();
	test_lightColor();
	test_spots_color_temp();
}



test_spot_specs();



module test_lightColor() {
	xdistribute(400) {
		lightColor(2700) cuboid(300);	
		lightColor(2000) cuboid(300);	
		lightColor(3000) cuboid(300);	
		lightColor(4000) cuboid(300);	
		lightColor(7000) cuboid(300);	
	}	
}


module test_spot_specs() {
	assert_equal( spotSpecs("Small recessed",SPOT_HEIGHT), 0.05);
	assert_equal( spotSpecs("Small recessed",SPOT_ANGLE), 30);
	assert_equal( spotSpecs("Small recessed",SPOT_LUMENS),800);
	assert_equal( spotSpecs("Small recessed",SPOT_WATTAGE), 8);
	assert_equal( spotSpecs("Small recessed",SPOT_TEMP), 2700);
	assert_equal( spotSpecs("Small recessed",SPOT_DIAMETER), 55);
}


module test_spots_color_temp() {
	xdistribute(400) {
	
		spots( type = "Small recessed", ray_h = 2, color_temp  = 2000 );
		spots( type = "Small recessed", ray_h = 2, color_temp  = 2700 );
		spots( type = "Small recessed", ray_h = 2, color_temp  = 3000 );
		spots( type = "Small recessed", ray_h = 2, color_temp  = 4000 );
		spots( type = "Small recessed", ray_h = 2, color_temp  = 5000 );

	}

}






module test_spots() {
	space(l=5,w=3, h=2.8,except=[FRONT,LEFT],debug=true ) {
		slab();	
		position(BACK+TOP)
			spots(count=15 ,spacing=200);
	}
	cuboid([ 3000, 200, 2000 ],anchor=BOT /*,$color=matColor("Plaster")*/) {
		position( TOP+FRONT )
			spots( ray_h = 2, count = 15 ,spacing = 200 );
			//show_anchors(300);
			
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