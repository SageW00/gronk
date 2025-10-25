# Building Standalone Windows EXE Guide

This guide shows you how to build a complete standalone Windows EXE for the Aerospace RAG GUI application.

## What You'll Get

After following this guide, you'll have:
- ✅ **Aerospace RAG Assistant.exe** - Standalone GUI application with icon
- ✅ **Desktop Shortcut** - One-click launcher from your desktop
- ✅ **No Console Window** - Professional windowed application
- ✅ **Portable** - Copy to any Windows computer and run

---

## Quick Build (2 Commands)

```cmd
REM 1. Run setup (if you haven't already)
setup_windows.bat

REM 2. Build the EXE
build_executables.bat
```

That's it! The EXE will be in the `dist\` folder.

---

## Detailed Build Process

### Step 1: Prerequisites

Make sure you have:
- ✅ Python 3.8+ installed
- ✅ Virtual environment set up (`setup_windows.bat` does this)
- ✅ All dependencies installed

### Step 2: Run the Build Script

```cmd
build_executables.bat
```

**What it does:**
1. ✅ Activates virtual environment
2. ✅ Installs PyInstaller and Pillow (if needed)
3. ✅ **Creates application icon** (aerospace_rag_icon.ico)
4. ✅ Builds CLI executable
5. ✅ **Builds GUI executable** (Aerospace RAG Assistant.exe)
6. ✅ Copies config files
7. ✅ Creates desktop shortcut helper

**Build time:** ~2-5 minutes

### Step 3: Create Desktop Shortcut

After building:
1. Go to `dist\` folder
2. Double-click **`Create_Desktop_Shortcut.bat`**
3. Desktop icon appears!

### Step 4: Launch the App

Double-click the desktop icon or run:
```
dist\Aerospace RAG Assistant.exe
```

---

## What's Created

### Files in `dist\` Folder

```
dist/
├── Aerospace RAG Assistant.exe  ← Main GUI application (standalone!)
├── AerospaceRAG-CLI.exe         ← Command-line version
├── Create_Desktop_Shortcut.bat  ← Desktop icon creator
├── README.txt                    ← Quick start instructions
├── config/
│   └── config.yaml              ← Configuration
└── data/                         ← Place PDFs here
    ├── coursenotes/
    └── textbook/
```

### Icon File

- **aerospace_rag_icon.ico** - Professional app icon
- **aerospace_rag_icon.png** - PNG preview

The icon features:
- Dark blue circular background
- Red "A" symbol for Aerospace
- Professional, modern design

---

## Application Features

### The Standalone EXE:

✅ **No Console Window**
- Pure GUI application
- Professional appearance
- Starts directly to interface

✅ **Has Icon**
- Shows in taskbar
- Shows on desktop
- Professional branding

✅ **Version Information**
- Product Name: Aerospace RAG Assistant
- Version: 1.0.0.0
- Description: AI-Powered Aerospace Learning Assistant

✅ **No Admin Required**
- Runs as normal user
- No UAC prompts

---

## Customizing the Build

### Change the Icon

**Option 1: Use Your Own Icon**
1. Create or download an `.ico` file
2. Name it `aerospace_rag_icon.ico`
3. Place in project root
4. Run `build_executables.bat`

**Option 2: Modify the Generated Icon**
1. Edit `aerospace_rag/utils/create_icon.py`
2. Change colors, shapes, text
3. Run `python aerospace_rag/utils/create_icon.py`

### Change Application Name

Edit `aerospace_rag_gui.spec`:
```python
name='Your Custom Name Here',  # Line 70
```

### Add More Files to EXE

Edit `aerospace_rag_gui.spec`:
```python
datas=[
    ('config/config.yaml', 'config'),
    ('aerospace_rag', 'aerospace_rag'),
    ('your_file.txt', '.'),  # Add this
],
```

---

## Troubleshooting

### Problem: "PyInstaller not found"

**Solution:**
```cmd
pip install pyinstaller
```

### Problem: "Icon file not found"

**Solution:**
```cmd
pip install pillow
python aerospace_rag/utils/create_icon.py
```

### Problem: "Build fails with import errors"

**Solution:**
Check `aerospace_rag_gui.spec` - add missing modules to `hiddenimports`:
```python
hiddenimports=[
    'your_missing_module',
    ...
],
```

### Problem: "EXE is too large"

**Current size:** ~150-250 MB (includes Python + all libraries)

**To reduce size:**
1. Use UPX compression (already enabled)
2. Remove unused dependencies from requirements.txt
3. Use `--exclude-module` for large unused libraries

### Problem: "Antivirus flags the EXE"

This is normal for PyInstaller EXEs. Solutions:
1. Add exception in antivirus
2. Sign the EXE with a code signing certificate
3. Build on the target machine (reduces false positives)

### Problem: "Missing DLLs when running on another PC"

**Solution:**
Install Visual C++ Redistributable:
https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist

---

## Distribution

### Sharing the Application

**Option 1: Share the `dist\` folder**
1. Zip the entire `dist\` folder
2. Send to users
3. They unzip and run `Aerospace RAG Assistant.exe`

**Option 2: Create an installer**
Use a tool like Inno Setup or NSIS to create a professional installer.

**Option 3: Share just the EXE**
⚠️ Note: Users need to create their own `config\` and `data\` folders

### System Requirements

**On target machine, users need:**
- ✅ Windows 10/11 (64-bit)
- ✅ PostgreSQL 16/18 running on port 5432
- ✅ Ollama with both models:
  - gemma3:1b (text generation)
  - embeddinggemma (embeddings)

**They DON'T need:**
- ❌ Python installed
- ❌ Virtual environment
- ❌ Any packages installed

---

## Advanced: One-File Build

By default, PyInstaller creates a one-file EXE (everything bundled).

**To create a folder distribution instead:**

Edit `aerospace_rag_gui.spec`, change:
```python
exe = EXE(
    pyz,
    a.scripts,
    [],  # Remove these
    exclude_binaries=True,  # Add this
    ...
)

