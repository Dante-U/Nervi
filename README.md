# Nervi - OpenSCAD Architectural Modeling Library

![](https://raw.githubusercontent.com/wiki/Dante-U/Nervi/images/logo/nervi-logo-1024-416.jpg)


> [!CAUTION]
> Work in Progress

Nervi is an OpenSCAD library for parametric architectural modeling, inspired by the innovative designs of Italian engineer-architect Pier Luigi Nervi. Built on top of the BOSL2 library, Nervi provides a modular, efficient framework for creating 3D spaces, walls, openings, and dividers, ideal for architects, designers, and makers.
 Work in Progress Warning 

Nervi is actively under development and not yet stable. Features may change, bugs may exist, and documentation may be incomplete. Use with caution and expect breaking changes. Contributions and feedback are welcome to shape its future!




Open-Source: Licensed under the MIT License for maximum flexibility.

## Installation

- Download Nervi:
	- Clone the repository: git clone https://github.com/Dante-U/nervi.git
	- Or download the latest release from GitHub Releases (#).
- Install BOSL2:
	- Nervi requires the `https://github.com/BelfrySCAD/BOSL2` library. Install it by cloning or downloading it to your OpenSCAD library folder.
- Add to OpenSCAD:
	- Place the Nervi folder in your OpenSCAD library path or include it in your project directory.
	- Include Nervi in your .scad file: include <nervi/nervi.scad>

## Usage

Nervi provides a suite of modules and functions to model architectural spaces parametrically. Below is an example inspired by the masterSuite usage:
openscad

```openscad
include <nervi/nervi.scad>
include <BOSL2/std.scad>

module masterSuite(l=3, w=2, h=2.5) {
    $space_length = l;
    $space_width  = w;
    $space_height = h;
    $space_wall   = 0.2;
    
    spaceWrapper() {
        space(name="Master-Suite", info=true, except=[BACK, FORWARD]) {
            attachWalls(faces=[LEFT, RIGHT], placement="both")
                placeOpening(anchors=[CENTER], w=1.2, h=2, opening=0.5)
                    cuboid([1200, 200, 2000], anchor=FORWARD);
            placeFurniture(anchors=[LEFT], inset=[3000, 0])
                cuboid([1500, 800, 400], anchor=FORWARD); // Simulated bed
        }
    }
}
masterSuite();
```

This example creates a 3x2x2.5 m room with 0.2 m walls, openings on the left and right walls, and furniture placement, showcasing Nervi’s modularity.

## Modules and Functions

- space(): Creates a 3D room with walls, supporting exclusions and IFC metadata.
- attachWalls(): Attaches geometry to specified wall sides, with inside/outside placement.
- placeOpening(): Positions openings (e.g., doors, windows) on walls with customizable anchors.
- divider(): Generates internal partition walls within a space.
- spaceWrapper(): Wraps a space with a bounding box for attachments.
- roomBound(): Calculates the room’s bounding box, including wall thickness.

See the wiki documentation for detailed usage and examples.

## Documentation
Nervi’s documentation follows the openscad_docsgen format. Each module and function includes:

- Synopsis: A brief overview.
- Topics: Relevant categories (e.ColorScheme=TomorrowGeometry).
- Description: Detailed explanation.
- Arguments: Parameter descriptions.
- Context Variables: Dependencies on $space_* variables.
- Examples: Visual examples with ColorScheme=Nature.

Explore the wiki for generated documentation.

## Contributing
Nervi is a work in progress, and contributions are welcome! To contribute:
Fork the repository.

- Create a feature branch: git checkout -b feature/your-feature.
- Commit changes: git commit -m "Add your feature".
- Push to the branch: git push origin feature/your-feature.
- Open a pull request.

Please follow the Code of Conduct (CODE_OF_CONDUCT.md) and ensure code adheres to Nervi’s best practices (e.g., `https://github.com/BelfrySCAD/openscad_docsgen` documentation, BOSL2 compatibility).

## License
Nervi is licensed under the MIT License. See the LICENSE file for details.
plaintext

```
Copyright (c) 2025 Kalpana

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```


## Work in Progress Warning
Nervi is under active development!  

- The library is not yet stable, and APIs may change.
- Some features (e.g., advanced IFC metadata, furniture placement) are incomplete.
- Bugs or performance issues may arise in complex models.
- Test thoroughly before using in production, and report issues on GitHub Issues (#).

## Inspiration

Named after Pier Luigi Nervi, whose innovative concrete structures (e.g., Palazzo dello Sport in Rome) revolutionized architecture, Nervi aims to empower parametric design with the same spirit of creativity and precision. The library draws on Nervi’s legacy to provide tools for architects and designers to craft intricate, functional spaces.

## Contact

- Issues: Report bugs or request features on GitHub Issues (#).
- Community: Join the OpenSCAD community on Reddit or Discord (#) to discuss Nervi.
- Author: Sébastien Ursini - [sursini@gmail.com (mailto:sursini@gmail.com)]


