include <../src/space.scad>



xdistribute(meters(6)) {

	test_space_with_variables();
	test_space_setting_variables();
	test_space();
	test_attach_walls();
	test_space_opening();
	test_wall_geometry();
}


module test_space_with_variables() {
	
	$space_length 	= 4;
	$space_width 	= 4;
	$space_height 	= 2.8;
	$space_wall		= 400;
	
	space(debug=true); 
}

module test_space_setting_variables() {
	
	space(l=3.1,w=3.2,h=2.8,wall=155) {
		assert($space_length	== 3.1,	str("Wrong space length variable : "	,$space_length	));
		assert($space_width 	== 3.2,	str("Wrong space width variable : "		,$space_width	));
		assert($space_height	== 2.8,	str("Wrong space height variable : "	,$space_height	));
		assert($space_wall 		== 155,	str("Wrong space wall variable : "		,$space_wall	));
	} 
}


module test_space() {

		space(l=2,w=6,h=2.5,debug=true);
}

module test_attach_walls() {
	space(l=6,w=4,h=2.5) {
		attachWalls([FWD]) 		assert($wall_orient == FWD );
		attachWalls([BACK]) 	assert($wall_orient == BACK );
		attachWalls([LEFT]) 	assert($wall_orient == LEFT );
		attachWalls([RIGHT]) 	assert($wall_orient == RIGHT );
	}
}

module test_space_opening() {
	space(l=6,w=4,h=2.5,debug=true) {
		attachWalls([FWD]) {
			//frame_ref(250);
			if (true) placeOpening (
				[LEFT ,CENTER,RIGHT],
				w = 1,
				h = 1.4,
				inset=[200,0],
				debug = false
			) {
				//frame_ref(850);
				//generic_airplane(850);
			}
		}

		attachWalls([BACK]){
			placeOpening (
				[LEFT,CENTER,RIGHT],
				w = 1,
				h = 1.4,
				inset=[200,0],
				debug = true
			){
				//frame_ref(850);
			};
		}
		attachWalls([LEFT]){
			assert($wall_orient == LEFT );
			placeOpening (
				[LEFT,CENTER,RIGHT],
				w = 1,
				h = 1.4,
				inset=[200,0],
				debug = true
			){
				//frame_ref(850);
			};
		}
		attachWalls([RIGHT]){
			placeOpening (
				[LEFT,CENTER,RIGHT],
				w = 1,
				h = 1.4,
				inset=[200,0],
				debug = true
			){
				//frame_ref(850);
			};
		}
	}	
}

module test_wall_geometry() {

	$space_length	= 1;
	$space_width 	= 1;
	$space_height 	= 1;
	$space_wall 	= 100;
	zrot(90) xdistribute(1300) {
		test_wall_geometry_front_right();
		test_wall_geometry_front_left();
		test_wall_geometry_left();
		
		test_wall_geometry_back_left();
		test_wall_geometry_back_right();
		test_wall_geometry_back_front();
		test_wall_geometry_left_right();
	}	

	module test_wall_geometry_front_right() {
		space(debug=true,except=[FRONT,RIGHT]) {


			attachWalls(placement="both")	{
				face = wallGeometry( $wall_orient,$wall_inside );
				back(30)
				//echo ("face",face);
				linear_extrude (50) polygon(face);
			}
		} 
	}	

	module test_wall_geometry_front_left() {
		space(wall=100,debug=true,except=[FRONT,LEFT]) {
			attachWalls(placement="both")	{
				linear_extrude (50) polygon( wallGeometry( $wall_orient,$wall_inside ) );
			}
		} 
	}
	module test_wall_geometry_back_left() {
		space(wall=100,debug=true,except=[BACK,LEFT]) {
			attachWalls(placement="both")	{
				linear_extrude (50) polygon( wallGeometry( $wall_orient,$wall_inside ) );
			}
		} 
	}
	module test_wall_geometry_back_right() {
		space(wall=100,debug=true,except=[BACK,RIGHT]) {
			attachWalls(placement="both")	{
				linear_extrude (50) polygon( wallGeometry( $wall_orient,$wall_inside ) );
			}
		} 
	}
	module test_wall_geometry_back_front() {
		space(wall=100,debug=true,except=[BACK,FRONT]) {
			attachWalls(placement="both")	{
				linear_extrude (50) polygon( wallGeometry( $wall_orient,$wall_inside ) );
			}
		} 
	}
	module test_wall_geometry_left_right() {
		space(wall=100,debug=true,except=[LEFT,RIGHT]) {
			attachWalls(placement="both")	{
				linear_extrude (50) polygon( wallGeometry( $wall_orient,$wall_inside ) );
			}
		} 
	}

	module test_wall_geometry_left() {
		space(debug=true,except=[ LEFT ]) {

			attachWalls(placement="both")	{
				unMutable() {
					face = wallGeometry( $wall_orient,$wall_inside );
					back(80)
					linear_extrude (50) polygon(face);
				}	
			}
		} 
	}	
}



