include <BOSL2/std.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: masonry.scad
//   Masonry material specs
// Includes:
//   include <_materials/masonry.scad>
// FileGroup: Materials
// FileSummary: Atchitecture, Material, Masonry
//////////////////////////////////////////////////////////////////////

// Function: masonrySpecs()
// 
// Synopsis: Retrieves masonry specifications by name and property.
// Topics: Materials, Masonry Properties, Construction
// Usage:
//   specs = masonrySpecs(material_name, property);
// Description:
//    Provides access to material specifications from the masonry_specs structure by material name. 
//    Can return either the complete specification for a material type or a specific property.
// 
// Arguments:
//    material_name 	= The name of the material to look up in the masonry_specs structure.
//    property  		= Optional. Specific property index to retrieve (uses constants like MATERIAL_DENSITY).
//
// Returns:
//    If property is defined, returns the specific property value for the material.
//    If property is not defined, returns the complete specification structure for the material.
//
// Example(NORENDER):
//    brick_density = masonrySpecs("Brick", MATERIAL_DENSITY);
//    brick_specs = masonrySpecs("Brick");
function masonrySpecs( wood_name, property ) =
	assert(is_def(wood_name), "[masonrySpecs] Missing wood name argument")
	let (
		data = _masonryData(),
		spec = struct_val(masonry_specs, wood_name),
	)
	assert(is_def(spec), str("[masonrySpecs] Unknown wood type: ", wood_name))
	is_def(property) ? spec[property] : spec;

	
function _masonryData()  = struct_set([], [
    // Traditional Masonry
    "Brick", [
        1900,       // Density (kg/m³)
        10.0,       // Compressive Strength (MPa)
        0.8,        // Thermal Conductivity (W/m·K)
        [215, 102.5, 65], // Standard Size (mm, standard clay brick)
        ["walls", "facades", "paving"],
        "Fired clay brick; widely used for structural and decorative purposes."
    ],
	// Concrete for Slabs
    "Concrete", [
        2400,       // Density (kg/m³)
        30.0,       // Compressive Strength (MPa)
        1.5,        // Thermal Conductivity (W/m·K)
        [1000, 1000, 180], // Standard Size (mm, typical slab section)
        ["slabs", "foundations", "pavements"],
        "Cast-in-place concrete; used for monolithic structural elements like slabs."
    ],	
    "Concrete Block", [
        2000,       // Density (kg/m³)
        7.0,        // Compressive Strength (MPa)
        1.0,        // Thermal Conductivity (W/m·K)
        [390, 190, 190], // Standard Size (mm, CMU)
        ["load-bearing walls", "foundations", "partitions"],
        "Cement-based block; versatile for structural applications."
    ],
    "Limestone", [
        2200,       // Density (kg/m³)
        15.0,       // Compressive Strength (MPa)
        1.3,        // Thermal Conductivity (W/m·K)
        [600, 300, 200], // Standard Size (mm, cut block)
        ["cladding", "walls", "flooring"],
        "Sedimentary rock; durable and aesthetically pleasing."
    ],
    "Sandstone", [
        2100,       // Density (kg/m³)
        12.0,       // Compressive Strength (MPa)
        1.7,        // Thermal Conductivity (W/m·K)
        [600, 300, 200], // Standard Size (mm, cut block)
        ["cladding", "paving", "walls"],
        "Sedimentary rock; used for decorative and structural purposes."
    ],
    // Modern Masonry
    "Aerated Concrete", [
        600,        // Density (kg/m³)
        4.0,        // Compressive Strength (MPa)
        0.2,        // Thermal Conductivity (W/m·K)
        [600, 200, 200], // Standard Size (mm, AAC block)
        ["non-load-bearing walls", "insulation", "partitions"],
        "Lightweight autoclaved aerated concrete; excellent thermal insulation."
    ],
    "Glass Block", [
        1800,       // Density (kg/m³)
        6.0,        // Compressive Strength (MPa)
        0.7,        // Thermal Conductivity (W/m·K)
        [190, 190, 80], // Standard Size (mm)
        ["decorative walls", "partitions", "windows"],
        "Translucent block; used for aesthetic and light-transmitting applications."
    ],
    "Rammed Earth", [
        1800,       // Density (kg/m³)
        2.0,        // Compressive Strength (MPa)
        0.6,        // Thermal Conductivity (W/m·K)
        [300, 300, 150], // Standard Size (mm, compressed block)
        ["walls", "foundations", "sustainable construction"],
        "Compressed soil mixture; eco-friendly and thermally efficient."
    ],
    // Specialty Masonry
    "Granite", [
        2700,       // Density (kg/m³)
        20.0,       // Compressive Strength (MPa)
        2.5,        // Thermal Conductivity (W/m·K)
        [600, 300, 200], // Standard Size (mm, cut block)
        ["cladding", "paving", "structural elements"],
        "Igneous rock; extremely durable and decorative."
    ],
    "Marble", [
        2600,       // Density (kg/m³)
        15.0,       // Compressive Strength (MPa)
        2.0,        // Thermal Conductivity (W/m·K)
        [600, 300, 200], // Standard Size (mm, cut block)
        ["flooring", "cladding", "sculptures"],
        "Metamorphic rock; valued for aesthetic appeal."
    ],
    "Adobe", [
        1600,       // Density (kg/m³)
        1.5,        // Compressive Strength (MPa)
        0.5,        // Thermal Conductivity (W/m·K)
        [300, 150, 100], // Standard Size (mm, sun-dried brick)
        ["walls", "sustainable construction"],
        "Sun-dried clay brick; traditional and eco-friendly."
    ]
]);	