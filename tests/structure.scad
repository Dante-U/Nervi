include <../src/structure.scad>

ydistribute(500) {

/*
	beam(l=2, section=[100, 100], material_type="Wood", 	material="Oak",info=true);
	beam(l=2, section=[100, 100], material_type="Metal",	material="Steel", index="B1",info=true);
	beam(l=2, section=[100, 100], material_type="Concrete", material="Concrete", info=true, cubic_price=300);
	
	
	pillar(l=3, section=[200, 200], material_type="Wood", material="Oak", info=true, cubic_price=600);
	pillar(l=3, diameter=200, material_type="Metal", material="Steel", index="P1", info=true, cubic_price=2000);
	pillar(l=3, section=[200, 300], material_type="Concrete", material="Concrete", info=true, cubic_price=300);
*/
	
	pillar(l=2*2.90,section=[150,150],family="Wood",anchor=BOT);
	
}