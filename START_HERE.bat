@echo off
REM Complete launcher for Aerospace RAG Application
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
echo   [1] Install Everything (First Time Only)
echo   [2] Run GUI (Graphical Interface)
echo   [3] Run CLI (Command-Line Interface)
echo   [4] Index Documents (Add PDFs for Q&A)
echo   [5] View Statistics (Database Info)
echo   [6] Test System (Check Ollama/Database)
echo   [7] Build Windows EXE (Optional)
echo   [8] Uninstall Application
echo   [9] Exit
echo.
set /p choice="Enter your choice (1-9): "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto run_gui
if "%choice%"=="3" goto run_cli
if "%choice%"=="4" goto index
if "%choice%"=="5" goto stats
if "%choice%"=="6" goto test
if "%choice%"=="7" goto build
if "%choice%"=="8" goto uninstall
if "%choice%"=="9" goto exit
echo Invalid choice. Please try again.
pause
goto menu

:install
cls
echo ========================================
echo RUNNING ONE-CLICK INSTALLER
echo ========================================
echo.
call INSTALL.bat
goto menu

:run_gui
cls
echo ========================================
echo STARTING GUI
echo ========================================
echo.
call run_gui.bat
goto menu

:run_cli
cls
echo ========================================
echo STARTING CLI
echo ========================================
echo.
call run_cli.bat
goto menu

:index
cls
echo ========================================
echo INDEX DOCUMENTS
echo ========================================
echo.
echo This will index PDF files for Q&A with embeddings.
echo Place your PDFs in:
echo   - data/coursenotes/
echo   - data/textbook/
echo.
if not exist "venv\Scripts\activate.bat" (
    echo ERROR: Please run Install first (Option 1)
    echo.
    pause
    goto menu
)
call venv\Scripts\activate.bat
python run_cli.py index
pause
goto menu

:stats
cls
echo ========================================
echo DATABASE STATISTICS
echo ========================================
echo.
if not exist "venv\Scripts\activate.bat" (
    echo ERROR: Please run Install first (Option 1)
    echo.
    pause
    goto menu
)
call venv\Scripts\activate.bat
python run_cli.py stats
pause
goto menu

:test
cls
echo ========================================
echo TESTING SYSTEM
echo ========================================
echo.
call diagnose_ollama.bat
echo.
pause
goto menu

:build
cls
echo ========================================
echo BUILDING WINDOWS EXE
echo ========================================
echo.
call build_executables.bat
echo.
pause
goto menu

:uninstall
cls
echo ========================================
echo UNINSTALL APPLICATION
echo ========================================
echo.
call uninstall.bat
goto menu

:exit
cls
echo ========================================
echo Thank you for using Aerospace RAG!
echo ========================================
timeout /t 2 >nul
exit
