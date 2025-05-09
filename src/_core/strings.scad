include <constants.scad>
include <BOSL2/fnliterals.scad>

use <assert.scad>
use <math.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: strings.scad
//   String handling
// Stronglxy inspired by https://github.com/davidson16807/relativity.scad/blob/master/strings.scad
// Includes:
//   include <_core/strings.scad>
// FileGroup: Utils
// FileSummary: String utilities
//////////////////////////////////////////////////////////////////////

// Function: str_center_pad()
//
// Synopsis: Centers a string with padding.
// Topics: Text Formatting, Utilities
// Description:
//   Pads a string on both sides with a specified character to reach a given length.
// Arguments:
//   str = The string to pad.
//   length = Desired total length.
//   char = Padding character [default: " "].
// Example:
//   padded = str_center_pad("Test", 10);  // Returns "   Test   "	
function str_center_pad( str, length, char=" " ) =
    assert(is_str(str), "str must be a string")
    assert(is_num(length) && length >= 0, "length must be a non-negative number")
    assert(is_str(char) && len(char) == 1, "char must be a single character string")
    let (
        str_len = len(str),
        padding_total = length - str_len
    )
    padding_total <= 0 ? str : // Return unchanged if str is too long
    let (
        pad_left = floor(padding_total / 2),
        pad_right = padding_total - pad_left,
        left_padding = str_join([for (i = [1:pad_left]) char], ""),
        right_padding = str_join([for (i = [1:pad_right]) char], "")
    )
    str(left_padding, str, right_padding);

// Function: str_left_pad()
// Synopsis: Left-pads a string with a specified character to reach a given length.
// Topics: Text Formatting, Utilities
// Description:
//   Pads a string on the left side with a specified character to reach a given length.
// Arguments:
//   str = The string to pad.
//   length = Desired total length.
//   char = Padding character [default: " "].
// Example:
//   padded = str_left_pad("Test", 10);  // Returns "      Test"
function str_left_pad(str, length, char=" ") =
    assert(is_str(str), "str must be a string")
    assert(is_num(length) && length >= 0, "length must be a non-negative number")
    assert(is_str(char) && len(char) == 1, "char must be a single character string")
    let (
        str_len = len(str),
        padding_total = length - str_len
    )
    padding_total <= 0 ? str : // Return unchanged if str is too long
    let (
        left_padding = str_join([for (i = [1:padding_total]) char], "")
    )
    str(left_padding, str);

	
// Function: replace()
// 
// Synopsis: Replaces all occurrences of a pattern in a string with a replacement string.
// Topics: String Manipulation, Text Processing
// See Also: index_of()
// Description:
//    Replaces all occurrences of a specified substring or pattern in the input string with a replacement string.
//    Supports both exact string matching and regular expression matching, with optional case-insensitive comparison.
//    Uses index_of() to locate all matches and delegates the replacement logic to replace_at_indices(). If no matches are found,
//    the original string is returned unchanged.
// Arguments:
//    string = The input string to process.
//    replaced = The substring or pattern to search for and replace.
//    replacement = The string to insert in place of each match.
//    ignore_case = If true, performs a case-insensitive search. [default: false]
//    regex = If true, treats replaced as a regular expression pattern. [default: false]
// Returns:
//    A new string with all occurrences of the replaced pattern substituted with the replacement string.
// Example(3D,ColorScheme=Tomorrow)
//    s = replace("Hello, World!", "World", "Universe");
//    color("green")
//    translate([0, 0, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: Hello, Universe!
// Example(3D,ColorScheme=Tomorrow)
//    s = replace("HELLO hello HeLLo", "hello", "hi", ignore_case=true);
//    color("green")
//    translate([0, 20, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: hi hi hi
function replace(string, replaced, replacement, ignore_case=false, regex=false) = 
	is_undef(string) || is_undef(replaced) ?
			string : replace_at_indices(string, replacement, index_of( string, replaced, ignore_case=ignore_case, regex=regex));	

function replace_at_indices(string, replacement, indices, i=0) = 
	len(indices) == 0 ? string :  // Return original string if no matches
    i >= len(indices)?
        after(string, indices[len(indices)-1].y-1)
    : i == 0?
        str( before(string, indices[0].x), replacement, replace_at_indices(string, replacement, indices, i+1) )
    :
        str( between(string, indices[i-1].y, indices[i].x), replacement, replace_at_indices(string, replacement, indices, i+1) )
    ;

