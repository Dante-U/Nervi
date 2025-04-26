//include <BOSL2/std.scad>
include <utils.scad>
include <strings.scad>

module echo_list(values,level = 0,label = "List Values")  {
	lines = echo_list(values,level);
	cols = 40;
	echo(str(
			CR,str_center_pad("",cols,"*"),
			CR,"*",str_center_pad(label,cols-2),"*",
			"\n",str_center_pad("",cols,"*"),
			CR,
			str_join(lines, CR),
			//"\n ************************"
			CR,str_center_pad("",cols,"*"),
		)
	);
} 	

function echo_list(values,level = 0,label) =
	let (
		tab = tab( level )
	)
	flatten(
	concat(
		is_def(label) ? [str(tab,label)]: [],
		[
			if (is_path(values)) 				
				echo_path(values,level)
			else 	
			for (item = values)
				if (is_path(item)) 				
					echo_path(values,level)
				else 
				if (is_list(item)) 				
					if (len(item) == 2 && is_string(item[1])  )				// Pair of string
						str(tab,item[0]," :",item[1])
					else if (len(item) == 2 && is_list(item[1])  )			// string and array
						
						echo_list(item[1] ,level = level+1,label=str(item[0]," [Array]"))	
					// 	
					else if (is_vector(item))	
						echo_vector(item,level)
					else
						str(tab( level + 1 ),item[0], " : ", item[1],"s is_ path",is_path(item))
		]
	)
	);
	
	
function echo_path( path,level = 0 ) =	
	flatten([
		str(tab( level + 1 ),len(path) ==2 ? "Pair:" : "Path:" /*,len(path)*/),
		for (pt = path) 
			if (is_path(pt))
				echo_path( pt,level+1 )
			else  	
				echo_vector(pt,level+1)
			
	]);
	
	
function echo_vector( value,level = 0 ) =
	str_join (flatten(
		[
			tab( level + 1 ),
			"vector",
			[ for (i = [0:len(value)-1]) str_left_pad (str(value[i]),8 ) ]
	]));	
	


