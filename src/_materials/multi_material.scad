include <../_core/constants.scad>

use <masonry.scad>
use <metal.scad>
use <wood.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: multi_material.scad
//   Masonry material specs
// Includes:
//   include <_materials/multi_material.scad>
// FileGroup: Materials
// FileSummary: Multi material specs
//////////////////////////////////////////////////////////////////////

// Function: materialSpec()
//
// Synopsis: Retrieves material properties for a specified material type and name.
// Topics: Materials, Specifications
// See Also:  woodSpecs(), metalSpecs(), masonrySpecs()
// Usage:
//   density = materialSpec(family,material,property);
// Description:
//   Returns the value of a specified property (e.g., density, unit price) for a given
//   material type and name. Supports three material types: Wood, Metal, and Masonry,
//   delegating to woodSpecs(), metalSpecs(), or masonrySpecs() based on the type.
//   Commonly used in structural design to access material characteristics for
//   calculations like weight, cost, or volume. If the type is invalid, returns undef.
// Arguments:
//   family        	= Material type (WOOD, METAL, MASONRY).
//   material 		= Specific material name (e.g., "Concrete", "Steel", "Pine").
//   property     	= Property to retrieve (e.g., MATERIAL_DENSITY, MATERIAL_UNIT_PRICE).
//
// Example:
//   density = materialSpec(MASONRY, "Concrete", MATERIAL_DENSITY); // kg/m³
//
function materialSpec ( family,material,property ) =
	assert (is_def(family),						"[materialSpec] missing material family")
	assert (isValidMaterialFamilies(family), 	"[materialSpec] invalid material family")
	assert (material,							"[materialSpec] missing material name")
	assert (is_def(property),					"[materialSpec] missing property")
	let (
		spec = 
			family == WOOD 		? woodSpecs(material,property) : 
			family == METAL 	? metalSpecs(material,property) : 
			family == MASONRY 	? masonrySpecs(material,property) : 
			undef,
	)
	spec;