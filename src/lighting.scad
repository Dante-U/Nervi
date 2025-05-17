include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: lighting.scad
//   The Nervi lighting library provides modules for modeling interior lighting fixtures,
//   including spotlights, LED strips, and pendant lights, tailored for architectural and
//   interior design applications. It supports realistic lighting properties such as color
//   temperature (2700K–6500K), lumens, and wattage, with metadata for BIM workflows.
//   Modules leverage BOSL2 for geometry and attachment, and integrate with Nervi’s core
//   utilities for material rendering and structural calculations. All dimensions follow
//   standard units: meters for large dimensions (e.g., ray height), millimeters for smaller
//   dimensions (e.g., spacing, diameters).
// Includes:
//   include <lighting.scad>
// FileGroup: Interior Equipment
// FileSummary: Architecture space definitions
//////////////////////////////////////////////////////////////////////
include <_materials/multi_material.scad>

SPOTS 			= 1;
LED_STRIPS 		= 2;
PENDANT_LIGHTS 	= 3;

// Typical luminous efficacy for LEDs in lumens per Watt.
// This value can range from 70 lm/W for basic LEDs to over 150 lm/W for high-efficiency ones.
// We use a general average for estimation.
DEFAULT_LED_EFFICACY = 100; // lm/W

// For LED Strips, it's common to find lumen ratings per unit length.
// Good quality LED strips are often around 1500 lumens/meter.
// 1500 lumens / 1000 mm = 1.5 lumens/mm
LUMENS_PER_MM_STRIP = 1.5; // lm/mm


function isValidLightSource( source ) = is_in(source, [SPOTS,LED_STRIPS,PENDANT_LIGHTS] );


// Function: spotTypes()
//
// Synopsis: Returns a structure of predefined spotlight profiles.
// Topics: Lighting, Specifications
// Usage:
//   types = spotTypes();
// Description:
//   Provides a structure mapping spotlight type names to their specifications,
//   including physical height, beam angle, lumens, wattage, color temperature,
//   and base diameter. Height is in meters; diameter is in millimeters.
// Example:
//   types = spotTypes();
//   echo(types); // Outputs structure with Small recessed, Medium track, Large pendant
function spotTypes() = struct_set([], [
	//					Height	Angle	Lumens	Wattage	C-Temp		Diameter
	"Small recessed", 	[50		, 30	, 800	, 8		, 2700, 	55	], // MR16-like, 5cm, 30°, 800lm, 8W, warm
    "Medium track"	 , 	[100	, 25	, 1200	, 13	, 3000, 	80	],	// PAR20-like, 10cm, 25°, 1200lm, 13W, soft
    "Large pendant" , 	[150	, 20	, 2000	, 20	, 4000, 	110	]	// PAR30-like, 15cm, 20°, 2000lm, 20W, neutral
]);

SPOT_HEIGHT		= 0;
SPOT_ANGLE		= 1;
SPOT_LUMENS		= 2;
SPOT_WATTAGE	= 3;
SPOT_TEMP		= 4;
SPOT_DIAMETER	= 5;

// Function: spotSpecs()
//
// Synopsis: Retrieves specifications for a spotlight type.
// Topics: Lighting, Specifications
// See Also: spots(), spotTypes()
// Usage:
//   specs = spotSpecs(name, [property]);
// Description:
//   Returns the specifications for a given spotlight type, or a specific property
//   if specified. Properties include physical height, beam angle, lumens, wattage,
//   color temperature, and base diameter.
// Arguments:
//   name     = Name of the spotlight type (e.g., "Small recessed").
//   property = Specific property index (e.g., SPOT_HEIGHT) [default: undef].
// Example:
//   height = spotSpecs("Small recessed", SPOT_HEIGHT); // Returns 0.05
//   specs = spotSpecs("Medium track"); // Returns full spec array
function spotSpecs(name, property) =
    assert(is_def(name), "[spotSpecs] Missing spot name argument")
    let (
		data = spotTypes(),
        spec = struct_val(data, name)
    )
    assert(is_def(spec), str("[spotSpecs] Unknown spot profile: ", name))
    is_def(property) ? spec[property] : spec;