// Still in dev
module rectRuler(
		length  	= first_defined([is_undef(length) 	? undef : length,	$parent_size.x ]),
		width		= first_defined([is_undef(width) 	? undef : width,	$parent_size.y ]),
		thickness   = 2,
		origin 		= LEFT+FRONT,
		sideMarks 	= false, 
		coordinates	= false,
		majorColor  = "black",
		minorColor  = "gray",
		textColor   = "white",		
	    unit        = "m",
		scale       = 1000  // Default: 1 unit = 1mm, display as m (1/1000)
	) {
	assert($parent_geom != undef, "No parent to add ruler !");

	w = width; // 	/ 1000;
	l = length;// 	/ 1000;
	
	echo ("width",width);
	echo ("length",length);
	
	extrude = 10;
	
	//cuboid ( [ length, width , 1000 ] );
	//echo ("_w",_w);
	//echo ("_l",_l);
	
    // Determine appropriate subdivision based on ruler size
    subdivision = 
        w < 50   ? 5  :  // Very small	: 5mm
        w < 200  ? 10 :  // Small		: 1cm
        w < 500  ? 50 :  // Medium		: 5cm
        w < 2000 ? 100 : // Large		: 10cm
                   200;  // Very large 	: 20cm
	
	  // Dynamic subdivision based on width (in meters)
    subdiv = w < 0.01 ? 0.01 : w <= 0.1 ? 0.005 : w < 0.5 ? 0.1 : 0.05;
	echo ("origin",origin);
	echo ("subdivision",subdivision);
		echo ("subdiv",subdiv);
	
	//xCount = ceil(length / subdivision);
	//yCount = ceil(width / subdivision);
    xCount = ceil(length / subdivision) ;  // +1 to ensure coverage
    yCount = ceil(width / subdivision) ;	
	
	echo ("xCount",xCount);
	echo ("yCount",yCount);
	
	echo ("sideMarks",sideMarks);
	echo ("coordinates",coordinates);
	//lt = subdivision/10;
	//fontSize = 2;
	//font="Courier New:style=Italic";
	//font="Roboto:style=Thin";
	//font="Arial:style=Regular";
	font="Liberation Sans";
	
	    // Text properties
    fontSize = subdivision / 10;
    textOffset = subdivision / 8;
	
	tOffset = subdivision/10;
	
	
	{
		xcopies (spacing=subdivision,n=xCount){
			lt = subdivision/(($idx % 5 == 0 ? 20 : 60 )*10);
			//measure = (origin.x == -1 ? $idx : xCount-($idx+1)) * subdivision/1000;
			measure = $pos.x / 1000;
			
			color("Green") cuboid([lt,width,extrude]);
			
			if (sideMarks)
				color("Black") 
					back(width/(2-0.1))
						linear_extrude (extrude) 
							//text(str(  measure ," m"),size = fontSize,font = font);
                                text(str(measure, " ", unit), 
                                     size=fontSize,
                                     font=font,
                                     halign="left",
                                     valign="bottom");							
		}
		// Horizontal
		ycopies (spacing=subdivision,n=yCount){
			lt = subdivision/(($idx % 5 == 0 ? 20 : 60 ));
			measure = $pos.y / 1000;
			color("Red")cuboid([length,lt,extrude]);
			if (sideMarks)
				color("White") 
					left(length/(2-0.1))
					linear_extrude (extrude) 
						//text(str(  measure ," m"),size = fontSize,font = font,anchor=RIGHT);
                                text(str(measure, " ", unit), 
                                     size=fontSize,
                                     font=font,
                                     halign="left",
                                     valign="bottom");
		}
		if (coordinates)
		grid_copies (spacing=subdivision,n=[xCount,yCount] ) {
			p = $pos/1000;
			//color("Black")
			color(textColor)
			translate([tOffset,tOffset*4,0])
				linear_extrude (extrude) 
					text (str(p.x*1500),size=fontSize ,font = font,valign="bottom");
			color(textColor)		
			translate([tOffset,tOffset,0])
				linear_extrude (extrude) 
					text (str(p.y*1500   ),size=fontSize ,font = font,valign="bottom");
		}	
		
		 // Coordinate markers at grid points
		 /*
            if (coordinates) {
                for (ix = [0:floor(l/subdivision)]) {
                    for (iy = [0:floor(w/subdivision)]) {
                        xPos = ix * subdivision;
                        yPos = iy * subdivision;
                        coordX = xPos / scale;
                        coordY = yPos / scale;
                        
                        translate([xPos + textOffset, yPos + textOffset, 0])
                            color(textColor)
                            linear_extrude(thickness * 2)
                                text(str("(", coordX, ",", coordY, ")"),
                                     size=fontSize * 0.8,
                                     font=font,
                                     halign="left",
                                     valign="bottom");
                    }
                }
            }
		*/	
	}	
}


/**
 * Creates a customizable rectangular ruler with markings
 * 
 * @param length Length of the ruler (defaults to parent x size if available)
 * @param width Width of the ruler (defaults to parent y size if available)
 * @param thickness Thickness/height of the ruler markings
 * @param origin Origin point for the ruler (affects positioning)
 * @param sideMarks Whether to show measurement labels on the sides
 * @param coordinates Whether to show x,y coordinates at grid points
 * @param majorColor Color for major markings
 * @param minorColor Color for minor markings
 * @param textColor Color for text labels
 * @param unit Unit to display (e.g., "m", "cm", "mm")
 * @param scale Scale factor to convert from model units to displayed units
 */
