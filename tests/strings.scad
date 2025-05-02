include <BOSL2/std.scad>
include <../src/_core/strings.scad>



 test_replace();
 test_start_with();
 test_end_with();
 test_upper();
 test_lower();
 test_between();
 test_index_of();
 test_substring();
 test_equals();
 test_before();
 test_replace();

test_parse_int();
test_left_pad();

test_format_weight();
test_format_volume();
test_format_area();
test_format_length();
test_format_section();


module test_format_weight(){
	assert_equal(formatWeight(1000),"1000 Kg");
	assert_equal(formatWeight(1000,"g"),"1000 g");
}

module test_format_volume() {
	assert_equal(formatVolume(2)		,"2 m³"	);
	assert_equal(formatVolume(2,undef)	,"2 m³"	);
	assert_equal(formatVolume(2,"l")	,"2 l"	);
}

module test_format_area() {
	assert_equal(formatArea(2)		,"2 m²"	);
	assert_equal(formatArea(20000)	,"2 ha"	);
	assert_equal(formatArea(2,"mm²"),"2 mm²");
}

module test_format_section(){
	assert_equal(formatSection([200,300]),"20 cm x 30 cm");
	assert_equal(formatSection([200,300],"mm"),"200 mm x 300 mm");
	assert_equal(formatSection([200,300],"m"),"0.2 m x 0.3 m");
}



module test_format_length(){
	
}

  
  
module test_replace() {

s = replace("Hello, World! Hello again!", "Hello", "Hi");
assert (s == "Hi, World! Hi again!");

assert (replace("16,7"		,"," 	,".") == "16.7");

assert (replace("16.97''"	, "''", "") == "16.97");
//assert (replace("16.97"		, "''", "") == "16.97");

}


module test_start_with(){
	assert_equal(starts_with("OneTwo","One"),true);
	
	assert_equal(starts_with("OneTwo","one",ignore_case=true),true);
	assert_equal(starts_with("OneTwo","one",ignore_case=false),false);
	assert_equal(starts_with("OneTwo","Two"),false);
}

module test_end_with(){
	assert_equal(ends_with("OneTwo","One"),false);
	assert_equal(ends_with("OneTwo","Two"),true);
}

module test_upper() {
	assert_equal (upper("AbCd"),"ABCD");
}

module test_lower() {
	assert_equal (lower("AbCd"),"abcd");

}

module test_between() {
	assert_equal (between("Hello, World!", 7, 12),"World");
	assert_equal (between("Hello, World!", 0, 5),"Hello");
}

module test_index_of() {
	assert_equal (index_of("123.456.789","."),[[3,4],[7,8]]);
	
	// Basic string matching tests
	assert_equal(index_of("hello world", "hello"), 	[[0, 5]]	, "Basic string match");
	assert_equal(index_of("hello world", "world"), 	[[6, 11]]	, "Match at end");
	assert_equal(index_of("hello world", "o"), 		[[4, 5],[7,8]]	, "Single character match");

	// Case sensitivity tests
	assert_equal(index_of("Hello World", "hello"), 	[]			, "Case sensitive default");
	assert_equal(index_of("Hello World", "hello", ignore_case=true), [[0, 5]], "Case insensitive match");
	assert_equal(index_of("HELLO WORLD", "hello", ignore_case=true), [[0, 5]], "Upper to lower case match");


	// Position and empty result tests
	assert_equal(index_of("hello world", "xyz"), 	[], "No match found");
	assert_equal(index_of("", "test"), 				[], "Empty string");

	assert_equal(index_of("hello", ""), 			[], "Empty pattern");

	assert_equal(index_of("hello hello", "hello"), [[0, 5],[6,11]], "Two occurrence only");

	// Edge cases
	assert_equal(index_of("a", "a"), 				[[0, 1]], "Single character string and pattern");
	//assert_equal(index_of("test", "t", pos=1), 		[], "Position parameter test");
	/*
	*/
	
	
}

module test_substring() {
	// Basic extraction tests
	assert_equal(substring("Hello, World!", 0, 5), "Hello", 	"Extract first 5 characters");
	assert_equal(substring("Hello, World!", 7, 6), "World!", 	"Extract last word with punctuation");
	assert_equal(substring("Test", 1, 2), "es", 				"Extract middle characters");

	// Extract to end (length=undef)
	assert_equal(substring("Hello, World!", 0), 				"Hello, World!", "Extract from start to end");
	assert_equal(substring("Hello, World!", 7), 				"World!", "Extract from middle to end");
	assert_equal(substring("Hello", 4), "o", 					"Extract single character to end");

	// Edge cases
	assert_equal(substring("Hello", 5), "", 					"Start at string length returns empty");
	assert_equal(substring("", 0), "", 							"Empty string with valid start");
	assert_equal(substring("Hello", 0, 0), "", 					"Zero length returns empty");

