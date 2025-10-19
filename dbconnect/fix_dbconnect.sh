#!/bin/bash

echo "🔧 Fixing Databricks Connect Issues..."

# Step 1: Unset SPARK_REMOTE if set
echo "1. Unsetting SPARK_REMOTE environment variable..."
unset SPARK_REMOTE
echo "   ✓ Done"

# Step 2: Clear Databricks Connect cache
echo "2. Clearing Databricks Connect cache..."
rm -rf ~/.databricks/connect/ 2>/dev/null && echo "   ✓ Removed connect cache" || echo "   ℹ No connect cache found"
rm -rf /tmp/spark-* 2>/dev/null && echo "   ✓ Removed temp Spark files" || echo "   ℹ No temp files found"

# Step 3: Clear token cache (optional - only if you want to re-authenticate)
echo "3. Clearing token cache..."
# Uncomment the line below if you want to clear auth tokens:
# rm ~/.databricks/token-cache.json 2>/dev/null && echo "   ✓ Removed token cache" || echo "   ℹ No token cache found"
echo "   ℹ Skipped (uncomment in script if needed)"

# Step 4: Verify .databrickscfg
echo "4. Checking .databrickscfg..."
if [ -f ~/.databrickscfg ]; then
    echo "   ✓ Found .databrickscfg"
else
    echo "   ❌ .databrickscfg not found!"
fi

# Step 5: Check if databricks-connect is installed
echo "5. Checking databricks-connect installation..."
if python -c "import databricks.connect" 2>/dev/null; then
    echo "   ✓ databricks-connect is installed"
    python -c "import databricks.connect; print(f'   Version: {databricks.connect.__version__}')" 2>/dev/null || echo "   Version: unknown"
else
    echo "   ❌ databricks-connect not found in current Python environment"
fi

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Next steps:"
echo "1. Restart VS Code completely"
echo "2. Reload the Python interpreter (Cmd+Shift+P -> 'Python: Select Interpreter')"
echo "3. Try running your code again"

