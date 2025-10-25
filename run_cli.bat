@echo off
REM Quick launcher for Aerospace RAG CLI

echo ========================================
echo Aerospace RAG CLI Launcher
echo ========================================
echo.

REM Activate virtual environment if it exists
if exist "venv\Scripts\activate.bat" (
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
) else (
    echo WARNING: Virtual environment not found!
    echo Please run setup_windows.bat first.
    echo.
    pause
    exit /b 1
)

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found!
    echo Please ensure Python is installed and in PATH.
    echo.
    pause
    exit /b 1
)

echo.
REM Run the CLI application
python run_cli.py %*

REM Always pause so user can see output
echo.
pause
