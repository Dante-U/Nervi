include <../src/_core/currency.scad>


test_format_currency_with_symbol_undef();

test_create_zeros();
test_split_by_decimals();
test_add_thousands_separators();
test_format_fixed_decimal();
test_format_currency();
test_format_currency_with_symbol();

test_convert_from_scientific();






module test_create_zeros() {
	assert_equal (create_zeros(3),		"000");
	assert_equal (create_zeros(undef),	"N/A");

}


module test_split_by_decimals() {
	assert_equal(split_by_decimal("18.25"),["18","25"]);
}

module test_add_thousands_separators() {
	assert_equal(add_thousands_separators ("10000")		,"10,000");
	assert_equal(add_thousands_separators ("10000","'")	,"10'000");
}

module test_format_fixed_decimal() {
	assert_equal(format_fixed_decimal(123.4567,2),"123.45");
	assert_equal(format_fixed_decimal(123.4567,0),"123");
}
module test_convert_from_scientific() {
	assert_equal(convert_from_scientific(40738 * 30.05),"1224180");
}


module test_format_currency() {
	assert_equal(formatCurrency(40738 * 30),"$1,222,140.00");
	{
		//$currency = "R$";
	//assert_equal( format_currency(40738 * 30.05),"R$1,224,180.00");
	}
	
}

module test_format_currency_with_symbol() {
	$currency = "R$";
	assert_equal(formatCurrency(40738 * 30),"R$1,222,140.00");
}

module test_format_currency_with_symbol_undef(){
	//assert_equal(formatCurrency(5),"$5.00");
	assert_equal(formatCurrency(5,symbol=undef),"$5.00");
}