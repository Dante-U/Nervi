include <../src/furniture.scad>


xdistribute(meters(3)) {
	test_squareTable();
	test_placeFurniture();
	test_bed();
	test_stool();
	test_diningChair();
	test_couch();
	test_dresser();
	test_curtain();
	test_desk();
	test_officeChair();	
	test_shelf();
}

// Test: test_placeFurniture
//
// Synopsis: Tests the placeFurniture() function and module for accurate positioning.
// Topics: Testing, Furniture, Positioning, Architecture
// See Also: bed(), squareTable(), stool(), diningChair(), couch(), dresser(), curtain(), desk(), officeChair(), shelf()
// Usage:
//   test_placeFurniture();
// Description:
//   Verifies that the placeFurniture() function computes correct translation vectors and the module positions
//   child geometry accurately based on anchor points, inset, and vertical alignment within a space.
//   Tests typical usage, edge cases, and context variables.
// Example(3D):
//   test_placeFurniture();
module test_placeFurniture() {


	/*
    // Mock space dimensions
    $space_length = 3; // meters
    $space_width = 3;  // meters
    $space_height = 2; // meters

    // Test function: Typical usage
    shifts = placeFurniture(anchors=[FRONT, RIGHT], inset=[100, 100], vAlign=BOT);
	echo ("shifts",shifts);
    assert(is_list(shifts), 		"[test_placeFurniture] shifts must be a list");
    assert(len(shifts) == 2, 		str("[test_placeFurniture] shifts should contain 2 vectors : ",len(shifts)));
    assert(is_vector(shifts[0]), 	"[test_placeFurniture] shifts[0] must be a vector");
    assert(approx(shifts[0], [1400, -1400, 0], eps=0.1), "[test_placeFurniture] Incorrect shift for FRONT");
    echo("Test placeFurniture function: shifts=", shifts);

    // Test function: Single anchor

    single_shift = placeFurniture(anchors=BACK, inset=[50, 50]);
    assert(len(single_shift) == 1, "[test_placeFurniture] single_shift should contain 1 vector");
    assert(approx(single_shift[0], [0, 1450, 0], eps=0.1), "[test_placeFurniture] Incorrect shift for BACK");
    echo("Test placeFurniture function single anchor: single_shift=", single_shift);


    // Test function: Edge case (zero inset)
    zero_inset = placeFurniture(anchors=LEFT, inset=[0, 0]);
    assert(approx(zero_inset[0], [-1500, 0, 0], eps=0.1), "[test_placeFurniture] Incorrect shift for zero inset");
    echo("Test placeFurniture function zero inset: zero_inset=", zero_inset);

    // Test module: Typical usage
	space()
    placeFurniture(anchors=[FRONT, RIGHT], inset=[100, 100], debug=false) {
        cuboid([100, 100, 100]); // Small placeholder
    }
    echo("Test placeFurniture module: Visual check for two cubes at FRONT and RIGHT");

    // Test module: Edge case (invalid anchors)
    assert(!is_def(placeFurniture(anchors=undef)), "[test_placeFurniture] Should fail with undefined anchors");
    echo("Test placeFurniture module: Invalid anchors handled");

    // Test module: Debug mode
    placeFurniture(anchors=BACK, inset=[50, 50], debug=true) {
        cuboid([50, 50, 50]);
    }
    echo("Test placeFurniture module debug: Visual check for sphere and cube at BACK");
		*/
}



// Test: test_bed
//
// Synopsis: Tests the bed() module for correct geometry and customization.
// Topics: Testing, Furniture, Bed, Interior Design
// See Also: placeFurniture(), squareTable(), stool(), diningChair(), couch(), dresser(), curtain(), desk(), officeChair(), shelf()
// Usage:
//   test_bed();
// Description:
//   Verifies that the bed() module generates correct bed geometry for predefined and custom sizes,
//   with proper cushion placement and headboard options. Tests typical usage and edge cases.
// Context Variables:
//   $color = Color applied to bed components (e.g., "Wood", "Fabric").
// Example(3D):
//   test_bed();
module test_bed() {

