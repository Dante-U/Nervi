## Installation

To use this Nervi, create a symbolic link from your project’s `src/` directory to OpenSCAD’s library path. This allows you to include files like `spaces.scad` in your designs with `include <Nervi/spaces.scad>`.

### Prerequisites
- OpenSCAD installed on your system.
- Admin privileges (for `sudo` access) to modify the library directory.

### Steps
1. **Locate Your OpenSCAD Library Path**  
   The default library path depends on your operating system:
   - **macOS (Intel)**: `/usr/local/share/openscad/libraries/`
   - **macOS (Apple Silicon, Homebrew)**: `/opt/homebrew/share/openscad/libraries/`
   - **Linux**: `/usr/share/openscad/libraries/` or `~/.local/share/OpenSCAD/libraries/`
   - **Windows**: Check OpenSCAD’s preferences (e.g., `C:\Program Files\OpenSCAD\libraries\`).

   Verify your path in OpenSCAD under **Edit > Preferences > Libraries**.

2. **Create the Symbolic Link**  
   Open a terminal, navigate to the project root directory (where `src/` resides), and run the appropriate command:

   ```bash
   ln -s "$(/bin/pwd)/src" /usr/local/share/openscad/libraries/Nervi
   ```
   