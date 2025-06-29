#!/bin/bash

# XML Module Example Script
# Demonstrates XML parsing, validation, and manipulation capabilities

# Import bash-lib
source "$(dirname "$0")/../../core/init.sh"

# Import required modules
import xml
import console
import file

console.info "=== XML Module Examples ==="

# Create a sample Hive configuration XML file
console.section "Creating Sample XML Configuration"

xml.create "hive-site.xml" "configuration" --root-attributes="version='1.0'"

# Add some Hive properties
xml.add_property "hive-site.xml" "hive.server2.port" "10000" --description="HiveServer2 port"
xml.add_property "hive-site.xml" "hive.server2.host" "localhost" --description="HiveServer2 host"
xml.add_property "hive-site.xml" "hive.metastore.uris" "thrift://localhost:9083" --description="Metastore URIs"
xml.add_property "hive-site.xml" "hive.exec.scratchdir" "/tmp/hive" --description="Scratch directory"
xml.add_property "hive-site.xml" "hive.warehouse.dir" "/user/hive/warehouse" --description="Warehouse directory"

console.success "Created hive-site.xml with sample configuration"

# Display the created XML
console.section "Sample XML Configuration"
cat hive-site.xml

# XML Validation Examples
console.section "XML Validation Examples"

if xml.validate "hive-site.xml"; then
    console.success "XML file is valid"
else
    console.error "XML file validation failed"
fi

# XML Property Extraction Examples
console.section "XML Property Extraction Examples"

# Extract specific properties
port=$(xml.get_value "hive-site.xml" "hive.server2.port" --property)
host=$(xml.get_value "hive-site.xml" "hive.server2.host" --property)
warehouse_dir=$(xml.get_value "hive-site.xml" "hive.warehouse.dir" --property)

console.info "HiveServer2 Port: $port"
console.info "HiveServer2 Host: $host"
console.info "Warehouse Directory: $warehouse_dir"

# Extract with default value
non_existent=$(xml.get_value "hive-site.xml" "hive.non.existent" --property --default="default_value")
console.info "Non-existent property (with default): $non_existent"

# XPath extraction example
xpath_port=$(xml.get_value "hive-site.xml" "//property[name='hive.server2.port']/value")
console.info "Port via XPath: $xpath_port"

# Get all properties
console.section "All Properties (Key-Value Format)"
xml.get_properties "hive-site.xml"

# Get properties with pattern filtering
console.section "HiveServer2 Properties Only"
xml.get_properties "hive-site.xml" --pattern="hive\.server2\..*"

# Get properties in JSON format
console.section "Properties in JSON Format"
echo "{"
xml.get_properties "hive-site.xml" --format="json"
echo "}"

# XML Property Checking Examples
console.section "XML Property Checking Examples"

if xml.contains "hive-site.xml" "hive.server2.port" --property; then
    console.success "Property 'hive.server2.port' exists"
else
    console.error "Property 'hive.server2.port' not found"
fi

if xml.contains "hive-site.xml" "hive.server2.port" "10000" --property; then
    console.success "Property 'hive.server2.port' has expected value '10000'"
else
    console.error "Property 'hive.server2.port' does not have expected value"
fi

if xml.contains "hive-site.xml" "hive.non.existent" --property; then
    console.error "Unexpected: Property 'hive.non.existent' exists"
else
    console.success "Property 'hive.non.existent' correctly not found"
fi

# XML Property Modification Examples
console.section "XML Property Modification Examples"

# Update existing property
console.info "Updating hive.server2.port to 10001"
xml.set_value "hive-site.xml" "hive.server2.port" "10001" --property

# Verify the change
new_port=$(xml.get_value "hive-site.xml" "hive.server2.port" --property)
console.info "Updated port: $new_port"

# Add new property
console.info "Adding new property 'hive.server2.transport'"
xml.add_property "hive-site.xml" "hive.server2.transport" "binary" --description="Transport mode"

# Verify new property
transport=$(xml.get_value "hive-site.xml" "hive.server2.transport" --property)
console.info "New transport property: $transport"

# Set value with create if missing
console.info "Setting property with create-if-missing"
xml.set_value "hive-site.xml" "hive.server2.max.connections" "100" --property --create

# Verify created property
max_conn=$(xml.get_value "hive-site.xml" "hive.server2.max.connections" --property)
console.info "Created max connections property: $max_conn"

# Display final XML
console.section "Final XML Configuration"
cat hive-site.xml

# Cleanup
console.section "Cleanup"
rm -f hive-site.xml
console.success "Cleaned up temporary files"

console.info "=== XML Module Examples Completed ==="
