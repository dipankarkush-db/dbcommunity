# Databricks Connect Troubleshooting Guide

## Issue: [CONNECT_URL_NOT_SET] Error After Modifying .databrickscfg

### Problem Description
After adding or modifying a `cluster_id` in `.databrickscfg`, Databricks Connect stops working in VS Code, even after reverting the configuration.

### Root Causes

#### 1. **Session Cache Corruption** ⚠️ MOST COMMON
Databricks Connect caches session information. When you modify your configuration, the cached session becomes stale but doesn't automatically refresh.

**Cache Locations:**
- `~/.databricks/connect/` - Databricks Connect cache
- `/tmp/spark-*` - Temporary Spark files
- `~/.databricks/token-cache.json` - Authentication token cache

#### 2. **Environment Variable Precedence**
If `SPARK_REMOTE` is set, it overrides `.databrickscfg` settings completely.

#### 3. **VS Code Extension State**
The Databricks VS Code extension might cache connection settings internally.

#### 4. **Python Kernel Not Restarted**
Old Databricks Connect session objects remain in Python's memory.

---

## Solutions

### Quick Fix (Try This First)

1. **Clear caches:**
   ```bash
   rm -rf ~/.databricks/connect/
   rm -rf /tmp/spark-*
   unset SPARK_REMOTE
   ```

2. **Restart VS Code completely** (not just reload window)

3. **Restart Python kernel:**
   - In VS Code: Click on kernel selector → "Restart"
   - Or: Command Palette → "Python: Restart"

### Comprehensive Fix

Run the provided script:
```bash
cd /path/to/DBConnect
chmod +x fix_dbconnect.sh
source fix_dbconnect.sh
```

Then:
1. **Completely quit VS Code** (Cmd+Q on Mac, not just close window)
2. **Reopen VS Code**
3. **Select Python Interpreter:**
   - Cmd+Shift+P → "Python: Select Interpreter"
   - Choose your `.venv` environment
4. **Reconfigure Databricks:**
   - Cmd+Shift+P → "Databricks: Configure Databricks Connection"
   - Select your profile

### Manual Configuration Check

Verify your `.databrickscfg` format:

**For Serverless:**
```ini
[profile-name]
host = https://your-workspace.cloud.databricks.com/
token = dapi...
```

**For Cluster:**
```ini
[profile-name]
host = https://your-workspace.cloud.databricks.com/
token = dapi...
cluster_id = 1234-567890-abcdef12
```

**In Code:**
```python
from databricks.connect import DatabricksSession

# For serverless
spark = DatabricksSession.builder.profile("profile-name").serverless().getOrCreate()

# For cluster (with cluster_id in config)
spark = DatabricksSession.builder.profile("profile-name").getOrCreate()

# For cluster (explicit)
spark = DatabricksSession.builder.profile("profile-name").clusterId("your-cluster-id").getOrCreate()
```

---

## Debugging Steps

### 1. Check Environment Variables
```bash
echo $SPARK_REMOTE
env | grep -i spark
env | grep -i databricks
```

### 2. Verify Python Environment
```bash
which python
pip show databricks-connect
python -c "import databricks.connect; print(databricks.connect.__version__)"
```

### 3. Test Configuration
```python
from databricks.sdk import WorkspaceClient
from databricks.sdk.core import Config

config = Config(profile="your-profile-name")
print(f"Host: {config.host}")
print(f"Cluster ID: {config.cluster_id}")
```

### 4. Check VS Code Settings
- Open Settings (Cmd+,)
- Search for "databricks"
- Verify no conflicting settings

---

## Prevention Tips

1. **Always use Python virtual environments** for each project
2. **Don't mix `serverless()` and `clusterId()`** in the same builder chain
3. **Clear caches when switching profiles** frequently
4. **Restart Python kernel** after changing `.databrickscfg`
5. **Use explicit profile names** instead of DEFAULT when possible

---

## Common Errors & Fixes

### Error: "maximum retries exceeded"
**Cause:** Cluster is stopped or unreachable, or wrong SPARK_REMOTE URL

**Fix:**
1. Check if cluster is running in Databricks UI
2. Verify cluster ID is correct
3. Clear `SPARK_REMOTE` environment variable
4. Use `.getOrCreate()` instead of explicit URL

### Error: "CONNECT_URL_NOT_SET"
**Cause:** No cluster_id specified and serverless not called

**Fix:**
- Add `.serverless()` OR ensure `cluster_id` is in `.databrickscfg`
- Clear cached sessions

### Error: "No module named 'databricks'"
**Cause:** Wrong Python environment or databricks-connect not installed

**Fix:**
```bash
pip install --upgrade "databricks-connect==15.4.*"
```

---

## Still Not Working?

1. **Complete cleanup:**
   ```bash
   # Remove all Databricks state
   rm -rf ~/.databricks/
   rm -rf /tmp/spark-*
   
   # Reinstall databricks-connect
   pip uninstall databricks-connect
   pip install --upgrade "databricks-connect==15.4.*"
   
   # Recreate .databrickscfg
   ```

2. **Check VS Code Extension:**
   - Uninstall Databricks extension
   - Reload VS Code
   - Reinstall extension
   - Reconfigure connection

3. **Use terminal instead:**
   ```bash
   # Bypass VS Code completely to test
   source .venv/bin/activate
   python your_script.py
   ```

---

## Need More Help?

- [Databricks Connect Documentation](https://docs.databricks.com/dev-tools/databricks-connect.html)
- [VS Code Extension Documentation](https://docs.databricks.com/dev-tools/vscode-ext.html)
- Community: https://community.databricks.com/