// Function: index_of()
// 
// Synopsis: Finds the first occurrence of a pattern in a string.
// Topics: String Manipulation, Pattern Matching
// See Also: replace(), starts_with(), search_index()
// Description:
//    Searches for the first occurrence of a specified pattern within a string and returns its position as a [start, end] array.
//    Supports both exact string matching and regular expression matching, with optional case-insensitive comparison.
//    Returns an empty array [] if no match is found or if the pattern is empty.
//    Delegates to search_index() for the actual search after handling the empty pattern case and regex parsing.
// Arguments:
//    string = The input string to search within.
//    pattern = The substring or regular expression pattern to search for.
//    ignore_case = If true, performs a case-insensitive comparison. [default: false]
//    regex = If true, treats the pattern as a regular expression. [default: false]
// Returns:
//    An array [start, end] containing the start (inclusive) and end (exclusive) indices of the first match,
//    or an empty array [] if no match is found or if the pattern is empty.
// Example(3D,ColorScheme=Tomorrow)
//    result = index_of("Hello, World!", "World");
//    if (result != []) {
//        color("green")
//        translate([0, 0, 0])
//        linear_extrude(height=1)
//        text(str("Found at: ", result), size=10);  // Outputs: Found at: [7, 12]
//    }
// Example(3D,ColorScheme=Tomorrow)
//    result = index_of("Hello, WORLD!", "world", ignore_case=true);
//    if (result != []) {
//        color("green")
//        translate([0, 20, 0])
//        linear_extrude(height=1)
//        text(str("Found at: ", result), size=10);  // Outputs: Found at: [7, 12]
//    }
// Example(3D,ColorScheme=Tomorrow)
//    result = index_of("Hello, World!", "");
//    if (result == []) {
//        color("red")
//        translate([0, 40, 0])
//        linear_extrude(height=1)
//        text("Empty pattern returns []", size=10);
//    }
function index_of(string, pattern, ignore_case=false, regex=false) = 
	pattern == "" ? [] : search_index(string, regex? _parse_rx(pattern) : pattern, regex=regex, ignore_case=ignore_case);

// Function: search_index()	
function search_index(string, pattern, pos=0, regex=false, ignore_case=false) = 		//[start,end]
	pos == undef?
        undef
	: pos >= len(string)?
		[]
	:
        search_index_recurse(string, pattern, 
            search_first(string, pattern, pos=pos, regex=regex, ignore_case=ignore_case),
            pos, regex, ignore_case)
	;	
	
function search_index_recurse(string, pattern, index_of_first, pos, regex, ignore_case) = 
    index_of_first == undef?
        []
    : concat(
        [index_of_first],
        fallback_if(
            search_index(string, pattern, 
                    pos = index_of_first.y,
                    regex=regex,
                    ignore_case=ignore_case),
            undef,
            [])
    );	
	
function search_first(string, pattern, pos=0, ignore_case=false, regex=false) =
	assert(pattern,"[search_first] pattern is undefined")
	pos == undef?
        undef
    : pos >= len(string)?
		undef
	: fallback_if([pos, _match(string, pattern, pos, regex=regex, ignore_case=ignore_case)], 
		[pos, undef],
		search_first(string, pattern, pos+1, regex=regex, ignore_case=ignore_case))
    ;	
	
function _match(string, pattern, pos, regex=false, ignore_case=false) = 
    assert(is_str(string), 			"[_match] string must be a string")
    assert(is_str(pattern), 		"[_match] pattern must be a string")
    assert(is_num(pos) && pos >= 0, "[_match] pos must be a non-negative number")
    regex?
    	_match_parsed_peg(string, undef, pos, peg_op=pattern, ignore_case=ignore_case)[_POS]
    : starts_with(string, pattern, pos, ignore_case=ignore_case)? 
        pos+len(pattern) 
    : 
        undef
    ;

// Function: fallback_if()
// 
// Synopsis: Returns a fallback value if the input matches an error condition.
// Topics: Utilities, Control Flow
// Description:
//    Evaluates an input value against a specified error condition and returns the fallback value if they match,
//    otherwise returns the original value. This function serves as a simple conditional selector, often used
//    to handle edge cases or undefined results in recursive operations. It is an internal helper function
//    within the string manipulation library.
// Arguments:
//    value = The input value to check.
//    error = The condition or value that triggers the use of the fallback (e.g., undef).
//    fallback = The value to return if the input matches the error condition.
// Returns:
//    The original value if it does not match the error condition, otherwise the fallback value.
// Example:
//    result = fallback_if(10, undef, 0);
//    echo(result);  // Outputs: 10
// Example:
//    result = fallback_if(undef, undef, 100);
//    echo(result);  // Outputs: 100	
function fallback_if(value, error, fallback) = 
	value == error ? fallback : value ;

