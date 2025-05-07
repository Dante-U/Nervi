include <_core/main.scad>
include <_materials/masonry.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: masonry-structure.scad
// Includes:
//   include <masonry-structure.scad>
// FileGroup: Superstructure
// FileSummary: Masonry, Foundation,Slabs
//////////////////////////////////////////////////////////////////////
include <space.scad>

// Module: slab()
//
// Synopsis: Creates a parametric slab with customizable dimensions 
// Topics: Architecture, Rooms, Ground, Slab, Interior Design, IFC  
// See Also: space()
// Usage:
//   slab(length, width, wall, thickness, material, unit_price, anchor, spin, info, ifc_guid);
// Description:
//   Generates a concrete slab with dimensions matching the parent space’s footprint, auto-positioned
//   at the bottom (anchor=TOP) when a direct child of the space module. Calculates volume, weight,
//   and cost using material properties from masonrySpecs and unit_price (cost per m³). Stores
//   metadata in $meta for BIM integration. In IFC, maps to IfcSlab with PredefinedType=BASESLAB.
//
// Arguments:
//   l 			= Length in meters (default: $space_length or 1).
//   w 			= Width in meters (default: $space_width or 1).
//   wall 		= Wall thickness in mm (default: $space_wall or 0).
//   thickness 	= Slab thickness in mm (default: 180).
//   material 	= Material name from masonry.scad (default: "Concrete").
//   unit_price = Cost per cubic meter in currency units (default: 100).
//   anchor 	= Anchor point (default: TOP if child of space, else BOTTOM).
//   spin 		= Rotation around Z-axis in degrees (optional).
//   info 		= If true, generates metadata (default: true).
//   ifc_guid 	= IFC global unique identifier (optional).
//
// Example(3D,ColorScheme=Tomorrow): Automatic sizing slab with parent space
//   space(3,3,2,debug=true,except=[FRONT,RIGHT])
//      color("IndianRed") slab();
module slab( 
		l 			= first_defined([is_undef(l) 	? undef : l ,$space_length]),
		w 			= first_defined([is_undef(w) 	? undef : w ,$space_width]),
		wall		= first_defined([is_undef(wall) ? undef : w ,is_undef($space_wall) ? undef : $space_wall ,WALL_DEFAULT ]),
		thickness 	= 180, 
		material	= "Concrete",	
		unit_price 	= 100,
		anchor		, 
		spin		,
		info
	) {
	assert(is_meters(l),			"[slab] [l] is undefined. Provide length or define variable $space_length");
	assert(is_meters(w),			"[slab] [w] is undefined. Provide length or define variable $space_width");
	
	_length	 	= (l 	? meters(l)		: 1000 ) + 2 * wall;
	_width	 	= (w 	? meters(w) 	: 1000 ) + 2 * wall;
	_thickness	= thickness ? thickness	: 200;
	// Auto-position at TOP if direct child of space
    _anchor = is_undef(anchor) && hasSpaceParent() ? TOP : first_defined([anchor, BOTTOM]);
	size = [_length, _width , _thickness]; 
	zOffset = hasSpaceParent() ? meters( $space_height / 2 ) : 0;
	down (zOffset)
	attachable(anchor = _anchor, spin = spin, orient = UP, size = size ){ 
		material(material) cuboid(size);
		children();
	}
	if (provideMeta(info)) {
		volume = mm3_to_m3(_length * _width * _thickness); // m³
        density = masonrySpecs(material, MATERIAL_DENSITY); // kg/m³
        _ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;	
		$meta = [	
			["name", 		str("Ground slab(", material, ")")],
            ["volume", 		volume				],
            ["weight", 		volume * density	],
            ["unit_price", 	unit_price			],
            ["cost", 		volume * unit_price	],
            ["ifc_class", 	"IfcSlab"			],
            ["ifc_type", 	"BASESLAB"			],
            ["ifc_guid", 	_ifc_guid			]			
		];	
		info();
	}
}


