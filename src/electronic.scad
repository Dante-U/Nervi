include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: electronic.scad
// Includes:
//   include <Nervi/electronic.scad>;
// FileGroup: Interior Equipment
// FileSummary: Architecture, Building, Furniture, BIM, Electronic, IfcElectricAppliance
//////////////////////////////////////////////////////////////////////


// Module: television()
// Synopsis: Creates a parametric television with customizable size and height.
// Topics: Interior Systems, Electronics, Furniture, IFC
// Usage:
//   television(size, height, anchor, spin, orient, info, ifc_guid);
// Description:
//   Generates a television with predefined sizes (32", 49", etc.) or custom dimensions,
//   including a frame and screen. Supports material definitions from materials.scad
//   (e.g., "Electronic", "DarkGlass"). Calculates weight and stores metadata in $meta
//   for BIM integration. In IFC, maps to IfcElectricAppliance with PredefinedType=TELEVISION.
// Arguments:
//   size = Diagonal screen size in inches (32, 49, 55, 65, 75, 88) or custom [width, depth, height] in mm (default: 32).
//   height = Stand height in mm (default: 0).
//   anchor = Anchor point (default: BOTTOM).
//   spin = Rotation around Z-axis in degrees (optional).
//   orient = Orientation vector (default: UP).
//   info = If true, generates metadata (default: true).
//   ifc_guid = IFC global unique identifier (optional).
// Example(3D,Big,ColorScheme=Tomorrow):
//   television(size=55, height=1600);
module television( size = 32,height = 0, anchor, spin, orient,info ) {

	frame = 20;
	sizes = struct_set([], [
        32, [740	,150,	460], 
		49, [1110	,80,	640], 
		55, [1320	,70,	720], 
		65, [1460	,70,	900], 
		75, [1700	,80,	1030], 
		88, [1960	,190,	1210], 
        
    ]);
    
    // Fetch bed specs based on type, fallback to custom width/length
    specs = struct_val(sizes, size, default = [740, 150, 460]);
	bounding_size = [specs[0],specs[2],specs[1]];

	//back( height ) 
	attachable(anchor, spin, orient = orient, size = bounding_size,cp=[0,0,])  {
		union() {
			back( height ) 
			diff()
				xrot(-90)
				cuboid(specs,rounding=5,$color=matColor("Electronic"))
					align(FRONT,inside=true,shiftout=1 )
						//tag("keep")
						material("DarkGlass")
						cuboid([
							specs[0]-2*frame,
							3,
							specs[2]-2*frame
							],
							$color="Black",
							rounding=1
							);
			
		}
		children();
	}
	if (provideMeta(info)) {
        volume = mm3_to_m3(specs[0] * specs[1] * specs[2]); // m³
        density = 1200; // Estimated for electronics (kg/m³)
        _ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
        $meta = [
            ["name", str("Television (", is_num(size) ? str(size, "\"") : "Custom", ")")],
            ["volume", volume],
            ["weight", volume * density],
            ["ifc_class", "IfcElectricAppliance"],
            ["ifc_type", "TELEVISION"],
            ["ifc_guid", _ifc_guid]
        ];
        info();
    }
}
	


module desklamp( anchor = BOT, spin	){
	length 	= 400;
	height 	= 460;
	width 	= 82;
	material("Aluminium")  attachable(anchor, spin, orient = UP, size = [length,width,height],cp=[0,0,height/2] )  {
		cyl(d=width,h=70,anchor=BOTTOM) 
			align(TOP)
				down(70)
				pendulum(80,200,70) 									// First pendulum
					align(TOP)
						yrot(50) 
						down(100) 
							pendulum(62,320,-30)  {						// Second pendulum 
								attach(BOT)
									cuboid([70,width,10],rounding=3);	// Balancer 1
								align(TOP)
									yrot(-120) 
									down(120) 
									pendulum(53,410,-30) {				// Last pendulum					
										attach(BOT)
											cuboid([55,55,10],rounding=3); // Balancer 1
										attach(TOP) yrot(75) translate([-10,0,-20]) {
											//prism(size=[100, 200, 50], anchor=CENTER, spin=0, orient=UP);
											
											prismoid(80, 45, rounding=10, h=25);
										}	
									}
							}; 
		children();
	}
	module pendulum( width, length, lever ) {
		attachable(anchor = BOT,  orient = UP, size = [10,width,length] ,cp=[0,0,lever]) {
			translate([0,0,lever]) ycopies(width,n=2) cuboid([10,5,length],rounding=2);
			children();
		}	
	}

}

module computerDisplay(anchor,spin) {
	height 		= 470;
	width 		= 700;
	depth       = 300;
	footHeight 	= 300;
	footLength 	= 300;
	frame=5;
	totalHeight = height + footHeight/2;
	
	 attachable(anchor, spin, orient = UP, size = [width, depth, totalHeight ] )  {
		union(){
			ft = 20;
			fl = 230;
			points =[
				[fl/2,0],
				[fl/2,ft],
				[-fl/2+ft,ft],
				[0,fl],
				[-ft,fl],
				[-fl/2,ft],
				[-fl/2,0],
			];
			points_3d = path3d(round_corners(points,radius=8));
			ecc = 400;
			zrot(-90) xrot(90) material("Aluminium") skin (
				profiles = [
					xrot(+10,	points_3d	, cp=[0,ecc,0]),	
					xrot(-10,	points_3d	, cp=[0,ecc,0])	
				],
				slices=2 
			);
			up(height*2/3)
				xrot(-5) 
					cuboid([width,50,height],rounding=5,$color=matColor("Electronic"))				
						align(FRONT,inside=true,shiftout=1 )
							//tag("keep")
							material("DarkGlass")
								cuboid([
										width-2*frame,
										3,
										height-2*frame
									],
									$color="Black",
									rounding=1
									);
		}
		children();
	}	

}

module keyboard( anchor = BOT, spin ) {
	length 		= 420;
	width 		= 115;
	thickness   = 8;
	
	material("Aluminium") attachable(anchor, spin, orient = UP, size = [length, width, thickness ] )   {
		heights = [
			[3, 3],
			[10, 10]
		];
		heightfield(heights, size=[420, 115],bottom=0);
		children();
	 }
}