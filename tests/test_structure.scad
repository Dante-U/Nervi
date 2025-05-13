include <../src/structure.scad>



test_beam();
test_pillar();
test_rectangularFrame();

module test_beam() {
	beam(l=2, section=[50, 100], family=WOOD, material="Oak");
}

module test_pillar() {
	pillar(l=2*2.90,section=[150,150],family=WOOD,anchor=BOT);
}

module test_rectangularFrame() {
	rectangularFrame(oSize=[.4, .4], section=[50, 80]) 
       beam(l=$frame_length, section=$frame_section, family=WOOD);
}

ydistribute(500) {

/*
	beam(l=2, section=[100, 100], family=WOOD, 	material="Oak",info=true);
	beam(l=2, section=[100, 100], family=METAL,	material="Steel", index="B1",info=true);
	beam(l=2, section=[100, 100], family=MASONRY, material="Concrete", info=true, cubic_price=300);
	
	pillar(l=3, section=[200, 200], family=WOOD, material="Oak", info=true, cubic_price=600);
	pillar(l=3, diameter=200, 		family=METAL, material="Steel", index="P1", info=true, cubic_price=2000);
	pillar(l=3, section=[200, 300], family=MASONRY, material="Concrete", info=true, cubic_price=300);
*/
	
	pillar(l=2*2.90,section=[150,150],family=WOOD,anchor=BOT);
	
}