// Function: starts_with()
// 
// Synopsis: Checks if a string starts with a specified substring.
// Topics: String Manipulation, Pattern Matching
// See Also: substring(), equals()
// Description:
//    Determines whether a string begins with a specified substring, starting from a given position.
//    Supports both exact matching and regular expression matching, with optional case-insensitive comparison.
//    If regex is true, uses _match_parsed_peg and _parse_rx for pattern matching; otherwise, performs a direct substring comparison.
// Arguments:
//    string 		= The input string to check.
//    start 		= The substring or pattern to search for at the start.
//    pos 			= The starting position in the string to begin the check. [default: 0]
//    ignore_case 	= If true, performs a case-insensitive comparison. [default: false]
//    regex 		= If true, treats start as a regular expression pattern. [default: false]
// Returns:
//    true if the string starts with the specified substring or matches the pattern, false otherwise.
// Example(3D,ColorScheme=Tomorrow)
//    if (starts_with("Hello, World!", "Hello")) {
//        color("green")
//        translate([0, 0, 0])
//        linear_extrude(height=1)
//        text("Match!", size=10);
//    }
// Example(3D,ColorScheme=Tomorrow)
//    if (starts_with("Hello, World!", "HELLO", ignore_case=true)) {
//        color("green")
//        translate([0, 20, 0])
//        linear_extrude(height=1)
//        text("Case-insensitive match!", size=10);
//    }	
function starts_with( string, start, pos=0, ignore_case=false, regex=false ) = 
    assert(is_str(string), 			"[starts_with] string must be a string")
    assert(is_str(start), 			"[starts_with] start must be a string")
    assert(is_num(pos) && pos >= 0, "[starts_with] pos must be a non-negative number")
	regex?
		_match_parsed_peg(string,
			undef,
			pos, 
			_parse_rx(start), 
			ignore_case=ignore_case) != undef
	:
		equals(	substring(string, pos, len(start)), 
			start, 
			ignore_case = ignore_case)
	;

// Function: ends_with()
// 
// Synopsis: Checks if a string ends with a specified substring.
// Topics: String Manipulation, Pattern Matching
// See Also: after(), equals()
// Description:
//    Determines whether a string ends with a specified substring.
//    Supports case-sensitive or case-insensitive comparison based on the ignore_case parameter.
//    Uses helper functions from _core.scad for substring extraction and comparison.
// Arguments:
//    string = The input string to check.
//    end = The substring to search for at the end.
//    ignore_case = If true, performs a case-insensitive comparison. [default: false]
// Returns:
//    true if the string ends with the specified substring, false otherwise.
// Example(3D,ColorScheme=Tomorrow)
//    if (ends_with("Hello, World!", "World!")) {
//        color("green")
//        translate([0, 0, 0])
//        linear_extrude(height=1)
//        text("Match!", size=10);
//    }
// Example(3D,ColorScheme=Tomorrow)
//    if (ends_with("Hello, WORLD!", "WORLD!", ignore_case=true)) {
//        color("green")
//        translate([0, 20, 0])
//        linear_extrude(height=1)
//        text("Case-insensitive match!", size=10);
//    }	
function ends_with(string, end, ignore_case=false) =
	equals(	after(string, len(string)-len(end)-1), end,ignore_case=ignore_case);

	
// Function: upper()
// 
// Synopsis: Converts a string to uppercase.
// Topics: String Manipulation, Text Processing
// See Also: ascii_code(), join()
// Description:
//    Transforms all lowercase characters in a string to uppercase.
//    Uses helper functions from _core.scad to convert characters based on ASCII codes.
//    Non-lowercase characters (e.g., numbers, symbols) remain unchanged.
// Arguments:
//    string = The input string to convert to uppercase.
// Returns:
//    A new string with all lowercase characters converted to uppercase.
// Example(3D,ColorScheme=Tomorrow)
//    s = upper("Hello, World!");
//    color("green")
//    translate([0, 0, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: HELLO, WORLD!
// Example(3D,ColorScheme=Tomorrow)
//    s = upper("Mixed123Case");
//    color("green")
//    translate([0, 20, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: MIXED123CASE
function upper(string) = 
	let( code = ascii_code( string ) ) join([for (i = [0:len(string)-1]) code[i] >= 97 && code[i] <= 122 ? chr(code[i]-97+65):string[i]]);

		
