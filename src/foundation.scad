include <_core/main.scad>
include <_materials/masonry.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: foundation.scad
// Includes:
//   include <foundation.scad>
// FileGroup: Superstructure
// FileSummary: Parametric foundation elements
//////////////////////////////////////////////////////////////////////
include <space.scad>
// Foundations types
//
// - T-Shaped  
// - Slab-on-grade foundation
// - Frost Protected
// IfcFooting
//
//
//  IfcFootingTypeEnum : 
//  - CAISSON_FOUNDATION 
//  - FOOTING_BEAM
//  - PAD_FOOTING
//  - PILE_CAP
// - STRIP_FOOTING
// - USERDEFINED
//  NOTDEFINED

/*
Create modules for modules :
- wallFooting
- strapFooting
- matFoundations
- combinedFooting
- IsolatedFooting 
*/


// Module: wallFooting()
// footingStrip()
//
// Synopsis: Creates a parametric strip footing for walls.
// Topics: Architecture, Foundations, Footing, IFC
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
// Example(3D,Big,ColorScheme=Nature): Simple wall footing
//   wallFooting(l=5, w=0.6, thickness=300);    
// Example(3D,Big,ColorScheme=Nature): Wall footing for space 
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

/*	
    assert(is_num(length) || !is_undef(length), "[footingStrip] length is undefined. Provide length or define $space_length");
    assert(is_num(width) || !is_undef(width), "[footingStrip] width is undefined. Provide width or define $space_width");
    assert(is_num(thickness) && thickness > 0, "[footingStrip] thickness must be positive");
    assert(is_string(material), "[footingStrip] material must be a string");
    assert(is_num(unit_price) && unit_price >= 0, "[footingStrip] unit_price must be non-negative");

    _length = meters(length ? length : 1);
    _width = meters(width ? width : 0.5);
    _thickness = thickness;
    size = [_length, _width, _thickness];
	
	echo ("hasSpaceParent()",hasSpaceParent());
*/	
	
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
			/*
			density = masonrySpecs(material, MATERIAL_DENSITY); // kg/m³
			_ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
			$meta = [
				["name", str("Strip footing (", material, ")")],
				["volume", volume],
				["weight", volume * density],
				["unit_price", unit_price],
				["cost", volume * unit_price],
				["ifc_class", "IfcFooting"],
				["ifc_type", "STRIPFOOTING"],
				["ifc_guid", _ifc_guid]
			];
			*/
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
	/*
	module _info(volume) {
		density = masonrySpecs(material, MATERIAL_DENSITY); // kg/m³
			_ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
			$meta = [
				["name", str("Strip footing (", material, ")")],
				["volume", volume],
				["weight", volume * density],
				["unit_price", unit_price],
				["cost", volume * unit_price],
				["ifc_class", "IfcFooting"],
				["ifc_type", "STRIPFOOTING"],
				["ifc_guid", _ifc_guid]
			];
		info();
	}
	*/
	
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
// Example(3D,Big,ColorScheme=Nature):
//   footingPad(length=3.0, width=0.8, thickness=400, material="Concrete", unit_price=120);

//footingPad(length=3, width=0.8, thickness=400, material="Concrete", unit_price=120);

module footingPad(
    length 		= is_undef($space_length) ? undef : $space_length,
    width 		= is_undef($space_width) ? undef : $space_width,
    thickness 	= 300,
    material = "Concrete",
    unit_price = 100,
    anchor = BOTTOM,
    spin,
    orient = UP,
    info = true,
    ifc_guid
) {
    assert(is_num(length) || !is_undef(length), "[footingPad] length is undefined. Provide length or define $space_length");
    assert(is_num(width) || !is_undef(width), "[footingPad] width is undefined. Provide width or define $space_width");
    assert(is_num(thickness) && thickness > 0, "[footingPad] thickness must be positive");
    assert(is_string(material), "[footingPad] material must be a string");
    assert(is_num(unit_price) && unit_price >= 0, "[footingPad] unit_price must be non-negative");

    _length = meters(length ? length : 1);
    _width = meters(width ? width : 1);
    _thickness = thickness;
    size = [_length, _width, _thickness];

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
// Example(3D,Big,ColorScheme=Nature):
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
// Example(3D,Big,ColorScheme=Nature):
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
// Example(3D,Big,ColorScheme=Nature):
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








