//////////////////////////////////////////////////////////////////////
// LibFile: _common.scad
//   Material Specs constants 
// Includes:
//   include <_materials/_common.scad>
// FileGroup: Materials
// FileSummary: Material specs constants
//////////////////////////////////////////////////////////////////////

// Constant: MATERIAL_DENSITY
// Description: Index for material density value (kg/m³)
MATERIAL_DENSITY = 0;

// Constant: MATERIAL_COMPRESSIVE_STRENGTH
// Description: Index for material compressive strength (MPa)
MATERIAL_COMPRESSIVE_STRENGTH = 1;

// Constant: MATERIAL_ELASTICITY
// Description: Index for material elasticity/modulus of elasticity (GPa)
MATERIAL_ELASTICITY = 2;

// Constant: MATERIAL_STRENGTH_CLASS
// Description: Index for material strength classification
MATERIAL_STRENGTH_CLASS = 3;

// Constant: MATERIAL_APPLICATION
// Description: Index for recommended applications
MATERIAL_APPLICATION = 4;

// Constant: MATERIAL_DESCRIPTION
// Description: Index for general description of the material
MATERIAL_DESCRIPTION = 5;


STRUCTURE_MATERIAL_FAMILIES = [ "Wood", "Metal", "Masonry" ];


function isValidMaterialFamilies ( value ) = 
	is_def(value)  && in_list(value,STRUCTURE_MATERIAL_FAMILIES);
	
function materialFamilyToMaterial( family  ) =
	assert (isValidMaterialFamilies(family),"[materialFamilyToMaterial] is not a valid family name")
	family == "Wood" 	? "Pine" : 	
	family == "Metal" 	? "Steel" : 	
	family == "Masonry"	? "Concrete" : 	
	undef;	
	
