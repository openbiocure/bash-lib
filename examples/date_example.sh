#!/bin/bash

# Example: Date Module
# This demonstrates the date and time operations functionality

# Import bash-lib
source core/init.sh
import date
import console

echo "=== Date Module Example ==="

echo ""
echo "=== Current Date and Time ==="

# Get current date
console.info "Current date operations..."
current_date=$(date.current)
console.info "Current date: $current_date"

# Get current time
current_time=$(date.currentTime)
console.info "Current time: $current_time"

# Get current timestamp
current_timestamp=$(date.timestamp)
console.info "Current timestamp: $current_timestamp"

# Get current date in different formats
console.info "Current date in different formats..."
iso_date=$(date.iso)
console.info "ISO format: $iso_date"

rfc_date=$(date.rfc)
console.info "RFC format: $rfc_date"

unix_date=$(date.unix)
console.info "Unix timestamp: $unix_date"

echo ""
echo "=== Date Formatting ==="

# Format current date
console.info "Date formatting operations..."
formatted=$(date.format "%Y-%m-%d %H:%M:%S")
console.info "Formatted date: $formatted"

custom_format=$(date.format "%A, %B %d, %Y")
console.info "Custom format: $custom_format"

short_format=$(date.format "%m/%d/%y")
console.info "Short format: $short_format"

time_format=$(date.format "%H:%M:%S")
console.info "Time format: $time_format"

echo ""
echo "=== Date Parsing ==="

# Parse date strings
console.info "Date parsing operations..."
date_string="2023-12-25"
parsed=$(date.parse "$date_string")
console.info "Parsed '$date_string': $parsed"

date_string="25/12/2023"
parsed=$(date.parse "$date_string" "%d/%m/%Y")
console.info "Parsed '$date_string': $parsed"

date_string="December 25, 2023"
parsed=$(date.parse "$date_string" "%B %d, %Y")
console.info "Parsed '$date_string': $parsed"

echo ""
echo "=== Date Arithmetic ==="

# Add days to date
console.info "Date arithmetic operations..."
base_date="2023-12-25"
future_date=$(date.addDays "$base_date" 7)
console.info "7 days after $base_date: $future_date"

past_date=$(date.addDays "$base_date" -7)
console.info "7 days before $base_date: $past_date"

# Add months to date
future_month=$(date.addMonths "$base_date" 3)
console.info "3 months after $base_date: $future_month"

past_month=$(date.addMonths "$base_date" -3)
console.info "3 months before $base_date: $past_month"

# Add years to date
future_year=$(date.addYears "$base_date" 1)
console.info "1 year after $base_date: $future_year"

past_year=$(date.addYears "$base_date" -1)
console.info "1 year before $base_date: $past_year"

# Add hours to date
base_datetime="2023-12-25 12:00:00"
future_hour=$(date.addHours "$base_datetime" 6)
console.info "6 hours after $base_datetime: $future_hour"

past_hour=$(date.addHours "$base_datetime" -6)
console.info "6 hours before $base_datetime: $past_hour"

# Add minutes to date
future_minute=$(date.addMinutes "$base_datetime" 30)
console.info "30 minutes after $base_datetime: $future_minute"

past_minute=$(date.addMinutes "$base_datetime" -30)
console.info "30 minutes before $base_datetime: $past_minute"

echo ""
echo "=== Date Comparison ==="

# Compare dates
console.info "Date comparison operations..."
date1="2023-12-25"
date2="2023-12-26"

if date.isAfter "$date2" "$date1"; then
    console.success "$date2 is after $date1"
else
    console.error "$date2 is not after $date1"
fi

if date.isBefore "$date1" "$date2"; then
    console.success "$date1 is before $date2"
else
    console.error "$date1 is not before $date2"
fi

if date.isEqual "$date1" "$date1"; then
    console.success "$date1 equals $date1"
else
    console.error "$date1 does not equal $date1"
fi

# Calculate date difference
console.info "Date difference calculations..."
diff_days=$(date.diffDays "$date1" "$date2")
console.info "Days between $date1 and $date2: $diff_days"

diff_hours=$(date.diffHours "$date1 00:00:00" "$date2 12:00:00")
console.info "Hours between dates: $diff_hours"

diff_minutes=$(date.diffMinutes "$date1 00:00:00" "$date2 00:30:00")
console.info "Minutes between dates: $diff_minutes"

echo ""
echo "=== Date Validation ==="

# Validate date formats
console.info "Date validation operations..."
valid_date="2023-12-25"
if date.isValid "$valid_date"; then
    console.success "'$valid_date' is a valid date"