// Module: wallFooting()
//
// Synopsis: Creates a parametric strip footing for walls.
// Topics: Architecture, Foundations, Footing, IFC
// See Also: slab(), space()
// Usage:
//   footingStrip(length, width, thickness, material, unit_price, anchor, spin, orient, info, ifc_guid);
// Description:
//   Generates a continuous strip footing under a wall, with dimensions specified or inherited
//   from the parent space. Calculates volume, weight, and cost using material properties from
//   masonrySpecs and unit_price (cost per m³). Stores metadata in $meta for BIM integration.
//   In IFC, maps to IfcFooting with PredefinedType=STRIPFOOTING.
// Arguments:
//   length = Length in meters (default: $space_length or 1).
//   width = Width in meters (default: $space_width or 0.5).
//   thickness = Footing thickness in mm (default: 300).
//   material = Material name from masonry.scad (default: "Concrete").
//   unit_price = Cost per cubic meter in currency units (default: 100).
//   anchor = Anchor point (default: BOTTOM).
//   spin = Rotation around Z-axis in degrees (optional).
//   orient = Orientation vector (default: UP).
//   info = If true, generates metadata (default: true).
//   ifc_guid = IFC global unique identifier (optional).
// Side Effects:
//   $meta = Stores metadata (name, volume, weight, unit_price, cost, IFC properties) if info=true.
// Example(3D,Big,ColorScheme=Tomorrow): Simple wall footing
//   wallFooting(l=5, w=0.6, thickness=300);    
// Example(3D,Big,ColorScheme=Tomorrow): Wall footing for space 
//   space(4,4,0.4,debug=true)
//      color("IndianRed") wallFooting(w=0.6, thickness=300);   
module wallFooting(
	l,
	w,
    thickness = 300,
    material = "Concrete",
    unit_price = 100,
    anchor = TOP,
    spin,
    orient = UP,
    info = true,
    ifc_guid
) {
	assert(is_meters(w),				"[wallFooting] [w] is undefined. Provide width.");
	assert(is_num_positive(thickness),	"[wallFooting] [thickness] parameter is undefined. Provide thickness."); 
	if (hasSpaceParent()) {
		zOffset = hasSpaceParent() ? meters( $space_height / 2 ) : 0;
		_w 		= meters(w);
		_length	= meters($space_length) + 1 * $space_wall + _w;
		_width 	= meters($space_width)  + 1 * $space_wall + _w;
		boundingSize = [_length,_width,thickness];
		down (zOffset)
		attachable(anchor=anchor, spin=spin, orient=orient, size=boundingSize,cp=[0,0,thickness/2]) {
			union() {
				material(material) rect_tube(size=[_length,_width], wall=_w, h=thickness);
			}
			children();
		}
		
		if (provideMeta(info)) {
			volume = mm3_to_m3((_length * _width-(_length-2*_w) * (_width- 2*_w)) * thickness); // m³
			$meta = _info(volume);
			info();
		}

	} else {
		assert(is_meters(l),	"[wallFooting] [l] is undefined. Provide length");
		_length	= meters(l);
		_width 		= meters(w);
		size = [_length, _width, thickness];
		attachable(anchor=anchor, spin=spin, orient=orient, size=size) {
			color(material == "Concrete" ? "LightGray" : material)
				cuboid(size);
			children();
		}
		if (provideMeta(info)) {
			volume = mm3_to_m3(size); // m³
			$meta = _info(volume);
			info();
		}	
	}
	function _info(volume) =
		let(	
			density = masonrySpecs(material, MATERIAL_DENSITY), // kg/m³
			_ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid,
		)
		[
			["name", str("Wall footing (", material, ")")],
			["volume", 		volume				],
			["weight", 		volume * density	],
			["unit_price", 	unit_price			],
			["cost", 		volume * unit_price	],
			["ifc_class", 	"IfcFooting"		],
			["ifc_type", 	"STRIPFOOTING"		],
			["ifc_guid", 	_ifc_guid			]
		];	
}