// Function: lower()
// 
// Synopsis: Converts a string to lowercase.
// Topics: String Manipulation, Text Processing
// See Also: ascii_code(), join()
// Description:
//    Transforms all uppercase characters in a string to lowercase.
//    Uses helper functions from _core.scad to convert characters based on ASCII codes.
//    Non-uppercase characters (e.g., numbers, symbols) remain unchanged.
// Arguments:
//    string = The input string to convert to lowercase.
// Returns:
//    A new string with all uppercase characters converted to lowercase.
// Example(3D,ColorScheme=Tomorrow)
//    s = lower("Hello, WORLD!");
//    color("green")
//    translate([0, 0, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: hello, world!
// Example(3D,ColorScheme=Tomorrow)
//    s = lower("MIXED123CASE");
//    color("green")
//    translate([0, 20, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: mixed123case		
function lower(string) = 
	let(code = ascii_code( string ) )
		join([for (i = [0:len(string)-1])code[i] >= 65 && code[i] <= 90?chr(code[i]+97-65):string[i]]);	
	

_ASCII_SPACE 	= 32;
_ASCII_0 		= 48;
_ASCII_9 		= _ASCII_0 + 9;
_ASCII_UPPER_A 	= 65;
_ASCII_UPPER_Z 	= _ASCII_UPPER_A + 25;
_ASCII_LOWER_A 	= 97;
_ASCII_LOWER_Z 	= _ASCII_LOWER_A + 25;
_ASCII = "\t\n\r !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
_ASCII_HACK = "\""; // only here to work around syntax highlighter defficiencies in certain text editors
_WHITESPACE = " \t\r\n";
_ASCII_CODE = concat(9,10,13, [for(i=[_ASCII_SPACE : _ASCII_LOWER_Z+4]) i]);

// Function: ascii_code()
function ascii_code(string) = 
	!is_string(string) ? undef : [for (result = search(string, _ASCII, 0)) result == undef ? undef : _ASCII_CODE[result[0]]];

// Function: substring()
// 
// Synopsis: Extracts a portion of a string starting at a given index.
// Topics: String Manipulation, Text Processing
// See Also: between(), before(), after()
// Description:
//    Returns a substring of the input string starting at the specified index. If a length is provided,
//    it extracts that many characters; otherwise, it extracts from the start index to the end of the string.
//    Relies on the between() function to perform the actual extraction, handling edge cases such as
//    invalid indices or lengths internally.
// Arguments:
//    string = The input string to extract from.
//    start = The starting index (inclusive) of the substring.
//    length = The number of characters to extract. If undefined, extracts to the end of the string. [default: undef]
// Returns:
//    The extracted substring, or an empty string if the start index is beyond the string length,
//    or undef if the input is invalid.
// Example(3D,ColorScheme=Tomorrow)
//    s = substring("Hello, World!", 0, 5);
//    color("green")
//    translate([0, 0, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: Hello
// Example(3D,ColorScheme=Tomorrow)
//    s = substring("Hello, World!", 7);
//    color("green")
//    translate([0, 20, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: World!	
function substring(string, start, length=undef) = 
	length == undef ? between(string, start, len(string)) : between(string, start, length+start);	

// Function: equals()
// 
// Synopsis: Compares two strings for equality.
// Topics: String Manipulation, Comparison
// See Also: lower(), starts_with(), ends_with()
// Description:
//    Determines if two strings are equal, with an option for case-insensitive comparison.
//    If ignore_case is true, converts both strings to lowercase before comparing using the lower() function;
//    otherwise, performs a direct string comparison. Useful for validating string matches in various contexts.
// Arguments:
//    this = The first string to compare.
//    that = The second string to compare.
//    ignore_case = If true, performs a case-insensitive comparison. [default: false]
// Returns:
//    true if the strings are equal (considering case sensitivity based on ignore_case), false otherwise.
// Example(3D,ColorScheme=Tomorrow)
//    if (equals("Hello", "Hello")) {
//        color("green")
//        translate([0, 0, 0])
//        linear_extrude(height=1)
//        text("Equal!", size=10);
//    }
// Example(3D,ColorScheme=Tomorrow)
//    if (equals("Hello", "HELLO", ignore_case=true)) {
//        color("green")
//        translate([0, 20, 0])
//        linear_extrude(height=1)
//        text("Case-insensitive equal!", size=10);
//    }	
function equals(this, that, ignore_case=false) = 
	ignore_case ? lower(this) == lower(that) : this == that ;	
	

