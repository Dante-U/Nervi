include <constants.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: colors.scad
// Includes:
//   include <_core/colors.scad>;
// FileGroup: Core
// FileSummary: Colors, Material
//////////////////////////////////////////////////////////////////////

function colorsData() = struct_set([], [
    "Aluminium",   ["Linen",           [0.98, 0.941, 0.902], 1],
    "Bamboo",      ["Khaki",           [0.941, 0.902, 0.549], 1],
    "Brick",       ["IndianRed",       [0.804, 0.361, 0.361], 1],
    "Carpet",      ["DarkOliveGreen",  [0.333, 0.42, 0.184], 1],
    "Cedar",       ["#A0522D",         [0.627, 0.322, 0.176], 1],
    "Ceramic",     ["Beige",           [0.961, 0.961, 0.863], 1],
    "Chrome",      ["Silver",          [0.753, 0.753, 0.753], 0.8],
    "Clearing",    ["Orange",          [1, 0.647, 0], 0.4],
    "Concrete",    ["Gray",            [0.502, 0.502, 0.502], 1],
    "Cork",        ["BurlyWood",       [0.871, 0.722, 0.529], 1],
    "Curtain",     ["White",           [1, 1, 1], 0.8],
    "DarkGlass",   ["Black",           [0, 0, 0], 0.8],
    "Drywall",     ["MistyRose",       [1, 0.894, 0.882], 1],
    "Electronic",  ["DarkGray",        [0.663, 0.663, 0.663], 1],
    "Eucalipto",   ["Olive",           [0.5, 0.5, 0], 1],
    "Fabric",      ["Linen",           [0.98, 0.941, 0.902], 1],
    "Fir",         ["#DAA520",         [0.855, 0.647, 0.125], 1],
    "Glass",       ["LightBlue",       [0.678, 0.847, 0.902], 0.6],
    "Granite",     ["DimGray",         [0.412, 0.412, 0.412], 1],
    "Grass",       ["Green",           [0, 0.604, 0.090], 1],
    "Laminate",    ["Gainsboro",       [0.863, 0.863, 0.863], 1],
    "Leather",     ["SaddleBrown",     [0.545, 0.271, 0.075], 1],
    "Linoleum",    ["DarkGray",        [0.663, 0.663, 0.663], 1],
    "Maple",       ["#F5DEB3",         [0.961, 0.871, 0.702], 1],
    "Marble",      ["LightGray",       [0.827, 0.827, 0.827], 1],
    "Metal",       ["Silver",          [0.753, 0.753, 0.753], 1],
    "Oak",         ["#C19A6B",         [0.757, 0.604, 0.420], 1],
    "OSB",         ["#DEB887",         [0.871, 0.722, 0.529], 1],
    "Pine",        ["#DEB887",         [0.871, 0.722, 0.529], 1],
    "Plaster",     ["#FFFAF0",         [1, 0.98, 0.941], 1],
    "Plastic",     ["White",           [1, 1, 1], 1],
    "Plywood",     ["#D2B48C",         [0.824, 0.706, 0.549], 1],
    "Polyethylene",["LightGray",       [0.827, 0.827, 0.827], 1],
	"Primary",     ["IndianRed",       [0.804, 0.361, 0.361], 1],
    "Sand",        ["Tan",             [0.824, 0.706, 0.549], 1],
    "Steel",       ["DimGray",         [0.412, 0.412, 0.412], 1],
    "Stone",       ["SlateGray",       [0.439, 0.502, 0.565], 1],
    "Stucco",      ["Tan",             [0.824, 0.706, 0.549], 1],
    "Tar",         ["Dark Brown",      [0.235, 0.184, 0.184], 1],
    "Teak",        ["#8B5A2B",         [0.545, 0.353, 0.169], 1],
    "Template",    ["Gray",            [0.502, 0.502, 0.502], 0.6],
    "Teracotta",   ["Sienna",          [0.627, 0.421, 0.215], 1],
    "Tile",        ["LightSlateGray",  [0.467, 0.533, 0.6], 1],
    "Veneer",      ["Peru",            [0.804, 0.522, 0.247], 1],
    "Wood",        ["#DEB887",         [0.871, 0.722, 0.529], 1],
    "Wood2",       ["BurlyWood",       [0.850, 0.621, 0.6], 1],
    "YellowLight", ["Yellow",          [1, 1, 0], 0.1]
]);

