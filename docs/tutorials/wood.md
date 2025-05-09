# Wood materials

The wood.scad library provides a structured database of wood specifications, including Brazilian, global, and engineered woods. It defines constants for property indices, a wood_specs structure with detailed data, and a woodSpecs function to query properties. This library is useful for OpenSCAD projects requiring material properties for structural or aesthetic purposes, such as designing furniture, buildings, or engineered components.


## Constants

The following constants define indices for accessing properties in the wood_specs structure:

- MATERIAL_DENSITY (0): Density in kg/m³.
- MATERIAL_COMPRESSIVE_STRENGTH (1): Compressive strength in MPa.
- MATERIAL_ELASTICITY (2): Modulus of elasticity in MPa.
- MATERIAL_STRENGTH_CLASS (3): Strength class (e.g., "C40", "N/A").
- MATERIAL_APPLICATION (4): List of applications (e.g., ["flooring", "beams"]).
- MATERIAL_DESCRIPTION (5): Description of the material and its scientific name.

## Data Structure: wood_specs

The wood_specs variable is a structure (created with struct_set) containing specifications for various woods, including Brazilian woods (e.g., Ipe, Jatoba), global woods (e.g., Oak, Teak), and engineered woods (e.g., Plywood, CLT). Each wood entry is an array with six properties corresponding to the constants above.

```
[
    730,        // Density (kg/m³)
    46.8,       // Compressive Strength (MPa)
    12000,      // Modulus of Elasticity (MPa)
    "C40",      // Strength Class
    ["structural beams", "flooring", "roof structures"],
    "High mechanical strength; suitable for structural applications in civil construction, aka Eucalyptus saligna."
]
```

## Function: woodSpecs

Syntax : 

```js
woodSpecs(wood_name, property)
```

### Parameters
- wood_name (string): The name of the wood (e.g., "Ipe", "Oak", "Plywood").

- property (integer, optional): The index of the desired property (e.g., MATERIAL_DENSITY, MATERIAL_APPLICATION). If omitted, returns the full specification array for the wood.
### Returns

- If property is specified: The value of the requested property (e.g., number, string, or list).
- If property is omitted: The full specification array for the wood.
### Description

Retrieves specifications for a given wood from wood_specs. Use this function to access specific properties like density or applications, or to retrieve the entire specification for a wood.

## Usage Examples

Example 1: Querying a Specific Property

Retrieve the density of "Ipe":

```scad
include <Nervi/_materials/wood.scad>
density = woodSpecs("Ipe", MATERIAL_DENSITY);
echo("Ipe density:", density); // Outputs: Ipe density: 1050
```
















