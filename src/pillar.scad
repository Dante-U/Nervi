include <_core/main.scad>
//////////////////////////////////////////////////////////////////////
// LibFile: pillar.scad
// Includes:
//   include <pillar.scad>
// FileGroup: Superstructure
// FileSummary: Architecture, Pillars
//////////////////////////////////////////////////////////////////////

// Module: rectPillar()
//
// Synopsis: Creates a rectangular pillar with customizable section and material.
// Topics: Structures, Superstructure
// See Also: obliquePillar()
// Description:
//   Generates a vertical rectangular pillar with a specified length and cross-section.
//   Supports material assignment, corner rounding, and attachment of child geometry.
// Arguments:
//   l          = Length of the pillar (in meters). No default.
//   section    = [width, depth] of the pillar’s cross-section. No default.
//   material   = Material name for rendering. [default: "Wood"]
//   rounding   = Corner rounding radius. [default: 0]
//   anchor     = Anchor point for attachment. [default: CENTER]
//   spin       = Rotation around Z-axis (degrees). [default: 0]
// DefineHeader(Generic):Children:
//   Objects to attach to the pillar.
// Usage:
//   rectPillar(l,section); 
// Example(3D,ColorScheme=Nature): Simple pillar with rounding
//   rectPillar(l=1, section=[150, 200], rounding=5);
module rectPillar(l,section,material= "Wood",rounding = 0,anchor,spin) {
	assert( is_num_positive(l),		"[obliquePillar] [l] is undefined.");
	assert( is_vector(section,2),	"[obliquePillar] [section] is undefined.");
	bounding_size = [section[X],section[Y],meters(l)];
	attachable( size = bounding_size,cp=[0,0,meters(l)/2],anchor, spin)  {
		union() {
			material( material ) cuboid( size = bounding_size , anchor=BOTTOM );
		}
		children();
	}	
}  

// Module: obliquePillar()
//
// Synopsis: Creates an oblique pillar with customizable sections and tilt.
// Topics: Pillars, Superstructure
// See Also: rectPillar() 
// Description:
//   Generates a slanted pillar connecting two rectangular sections over a specified length,
//   with optional rounding, material, and offset. The pillar tilts at an angle, adjustable via
//   explicit offset or derived from the angle and length. Supports attachment of children.
// Arguments:
//   l          = Length of the pillar along its vertical axis (in meters). No default.
//   section1   = [width, depth] of the bottom section. No default.
//   section2   = [width, depth] of the top section. [default: section1]
//   angle      = Angle of slant (degrees) from vertical. No default.
//   offset     = Horizontal offset between sections. [default: derived from l and angle]
//   spin       = Rotation around Z-axis (degrees). [default: 0]
//   material   = Material name for rendering. [default: "Wood"]
//   rounding   = Corner rounding radius. [default: 0]
//   anchor     = Anchor point for attachment. [default: CENTER]
//   debug      = If true, shows bounding box as ghost. [default: false]
// DefineHeader(Generic):Children:
//   Objects to attach to the pillar.
// Usage:
//   obliquePillar(l, section1,section2,angle,offset); 
// Example(3D,ColorScheme=Nature): Oblique pillar using angleX
//   obliquePillar(l=1, section1=[100, 100], angleX=20);
// Example(3D,ColorScheme=Nature): Oblique pillar using offsetX
//   obliquePillar(l=1, section1=[100, 100], offsetX=300);
// Example(3D,ColorScheme=Nature): Oblique pillar using angleY and different sections
//   obliquePillar(l=1, section1=[200, 200], section2=[150, 150],angleY=25);
// Example(3D,ColorScheme=Nature,NoAxes): Test with TOP attachments
//   cuboid([800,800,100])
//      attach(TOP,BOT,align=corners(BOT))
//         obliquePillar(
//            l=1.5,
//            section1=[100,100],
//            offsetX=$align[X] * 300,
//            offsetY=$align[Y] * 300,
//            anchor=BOT+$align
//         );
// Example(3D,ColorScheme=Nature,NoAxes): Test with BOTTOM attachments
//   cuboid([800,800,100])
//      attach(BOT,TOP,align=corners(BOT))
//         obliquePillar(
//            l=1.5,
//            section1=[100,100],
//            offsetX=$align[X] * 300,
//            offsetY=$align[Y] * 300,
//            anchor=TOP+$align
//         );
module obliquePillar(
		l,
		section1,
		section2,
		angleX = 0,
		angleY = 0,
		offsetX,
		offsetY,
		spin = 0,
		material= "Wood",
		rounding = 0,
		anchor = BOT,
		debug=false
	) 
{
	assert(is_num_positive(l) ,		"[obliquePillar] [l] is undefined. Provide length of pillar");
	assert(is_vector(section1,2),	"[obliquePillar] [section1] is undefined. Provide at least section1");
	assert( is_def(offsetX) || is_def(offsetY) || is_def(angleX) || is_def(angleY), 
									"[obliquePillar] offset or angle should be defined");	
	_l = meters(l);
	offsetX 			= is_undef(offsetX) && is_def(angleY) && angleY > 0  ? adj_ang_to_opp(_l,angleY) : is_def(offsetX) ? offsetX : 0;
	offsetY 			= is_undef(offsetY) && is_def(angleX) && angleX > 0  ? adj_ang_to_opp(_l,angleX) : is_def(offsetY) ? offsetY : 0;
	section2 		= default(section2,section1); 
	bounding_size 	= 
		anchor[Z] == -1 ? 
			[
				section1[X],
				section1[Y],
				_l
			] :
		anchor[Z] == 1 ? 
			[
				section2[X],
				section2[Y],
				_l
			]
		:
	[
		max(section1[X],section2[X]) + abs(offsetX),
		max(section1[Y],section2[Y]) + abs(offsetY),
		_l
	];
	
	cp = [anchor[Z] * offsetX/2,anchor[Z] * offsetY/2,0];
	zrot(spin)
	attachable( size = bounding_size,cp=cp,anchor=anchor /*, spin=spin*/)  {
		union() {
			if (debug) ghost() cuboid(bounding_size);
			material( material )
				skin(
					[
						move([-offsetX/2,-offsetY/2,-_l/2]	,path3d(rect(section1,rounding=rounding))),
						move([offsetX/2,offsetY/2,_l/2]		,path3d(rect(section2,rounding=rounding)))
						//move([anchor[X]*offset/2,	0,	-_l/2],path3d(rect(section1,rounding=rounding))),
						//move([anchor[X]*-offset/2,	0,	+_l/2],path3d(rect(section2,rounding=rounding)))
					],
					slices=10
				);
		}
		children();
	}	
}  