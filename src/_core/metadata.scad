include <constants.scad>

//////////////////////////////////////////////////////////////////////
// LibFile: metadata.scad
//   Metadata handling library for managing and displaying object properties.
// Includes:
//   include <Nervi/_core/metadata.scad>
// FileGroup: Metadata
// FileSummary: Architecture, Metadata
//////////////////////////////////////////////////////////////////////

// Section: Constants
//   Predefined metadata specifications for common properties.
meta_specs = struct_set([], [
	"id",        	 [ "ID"				    							],
	"name",        	 [ "Name"											],
	"type",        	 [ "Type"											],
	"code-prefix",   [ "Code prefix"									],
	
    "volume",        [ "Volume"		, function(v) format_volume(v)		],
	"unit_price",    [ "Unit Price"	, function(v) format_currency(v) 	],
	"weight",    	 [ "Weight"		, function(v) format_weight(v)		],
	"area",    	 	 [ "Area"		, function(v) format_area(v)		],
	"perimeter",     [ "Perimeter"	, function(v) format_length(v)		],
	"section",     	 [ "Section"	, function(v) format_section(v)		],
	"value",    	 [ "Value"		, function(v) format_currency(v)    ],
	"orientation", 	 [ "Orientation"									],
	"qty",        	 [ "Quantity"	, "Unit"							],
	"units",         [ "Units"		, "pce"								],
	"material",      [ "Material"										],
	"linear_meters", [ "Linear Meters"	, function(v) format_length(v)	],
	
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
	struct_val(meta_specs, property);


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
		for ( m = $meta ) 
			let ( s = assert(m[0],"meta 0 cannot be undef") metaSpec(m[0]) )	
				if (s) 
					[ 
						s[0], // Label
						is_function(s[1]) ? s[1](m[1])  : m[1], 
						is_function(s[1]) ? "" : s[1]
					] 
				else if (m[0] == "Materials") 
					[
						"Materials",
						[
							for ( material = m[1] ) 
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
// Example(3D,ColorScheme=Nature,NORENDER)
//   $meta = [["volume", 5], ["weight", 2]];
//   info();  // Outputs a formatted block with Volume and Weight
module info() {
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
// Example(3D,ColorScheme=Nature)
//   printData("Specs", ["Volume : 5 Kg", "Weight : 2 Kg"]);
module printData(title,data) {
    assert(is_def(title), "title must be defined");
    assert(is_string(title), "title must be a string");
	cols = 20;
    header = [
		str_pad("",cols,"*"),
		str_center_pad (title,cols),
		str_pad("",cols,"*"),
    ];
	lines = concat(header,data,str_pad("",cols,"*"));
    echo(str( CR, str_join(lines, CR), CR ));
}	