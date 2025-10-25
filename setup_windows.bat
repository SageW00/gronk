@echo off
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
pg_isready -h localhost -p 5433 >nul 2>&1
if errorlevel 1 (
    echo WARNING: PostgreSQL may not be running on port 5433
    echo Please ensure PostgreSQL 16 is installed and running
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
)

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

REM Initialize database
echo Initializing database...
python run_cli.py init
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
