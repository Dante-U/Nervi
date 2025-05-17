include <BOSL2/std.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: assert.scad
// Includes:
//   include <_core/assert.scad>;
// FileGroup: Core
// FileSummary: Assertion, tests, validation
//////////////////////////////////////////////////////////////////////

// Function: is_num_positive()
//
// Synopsis: Checks if a value is a positive number.
// Topics: Validation, Numbers
// See Also: is_between()
// Usage:
//   result = is_num_positive(x);
// Description:
//   Determines whether the input value is a valid number and greater than zero.
//   Relies on BOSL2's is_num() function to validate the input as a number.
//   Returns true only if the input is a number and positive (x > 0).
// Arguments:
//   x = The value to check. No default.
// Returns:
//   Boolean: true if x is a number and x > 0, false otherwise.
function is_num_positive(x) = is_num(x) && x > 0; 

// Function: is_meters()
//
// Synopsis: Checks if a value is a positive number representing a plausible length in meters.
// Topics: Validation, Numbers
// See Also: is_num_positive()
// Usage:
//   result = is_meters(x, [plausible=true]);
// Description:
//   Determines whether the input value is a positive number, suitable for representing a length in meters.
//   If plausible is true, asserts that the value is less than 1000 meters to catch potentially erroneous inputs.
//   Relies on BOSL2's is_num() for number validation.
// Arguments:
//   x = The value to check. No default.
//   plausible = If true, checks if x is less than 1000 meters. Default: true
// Returns:
//   Boolean: true if x is a positive number (and less than 1000 if plausible=true), false otherwise.
// Example
//   length = 500;
//   if (is_meters(length)) {
//     cuboid([length, 100, 50]);  // Creates cuboid with valid length
//   }
// Example
//   length = 1500;
//   if (is_meters(length, plausible=false)) {
//     cuboid([length, 100, 50]);  // Creates cuboid, bypassing plausible check
//   }
// Example
//   length = undef;
//   if (is_meters(length)) {
//     cuboid([100, 100, 50]);  // No cuboid created since undef returns false
//   }
function is_meters(x,plausible = true)  = 
	is_list (x) ? all([ for (v = x) is_meters(v,plausible)]) : 
		is_def(x) && is_num(x) ? 
			assert(plausible == false || x < 1000,str("[is_meters] value(",x,") seems to be too big for a meter value"))
		//1000 * value 
		is_num(x) && x > 0
		: false;



/*
	assert(plausible == false || x < 1000,str("[is_meters] value(",x,") seems to be too big for a meter value"))
	is_num(x) && x > 0; 
	*/

// Function: is_between()
//
// Synopsis: Checks if a value is within a specified range.
// Topics: Validation, Numbers
// See Also: is_num_positive()
// Usage:
//   result = is_between(x, min, max, [min_inc=true], [max_inc=true]);
// Description:
//   Determines whether the input value x is within the range defined by min and max.
//   The min_inc and max_inc parameters control whether the bounds are inclusive (true)
//   or exclusive (false). Relies on BOSL2's is_num() to validate numeric inputs.
// Arguments:
//   x = The value to check. No default.
//   min = The minimum bound of the range. No default.
//   max = The maximum bound of the range. No default.
//   min_inc = Whether the minimum bound is inclusive. Default: true
//   max_inc = Whether the maximum bound is inclusive. Default: true
// Returns:
//   Boolean: true if x is within the range, false otherwise.
// Example
//   // Inclusive range [1, 5]
//   value = 3;
//   if (is_between(value, 1, 5)) {
//     cube([value, 2, 1]);  // Creates a cube for value in [1, 5]
//   }
// Example
//   // Exclusive range (2, 5)
//   value = 2;
//   if (is_between(value, 2, 5, min_inc=false, max_inc=false)) {
//     cube([value, 2, 1]);  // No cube created since 2 is not in (2, 5)
//   }
// Example
//   // Inclusive min, exclusive max [0, 10)
//   value = 10;
//   if (is_between(value, 0, 10, max_inc=false)) {
//     cube([value, 2, 1]);  // No cube created since 10 is not in [0, 10)
//   }
function is_between(x, min, max, min_inc=true, max_inc=true) =
  assert(is_num(min), "[is_between] min must be a number")
  assert(is_num(max), "[is_between] max must be a number")
  assert(min <= max, "[is_between] min must not exceed max")
  assert(is_bool(min_inc), "[is_between] min_inc must be a boolean")
  assert(is_bool(max_inc), "[is_between] max_inc must be a boolean")
  !is_num(x) ? false :  // Return false if x is not a number (including undef)
  let(
    min_check = min_inc ? x >= min : x > min,
    max_check = max_inc ? x <= max : x < max
  )
  min_check && max_check;

	

