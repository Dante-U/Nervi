include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: structure.scad
//   A library for creating parametric structural components in OpenSCAD, designed for BIM and superstructure design.
//   Provides modules to generate beams and pillars with configurable materials (wood, metal, concrete), cross-sections
//   (rectangular or circular for pillars), and optional indexed text. Leverages BOSL2 for geometry, attachments, and
//   rendering. Supports IFC metadata for BIM integration, with material-specific properties and cost calculations.
//   Uses meters for lengths and millimeters for cross-sectional dimensions, with robust assertions for validation.
// Includes:
//   include <structure.scad>
// FileGroup: Superstructure
// FileSummary: Architecture structure agnostic in term of material
//////////////////////////////////////////////////////////////////////
use <_materials/multi_material.scad>

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
// Example(3D,Small,ColorScheme=Tomorrow):
//   beam(l=2, section=[50, 100], family="Wood", material="Oak");
// Example(3D,Small,ColorScheme=Tomorrow): Metal Beam with Text
//   beam(l=2, section=[100, 100], family="Metal", material="Steel", index="B1");
// Example(3D,Small,ColorScheme=Tomorrow): Concrete Beam with Info
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
    assert(is_meters(l), 										"[beam] l must be a plausible positive number in meters");
    assert(is_dim_pair(section), 								"[beam] section must be a valid [width, thickness] pair in millimeters");
    assert(isValidMaterialFamilies(family),					"[beam] family must be 'Wood', 'Metal', or 'Masonry'");
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
// Example(3D,Big,ColorScheme=Tomorrow):
//   pillar(l=3, section=[200, 200], family="Wood", material="Oak", info=true, cubic_price=600);
// Example(3D,Big,ColorScheme=Tomorrow): Circular Pillar with Text
//   pillar(l=3, diameter=200, family="Metal", material="Steel", index="P1", info=true, cubic_price=2000);
// Example(3D,Big,ColorScheme=Tomorrow): Concrete Pillar
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
	
