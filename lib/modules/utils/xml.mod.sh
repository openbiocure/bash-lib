#!/bin/bash

# XML Module for bash-lib
# Provides XML parsing, validation, and manipulation utilities

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "xml" "${BASH__PATH:-/opt/bash-lib}/modules/utils/xml.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console
import string

# XML Module Configuration
__XML__DEFAULT_INDENT=2
__XML__DEFAULT_ENCODING="UTF-8"

##
## (Usage) Extract value from XML by XPath or property name
## Examples:
##   xml.get_value "config.xml" "//property[name='hive.server2.port']/value"
##   xml.get_value "config.xml" "hive.server2.port" --property
##   xml.get_value "config.xml" "//server/port"
##
function xml.get_value() {
    local file="$1"
    local path="$2"
    shift 2

    local property_mode=false
    local default_value=""
    local silent=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --property | -p) property_mode=true ;;
        --default=*) default_value="${arg#*=}" ;;
        --silent | -s) silent=true ;;
        *) ;;
        esac
    done

    if [[ -z "$file" ]]; then
        console.error "XML file path is required"
        return 1
    fi

    if [[ -z "$path" ]]; then
        console.error "XPath or property name is required"
        return 1
    fi

    if [[ ! -f "$file" ]]; then
        console.error "XML file does not exist: $file"
        return 1
    fi

    local result=""

    # Handle property mode (for Hive-style XML)
    if [[ "$property_mode" == true ]]; then
        result=$(xml.__extract_property_value "$file" "$path")
    else
        result=$(xml.__extract_xpath_value "$file" "$path")
    fi

    if [[ -n "$result" ]]; then
        echo "$result"
        return 0
    elif [[ -n "$default_value" ]]; then
        echo "$default_value"
        return 0
    else
        [[ "$silent" == false ]] && console.error "No value found for path: $path"
        return 1
    fi
}

##
## (Usage) Set value in XML file
## Examples:
##   xml.set_value "config.xml" "//property[name='hive.server2.port']/value" "10000"
##   xml.set_value "config.xml" "hive.server2.port" "10000" --property
##
function xml.set_value() {
    local file="$1"
    local path="$2"
    local value="$3"
    shift 3

    local property_mode=false
    local create_if_missing=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --property | -p) property_mode=true ;;
        --create | -c) create_if_missing=true ;;
        *) ;;
        esac
    done

    if [[ -z "$file" || -z "$path" || -z "$value" ]]; then
        console.error "File, path, and value are required"
        return 1
    fi

    if [[ ! -f "$file" ]]; then
        console.error "XML file does not exist: $file"
        return 1
    fi

    # Handle property mode
    if [[ "$property_mode" == true ]]; then
        xml.__set_property_value "$file" "$path" "$value" "$create_if_missing"
    else
        xml.__set_xpath_value "$file" "$path" "$value"
    fi
}

##
## (Usage) Validate XML file structure
## Examples:
##   xml.validate "config.xml"
##   xml.validate "config.xml" --schema="schema.xsd"
##
function xml.validate() {
    local file="$1"
    shift

    local schema=""
    local strict=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --schema=*) schema="${arg#*=}" ;;
        --strict | -s) strict=true ;;
        *) ;;
        esac
    done

    if [[ -z "$file" ]]; then
        console.error "XML file path is required"
        return 1
    fi

    if [[ ! -f "$file" ]]; then
        console.error "XML file does not exist: $file"
        return 1
    fi

    # Basic XML structure validation
    if ! xml.__validate_structure "$file"; then
        console.error "Invalid XML structure in $file"
        return 1
    fi

    # Schema validation if provided
    if [[ -n "$schema" ]]; then
        if ! xml.__validate_schema "$file" "$schema"; then
            console.error "XML file does not conform to schema: $schema"
            return 1
        fi
    fi

    console.success "XML file is valid: $file"
    return 0
}