// Function: before()
// 
// Synopsis: Extracts the portion of a string before a specified index.
// Topics: String Manipulation, Text Processing
// See Also: after(), between(), join()
// Description:
//    Returns the substring of the input string from the beginning up to, but not including, the specified index.
//    Handles various edge cases: returns undef if the input string or index is undefined, the full string if
//    the index exceeds the string length, an empty string if the index is 0 or negative, and the appropriate
//    substring otherwise. Uses join() to concatenate characters into the result.
// Arguments:
//    string = The input string to extract from.
//    index = The position up to which to extract (exclusive). [default: 0]
// Returns:
//    The substring before the specified index, the full string if index exceeds length, an empty string if
//    index is 0 or negative, or undef if the input string or index is undefined.
// Example(3D,ColorScheme=Tomorrow)
//    s = before("Hello, World!", 5);
//    color("green")
//    translate([0, 0, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: Hello
// Example(3D,ColorScheme=Tomorrow)
//    s = before("Hello, World!", 12);
//    color("green")
//    translate([0, 20, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: Hello, World!	
function before(string, index=0) = 
	string == undef ? undef : index == undef ? undef : index > len(string)? string : index <= 0 ? "" : join([for (i=[0:index-1]) string[i]]);

// Function: after()
function after(string, index=0) =
	string == undef ? undef	: index == undef ? undef : index < 0 ? string : index >= len(string)-1 ? ""	: join([for (i=[index+1:len(string)-1]) string[i]]);	

// Function: between()
// 
// Synopsis: Extracts a substring between two indices.
// Topics: String Manipulation, Text Processing
// See Also: before(), after(), join()
// Description:
//    Extracts a substring from the input string between the start index (inclusive) and end index (exclusive).
//    Handles various edge cases by returning undef, adjusting indices, or extracting partial substrings.
//    Uses helper functions from _core.scad for substring extraction and joining.
// Arguments:
//    string = The input string to extract from.
//    start = The starting index (inclusive). If negative, extracts from the beginning to end.
//    end = The ending index (exclusive). If greater than string length, extracts from start to the end.
// Returns:
//    The extracted substring, or undef if the input is invalid.
// Example(3D,ColorScheme=Tomorrow)
//    s = between("Hello, World!", 0, 5);
//    color("green")
//    translate([0, 0, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: Hello
// Example(3D,ColorScheme=Tomorrow)
//    s = between("Hello, World!", 7, 12);
//    color("green")
//    translate([0, 20, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: World
function between(string, start, end) = 
	string == undef ?undef:start == undef?undef	: start > len(string)?undef	: start < 0?before(string, end)	: end == undef?undef: end < 0?undef
	: end > len(string)?after(string, start-1)	: start > end?undef: start == end ?"":join([for (i=[start:end-1]) string[i]]);	

// Function: join()
function join(strings, delimeter="") = 
	strings == undef ? undef : strings == [] ? "" : _join(strings, len(strings)-1, delimeter);
	
function _join(strings, index, delimeter) = 
	index==0 ? strings[index] : str(_join(strings, index-1, delimeter), delimeter, strings[index]);	

function parse_int(string, base=10) = 
	string[0] == "-" ? -1*_parse_int(string, base, 1)	: 
	string[0] == "+" ? _parse_int(string, base, 1) :
	_parse_int(string, base);


function _parse_int(string, base, i=0, sum=0) = 
	i == len(string) ? sum : sum + _parse_int(string, base, i+1, search(string[i],"0123456789ABCDEF")[0]*pow(base,len(string)-i-1));	
	
function parse_float(string) = 
	string[0] == "-" ? -1*parse_float(after(string,0)) : _parse_float(split(string, "."));

function _parse_float(sections)=
    len(sections) == 2 ? _parse_int(sections[0], 10) + _parse_int(sections[1], 10)/pow(10,len(sections[1])) : _parse_int(sections[0], 10);	
	

