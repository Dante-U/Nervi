include <../src/equipment.scad>




xdistribute(2000) {
	waterTank(d = 1.680	, h = 1 ,$RD = RENDER_SIMPLIFIED, capacity = 2.000, weight = 33.34, info=true);
	waterTank(d = 1.680	, h = 1 ,$RD = RENDER_STANDARD);
	waterTank(d = 1.680	, h = 1 ,$RD = RENDER_DETAILED,material="Polyethylene");
}
