include <BOSL2/std.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: wood.scad
//   Wood specs
// Includes:
//   include <_materials/wood.scad>
// FileGroup: Materials
// FileSummary: Material specs
//////////////////////////////////////////////////////////////////////

// Function: woodSpecs()
// 
// Synopsis: Retrieves wood specifications by name and property.
// Topics: Materials, Wood Properties, Construction
// Usage:
//   specs = woodSpecs(wood_name, property);
// Description:
//    Provides access to wood specifications from the wood_specs structure by wood name. 
//    Can return either the complete specification for a wood type or a specific property.
// 
// Arguments:
//    wood_name = The name of the wood to look up in the wood_specs structure.
//    property  = Optional. Specific property index to retrieve (uses constants like WOOD_DENSITY).
//
// Returns:
//    If property is defined, returns the specific property value for the wood.
//    If property is not defined, returns the complete specification structure for the wood.
//
// Example(NORENDER):
//    pine_density = woodSpecs("Pine", WOOD_DENSITY);
//    oak_specs = woodSpecs("Oak");
function woodSpecs( wood_name, property ) =
	assert(is_def(wood_name), "[woodSpecs] Missing wood name argument")
	let (
		spec = struct_val(wood_specs, wood_name),
	)
	assert(is_def(spec), str("[woodSpecs] Unknown wood type: ", wood_name))
	is_def(property) ? spec[property] : spec;
	
	
// Constant: WOOD_DENSITY
// Description: Index for wood density value (kg/m³)
WOOD_DENSITY 				= 0;
// Constant: WOOD_COMPRESSIVE_STRENGTH
// Description: Index for wood compressive strength (MPa)
WOOD_COMPRESSIVE_STRENGTH = 1;

// Constant: WOOD_ELASTICITY
// Description: Index for wood elasticity/modulus of elasticity (GPa)
WOOD_ELASTICITY = 2;

// Constant: WOOD_STRENGTH_CLASS
// Description: Index for wood strength classification
WOOD_STRENGTH_CLASS = 3;

// Constant: WOOD_APPLICATION
// Description: Index for recommended applications
WOOD_APPLICATION = 4;

// Constant: WOOD_DESCRIPTION
// Description: Index for general description of the wood
WOOD_DESCRIPTION = 5;