function tempToColor(temp) = 
	temp <= 2700 ? "#FFE0AD" : 	// Warm White
	temp <= 3000 ? "#FFE5BF" : 	// Soft White
	temp <= 4000 ? "#FFF2E0" : // NeutralWhite
	temp <= 5000 ? "#FFFAF2" :  	// CoolWhite" 
		"#F2FAFF";			// Day Light 

// Module: lightColor()
//
// Synopsis: Applies a color to children based on a specified color temperature.
// Topics: Lighting, Materials, Rendering
// See Also: spots(), ledStrip(), pendantLight()
// Usage:
//   lightColor(temp, [alpha]) { <children> }
// Description:
//   Colors its children with a hex color corresponding to the given color temperature
//   (in Kelvin), suitable for rendering light sources like spotlights or LED strips.
//   Uses a realistic color mapping for common lighting temperatures (2700K to 6500K),
//   with interpolation for intermediate values. Designed for interior lighting design
//   within the Nervi library, leveraging the tempToColor() function for consistency.
//   The color is applied with a specified opacity to simulate light emission.
// Arguments:
//   temp  = Color temperature in Kelvin (e.g., 2700, 4000).
//   alpha = Opacity of the color [default: 0.5].
// Example(3D):
//   xdistribute(400) {
//      lightColor(2700) cuboid(300);	
//      lightColor(2000) cuboid(300);	
//      lightColor(3000) cuboid(300);	
//      lightColor(4000) cuboid(300);	
//      lightColor(7000) cuboid(300);	
//   }	
module lightColor( temp, alpha = 0.5 ) {
	assert(temp,"[lightColor] missing temp argument")
	let (
		color = 
			temp <= 2700 ? "#FFE0AD" : 	// Warm White
			temp <= 3000 ? "#FFE5BF" : 	// Soft White
			temp <= 4000 ? "#FFF2E0" : 	// NeutralWhite
			temp <= 5000 ? "#FFFAF2" :  // CoolWhite" 
				"#F2FAFF"	
	)
	color(color,alpha) 
		children();
} 	



