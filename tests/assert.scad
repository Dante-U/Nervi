include <../src/_core/assert.scad>


test_is_num_positive();
test_is_between();
test_is_greater_than();
test_is_less_than();
test_is_dim_pair();
test_is_meters();


module test_is_meters() {
	assert_equal(is_meters(20),true);
	assert_equal(is_meters(2000,plausible=false),true);
	
	assert_equal(is_meters([20,30]),true);
	assert_equal(is_meters([20,"AA"]),false);

}



module test_is_num_positive() {
	assert_equal(is_num_positive(undef)	,false);
	assert_equal(is_num_positive(-1)	,false);
	assert_equal(is_num_positive(0)		,false);
	assert_equal(is_num_positive(1)		,true);


}	

module test_is_between() {
  assert_equal(is_between(3, 1, 5), true , 				"[test_is_between] Expected 3 in [1, 5] to return true");
  assert_equal(is_between(1, 1, 5), true, 				"[test_is_between] Expected 1 in [1, 5] to return true");
  assert_equal(is_between(5, 1, 5), true, 				"[test_is_between] Expected 5 in [1, 5] to return true");
  assert_equal(is_between(0, 1, 5), false, 				"[test_is_between] Expected 0 not in [1, 5]");
  assert_equal(is_between(6, 1, 5), false, 				"[test_is_between] Expected 6 not in [1, 5]");
  assert_equal(is_between(1, 1, 5, min_inc=false), false, "[test_is_between] Expected 1 not in (1, 5)");
  assert_equal(is_between(5, 1, 5, max_inc=false), false, "[test_is_between] Expected 5 not in (1, 5)");
  assert_equal(is_between(5, 1, 5, max_inc=false), false, "[test_is_between] Expected 5 not in [1, 5)");
  assert_equal(is_between(1, 1, 5, min_inc=false), false, "[test_is_between] Expected 1 not in (1, 5]");
  //assert_equal(is_between("2", 1, 5), false, 				"[test_is_between] Expected non-numeric input to return false");
  assert_equal(is_between(undef, 1, 5), false, 				"[test_is_between] Expected undef to return false");
  assert_equal(is_between(0, 0, 5), true, 					"[test_is_between] Expected 0 in [0, 5] to return true");
  assert_equal(is_between(-3, -5, 5), true, 				"[test_is_between] Expected -3 in [-5, 5] to return true");
  
  
  assert_equal(is_between(0, 0, 90), true , 				"[test_is_between] Expected 0 in [0, 90] to return false");
  assert_equal(is_between(90, 0, 90), true , 				"[test_is_between] Expected 90 in [0, 90] to return false");
  assert_equal(is_between(45, 0, 90), true , 				"[test_is_between] Expected 0 in [0, 90] to return true");
  
}


module test_is_greater_than() {
  // Test 1: Inclusive (>= 5), value above threshold
  assert_equal(is_greater_than(6, 5), true, "[test_is_greater_than] Expected 6 >= 5 to return true");
  
  // Test 2: Inclusive (>= 5), value at threshold
  assert_equal(is_greater_than(5, 5), true, "[test_is_greater_than] Expected 5 >= 5 to return true");
  
  // Test 3: Inclusive (>= 5), value below threshold
  assert_equal(is_greater_than(4, 5), false, "[test_is_greater_than] Expected 4 not >= 5");
  
  // Test 4: Exclusive (> 5), value at threshold
  assert_equal(is_greater_than(5, 5, inclusive=false), false, "[test_is_greater_than] Expected 5 not > 5");
  
  // Test 5: Exclusive (> 5), value above threshold
  assert_equal(is_greater_than(6, 5, inclusive=false), true, "[test_is_greater_than] Expected 6 > 5 to return true");
  
  // Test 6: Non-numeric input
  assert_equal(is_greater_than("5", 5), false, "[test_is_greater_than] Expected string input to return false");
  
  // Test 7: Undefined input
  assert_equal(is_greater_than(undef, 5), false, "[test_is_greater_than] Expected undef to return false");
  
  // Test 8: Negative value (>= 0)
  assert_equal(is_greater_than(-1, 0), false, "[test_is_greater_than] Expected -1 not >= 0");
  
  // Test 9: Zero (>= 0)
  assert_equal(is_greater_than(0, 0), true, "[test_is_greater_than] Expected 0 >= 0 to return true");
}

module test_is_less_than() {
  // Test 1: Inclusive (<= 5), value below threshold
  assert_equal(is_less_than(4, 5), true, "[test_is_less_than] Expected 4 <= 5 to return true");
  
  // Test 2: Inclusive (<= 5), value at threshold
  assert_equal(is_less_than(5, 5), true, "[test_is_less_than] Expected 5 <= 5 to return true");
  
  // Test 3: Inclusive (<= 5), value above threshold
  assert_equal(is_less_than(6, 5), false, "[test_is_less_than] Expected 6 not <= 5");
  
  // Test 4: Exclusive (< 5), value at threshold
  assert_equal(is_less_than(5, 5, inclusive=false), false, "[test_is_less_than] Expected 5 not < 5");
  
  // Test 5: Exclusive (< 5), value below threshold
  assert_equal(is_less_than(4, 5, inclusive=false), true, "[test_is_less_than] Expected 4 < 5 to return true");
  
  // Test 6: Non-numeric input
  assert_equal(is_less_than("5", 5), false, "[test_is_less_than] Expected string input to return false");
  
  // Test 7: Undefined input
  assert_equal(is_less_than(undef, 5), false, "[test_is_less_than] Expected undef to return false");
  
  // Test 8: Negative value (<= 0)
  assert_equal(is_less_than(-1, 0), true, "[test_is_less_than] Expected -1 <= 0 to return true");
  
  // Test 9: Zero (<= 0)
  assert_equal(is_less_than(0, 0), true, "[test_is_less_than] Expected 0 <= 0 to return true");
}

module test_is_dim_pair() {
  assert_equal(is_dim_pair([10, 20]), 		true, "[test_is_dim_pair] Expected [10, 20] to be valid");
  assert_equal(is_dim_pair([10, -5]), 		false, "[test_is_dim_pair] Expected [10, -5] to be invalid");
  assert_equal(is_dim_pair([0, 20]), 		false, "[test_is_dim_pair] Expected [0, 20] to be invalid");
  assert_equal(is_dim_pair([10, "20"]), 	false, "[test_is_dim_pair] Expected [10, \"20\"] to be invalid");
  assert_equal(is_dim_pair(undef), 			false, "[test_is_dim_pair] Expected undef to be invalid");
  assert_equal(is_dim_pair([10]), 			false, "[test_is_dim_pair] Expected [10] to be invalid");
  assert_equal(is_dim_pair([10, 20, 30]), 	false, "[test_is_dim_pair] Expected [10, 20, 30] to be invalid");
  assert_equal(is_dim_pair([0.1, 0.2]), 	true, "[test_is_dim_pair] Expected [0.1, 0.2] to be valid");
  assert_equal(is_dim_pair(10), 			false, "[test_is_dim_pair] Expected 10 to be invalid");
}