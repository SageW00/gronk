# Aerospace RAG - Windows 11 Setup Guide

Complete guide for building and running the Aerospace RAG application on Windows 11.

## Prerequisites

### 1. Install Python 3.8+

Download from: https://www.python.org/downloads/

**IMPORTANT**: During installation, check **"Add Python to PATH"**

Verify installation:
```cmd
python --version
```

### 2. Install PostgreSQL 16/18

Download from: https://www.postgresql.org/download/windows/

During installation:
- Set port: **5432** (default port, or use any available port)
- Set password for postgres user: **1234**
- Remember to install Stack Builder for additional tools

After installation, create the database:
```cmd
psql -U postgres -p 5432
CREATE DATABASE AEROSPACE;
CREATE EXTENSION vector;
\q
```

**Install pgvector extension**:

The pgvector extension is required for vector similarity search. The setup script will automatically check and offer to install it, or you can install it manually.

**Option 1: Automatic (During Setup)**
- The setup script will detect if pgvector is missing
- It will offer to run the installer for you
- Just answer 'Y' when prompted

**Option 2: Manual Installation**
```cmd
# Run the pgvector installer
install_pgvector.bat
```

The installer provides three methods:
1. Automatic SQL installation (tries to create the extension)
2. Download prebuilt binaries from GitHub
3. Use PostgreSQL Stack Builder

**Option 3: Manual Steps**
1. Download from: https://github.com/pgvector/pgvector/releases
2. Look for: `pgvector-X.X.X-postgres-18-windows-x64.zip`
3. Extract and copy files:
   - `vector.dll` → `C:\Program Files\PostgreSQL\18\lib\`
   - `vector.control` and `vector--*.sql` → `C:\Program Files\PostgreSQL\18\share\extension\`
4. Restart PostgreSQL service (services.msc)
5. Run: `psql -U postgres -p 5432 -d AEROSPACE -c "CREATE EXTENSION vector;"`

### 3. Install Ollama

Download from: https://ollama.com/download/windows

After installation, pull the model:
```cmd
ollama serve
```

In another terminal:
```cmd
ollama pull gemma3:1b
```

## Quick Setup (Recommended)

### Step 1: Clone/Download the Repository

```cmd
cd C:\
git clone <repository-url> aerospace-rag
cd aerospace-rag
```

Or download and extract the ZIP file.

### Step 2: Run Setup Script

Double-click `setup_windows.bat` or run in Command Prompt:
```cmd
setup_windows.bat
```

This will:
- Create virtual environment
- Install all Python dependencies
- Install PyInstaller
- Initialize the database schema

### Step 3: Build Executables (One-Time)

Double-click `build_executables.bat` or run:
```cmd
build_executables.bat
```

This creates standalone .exe files in the `dist\` folder:
- `AerospaceRAG-CLI.exe` - Command-line interface
- `AerospaceRAG-GUI.exe` - Graphical interface

**Build time**: ~5-10 minutes

### Step 4: Add Your PDFs

Place your course PDFs in:
```
data\coursenotes\<course_code>\
data\textbook\<course_code>\
```

Example:
```
data\coursenotes\16.100\lecture1.pdf
data\coursenotes\16.100\lecture2.pdf
data\textbook\16.100\aerodynamics_textbook.pdf
```

### Step 5: Run the Application

#### Option A: Using Executables (Recommended)

Double-click one of these files in the `dist\` folder:
- `AerospaceRAG-GUI.exe` - For graphical interface
- `AerospaceRAG-CLI.exe` - For command-line

#### Option B: Using Batch Files

Double-click:
- `run_gui.bat` - Start GUI
- `run_cli.bat` - Start CLI

Or from Command Prompt:
```cmd
run_gui.bat
```

## Using the Application

### GUI Interface

1. Double-click `AerospaceRAG-GUI.exe` (or `run_gui.bat`)
2. Click "Index Documents" to process your PDFs
3. Type questions in the text box
4. Use filters and adjust sources as needed
5. View answers with source citations

### CLI Interface

Open Command Prompt in the application folder:

```cmd
# Interactive mode (recommended)
AerospaceRAG-CLI.exe interactive

