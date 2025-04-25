include <BOSL2/std.scad>;
include <_core/utils.scad>;

debugging_light = false;



module spots( height = 2000,ang = 10, count = 1, spacing = 200, anchor = TOP,spin) {
	target_diam = adj_ang_to_opp( height, ang/2 );
	bounding_size = [target_diam,target_diam, height]; 
	attachable( anchor, spin, orient = UP, size = bounding_size	) { 
		union() {
			material("YellowLight",deep=true)
				xcopies(n=count,spacing=spacing)
					cyl(l=height, r2=25, r1=target_diam);
		}	
		children();	
	}			
}



module ledStrip ( length, radius = 75,anchor,spin ) {
	bounding_size = [length,radius*2, radius*2]; 
	attachable( anchor, spin, orient = UP, size = bounding_size, cp=[0,-radius,-radius]	) { 
		union() {
			material("YellowLight")
				cyl(l=length, r=radius,orient=LEFT,anchor=CENTER);
		}	
		children();	
	}		
}

module pendantLight(
		type 		= "cylinder", 
		cordLength 	= 1200,
		height		= 250,
		width		= 400,
		anchor		= TOP,
		spin 	
	) {
	bounding_size = [ width, width, cordLength + height]; 
	attachable( anchor 	= anchor, spin 	= spin, orient 	= UP, size 	= bounding_size	) { 
		union() {
			up( bounding_size[Z] - cordLength )
				cyl(h=cordLength,d=6,anchor=CENTER)
					align(BOT) {
						if (type == "cylinder") {
							tube(h=height, od1=width, od2=width, wall=5,anchor=TOP);
						} else if (type == "conic") {
							tube(h=height, od1=width, od2=width*0.75, wall=5,anchor=TOP);
						}
					}
		}
		children();
	}
}


if (debugging_light) {

	fwd(500) ledStrip(2000) ;

	cuboid([ 3000, 200, 2000 ],anchor=BOT /*,$color=matColor("Plaster")*/) {
		position( TOP+FRONT )
			spots(count=15 ,spacing=200) show_anchors(300);
			
	}
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