@echo off
REM Quick launcher for Aerospace RAG GUI

REM Activate virtual environment if it exists
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
)

REM Run the GUI application
python run_gui.py

REM Keep window open if there was an error
if errorlevel 1 pause
