@echo off
REM Debug script to check Ollama API structure

echo ========================================
echo Ollama API Debug Tool
echo ========================================
echo.

REM Activate virtual environment if it exists
if exist "venv\Scripts\activate.bat" (
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
    echo.
) else (
    echo WARNING: Virtual environment not found!
    echo Using system Python...
    echo.
)

REM Run the debug script
python debug_ollama_api.py

echo.
echo ========================================
echo.
pause