// Module: spots()
//
// Synopsis: Creates a series of conical spotlights with customizable dimensions.
// Topics: Architecture, Lighting, Interior Design
// See Also: ledStrip(), pendantLight()
// Usage:
//   spots([height], [ang], [count], [spacing], [anchor], [spin], [info]);
// Description:
//   Generates a row of conical spotlights, each with a specified height and beam angle,
//   arranged along the X-axis with configurable spacing. Uses BOSL2 for geometry and
//   attachment, with a material system for rendering. Suitable for architectural lighting
//   designs within the Nervi library. All dimensions are in millimeters.
// Arguments:
//   type    	= Spotlight type ("Small recessed", "Medium track", "Large pendant") [default: "Small recessed"].
//   h  	 	= Physical height of each spotlight in mm [default: from type].
//	 ray_h       = Light ray height for 3D view in meters [default: $space_height or 2].	
//   lumens     = Total luminous flux per spotlight in lumens [default: from type or calculated].
//   wattage    = Power consumption per spotlight in watts [default: from type].
//   color_temp = Color temperature in Kelvin (e.g., 2700, 4000) [default: from type].
//   angle     	= Beam angle of the spotlight in degrees [default: 10].
//   count   	= Number of spotlights [default: 1].
//   spacing 	= Spacing between spotlights in millimeters [default: 200].
//   anchor  	= BOSL2 anchor point [default: TOP].
//   spin    	= Rotation angle in degrees around Z-axis [default: 0].
//   info    	= Metadata callback function for IFC export [default: undef].
// Example(3D): Five spots separated by 300 mm
//   spots(ray_h=2, angle=10, count=5, spacing=300);
// Example(3D): Single top spot
//   include <space.scad>
//   include <masonry-structure.scad>
//   space(l=3, w=2, h=2.5, wall=200, name="Room", except=[FRONT,LEFT],debug=true) {
//      slab($color="IndianRed");
//      position(TOP)
//         spots(type="Small recessed",angle=90,anchor=TOP);
//   }
module spots(
	type        = "Small recessed",
	ray_h       = first_defined([is_undef(h) 	? undef : h ,is_undef($space_height) ? undef : $space_height ]),
	height			,
	lumens,
	wattage,	
	color_temp,
    angle     	,
    count   	= 1,
    spacing 	= 200,
    anchor  	= TOP,
    spin    	= 0,
	unit_price	= 0,
	name,
    info
) {
   // Validate type
    assert(in_list(type, struct_keys(spotTypes())), str("[spots] type must be one of: ", struct_keys(spotTypes())));

    // Select profile or override with user values
    _h 			= first_defined([ height, spotSpecs(type, SPOT_HEIGHT) ] );
	_ray_h 		= meters(ray_h); // Default to 2m if no $space_height
    _ang 		= first_defined([angle,spotSpecs(type, SPOT_ANGLE)]);
    _lumens 	= first_defined([
		lumens, 
		spotSpecs(type, SPOT_LUMENS), 
		//estimate_lumens(SPOTS, count=1, target_diam=spotSpecs(type, SPOT_DIAMETER))
	]);
    _wattage 	= first_defined([wattage, spotSpecs(type, SPOT_WATTAGE)]);
    _color_temp = first_defined([color_temp, spotSpecs(type, SPOT_TEMP)]);
    _base_diam 	= spotSpecs(type, SPOT_DIAMETER);

    // Assertions
    assert(is_num_positive(_h), 				"[spots] height must be positive number or derive from type");
    assert(is_meters(ray_h), 					"[spots] ray_h must be a positive number (meters)");
    assert(is_num(count) && count >= 1, 		"[spots] count must be a positive integer");
    assert(is_num_positive(spacing), 			"[spots] spacing must be a positive number (millimeters)");
    assert(is_num(_lumens) && _lumens >= 0, 	"[spots] lumens must be a non-negative number");
    assert(is_num(_wattage) && _wattage >= 0, 	"[spots] wattage must be a non-negative number");
    assert(is_num(_color_temp) && _color_temp >= 2000 && _color_temp <= 6500, 
				"[spots] color_temp must be between 2000 and 6500 Kelvin");
	
    _target_diam = adj_ang_to_opp(_ray_h, _ang/2); // Base diameter based on ray height
    size = [
		_target_diam * count + spacing * (count - 1), 
		_target_diam, 
		_ray_h
	];
    //_material = "YellowLight";

    if (provideMeta(info)) {
        volume = mm3_to_m3(PI * _h * (_target_diam/2)^2 / 3); // Volume based on physical height
        _ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
        $meta = [
            ["name",        str("Spotlight", is_undef(name) ? "" : str(" '", name, "'"))],
            ["volume",      volume],
            ["lumens",      _lumens * count],
            ["wattage",     _wattage * count],
            ["color_temp",  _color_temp],
            ["height",		 _h],
            ["ray_height",  _ray_h],
            ["ifc_class",   "IfcLightFixture"],
            ["ifc_type",    str("Spotlight_", type)],
            ["ifc_guid",    _ifc_guid]
        ];
        info();
    }
    attachable(anchor=anchor, spin=spin, orient=UP, size=size) {
		lightColor(_color_temp)
            xcopies(n=count, spacing=spacing)
                //cyl(l=_ray_h, r1=_target_diam/2, r2=25/2);
				cyl(l=_ray_h, r1=_target_diam/2, r2=_h);
        children();
    }
}



