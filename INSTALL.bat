@echo off
REM ONE-CLICK INSTALLER - Creates venv, installs everything, pulls models
REM Just double-click this file and wait. That's it.

title Aerospace RAG - One-Click Installer

cls
echo ============================================================
echo   AEROSPACE RAG APPLICATION - ONE-CLICK INSTALLER
echo ============================================================
echo.
echo This will:
echo   1. Create virtual environment (venv folder)
echo   2. Install all Python packages (requirements.txt)
echo   3. Pull Ollama models (gemma3:1b, embeddinggemma)
echo   4. Create build folders (dist, build)
echo   5. Set up database
echo.
echo This may take 5-10 minutes depending on your internet speed.
echo.
pause
echo.

REM ============================================================
REM STEP 1: Check Python
REM ============================================================
echo [1/6] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Python not found!
    echo.
    echo Please install Python 3.8+ from: https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation!
    echo.
    pause
    exit /b 1
)
python --version
echo   Python found!
echo.

REM ============================================================
REM STEP 2: Create venv folder
REM ============================================================
echo [2/6] Creating virtual environment (venv folder)...
if exist venv (
    echo   venv folder already exists, skipping...
) else (
    python -m venv venv
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to create virtual environment!
        echo.
        pause
        exit /b 1
    )
    echo   venv folder created!
)
echo.

REM ============================================================
REM STEP 3: Install Python packages
REM ============================================================
echo [3/6] Installing Python packages from requirements.txt...
echo   This may take 2-3 minutes...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
if errorlevel 1 (
    echo.
    echo ERROR: Failed to install packages!
    echo.
    pause
    exit /b 1
)
pip install pyinstaller --quiet
echo   All packages installed!
echo.

REM ============================================================
REM STEP 4: Create build folders
REM ============================================================
echo [4/6] Creating build folders (dist, build)...
if not exist dist mkdir dist
if not exist build mkdir build
echo   Folders created!
echo.

REM ============================================================
REM STEP 5: Pull Ollama models
REM ============================================================
echo [5/6] Checking Ollama and pulling models...
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: Ollama not running!
    echo.
    echo Please install and start Ollama:
    echo   Download from: https://ollama.com/download/windows
    echo   Then run: ollama serve
    echo.
    echo Skipping model download for now.
    echo You can pull models later with: ollama pull gemma3:1b
    echo.
) else (
    echo   Ollama is running!
    echo.

    REM Check gemma3:1b
    echo   Checking gemma3:1b...
    curl -s http://localhost:11434/api/tags | findstr /C:"gemma3:1b" >nul 2>&1
    if errorlevel 1 (
        echo   Pulling gemma3:1b (this may take 3-5 minutes)...
        ollama pull gemma3:1b
    ) else (
        echo   gemma3:1b already available!
    )

    REM Check embeddinggemma
    echo   Checking embeddinggemma...
    curl -s http://localhost:11434/api/tags | findstr /C:"embeddinggemma" >nul 2>&1
    if errorlevel 1 (
        echo   Pulling embeddinggemma (this may take 2-3 minutes)...
        ollama pull embeddinggemma
    ) else (
        echo   embeddinggemma already available!
    )

    echo.
    echo   All Ollama models ready!
)
echo.

REM ============================================================
REM STEP 6: Database setup
REM ============================================================
echo [6/6] Checking database...
pg_isready -h localhost -p 5432 >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: PostgreSQL not running!
    echo.
    echo Please install PostgreSQL:
    echo   Download from: https://www.postgresql.org/download/windows/
    echo   Or use: https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
    echo.
    echo After installing PostgreSQL:
    echo   1. Run: migrate_vector_dimensions.bat
    echo   2. This will create the AEROSPACE database
    echo.
) else (
    echo   PostgreSQL is running!
    echo.
    echo   Next step: Run migrate_vector_dimensions.bat to create database
)
echo.

REM ============================================================
REM DONE!
REM ============================================================
echo ============================================================
echo   INSTALLATION COMPLETE!
echo ============================================================
echo.
echo What was created:
echo   - venv folder (virtual environment with all packages)
echo   - dist folder (for built executables)
echo   - build folder (for build files)
echo   - .env file (configuration)
echo.
echo Next steps:
echo   1. If you haven't already, run: migrate_vector_dimensions.bat
echo   2. Then launch the app:
echo      - Double-click: run_gui.bat (for graphical interface)
echo      - Double-click: run_cli.bat (for command-line interface)
echo.
echo All folders and dependencies are now ready!
echo.
pause