##
## (Usage) Get all properties from XML file
## Examples:
##   xml.get_properties "config.xml"
##   xml.get_properties "config.xml" --pattern="hive.*"
##
function xml.get_properties() {
    local file="$1"
    shift

    local pattern=""
    local format="key-value"

    # Parse options
    for arg in "$@"; do
        case $arg in
        --pattern=*) pattern="${arg#*=}" ;;
        --format=*) format="${arg#*=}" ;;
        *) ;;
        esac
    done

    if [[ -z "$file" ]]; then
        console.error "XML file path is required"
        return 1
    fi

    if [[ ! -f "$file" ]]; then
        console.error "XML file does not exist: $file"
        return 1
    fi

    xml.__extract_all_properties "$file" "$pattern" "$format"
}

##
## (Usage) Check if XML contains specific property or value
## Examples:
##   xml.contains "config.xml" "hive.server2.port"
##   xml.contains "config.xml" "//server/port" "10000"
##
function xml.contains() {
    local file="$1"
    local path="$2"
    local expected_value="${3:-}"

    if [[ -z "$file" || -z "$path" ]]; then
        console.error "File and path are required"
        return 1
    fi

    local actual_value=$(xml.get_value "$file" "$path" --silent)

    if [[ -z "$actual_value" ]]; then
        return 1
    fi

    if [[ -n "$expected_value" ]]; then
        [[ "$actual_value" == "$expected_value" ]]
    else
        return 0
    fi
}

##
## (Usage) Create XML file with basic structure
## Examples:
##   xml.create "config.xml" "configuration"
##   xml.create "config.xml" "configuration" --root-attributes="version='1.0'"
##
function xml.create() {
    local file="$1"
    local root_element="$2"
    shift 2

    local root_attributes=""
    local encoding="${__XML__DEFAULT_ENCODING}"

    # Parse options
    for arg in "$@"; do
        case $arg in
        --root-attributes=*) root_attributes="${arg#*=}" ;;
        --encoding=*) encoding="${arg#*=}" ;;
        *) ;;
        esac
    done

    if [[ -z "$file" || -z "$root_element" ]]; then
        console.error "File and root element are required"
        return 1
    fi

    xml.__create_file "$file" "$root_element" "$root_attributes" "$encoding"
}

##
## (Usage) Add property to XML file
## Examples:
##   xml.add_property "config.xml" "hive.server2.port" "10000"
##   xml.add_property "config.xml" "hive.server2.host" "localhost" --description="Server host"
##
function xml.add_property() {
    local file="$1"
    local name="$2"
    local value="$3"
    shift 3

    local description=""
    local overwrite=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --description=*) description="${arg#*=}" ;;
        --overwrite | -f) overwrite=true ;;
        *) ;;
        esac
    done

    if [[ -z "$file" || -z "$name" || -z "$value" ]]; then
        console.error "File, name, and value are required"
        return 1
    fi

    xml.__add_property "$file" "$name" "$value" "$description" "$overwrite"
}

xml.__add_property() {
    local file="$1"
    local name="$2"
    local value="$3"
    local description="$4"
    local overwrite="$5"

    # Check if property already exists
    if xml.contains "$file" "$name" --property; then
        if [[ "$overwrite" == true ]]; then
            xml.set_value "$file" "$name" "$value" --property
        else
            console.warn "Property '$name' already exists, use --overwrite to update"
            return 1
        fi
    else
        # Add new property before closing root tag
        local temp_file=$(mktemp)
        local found=false

        while IFS= read -r line; do
            # Check if this is the closing root tag and we haven't added the property yet
            if [[ "$line" == *"</"*">"* ]] && [[ "$found" == false ]]; then
                # Add the property before the closing tag
                echo "  <property>"
                echo "    <name>$name</name>"
                echo "    <value>$value</value>"
                if [[ -n "$description" ]]; then
                    echo "    <description>$description</description>"
                fi
                echo "  </property>"
                found=true
            fi
            echo "$line"
        done <"$file" >"$temp_file"

        mv "$temp_file" "$file"
        console.success "Added property '$name' to $file"
    fi
}

# Internal helper functions

