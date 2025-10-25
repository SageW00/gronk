@echo off
REM Quick launcher for Aerospace RAG GUI

echo ========================================
echo Aerospace RAG GUI Launcher
echo ========================================
echo.

REM Activate virtual environment if it exists
if exist "venv\Scripts\activate.bat" (
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
) else (
    echo ERROR: Virtual environment not found!
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

echo Launching GUI...
echo.
REM Run the GUI application
python run_gui.py

REM Pause on error to show messages
if errorlevel 1 (
    echo.
    echo ========================================
    echo ERROR: GUI failed to launch
    echo ========================================
    echo.
    pause
)
