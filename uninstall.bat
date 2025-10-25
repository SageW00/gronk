@echo off
REM Uninstall script for Aerospace RAG Application - Windows

title Aerospace RAG - Uninstaller

echo =========================================
echo   AEROSPACE RAG APPLICATION
echo   Uninstaller
echo =========================================
echo.
echo This will remove the application files and data.
echo.

:confirm
echo What would you like to remove?
echo.
echo   [1] Remove everything (recommended for clean uninstall)
echo   [2] Remove application only (keep data and database)
echo   [3] Remove build files only (keep source and data)
echo   [4] Cancel
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto remove_all
if "%choice%"=="2" goto remove_app
if "%choice%"=="3" goto remove_build
if "%choice%"=="4" goto cancel
goto confirm

:remove_all
cls
echo =========================================
echo   COMPLETE UNINSTALL
echo =========================================
echo.
echo This will remove:
echo   - Virtual environment (venv folder)
echo   - Build files (dist, build folders)
echo   - Python cache files (__pycache__)
echo   - PDF data files
echo.
echo WARNING: This will also DROP the PostgreSQL database!
echo.
set /p confirm="Are you sure? Type 'YES' to confirm: "
if not "%confirm%"=="YES" (
    echo Uninstall cancelled.
    pause
    exit /b 0
)

echo.
echo Removing application files...

REM Remove virtual environment
if exist "venv" (
    echo Removing virtual environment...
    rmdir /s /q venv
    echo   - Virtual environment removed
)

REM Remove build artifacts
if exist "dist" (
    echo Removing executables...
    rmdir /s /q dist
    echo   - Executables removed
)

if exist "build" (
    rmdir /s /q build
    echo   - Build folder removed
)

REM Remove Python cache
for /d /r %%d in (__pycache__) do @if exist "%%d" rmdir /s /q "%%d"
echo   - Python cache cleaned

REM Remove .spec files
if exist "*.spec" del /q *.spec
echo   - PyInstaller specs removed

REM Remove data files
if exist "data\coursenotes" (
    rmdir /s /q data\coursenotes
    mkdir data\coursenotes
    type nul > data\coursenotes\.gitkeep
    echo   - Course notes removed
)

if exist "data\textbook" (
    rmdir /s /q data\textbook
    mkdir data\textbook
    type nul > data\textbook\.gitkeep
    echo   - Textbook files removed
)

REM Drop PostgreSQL database
echo.
echo Dropping PostgreSQL database...
psql -U postgres -p 5432 -c "DROP DATABASE IF EXISTS AEROSPACE;" 2>nul
if errorlevel 1 (
    echo   ! Could not drop database (you may need to do this manually)
) else (
    echo   - Database dropped successfully
)

goto finish_uninstall

:remove_app
cls
echo =========================================
echo   APPLICATION UNINSTALL
echo =========================================
echo.
echo This will remove:
echo   - Virtual environment (venv folder)
echo   - Build files (dist, build folders)
echo   - Python cache files
echo.
echo This will KEEP:
echo   - Your PDF data files
echo   - PostgreSQL database
echo   - Source code
echo.
set /p confirm="Continue? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Uninstall cancelled.
    pause
    exit /b 0
)

echo.
echo Removing application files...

REM Remove virtual environment
if exist "venv" (
    echo Removing virtual environment...
    rmdir /s /q venv
    echo   - Virtual environment removed
)

REM Remove build artifacts
if exist "dist" (
    echo Removing executables...
    rmdir /s /q dist
    echo   - Executables removed
)

if exist "build" (
    rmdir /s /q build
    echo   - Build folder removed
)

REM Remove Python cache
for /d /r %%d in (__pycache__) do @if exist "%%d" rmdir /s /q "%%d"
echo   - Python cache cleaned

echo.
echo Application removed successfully!
echo Your data files and database are preserved.

goto end

:remove_build
cls
echo =========================================
echo   BUILD FILES CLEANUP
echo =========================================
echo.
echo This will remove:
echo   - Build files (dist, build folders)
echo   - Python cache files
echo.
echo This will KEEP:
echo   - Virtual environment
echo   - Source code
echo   - PDF data
echo   - Database
echo.
set /p confirm="Continue? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Cleanup cancelled.
    pause
    exit /b 0
)

echo.
echo Cleaning build files...

if exist "dist" (
    rmdir /s /q dist
    echo   - Executables removed
)

if exist "build" (
    rmdir /s /q build
    echo   - Build folder removed
)

REM Remove Python cache
for /d /r %%d in (__pycache__) do @if exist "%%d" rmdir /s /q "%%d"
echo   - Python cache cleaned

echo.
echo Build files cleaned successfully!
echo You can rebuild executables with: build_executables.bat

goto end

:finish_uninstall
echo.
echo =========================================
echo   UNINSTALL COMPLETE
echo =========================================
echo.
echo All application files and data have been removed.
echo.
echo To completely remove:
echo   1. Delete this folder: %CD%
echo   2. Uninstall Ollama (if not needed)
echo   3. Uninstall PostgreSQL (if not needed)
echo.
echo Thank you for using Aerospace RAG!
echo.
pause
exit /b 0

:cancel
echo.
echo Uninstall cancelled.
echo.
pause
exit /b 0

:end
echo.
pause
exit /b 0
