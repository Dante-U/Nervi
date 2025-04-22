#!/bin/bash


# Function to run openscad-docsgen with your specified options
run_docsgen() {
    clear
    # Check if we are in the virtual environment
    if [ -z "$VIRTUAL_ENV" ] || [ ! "$(basename "$VIRTUAL_ENV")" == "docgen" ]; then
        echo "Activating docgen virtual environment..."
        source docgen/bin/activate || { echo "Failed to activate virtual environment. Make sure 'docgen' exists."; return 1; }
    fi
    echo "Running openscad-docsgen..."
    cd ./src
    #openscad-docsgen -f -P "$project_name" ./*.scad
    openscad-docsgen -P "$project_name" ./*.scad ./_core/*.scad
    cd ..

#    cd ./src/_core
#    openscad-docsgen -f -P "$project_name" ./*.scad
#    cd ../..

    echo "Documentation generation completed."
    compose_template
    echo "Documentation composition completed"
	pwd
   move_core_to_wiki_with_image_merge
}

# Function to run openscad-docsgen with your specified options
run_docsgen_with_force() {
    clear
    # Check if we are in the virtual environment
    if [ -z "$VIRTUAL_ENV" ] || [ ! "$(basename "$VIRTUAL_ENV")" == "docgen" ]; then
        echo "Activating docgen virtual environment..."
        source docgen/bin/activate || { echo "Failed to activate virtual environment. Make sure 'docgen' exists."; return 1; }
    fi
    echo "Running openscad-docsgen..."
    cd ./src
    openscad-docsgen -f -P "$project_name" ./*.scad ./_core/*.scad
    cd ..

#    cd ./src/_core
#    openscad-docsgen -f -P "$project_name" ./*.scad
#    cd ../..
    echo "Documentation generation completed."
    compose_template
    echo "Documentation composition completed"
   move_core_to_wiki_with_image_merge
}

tutorials_docgen() {
    clear
    # Check if we are in the virtual environment
    if [ -z "$VIRTUAL_ENV" ] || [ ! "$(basename "$VIRTUAL_ENV")" == "docgen" ]; then
        echo "Activating docgen virtual environment..."
        source docgen/bin/activate || { echo "Failed to activate virtual environment. Make sure 'docgen' exists."; return 1; }
    fi
    echo "Running openscad-docsgen..."
   echo "Generate tutorials documentations...."
   cd ./tutorials
   openscad-mdimggen 
	
   cd ..

}

# Function to install docgen
install_docgen() {
    echo "Creating virtual environment..."
    python3 -m venv docgen
    source docgen/bin/activate
    echo "Installing openscad_docsgen..."
    pip install openscad_docsgen
    echo "Installation completed."
}

open_docgen_session() {
    echo "Open docgen virtual environment..."
    source docgen/bin/activate
}

# Function to uninstall (deactivate the virtual environment)
uninstall_docgen() {
    echo "Deactivating virtual environment..."
    deactivate
    echo "Virtual environment deactivated."
}

# INI Parser
parse_ini() {
    # Check if file exists and is readable
    local ini_file="$1"
    if [[ ! -f "$ini_file" ]] || [[ ! -r "$ini_file" ]]; then
        echo "Error: Cannot read file $ini_file" >&2
        return 1
    fi  # Changed this brace from } to fi

    # Initialize section variable
    local current_section=""

    # Read the file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Trim whitespace
        line="${line##*( )}"
        line="${line%%*( )}"

        # Skip empty lines and comments
        [[ -z "$line" ]] || [[ "$line" == \#* ]] && continue

        # Check if it's a section
        if [[ "$line" =~ ^\[(.*)\]$ ]]; then
            current_section="${BASH_REMATCH[1]}"
            continue
        fi

        # Parse key-value pairs
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"

            # Trim whitespace from key and value
            key="${key##*( )}"
            key="${key%%*( )}"
            value="${value##*( )}"
            value="${value%%*( )}"

            # Remove quotes if present
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"

            # Create variable name
            local var_name
            if [[ -n "$current_section" ]]; then
                # If in a section, prefix variable with section name
                var_name="${current_section}_${key}"
            else
                var_name="$key"
            fi

            # Make variable name safe for bash
            var_name=$(echo "$var_name" | sed 's/[^a-zA-Z0-9_]/_/g')

            # Export the variable
            #declare -g "$var_name=$value"
            eval "export $var_name='$value'"
        fi
    done < "$ini_file"
}
# Parse config.ini
parse_ini config.ini

# Debug: Print all variables in the environment
echo "Environment variables after parsing:"
printenv | grep -E "project_name|template|doc_folder|version"


compose_template() {
	echo "Composing templates..."
	# Define variables
	template=".template.md"
	#doc_folder="docs"
	doc_folder=$project_doc_folder

	# Create temp files
	tmp_overview=$(mktemp)
	tmp_dependencies=$(mktemp)
	tmp_usage=$(mktemp)
	tmp_installation=$(mktemp)
	tmp_toc=$(mktemp)
	tmp_main=$(mktemp)
	tmp_table_of_contents=$(mktemp)
	tmp_topics=$(mktemp)
	tmp_alpha_index=$(mktemp)
	tmp_sidebar=$(mktemp)


	# Read content into temp files


	process_md "Overview" "$tmp_overview"
	process_md "Dependencies" "$tmp_dependencies"
	process_md "Usage" "$tmp_usage"
	process_md "Installation" "$tmp_usage"
	# process_md "$project_main" "$tmp_main"

	# cat "$doc_folder/shelf.scad.md" > "$tmp_main"

	# Replace image links in main
	# sed -i 's|images/|docs/images/|g' "$tmp_main"
	if [ -f "$doc_folder/${project_main}.md" ]; then
		cat "$doc_folder/${project_main}.md" | sed 's|images/|docs/images/|g' > "$tmp_main"
	fi
	process_md "TOC" "$tmp_toc"
	#process_md "_Sidebar" "$tmp_table_of_contents"
	process_md "Topics" "$tmp_topics"
	process_md "AlphaIndex" "$tmp_alpha_index"
	#process_md "_Sidebar" "$tmp_sidebar"

	# Use sed with file reads
	sed -e "s|{{project_name}}|$project_name|g" \
	    -e "s|{{project_version}}|$project_version|g" \
	    -e "/{{overview}}/r $tmp_overview" -e "/{{overview}}/d" \
	    -e "/{{dependencies}}/r $tmp_dependencies" -e "/{{dependencies}}/d" \
	    -e "/{{usage}}/r $tmp_usage" -e "/{{usage}}/d" \
	    -e "/{{installation}}/r $tmp_usage" -e "/{{installation}}/d" \
	    -e "/{{main}}/r $tmp_main" -e "/{{main}}/d" \
	    -e "/{{toc}}/r $tmp_toc" -e "/{{toc}}/d" \
	    -e "/{{table_of_contents}}/r $tmp_table_of_contents" -e "/{{table_of_contents}}/d" \
	    -e "/{{topics}}/r $tmp_topics" -e "/{{topics}}/d" \
	    -e "/{{alpha_index}}/r $tmp_alpha_index" -e "/{{alpha_index}}/d" \
	    -e "/{{sidebar}}/r $tmp_sidebar" -e "/{{sidebar}}/d" \
	    "$template" > "$doc_folder/Home.md"

	# Clean up temp files
	rm -f "$tmp_overview" "$tmp_dependencies" "$tmp_usage" "$tmp_toc" "$tmp_table_of_contents" "$tmp_topics" "$tmp_alpha_index" "$tmp_sidebar"

	echo "README.md has been generated."
}

process_md() {
    #local src_file="$doc_folder/$1.md"
    #local dest_file="$2"
    local src_file="./docs/$1.md"
    local dest_file="$2"
    if [ -f "$src_file" ]; then
        if [ "$1" == "$project_main" ]; then
            sed 's|images/|docs/images/|g' "$src_file" > "$dest_file"
        else
            cat "$src_file" > "$dest_file"
        fi
    fi
}

move_core_to_wiki_with_image_merge() {
    # Check if source directory exists
    if [ ! -d "./wiki/_core" ]; then
        echo "Error: Source directory ./wiki/_core does not exist" >&2
        return 1
    fi

    # Ensure target directory exists
    if [ ! -d "./wiki" ]; then
        mkdir -p ./wiki || {
            echo "Error: Failed to create target directory ./wiki/" >&2
            return 1
        }
        echo "Created target directory ./wiki/"
    fi

    # Enable dotglob to include hidden files
    shopt -s dotglob

    # Handle the images directory merge first
    if [ -d "./wiki/_core/images" ]; then
        # Ensure ./wiki/images exists
        if [ ! -d "./wiki/images" ]; then
            mv -f ./wiki/_core/images ./wiki/ || {
                echo "Error: Failed to move ./wiki/_core/images to ./wiki/images" >&2
                return 1
            }
            echo "Moved ./wiki/_core/images to ./wiki/images"
        else
            # Merge contents of ./wiki/_core/images into ./wiki/images
            mv -f ./wiki/_core/images/* ./wiki/images/ || {
                echo "Error: Failed to merge contents of ./wiki/_core/images into ./wiki/images" >&2
                return 1
            }
            echo "Merged contents of ./wiki/_core/images into ./wiki/images"
            # Remove the now-empty images dir in _core
            rmdir ./wiki/_core/images 2>/dev/null || echo "Warning: ./wiki/_core/images not empty" >&2
        fi
    fi

    # Move remaining contents from ./wiki/_core/ to ./wiki/
    contents=(./wiki/_core/*)
    if [ ${#contents[@]} -gt 0 ] && [ "$(ls -A ./wiki/_core)" != "" ]; then
        mv -f ./wiki/_core/* ./wiki/ || {
            echo "Error: Failed to move remaining contents from ./wiki/_core/ to ./wiki/" >&2
            echo "Check: ls -la ./wiki/_core/ and ls -la ./wiki/" >&2
            return 1
        }
        echo "Moved remaining contents from ./wiki/_core/ to ./wiki/"
    else
        echo "No remaining contents to move from ./wiki/_core/ (after images merge)"
    fi

    # Remove _core if empty
    rmdir ./wiki/_core 2>/dev/null || echo "Note: ./wiki/_core retained (not empty)" >&2
    echo "Successfully completed move and merge from ./wiki/_core/ to ./wiki/"
    return 0
}



# Main script logic
echo "Nervi make script"
echo "----------------------"
echo "1. Doc Generation"
echo "2. Install docgen"
echo "3. Uninstall docgen"
echo "4. Open Docgen session"
echo "5. Doc Generation with force regeneration"
echo "6. Tutorials generation"
echo "q. Exit"

while true; do
    read -p "Choose an option (1/2/3/4/5/6/q): " choice
    
    case $choice in
        1)
            run_docsgen
            ;;
        2)
            install_docgen
            ;;
        3)
            uninstall_docgen
            ;;
        4)
            open_docgen_session
            ;;
        5)
            run_docsgen_with_force
            ;;
        6)
            tutorials_docgen
            ;;
        q)
            echo "Exiting script. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