# Or using batch file
run_cli.bat interactive
```

Available commands:
```cmd
AerospaceRAG-CLI.exe init                    # Initialize database
AerospaceRAG-CLI.exe index                   # Index all PDFs
AerospaceRAG-CLI.exe index --course 16.100   # Index specific course
AerospaceRAG-CLI.exe query "What is lift?"   # Ask a question
AerospaceRAG-CLI.exe interactive             # Chat mode
AerospaceRAG-CLI.exe stats                   # View statistics
AerospaceRAG-CLI.exe test                    # Test connectivity
```

## Distributing the Application

### Creating a Portable Package

1. Build the executables (see Step 3 above)
2. Copy the entire `dist\` folder to a USB drive or zip it
3. The folder contains:
   - `AerospaceRAG-GUI.exe`
   - `AerospaceRAG-CLI.exe`
   - `config\config.yaml`
   - `data\` folders (add your PDFs here)

### On Another Windows Computer

1. Copy the `dist\` folder
2. Ensure PostgreSQL 16/18 is running (port 5432)
3. Ensure Ollama is running with gemma3:1b
4. Double-click `AerospaceRAG-GUI.exe`

**Note**: The .exe files are portable, but PostgreSQL and Ollama must be installed and running on each computer.

## Troubleshooting

### "Python is not recognized"

**Problem**: Python not in PATH

**Solution**:
1. Reinstall Python
2. Check "Add Python to PATH" during installation
3. Or manually add Python to PATH

### "Could not connect to database"

**Problem**: PostgreSQL not running or wrong port

**Solution**:
1. Check PostgreSQL is running:
   ```cmd
   pg_isready -h localhost -p 5432
   ```
2. Start PostgreSQL service:
   - Open Services (Win + R, type `services.msc`)
   - Find "postgresql-x64-16" or "postgresql-x64-18"
   - Click "Start"

### "Failed to connect to Ollama"

**Problem**: Ollama not running

**Solution**:
```cmd
ollama serve
```

Keep this terminal open while using the app.

### "Module not found" errors

**Problem**: Dependencies not installed

**Solution**:
```cmd
setup_windows.bat
```

### "extension vector does not exist"

**Problem**: pgvector extension not installed

**Solution**:
```cmd
psql -U postgres -p 5432 -d AEROSPACE
CREATE EXTENSION vector;
\q
```

### Build fails with PyInstaller

**Problem**: Missing dependencies or conflicts

**Solution**:
```cmd
# Clean rebuild
rmdir /s /q build dist
pip install --upgrade pyinstaller
build_executables.bat
```

## Configuration

Edit `config\config.yaml` to customize:

```yaml
database:
  host: localhost
  port: 5432        # Default PostgreSQL port
  user: postgres
  password: "1234"  # Change if using different password
  database: AEROSPACE

ollama:
  base_url: http://localhost:11434
  model: gemma3:1b  # Change to use different model
  temperature: 0.7
  max_tokens: 2048

rag:
  chunk_size: 512
  chunk_overlap: 100
  top_k: 5          # Number of sources to retrieve
  similarity_threshold: 0.7
```

## File Structure

```
aerospace-rag/
├── dist/                          # Built executables (after build)
│   ├── AerospaceRAG-CLI.exe      # CLI executable
│   ├── AerospaceRAG-GUI.exe      # GUI executable
│   ├── config/
│   │   └── config.yaml
│   └── data/
│       ├── coursenotes/
│       └── textbook/
├── aerospace_rag/                 # Source code
├── config/
│   └── config.yaml               # Configuration
├── data/                          # PDF storage
│   ├── coursenotes/
│   └── textbook/
├── setup_windows.bat             # Setup script
├── build_executables.bat         # Build .exe files
├── run_cli.bat                   # Quick CLI launcher
├── run_gui.bat                   # Quick GUI launcher
└── requirements.txt              # Python dependencies
```

## Performance on Windows

### Typical Performance:
- **Indexing**: ~1-2 minutes per 100 PDF pages
- **Query**: ~3-6 seconds per question
- **Memory**: ~2-3GB during indexing, ~500MB during queries
- **Disk**: ~10-20MB per 100 pages (includes vectors)

### Optimization Tips:
1. Use SSD for better performance
2. Close other applications during indexing
3. Use `top_k=3-5` for faster queries
4. Filter by course when possible

## Advanced Usage

### Running Without Building Executables

If you prefer to run from source:

```cmd
# Activate virtual environment
venv\Scripts\activate.bat

# Run directly
python run_gui.py
python run_cli.py interactive
```

### Updating the Application

```cmd
git pull
setup_windows.bat
build_executables.bat
```

### Adding New Courses

1. Edit `config\config.yaml`:
```yaml
courses:
  "NEW.CODE": "New Course Name"
