#!/bin/bash

# Example: String Module
# This demonstrates the string manipulation functionality

# Import bash-lib
source core/init.sh
import string
import console

echo "=== String Module Example ==="

echo ""
echo "=== Basic String Operations ==="

# String length
console.info "String length operations..."
text="Hello World"
length=$(string.length "$text")
console.info "Length of '$text': $length"

# String concatenation
console.info "String concatenation..."
str1="Hello"
str2="World"
result=$(string.concat "$str1" "$str2")
console.info "Concatenated: '$result'"

# String concatenation with separator
result=$(string.concatWithSeparator "$str1" "$str2" " ")
console.info "Concatenated with space: '$result'"

# String repetition
console.info "String repetition..."
result=$(string.repeat "abc" 3)
console.info "Repeated 'abc' 3 times: '$result'"

echo ""
echo "=== String Case Operations ==="

# Convert to uppercase
console.info "Case conversion operations..."
text="hello world"
result=$(string.toUpper "$text")
console.info "Uppercase: '$result'"

# Convert to lowercase
text="HELLO WORLD"
result=$(string.toLower "$text")
console.info "Lowercase: '$result'"

# Capitalize first letter
text="hello world"
result=$(string.capitalize "$text")
console.info "Capitalized: '$result'"

# Title case
text="hello world example"
result=$(string.titleCase "$text")
console.info "Title case: '$result'"

# Camel case
text="hello world example"
result=$(string.camelCase "$text")
console.info "Camel case: '$result'"

# Snake case
text="Hello World Example"
result=$(string.snakeCase "$text")
console.info "Snake case: '$result'"

# Kebab case
text="Hello World Example"
result=$(string.kebabCase "$text")
console.info "Kebab case: '$result'"

echo ""
echo "=== String Trimming and Padding ==="

# Trim whitespace
console.info "Trimming operations..."
text="  hello world  "
result=$(string.trim "$text")
console.info "Trimmed: '$result'"

# Trim left
result=$(string.trimLeft "$text")
console.info "Left trimmed: '$result'"

# Trim right
result=$(string.trimRight "$text")
console.info "Right trimmed: '$result'"

# Pad left
console.info "Padding operations..."
text="hello"
result=$(string.padLeft "$text" 10)
console.info "Left padded to 10: '$result'"

# Pad right
result=$(string.padRight "$text" 10)
console.info "Right padded to 10: '$result'"

# Pad center
result=$(string.padCenter "$text" 10)
console.info "Center padded to 10: '$result'"

# Pad with custom character
result=$(string.padLeft "$text" 10 "*")
console.info "Left padded with *: '$result'"

echo ""
echo "=== String Search and Replace ==="

# Find substring
console.info "Substring search operations..."
text="Hello World Example"
if string.contains "$text" "World"; then
    console.success "Found 'World' in '$text'"
else
    console.error "Did not find 'World' in '$text'"
fi

# Find substring position
position=$(string.indexOf "$text" "World")
console.info "Position of 'World': $position"

# Find last occurrence
text="hello world hello"
position=$(string.lastIndexOf "$text" "hello")
console.info "Last position of 'hello': $position"

# Replace substring
console.info "Replace operations..."
text="Hello World"
result=$(string.replace "$text" "World" "Bash")
console.info "Replaced: '$result'"

# Replace all occurrences
text="hello hello hello"
result=$(string.replaceAll "$text" "hello" "hi")
console.info "Replaced all: '$result'"

# Replace with regex
text="Hello123World456"
result=$(string.replaceRegex "$text" "[0-9]+" "NUM")
console.info "Regex replaced: '$result'"

echo ""
echo "=== String Splitting and Joining ==="

# Split string
console.info "String splitting operations..."
text="apple,banana,orange,grape"
result=$(string.split "$text" ",")
console.info "Split by comma: $result"

# Split with multiple delimiters
text="apple;banana,orange:grape"
result=$(string.splitMultiple "$text" ";" "," ":")
console.info "Split by multiple delimiters: $result"

# Join strings
console.info "String joining operations..."
array=("apple" "banana" "orange" "grape")
result=$(string.join "${array[@]}" ",")
console.info "Joined with comma: '$result'"

# Join with custom separator
result=$(string.join "${array[@]}" " - ")
console.info "Joined with custom separator: '$result'"

echo ""
echo "=== String Validation ==="

# Check if string is empty
console.info "String validation operations..."
text=""
if string.isEmpty "$text"; then
    console.success "String is empty"
else
    console.error "String is not empty"
fi

text="hello"
if string.isEmpty "$text"; then
    console.error "String is empty (unexpected)"
else
    console.success "String is not empty"
fi

# Check if string is numeric
text="123"
if string.isNumeric "$text"; then
    console.success "'$text' is numeric"
else
    console.error "'$text' is not numeric"
fi

text="123abc"
if string.isNumeric "$text"; then
    console.error "'$text' is numeric (unexpected)"
else
    console.success "'$text' is not numeric"
fi

# Check if string is alphabetic
text="Hello"
if string.isAlpha "$text"; then
    console.success "'$text' is alphabetic"
else
    console.error "'$text' is not alphabetic"
fi

