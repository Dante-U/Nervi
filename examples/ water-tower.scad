
//
// Torre de agua em eucalipto tratado
//
//

//include <Nervi/masonry-structure.scad>
include <Nervi/wood-structure.scad>

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


//tower();

module tower() {

	grid_copies( size=2000, n=2){
		footingPad(l=0.75,w=0.75,thickness = 200 )
			attach(TOP) 
				rectPillar(l=2*2.90,section=[150,150],anchor=BOT);
	}	
}
 	



//right (3000)
	waterTank(diameter=1680);

module waterTank(diameter,height) {

	shape = rect([100,200], rounding=[50,50,3,7],spin=90);

	if (true) cyl(height = 1000
		,d=1680
		,rounding1=100
		,rounding2=400		
		,$fn=24 
		,texture="trunc_ribs", tex_size=[500,100]
		//,texture="diamonds", tex_size=[150,150]
		, teardrop=true
	) 
	{
		
	
		attach(TOP)
			left(400)
			//tube(height=100,or=200,wall=5);
				cyl(height=100,d=400);
		attach( TOP )
			zrot_copies([45,45+90])
			down(50)
				extrude(diameter,path=shape,dir=RIGHT,center=true);
	};
	//path = xrot(90 ,  rect([100,200], rounding=[50,50,3,7]));
	//back(400) xrot(90) rect([100,200], rounding=[50,50,3,7]);
	//stroke(path);
	
	//shape = rect([100,200], rounding=[50,50,3,7],spin=90);
	
	//extrude(diameter,path=shape,dir=RIGHT);
	//path = [for(x=[-2000:10:2000]) [x,0, 100*sin(x)]];
	
	step = 25;
	path = ballistic_path(4000,500,step*2);

	
	
	
	//path_transforms = [for (t=[0:step:1-step]) translate(path(t)) * zrot(rotate(t)) * scale([drop(t), drop(t), 1])];
	
	radius 	= 15;
	angle 	= 40;
	
	T = [  
			//for(i=[0:25]) 
			for(i=[0:2]) 
				xrot( -angle*i/25,cp=[0,radius,0]) *scale ( [1+i/25, 2-i/25,1] )
		];
		
	echo ("T0:",T[0]);	
	echo ("T1:",T[1]);	
	
	function ballistic_path(
    range  = 4000,
    height = 1000,
    steps  = 401
) = [
    for (x = [-range/2 : range/(steps-1) : range/2])
        let (
            a = -height / pow(range/2, 2),
            z = a * x * x + height
        )
        [x, 0, z]
];
	
	
	function ballistic_z(
		x,
		range  = 4000,
		height = 1000
	) = let (
		half_range = range / 2
	) 
	  [x,0,height * (1 - pow(x / half_range, 2))];
	
	
	echo ("aa",ballistic_z(0));
	
	function rotate(t) = 180 * pow((1 - t), 3);
	
	function rotateY(t) = 
		let (
			ratio = abs(t)/2000
		)	
		ratio * 90;
	
	
	path_transforms = [
		//for (t=[0:step:1-step]) 
		for (t=[-2000:100:2000]) 
			translate(ballistic_z(t)) * 
			zrot(rotateY(t)) * 
			scale([1, 1, 1])
	];

	echo ("path_transforms",path_transforms)	;
	
	//path_sweep( shape, path, method="incremental", last_normal=UP );
	
	
	//t4 = ballistic_transforms();
	
	
//	sweep(shape,path_transforms);
	//sweep(shape,t4);
	
	

	
	

}

module reinforcement(length,width) {
	layer_bez = flatten([
		bez_begin ([-size,0,bz],  90, d, p=theta),
		bez_tang  ([0, size,bz],   0, d, p=theta),
		bez_tang  ([size, 0,bz], -90, d, p=theta),
		bez_tang  ([0,-size,bz], 180, d, p=theta),    
		bez_end   ([-size,0,bz], -90, d, p=180 - theta)
	]);
}




// Function: ballistic_transforms()
// Synopsis: Generates transformation matrices for a ballistic trajectory sweep.
// Topics: Geometry, Physics, Trajectories
// Usage:
//   transforms = ballistic_transforms(range, angle, steps);
// Description:
//   Creates a list of transformation matrices for sweeping a shape along a parabolic ballistic trajectory
//   in the XZ-plane (y=0), from x=-range/2 to x=range/2, with a peak height determined by the launch angle.
//   Includes scaling and rotation transformations from the original drop() and rotate() functions.
// Arguments:
//   range = Total horizontal distance of the trajectory in mm. Default: 4000
//   angle = Launch angle in degrees (0 < angle < 90). Default: 45
//   steps = Number of points along the path. Default: 100
// Returns:
//   A list of transformation matrices combining translation, rotation, and scaling.
// Example:
//   transforms = ballistic_transforms(range=4000, angle=45, steps=5);
//   echo(transforms); // Outputs transformation matrices
function ballistic_transforms(
    range = 4000,
    angle = 45,
    steps = 100
) = let (
    g = 9.81 * 1000, // Gravity in mm/s^2
    theta = angle * PI / 180,
    v0 = sqrt((range * g) / sin(2 * theta)),
    T = 2 * v0 * sin(theta) / g,
    h = (v0 * sin(theta))^2 / (2 * g)
) [
    for (t = [0 : 1/(steps-1) : 1]) let (
        x = -range/2 + range * t,
        t_scaled = t * T,
        z = v0 * sin(theta) * t_scaled - 0.5 * g * t_scaled^2,
        drop = 100 * 0.5 * (1 - cos(180 * t)) * sin(180 * t) + 1,
        rot = 180 * pow((1 - t), 3)
    )
        translate([x, 0, z]) * zrot(rot) * scale([drop, drop, 1])
];




/*

https://www.fortlev.com.br/produtos/reservatorios/tanque-de-polietileno-2000l/
Capacidade	2.000L
A - Altura total	1,13
B - Diâmetro da boca de inspeção	0,60
C - Diâmetro da base	1,68
Adaptador flange para saída incluso
*/