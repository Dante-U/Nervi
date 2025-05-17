include <constants.scad>
use <strings.scad>
use <currency.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: metadata.scad
//   Metadata handling library for managing and displaying object properties.
// Includes:
//   include <Nervi/_core/metadata.scad>
// FileGroup: Metadata
// FileSummary: Architecture, Metadata
//////////////////////////////////////////////////////////////////////

function metaSpecs() = struct_set([], [
	"id",        	 [ "ID"				    							],
	"name",        	 [ "Name"											],
	"type",        	 [ "Type"											],
	"code-prefix",   [ "Code prefix"									],
	
    "volume",        [ "Volume"		, 		function(v,u) formatVolume(v,u)		],
	"unit_price",    [ "Unit Price"	, 		function(v,u) formatCurrency(v,symbol=u) 	],
	"weight",    	 [ "Weight"		, 		function(v,u) formatWeight(v,u)		],
	"area",    	 	 [ "Area"		, 		function(v,u) formatArea(v,u)			],
	"perimeter",     [ "Perimeter"	, 		function(v,u) formatLength(v,u)		],
	"section",     	 [ "Section"	, 		function(v,u) formatSection(v,u)		],
	"value",    	 [ "Value(use cost) ", 	function(v,u) formatCurrency(v,symbol=u)    ],
	"cost",    	 	 [ "Cost"		, 		function(v,u) formatCurrency(v,symbol=u)    ],
	"orientation", 	 [ "Orientation"									],
	"qty",        	 [ "Quantity"	, "Unit"							],
	"units",         [ "Units"		/*, "pce"*/								],
	"material",      [ "Material"										],
	"linear_meters", [ "Linear Meters", 	function(v,u) formatLength(v,u)	],
	"diameter", 	 [ "Diameter"	, 		function(v,u) formatLength(v,u)	],
	"height", 	 	 [ "Height"		, 		function(v,u) formatLength(v,u)	],
    // New IFC properties
    "ifc_class",     [ "IFC Class"                                  ],
    "ifc_type",      [ "IFC Type"                                   ],
    "ifc_guid",      [ "IFC GUID"                                   ],
    "ifc_props",     [ "IFC Properties"                             ],
	
]);

function generate_guid() =
    let(
        chars = "0123456789ABCDEF",
        sections = [8, 4, 4, 4, 12],
        parts = [for(s = sections) join([for(i = [0:s-1]) chars[floor(rands(0, 15, 1)[0])]]) ]
    )
    join(parts, "-");
	
// Function: metaSpec()
//
// Synopsis: Retrieves metadata specification for a given property.
// Topics: Metadata, Utilities
// Description:
//   Returns the specification (label and unit) for a specified metadata property.
// Arguments:
//   property = The property key to look up (e.g., "volume").
// Example:
//   spec = metaSpec("volume");  // Returns ["Volume", "Kg"]	
function metaSpec( property ) =	
	assert(property, "Meta spec property cannot be undefined")
	let(
		data = metaSpecs()
	)
	struct_val(data, property);

// Function: materialSpecs()
// 
// Synopsis: Defines a material specification with properties like price and quantity.
// Topics: Materials, Cost Estimation, Architectural Modeling
// Description:
//    Creates a material specification for use in architectural modeling, associating a material
//    name with properties such as unit price, quantity, total value, material type, and units.
//    This function is useful for defining materials in the context of the space module, such as
//    specifying concrete for walls or glass for windows in a masterSuite setup. Returns a list
//    with the material name and a sublist of properties, including calculated values like total
//    cost (price * quantity) when applicable.
// Arguments:
//    name  = The name of the material (required).
//    price = The unit price of the material (optional, must be a number if defined).
//    qty   = The quantity of the material (optional).
//    type  = The type of material (optional).
//    units = The units of measurement (optional).
// Returns:
//    A list of the form [name, [properties]], where properties include key-value pairs like
//    ["unit_price", price], ["qty", qty], ["value", price * qty], ["material", type], and
//    ["units", units], depending on which parameters are defined.	
function materialSpecs ( name, price, qty,type, units ) = 
	assert(name,								"Material spec name should be defined")
	assert(is_undef(price ) || is_num(price),	"Material spec price should be a number if defined")
	[
		name , 
		[
			if (is_def(price) ) 				["unit_price"	,price			],
			if (is_def(qty) ) 					["qty"			,qty			],
			if (is_def(qty) && is_def(price))	["cost"			,price * qty	],
			if (is_def(type))					["material"		,type			],
			if (is_def(units) ) 				["units"		,units			],
		]
	
	];	
	

// Function: retrieveInfo()
//
// Synopsis: Gathers metadata with specifications.
// Topics: Metadata, Utilities
// Description:
//   Retrieves metadata from $meta, pairing each entry with its specification from meta_specs.
// Example:
//   $meta = [["volume", 5], ["weight", 2]];
//   info = retrieveInfo();  // Returns [["Volume", 5, "Kg"], ["Weight", 2, "Kg"]]	
function retrieveInfo( data = is_undef(data) ? $meta : data ) = 
	[
		for ( m = data ) 
			let ( 
				key 		= m[0],
				value 		= m[1],
				_metricUnit =  assert(key,"meta 0 cannot be undef") parseMetricUnit(key), 
				metric		= _metricUnit[0],
				unit 		= _metricUnit[1],
				spec 			= assert(m[0],"meta 0 cannot be undef") metaSpec(metric) 
			)	
			if (spec) 
				let(
					label 		= spec[0],
					unitLabel 	= is_function(spec[1]) ? undef 		: spec[1],
					formatFunc  = is_function(spec[1]) ? spec[1] 	: undef,
				)
				[ 
					label, 										// Label
					formatFunc 	? formatFunc(value,unit)  : value, 	// Format function or value
					unitLabel 	? unitLabel : ""				// Unit if provided by spec
				] 
			else if (key == "Materials") 
				[
					"Materials",
					[
						for ( material = value ) 
							[
								material[0],
								retrieveMaterialInfo (material[1])
							]
					]
				]
	];	

