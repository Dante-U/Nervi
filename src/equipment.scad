include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: equipment.scad
// Includes:
//   include <equipment.scad>
// FileGroup: Equipment
// FileSummary: Architecture, Building, Equipment
//////////////////////////////////////////////////////////////////////

// Module: waterTank()
//
// Synopsis: Creates a cylindrical water tank with inspection tap and reinforcements.
// SynTags: Geom, BIM
// Topics: Geometry, Tanks, IFC
// Usage:
//   waterTank(d, h, capacity, material, unit_price, weight, anchor, spin, info);
// Description:
//   Generates a cylindrical water tank with rounded top and bottom, an inspection tap. 
//   The tank has a specified diameter (d) and height (h), with metadata for BIM integration mapping
//   to IfcTank with PredefinedType=STORAGE. The material defaults to "Plastic", and volume is specified in m3.
// Arguments:
//   d          = Diameter of the tank in meters. No default
//   h          = Height of the tank in meters. No default
//   capacity   = Tank volume in m3. No default
//   material   = Material name (e.g., "Polyethylene"). Default: "Plastic"
//   unit_price = Cost unit. Default: undef
//   weight     = Tank weight in kg. Default: undef
//   anchor     = Anchor point for positioning. Default: CENTER
//   spin       = Rotation around Z-axis in degrees. Default: 0
//   info       = If true, generates metadata. Default: false
//
// Example(3D,Big,ColorScheme=Nature):
//   waterTank(d=1.68, h=1.2, capacity=2000, material="Polyethylene", unit_price=1530, weight=34, info=true);
module waterTank( d, h , capacity, material, unit_price, weight, anchor, spin, info ) {
	assert(is_meters(d),			"[waterTank] [d] is undefined. Provide diameter");
	assert(is_meters(h),			"[waterTank] [h] is undefined. Provide height");
	_d= meters(d);	
	_h= meters(h);	
	
	rw = _d/12;
	rh = _d/8;
	reinforcement = rect([ rw, rh ], rounding= valueByRendering(0,[rw/2,rw/2,0,0]),spin=90);
	
	size = [_d,_d,_h];
	attachable( anchor = anchor, spin = spin, size = size ) { 
		material(material,default="Plastic")
		cyl(height = _h	,d=_d ,rounding1=_d/10 ,rounding2=_d/4,$fn=valueByRendering(16,32,64)) 
		{
			attach(TOP)		// Inspection tap
				left(_d/3.5)
					cyl(height=100,d=400,rounding2=30);
			attach( TOP )	// Reinforcement
				zrot_copies(n=4,sa=45)
				down(50)
					skew(sxz=-0.5)
						extrude(_d*0.85/2,path=reinforcement,dir=RIGHT);
		};
		children();
	}
	if (provideMeta(info)) {
		_ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;  // Generate a GUID if not provided
		cost = unit_price ? unit_price : undef;
		$meta = info ?  [
			["name",		str("Water tank(",capacity," L)")	]	,
			["diameter",	d									]	,
			["height",		h									]	,
			["volume,liters",		capacity					]	,
			["area",		circleArea(d=d)						]	,
			if (cost)
				["cost",	unit_price 							]   ,
			if (weight)
				["weight",	weight 								]   ,
			// Add IFC metadata
            ["ifc_class",   "IfcTank"   ],
            ["ifc_type",    "STORAGE"    ],
            ["ifc_guid",    _ifc_guid   ],			
		] : undef;
		info();
	}
}	