module rectRuler2(
    length      = first_defined([is_undef($parent_size) ? 1000 : $parent_size.x]),
    width       = first_defined([is_undef($parent_size) ? 1000 : $parent_size.y]),
    thickness   = 2,
    origin      = LEFT+FRONT,
    sideMarks   = true,
    coordinates = false,
    majorColor  = "black",
    minorColor  = "gray",
    textColor   = "white",
    unit        = "m",
    scale       = 1000  // Default: 1 unit = 1mm, display as m (1/1000)
) {
    // Check if parent geometry exists, but make it a warning rather than error
    if ($parent_geom == undef) {
        echo("WARNING: No parent geometry for ruler. Using specified dimensions.");
    }
    
    // Convert to working units (mm)
    w = width;
    l = length;
    
    echo("Ruler width:", w, "mm");
    echo("Ruler length:", l, "mm");
    
    // Determine appropriate subdivision based on ruler size
    subdivision = 
        w < 50   ? 5  :  // Very small	: 5mm
        w < 200  ? 10 :  // Small		: 1cm
        w < 500  ? 50 :  // Medium		: 5cm
        w < 2000 ? 100 : // Large		: 10cm
                   200;  // Very large 	: 20cm
                   
    // Calculate number of markings needed
    xCount = ceil(l / subdivision) + 1;  // +1 to ensure coverage
    yCount = ceil(w / subdivision) + 1;
    
    echo("Subdivision:", subdivision, "mm");
    echo("X markings:", xCount);
    echo("Y markings:", yCount);
    
    // Text properties
    fontSize = subdivision / 10;
    font = "Liberation Sans";
    textOffset = subdivision / 8;
    
    // Draw ruler
    difference() {
        union() {
            // X-axis markings
            for (i = [0:xCount-1]) {
                xPos = i * subdivision;
                if (xPos <= l) {  // Only draw if within bounds
                    isMajor = (i % 5 == 0);
                    markWidth = isMajor ? subdivision/20 : subdivision/60;
                    markHeight = isMajor ? thickness * 1.5 : thickness;
                    
                    // Calculate measurement value
                    measure = xPos / scale;
                    
                    translate([xPos, 0, 0])
                        color(isMajor ? majorColor : minorColor)
                        cuboid([markWidth, w, markHeight], anchor=BOTTOM+LEFT);
                    
                    // Side measurement labels for major marks
                    if (sideMarks && isMajor) {
                        translate([xPos, w - textOffset, 0])
                            color(textColor)
                            linear_extrude(thickness * 2)
                                text(str(measure, " ", unit), 
                                     size=fontSize,
                                     font=font,
                                     halign="left",
                                     valign="bottom");
                    }
                }
            }
            
            // Y-axis markings
            for (i = [0:yCount-1]) {
                yPos = i * subdivision;
                if (yPos <= w) {  // Only draw if within bounds
                    isMajor = (i % 5 == 0);
                    markWidth = isMajor ? subdivision/20 : subdivision/60;
                    markHeight = isMajor ? thickness * 1.5 : thickness;
                    
                    // Calculate measurement value
                    measure = yPos / scale;
                    
                    translate([0, yPos, 0])
                        color(isMajor ? majorColor : minorColor)
                        cuboid([l, markWidth, markHeight], anchor=BOTTOM+LEFT);
                    
                    // Side measurement labels for major marks
                    if (sideMarks && isMajor) {
                        translate([textOffset, yPos, 0])
                            color(textColor)
                            linear_extrude(thickness * 2)
                                text(str(measure, " ", unit), 
                                     size=fontSize,
                                     font=font,
                                     halign="left",
                                     valign="bottom");
                    }
                }
            }
            
            // Coordinate markers at grid points
            if (coordinates) {
                for (ix = [0:floor(l/subdivision)]) {
                    for (iy = [0:floor(w/subdivision)]) {
                        xPos = ix * subdivision;
                        yPos = iy * subdivision;
                        coordX = xPos / scale;
                        coordY = yPos / scale;
                        
                        translate([xPos + textOffset, yPos + textOffset, 0])
                            color(textColor)
                            linear_extrude(thickness * 2)
                                text(str("(", coordX, ",", coordY, ")"),
                                     size=fontSize * 0.8,
                                     font=font,
                                     halign="left",
                                     valign="bottom");
                    }
                }
            }
        }
    }
}

/**
 * Displays debug information for a path by visualizing its self-crossings.
 * 
 * @param path - The input path to analyze for self-crossings.
 * 
 * This module:
 * - Splits the path at points where it intersects itself.
 * - Renders each segment of the split path with different colors for easy identification.
 */
module showDebugPath( path ) {
    assert(is_path(path),"Path to show is not a path");
    assert(is_path_simple(path),"Path is not simple");
    rainbow(split_path_at_self_crossings(path)) 
        stroke($item, closed=false, width=0.2);
}