// Module: footingPad()
//
// Synopsis: Creates a parametric pad footing for columns.
// Topics: Architecture, Foundations, Footing, IFC
// Usage:
//   footingPad(length, width, thickness, material, unit_price, anchor, spin, orient, info, ifc_guid);
// Description:
//   Generates a rectangular pad footing under a column, with dimensions specified or inherited
//   from the parent space. Calculates volume, weight, and cost using material properties from
//   masonrySpecs and unit_price (cost per m³). Stores metadata in $meta for BIM integration.
//   In IFC, maps to IfcFooting with PredefinedType=PADFOOTING.
// Arguments:
//   length = Length in meters (default: $space_length or 1).
//   width = Width in meters (default: $space_width or 1).
//   thickness = Footing thickness in mm (default: 300).
//   material = Material name from masonry.scad (default: "Concrete").
//   unit_price = Cost per cubic meter in currency units (default: 100).
//   anchor = Anchor point (default: BOTTOM).
//   spin = Rotation around Z-axis in degrees (optional).
//   orient = Orientation vector (default: UP).
//   info = If true, generates metadata (default: true).
//   ifc_guid = IFC global unique identifier (optional).
// Side Effects:
//   $meta = Stores metadata (name, volume, weight, unit_price, cost, IFC properties) if info=true.
// Example(3D,Big,ColorScheme=Tomorrow): Footing pad with top pillar
//   include <wood-structure.scad>
//   color_this("IndianRed") 
//   footingPad (l=0.6, w=0.6, thickness=300 )
//      attach(TOP)
//         rectPillar(l=2,section=[200,200],material="Concrete",anchor=BOT);
module footingPad(
    l 		,
    w 		,
    thickness,
    material 	= "Concrete",
    unit_price 	= 100,
    anchor 		= BOTTOM,
    spin,
    orient 		= UP,
    info 		= false,
    ifc_guid
) {
    assert(is_meters(l) , 						"[footingPad] {l} is undefined. Provide width");
    assert(is_meters(w) , 						"[footingPad] {w} is undefined. Provide width");
    assert(is_num_positive(thickness), 			"[footingPad] {thickness} must be positive");
    assert(is_string(material), 				"[footingPad] material must be a string");

    _length 	= meters(l);
    _width 		= meters(w);
    _thickness 	= thickness;
    size 		= [_length, _width, _thickness];

    if (provideMeta(info)) {
        volume = mm3_to_m3(_length * _width * _thickness); // m³
        density = masonrySpecs(material, MATERIAL_DENSITY); // kg/m³
        _ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
        $meta = [
            ["name", str("Pad footing (", material, ")")],
            ["volume", volume],
            ["weight", volume * density],
            ["unit_price", unit_price],
            ["cost", volume * unit_price],
            ["ifc_class", "IfcFooting"],
            ["ifc_type", "PADFOOTING"],
            ["ifc_guid", _ifc_guid]
        ];
        info();
    }

    attachable(anchor=anchor, spin=spin, orient=orient, size=size) {
        color(material == "Concrete" ? "LightGray" : material)
            cuboid(size);
        children();
    }
}





