//////////////////////////////////////////////////////////////////////
// LibFile: math.scad
//   Math handling library 
// Includes:
//   include <_core/math.scad>
// FileGroup: Math
// FileSummary: Math library
//////////////////////////////////////////////////////////////////////

// Function: decRound()
//
// Synopsis: Rounds a number to a specified number of decimal places using a pre-adjustment step.
// Topics: Math, Number Theory, Floating Point
// See Also: adjustValue(), EPSILON
// Description:
//   Rounds a floating-point number to a specific number of `decimals`.
//   This version first calls `adjustValue()` to slightly nudge the input `value`
//   away from zero by adding or subtracting EPSILON *before* applying the
//   standard rounding logic (scaling by 10^decimals, rounding, unscaling).
//   This pre-adjustment step aims to potentially influence rounding behavior,
//   possibly to handle specific floating-point edge cases, but it results in
//   rounding behavior that deviates from the standard `round()` function's direct application.
//
//   *Note:* Using the standard rounding approach (without `adjustValue`) is
//   generally recommended for predictability and clarity unless this specific
//   epsilon adjustment is demonstrably necessary for a particular known issue.
// Arguments:
//   value    = The number to round. Must be a numerical value.
//   decimals = The number of decimal places to round to. Must be an integer >= 0. [default: 2]
// Example(Text):
//   // Note: The effect of EPSILON (1e-9) is usually invisible after rounding
//   // to typical decimal places, as the nudge is smaller than the rounding precision.
//   // Examples primarily show the rounding outcome, which often matches standard rounding.
//   echo("Pi rounded to default (2) decimals: ", decRound(3.14159));          // Expect: 3.14
//   echo("Pi rounded to 4 decimals: ", decRound(3.14159, 4));                  // Expect: 3.1416
//   echo("A number rounded to 0 decimals: ", decRound(10.987, 0));            // Expect: 11
//   echo("Rounding 5 (already integer): ", decRound(5, 3));                    // Expect: 5
//   echo("Rounding negative number: ", decRound(-1.23456, 3));                 // Expect: -1.235
//   // Test rounding near 0.5 after adjustment. The effect of adjustValue here
//   // is typically negligible after multiplication unless dealing with extreme precision needs.
//   // adjustValue(2.5) = 2.5+1e-9. (2.5+1e-9)*1 = 2.5+1e-9. round(2.5+1e-9) = 3.
//   echo("Rounding edge case (halfway): ", decRound(2.5, 0));                 // Expect: 3
//   // adjustValue(-2.5) = -2.5-1e-9. (-2.5-1e-9)*1 = -2.5-1e-9. round(-2.5-1e-9) = -3.
//   echo("Rounding negative edge case (halfway): ", decRound(-2.5, 0));        // Expect: -3
//   // Example where EPSILON *might* matter if precision was higher and value closer to boundary
//   // echo( decRound(0.1250000000001, 2) ); // Might differ from standard round if EPSILON pushes it

function decRound(value,decimals = 2) =
	let  (
		mult = pow(10, decimals)
		//adjusted_value = 
	) 	
	round( adjustValue(value) * mult ) / mult;


// Function: adjustValue()
//
// Synopsis: Slightly adjusts a value away from zero using EPSILON.
// Topics: Math, Floating Point
// See Also: EPSILON
// Description:
//   Takes a numerical value and adds EPSILON if the value is non-negative (>= 0),
//   or subtracts EPSILON if the value is negative. This technique might be used
//   to perturb values slightly, potentially influencing rounding or comparison
//   results near zero or other critical points, sometimes aiming to mitigate
//   floating-point representation issues. Its effectiveness and necessity
//   depend heavily on the specific use case.
// Arguments:
//   value = The numerical value to adjust.
// Example(Text):
//   // Epsilon is 1e-9
//   echo("Adjusting positive value (10.5): ", adjustValue(10.5));        // Expect: 10.500000001
//   echo("Adjusting zero (0): ", adjustValue(0));                      // Expect: 1e-09
//   echo("Adjusting negative value (-5.2): ", adjustValue(-5.2));       // Expect: -5.200000001
//   echo("Adjusting small positive value (1e-10): ", adjustValue(1e-10)); // Expect: 1.1e-09
//   echo("Adjusting small negative value (-1e-10):", adjustValue(-1e-10));// Expect: -1.1e-09
function adjustValue( value ) = 
	value + (value >= 0 ? EPSILON : -EPSILON);
	

// Function: evenOddSign()
// Synopsis: Returns -1 for odd numbers and +1 for even numbers.
// Topics: Mathematics, Utilities
// Description:
//   Determines if a number is odd or even and returns -1 for odd numbers
//   and +1 for even numbers. Works with integers only.
// Arguments:
//   n = The number to check. No default.
// DefineHeader(Generic):Returns:
//   -1 if the number is odd, +1 if the number is even.
// Usage:
//   sign = evenOddSign(5); // Returns -1 (odd)
//   sign = evenOddSign(4); // Returns +1 (even)
// Example: Test odd and even numbers
//   ColorScheme=Nature
//   echo(evenOddSign(5)); // ECHO: -1
//   echo(evenOddSign(6)); // ECHO: 1
function evenOddSign(n) =
    assert(is_num(n), 		"n must be a number")
    assert(n == floor(n), 	"n must be an integer")
    n % 2 == 0 ? 1 : -1;


function is_even(n) = 
    assert(is_num(n), 		"n must be a number")
    assert(n == floor(n), 	"n must be an integer")
	n % 2 == 0 ? true : false;
	
function is_odd(n) = 
    assert(is_num(n), 		"n must be a number")
    assert(n == floor(n), 	"n must be an integer")
	n % 2 == 0 ? false : true;	


// Function: bipolar()
// 
// Synopsis: Maps a boolean to a bipolar numeric value (true to 1, false to -1).
// Topics: Boolean, Math
// Description:
//   Transforms a boolean input into a bipolar output where `true` becomes `1` and
//   `false` becomes `-1`. Uses a concise mathematical approach for efficiency.
// Arguments:
//   b = The boolean value to convert. Expected to be `true` or `false`.
// Returns:
//   1 if `b` is `true`, -1 if `b` is `false`.
// Example:
//   value_true = bipolar(true);  // Returns 1
//   value_false = bipolar(false); // Returns -1
function bipolar(b) = b ? 1 : -1;	


function clamp(value, min_val, max_val) =
    value < min_val ? min_val :
    value > max_val ? max_val :
    value;



