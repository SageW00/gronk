@echo off
REM Simple launcher for Aerospace RAG Application
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
echo   [4] Test System
echo   [5] Build Windows EXE (Optional)
echo   [6] Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto setup
if "%choice%"=="2" goto run_gui
if "%choice%"=="3" goto run_cli
if "%choice%"=="4" goto test
if "%choice%"=="5" goto build
if "%choice%"=="6" goto exit
echo Invalid choice. Please try again.
pause
goto menu

:setup
cls
echo ========================================
echo RUNNING INSTALLER
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

:exit
cls
echo ========================================
echo Thank you for using Aerospace RAG!
echo ========================================
timeout /t 2 >nul
exit
