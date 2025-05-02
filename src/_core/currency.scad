include <strings.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: currency.scad
//   Currency handling
// Includes:
//   include <_core/currency.scad>
// FileGroup: Currency
// FileSummary: Currency utilities
//////////////////////////////////////////////////////////////////////

/**
 * Currency formatting function for OpenSCAD
 * Formats a number as a currency string with thousands separators and proper decimal places
 */

// Main currency formatting function
function formatCurrency( 
		amount, 
		symbol 	= first_defined([ 
					is_undef(symbol) 	? undef : symbol , 
					is_undef($currency) ? "$" : $currency,
					//((symbol == undef ? "$" : "$"
			]),
		decimals 			= 2, 
		thousands_separator	= ",", 
		decimal_separator 	= ".",
		symbol_position 	= "before",
	) =
	is_undef(amount) ?
		"N/A"
	:	
    let(
        // Convert to string with fixed decimal places
		_symbol = is_undef(symbol) ? "$" : symbol,
        amount_str = format_fixed_decimal(amount, decimals),
        // Split into integer and decimal parts
        parts 			= split_by_decimal(amount_str),
        integer_part 	= parts[0],
        decimal_part 	= parts[1],
        // Add thousands separators to integer part
        formatted_integer = add_thousands_separators( integer_part, thousands_separator ),
        // Build final string based on symbol position
        with_decimal = (decimals > 0) ? 
                      str(formatted_integer, decimal_separator, decimal_part) :
                      formatted_integer,
        result = ( symbol_position == "before" ) ? 
                 //str(currency_symbol, with_decimal) : 
				 str( _symbol, with_decimal ) : 
                 str( with_decimal, _symbol )
    ) 
	result;


// Helper function to convert from scientific notation
function convert_from_scientific(number) =
    let(
        num_str	= str(number),
        e_pos 	= search("e", num_str)[0], 	// 7
        has_e 	= e_pos != undef,			// True
        

        // If not in scientific notation, return as is
        result = !has_e ? num_str : 
                 let(
                     mantissa = substring(num_str, 0, e_pos),  // 1.22418
                     exponent = substring(num_str, e_pos + 1), // +6
                     
                     // Convert mantissa to a number with proper decimal point
                     mantissa_parts = split_by_decimal(mantissa),  // ["1","22418"]
                     m_int = mantissa_parts[0],  // 1
                     m_dec = mantissa_parts[1],  // 22418
                     // Calculate new position of decimal point
                     exp_val = parse_int(exponent),
                     // Handle positive exponent
                     full_num = (exp_val >= 0) ?
                                str(m_int, m_dec, create_zeros(exp_val - len(m_dec))) :
                                str("0.", create_zeros(-exp_val - 1), m_int, m_dec)
                 ) 
				 //exponent
				 full_num
    ) 
	result;

// Helper function to process integer in groups of 3
function process_groups(str, separator) =
    let(
        str_len = len(str),
        
        // Calculate number of complete groups of 3
        num_groups = floor(str_len / 3),
        remainder = str_len % 3,
        
        // Process first chunk (which may be less than 3 digits)
        first_chunk = (remainder == 0) ? 
                     substring(str, 0, 3) :
                     substring(str, 0, remainder),
        
        // Initialize result with first chunk
        result = first_chunk
    )
    // Add remaining groups with separators
    add_remaining_groups(str, result, separator, remainder == 0 ? 3 : remainder, str_len);

// Helper function to add remaining groups
function add_remaining_groups(str, result, separator, current_pos, str_len) =
    (current_pos >= str_len) ? result :
    let(
        next_pos = current_pos + 3,
        next_group = substring(str, current_pos, 3),
        new_result = str(result, separator, next_group)
    )
    (next_pos >= str_len) ? new_result :
    let(
        next_next_pos = next_pos + 3,
        next_next_group = substring(str, next_pos, 3),
        newer_result = str(new_result, separator, next_next_group)
    )
    (next_next_pos >= str_len) ? newer_result :
    let(
        final_pos = next_next_pos + 3,
        final_group = substring(str, next_next_pos, 3),
        final_result = str(newer_result, separator, final_group)
    )
    (final_pos >= str_len) ? final_result :
    str(final_result, separator, substring(str, final_pos));




// Non-recursive helper function to create a string of zeros
function create_zeros( count ) =
	is_undef(count) ? "N/A" : 
    (count <= 0) ? "" :
    (count == 1) ? "0" :
    (count == 2) ? "00" :
    (count == 3) ? "000" :
    (count == 4) ? "0000" :
    (count == 5) ? "00000" :
    (count == 6) ? "000000" :
    (count == 7) ? "0000000" :
    (count == 8) ? "00000000" :
    (count == 9) ? "000000000" :
    (count == 10) ? "0000000000" :
    str("0000000000", create_zeros(count - 10));
	

// Helper function to parse integer
/*
function parse_int(str) =
    let(
        is_negative = (len(str) > 0 && str[0] == "-"),
        value_str = is_negative ? substring(str, 1) : str,
        value = parse_digit(value_str, 0)
    )
    is_negative ? -value : value;
*/	

	
	
