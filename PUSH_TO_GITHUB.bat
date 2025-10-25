@echo off
REM Automated script to push Aerospace RAG to your gronk3 repository
REM Run this from the gronk3 folder on your laptop

echo ========================================
echo Push to gronk3 Repository
echo ========================================
echo.

REM Check if we're in the right directory
if not exist "aerospace_rag" (
    echo ERROR: aerospace_rag folder not found!
    echo Please run this script from the aero1 directory.
    echo.
    pause
    exit /b 1
)

REM Check if git is initialized
if not exist ".git" (
    echo Initializing git repository...
    git init
    git branch -M main
    echo.
)

REM Configure git (update with your info if needed)
echo Configuring git...
git config user.name "SageW00"
git config user.email "your-email@example.com"
echo.

REM Add all files
echo Adding all files to git...
git add -A
echo.

REM Check if there are changes to commit
git diff-index --quiet HEAD --
if errorlevel 1 (
    echo Committing changes...
    git commit -m "Complete Aerospace RAG Application - All Fixes Included

This is the complete, production-ready Aerospace RAG application.

FEATURES:
- AI-powered Q&A with MIT OCW aerospace course materials
- Dual interfaces: CLI and GUI
- Local AI: Ollama with gemma3:1b + embeddinggemma
- Vector search: PostgreSQL + pgvector (768 dimensions)
- PDF processing and indexing
- Windows standalone EXE support
- Complete documentation

ALL FIXES INCLUDED:
- Model detection (handles all Ollama API variations)
- Vector dimensions (768 for embeddinggemma)
- Batch files (won't close, show errors)
- Standalone EXE with icon and desktop shortcut

SETUP:
1. Run setup_windows.bat
2. Run migrate_vector_dimensions.bat
3. Launch with run_cli.bat or run_gui.bat

See README.md for complete documentation."
    echo.
) else (
    echo No changes to commit, files already committed.
    echo.
)

REM Add remote if it doesn't exist
git remote | findstr "origin" >nul
if errorlevel 1 (
    echo Adding gronk3 remote repository...
    git remote add origin https://github.com/SageW00/gronk3.git
    echo.
) else (
    echo Setting gronk3 remote URL...
    git remote set-url origin https://github.com/SageW00/gronk3.git
    echo.
)

REM Push to GitHub
echo ========================================
echo Pushing to GitHub...
echo ========================================
echo.
echo Repository: https://github.com/SageW00/gronk3.git
echo Branch: main
echo.

git push -u origin main

if errorlevel 1 (
    echo.
    echo ========================================
    echo PUSH FAILED
    echo ========================================
    echo.
    echo This could be due to:
    echo   1. Authentication required (enter your GitHub credentials)
    echo   2. Branch conflicts (remote has different history)
    echo   3. Network issues
    echo.
    echo To force push (overwrites remote):
    echo   git push -f origin main
    echo.
    echo To pull and merge first:
    echo   git pull origin main --allow-unrelated-histories
    echo   git push origin main
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS!
echo ========================================
echo.
echo All files pushed to:
echo https://github.com/SageW00/gronk3
echo.
echo You can now:
echo   1. Visit your repository on GitHub
echo   2. Clone it on other computers
echo   3. Share it with others
echo.
echo Next steps:
echo   - Run setup_windows.bat to set up the application
echo   - Run migrate_vector_dimensions.bat to fix database
echo   - Launch with run_cli.bat or run_gui.bat
echo.
pause