else
    console.error "'$valid_date' is not a valid date"
fi

invalid_date="2023-13-45"
if date.isValid "$invalid_date"; then
    console.error "'$invalid_date' is valid (unexpected)"
else
    console.success "'$invalid_date' is not a valid date"
fi

# Check if date is in range
start_date="2023-12-01"
end_date="2023-12-31"
test_date="2023-12-15"

if date.isInRange "$test_date" "$start_date" "$end_date"; then
    console.success "$test_date is in range $start_date to $end_date"
else
    console.error "$test_date is not in range $start_date to $end_date"
fi

echo ""
echo "=== Date Information ==="

# Get date components
console.info "Date component extraction..."
test_date="2023-12-25 14:30:45"

year=$(date.getYear "$test_date")
console.info "Year: $year"

month=$(date.getMonth "$test_date")
console.info "Month: $month"

day=$(date.getDay "$test_date")
console.info "Day: $day"

hour=$(date.getHour "$test_date")
console.info "Hour: $hour"

minute=$(date.getMinute "$test_date")
console.info "Minute: $minute"

second=$(date.getSecond "$test_date")
console.info "Second: $second"

# Get day of week
day_of_week=$(date.getDayOfWeek "$test_date")
console.info "Day of week: $day_of_week"

day_name=$(date.getDayName "$test_date")
console.info "Day name: $day_name"

month_name=$(date.getMonthName "$test_date")
console.info "Month name: $month_name"

# Get week number
week_number=$(date.getWeekNumber "$test_date")
console.info "Week number: $week_number"

# Get quarter
quarter=$(date.getQuarter "$test_date")
console.info "Quarter: $quarter"

echo ""
echo "=== Date Ranges and Periods ==="

# Get date range
console.info "Date range operations..."
start_date="2023-12-01"
end_date="2023-12-31"
range=$(date.getRange "$start_date" "$end_date")
console.info "Date range: $range"

# Get week range
week_range=$(date.getWeekRange "$test_date")
console.info "Week range for $test_date: $week_range"

# Get month range
month_range=$(date.getMonthRange "$test_date")
console.info "Month range for $test_date: $month_range"

# Get quarter range
quarter_range=$(date.getQuarterRange "$test_date")
console.info "Quarter range for $test_date: $quarter_range"

# Get year range
year_range=$(date.getYearRange "$test_date")
console.info "Year range for $test_date: $year_range"

echo ""
echo "=== Date Utilities ==="

# Get first day of month
console.info "Date utility operations..."
first_day=$(date.getFirstDayOfMonth "$test_date")
console.info "First day of month: $first_day"

# Get last day of month
last_day=$(date.getLastDayOfMonth "$test_date")
console.info "Last day of month: $last_day"

# Get first day of year
first_day_year=$(date.getFirstDayOfYear "$test_date")
console.info "First day of year: $first_day_year"

# Get last day of year
last_day_year=$(date.getLastDayOfYear "$test_date")
console.info "Last day of year: $last_day_year"

# Check if date is weekend
if date.isWeekend "$test_date"; then
    console.info "$test_date is a weekend"
else
    console.info "$test_date is a weekday"
fi

# Check if date is holiday (simplified)
if date.isHoliday "$test_date"; then
    console.info "$test_date is a holiday"
else
    console.info "$test_date is not a holiday"
fi

echo ""
echo "=== Time Zone Operations ==="

# Get current timezone
console.info "Timezone operations..."
current_tz=$(date.getTimezone)
console.info "Current timezone: $current_tz"

# Convert timezone
utc_time=$(date.toUTC "$test_date")
console.info "UTC time: $utc_time"

local_time=$(date.toLocal "$utc_time")
console.info "Local time: $local_time"

# List available timezones
console.info "Available timezones (first 5):"
date.listTimezones | head -5

echo ""
echo "=== Date Formatting Examples ==="

# Various date formats
console.info "Various date format examples..."
console.info "ISO 8601: $(date.format "%Y-%m-%dT%H:%M:%SZ")"
console.info "RFC 2822: $(date.format "%a, %d %b %Y %H:%M:%S %z")"
console.info "US format: $(date.format "%m/%d/%Y")"
console.info "European format: $(date.format "%d/%m/%Y")"
console.info "Full date: $(date.format "%A, %B %d, %Y")"
console.info "Short date: $(date.format "%b %d, %Y")"
console.info "Time only: $(date.format "%H:%M:%S")"
console.info "12-hour time: $(date.format "%I:%M:%S %p")"

echo ""
echo "=== Date Module Example Complete ===" 