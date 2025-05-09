include <../src/_core/utils.scad>


test_general();


test_extrude_path(); 
test_extrude_geom(); 

module test_general() {
	pieSlice( 500 ,45, 80) show_anchors(300) ;
	
	//clearingZone(length=800, width=400);
	//clearingZone(label="toilet") show_anchors(500);
	left(1000)
		clearingZone (300  , 200 , "Wash Bassin");	
	left(2000)
		clearingZone (900  , 700 , "Wash Bassin");	
	left(3500)
		clearingZone (1400  , 1200 , "Wash Bassin");	
		

	echo ("round_points",round_points([
		[0.345,23.455657657,3434.222222],
		[0.4785,1.7869],
	]));		
	
	contour2D=[
		[-1,0],
		[5,0],
		[5,4],
		[2,4.5],
		[-1,3],
	];
	
	//echo ("---- boundingSize",boundingSize(contour));
	contour3D=[
		[-1,0,3],
		[5,0,3],
		[5,4,3],
		[2,4.5,-3],
		[-1,3,-3],
	];
	assert (boundingSize(contour3D) == [6, 4.5, 6]," Bounding size for 3d Path is wrong!" );
	assert (boundingSize(contour2D) == [6, 4.5, 0]," Bounding size for 2d Path is wrong!" );
}


module test_extrude_path() {
	path = [ [0,0],	[100,40], [100,0] ];
	height = 5;	
	// Up (Ok)
	color ("Blue") extrude(height,dir=UP,path=path,anchor=LEFT);// show_anchors(20);
	// Down (Ok)
	color ("Red") extrude(height,dir=DOWN,path=path);//  show_anchors(20);
	// Right (OK)
	color ("Red") extrude(height,dir=RIGHT,path=path);// show_anchors(20);
	// Left (OK)
	color ("Blue") extrude(height,dir=LEFT,path=path);// show_anchors(20);
	// Front (OK)
	color ("Red") extrude(height,dir=FRONT,path=path);// show_anchors(20);
	// Back 
	color ("Blue") extrude(height,dir=BACK,path=path);// show_anchors(20);

}

module test_extrude_geom() {
	path = [ [0,0],	[100,40], [100,0] ];
	height = 5;	
	// Up (Ok)
	color ("Blue") extrude(height,dir=UP) polygon(path);// show_anchors(20);
	// Down (Ok)
	color ("Red") extrude(height,dir=DOWN) polygon(path);//  show_anchors(20);
	// Right (OK)
	color ("Red") extrude(height,dir=RIGHT) polygon(path);// show_anchors(20);
	// Left (OK)
	color ("Blue") extrude(height,dir=LEFT) polygon(path);// show_anchors(20);
	// Front (OK)
	color ("Red") extrude(height,dir=FRONT) polygon(path);// show_anchors(20);
	// Back 
	color ("Blue") extrude(height,dir=BACK) polygon(path);// show_anchors(20);
}