// Module: ledStrip()
//
// Synopsis: Creates a cylindrical LED strip for interior lighting with customizable lighting properties.
// Topics: Lighting, Interior Design, Rendering
// See Also: spots(), pendantLight(), lightColor()
// Usage:
//   ledStrip(length, [radius], [color_temp], [lumens], [wattage], [anchor], [spin], [name], [info], [unit_price]);
// Description:
//   Generates a cylindrical LED strip along the X-axis, tailored for architectural lighting designs.
//   Supports realistic lighting properties, including color temperature (2700K–6500K) via lightColor(),
//   lumens, and wattage, with metadata for BIM workflows. Uses BOSL2 for geometry and attachment,
//   rendering a cylinder with the specified length and radius. All dimensions are in millimeters.
// Arguments:
//   length      = Length of the LED strip in millimeters.
//   radius      = Radius of the LED strip in millimeters [default: 75].
//   color_temp  = Color temperature in Kelvin (e.g., 2700, 4000) [default: 3000].
//   lumens      = Total luminous flux in lumens [default: calculated from length].
//   wattage     = Power consumption in watts [default: calculated from lumens].
//   anchor      = BOSL2 anchor point [default: undef].
//   spin        = Rotation angle in degrees around Z-axis [default: undef].
//   name        = Descriptive name for the LED strip (e.g., "Philips Hue") [default: undef].
//   info        = Metadata callback function for IFC export [default: undef].
//   unit_price  = Cost per LED strip in dollars [default: 0].
// Example(3D): Warm white LED strip
//   ledStrip(length=1000, radius=75, color_temp=2700);
// Example(3D): Neutral white LED strip with metadata
//   ledStrip(length=1500, radius=50, color_temp=4000, name="Osram Linear", info=true);
module ledStrip(
    length,
    radius      = 75,
    color_temp  = 3000,
    lumens      = undef,
    wattage     = undef,
    anchor      = undef,
    spin        = undef,
    name        = undef,
    info        = undef,
    unit_price  = 0
) {
    // Assertions
    assert(is_num_positive(length), "[ledStrip] length must be a positive number (millimeters)");
    assert(is_num_positive(radius), "[ledStrip] radius must be a positive number (millimeters)");
    assert(is_num(color_temp) && color_temp >= 2000 && color_temp <= 6500, 
           "[ledStrip] color_temp must be between 2000 and 6500 Kelvin");
    
    // Calculate lumens and wattage if not provided
    _lumens  = first_defined([lumens, length * LUMENS_PER_MM_STRIP]);
    _wattage = first_defined([wattage, _lumens / DEFAULT_LED_EFFICACY]);
    
    // Additional assertions for calculated values
    assert(is_num(_lumens) && _lumens >= 0, "[ledStrip] lumens must be a non-negative number");
    assert(is_num(_wattage) && _wattage >= 0, "[ledStrip] wattage must be a non-negative number");

    bounding_size = [length, radius*2, radius*2];
    
    // Metadata for IFC export
    if (provideMeta(info)) {
        volume = mm3_to_m3(PI * radius * radius * length); // m³
        _ifc_guid = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
        $meta = [
            ["name",        str("LEDStrip", is_undef(name) ? "" : str(" '", name, "'"))],
            ["volume",      volume],
            ["lumens",      _lumens],
            ["wattage",     _wattage],
            ["color_temp",  color_temp],
            ["length",      length],
            ["radius",      radius],
            ["ifc_class",   "IfcLightFixture"],
            ["ifc_type",    "LEDStrip"],
            ["ifc_guid",    _ifc_guid],
            ["unit_price",  unit_price],
            ["cost",        unit_price]
        ];
        info();
    }

    attachable(anchor=anchor, spin=spin, orient=UP, size=bounding_size, cp=[0, -radius, -radius]) {
        lightColor(color_temp)
            cyl(l=length, r=radius, orient=LEFT, anchor=CENTER);
        children();
    }
}