// Helper function to parse digits non-recursively
function parse_digit( str, val = 0 ) =
    let(
        l = len(str),
        d0 = l > 0 ? (ord(str[0]) - 48) : 0,
        d1 = l > 1 ? (ord(str[1]) - 48) : 0,
        d2 = l > 2 ? (ord(str[2]) - 48) : 0,
        d3 = l > 3 ? (ord(str[3]) - 48) : 0
    )
    l <= 0 ? val :
    l == 1 ? val * 10 + d0 :
    l == 2 ? val * 100 + d0 * 10 + d1 :
    l == 3 ? val * 1000 + d0 * 100 + d1 * 10 + d2 :
    l == 4 ? val * 10000 + d0 * 1000 + d1 * 100 + d2 * 10 + d3 :
    parse_digit(substring(str, 4), val * 10000 + d0 * 1000 + d1 * 100 + d2 * 10 + d3);

	
	
// Helper function to format number with fixed decimal places
function format_fixed_decimal(number, decimals) =
    let(
        // Convert to string first and ensure scientific notation is handled
        num_str = (number >= 1000000) ? convert_from_scientific(number) : str(number),
        
        // Check if it already has a decimal point
        decimal_pos = search(".", num_str)[0],
        has_decimal = decimal_pos != undef,
        
        // Split into integer and decimal parts
        integer_part = has_decimal ? substring(num_str, 0, decimal_pos) : num_str,
        existing_decimal = has_decimal ? substring(num_str, decimal_pos + 1) : "",
        
        // Pad or truncate decimal part
        decimal_length = len(existing_decimal),
        padding_needed = decimals - decimal_length,
        
        decimal_part = (decimals <= 0) ? "" :
                       (padding_needed > 0) ?
                       str(existing_decimal, create_zeros(padding_needed)) :
                       substring(existing_decimal, 0, decimals)
    ) 
		//[number,decimals,num_str,integer_part];
		(decimals > 0) ? str(integer_part, ".", decimal_part) : integer_part;	

//echo(format_fixed_decimal(123456.789,2));
//echo(123456.78);

// Function: add_thousands_separators()
// 
// Synopsis: Adds thousands separators to an integer string.
// Topics: String Formatting, Number Display
// See Also: substring()
// Description:
//    Formats an integer string by adding thousands separators (e.g., commas) every three digits from the right.
//    Handles negative numbers by preserving the leading minus sign.
//    Uses helper functions from _core.scad for substring extraction and processing.
// Arguments:
//    integer_str = The input string representing an integer (e.g., "1234567").
//    separator = The character to use as the thousands separator. [default: ","]
// Returns:
//    A string with thousands separators added (e.g., "1,234,567").
// Example(3D,ColorScheme=Nature)
//    s = add_thousands_separators("1234567");
//    color("green")
//    translate([0, 0, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: 1,234,567
// Example(3D,ColorScheme=Nature)
//    s = add_thousands_separators("-1234567", ".");
//    color("green")
//    translate([0, 20, 0])
//    linear_extrude(height=1)
//    text(s, size=10);  // Outputs: -1.234.567	
function add_thousands_separators(integer_str, separator = ",") =
    let(
        // Handle negative numbers
        is_negative = (len(integer_str) > 0 && integer_str[0] == "-"),
        positive_part = is_negative ? substring(integer_str, 1) : integer_str,
        positive_len = len(positive_part),
        // Process the digits in groups of 3 from right to left
        result = (positive_len <= 3) ? positive_part :
                 process_groups(positive_part, separator),
        // Add negative sign back if needed
        final_result = is_negative ? str("-", result) : result
    ) final_result;
	

// Function: split_by_decimal()
// 
// Synopsis: Splits a string into integer and decimal parts.
// Topics: String Manipulation, Number Parsing
// Description:
//    Splits a string representing a number into its integer and decimal parts, using the first decimal point as the separator.
//    Returns a two-element array containing the integer part and decimal part.
//    If no decimal point is found, the decimal part is an empty string.
// Arguments:
//    str = The input string to split (e.g., "123.45").
// Returns:
//    A two-element array [integer_part, decimal_part].
// Example(3D,ColorScheme=Nature)
//    parts = split_by_decimal("123.45");
//    color("green")
//    translate([0, 0, 0])
//    linear_extrude(height=1)
//    text(str("Integer: ", parts[0]), size=10);  // Outputs: Integer: 123
// Example(3D,ColorScheme=Nature)
//    parts = split_by_decimal("123.45");
//    color("green")
//    translate([0, 20, 0])
//    linear_extrude(height=1)
//    text(str("Decimal: ", parts[1]), size=10);  // Outputs: Decimal: 45	
function split_by_decimal( str ) =
    let(
        decimal_pos = search(".", str)[0],
        has_decimal = decimal_pos != undef,
        integer_part = has_decimal ? 
                      substring(str, 0, decimal_pos) : 
                      str,
        decimal_part = has_decimal ? 
                      substring(str, decimal_pos + 1) : 
                      ""
    ) [integer_part, decimal_part];