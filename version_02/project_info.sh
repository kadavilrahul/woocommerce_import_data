#!/bin/bash

set -e  # Exit on any error

# Function to cleanup temporary files
cleanup() {
    rm -f project_structure.txt sensitive_info.txt line_counts.txt
}

# Set trap to cleanup on exit
trap cleanup EXIT

echo "Gathering project information..."

# Check if an argument is provided
if [ -z "$1" ]; then
    directory="."
else
    directory="$1"
fi

# Generate project structure
echo "Generating project structure..."
{
    echo "=== Project Structure ==="
    if command -v tree >/dev/null 2>&1; then
        # Use tree if available
        tree "$directory" -a -I '.git|node_modules|__pycache__|*.pyc|.env'
    else
        # Fallback to find
        echo "Directory structure for: $directory"
        find "$directory" -type f -not -path '*/\.*' -not -path '*/__pycache__/*' \
             -not -path '*/node_modules/*' | sort | sed 's|[^/]*/|- |g'
    fi
} > project_structure.txt

# Search for sensitive information
echo "Scanning for sensitive information..."
{
    echo "=== Sensitive Information Scan ==="
    if grep -i -r --exclude="sensitive_info.txt" --exclude="project_info.txt" \
         -E "(API_KEY|SECRET|PASSWORD|TOKEN|DATABASE_URL)" "$directory" 2>/dev/null; then
        echo ""
        echo "⚠️  WARNING: Potential sensitive information found above!"
    else
        echo "✅ No sensitive patterns found"
    fi
} > sensitive_info.txt

# Count lines of code for various file types
echo "Counting lines of code..."
{
    echo "=== Line Counts ==="
    
    # Find and count lines for each file type
    total_lines=0
    file_count=0
    
    for file in $(find "$directory" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" \
                         -o -name "*.c" -o -name "*.cpp" -o -name "*.sh" -o -name "*.go" \
                         -o -name "*.rb" -o -name "*.php" \) 2>/dev/null); do
        if [ -f "$file" ]; then
            lines=$(wc -l < "$file" 2>/dev/null || echo 0)
            echo "$lines $file"
            total_lines=$((total_lines + lines))
            file_count=$((file_count + 1))
        fi
    done
    
    echo ""
    echo "📊 Summary:"
    echo "Total files: $file_count"
    echo "Total lines: $total_lines"
    
    if [ $file_count -eq 0 ]; then
        echo "No code files found"
    fi
} > line_counts.txt

# Store project information
echo "Creating project_info.txt..."
{
    echo "=== PROJECT INFORMATION ==="
    echo "Generated on: $(date)"
    echo ""
    cat project_structure.txt
    echo ""
    cat sensitive_info.txt
    echo ""
    cat line_counts.txt
} > project_info.txt

echo "✅ Project information saved to project_info.txt"
echo "📁 Individual reports: project_structure.txt, sensitive_info.txt, line_counts.txt"