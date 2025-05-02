include <../src/_core/metadata.scad>


test_meta_spec();
test_parse_metric_unit();
test_retrieve_info();



module test_meta_spec() {

	assert_equal(metaSpec("volume")[0],"Volume","Title for spec 'volume' should be 'Volume'");
}

module test_parse_metric_unit(){
	assert_equal(parseMetricUnit("volume,l"),	["volume", "l"	]);
	assert_equal(parseMetricUnit("volume"),		["volume", undef]);
}


module test_retrieve_info() {

	// Volume without units
	assert_equal(
		retrieveInfo( data = [["volume",5]]),
		[["Volume","5 m³",""]],
		"Retrieve volume info with explicit data"
	);
	// Volume with liter units
	assert_equal( retrieveInfo( data = [["volume,l",5]]), 	[["Volume","5 l",""]] );
	
	
	assert_equal( retrieveInfo( data = [["unit_price",5]]), 	[["Unit Price","$5.00",""]] );
	assert_equal( retrieveInfo( data = [["unit_price,R$",5]]), 	[["Unit Price","R$5.00",""]] );
	
	
	assert_equal( retrieveInfo( data = [["weight",5]]), 	[["Weight","5 Kg",""]] );
	assert_equal( retrieveInfo( data = [["weight,g",5]]), 	[["Weight","5 g",""]] );
	
	
	assert_equal( retrieveInfo( data = [["area",2]]), 		[["Area","2 m²",""]] );
	assert_equal( retrieveInfo( data = [["area,mm²",2]]), 	[["Area","2 mm²",""]] );

	assert_equal( retrieveInfo( data = [["perimeter",2]]), 		[["Perimeter","2 m",""]] );
	assert_equal( retrieveInfo( data = [["perimeter,km",2]]), 	[["Perimeter","2 km",""]] );

	assert_equal( retrieveInfo( data = [["section",		[200,300]]]), 	[["Section","20 cm x 30 cm",""]] );
	assert_equal( retrieveInfo( data = [["section,mm",	[200,300]]]), 	[["Section","200 mm x 300 mm",""]] );
	assert_equal( retrieveInfo( data = [["section,cm",	[200,300]]]), 	[["Section","20 cm x 30 cm",""]] );
	
	
	assert_equal( retrieveInfo( data = [["name","Eureka"]]), 	[["Name","Eureka",""]] );
	
}






