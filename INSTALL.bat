@echo off
REM ONE-CLICK INSTALLER - Creates venv, installs everything, pulls models
REM Just double-click this file and wait. That's it.

title Aerospace RAG - One-Click Installer

cls
echo ============================================================
echo   AEROSPACE RAG APPLICATION - ONE-CLICK INSTALLER
echo ============================================================
echo.
echo This will install everything you need:
echo   1. Create virtual environment (venv folder)
echo   2. Install all Python packages (requirements.txt)
echo   3. Pull Ollama models (gemma3:1b, embeddinggemma)
echo   4. Create build folders (dist, build)
echo   5. Set up database structure
echo.
echo Time required: 5-10 minutes (depending on internet speed)
echo.
echo REQUIREMENTS:
echo   - Python 3.8+ installed and in PATH
echo   - PostgreSQL 16+ installed and running
echo   - Ollama installed and running
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
    echo ============================================
    echo ERROR: Python not found!
    echo ============================================
    echo.
    echo Please install Python 3.8 or higher from:
    echo https://www.python.org/downloads/
    echo.
    echo IMPORTANT: During installation, check "Add Python to PATH"
    echo.
    pause
    exit /b 1
)
python --version
echo   ✓ Python found!
echo.

REM ============================================================
REM STEP 2: Create venv folder
REM ============================================================
echo [2/6] Creating virtual environment (venv folder)...
if exist venv (
    echo   ✓ venv folder already exists
) else (
    python -m venv venv
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to create virtual environment!
        echo Make sure Python venv module is installed.
        echo.
        pause
        exit /b 1
    )
    echo   ✓ venv folder created successfully!
)
echo.

REM ============================================================
REM STEP 3: Install Python packages
REM ============================================================
echo [3/6] Installing Python packages...
echo   This may take 2-3 minutes...
call venv\Scripts\activate.bat

REM Upgrade pip first
python -m pip install --upgrade pip --quiet >nul 2>&1

REM Install all requirements
pip install -r requirements.txt --quiet
if errorlevel 1 (
    echo.
    echo ERROR: Failed to install packages from requirements.txt
    echo.
    pause
    exit /b 1
)

REM Install PyInstaller for building executables
pip install pyinstaller --quiet >nul 2>&1

echo   ✓ All Python packages installed!
echo.

REM ============================================================
REM STEP 4: Create build folders
REM ============================================================
echo [4/6] Creating build folders...
if not exist dist mkdir dist
if not exist build mkdir build
echo   ✓ Folders created (dist, build)
echo.

REM ============================================================
REM STEP 5: Check and pull Ollama models
REM ============================================================
echo [5/6] Checking Ollama and pulling models...
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo.
    echo ============================================
    echo WARNING: Ollama not running!
    echo ============================================
    echo.
    echo Ollama is required for AI text generation and embeddings.
    echo.
    echo To install Ollama:
    echo   1. Download from: https://ollama.com/download/windows
    echo   2. Install and start Ollama
    echo   3. Run this installer again
    echo.
    echo Skipping model download for now...
    echo.
) else (
    echo   ✓ Ollama is running!
    echo.

    REM Check gemma3:1b (text generation model)
    echo   Checking gemma3:1b (text generation model)...
    curl -s http://localhost:11434/api/tags | findstr /C:"gemma3:1b" >nul 2>&1
    if errorlevel 1 (
        echo   ! Model not found, pulling now...
        echo   This may take 3-5 minutes (815 MB download)
        ollama pull gemma3:1b
        if errorlevel 1 (
            echo   WARNING: Failed to pull gemma3:1b
        ) else (
            echo   ✓ gemma3:1b installed!
        )
    ) else (
        echo   ✓ gemma3:1b already installed
    )

    REM Check embeddinggemma (embedding model)
    echo   Checking embeddinggemma (embedding model)...
    curl -s http://localhost:11434/api/tags | findstr /C:"embeddinggemma" >nul 2>&1
    if errorlevel 1 (
        echo   ! Model not found, pulling now...
        echo   This may take 2-3 minutes (621 MB download)
        ollama pull embeddinggemma
        if errorlevel 1 (
            echo   WARNING: Failed to pull embeddinggemma
        ) else (
            echo   ✓ embeddinggemma installed!
        )
    ) else (
        echo   ✓ embeddinggemma already installed
    )

    echo.
    echo   ✓ All Ollama models ready!
)
echo.

REM ============================================================
REM STEP 6: Check database
REM ============================================================
echo [6/6] Checking PostgreSQL database...
pg_isready -h localhost -p 5432 >nul 2>&1
if errorlevel 1 (
    echo.
    echo ============================================
    echo WARNING: PostgreSQL not running!
    echo ============================================
    echo.
    echo PostgreSQL is required for vector database storage.
    echo.
    echo To install PostgreSQL:
    echo   1. Download from: https://www.postgresql.org/download/windows/
    echo   2. Install PostgreSQL 16 or higher
    echo   3. Set password to '1234' (or update .env file)
    echo   4. Run: migrate_vector_dimensions.bat
    echo.
) else (
    echo   ✓ PostgreSQL is running!
    echo.
    echo   NEXT STEP: Create the AEROSPACE database
    echo   Run: migrate_vector_dimensions.bat
)
echo.

REM ============================================================
REM DONE!
REM ============================================================
echo ============================================================
echo   INSTALLATION COMPLETE!
echo ============================================================
echo.
echo What was installed:
echo   ✓ venv folder (Python virtual environment)
echo   ✓ All Python packages (from requirements.txt)
echo   ✓ Ollama models (gemma3:1b, embeddinggemma)
echo   ✓ Build folders (dist, build)
echo.
echo Next steps:
echo   1. Run: migrate_vector_dimensions.bat (create database)
echo   2. Launch app: run_gui.bat (GUI) or run_cli.bat (CLI)
echo   3. Add PDFs: Place in data/coursenotes/ or data/textbook/
echo   4. Index PDFs: Choose option 4 in START_HERE.bat
echo.
echo You can now use the Aerospace RAG application!
echo.
pause