xml.__extract_xpath_value() {
    local file="$1"
    local xpath="$2"

    # Method 1: Try xmlstarlet (most reliable)
    if command -v xmlstarlet >/dev/null 2>&1; then
        xmlstarlet sel -t -v "$xpath" "$file" 2>/dev/null && return 0
    fi

    # Method 2: Try xmllint
    if command -v xmllint >/dev/null 2>&1; then
        xmllint --xpath "$xpath/text()" "$file" 2>/dev/null && return 0
    fi

    # Method 3: Use grep/sed for simple XPath-like queries
    xml.__extract_with_grep "$file" "$xpath"
}

xml.__extract_property_value() {
    local file="$1"
    local property_name="$2"

    # Use grep/sed for robust property extraction
    local temp_file=$(mktemp)

    # Extract property blocks
    sed -n '/<property>/,/<\/property>/p' "$file" >"$temp_file"

    # Find the specific property
    local found=false
    local in_property=false
    local current_name=""
    local current_value=""

    while IFS= read -r line; do
        # Check for property start
        if [[ "$line" == *"<property>"* ]]; then
            in_property=true
            current_name=""
            current_value=""
        # Check for property end
        elif [[ "$line" == *"</property>"* ]]; then
            if [[ "$in_property" == true && "$current_name" == "$property_name" ]]; then
                echo "$current_value"
                found=true
                break
            fi
            in_property=false
        # Check for name tag
        elif [[ "$in_property" == true && "$line" == *"<name>"* ]]; then
            current_name=$(echo "$line" | sed 's/.*<name>\(.*\)<\/name>.*/\1/')
        # Check for value tag
        elif [[ "$in_property" == true && "$line" == *"<value>"* ]]; then
            current_value=$(echo "$line" | sed 's/.*<value>\(.*\)<\/value>.*/\1/')
        fi
    done <"$temp_file"

    rm -f "$temp_file"
    [[ "$found" == true ]]
}

xml.__extract_with_grep() {
    local file="$1"
    local xpath="$2"

    # Simple XPath-like parsing for common patterns
    case "$xpath" in
    "//property[name='*']/value")
        local prop_name="${xpath#*name='}"
            prop_name="${prop_name%'*}"
        xml.__extract_property_value "$file" "$prop_name"
        ;;
    *)
        # Generic element extraction
        local element_name="${xpath##*/}"
        grep -o "<$element_name>[^<]*</$element_name>" "$file" | sed "s/<$element_name>\(.*\)<\/$element_name>/\1/"
        ;;
    esac
}

xml.__set_xpath_value() {
    local file="$1"
    local xpath="$2"
    local value="$3"

    # Use xmlstarlet for setting values
    if command -v xmlstarlet >/dev/null 2>&1; then
        xmlstarlet ed -u "$xpath" -v "$value" "$file" >"${file}.tmp" && mv "${file}.tmp" "$file"
        return $?
    fi

    # Fallback to sed-based replacement
    xml.__set_value_with_sed "$file" "$xpath" "$value"
}

xml.__set_property_value() {
    local file="$1"
    local property_name="$2"
    local value="$3"
    local create_if_missing="$4"

    # Check if property exists
    if xml.contains "$file" "$property_name" --property; then
        # Update existing property using sed
        sed -i.bak "/<name>$property_name<\/name>/,/<\/property>/s/<value>.*<\/value>/<value>$value<\/value>/" "$file"
        rm -f "${file}.bak"
    elif [[ "$create_if_missing" == true ]]; then
        # Add new property
        xml.add_property "$file" "$property_name" "$value"
    else
        console.error "Property '$property_name' not found"
        return 1
    fi
}

xml.__set_value_with_sed() {
    local file="$1"
    local xpath="$2"
    local value="$3"

    # Simple sed-based replacement for basic cases
    sed -i.bak "s|$xpath|$value|g" "$file"
    rm -f "${file}.bak"
}

xml.__validate_structure() {
    local file="$1"

    # Check for basic XML structure
    if ! grep -q "^[[:space:]]*<" "$file"; then
        return 1
    fi

    # Check for balanced tags (simple check)
    local open_tags=$(grep -o "<[^/][^>]*>" "$file" | wc -l)
    local close_tags=$(grep -o "</[^>]*>" "$file" | wc -l)

    [[ $open_tags -eq $close_tags ]]
}

