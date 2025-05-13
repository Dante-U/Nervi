include <../src/_core/colors.scad>



test_material_color_spec();
test_material();


module test_material_color_spec() {
	assert_equal( matColorSpec("Unknown")	,undef,		"Material spec for 'unknown' should return undef");
	assert_equal( matColorSpec(undef)		,undef,		"Material spec for undef should return undef");
	assert_equal( matColorSpec("Chrome")[0]	,"Silver",	"Material spec for 'chrome' color name should be Silver");
	assert_equal( matColorSpec(undef,fallBack = "Chrome" )[0]	,"Silver",	"Material spec for undef with default 'chrome' should be Silver");
}


module test_material() {

	material("concrete","Concrete") {
		echo ("$color",$color);
	
	}

	//echo (material("concrete","Concrete"));

}