wood_specs = struct_set([], [
    // Brazilian Woods
    "Eucalyptus saligna", [
        730,        // Density (kg/m³)
        46.8,       // Compressive Strength (MPa)
        12000,      // Modulus of Elasticity (MPa)
        "C40",      // Strength Class
        ["structural beams", "flooring", "roof structures"],
        "High mechanical strength; suitable for structural applications in civil construction, aka Eucalyptus saligna."
    ],
    "Paricá", [
        276,        // Density (kg/m³)
        20.0,       // Compressive Strength (MPa)
        7000,       // Modulus of Elasticity (MPa)
        "C20",      // Strength Class
        ["plywood panels", "lightweight furniture"],
        "Lightweight wood with low density; commonly used in plywood industry, aka Schizolobium amazonicum."
    ],
    "Eucalyptus alba", [
        650,        // Density (kg/m³)
        35.0,       // Compressive Strength (MPa)
        10000,      // Modulus of Elasticity (MPa)
        "C30",      // Strength Class
        ["construction framing", "furniture"],
        "Moderate strength and density; versatile for various construction purposes, aka Eucalyptus alba."
    ],
    "Cedroarana", [
        520,        // Density (kg/m³)
        46.6,       // Compressive Strength (MPa)
        9000,       // Modulus of Elasticity (MPa)
        "C30",      // Strength Class
        ["interior joinery", "light structural elements"],
        "Moderate strength with good workability; suitable for interior applications, aka Cedrelinga catenaeformis."
    ],
    "Sabiá", [
        800,        // Density (kg/m³)
        50.0,       // Compressive Strength (MPa)
        13000,      // Modulus of Elasticity (MPa)
        "C40",      // Strength Class
        ["heavy-duty flooring", "structural supports"],
        "High-density hardwood with excellent mechanical properties; ideal for heavy structural use, aka Mimosa caesalpiniaefolia."
    ],
    "Eucalyptus AMARU", [
        700,        // Density (kg/m³)
        40.0,       // Compressive Strength (MPa)
        11000,      // Modulus of Elasticity (MPa)
        "C30",      // Strength Class
        ["round timber structures", "bridges", "utility poles"],
        "Engineered clone with consistent properties; used in various structural applications, aka Eucalyptus hybrid."
    ],
    "Ipe", [
        1050,       // Density (kg/m³)
        60.0,       // Compressive Strength (MPa, estimated)
        14000,      // Modulus of Elasticity (MPa, estimated)
        "C50",      // Strength Class (estimated)
        ["decking", "flooring", "structural beams"],
        "Extremely durable and dense; ideal for heavy outdoor use, aka Tabebuia spp."
    ],
    "Jatoba", [
        910,        // Density (kg/m³)
        55.0,       // Compressive Strength (MPa, estimated)
        13500,      // Modulus of Elasticity (MPa, estimated)
        "C40",      // Strength Class (estimated)
        ["flooring", "furniture", "structural supports"],
        "Hard and durable with warm reddish tones, aka Hymenaea courbaril."
    ],
    "Pinus", [
        450,        // Density (kg/m³)
        30.0,       // Compressive Strength (MPa, estimated)
        8000,       // Modulus of Elasticity (MPa, estimated)
        "C20",      // Strength Class (estimated)
        ["framing", "plywood", "formwork"],
        "Softwood widely planted in southern Brazil for construction and pulp, aka Pinus elliottii."
    ],
    "Massaranduba", [
        1000,       // Density (kg/m³)
        58.0,       // Compressive Strength (MPa, estimated)
        14000,      // Modulus of Elasticity (MPa, estimated)
        "C50",      // Strength Class (estimated)
        ["decking", "structural beams", "flooring"],
        "Very dense and durable; resistant to weather and insects, aka Manilkara bidentata."
    ],
    "Angelim", [
        850,        // Density (kg/m³)
        52.0,       // Compressive Strength (MPa, estimated)
        12500,      // Modulus of Elasticity (MPa, estimated)
        "C40",      // Strength Class (estimated)
        ["structural beams", "bridges", "flooring"],
        "Strong and durable; common in Amazonian construction, aka Hymenolobium spp."
    ],
    "Cumaru", [
        950,        // Density (kg/m³)
        57.0,       // Compressive Strength (MPa, estimated)
        13800,      // Modulus of Elasticity (MPa, estimated)
        "C50",      // Strength Class (estimated)
        ["decking", "flooring", "structural supports"],
        "Highly durable with rich color; popular for outdoor use, aka Dipteryx odorata."
    ],
    // Global Woods
    "Oak", [
        700,        // Density (kg/m³)
        40.0,       // Compressive Strength (MPa, estimated)
        11000,      // Modulus of Elasticity (MPa, estimated)
        "C30",      // Strength Class (estimated)
        ["flooring", "furniture", "structural beams"],
        "Durable hardwood widely used in Europe and North America, aka Quercus robur."
    ],
    "Pine", [
        480,        // Density (kg/m³)
        30.0,       // Compressive Strength (MPa, estimated)
        8000,       // Modulus of Elasticity (MPa, estimated)
        "C20",      // Strength Class (estimated)
        ["framing", "plywood", "roofing"],
        "Softwood common globally for construction, aka Pinus sylvestris."
    ],
    "Cedar", [
        380,        // Density (kg/m³)
        25.0,       // Compressive Strength (MPa, estimated)
        7000,       // Modulus of Elasticity (MPa, estimated)
        "C20",      // Strength Class (estimated)
        ["siding", "decking", "structural elements"],
        "Lightweight with natural insect resistance, aka Cedrus spp."
    ],
    "Douglas Fir", [
        500,        // Density (kg/m³)
        35.0,       // Compressive Strength (MPa, estimated)
        9000,       // Modulus of Elasticity (MPa, estimated)
        "C30",      // Strength Class (estimated)
        ["framing", "beams", "flooring"],
        "Strong softwood prevalent in North American construction, aka Pseudotsuga menziesii."
    ],
    "Teak", [
        630,        // Density (kg/m³)
        38.0,       // Compressive Strength (MPa, estimated)
        10000,      // Modulus of Elasticity (MPa, estimated)
        "C30",      // Strength Class (estimated)
        ["outdoor furniture", "decking", "marine structures"],
        "Highly durable; resistant to moisture and insects, aka Tectona grandis."
    ],
    "Maple", [
        650,        // Density (kg/m³)
        40.0,       // Compressive Strength (MPa, estimated)
        11000,      // Modulus of Elasticity (MPa, estimated)
        "C30",      // Strength Class (estimated)
        ["flooring", "furniture", "structural elements"],
        "Hard and durable; common in North America, aka Acer saccharum."
    ],
    "Mahogany", [
        590,        // Density (kg/m³)
        35.0,       // Compressive Strength (MPa, estimated)
        9500,       // Modulus of Elasticity (MPa, estimated)
        "C30",      // Strength Class (estimated)
        ["furniture", "joinery", "flooring"],
        "Durable with rich color; used globally, aka Swietenia macrophylla."
    ],
    "Spruce", [
        400,        // Density (kg/m³)
        28.0,       // Compressive Strength (MPa, estimated)
        7500,       // Modulus of Elasticity (MPa, estimated)
        "C20",      // Strength Class (estimated)
        ["framing", "plywood", "roofing"],
        "Lightweight softwood common in Europe, aka Picea abies."
    ],
    "Walnut", [
        660,        // Density (kg/m³)
        38.0,       // Compressive Strength (MPa, estimated)
        10500,      // Modulus of Elasticity (MPa, estimated)
        "C30",      // Strength Class (estimated)
        ["furniture", "flooring", "cabinetry"],
        "Rich color and grain; used for high-end applications, aka Juglans regia."
    ],
    "Ash", [
        680,        // Density (kg/m³)
        40.0,       // Compressive Strength (MPa, estimated)
        11000,      // Modulus of Elasticity (MPa, estimated)
        "C30",      // Strength Class (estimated)
        ["flooring", "furniture", "structural elements"],
        "Strong and flexible; common in Europe, aka Fraxinus excelsior."
    ],
    "Bamboo", [
        700,        // Density (kg/m³, for engineered bamboo)
        50.0,       // Compressive Strength (MPa, estimated)
        12000,      // Modulus of Elasticity (MPa, estimated)
        "C40",      // Strength Class (estimated)
        ["flooring", "scaffolding", "structural panels"],
        "Fast-growing; used as engineered wood globally, aka Bambusa spp."
    ],
    "Hemlock", [
        450,        // Density (kg/m³)
        30.0,       // Compressive Strength (MPa, estimated)
        8500,       // Modulus of Elasticity (MPa, estimated)
        "C20",      // Strength Class (estimated)
        ["framing", "siding", "roofing"],
        "Softwood used in North America and Asia, aka Tsuga heterophylla."
    ],
    "Larch", [
        550,        // Density (kg/m³)
        35.0,       // Compressive Strength (MPa, estimated)
        9500,       // Modulus of Elasticity (MPa, estimated)
        "C30",      // Strength Class (estimated)
        ["cladding", "structural beams", "decking"],
        "Durable softwood; common in Europe and Asia, aka Larix decidua."
    ],
    // Engineered Woods
    "OSB", [
        650,        // Density (kg/m³)
        20.0,       // Compressive Strength (MPa, estimated)
        5000,       // Modulus of Elasticity (MPa, estimated)
        "N/A",      // Strength Class
        ["sheathing", "subflooring", "roofing"],
        "Engineered wood; cost-effective for structural panels, aka Oriented Strand Board."
    ],
    "Plywood", [
        600,        // Density (kg/m³)
        25.0,       // Compressive Strength (MPa, estimated)
        6000,       // Modulus of Elasticity (MPa, estimated)
        "N/A",      // Strength Class
        ["sheathing", "subflooring", "formwork"],
        "Layered engineered wood; versatile and strong, aka Laminated Wood."
    ],
    "CLT", [
        500,        // Density (kg/m³)
        30.0,       // Compressive Strength (MPa, estimated)
        8000,       // Modulus of Elasticity (MPa, estimated)
        "N/A",      // Strength Class
        ["structural walls", "floors", "roofs"],
        "Cross-laminated timber for modern construction, aka Cross-Laminated Timber."
    ],
    "MDF", [
        750,        // Density (kg/m³)
        15.0,       // Compressive Strength (MPa, estimated)
        3500,       // Modulus of Elasticity (MPa, estimated)
        "N/A",      // Strength Class
        ["furniture", "cabinetry", "non-structural panels"],
        "Uniform engineered wood for interior applications, aka Medium-Density Fiberboard."
    ],
    "LVL", [
        550,        // Density (kg/m³)
        35.0,       // Compressive Strength (MPa, estimated)
        9000,       // Modulus of Elasticity (MPa, estimated)
        "N/A",      // Strength Class
        ["beams", "headers", "structural supports"],
        "Strong engineered wood for structural use, aka Laminated Veneer Lumber."
    ]
]);