xml.__validate_schema() {
    local file="$1"
    local schema="$2"

    if command -v xmllint >/dev/null 2>&1; then
        xmllint --schema "$schema" "$file" >/dev/null 2>&1
        return $?
    fi

    console.warn "xmllint not available, skipping schema validation"
    return 0
}

xml.__extract_all_properties() {
    local file="$1"
    local pattern="$2"
    local format="$3"

    local temp_file=$(mktemp)
    sed -n '/<property>/,/<\/property>/p' "$file" >"$temp_file"

    local in_property=false
    local current_name=""
    local current_value=""

    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*\<property\>$ ]]; then
            in_property=true
            current_name=""
            current_value=""
        elif [[ "$line" =~ ^[[:space:]]*\</property\>$ ]]; then
            if [[ "$in_property" == true && -n "$current_name" ]]; then
                local should_output=false
                if [[ -z "$pattern" ]]; then
                    should_output=true
                else
                    # Use grep for pattern matching instead of bash regex
                    echo "$current_name" | grep -q "$pattern" && should_output=true
                fi

                if [[ "$should_output" == true ]]; then
                    case "$format" in
                    "key-value")
                        echo "$current_name=$current_value"
                        ;;
                    "json")
                        echo "  \"$current_name\": \"$current_value\","
                        ;;
                    *)
                        echo "$current_name: $current_value"
                        ;;
                    esac
                fi
            fi
            in_property=false
        elif [[ "$in_property" == true ]]; then
            if [[ "$line" =~ ^[[:space:]]*\<name\>(.*)\</name\>$ ]]; then
                current_name="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^[[:space:]]*\<value\>(.*)\</value\>$ ]]; then
                current_value="${BASH_REMATCH[1]}"
            fi
        fi
    done <"$temp_file"

    rm -f "$temp_file"
}

xml.__create_file() {
    local file="$1"
    local root_element="$2"
    local root_attributes="$3"
    local encoding="$4"

    cat >"$file" <<EOF
<?xml version="1.0" encoding="$encoding"?>
<$root_element$([[ -n "$root_attributes" ]] && echo " $root_attributes")>
</$root_element>
EOF

    console.success "Created XML file: $file"
}

##
## (Usage) Show XML module help
##
function xml.help() {
    cat <<EOF
XML Module - XML parsing, validation, and manipulation utilities

Available Functions:
  xml.get_value <file> <path> [options]        - Extract value from XML
  xml.set_value <file> <path> <value> [opts]   - Set value in XML
  xml.validate <file> [options]                - Validate XML structure
  xml.get_properties <file> [options]          - Get all properties
  xml.contains <file> <path> [value]           - Check if XML contains value
  xml.create <file> <root> [options]           - Create XML file
  xml.add_property <file> <name> <value> [opts] - Add property to XML
  xml.help                                     - Show this help

Options:
  --property, -p           - Treat path as property name (Hive-style XML)
  --default=<value>        - Default value if not found
  --silent, -s             - Suppress error messages
  --create, -c             - Create property if missing
  --overwrite, -f          - Overwrite existing property
  --description=<text>     - Add description to property
  --pattern=<regex>        - Filter properties by pattern
  --format=<format>        - Output format (key-value|json|text)
  --schema=<file>          - Validate against XML schema
  --strict, -s             - Strict validation mode
  --root-attributes=<attr> - Root element attributes
  --encoding=<encoding>    - XML encoding (default: UTF-8)

Examples:
  xml.get_value config.xml "//property[name='hive.server2.port']/value"
  xml.get_value config.xml "hive.server2.port" --property
  xml.set_value config.xml "hive.server2.port" "10000" --property
  xml.validate config.xml --schema=schema.xsd
  xml.get_properties config.xml --pattern="hive.*" --format=json
  xml.contains config.xml "hive.server2.port" "10000"
  xml.create config.xml "configuration" --root-attributes="version='1.0'"
  xml.add_property config.xml "hive.server2.port" "10000" --description="Server port"
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_xml="1"