// Module: footingPileCap()
//
// Synopsis: Creates a parametric pile cap for connecting piles to columns.
// Topics: Architecture, Foundations, Footing, IFC
// Usage:
//   footingPileCap(length, width, thickness, material, unit_price, anchor, spin, orient, info, ifc_guid);
// Description:
//   Generates a rectangular pile cap connecting piles to a column, with dimensions specified
//   or inherited from the parent space. Calculates volume, weight, and cost using material
//   properties from masonrySpecs and unit_price (cost per m³). Stores metadata in $meta for
//   BIM integration. In IFC, maps to IfcFooting with PredefinedType=PILECAP.
// Arguments:
//   length 	= Length in meters (default: $space_length or 1).
//   width 		= Width in meters (default: $space_width or 1).
//   thickness 	= Pile cap thickness in mm (default: 500).
//   material 	= Material name from masonry.scad (default: "Concrete").
//   unit_price	= Cost per cubic meter in currency units (default: 100).
//   anchor 	= Anchor point (default: BOTTOM).
//   spin 		= Rotation around Z-axis in degrees (optional).
//   orient 	= Orientation vector (default: UP).
//   info 		= If true, generates metadata (default: true).
//   ifc_guid 	= IFC global unique identifier (optional).
// Side Effects:
//   $meta = Stores metadata (name, volume, weight, unit_price, cost, IFC properties) if info=true.
// Example(3D,Big,ColorScheme=Tomorrow):
//   footingPileCap(length=2, width=2, thickness=600, material="Concrete", unit_price=120);
//footingPileCap(length=2, width=2, thickness=600, material="Concrete", unit_price=120);
module footingPileCap(
    length = is_undef($space_length) ? undef : $space_length,
    width = is_undef($space_width) ? undef : $space_width,
    thickness = 500,
    material = "Concrete",
    unit_price = 100,
    anchor = BOTTOM,
    spin,
    orient = UP,
    info = true,
    ifc_guid
) {
    assert(is_num(length) || !is_undef(length), "[footingPileCap] length is undefined. Provide length or define $space_length");
    assert(is_num(width) || !is_undef(width), "[footingPileCap] width is undefined. Provide width or define $space_width");
    assert(is_num(thickness) && thickness > 0, "[footingPileCap] thickness must be positive");
    assert(is_string(material), "[footingPileCap] material must be a string");
    assert(is_num(unit_price) && unit_price >= 0, "[footingPileCap] unit_price must be non-negative");

    _length = meters(length ? length : 1);
    _width = meters(width ? width : 1);
    _thickness = thickness;
    size = [_length, _width, _thickness];

    if (provideMeta(info)) {
        volume = mm3_to_m3(_length * _width * _thickness); // m³
        density = masonrySpecs(material, MATERIAL_DENSITY); // kg/m³
        _ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
        $meta = [
            ["name", str("Pile cap (", material, ")")],
            ["volume", volume],
            ["weight", volume * density],
            ["unit_price", unit_price],
            ["cost", volume * unit_price],
            ["ifc_class", "IfcFooting"],
            ["ifc_type", "PILECAP"],
            ["ifc_guid", _ifc_guid]
        ];
        info();
    }

    attachable(anchor=anchor, spin=spin, orient=orient, size=size) {
        color(material == "Concrete" ? "LightGray" : material)
            cuboid(size);
        children();
    }
}

// Module: footingCaisson()
//
// Synopsis: Creates a parametric caisson foundation.
// Topics: Architecture, Foundations, Footing, IFC
// Usage:
//   footingCaisson(diam, depth, material, unit_price, anchor, spin, orient, info, ifc_guid);
// Description:
//   Generates a cylindrical caisson foundation for deep support, with specified diameter and depth.
//   Calculates volume, weight, and cost using material properties from masonrySpecs and unit_price
//   (cost per m³). Stores metadata in $meta for BIM integration. In IFC, maps to IfcFooting with
//   PredefinedType=CAISSON_FOUNDATION.
// Arguments:
//   diam 		= Diameter in meters (default: 1).
//   depth 		= Caisson depth in mm (default: 3000).
//   material 	= Material name from masonry.scad (default: "Concrete").
//   unit_price	= Cost per cubic meter in currency units (default: 100).
//   anchor 	= Anchor point (default: TOP).
//   spin 		= Rotation around Z-axis in degrees (optional).
//   orient 	= Orientation vector (default: UP).
//   info 		= If true, generates metadata (default: true).
//   ifc_guid 	= IFC global unique identifier (optional).
// Side Effects:
//   $meta = Stores metadata (name, volume, weight, unit_price, cost, IFC properties) if info=true.
// Example(3D,Big,ColorScheme=Tomorrow):
//   footingCaisson(diam=1.2, depth=4000, material="Concrete", unit_price=120);
//footingCaisson(diam=1.2, depth=4000, material="Concrete", unit_price=120);
module footingCaisson(
    diam = 1,
    depth = 3000,
    material = "Concrete",
    unit_price = 100,
    anchor = TOP,
    spin,
    orient = UP,
    info = true,
    ifc_guid
) {
    assert(is_num(diam) && diam > 0, "[footingCaisson] diam must be positive");
    assert(is_num(depth) && depth > 0, "[footingCaisson] depth must be positive");
    assert(is_string(material), "[footingCaisson] material must be a string");
    assert(is_num(unit_price) && unit_price >= 0, "[footingCaisson] unit_price must be non-negative");

    _diam = meters(diam);
    _depth = depth;
    size = [_diam, _diam, _depth];

    if (provideMeta(info)) {
        volume = mm3_to_m3(PI * pow(_diam/2, 2) * _depth); // m³
        density = masonrySpecs(material, MATERIAL_DENSITY); // kg/m³
        _ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
        $meta = [
            ["name", str("Caisson foundation (", material, ")")],
            ["volume", volume],
            ["weight", volume * density],
            ["unit_price", unit_price],
            ["cost", volume * unit_price],
            ["ifc_class", "IfcFooting"],
            ["ifc_type", "CAISSON_FOUNDATION"],
            ["ifc_guid", _ifc_guid]
        ];
        info();
    }

    attachable(anchor=anchor, spin=spin, orient=orient, size=size) {
        color(material == "Concrete" ? "LightGray" : material)
            cyl(d=_diam, h=_depth, $fn=64);
        children();
    }
}

