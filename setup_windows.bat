@echo off
setlocal enabledelayedexpansion
REM Setup script for Aerospace RAG Application - Windows
REM This will install dependencies and set up the application

echo =========================================
echo Aerospace RAG Application Setup
echo Windows 11 Edition
echo =========================================
echo.

REM Check Python installation
echo Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

python --version
echo.

REM Check PostgreSQL
echo Checking PostgreSQL connection...
pg_isready -h localhost -p 5432 >nul 2>&1
if errorlevel 1 (
    echo WARNING: PostgreSQL may not be running on port 5432
    echo Please ensure PostgreSQL 16/18 is installed and running
    echo.
)

REM Check Ollama
echo Checking Ollama...
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo WARNING: Ollama may not be running
    echo Please ensure Ollama is installed and running
    echo Download from: https://ollama.com/download/windows
    echo.
    pause
    exit /b 1
)

REM Pull required Ollama models
echo.
echo Pulling required Ollama models...
echo This application requires two models:
echo   1. gemma3:1b - for text generation (answering questions)
echo   2. embeddinggemma - for embeddings (semantic search)
echo.

REM Check if gemma3:1b is already installed
ollama list 2>nul | findstr /C:"gemma3:1b" >nul 2>&1
if errorlevel 1 (
    echo Pulling gemma3:1b... (this may take a few minutes)
    ollama pull gemma3:1b
    if errorlevel 1 (
        echo ERROR: Failed to pull gemma3:1b
        pause
        exit /b 1
    )
    echo   - gemma3:1b installed successfully
) else (
    echo   - gemma3:1b already installed
)

REM Check if embeddinggemma is already installed
ollama list 2>nul | findstr /C:"embeddinggemma" >nul 2>&1
if errorlevel 1 (
    echo Pulling embeddinggemma... (this may take a few minutes)
    ollama pull embeddinggemma
    if errorlevel 1 (
        echo ERROR: Failed to pull embeddinggemma
        pause
        exit /b 1
    )
    echo   - embeddinggemma installed successfully
) else (
    echo   - embeddinggemma already installed
)

echo.
echo All required Ollama models are installed!
echo.

REM Create virtual environment
echo Creating virtual environment...
if not exist "venv" (
    python -m venv venv
    echo Virtual environment created
) else (
    echo Virtual environment already exists
)
echo.

REM Activate virtual environment and install dependencies
echo Installing dependencies...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt
echo Dependencies installed
echo.

REM Install PyInstaller for building executables
echo Installing PyInstaller...
pip install pyinstaller
echo.

REM Check for pgvector extension
echo Checking for pgvector extension...
psql -U postgres -p 5432 -d AEROSPACE -c "SELECT * FROM pg_extension WHERE extname='vector';" >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: pgvector extension may not be installed
    echo.
    set /p install_pgvector="Would you like to install pgvector now? (Y/N): "
    if /i "!install_pgvector!"=="Y" (
        call install_pgvector.bat
    ) else (
        echo.
        echo Skipping pgvector installation.
        echo You can install it later by running: install_pgvector.bat
        echo.
    )
)

REM Initialize database
echo Initializing database...
python run_cli.py init
if errorlevel 1 (
    echo.
    echo =========================================
    echo   DATABASE INITIALIZATION FAILED
    echo =========================================
    echo.
    echo If you see a pgvector error, run:
    echo   install_pgvector.bat
    echo.
    echo Then run setup again.
    echo.
    pause
    exit /b 1
)
echo.

echo =========================================
echo Setup completed successfully!
echo =========================================
echo.
echo Next steps:
echo   1. Place your PDF files in:
echo      - data\coursenotes\^<course_code^>\
echo      - data\textbook\^<course_code^>\
echo.
echo   2. Build executables (optional):
echo      build_executables.bat
echo.
echo   3. Or run directly:
echo      run_cli.bat
echo      run_gui.bat
echo.
pause
