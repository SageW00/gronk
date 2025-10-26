@echo off
REM Quick launcher for Aerospace RAG CLI

echo ========================================
echo Aerospace RAG CLI Launcher
echo ========================================
echo.

REM Check if virtual environment exists
if not exist "venv\Scripts\activate.bat" (
    echo Virtual environment not found!
    echo Running setup first...
    echo.
    call setup_windows.bat
    if errorlevel 1 (
        echo.
        echo ERROR: Setup failed!
        echo.
        pause
        exit /b 1
    )
    echo.
    echo Setup complete! Now launching CLI...
    echo.
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

echo.
REM Run the CLI application
python run_cli.py %*

REM Always pause so user can see output
echo.
pause
