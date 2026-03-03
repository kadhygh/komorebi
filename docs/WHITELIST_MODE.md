# Whitelist Mode Configuration

## Overview

Whitelist mode is a feature that allows you to control which windows komorebi manages. When enabled, **only windows that match the rules in `manage_rules` will be managed** by komorebi. All other windows will be ignored.

## Default Behavior vs Whitelist Mode

### Default Behavior (whitelist_mode: false or not set)
- Komorebi manages all windows that meet the standard criteria (have title bar, window border, etc.)
- Windows in `ignore_rules` are excluded
- Windows in `manage_rules` are force-managed even if they're in `ignore_rules`

### Whitelist Mode (whitelist_mode: true)
- **Only** windows in `manage_rules` are managed
- All other windows are ignored, regardless of their properties
- `ignore_rules` has no effect in this mode

## Configuration

### Enable Whitelist Mode in komorebi.json

```json
{
  "whitelist_mode": true,
  "manage_rules": [
    {
      "kind": "exe",
      "id": "notepad.exe",
      "matching_strategy": "equals"
    },
    {
      "kind": "title",
      "id": "Visual Studio Code",
      "matching_strategy": "contains"
    }
  ]
}
```

### Matching Strategies

- `"equals"`: Exact match (case-sensitive)
- `"contains"`: Substring match
- `"regex"`: Regular expression match

### Matching Kinds

- `"exe"`: Match by executable name (e.g., "notepad.exe")
- `"title"`: Match by window title
- `"class"`: Match by window class
- `"path"`: Match by full executable path

## Runtime Control

You can enable or disable whitelist mode at runtime using the CLI:

```bash
# Enable whitelist mode
komorebic whitelist-mode true

# Disable whitelist mode
komorebic whitelist-mode false

# Check current status
komorebic state | grep whitelist_mode
```

## Adding Windows to Whitelist

### Via Configuration File

Edit your `komorebi.json` and add rules to `manage_rules`:

```json
{
  "manage_rules": [
    {
      "kind": "exe",
      "id": "your-app.exe",
      "matching_strategy": "equals"
    }
  ]
}
```

Then reload the configuration:

```bash
komorebic reload-configuration
```

### Via CLI (Runtime)

```bash
# Add by executable name
komorebic manage-rule exe notepad.exe

# Add by window title
komorebic manage-rule title "My Application"

# Add by window class
komorebic manage-rule class "MyAppClass"
```

## Example Use Cases

### 1. Minimal Setup - Only Manage Essential Apps

```json
{
  "whitelist_mode": true,
  "manage_rules": [
    {"kind": "exe", "id": "Code.exe", "matching_strategy": "equals"},
    {"kind": "exe", "id": "chrome.exe", "matching_strategy": "equals"},
    {"kind": "exe", "id": "WindowsTerminal.exe", "matching_strategy": "equals"}
  ]
}
```

### 2. Development Environment

```json
{
  "whitelist_mode": true,
  "manage_rules": [
    {"kind": "title", "id": "Visual Studio", "matching_strategy": "contains"},
    {"kind": "exe", "id": "Code.exe", "matching_strategy": "equals"},
    {"kind": "exe", "id": "WindowsTerminal.exe", "matching_strategy": "equals"},
    {"kind": "exe", "id": "chrome.exe", "matching_strategy": "equals"},
    {"kind": "exe", "id": "firefox.exe", "matching_strategy": "equals"}
  ]
}
```

### 3. Work Setup - Specific Applications Only

```json
{
  "whitelist_mode": true,
  "manage_rules": [
    {"kind": "exe", "id": "OUTLOOK.EXE", "matching_strategy": "equals"},
    {"kind": "exe", "id": "EXCEL.EXE", "matching_strategy": "equals"},
    {"kind": "exe", "id": "WINWORD.EXE", "matching_strategy": "equals"},
    {"kind": "exe", "id": "chrome.exe", "matching_strategy": "equals"}
  ]
}
```

## Testing Your Configuration

1. **Start with whitelist mode disabled** to see which windows komorebi would normally manage:
   ```bash
   komorebic state
   ```

2. **Enable whitelist mode** and add a single test application:
   ```bash
   komorebic whitelist-mode true
   komorebic manage-rule exe notepad.exe
   ```

3. **Open the test application** (e.g., Notepad) and verify it's managed

4. **Open other applications** and verify they're NOT managed

5. **Check the logs** for debugging:
   ```bash
   # Logs are typically in %LOCALAPPDATA%\komorebi\
   ```

## Troubleshooting

### Windows Not Being Managed

1. **Check if whitelist mode is enabled**:
   ```bash
   komorebic state | grep whitelist_mode
   ```

2. **Verify your manage_rules**:
   ```bash
   komorebic state | grep manage_rules
   ```

3. **Check the exact executable name**:
   - Open Task Manager
   - Find your application
   - Note the exact executable name (case-sensitive)

4. **Use debug window command**:
   ```bash
   # Get the window handle (HWND) from komorebic visible-windows
   komorebic debug-window <HWND>
   ```

### All Windows Being Managed (Whitelist Not Working)

1. **Verify whitelist mode is actually enabled**:
   ```bash
   komorebic state | grep whitelist_mode
   # Should show: "whitelist_mode": true
   ```

2. **Reload configuration**:
   ```bash
   komorebic reload-configuration
   ```

3. **Restart komorebi**:
   ```bash
   komorebic stop
   komorebic start
   ```

## Performance Considerations

Whitelist mode can improve performance in scenarios where:
- You have many windows open but only want to manage a few
- You want to reduce CPU usage from window event processing
- You have applications that conflict with tiling behavior

## Migration from Default Mode

If you're switching from default mode to whitelist mode:

1. **Document your current setup**: Run `komorebic state` and save the output
2. **Identify managed windows**: Note which windows you actually want managed
3. **Create manage_rules**: Add rules for each window type
4. **Test incrementally**: Add rules one at a time and test
5. **Enable whitelist mode**: Once all rules are added, enable the mode

## See Also

- [komorebi.whitelist.example.json](./komorebi.whitelist.example.json) - Complete example configuration
- [komorebi.example.json](./komorebi.example.json) - Standard configuration example
- [applications.json](../komorebic/applications.json) - Application-specific configurations
