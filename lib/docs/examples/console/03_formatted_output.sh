#!/bin/bash

# Example: Formatted Output
# This demonstrates tables, JSON output, and custom formatting

# Import bash-lib
source core/init.sh
import console

echo "=== Formatted Output ==="

# Table output
echo ""
echo "=== Table Output ==="
console.table "Name,Age,City" "John,25,New York" "Jane,30,Los Angeles" "Bob,35,Chicago"

# JSON output
echo ""
echo "=== JSON Output ==="
console.json '{"name": "John", "age": 25, "city": "New York"}'

# Formatted output
echo ""
echo "=== Formatted Output ==="
console.format "%-20s %-10s %-15s" "Name" "Age" "City"
console.format "%-20s %-10s %-15s" "John Doe" "25" "New York"
console.format "%-20s %-10s %-15s" "Jane Smith" "30" "Los Angeles"

# Section headers
echo ""
echo "=== Section Headers ==="
console.section "User Information"
console.info "Name: John Doe"
console.info "Email: john@example.com"

console.section "System Status"
console.success "All systems operational"

# Custom styling
echo ""
echo "=== Custom Styling ==="
console.custom "CUSTOM" "This is a custom styled message"
console.bold "This is bold text"
console.italic "This is italic text"
console.underline "This is underlined text"

# Complex table example
echo ""
echo "=== Complex Table Example ==="
console.table "ID,Name,Status,Last Updated" \
    "1,Web Server,Online,2024-01-15 10:30:00" \
    "2,Database,Online,2024-01-15 10:29:45" \
    "3,Cache,Offline,2024-01-15 10:25:12" \
    "4,API Gateway,Online,2024-01-15 10:30:15"

# JSON with complex data
echo ""
echo "=== Complex JSON Output ==="
complex_json='{
  "user": {
    "id": 123,
    "name": "John Doe",
    "email": "john@example.com",
    "roles": ["admin", "user"],
    "preferences": {
      "theme": "dark",
      "language": "en"
    }
  },
  "system": {
    "version": "1.2.3",
    "status": "healthy"
  }
}'
console.json "$complex_json"

# Formatted data display
echo ""
echo "=== Formatted Data Display ==="
console.format "%-15s %-20s %-10s %-15s" "Component" "Status" "Uptime" "Version"
console.format "%-15s %-20s %-10s %-15s" "Web Server" "Online" "15d 3h" "2.1.0"
console.format "%-15s %-20s %-10s %-15s" "Database" "Online" "30d 12h" "5.7.0"
console.format "%-15s %-20s %-10s %-15s" "Cache" "Offline" "0d 0h" "1.0.0"

echo ""
echo "=== Formatted Output Example Complete ===" 