	// Out-of-bounds and invalid cases (assuming between() behavior)
	assert_equal(substring("Hello", 10), undef, 				"Start beyond length returns undef");
	assert_equal(substring("Hello", -1), "Hello", 				"Negative start returns full string (via between)");
	assert_equal(substring("Hello", 2, 10), "llo", 				"Length beyond end returns to end");

	// Assuming between() returns undef for invalid string input
	assert_equal(substring(undef, 0, 5), undef, 				"Undefined string input");
}

module test_equals() {
	// Basic equality tests
	assert_equal(equals("hello", "hello"), true, 						"Identical strings");
	assert_equal(equals("hello", "world"), false, 						"Different strings");
	assert_equal(equals("", ""), true, 									"Empty strings equal");

	// Case sensitivity tests
	assert_equal(equals("Hello", "hello"), false, 						"Case sensitive by default");
	assert_equal(equals("Hello", "hello", ignore_case=true), true, 		"Case insensitive match");
	assert_equal(equals("WORLD", "world", ignore_case=true), true, 		"Upper to lower case match");
	assert_equal(equals("HeLLo", "hEllO", ignore_case=true), true, 		"Mixed case match");

	// Edge cases
	assert_equal(equals("hello", "hello "), false, 						"Trailing space matters");
	assert_equal(equals("hello ", "HELLO ", ignore_case=true), true, 	"Trailing space with ignore case");
	assert_equal(equals("", " ", ignore_case=true), false, 				"Empty vs space");

	// Invalid inputs (assuming behavior with undef)
	assert_equal(equals(undef, "hello"), false, 						"Undef vs string");
	assert_equal(equals("hello", undef), false, 						"String vs undef");
	assert_equal(equals(undef, undef), true, 							"Undef vs undef");

	// Non-string inputs (assuming OpenSCAD type coercion or lower() handles it)
	assert_equal(equals(123, "123"), false, 							"Number vs string");
	assert_equal(equals("123", "123", ignore_case=true), true, 			"String numbers with ignore case");

}

module test_before() {
	// Basic extraction tests
	assert_equal(before("Hello, World!", 5), "Hello", 			"Extract before comma");
	assert_equal(before("Hello", 2), "He", 						"Extract first two characters");
	assert_equal(before("Test", 4), "Test", 					"Index equals string length");

	// Edge cases
	assert_equal(before("Hello", 0), "", 						"Index 0 returns empty");
	assert_equal(before("Hello", -1), "", 						"Negative index returns empty");
	assert_equal(before("Hello", 6), "Hello", 					"Index beyond length returns full string");
	assert_equal(before("", 0), "", 							"Empty string with index 0");

	// Invalid inputs
	assert_equal(before(undef, 5), undef, 						"Undefined string");
	assert_equal(before("Hello", undef), undef, 				"Undefined index");

	// Boundary conditions
	assert_equal(before("a", 1), "a", 							"Single character with index at length");
	assert_equal(before("ab", 1), "a", 							"Two characters with index in middle");
	assert_equal(before("Hello, World!", 12), "Hello, World", 	"Index at exact length");
}

module test_replace(){
	assert_equal(replace("Hello, World!", "World", "Universe"), 	"Hello, Universe!", "Single replacement");
	assert_equal(replace("Hello Hello", "Hello", "Hi"), "Hi Hi", 	"Multiple replacements");
	assert_equal(replace("Test", "t", "x"), "Tesx", 				"Single character replacement");

	// Case sensitivity tests
	assert_equal(replace("Hello HELLO hello", "hello", "hi"), "Hello HELLO hi", "Case sensitive default");
	assert_equal(replace("Hello HELLO hello", "hello", "hi", ignore_case=true), "hi hi hi", "Case insensitive replacement");

	// Edge cases
	assert_equal(replace("Hello", "", "x"), "Hello", 								"Empty pattern returns original");
	assert_equal(replace("", "test", "x"), "", 										"Empty string with pattern");
	assert_equal(replace("Hello", "xyz", "abc"), "Hello", 							"No match returns original");
	assert_equal(replace("Hello!", "Hello", ""), "!", 								"Replace with empty string");


	// Invalid inputs
	assert_equal(replace(undef, "test", "x"), undef, 								"Undefined string");

	assert_equal(replace("Hello", undef, "x"), "Hello", 							"Undefined pattern return input");
		/*
	// Overlapping cases (assuming replace handles first occurrence per index_of behavior)
	assert_equal(replace("aaa", "aa", "b"), "ba", 									"Overlapping pattern replaces first occurrence");
	*/

}




module test_parse_int() {
	assert_equal(parse_int("+6"),6);
	assert_equal(parse_int("-6"),-6);
}

module test_left_pad() {
	assert_equal( str_left_pad("Hello",8,"_"), "___Hello");
}