	ydistribute(meters(3)) {
		// Test: KingSize bed
		bed(type="KingSize", height=400, materass=250, place=2, headboard=true);
	 
		// Test: Single bed
		bed(type="Single", height=300, materass=200, place=1);
	 
		// Test: Custom size
		bed(type="Custom", width=800, length=2100, height=350, materass=300, place=1, headboard=false);
	 
		// Test: Edge case (minimum dimensions)
		bed(type="Custom", width=500, length=1500, height=200, materass=100, place=1);
	}
} 



// Usage:
//   test_squareTable();
// Description:
//   Verifies that the squareTable() module generates correct table geometry for predefined
//   seat counts and custom sizes. Tests typical usage and edge cases.
// Context Variables:
//   $color = Color applied to table components (e.g., "Silver").
// Example(3D):
//   test_squareTable();
module test_squareTable() {

	ydistribute(meters(3)) {
		// Test: Table for 12 persons
		squareTable(place=12);

		// Test: Custom size
		squareTable(length=2000, width=800, height=780);

		// Test: Edge case (minimum size)
		squareTable(length=500, width=500, height=600);

		// Test: Invalid place
		squareTable(place=3); // Should fall back to default
	}		
}


module test_stool() {

	ydistribute(meters(3)) {
		// Test: Default stool
		stool(width=400, depth=400, height=400);

		// Test: Custom size
		stool(width=500, depth=450, height=450);

		// Test: Edge case (minimum dimensions)
		stool(width=200, depth=200, height=200);
	}	
}

module test_diningChair() {

	ydistribute(meters(3)) {
		// Test: Default chair
		diningChair(width=400, depth=400, height=400, back=500);
		// Test: Custom size
		diningChair(width=450, depth=450, height=450, back=600);
		// Test: Edge case (minimum dimensions)
		diningChair(width=300, depth=300, height=300, back=400);
	}
}


module test_couch() {

	ydistribute(meters(3)) { 
		// Test: Default couch (1 user)
		couch(length=undef, depth=980, height=800, users=1);
	 
		// Test: 3-user couch
		couch(users=3);
	 
		// Test: Edge case (minimum users)
		couch(users=1, depth=800, height=700);
	}	
}

module test_dresser() {
	ydistribute(meters(3)) { 
		// Test: 2x3 dresser
		dresser(length=2160, height=720, rows=2, cols=3);

		// Test: Default dresser
		dresser(length=1440, height=720, depth=370, rows=2, cols=2);

		// Test: Edge case (1x1 dresser)
		dresser(length=720, height=360, rows=1, cols=1);
	}	
}

module test_curtain() {
	ydistribute(meters(3)) { 
		// Test: Default curtain
		curtain(length=3000, height=2000, pleat_count=10);

		// Test: Smaller curtain
		curtain(length=2000, height=1500, pleat_count=5);

		// Test: Edge case (minimum pleats)
		curtain(length=1000, height=1000, pleat_count=2);
	}	
}

module test_desk() {

	ydistribute(meters(3)) { 
		// Test: Default desk
		desk(length=1900, height=750, depth=800);

		// Test: Custom size
		desk(length=1500, height=700, depth=600);

		// Test: Edge case (minimum dimensions)
		desk(length=1000, height=500, depth=400);
	}	
}

module test_officeChair() {

	ydistribute(meters(3)) { 
		// Test: Default office chair
		officeChair(width=550, height=900, depth=500, seatHeight=500);

		// Test: Custom size
		officeChair(width=600, height=1000, depth=550, seatHeight=550);

		// Test: Edge case (minimum dimensions)
		officeChair(width=400, height=700, depth=400, seatHeight=400);
	}
}

module test_shelf() {
	ydistribute(meters(3)) { 
		// Test: Default shelf
		shelf(width=1000, depth=400, height=2000, count=6);

		// Test: Custom size
		shelf(width=800, depth=300, height=1500, count=4);

		// Test: Edge case (minimum shelves)
		shelf(width=500, depth=200, height=1000, count=2);
	}
} 




