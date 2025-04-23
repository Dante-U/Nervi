include <constants.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: colors.scad
// Includes:
//   include <BOSL2/std.scad>;
//   include <Nervi/_core/colors.scad>;
// FileGroup: Core
// FileSummary: Colors, Material
//////////////////////////////////////////////////////////////////////

material_colors = struct_set([], [
    "Wood",        ["#DEB887", 			[0.871, 0.722, 0.529]	, 1],
	"Wood2",  	   ["BurlyWood", 		[0.850, 0.621, 0.6]	, 1],
	"Pine",        ["#DEB887", 			[0.871, 0.722, 0.529], 1],
	"Oak",         ["#C19A6B", 			[0.757, 0.604, 0.420], 1],
	"Plywood",     ["#D2B48C", 			[0.824, 0.706, 0.549], 1],
	"Cedar",       ["#A0522D", 			[0.627, 0.322, 0.176], 1],
	"Fir",         ["#DAA520", 			[0.855, 0.647, 0.125], 1],
	"Maple",       ["#F5DEB3", 			[0.961, 0.871, 0.702], 1],
	"Teak",        ["#8B5A2B", 			[0.545, 0.353, 0.169], 1],

	"OSB",         ["#DEB887", 			[0.871, 0.722, 0.529], 1],	
	
	
	"Eucalipto",   ["Olive", 			[0.5, 0.5, 0]	, 1],
	
    "Metal",       ["Silver",  			[0.753, 0.753, 0.753]	, 1],
    "Glass",       ["LightBlue", 		[0.678, 0.847, 0.902]	, 0.6],  // Glass typically has some transparency
    "DarkGlass",   ["Black", 			[0, 0, 0]				, 0.8],  // Glass typically has some transparency
    "Plastic",     ["White", 			[1, 1, 1]				, 1],
    "Concrete",    ["Gray", 			[0.502, 0.502, 0.502]	, 1],
    "Brick",       ["IndianRed", 		[0.804, 0.361, 0.361]	, 1],
    "Stone",       ["SlateGray", 		[0.439, 0.502, 0.565]	, 1],
    "Marble",      ["LightGray", 		[0.827, 0.827, 0.827]	, 1],
    "Granite",     ["DimGray", 			[0.412, 0.412, 0.412]	, 1],
    "Ceramic",     ["Beige", 			[0.961, 0.961, 0.863]	, 1],
    "Tile",        ["LightSlateGray", 	[0.467, 0.533, 0.6]		, 1],
    "Fabric",      ["Linen", 			[0.98, 0.941, 0.902]	, 1],
    "Aluminium",   ["Linen", 			[0.98, 0.941, 0.902]	, 1],
    "Leather",     ["SaddleBrown", 		[0.545, 0.271, 0.075]	, 1],
    "Carpet",      ["DarkOliveGreen", 	[0.333, 0.42, 0.184]	, 1],
    "Laminate",    ["Gainsboro", 		[0.863, 0.863, 0.863]	, 1],
    "Veneer",      ["Peru", 			[0.804, 0.522, 0.247]	, 1],
    "Stucco",      ["Tan", 				[0.824, 0.706, 0.549]	, 1],
    
    "Drywall",     ["MistyRose", 		[1, 0.894, 0.882]		, 1],
    "Bamboo",      ["Khaki", 			[0.941, 0.902, 0.549]	, 1],
    "Plaster",     ["#FFFAF0", 			[1, 0.98, 0.941]		, 1],
    //"Plaster1",   ["#FFFAF0", [1, 0.98, 0.941], 1],
    //"Plaster2",   ["#FFFFF0", [1, 1, 0.941], 1],
    "Cork",        ["BurlyWood", 		[0.871, 0.722, 0.529]	, 1],
    "Linoleum",    ["DarkGray", 		[0.663, 0.663, 0.663]	, 1],
    "Steel",       ["DimGray", 			[0.412, 0.412, 0.412]	, 1],
    "Electronic",  ["DarkGray", 		[0.663, 0.663, 0.663]	, 1],
    // Special 
    "Clearing",    ["Orange", 			[1, 0.647, 0]			, 0.4],
    "Chrome",      ["Silver", 			[0.753, 0.753, 0.753]	, 0.8],
    "Curtain",     ["White", 			[1, 1, 1]				, 0.8],
    "YellowLight", ["Yellow", 			[1, 1, 0]				, 0.1],
	"Grass", 	   ["Green", 			[0, 0.604, 0.090]		, 1],
	"Sand", 	   ["Tan", 				[0.824, 0.706, 0.549]	, 1],
	"Tar", 	   	   ["Dark Brown", 		[0.235, 0.184, 0.184]	, 1],
	"Ghost", 	   ["Silver", 			[0.753, 0.753, 0.753]	, 0.3],
	"Teracotta",    ["Sienna", 			[0.627, 0.421, 0.215]	, 1],
	
]);

// Module: material()
// 
// Synopsis: Applies the corresponding color to a given material.
// Description: 
//    This module colors its child object based on the material name.
// Arguments: 
//    name 			= Material name (e.g., "Wood", "Metal", "Glass").
//    transparency  = Transparency 
//    deep  		= If false color at current level only 
// Example(3D,Small,ColorScheme=Nature,NoAxes): Wood
//   material("Wood") cube([20,20,20]); 
// Example(3D,Small,ColorScheme=Nature): Clearing
//   material("Clearing",0.2) cube([20,20,20]); 
// Example(3D,Small,ColorScheme=Nature): Ghost
//   material("Ghost") cube([20,20,20]); 
//
module material( name, transparency, deep= true ) {
	//req_children($children);  
	c = matColorSpec(name);
	newColor = flatten([c[1],c[2]]);
	if ( deep ) {
		$color=newColor;
		children();	
	}	
	else {
		$save_color=default($color,"default");
		$color=newColor;
		children();	
	}	
}


// Function: matColor()
// 
// Synopsis: Returns the color corresponding to a given material.
// Topics: Materials, Colors
// Description: 
//    This function performs a lookup in the `material_colors` table 
//    and returns the corresponding color for the given material name. 
//    If the material is not found, it returns "default" as a default color.
// Arguments: 
//    material = A string representing the material name (e.g., "Wood", "Metal").
// Example(3D,Small,ColorScheme=Nature,NoAxes): 
//   cuboid(600,$color=matColor("Sand"));
//
function matColor( material ) =
	struct_val(material_colors, material, default = ["default",1])[0];
	
// Function: matColorSpec()
// 
// Synopsis: Returns the color corresponding to a given material with the transparency.
// Topics: Materials, Colors
// Description: 
//    This function performs a lookup in the `material_colors` table 
//    and returns the corresponding color for the given material name. 
//    If the material is not found, it returns "default" as a default color.
// Arguments: 
//    material = A string representing the material name (e.g., "Wood", "Metal").
// DefineHeader(Generic)Returns: 
//    A color string corresponding to the material (e.g., "DarkKhaki" for "Wood") with the transparency.	
function matColorSpec( material ) =
	struct_val(material_colors, material, default = ["default",1]);	


/**
 * Function: green_palette
 * Description: Generates a shade of green based on a factor f.
 * Parameters:
 *   f - Factor from 0 to 1
 * Returns: RGB color as [r, g, b], each from 0 to 1
 */
function green_palette(f) =
    let(
        // Hue: Fixed at 120 (green)
        hue = 120,
        // Saturation: Varies from 0.5 to 0.8
        saturation = 0.5 + f * (0.8 - 0.5),
        // Value: Varies from 0.3 to 0.9
        value = 0.3 + f * (0.9 - 0.3)
    )
	hsv(hue, saturation, value);
