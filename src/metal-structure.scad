include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: metal-structure.scad
//   A library for creating parametric metal structural components in OpenSCAD, designed for superstructure 
//   and architectural applications.
//   Provides a module to extrude 2D metal profiles (e.g., HSS, angle, pipe, channel, I-beam, T-beam) to specified lengths.
//   Supports customizable dimensions and BOSL2 for geometry, attachments, and rendering. Uses millimeters for dimensions,
//   with robust assertions for validation.
// Includes:
//   include <metal-structure.scad>
// FileGroup: Superstructure
// FileSummary: Architecture, Building, Project, Metal
//////////////////////////////////////////////////////////////////////


include <_materials/metal.scad>

// Module: extrudeMetalProfile()
//
// Synopsis: Extrudes a named metal profile to a specified length
// Topics: Metal, Profiles
// Description:
//   Extrudes a 2D metal profile (e.g., HSS, angle, pipe) identified by name to a specified length.
//   The profile is defined by the metalSection function, and arguments are passed as an array.
// Usage:
//   extrudeMetalProfile(section_name, length, args, [anchor], [spin], [orient])
// Arguments:
//   section_name 	= Name of the profile (e.g., "square", "pipe", "corne")
//   length 		= Extrusion length
//   args 			= Array of arguments for the profile function (e.g., [width, height, thickness, rounding])
//   anchor 		= Anchor point (default: CENTER)
//   spin 			= Rotation around z-axis (default: 0)
//   orient 		= Orientation (default: UP)
// Example(3D,ColorScheme=Tomorrow,Small): Square profile
//   extrudeMetalProfile("square", length= 60,width= 50,height= 100,thickness = 3,);
// Example(3D,ColorScheme=Tomorrow,Small): Pipe profile
//   extrudeMetalProfile("pipe",length= 60,diameter= 50,thickness = 3);
// Example(3D,ColorScheme=Tomorrow,Small): Corner profile
//   extrudeMetalProfile("corner",length= 60,width= 50,height= 100,thickness = 3);
// Example(3D,ColorScheme=Tomorrow,Small): Channel profile
//   extrudeMetalProfile("channel",length= 60,width= 50,height= 100,thickness = 3);
// Example(3D,ColorScheme=Tomorrow,Small): iBeam
//   extrudeMetalProfile("ibeam",length= 60,width= 50,height= 100,web_thickness = 3,flange_thickness = 3);
// Example(3D,ColorScheme=Tomorrow,Small): tBeam
//   extrudeMetalProfile("tbeam",length= 60,width= 50,height= 100,web_thickness = 3,flange_thickness = 3); 
module extrudeMetalProfile(
		section_name, 
		length,
		width,
		height,
		diameter,
		thickness,
		web_thickness,
		flange_thickness,
		rounding = 0,
		anchor=CENTER, 
		spin=0, 
		orient=UP
	) {
    assert(is_string(section_name), 	"[extrudeMetalProfile] section_name must be a string");
    assert(length > 0, 					"[extrudeMetalProfile] Length must be positive");
    
	$profile_width 				= width; 
	$profile_height 			= height;
	$profile_diameter 			= diameter;
	$profile_thickness 			= thickness; 
	$profile_web_thickness 		= web_thickness; 
	$profile_flange_thickness 	= flange_thickness; 
	$profile_rounding 			= rounding; 
	
    // Get the 2D profile geometry
    profile = metalSectionPath(section_name)();
	bound = boundingSize( profile );
	size = [bound.x,bound.y,length];
    attachable(anchor, spin, orient, size=size) {
        linear_extrude(height=length, center=true) region(profile);
        children();
    }
}