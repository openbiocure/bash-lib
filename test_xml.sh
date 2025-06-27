#!/bin/bash

# Simple test for XML module
source core/init.sh
import xml

echo "Testing XML module..."

# Create a test XML file
xml.create "test.xml" "configuration"

# Add some properties
xml.add_property "test.xml" "hive.server2.port" "10000"
xml.add_property "test.xml" "hive.server2.host" "localhost"

# Test getting values
port=$(xml.get_value "test.xml" "hive.server2.port" --property)
host=$(xml.get_value "test.xml" "hive.server2.host" --property)

echo "Port: $port"
echo "Host: $host"

# Display the XML
cat test.xml

# Cleanup
rm -f test.xml
echo "Test completed."
