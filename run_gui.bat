@echo off
REM Quick launcher for Aerospace RAG GUI

echo ========================================
echo Aerospace RAG GUI Launcher
echo ========================================
echo.

REM Check if virtual environment exists
if not exist "venv\Scripts\activate.bat" (
    echo.
    echo ============================================
    echo  FIRST TIME SETUP REQUIRED
    echo ============================================
    echo.
    echo The venv folder is missing!
    echo Please run INSTALL.bat first to set up everything.
    echo.
    echo This is a ONE-TIME setup that:
    echo   - Creates venv folder
    echo   - Installs all packages
    echo   - Downloads Ollama models
    echo.
    echo After that, this will work automatically!
    echo ============================================
    echo.
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

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
