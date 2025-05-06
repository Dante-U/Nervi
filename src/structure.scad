include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: structure.scad
// Includes:
//   include <structure.scad>
// FileGroup: Superstructure
// FileSummary: Architecture structure agnostic in term of material
//////////////////////////////////////////////////////////////////////
include <_materials/multi_material.scad>

//
// Module: beam()
//
// Synopsis: Creates a parametric beam with configurable material (wood, metal, or concrete) and optional indexed text.
// Topics: Geometry, Superstructure
// SynTags: Geom, Attachable, BIM
// Usage:
//   beam(l, section, family, material, index, rounding, textSize, textDepth, textColor, info, cubic_price, anchor, spin, orient);
// Description:
//   Generates a cuboid beam with specified length and cross-sectional dimensions, with optional rounded edges using BOSL2's cuboid().
//   The beam can be made of wood, metal, or concrete, set via family, with material-specific colors, density, and IFC metadata.
//   If index is provided, centered text is extruded on the top face. The beam's color is set by material, falling back to $color
//   or material-specific defaults ("BurlyWood" for wood, "Silver" for metal, "Gray" for concrete). Length defaults to $beam_l,
//   and section defaults to $beam_section. Length (l) is in meters; section dimensions (width, thickness), rounding, textSize, and
//   textDepth are in millimeters. Length and section dimensions must be positive, and rounding must be between 0 and half the
//   smallest section dimension (inclusive). Metadata is stored in $meta for BIM integration, mapping to IfcMember with
//   material-specific ifc_type (BEAM for wood/metal, CONCRETE for concrete).
// Arguments:
//   l             = Length of the beam (x-axis) in meters. Default: $beam_l or 2
//   section       = Cross-sectional dimensions [width, thickness] in millimeters. Default: $beam_section or [100, 100]
//   family		 = Material type ("Wood", "Metal", "Masonry"). Default: "wood"
//   material      = Specific material name (e.g., "Oak", "Steel", "Concrete") 
//   index         = Index number or string to display as text. Default: undef (no text)
//   rounding      = Radius for edge rounding in millimeters. Default: $beam_rounding or 5
//   textSize      = Size of the text in millimeters. Default: 0.75// section[0]
//   textDepth     = Extrusion depth of the text in millimeters. Default: 1
//   textColor     = Color of the text. Default: "White"
//   info          = If true, generates metadata. Default: false
//   cubic_price   = Price per cubic meter for cost calculation (currency/m³). Default: undef
//   anchor        = Anchor point for positioning. Default: BOTTOM
//   spin          = Rotation around Z-axis in degrees. Default: 0
//   orient        = Orientation vector. Default: UP
// Example(3D,Small,ColorScheme=Nature):
//   beam(l=2, section=[50, 100], family="Wood", material="Oak");
// Example(3D,Small,ColorScheme=Nature): Metal Beam with Text
//   beam(l=2, section=[100, 100], family="Metal", material="Steel", index="B1");
// Example(3D,Small,ColorScheme=Nature): Concrete Beam with Info
//   beam(l=2, section=[100, 100], family="Masonry", material="Concrete", info=true, cubic_price=300);
module beam(
    l             = first_defined([is_undef(l)          ? undef : l,         is_undef($beam_length)         ? 2      : $beam_length]),
    section       = first_defined([is_undef(section)    ? undef : section,   is_undef($beam_section)   ? [100, 100]  : $beam_section]),
    family 		  = "wood",
    material      = undef,
    index         = undef,
    rounding      = first_defined([is_undef(rounding)   ? undef : rounding,  is_undef($beam_rounding)  ? 5       : $beam_rounding]),
    textSize      = undef,
    textDepth     = 1,
    textColor     = "White",
    info          = false,
    cubic_price,
    anchor        ,
    spin          = 0,
    orient        = UP
) {
    // Validate inputs
    assert(is_meters(l), 							"[beam] l must be a plausible positive number in meters");
    assert(is_dim_pair(section), 					"[beam] section must be a valid [width, thickness] pair in millimeters");
    assert(isValidMaterialFamilies(family),			"[beam] family must be 'wood', 'metal', or 'concrete'");
    assert(is_between(rounding, 0, min(section) / 2, min_inc=true, max_inc=true), 
           "[beam] rounding must be between 0 and half the smallest section dimension (inclusive) in millimeters");
    assert(is_undef(index) || is_string(index) || is_num(index), "[beam] index must be a string or number");
    assert(is_num_positive(textSize) || is_undef(textSize), "[beam] textSize must be a positive number in millimeters");
    assert(is_num_positive(textDepth), "[beam] textDepth must be a positive number in millimeters");

    // Extract section dimensions
    width 		= section.x;   // Width in millimeters
    thickness 	= section.y; 	// Thickness in millimeters
    length 		= l * 1000;     // Convert length to millimeters for rendering
    // Material-specific settings
	_material = default( material,materialFamilyToMaterial( family ));
    // Geometry and text settings
    size = [length, width, thickness];
    _textSize = clamp(
        is_undef(textSize) ? 0.75 * width : textSize,
        0.1 * width,
        0.9 * width
    );
    // Metadata for BIM/IFC
    if (provideMeta(info)) {
		_ifc_type = family == "Masonry" ? "CONCRETE" : "BEAM";
		_density  = materialSpec(family, _material, MATERIAL_DENSITY);
        volume = l * width * thickness / 1000000; // m³ (length in meters, width/thickness in mm)
        cost = is_def(cubic_price) ? cubic_price * volume : undef;
        _ifc_guid = generate_guid();
        $meta = [
            ["name", str("Beam (", _material, ")")],
            ["volume", volume],
            ["weight", volume * _density],
            if (cost) ["cost", cost],
            ["ifc_class", "IfcMember"],
            ["ifc_type", _ifc_type],
            ["ifc_guid", _ifc_guid]
        ];
        info();
    }

    // Render beam and optional text
    attachable(size=size, anchor=anchor, spin=spin, orient=orient) {
        union() {
            material(_material, default = materialFamilyToMaterial(family))
                cuboid(size, rounding=rounding);
            if (index)
                color(textColor)
                    up(thickness / 2)
                    linear_extrude(textDepth)
                        text(str(index), size=_textSize, valign="center", halign="center", $fn=32);
        }
        children();
    }
}