// Module: pendantLight()
//
// Synopsis: Creates a pendant light with a cord and light-emitting shade for interior lighting.
// Topics: Lighting, Interior Design, Rendering
// See Also: spots(), ledStrip(), lightColor()
// Usage:
//   pendantLight([type], [cordLength], [height], [width], [color_temp], [lumens], [wattage], [anchor], [spin], [name], [info], [unit_price]);
// Description:
//   Generates a pendant light with a cord and a shade (cylindrical or conical), suspended from
//   the anchor point. The shade emits light based on the specified color temperature (2700K–6500K)
//   using lightColor(), with lumens and wattage for realistic lighting properties. Supports metadata
//   for BIM workflows, with an IfcLightFixture classification. Uses BOSL2 for geometry and attachment,
//   rendering a thin cord and a tubular shade. All dimensions are in millimeters.
// Arguments:
//   type        = Shade type ("cylinder", "conic") [default: "cylinder"].
//   cordLength  = Length of the cord in millimeters [default: 1200].
//   height      = Height of the shade in millimeters [default: 250].
//   width       = Width (diameter) of the shade in millimeters [default: 400].
//   color_temp  = Color temperature in Kelvin (e.g., 2700, 4000) [default: 3000].
//   lumens      = Total luminous flux in lumens [default: calculated from width and height].
//   wattage     = Power consumption in watts [default: calculated from lumens].
//   anchor      = BOSL2 anchor point [default: TOP].
//   spin        = Rotation angle in degrees around Z-axis [default: undef].
//   name        = Descriptive name for the pendant light (e.g., "Artemide Tolomeo") [default: undef].
//   info        = Metadata callback function for IFC export [default: undef].
//   unit_price  = Cost per pendant light in dollars [default: 0].
// Example(3D): Warm white cylindrical pendant
//   pendantLight(type="cylinder", cordLength=1200, height=250, width=400, color_temp=2700);
// Example(3D): Conical pendant with neutral white and metadata
//   pendantLight(type="conic", cordLength=1000, height=300, width=350, color_temp=4000, name="Flos Skygarden", info=true);
module pendantLight(
    type        = "cylinder",
    cordLength  = 1200,
    height      = 250,
    width       = 400,
    color_temp  = 3000,
    lumens      = undef,
    wattage     = undef,
    anchor      = TOP,
    spin        = undef,
    name        = undef,
    info        = undef,
    unit_price  = 0
) {
    // Assertions
    assert(in_list(type, ["cylinder", "conic"]), 	"[pendantLight] type must be 'cylinder' or 'conic'");
    assert(is_num_positive(cordLength), 			"[pendantLight] cordLength must be a positive number (millimeters)");
    assert(is_num_positive(height), 				"[pendantLight] height must be a positive number (millimeters)");
    assert(is_num_positive(width), 					"[pendantLight] width must be a positive number (millimeters)");
    assert(is_num(color_temp) && color_temp >= 2000 && color_temp <= 6500, 
						"[pendantLight] color_temp must be between 2000 and 6500 Kelvin");

    // Calculate lumens and wattage if not provided (based on shade surface area)
    _shade_area = PI * width * height; // Approximate surface area in mm²
    _lumens     = first_defined([lumens, _shade_area * 0.05]); // 0.05 lm/mm², rough estimate
    _wattage    = first_defined([wattage, _lumens / DEFAULT_LED_EFFICACY]);

    // Additional assertions for calculated values
    assert(is_num(_lumens) && _lumens >= 0, 		"[pendantLight] lumens must be a non-negative number");
    assert(is_num(_wattage) && _wattage >= 0, 		"[pendantLight] wattage must be a non-negative number");

    bounding_size = [width, width, cordLength + height];
    wall_thickness = 5; // Fixed wall thickness from original module
    cord_diameter  = 6; // Fixed cord diameter from original module

    // Metadata for IFC export
    if (provideMeta(info)) {
        shade_volume = mm3_to_m3(PI * (width/2 - wall_thickness)^2 * height); // Inner shade volume in m³
        cord_volume  = mm3_to_m3(PI * (cord_diameter/2)^2 * cordLength); // Cord volume in m³
        volume       = shade_volume + cord_volume;
        _ifc_guid    = is_undef(ifc_guid) ? generate_guid() : ifc_guid;
        $meta = [
            ["name",        str("PendantLight", is_undef(name) ? "" : str(" '", name, "'"))],
            ["volume",      volume],
            ["lumens",      _lumens],
            ["wattage",     _wattage],
            ["color_temp",  color_temp],
            ["cord_length", cordLength],
            ["shade_height", height],
            ["shade_width", width],
            ["ifc_class",   "IfcLightFixture"],
            ["ifc_type",    str("Pendant_", type)],
            ["ifc_guid",    _ifc_guid],
            ["unit_price",  unit_price],
            ["cost",        unit_price]
        ];
        info();
    }

    attachable(anchor=anchor, spin=spin, orient=UP, size=bounding_size) {
        up(bounding_size.z - cordLength)
            material("Chrome")
                cyl(h=cordLength, d=cord_diameter, anchor=CENTER)
                    align(BOT)
                        lightColor(color_temp, alpha=0.5) {
                            if (type == "cylinder") {
                                tube(h=height, od1=width, od2=width, wall=wall_thickness, anchor=TOP);
                            } else if (type == "conic") {
                                tube(h=height, od1=width, od2=width*0.75, wall=wall_thickness, anchor=TOP);
                            }
                        }
        children();
    }
}
