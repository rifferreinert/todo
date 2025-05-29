#!/bin/bash
# SwiftLint utility script for Focus To-Do project

echo "🔍 Running SwiftLint on Focus To-Do project..."
echo "=============================================="

# Run SwiftLint and capture output
swiftlint_output=$(swiftlint 2>&1)
exit_code=$?

# Display results
if [ $exit_code -eq 0 ]; then
    echo "✅ SwiftLint passed! No violations found."
    echo "$swiftlint_output"
else
    echo "⚠️  SwiftLint found violations:"
    echo "$swiftlint_output"
    echo ""
    echo "💡 To auto-fix some violations, run:"
    echo "   swiftlint --fix"
    echo ""
    echo "📖 For help with specific rules, visit:"
    echo "   https://realm.github.io/SwiftLint/rule-directory.html"
fi

echo ""
echo "🛠  Manual commands:"
echo "   swiftlint                    # Check all files"
echo "   swiftlint --fix              # Auto-fix violations"
echo "   swiftlint --quiet            # Show only violations"
echo "   swiftlint Todo/              # Check only main target"

exit $exit_code
