
//
// Torre de agua em eucalipto tratado
//
//

//include <Nervi/masonry-structure.scad>
include <Nervi/structure.scad>
include <Nervi/wood-structure.scad>
include <Nervi/masonry-structure.scad>

LITER_PER_DAY_PER_PEOPLE = 175; //150-200 Lire/Day
AUTONOMY = 1.5; // Days  convering defects and maintenance

// Function: waterConsumePerDay()
//
// Synopsis: Calculate consumer in Liters/day total
function waterConsumePerDay (people) = LITER_PER_DAY_PER_PEOPLE * people;

function waterVolumeRequirement ( people , risk = 0.20, autonomy = AUTONOMY) 
	=
	waterConsumePerDay(people) * (1+risk) * autonomy;	



//echo(str("Water consume for 6 people: ",waterConsumePerDay(6)," l/day"));
//echo(str("Tank volumefor 6 people: ",waterVolumeRequirement(6)," liters"));


tower();

module tower() {

	grid_copies( size=2000, n=2){
		footingPad(l=0.75,w=0.75,thickness = 200 )
			attach(TOP) 
				pillar(l=2*2.90,diameter=150,material_type="Wood",anchor=BOT) {
							
				
				}
	}	
	
	
	up(meters(1.6)) ycopies( 2050, n=2){
		beam(l=2-0.0250, section=[100, 100], material_type="Wood", 	material="Oak",info=true);
	}
	//beam(2,2);
	
}
	