// Function: is_greater_than()
// Synopsis: Checks if a value is greater than a threshold.
// Topics: Validation, Numbers
// See Also: is_less_than(), is_between()
// Usage:
//   result = is_greater_than(x, threshold, [inclusive=true]);
// Description:
//   Determines whether the input value x is greater than the specified threshold.
//   The inclusive parameter controls whether the comparison is inclusive (>=, true)
//   or exclusive (>, false). Relies on BOSL2's is_num() to validate numeric inputs.
//   Returns false if x is undef or not a number.
// Arguments:
//   x = The value to check. No default.
//   threshold = The threshold value to compare against. No default.
//   inclusive = Whether the comparison is inclusive (>=). Default: true
// Returns:
//   Boolean: true if x is a number and greater than (or equal to, if inclusive) the threshold, false otherwise.
// Example
//   // Inclusive comparison (>= 5)
//   value = 5;
//   if (is_greater_than(value, 5)) {
//     cube([value, 2, 1]);  // Creates a cube since 5 >= 5
//   }
// Example
//   // Exclusive comparison (> 5)
//   value = 5;
//   if (is_greater_than(value, 5, inclusive=false)) {
//     cube([value, 2, 1]);  // No cube created since 5 is not > 5
//   }
// Example
//   // Undefined input
//   value = undef;
//   if (is_greater_than(value, 0)) {
//     cube([1, 2, 1]);  // No cube created since undef returns false
//   }
function is_greater_than(x, threshold, inclusive=true) =
  assert(is_num(threshold), "[is_greater_than] threshold must be a number")
  assert(is_bool(inclusive), "[is_greater_than] inclusive must be a boolean")
  !is_num(x) ? false :  // Return false if x is not a number (including undef)
  inclusive ? x >= threshold : x > threshold;

// Function: is_less_than()
// Synopsis: Checks if a value is less than a threshold.
// Topics: Validation, Numbers
// See Also: is_greater_than(), is_between()
// Usage:
//   result = is_less_than(x, threshold, [inclusive=true]);
// Description:
//   Determines whether the input value x is less than the specified threshold.
//   The inclusive parameter controls whether the comparison is inclusive (<=, true)
//   or exclusive (<, false). Relies on BOSL2's is_num() to validate numeric inputs.
//   Returns false if x is undef or not a number.
// Arguments:
//   x = The value to check. No default.
//   threshold = The threshold value to compare against. No default.
//   inclusive = Whether the comparison is inclusive (<=). Default: true
// Returns:
//   Boolean: true if x is a number and less than (or equal to, if inclusive) the threshold, false otherwise.
// Example
//   // Inclusive comparison (<= 5)
//   value = 5;
//   if (is_less_than(value, 5)) {
//     cube([value, 2, 1]);  // Creates a cube since 5 <= 5
//   }
// Example
//   // Exclusive comparison (< 5)
//   value = 5;
//   if (is_less_than(value, 5, inclusive=false)) {
//     cube([value, 2, 1]);  // No cube created since 5 is not < 5
//   }
// Example
//   // Undefined input
//   value = undef;
//   if (is_less_than(value, 10)) {
//     cube([1, 2, 1]);  // No cube created since undef returns false
//   }
function is_less_than(x, threshold, inclusive=true) =
  assert(is_num(threshold), "[is_less_than] threshold must be a number")
  assert(is_bool(inclusive), "[is_less_than] inclusive must be a boolean")
  !is_num(x) ? false :  // Return false if x is not a number (including undef)
  inclusive ? x <= threshold : x < threshold;
	
