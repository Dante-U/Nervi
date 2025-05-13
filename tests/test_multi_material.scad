include <../src/_core/constants.scad>
use <../src/_materials/multi_material.scad>

test_materialSpec();

module test_materialSpec(){
	assert_equal(materialSpec( WOOD, 	"Pine",		MATERIAL_DENSITY ),	480);
	assert_equal(materialSpec( METAL, 	"Steel",	MATERIAL_DENSITY ),	7850);
	assert_equal(materialSpec( MASONRY, "Concrete",	MATERIAL_DENSITY ),	2400);
}