// Module: pile()
//
// Synopsis: Creates a parametric pile (driven or bored).
// Topics: Architecture, Foundations, Pile, IFC
// Usage:
//   pile(diam, depth, type, material, unit_price, anchor, spin, orient, info, ifc_guid);
// Description:
//   Generates a cylindrical pile (driven or bored) for deep foundation support, with specified
//   diameter, depth, and type. Calculates volume, weight, and cost using material properties from
//   masonrySpecs and unit_price (cost per m³). Stores metadata in $meta for BIM integration.
//   In IFC, maps to IfcPile with PredefinedType=DRIVEN or BORED.
// Arguments:
//   diam 		= Diameter in meters (default: 0.3).
//   depth 		= Pile depth in mm (default: 10000).
//   type 		= Pile type ("DRIVEN" or "BORED") (default: "DRIVEN").
//   material 	= Material name from masonry.scad (default: "Concrete").
//   unit_price	= Cost per cubic meter in currency units (default: 100).
//   anchor 	= Anchor point (default: TOP).
//   spin 		= Rotation around Z-axis in degrees (optional).
//   orient 	= Orientation vector (default: UP).
//   info 		= If true, generates metadata (default: true).
//   ifc_guid 	= IFC global unique identifier (optional).
// Side Effects:
//   $meta = Stores metadata (name, volume, weight, unit_price, cost, IFC properties) if info=true.
// Example(3D,Big,ColorScheme=Tomorrow):
//   pile(diam=0.4, depth=12000, type="BORED", material="Concrete", unit_price=120);
module pile(
    diam = 0.3,
    depth = 10000,
    type = "DRIVEN",
    material = "Concrete",
    unit_price = 100,
    anchor = TOP,
    spin,
    orient = UP,
    info = true,
    ifc_guid
) {
    assert(is_num(diam) && diam > 0, "[pile] diam must be positive");
    assert(is_num(depth) && depth > 0, "[pile] depth must be positive");
    assert(is_string(type) && (type == "DRIVEN" || type == "BORED"), "[pile] type must be 'DRIVEN' or 'BORED'");
    assert(is_string(material), "[pile] material must be a string");
    assert(is_num(unit_price) && unit_price >= 0, "[pile] unit_price must be non-negative");

    _diam = meters(diam);
    _depth = depth;
    size = [_diam, _diam, _depth];

    if (provideMeta(info)) {
        volume = mm3_to_m3(PI * pow(_diam/2, 2) * _depth); // m³
        density = masonrySpecs(material, MATERIAL_DENSITY); // kg/m³
        _ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
        $meta = [
            ["name", str(type, " pile (", material, ")")],
            ["volume", volume],
            ["weight", volume * density],
            ["unit_price", unit_price],
            ["cost", volume * unit_price],
            ["ifc_class", "IfcPile"],
            ["ifc_type", type],
            ["ifc_guid", _ifc_guid]
        ];
        info();
    }

    attachable(anchor=anchor, spin=spin, orient=orient, size=size) {
        color(material == "Concrete" ? "LightGray" : material)
            cyl(d=_diam, h=_depth, $fn=64);
        children();
    }
}








