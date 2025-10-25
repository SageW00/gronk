@echo off
REM Ollama Diagnostic Script for Aerospace RAG (Windows)
REM This script checks if Ollama is set up correctly

setlocal enabledelayedexpansion
set ISSUES=0

echo ========================================
echo Ollama Setup Diagnostic Tool
echo ========================================
echo.

REM Check 1: Is Ollama installed?
echo [1/6] Checking if Ollama is installed...
ollama --version >nul 2>&1
if errorlevel 1 (
    echo X FAIL: Ollama is not installed
    echo    -^> Install from: https://ollama.com/download/windows
    set /a ISSUES+=1
) else (
    for /f "tokens=*" %%i in ('ollama --version 2^>^&1') do set VERSION=%%i
    echo √ PASS: Ollama is installed (!VERSION!)
)
echo.

REM Check 2: Is Ollama running?
echo [2/6] Checking if Ollama service is running...
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo X FAIL: Ollama service is not running
    echo    -^> Start it with: ollama serve
    echo    -^> Keep that Command Prompt window open
    set /a ISSUES+=1
) else (
    echo √ PASS: Ollama service is running on port 11434
)
echo.

REM Check 3: Is gemma3:1b installed?
echo [3/6] Checking for gemma3:1b model...
curl -s http://localhost:11434/api/tags 2>&1 | findstr /C:"gemma3:1b" >nul 2>&1
if errorlevel 1 (
    echo X FAIL: gemma3:1b model is not installed
    echo    -^> Install with: ollama pull gemma3:1b
    echo    -^> This will download ~2GB (takes 5-15 minutes^)
    set /a ISSUES+=1
) else (
    echo √ PASS: gemma3:1b model is installed
)
echo.

REM Check 4: Is embeddinggemma installed?
echo [4/6] Checking for embeddinggemma model...
curl -s http://localhost:11434/api/tags 2>&1 | findstr /C:"embeddinggemma" >nul 2>&1
if errorlevel 1 (
    echo X FAIL: embeddinggemma model is not installed
    echo    -^> Install with: ollama pull embeddinggemma
    echo    -^> This will download ~300MB (takes 1-5 minutes^)
    set /a ISSUES+=1
) else (
    echo √ PASS: embeddinggemma model is installed
)
echo.

REM Check 5: Can we list models?
echo [5/6] Listing all installed models...
ollama --version >nul 2>&1
if errorlevel 1 (
    echo !  SKIP: Ollama not installed
) else (
    echo.
    ollama list
    echo.
)
echo.

REM Check 6: Test connection
echo [6/6] Testing Ollama API connection...
curl -s http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo !  SKIP: Ollama service not running
) else (
    echo √ PASS: Can connect to Ollama API
)
echo.

REM Summary
echo ========================================
echo DIAGNOSTIC SUMMARY
echo ========================================
echo.

if !ISSUES! equ 0 (
    echo SUCCESS! Everything is set up correctly!
    echo.
    echo You can now run:
    echo   setup_windows.bat     # Set up Aerospace RAG
    echo   run_cli.bat           # Run the CLI
    echo   run_gui.bat           # Run the GUI
    echo.
) else (
    echo !  Found !ISSUES! issue(s^) that need to be fixed.
    echo.
    echo Quick Fix Commands:
    echo.

    ollama --version >nul 2>&1
    if errorlevel 1 (
        echo 1. Install Ollama:
        echo    Download from: https://ollama.com/download/windows
        echo    Run the installer
        echo.
    )

    curl -s http://localhost:11434/api/tags >nul 2>&1
    if errorlevel 1 (
        echo 2. Start Ollama service:
        echo    ollama serve
        echo    (Keep this Command Prompt window open!^)
        echo.
    )

    curl -s http://localhost:11434/api/tags 2>&1 | findstr /C:"gemma3:1b" >nul 2>&1
    if errorlevel 1 (
        echo 3. Pull gemma3:1b model:
        echo    ollama pull gemma3:1b
        echo.
    )

    curl -s http://localhost:11434/api/tags 2>&1 | findstr /C:"embeddinggemma" >nul 2>&1
    if errorlevel 1 (
        echo 4. Pull embeddinggemma model:
        echo    ollama pull embeddinggemma
        echo.
    )

    echo After fixing, run this diagnostic again:
    echo   diagnose_ollama.bat
    echo.
)

echo For detailed help, see: OLLAMA_SETUP_GUIDE.md
echo.
pause
