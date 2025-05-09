# Nervi OpenSCAD Architecture Library

## Include Structure Analysis

This document describes the include dependency structure of the Nervi OpenSCAD library, confirming that there are no recursive includes.

### Key Findings

- The codebase uses a clean hierarchical include structure
- No circular dependencies exist between files
- Proper use of `include` vs `use` statements prevents recursive includes
- The potential circular dependency between masonry-structure.scad and space.scad is avoided by using `use` instead of `include`

### Dependency Tree

```
main.scad
├── constants.scad
    └── BOSL2/std.scad

masonry-structure.scad
├── main.scad
├── masonry.scad
└── space.scad
    ├── main.scad
    └── use <masonry.scad>  // Important: uses, not includes

metal-structure.scad
├── main.scad
└── metal.scad
    ├── BOSL2/std.scad
    └── BOSL2/rounding.scad

wood-structure.scad
├── main.scad
└── wood.scad
    └── BOSL2/std.scad
```

### Best Practices for Include Management

1. Use `include` only when you need all symbols from a file
2. Use `use` when you only need module and function definitions but not variables
3. Maintain a clear hierarchy with core files at the top
4. Be careful when including files that include other files to avoid circular dependencies
5. Document include relationships in larger projects

### include vs use in OpenSCAD

- `include <file.scad>` brings in all symbols (variables, modules, functions)
- `use <file.scad>` only brings in module and function definitions, not variables
- Using `use` helps avoid namespace conflicts and circular dependencies