```

2. Create directories:
```cmd
mkdir data\coursenotes\NEW.CODE
mkdir data\textbook\NEW.CODE
```

3. Add PDFs and index:
```cmd
AerospaceRAG-CLI.exe index --course NEW.CODE
```

## Getting Help

1. Check this guide
2. Read `README.md` for detailed documentation
3. Run: `AerospaceRAG-CLI.exe test` to diagnose issues
4. Check logs in the console output

## System Requirements

### Minimum:
- Windows 10/11 (64-bit)
- Python 3.8+
- 4GB RAM
- 5GB free disk space
- PostgreSQL 16
- Ollama

### Recommended:
- Windows 11 (64-bit)
- Python 3.10+
- 8GB+ RAM
- 20GB+ free disk space (for multiple courses)
- SSD storage
- Dedicated GPU (for faster Ollama inference)

## Tips for Windows Users

1. **Use PowerShell or Command Prompt as Administrator** for initial setup
2. **Add exceptions in Windows Defender** for the dist folder (may flag .exe files)
3. **Keep Ollama running** - Add to startup if you use the app frequently
4. **Use Task Scheduler** to auto-start PostgreSQL service
5. **Create desktop shortcuts** to the .exe files for easy access

## Creating Desktop Shortcuts

1. Right-click on `AerospaceRAG-GUI.exe` in the dist folder
2. Click "Create shortcut"
3. Drag shortcut to desktop
4. Right-click shortcut → Properties → Change icon (optional)

Now you can launch the app directly from your desktop!

---

## Uninstalling the Application

If you need to remove Aerospace RAG from your system:

### Method 1: Using the Main Menu (Recommended)

```cmd
Double-click: START_HERE.bat
Choose option: 8 (Uninstall Application)
```

### Method 2: Direct Uninstaller

```cmd
Double-click: uninstall.bat
```

### Uninstall Options

The uninstaller will give you three choices:

**1. Remove Everything (Complete Uninstall)**
- Removes virtual environment (venv folder)
- Removes executables (dist folder)
- Removes build files (build folder)
- **Removes all PDF data files**
- **Drops PostgreSQL AEROSPACE database**
- Cleans Python cache files

**Warning**: This option will permanently delete your indexed data and database!

**2. Remove Application Only**
- Removes virtual environment
- Removes executables
- Removes build files
- **Keeps your PDF files**
- **Keeps PostgreSQL database**
- Cleans Python cache

This is good if you want to reinstall later with your existing data.

**3. Remove Build Files Only**
- Removes executables (dist folder)
- Removes build artifacts (build folder)
- Cleans Python cache
- **Keeps everything else**

Useful when you want to rebuild the executables or free up disk space.

### What Gets Removed

| Item | Option 1 | Option 2 | Option 3 |
|------|----------|----------|----------|
| Virtual Environment | ✅ | ✅ | ❌ |
| Executables (.exe) | ✅ | ✅ | ✅ |
| Build Files | ✅ | ✅ | ✅ |
| Python Cache | ✅ | ✅ | ✅ |
| PDF Data Files | ✅ | ❌ | ❌ |
| PostgreSQL Database | ✅ | ❌ | ❌ |
| Source Code | ❌ | ❌ | ❌ |

### Complete Removal

After running the uninstaller, to completely remove everything:

1. **Delete the application folder**
   ```cmd
   rmdir /s /q C:\path\to\gronk
   ```

2. **Uninstall Ollama** (optional)
   - Go to Windows Settings → Apps
   - Find "Ollama" and click Uninstall

3. **Uninstall PostgreSQL** (optional)
   - Go to Windows Settings → Apps
   - Find "PostgreSQL 18" and click Uninstall
   - Or use the PostgreSQL uninstaller in the installation directory

### Backup Before Uninstalling

If you want to backup your data before uninstalling:

**Backup PDFs:**
```cmd
xcopy /E /I data\coursenotes C:\backup\coursenotes
xcopy /E /I data\textbook C:\backup\textbook
```

**Backup Database:**
```cmd
pg_dump -U postgres -p 5432 AEROSPACE > aerospace_backup.sql
```

**Restore Database Later:**
```cmd
psql -U postgres -p 5432 -c "CREATE DATABASE AEROSPACE;"
psql -U postgres -p 5432 AEROSPACE < aerospace_backup.sql
```

---

**You're all set!** Double-click `AerospaceRAG-GUI.exe` to start using your AI aerospace assistant! ✈️
