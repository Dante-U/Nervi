include <../src/equipment.scad>



$mute_info = true; // Mute for test

test_waterTank();
test_waterTank_info();

module test_waterTank() {

	xdistribute(2000) {
		waterTank(d = 1.680	, h = 1 ,$RD = RENDER_SIMPLIFIED, capacity = 2.000, weight = 33.34);
		waterTank(d = 1.680	, h = 1 ,$RD = RENDER_STANDARD);
		waterTank(d = 1.680	, h = 1 ,$RD = RENDER_DETAILED,material="Polyethylene");
	}

}

module test_waterTank_info() {
	waterTank(d = 1.680	, h = 1 ,$RD = RENDER_SIMPLIFIED, capacity = 2.000, weight = 33.34, info=true);

}