// Function: is_dim_pair()
// Synopsis: Checks if an array represents a valid pair of dimensions.
// Topics: Validation, Dimensions
// See Also: is_num_positive()
// Usage:
//   result = is_dim_pair(dims);
// Description:
//   Determines whether the input is a valid two-element array [dim1, dim2] where both
//   elements are positive numbers (e.g., [height, width] or [height, depth]). Returns false
//   if the input is undef, not a list, not exactly two elements, or contains non-positive
//   or non-numeric values. Relies on BOSL2's is_num() for number validation.
// Arguments:
//   dims = The array to check, expected to be [dim1, dim2]. No default.
// Returns:
//   Boolean: true if dims is a two-element array of positive numbers, false otherwise.
// Example:
//   // Valid dimension pair
//   dims = [10, 20];
//   if (is_dim_pair(dims)) {
//     cuboid([dims[1], 5, dims[0]]);  // Creates a cuboid with width=20, height=10
//   }
// Example:
//   // Invalid dimension pair (negative value)
//   dims = [10, -5];
//   if (is_dim_pair(dims)) {
//     cuboid([dims[1], 5, dims[0]]);  // No cuboid created
//   }
// Example:
//   // Undefined input
//   dims = undef;
//   if (is_dim_pair(dims)) {
//     cuboid([10, 5, 10]);  // No cuboid created
//   }
function is_dim_pair(dims) =
  !is_list(dims) || len(dims) != 2 ? false :  // Check if dims is a list with 2 elements
  !is_num(dims[0]) || !is_num(dims[1]) ? false : //" Check if both elements are numbers
  dims[0] <= 0 || dims[1] <= 0 ? false :  // Check if both are positive
  true;	

// Function: isLine()
//
// Synopsis: Checks if a list represents a valid 2D line segment.
// Topics: Geometry, Validation
// Usage:
//   result = isLine(path);
// Description:
//   Determines if the input is a valid 2D line segment, defined as a list of exactly two distinct points,
//   where each point is a valid 2D point (checked via isValidPoint).
// Arguments:
//   l = List representing a line segment, expected to contain two 2D points ([x1, y1], [x2, y2]).
// Example:
//   line = [[0, 0], [1, 1]];
//   echo(isLine(line)); // Outputs: true
//   echo(isLine([[0, 0], [0, 0]])); // Outputs: false		
function isLine(l) = 
	is_list(l) && 			// is a list
	len(l) == 2 && 			// has 2 points
	isPoint(l[0]) && 		// point 1 is valid
	isPoint(l[1]) && 		// point 2 is valid
	(l[0] != l[1]);			// point 1 is not point 2

// Function: isPoint()
//
// Synopsis: Checks if a value is a valid 2D or 3D point.
// Topics: Geometry, Validation
// Usage:
//   result = isPoint(pt); // 2D or 3D point return true
// Description:
//   Determines if the input is a valid 2D/3D point, defined as a list of exactly two numeric coordinates [x, y].
// Arguments:
//   pt = Value to check, expected to be a list of two numbers representing a 2D point.
// Example:
//   point = [1, 2];
//   echo(isPoint(point)); // Outputs: true
//   echo(isPoint([1, "2"])); // Outputs: false	
function isPoint(p) = 
	is_list(p) && (len(p) == 2 || len(p) == 3) && all([for (coord = p) is_num(coord)]);
	
	