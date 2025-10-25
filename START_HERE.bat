@echo off
REM Main launcher for Aerospace RAG Application
title Aerospace RAG Application

:menu
cls
echo =========================================
echo   AEROSPACE RAG APPLICATION
echo   AI-Powered Aerospace Learning Assistant
echo =========================================
echo.
echo What would you like to do?
echo.
echo   [1] Setup (First Time Only)
echo   [2] Build Windows Executables
echo   [3] Run GUI (Graphical Interface)
echo   [4] Run CLI (Command-Line Interface)
echo   [5] Index Documents
echo   [6] View Statistics
echo   [7] Test System
echo   [8] Exit
echo.
set /p choice="Enter your choice (1-8): "

if "%choice%"=="1" goto setup
if "%choice%"=="2" goto build
if "%choice%"=="3" goto run_gui
if "%choice%"=="4" goto run_cli
if "%choice%"=="5" goto index
if "%choice%"=="6" goto stats
if "%choice%"=="7" goto test
if "%choice%"=="8" goto exit
goto menu

:setup
cls
echo Running setup...
call setup_windows.bat
pause
goto menu

:build
cls
echo Building executables...
call build_executables.bat
pause
goto menu

:run_gui
cls
echo Starting GUI...
if exist "dist\AerospaceRAG-GUI.exe" (
    start dist\AerospaceRAG-GUI.exe
    goto menu
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    python run_gui.py
) else (
    echo ERROR: Please run Setup first (Option 1)
    pause
    goto menu
)
goto menu

:run_cli
cls
if exist "dist\AerospaceRAG-CLI.exe" (
    echo Starting CLI...
    dist\AerospaceRAG-CLI.exe interactive
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    python run_cli.py interactive
) else (
    echo ERROR: Please run Setup first (Option 1)
    pause
)
goto menu

:index
cls
if exist "dist\AerospaceRAG-CLI.exe" (
    dist\AerospaceRAG-CLI.exe index
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    python run_cli.py index
) else (
    echo ERROR: Please run Setup first (Option 1)
)
pause
goto menu

:stats
cls
if exist "dist\AerospaceRAG-CLI.exe" (
    dist\AerospaceRAG-CLI.exe stats
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    python run_cli.py stats
) else (
    echo ERROR: Please run Setup first (Option 1)
)
pause
goto menu

:test
cls
if exist "dist\AerospaceRAG-CLI.exe" (
    dist\AerospaceRAG-CLI.exe test
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    python run_cli.py test
) else (
    echo ERROR: Please run Setup first (Option 1)
)
pause
goto menu

:exit
cls
echo Thank you for using Aerospace RAG!
echo.
timeout /t 2 >nul
exit
