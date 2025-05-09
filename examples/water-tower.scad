
//
// Torre de agua em eucalipto tratado
//
//

include <Nervi/structure.scad>
include <Nervi/wood-structure.scad>
include <Nervi/masonry-structure.scad>
include <Nervi/_core/distribute.scad>
include <Nervi/equipment.scad>

LITER_PER_DAY_PER_PEOPLE = 175; //150-200 Lire/Day
AUTONOMY = 1.5; // Days  convering defects and maintenance

PILLAR_DIAMETER = 150;

//$RD = RENDER_DETAILED;
$RD = RENDER_SIMPLIFIED;

//
// Synopsis: Calculate consumer in Liters/day total
function waterConsumePerDay (people) = LITER_PER_DAY_PER_PEOPLE * people;

function waterVolumeRequirement ( people , risk = 0.20, autonomy = AUTONOMY) 
	=
	waterConsumePerDay(people) * (1+risk) * autonomy;	

//echo(str("Water consume for 6 people: ",waterConsumePerDay(6)," l/day"));
//echo(str("Tank volumefor 6 people: ",waterVolumeRequirement(6)," liters"));

tower();

// module: tower()
module tower() {

	grid_copies( size=2000, n=2){
		footingPad(l=0.75,w=0.75,thickness = 200,anchor=TOP )
			attach(TOP) 
				pillar(l=2*2.90,diameter=PILLAR_DIAMETER,family="Wood",anchor=BOT) {
								
				
				}
	}	
	
	
	up(meters(1.6)) ycopies( 2050, n=2){
		beam(l=2-0.0250, section=[100, 100], family="Wood", 	material="Oak",info=false);
	}
	
	
	up (meters(2*2.90)) {
	
		deck(l=2, w=2, section=[150, 30], gap=15, dir=BACK,anchor=BOT)
			attach(TOP)
				waterTank(d=1.68, h=1.2, capacity=2000, material="Polyethylene", unit_price=1530, weight=34, info=true,anchor=BOT);
	}	
	
	
	up(meters(2*2.90))
	rectangularFrame(iSize=[2+PILLAR_DIAMETER/1000, 2+PILLAR_DIAMETER/1000], section=[50, 150]) 
		beam(l=$frame_length, section=$frame_section, family="Wood");

		
		
}
	