//
// Module: pillar()
//
// Synopsis: Creates a parametric pillar with rectangular or circular cross-section and configurable material.
// Topics: Architecture, Structural, IFC
// SynTags: Geom, Attachable, BIM
// Usage:
//   pillar(l, section, diameter, family, material, index, rounding, textSize, textDepth, textColor, info, cubic_price, anchor, spin, orient);
// See Also: beam()
// Description:
//   Generates a pillar with a rectangular or circular cross-section, defined by length (l) and either section or diameter.
//   Supports wood, metal, or concrete materials, set via family, with material-specific colors, density, and IFC metadata.
//   If index is provided, centered text is extruded on the top face. The pillar's color is set by material, falling back to $color
//   or material-specific defaults ("BurlyWood" for wood, "Silver" for metal, "Gray" for concrete). Length defaults to $pillar_l,
//   section to $pillar_section, and diameter to $pillar_diameter. Length (l) is in meters; section dimensions (width, thickness),
//   diameter, rounding, textSize, and textDepth are in millimeters. Length and section/diameter must be positive, and rounding
//   must be between 0 and half the smallest section dimension or diameter (inclusive). Metadata is stored in $meta for BIM
//   integration, mapping to IfcColumn with material-specific ifc_type (COLUMN for wood/metal, CONCRETE for concrete).
// Arguments:
//   l             = Length of the pillar (z-axis) in meters. Default: $pillar_l or 3
//   section       = Cross-sectional dimensions [width, thickness] in millimeters for rectangular pillars. Default: $pillar_section or undef
//   diameter      = Diameter in millimeters for circular pillars. Default: $pillar_diameter or undef
//   family 	   = Material type ("Wood", "Metal", "Masonry"). Default: "Wood"
//   material      = Specific material name (e.g., "Oak", "Steel", "Concrete")
//   index         = Index number or string to display as text. Default: undef (no text)
//   rounding      = Radius for edge rounding in millimeters. Default: $pillar_rounding or 5
//   textSize      = Size of the text in millimeters. Default: 0.75// (section.x or diameter)
//   textDepth     = Extrusion depth of the text in millimeters. Default: 1
//   textColor     = Color of the text. Default: "White"
//   info          = If true, generates metadata. Default: false
//   cubic_price   = Price per cubic meter for cost calculation (currency/m³). Default: undef
//   anchor        = Anchor point for positioning. Default: BOTTOM
//   spin          = Rotation around Z-axis in degrees. Default: 0
//   orient        = Orientation vector. Default: UP
// Example(3D,Big,ColorScheme=Nature):
//   pillar(l=3, section=[200, 200], family="Wood", material="Oak", info=true, cubic_price=600);
// Example(3D,Big,ColorScheme=Nature): Circular Pillar with Text
//   pillar(l=3, diameter=200, family="Metal", material="Steel", index="P1", info=true, cubic_price=2000);
// Example(3D,Big,ColorScheme=Nature): Concrete Pillar
//   pillar(l=3, section=[200, 300], family="Masonry", material="Concrete", info=true, cubic_price=300);
module pillar(
    l             = first_defined([is_undef(l)          ? undef : l,         is_undef($pillar_l)         ? 3       : $pillar_l]),
    section       = first_defined([is_undef(section)    ? undef : section,   is_undef($pillar_section)   ? undef   : $pillar_section]),
    diameter      = first_defined([is_undef(diameter)   ? undef : diameter,  is_undef($pillar_diameter)  ? undef   : $pillar_diameter]),
    family 		  = "Wood",
    material      = undef,
    index         = undef,
    rounding      = first_defined([is_undef(rounding)   ? undef : rounding,  is_undef($pillar_rounding)  ? 5       : $pillar_rounding]),
    textSize      = undef,
    textDepth     = 1,
    textColor     = "White",
    info          = false,
    cubic_price,
    anchor        = BOTTOM,
    spin          = 0,
    orient        = UP
) {
    // Validate inputs
    assert(is_meters(l), 										"[pillar] l must be a plausible positive number in meters");
    assert(is_dim_pair(section) || is_num_positive(diameter), 	"[pillar] Define either section for rectangular or diameter for circular pillars");
    assert(num_defined([section, diameter]) == 1, 				"[pillar] Define exactly one of section or diameter");
    assert(isValidMaterialFamilies(family),						"[pillar] family must be 'Wood', 'Metal', or 'Concrete'");
    assert(is_between(rounding, 0, min(section != undef ? [section.x, section.y] : [diameter, diameter]) / 2, min_inc=true, max_inc=true), 
           "[pillar] rounding must be between 0 and half the smallest section dimension or diameter (inclusive) in millimeters");
    assert(is_undef(index) || is_string(index) || is_num(index),"[pillar] index must be a string or number");
    assert(is_num_positive(textSize) || is_undef(textSize), 	"[pillar] textSize must be a positive number in millimeters");
    assert(is_num_positive(textDepth), 							"[pillar] textDepth must be a positive number in millimeters");
    // Extract dimensions
    width 		= section != undef ? section.x : diameter; // Width or diameter in millimeters
    thickness 	= section != undef ? section.y : diameter; // Thickness or diameter in millimeters
    length 		= meters(l); // Convert length to millimeters for rendering
    // Material-specific settings
	_material = default( material,materialFamilyToMaterial(family));
	_fn = valueByRendering(simple=16, standard=32, detailed=64); // Adjust $fn based on rendering level
    // Geometry and text settings
    size = [width, thickness, length];
    _textSize = clamp(
        is_undef(textSize) ? 0.75 * width : textSize,
        0.1 * width,
        0.9 * width
    );
    // Metadata for BIM/IFC
    if (provideMeta(info)) {
		_ifc_type = family == "Masonry" ? "CONCRETE" : "COLUMN";
		_density = materialSpec(family, _material, MATERIAL_DENSITY);		   
        volume = section != undef
            ? l * width * thickness / 1000000 // m³ (rectangular: length in meters, width/thickness in mm)
            : l * PI * pow(diameter / 2, 2) / 1000000; // m³ (circular: length in meters, diameter in mm)
        cost = is_def(cubic_price) ? cubic_price * volume : undef;
        _ifc_guid = generate_guid();
        $meta = [
            ["name", str("Pillar (", _material, ")")],
            ["volume", volume],
            ["weight", volume * _density],
            if (cost) ["cost", cost],
            ["ifc_class", "IfcColumn"],
            ["ifc_type", _ifc_type],
            ["ifc_guid", _ifc_guid]
        ];
        info();
    }
    // Render pillar and optional text
    attachable(size=size, anchor=anchor, spin=spin, orient=orient) {
        union() {
            material(_material, default = materialFamilyToMaterial(family)) {
                if (section != undef) {
                    cuboid(size, rounding=rounding);
                } else {
                    cyl(d=diameter, h=length, rounding=rounding, $fn=_fn);
                }
            }
            if (index) {
                color(textColor)
                    up(thickness / 2)
                    linear_extrude(textDepth)
                        text(str(index), size=_textSize, valign="center", halign="center", $fn=_fn);
            }
        }
        children();
    }
}
