@echo off
REM Quick launcher for Aerospace RAG CLI

REM Activate virtual environment if it exists
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
)

REM Run the CLI application
python run_cli.py %*

REM Keep window open if there was an error
if errorlevel 1 pause