// Module: rectangularFrame
//
// Synopsis: Creates a rectangular frame of beams for structural applications
// SynTags: Geom, Attachable, BIM
// Topics: Structural, Framing, Beams
// See Also: beam()
// Description:
//   Generates a perimeter frame composed of beams arranged along the X and Y axes,
//   suitable for roofing, flooring, or other structural frameworks. The frame’s outer
//   or inner dimensions are specified in meters, with beams distributed to form the
//   top, bottom, left, and right edges. Beams are oriented based on a prioritization
//   axis (X or Y), with Y-axis beams rotated 90 degrees. The module supports debugging
//   with a ghosted bounding box and provides metadata (volume, weight, cost, IFC class)
//   via the info argument. Special variables $frame_length and $frame_section pass beam
//   parameters to child modules.
// Usage:
//   rectangularFrame(iSize,oSize,section,[prioritize],[material],[anchor],[spin],[debug],[info])
//
// Arguments:
//   iSize      = Inner dimensions [width, depth] in meters (optional; one of iSize or oSize required).
//   oSize      = Outer dimensions [width, depth] in meters (optional; takes precedence over iSize).
//   section    = Beam cross-section [width, height] in millimeters.
//   prioritize = Axis to prioritize for beam length (X=[1,0,0] or Y=[0,1,0]) [default: X].
//   material   = Beam material (e.g., "Wood", "Steel") [default: "Wood"].
//   anchor     = Anchor point for positioning (used by attachable) [default: undef].
//   spin       = Rotation angle in degrees around Z-axis (used by attachable) [default: undef].
//   debug      = If true, renders a ghosted bounding box [default: true].
//   info       = If defined, returns metadata instead of geometry [default: undef].
//
// Context Variables:
//   $frame_length  = Beam length in millimeters for the current child call.
//   $frame_section = Beam cross-section [width, height] in millimeters.
//
// Named Anchors:
//   "front-left" 	= front left assembly anchor for x prioritized
//   "front-right" 	= front right assembly anchor for x prioritized
//   "back-left" 	= back left assembly anchor for x prioritized
//   "back-right" 	= back right assembly anchor for x prioritized
//   "left-back" 	= left back assembly anchor for y prioritized
//   "left-fwd" 	= left forward assembly anchor for y prioritized
//   "right-back" 	= right back assembly anchor for y prioritized
//   "right-fwd" 	= right fordard assembly anchor for y prioritized
//
// Example(3D,ColorScheme=Tomorrow): Beam reactangular frame with default priorization on X axis
//   include <structure.scad>
//   rectangularFrame(oSize=[.4, .4], section=[50, 80]) 
//       beam(l=$frame_length, section=$frame_section, family="Wood");
// Example(3D,ColorScheme=Tomorrow): Beam reactangular frame with priorization on Y axis
//   include <structure.scad>
//   rectangularFrame(oSize=[.4, .4], section=[50, 80],prioritize = Y) 
//       beam(l=$frame_length, section=$frame_section, family="Wood");
// Example(3D,ColorScheme=Tomorrow): Beam reactangular with assembly anchors
//   include <structure.scad>
//   diff() rectangularFrame(oSize=[.4, .4], section=[50, 80], prioritize = Y) {
//      beam(l=$frame_length, section=$frame_section, family="Wood");
//      attach(["left-back","left-fwd","right-back","right-fwd"],CTR,inside=true) cyl(d=20,l=15);
//   }
//
module rectangularFrame(
    iSize,
    oSize,
    prioritize = X,
    section,
	family 			= "Wood",
    material   		= "Pine",
	cubic_price		= 0,
    anchor,
    spin,
    debug      		= false,
    info
) {
    // Validate inputs
    assert(any_defined([iSize, oSize]), 			"[rectangularFrame] Must define at least iSize or oSize");
    assert(is_undef(iSize) || is_meters(iSize)  , 	"[rectangularFrame] iSize must be a valid [width, depth] in meters");
    assert(is_undef(oSize) || is_meters(oSize)  , 	"[rectangularFrame] oSize must be a valid [width, depth] in meters");
    //assert(is_vector(prioritize) && in_list(prioritize, [X, Y]), "[RectangularFrame] prioritize must be X or Y");
	assert(in_list(prioritize, [X, Y]), 			"[rectangularFrame] prioritize must be X or Y");
    assert(is_vector(section) && len(section) == 2 && all_positive(section), "[rectangularFrame] section must be a valid [width, height] in mm");
    assert(info == false || is_string(material), 	"[rectangularFrame] material must be a string");
	assert(info == false || is_string(family), 		"[rectangularFrame] family must be a string");
	
	dw = 2*section.x; // Double width
	hw = section.x/2; // Half width
    // Calculate outer dimensions (in millimeters)
    outer_size = is_def(oSize) ? meters(oSize) : meters(iSize) + [dw,dw];

    $frame_section = section;	// Set beam section for children

    // Calculate shortening for beam length (in mm) to avoid overlaps
    shortening = prioritize == X ? [0,dw] : [dw, 0];
    bounding = [outer_size.x, outer_size.y, section.y];
	
	
	anchors = prioritize == X ? [
			named_anchor("front-left",	pos=[ -bounding.x/2+hw	, -bounding.y/2, 0 ],orient=FWD),
			named_anchor("front-right",	pos=[ +bounding.x/2-hw	, -bounding.y/2, 0 ],orient=FWD),
			named_anchor("back-left",	pos=[ -bounding.x/2+hw	, +bounding.y/2, 0 ],orient=BACK),
			named_anchor("back-right",	pos=[ +bounding.x/2-hw	, +bounding.y/2, 0 ],orient=BACK),
			
		] : 
		[
			named_anchor("left-back",	pos=[ -bounding.x/2		, +bounding.y/2 -hw , 0 ],orient=LEFT),
			named_anchor("left-fwd",	pos=[ -bounding.x/2		, -bounding.y/2 +hw , 0 ],orient=LEFT),
			named_anchor("right-back",	pos=[ +bounding.x/2		, +bounding.y/2 -hw , 0 ],orient=RIGHT),
			named_anchor("right-fwd",	pos=[ +bounding.x/2		, -bounding.y/2 +hw , 0 ],orient=RIGHT),
		];

    // Metadata calculation
    if (provideMeta(info)) {
        // Estimate volume: 2 X-axis beams + 2 Y-axis beams
        x_beam_length = outer_size.x - shortening.x;
        y_beam_length = outer_size.y - shortening.y;
        beam_volume = (2 * x_beam_length * section.x * section.y +
                       2 * y_beam_length * section.x * section.y) / 1e9; // mm³ to m³
		density = materialSpec( family,material,MATERIAL_DENSITY); // kg/m³
        _ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
        $meta = [
            ["name",        str("Frame(", material, ")")],
            ["volume",      beam_volume					],
            ["weight",      beam_volume * density		],
            ["unit_price",  cubic_price					],
            ["cost",        beam_volume * cubic_price	],
            ["ifc_class",   "IfcMember"					],
            ["ifc_type",    "BEAM"						],
            ["ifc_guid",    _ifc_guid					]
        ];
        info();
    } else {
        attachable( anchor=anchor, spin=spin, size=bounding, anchors = anchors ) {
            union() {
                // X-axis beams (top and bottom)
                ycopies(outer_size.y - section.x) {
                    $frame_length = asMeters(outer_size.x - shortening.x);
					children(0);
                }
                // Y-axis beams (left and right, rotated 90°)
                xcopies(outer_size.x - section.x) {
                    $frame_length = asMeters(outer_size.y - shortening.y);
                    zrot(90) children(0);
                }
            }
			union() {
				if ($children > 1) children([1 : $children-1]);  
				if (debug) ghost() cuboid(bounding);
			}
        }
    }
}