# Then add
coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='Aerospace RAG Assistant',
)
```

This creates a folder with multiple files (smaller startup time).

---

## Testing the EXE

### Before Distribution

Test on a clean Windows VM:
1. ✅ Install PostgreSQL 16/18
2. ✅ Install Ollama + models
3. ✅ Copy `dist\` folder
4. ✅ Run `Aerospace RAG Assistant.exe`
5. ✅ Test all features

### Known Issues

**Issue: First startup is slow**
- Normal! EXE unpacks to temp folder on first run
- Subsequent runs are faster

**Issue: Windows Defender warning**
- Click "More info" → "Run anyway"
- Or add folder to exclusions

---

## Build Variants

### Debug Build

For troubleshooting, create a debug build:

Edit `aerospace_rag_gui.spec`:
```python
console=True,  # Shows console for debugging
debug=True,    # Enables debug output
```

### Optimized Build

For smallest size:

Edit `aerospace_rag_gui.spec`:
```python
upx=True,        # Compress (already enabled)
upx_exclude=[],  # Compress all files
```

---

## Automated Build

### Create a Build Script

`auto_build.bat`:
```cmd
@echo off
call venv\Scripts\activate
python aerospace_rag/utils/create_icon.py
pyinstaller --clean --noconfirm aerospace_rag_gui.spec
echo Build complete!
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build Windows EXE

on: [push]

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: '3.10'
      - run: pip install -r requirements.txt
      - run: python aerospace_rag/utils/create_icon.py
      - run: pyinstaller --clean --noconfirm aerospace_rag_gui.spec
      - uses: actions/upload-artifact@v2
        with:
          name: aerospace-rag-exe
          path: dist/
```

---

## FAQ

### Q: Can I build on Linux/Mac?

**A:** PyInstaller creates platform-specific binaries. You need Windows to build Windows EXEs.

Use a Windows VM or GitHub Actions with `runs-on: windows-latest`.

### Q: How do I update the EXE?

**A:** Re-run `build_executables.bat` after making code changes.

### Q: Can I rename the EXE?

**A:** Yes! Either:
1. Edit `aerospace_rag_gui.spec` (name='YourName')
2. Or just rename the .exe file after building

### Q: Why is the EXE so large?

**A:** It includes Python + all libraries. This is normal for PyInstaller.

### Q: Do I need to rebuild for each user?

**A:** No! Build once, distribute to all Windows users.

### Q: Can users run this without internet?

**A:** Yes! All models run locally via Ollama. No internet needed after setup.

---

## Support

**Having issues?**
1. Check [OLLAMA_SETUP_GUIDE.md](OLLAMA_SETUP_GUIDE.md)
2. Run `diagnose_ollama.bat`
3. Check [FIX_VECTOR_DIMENSIONS.md](FIX_VECTOR_DIMENSIONS.md)

**Build-specific issues?**
- Ensure Python 3.8+
- Ensure all dependencies installed
- Try deleting `build\` and `dist\` folders, rebuild

---

## Success Checklist

After building, verify:
- [ ] `dist\Aerospace RAG Assistant.exe` exists
- [ ] Icon shows on EXE file
- [ ] Double-clicking launches GUI (no console)
- [ ] Application window has title and icon
- [ ] Desktop shortcut works
- [ ] Can query the system successfully

✅ If all checked, you're ready to distribute!

---

**Last Updated:** After adding icon, desktop shortcut, and improved spec file
**Build Status:** ✅ Production Ready
