include <../src/_core/utils.scad>


test_extrude_path(); 
test_extrude_geom(); 


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