function retrieveMaterialInfo ( mat ) = 
	[ for (p = mat) 
			let (s = metaSpec(p[0] )  )	
				if (s) [ s[0], is_function(s[1]) ? s[1](p[1])  : p[1], is_function(s[1]) ? "" : s[1]] 
	];		
	
// Function: formatInfo()
//
// Synopsis: Formats metadata lines for display.
// Topics: Metadata, Text Formatting
// Description:
//   Converts a list of metadata entries into formatted strings with aligned labels.
// Arguments:
//   lines = List of metadata entries, each as [label, value, unit].
// Example:
//   lines = [["Volume", 5, "Kg"], ["Weight", 2, "Kg"]];
//   formatted = formatInfo(lines);  // Returns ["Volume         : 5 Kg", "Weight
function formatInfo( lines, tab = 1, label ) = 
	let (
		leftTab 	= str_join([for (i = [1:tab*3]) " "], ""),
		previous 	= tab(tab-1)
	)
	flatten(concat(
		is_def(label) ? [str( previous, label ,":")] : [],
		[
			for(l = lines) 
				if (l[0] == "Materials" )	
					for (mat = l[1])
							formatInfo(mat[1],tab = tab+1,label = mat[0] )
				else if (is_def(l) )
					str(
						str_left_pad(l[0],20),		// label
						": ",					
						l[1],						// value
						" ",
						is_def(l[2]) ? l[2] : "",	// unit
					)
		]
	));		
	
// Function: findMeta()
//
// Synopsis: Finds a metadata entry by field name.
// Topics: Metadata, Search
// Description:
//   Searches the $meta special variable for an entry matching the given field.
// Arguments:
//   field = The field name to search for (e.g., "volume").
// Example:
//   $meta = [["volume", 5], ["weight", 2]];
//   entry = findMeta("volume");  // Returns ["volume", 5]	
function findMeta( field ) = 
	let( result = filter(function(l) l[0] == field, $meta ) )
		result ? result[0] : result;

// Function: findMetaValue()
//
// Synopsis: Retrieves the value of a metadata field.
// Topics: Metadata, Search
// Description:
//   Extracts the value associated with a field from $meta.
// Arguments:
//   field = The field name to retrieve (e.g., "volume").
// Example:
//   $meta = [["volume", 5], ["weight", 2]];
//   value = findMetaValue("volume");  // Returns 5	
function findMetaValue( field ) = 
	let(result = findMeta(field))
		result ? result[1] : undef;
		
// Module: info()
//
// Synopsis: Displays formatted metadata information.
// Topics: Metadata, Display
// Description:
//   Prints metadata from $meta in a neatly formatted block using retrieveInfo() and printData().
// Example(3D,ColorScheme=Tomorrow,NORENDER)
//   $meta = [["volume", 5], ["weight", 2]];
//   info();  // Outputs a formatted block with Volume and Weight
module info() {
	if (is_undef( $mute_info ) || $mute_info == false)
	printData("Info",formatInfo( retrieveInfo() ));
}

function provideMeta( enabled ) = 
	enabled && (is_undef($multi_pass) || $multi_pass == false );

// Module: printData()
//
// Synopsis: Prints a formatted data block.
// Topics: Text Formatting, Display
// Description:
//   Outputs a block of text with a centered title and data lines, framed by asterisks.
// Arguments:
//   title = The title of the block.
//   data = List of strings to display.
// Example(3D,ColorScheme=Tomorrow)
//   printData("Specs", ["Volume : 5 Kg", "Weight : 2 Kg"]);
module printData(title,data) {
    assert(is_def(title), "title must be defined");
    assert(is_string(title), "title must be a string");
	cols = 40;
    header = [
		str_pad("",cols,"*"),
		str_center_pad (title,cols),
		str_pad("",cols,"*"),
    ];
	lines = concat(header,data,str_pad("",cols,"*"));
    echo(str( CR, str_join(lines, CR), CR ));
}	


// Function: parseMetricUnit()
//
// Synopsis: Parses a string to extract metric and unit components.
// Topics: String, Parsing, Metadata
// Usage:
//   result = parseMetricUnit(str);
// Description:
//   Parses a string of the form "metric,unit" (e.g., "volume,l") to extract the metric name and unit.
//   If no comma is present (e.g., "volume"), returns the metric with an undefined unit.
//   Trims whitespace from both metric and unit. Returns undef for invalid input.
// Arguments:
//   str = Input string to parse (e.g., "volume,l", "volume"). No default
// Returns:
//   A list [metric, unit] (e.g., ["volume", "l"], ["volume", undef]), or undef if input is invalid.
// Example:
//   result = parseMetricUnit("volume,l"); // ["volume", "l"]
//   result = parseMetricUnit("volume");   // ["volume", undef]
//   result = parseMetricUnit("");         // undef
function parseMetricUnit(str) =
    assert(is_str(str), "[parseMetricUnit] str must be a string")
    str == "" ? undef :
    let (
        parts = split(str, ","),
        metric = trim(parts[0]),
        unit = len(parts) > 1 ? trim(parts[1]) : undef
    )
    metric == "" ? undef : [metric, unit];