// Module: material()
// 
// Synopsis: Applies the corresponding color to a given material.
// Description: 
//    This module colors its child object based on the material name.
// Arguments: 
//    name 			= Material name (e.g., "Wood", "Metal", "Glass").
//	  default		= Default material if name is not provided or wrong	
//    deep  		= If false color at current level only 
//    transparency  = Transparency 
// Example(3D,Small,ColorScheme=Tomorrow,NoAxes): Wood
//   material("Wood") cube([20,20,20]); 
// Example(3D,Small,ColorScheme=Tomorrow): Clearing
//   material("Clearing",0.2) cube([20,20,20]); 
// Example(3D,Small,ColorScheme=Tomorrow): Ghost
//   material("Ghost") cube([20,20,20]); 
//
module material( name, default, family, deep= true ,transparency) {
	assert(is_undef(transparency) || is_num(transparency),"[material] transparency could be undef or a number");
	_default = first_defined([ default, is_def(family) ? materialFamilyToMaterial(family) : undef ]);
	if (is_def(name) || is_def(_default)) {
		c = matColorSpec(name,fallBack = _default);
		newColor = flatten([c[1],c[2]]);
		if ( deep ) {
			$color=newColor;
			children();	
		}	
		else {
			$save_color=default($color,_default);
			$color=newColor;
			children();	
		}	
	} else {
		children();
	}	
}


// Function: matColor()
// 
// Synopsis: Returns the color corresponding to a given material.
// Topics: Materials, Colors
// Description: 
//    This function performs a lookup in the `colorsData()` table 
//    and returns the corresponding color for the given material name. 
//    If the material is not found, it returns "default" as a default color.
// Arguments: 
//    material = A string representing the material name (e.g., "Wood", "Metal").
// Example(3D,Small,ColorScheme=Tomorrow,NoAxes): 
//   cuboid(600,$color=matColor("Sand"));
//
function matColor( material ) =
	struct_val( colorsData() , material, default = ["default",1])[0];
	
// Function: matColorSpec()
// Synopsis: Returns the color specification for a given material.
// Topics: Materials, Colors
// Usage:
//   spec = matColorSpec(material, fallBack);
// Description:
//   Looks up the color specification (color name, RGB vector, transparency) for a given material in the
//   material_colors structure. If the material is not found or undefined, it attempts to use the fallBack
//   material. Returns undef if both material and fallBack are invalid.
// Arguments:
//   material = Material name (e.g., "Polyethylene", "Wood"). No default.
//   fallBack = Optional fallback material name if material is not found. Default: undef
// Returns:
//   A list [color_name, rgb_vector, transparency] (e.g., ["LightGray", [0.827, 0.827, 0.827], 1]), or undef.
// Example:
//   spec = matColorSpec("Polyethylene"); // ["LightGray", [0.827, 0.827, 0.827], 1]
//   spec = matColorSpec("Unknown", "Wood"); // ["#DEB887", [0.871, 0.722, 0.529], 1]
//   spec = matColorSpec("Unknown"); // undef
function matColorSpec( material, fallBack ) =
	let (
		data 	= colorsData(),
		found 	= is_def(material) ? struct_val(data, material) : undef,
		result 	= found ? found : fallBack ? struct_val(data, fallBack) : undef
	)
	result;

//echo ("matColorSpec",matColorSpec("Wood"));	
//echo ("matColorSpec with fallback",matColorSpec("glu",fallBack="Plywood"));	
	
// Module: applyColor()
//
// Synopsis: Applies the $color special variable to geometry if defined.
// Topics: Color, Geometry
// Usage:
//   applyColor() { <geometry> }
// Description:
//   Wraps the given geometry in a color() module if $color is defined.
//   If $color is undef, the geometry is rendered with the default color.
//   Useful for ensuring consistent color application across BOSL2 and native OpenSCAD modules.
//   Especially usefull with linear_extrude
// Example(ColorScheme=Tomorrow)
//   $color = "Blue";
//   applyColor() cuboid(20);  // Blue cuboid
// Example(ColorScheme=Tomorrow)
//   $color = "Blue";
//   applyColor() linear_extrude(50) rect(60);  // Blue extruded rectangle
// Example(ColorScheme=Tomorrow)
//   applyColor() cuboid(20);  // Default color (no $color defined)
module applyColor() {
  if (is_def($color) && $color != "default") {
    color($color) children();
  } else {
    children();
  }
}	

/**
 * Function: green_palette
 *
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

	
module reddish() {
	color("IndianRed") children(); 	
}	
module primary() {
	color("IndianRed") children(); 	
}	
module secondary() {
	color("IndianRed") children(); 	
}	