function tab( count , spaces = 3 ) = 
	str_join([for (i = [1:count*spaces]) " "], "");	
	

	

function formatLength( value,unit ) =
	is_undef(value) ? "N/A" :  
	let (
		decimals = value < 1  ? 3 :
				value < 10 ? 2 : 
				0,
				//value < 100 : 0,
		value = decRound(value,decimals)
	)
		str(value," ",default(unit,"m")); 

		
function formatSection( value , unit ) =
	assert (is_dim_pair(value),"Value to format as a section should be 2 dim array")
	let (
		_unit = default(unit,"cm"),
		_divider = 
			_unit == "mm" ? 1 :  
			_unit == "cm" ? 10 :  
			_unit == "m"  ? 1000 :  
			1
	)
	str(value.x/_divider, " ",_unit," x ",value.y/_divider," ",_unit );
	


function formatArea( value, unit ) =
	let(
		_unit = is_def(unit) ? unit : 
			value > 10000 ? "ha" : "m²",
		divider = is_def(unit) ? 1 : 
			value > 10000 ? 10000 : 1,
	)
	str(value/divider," ",_unit);
	//value <10000 ? str(value," m²") : str(value/10000," ha");	
	

// Function: formatWeight()
//
// Synopsis: Formats a weight in kilograms or tons with appropriate units.
// Topics: Utilities, Formatting, Weight
// Usage:
//   weight_str = formatWeight(value);
// Description:
//   Formats a weight value, displaying in kilograms (Kg) for values up to 1000 kg
//   and in metric tons (t) for values above 1000 kg. Applies decimal precision based
//   on magnitude: 3 decimals (< 1 kg), 2 decimals (1–20 kg), 0 decimals (> 20 kg),
//   or 2 decimals (in tons).
// Arguments:
//   value = Weight in kilograms (scalar).
// Returns: String with formatted weight and unit (Kg or t).
function formatWeight(value,unit) =
    is_undef(value) ? "N/A" :
    let (
        is_tons = value > 1000,
        display_value = is_tons ? value / 1000 : value,
        decimals = is_tons ? 2 :
                   display_value < 1 ? 3 :
                   display_value < 20 ? 2 : 0,
        rounded_value = decRound(display_value, decimals),
        _unit = unit ? unit : is_tons ? "t" : "Kg"
    )
    str(rounded_value, " ", _unit);	

	

function formatVolume( 
		value,
		unit
		//unit = is_undef(unit) ? "m³" : unit
	) =
	is_undef(value) ? "N/A" :  
	let (
		decimals = 
				value < 1  ? 3 :
				value < 20 ? 2 : 
				0,
		value = decRound(value,decimals)
	)
	str(value," ",is_undef(unit) ? "m³" : unit ); 

	
function split(string, seperator=" ", ignore_case = false, regex=false) = 
	_split(string, index_of(string, seperator, ignore_case=ignore_case, regex=regex));
    
function _split(string, indices, i=0) = 
    len(indices) == 0?
        [string]
    : i >= len(indices)?
        _coalesce_on(after(string, indices[len(indices)-1].y-1), "", [])
    : i == 0?
        concat( _coalesce_on(before(string, indices[0].x), "", []), _split(string, indices, i+1) )
    :
        concat( between(string, indices[i-1].y, indices[i].x), _split(string, indices, i+1) )
    ;	


function _coalesce_on(value, error, fallback) = 
	value == error ? fallback : value ;	
	
	
function trim(string) = 
	string == undef ? undef : string == "" ? ""	:
		_null_coalesce(
			between(string, _match_set(string, _WHITESPACE, 0), 
					_match_set_reverse(string, _WHITESPACE, len(string))),
			""
		)
	;	
	
function _null_coalesce(string, replacement) = 
	string == undef ? replacement :	string;


function _match_set(string, set, pos) = 
	pos >= len(string)?	len(string)	: is_in(string[pos], set )?	_match_set(string, set, pos+1) : pos ;

function _match_set_reverse(string, set, pos) = 
	pos <= 0 ? 0 : is_in(string[pos-1], set) ? _match_set_reverse(string, set, pos-1) : pos	;	
	
function is_in(string, list, ignore_case=false) = 
	string == undef ? false  : any([ for (i = [0:len(list)-1]) equals(string, list[i], ignore_case=ignore_case) ]);	
	
	