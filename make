#!/bin/bash

# ANSI color codes
BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Function to activate the docgen virtual environment
activate_docgen_env() {
    if [ -z "$VIRTUAL_ENV" ] || [ ! "$(basename "$VIRTUAL_ENV")" == "docgen" ]; then
        echo -e "${YELLOW}Activating docgen virtual environment...${NC}"
        source docgen/bin/activate || {
            echo -e "${RED}Error: Failed to activate virtual environment. Make sure 'docgen' exists.${NC}" >&2
            return 1
        }
    fi
    return 0
}

# Function to run openscad-docsgen with optional force and verbose flags
run_docsgen() {
    local force=${1:-false}
    local verbose=${2:-false}

    clear
    activate_docgen_env || return 1

    echo -e "${CYAN}Running openscad-docsgen${force:+ with force flag}...${NC}"
    cd ./src
    if [ "$force" = true ]; then
        openscad-docsgen -f -P "$project_name" ./*.scad ./_core/*.scad ./_materials/*.scad
    else
        openscad-docsgen -P "$project_name" ./*.scad ./_core/*.scad ./_materials/*.scad
    fi
    cd .. || { echo -e "${RED}Error: Failed to return to parent directory${NC}" >&2; return 1; }

    echo -e "${GREEN}Documentation generation completed.${NC}"
    compose_template
    echo -e "${GREEN}Documentation composition completed${NC}"
    pwd
    flatten_wiki_structure "./wiki/_core" "./wiki" "$verbose"
    flatten_wiki_structure "./wiki/_materials" "./wiki" "$verbose"
}

# Function to generate tutorial documentation
tutorials_docgen() {
    local force=${1:-false}
    clear
    activate_docgen_env || return 1

    echo -e "${CYAN}Running openscad-mdimggen...${NC}"
    echo -e "${CYAN}Generating tutorials documentation...${NC}"
    cd ./docs/tutorials
    if [ "$force" = true ]; then
        openscad-mdimggen -f
    else    
        openscad-mdimggen 
    fi    
    cd ../.. || { echo -e "${RED}Error: Failed to return to parent directory${NC}" >&2; return 1; }
}

# Function to install docgen
install_docgen() {
    clear
    echo -e "${YELLOW}Creating virtual environment...${NC}"
    python3 -m venv docgen
    source docgen/bin/activate
    echo -e "${YELLOW}Installing openscad_docsgen...${NC}"
    pip install openscad_docsgen
    echo -e "${GREEN}Installation completed.${NC}"
}

# Function to uninstall (deactivate the virtual environment)
uninstall_docgen() {
    clear
    echo -e "${YELLOW}Deactivating virtual environment...${NC}"
    deactivate
    echo -e "${GREEN}Virtual environment deactivated.${NC}"
}

# Function to open a docgen session
open_docgen_session() {
    clear
    echo -e "${YELLOW}Opening docgen virtual environment...${NC}"
    source docgen/bin/activate
}

# INI Parser
parse_ini() {
    local ini_file="$1"
    if [[ ! -f "$ini_file" ]] || [[ ! -r "$ini_file" ]]; then
        echo -e "${RED}Error: Cannot read file $ini_file${NC}" >&2
        return 1
    fi

    local current_section=""
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line##*( )}"
        line="${line%%*( )}"
        [[ -z "$line" ]] || [[ "$line" == \#* ]] && continue
        if [[ "$line" =~ ^\[(.*)\]$ ]]; then
            current_section="${BASH_REMATCH[1]}"
            continue
        fi
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            key="${key##*( )}"
            key="${key%%*( )}"
            value="${value##*( )}"
            value="${value%%*( )}"
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            local var_name
            if [[ -n "$current_section" ]]; then
                var_name="${current_section}_${key}"
            else
                var_name="$key"
            fi
            var_name=$(echo "$var_name" | sed 's/[^a-zA-Z0-9_]/_/g')
            eval "export $var_name='$value'"
        fi
    done < "$ini_file"
}

# Parse config.ini
parse_ini config.ini

# Function to flatten a nested wiki structure into a flat layout
flatten_wiki_structure() {
    local source_dir="$1"
    local target_dir="$2"
    local verbose=${3:-false}

    verbose_echo() {
        if [ "$verbose" = true ]; then
            echo -e "$@"
        fi
    }

    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}Error: Source directory $source_dir does not exist${NC}" >&2
        return 1
    fi

    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir" || {
            echo -e "${RED}Error: Failed to create target directory $target_dir${NC}" >&2
            return 1
        }
        verbose_echo "${GREEN}Created target directory $target_dir${NC}"
    fi

    shopt -s dotglob
    verbose_echo "${CYAN}Flattening $source_dir into $target_dir...${NC}"

    if [ -d "$source_dir/images" ]; then
        mkdir -p "$target_dir/images" || {
            echo -e "${RED}Error: Failed to create $target_dir/images${NC}" >&2
            return 1
        }
        if command -v rsync >/dev/null 2>&1; then
            rsync -a --remove-source-files "$source_dir/images/" "$target_dir/images/" || {
                echo -e "${RED}Error: Failed to merge $source_dir/images into $target_dir/images${NC}" >&2
                return 1
            }
            verbose_echo "${GREEN}Merged $source_dir/images into $target_dir/images using rsync${NC}"
        else
            find "$source_dir/images" -type f -exec cp -f {} "$target_dir/images/" \; || {
                echo -e "${RED}Error: Failed to copy files from $source_dir/images to $target_dir/images${NC}" >&2
                return 1
            }
            verbose_echo "${GREEN}Copied files from $source_dir/images to $target_dir/images using cp${NC}"
        fi
        find "$source_dir/images" -type d -empty -delete 2>/dev/null
        rmdir "$source_dir/images" 2>/dev/null || verbose_echo "${YELLOW}Note: $source_dir/images retained (not empty)${NC}" >&2
    fi

    find "$source_dir" -type f -not -path "$source_dir/images/*" -exec mv -f {} "$target_dir/" \; || {
        echo -e "${RED}Error: Failed to move remaining files from $source_dir to $target_dir${NC}" >&2
        return 1
    }
    verbose_echo "${GREEN}Moved remaining files from $source_dir to $target_dir${NC}"

    find "$source_dir" -type d -empty -delete 2>/dev/null
    rmdir "$source_dir" 2>/dev/null || verbose_echo "${YELLOW}Note: $source_dir retained (not empty)${NC}" >&2
    verbose_echo "${GREEN}Successfully flattened $source_dir into $target_dir${NC}"
    return 0
}

compose_template() {
    echo -e "${CYAN}Composing templates...${NC}"
    template=".template.md"
    doc_folder=$project_doc_folder

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

    process_md "Overview" "$tmp_overview"
    process_md "Dependencies" "$tmp_dependencies"
    process_md "Usage" "$tmp_usage"
    process_md "Installation" "$tmp_usage"
    if [ -f "$doc_folder/${project_main}.md" ]; then
        cat "$doc_folder/${project_main}.md" | sed 's|images/|docs/images/|g' > "$tmp_main"
    fi
    process_md "TOC" "$tmp_toc"
    process_md "Topics" "$tmp_topics"
    process_md "AlphaIndex" "$tmp_alpha_index"

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

    rm -f "$tmp_overview" "$tmp_dependencies" "$tmp_usage" "$tmp_toc" "$tmp_table_of_contents" "$tmp_topics" "$tmp_alpha_index" "$tmp_sidebar"
    echo -e "${GREEN}README.md has been generated.${NC}"
}

process_md() {
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

# Main menu function
display_menu() {
    local force_state=$1
    local verbose_state=$2

    clear
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}      Nervi Make Script Menu          ${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo -e "${CYAN}Project: $project_name${NC}"
    echo -e "${CYAN}Version: $project_version${NC}"
    echo -e "${YELLOW}Force: $( [ "$force_state" = true ] && echo "ON" || echo "OFF" )${NC}"
    echo -e "${YELLOW}Verbose: $( [ "$verbose_state" = true ] && echo "ON" || echo "OFF" )${NC}"
    echo -e "${BLUE}--------------------------------------${NC}"
    echo -e "${GREEN}1. Run Doc Generation${NC}"
    echo -e "${GREEN}2. Generate Tutorials${NC}"
    echo -e "${GREEN}3. Toggle Force Mode${NC}"
    echo -e "${GREEN}4. Toggle Verbose Mode${NC}"
    echo -e "${GREEN}5. Install Docgen${NC}"
    echo -e "${GREEN}6. Uninstall Docgen${NC}"
    echo -e "${GREEN}7. Open Docgen Session${NC}"
    echo -e "${RED}q. Exit${NC}"
    echo -e "${BLUE}--------------------------------------${NC}"
    echo -e "${CYAN}Select an option (1-7, q):${NC} \c"
}

# Main script logic
force=false
verbose=false

while true; do
    display_menu "$force" "$verbose"
    read -r choice

    case $choice in
        1)
            run_docsgen "$force" "$verbose"
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        2)
            tutorials_docgen
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        3)
            force=$([ "$force" = true ] && echo false || echo true)
            ;;
        4)
            verbose=$([ "$verbose" = true ] && echo false || echo true)
            ;;
        5)
            install_docgen
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        6)
            uninstall_docgen
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        7)
            open_docgen_session
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        q|Q)
            echo -e "${RED}Exiting script. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
    esac
done