text="Hello123"
if string.isAlpha "$text"; then
    console.error "'$text' is alphabetic (unexpected)"
else
    console.success "'$text' is not alphabetic"
fi

# Check if string is alphanumeric
text="Hello123"
if string.isAlphanumeric "$text"; then
    console.success "'$text' is alphanumeric"
else
    console.error "'$text' is not alphanumeric"
fi

text="Hello 123"
if string.isAlphanumeric "$text"; then
    console.error "'$text' is alphanumeric (unexpected)"
else
    console.success "'$text' is not alphanumeric"
fi

# Check if string starts with
text="Hello World"
if string.startsWith "$text" "Hello"; then
    console.success "'$text' starts with 'Hello'"
else
    console.error "'$text' does not start with 'Hello'"
fi

# Check if string ends with
if string.endsWith "$text" "World"; then
    console.success "'$text' ends with 'World'"
else
    console.error "'$text' does not end with 'World'"
fi

echo ""
echo "=== String Transformation ==="

# Reverse string
console.info "String transformation operations..."
text="Hello"
result=$(string.reverse "$text")
console.info "Reversed '$text': '$result'"

# Rotate string
result=$(string.rotate "$text" 2)
console.info "Rotated '$text' by 2: '$result'"

# Shuffle string
result=$(string.shuffle "$text")
console.info "Shuffled '$text': '$result'"

# Generate random string
console.info "Random string generation..."
result=$(string.random 10)
console.info "Random string (10 chars): '$result'"

result=$(string.randomAlpha 8)
console.info "Random alphabetic string (8 chars): '$result'"

result=$(string.randomNumeric 6)
console.info "Random numeric string (6 chars): '$result'"

result=$(string.randomAlphanumeric 12)
console.info "Random alphanumeric string (12 chars): '$result'"

echo ""
echo "=== String Encoding and Decoding ==="

# Base64 encoding
console.info "Encoding operations..."
text="Hello World"
encoded=$(string.base64Encode "$text")
console.info "Base64 encoded: '$encoded'"

# Base64 decoding
decoded=$(string.base64Decode "$encoded")
console.info "Base64 decoded: '$decoded'"

# URL encoding
text="Hello World!"
encoded=$(string.urlEncode "$text")
console.info "URL encoded: '$encoded'"

# URL decoding
decoded=$(string.urlDecode "$encoded")
console.info "URL decoded: '$decoded'"

# HTML encoding
text="<script>alert('Hello')</script>"
encoded=$(string.htmlEncode "$text")
console.info "HTML encoded: '$encoded'"

# HTML decoding
decoded=$(string.htmlDecode "$encoded")
console.info "HTML decoded: '$decoded'"

echo ""
echo "=== String Formatting ==="

# Format string with placeholders
console.info "String formatting operations..."
template="Hello {name}, you are {age} years old"
result=$(string.format "$template" "name:John" "age:30")
console.info "Formatted: '$result'"

# Format with printf-style
result=$(string.printf "Hello %s, you are %d years old" "John" 30)
console.info "Printf formatted: '$result'"

# Format currency
amount=1234.56
result=$(string.formatCurrency "$amount" "USD")
console.info "Currency formatted: '$result'"

# Format number
number=1234567.89
result=$(string.formatNumber "$number" 2)
console.info "Number formatted: '$result'"

# Format percentage
percentage=0.1234
result=$(string.formatPercentage "$percentage" 2)
console.info "Percentage formatted: '$result'"

echo ""
echo "=== String Comparison ==="

# Case-insensitive comparison
console.info "String comparison operations..."
str1="Hello"
str2="hello"
if string.equalsIgnoreCase "$str1" "$str2"; then
    console.success "'$str1' equals '$str2' (case-insensitive)"
else
    console.error "'$str1' does not equal '$str2' (case-insensitive)"
fi

# Compare strings
if string.compare "$str1" "$str2"; then
    console.success "'$str1' equals '$str2'"
else
    console.success "'$str1' does not equal '$str2'"
fi

# Natural sort comparison
str1="file2.txt"
str2="file10.txt"
if string.naturalCompare "$str1" "$str2"; then
    console.success "'$str1' comes before '$str2' in natural sort"
else
    console.success "'$str2' comes before '$str1' in natural sort"
fi

echo ""
echo "=== String Extraction ==="

# Extract substring
console.info "String extraction operations..."
text="Hello World Example"
result=$(string.substring "$text" 6 5)
console.info "Substring from position 6, length 5: '$result'"

# Extract before delimiter
result=$(string.extractBefore "$text" "World")
console.info "Extract before 'World': '$result'"

# Extract after delimiter
result=$(string.extractAfter "$text" "World")
console.info "Extract after 'World': '$result'"

# Extract between delimiters
text="<tag>content</tag>"
result=$(string.extractBetween "$text" "<tag>" "</tag>")
console.info "Extract between tags: '$result'"

# Extract words
text="Hello World Example"
result=$(string.extractWords "$text")
console.info "Extract words: $result"

# Extract numbers
text="Hello123World456"
result=$(string.extractNumbers "$text")
console.info "Extract numbers: '$result'"

echo ""
echo "=== String Module Example Complete ===" 