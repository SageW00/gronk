@echo off
REM Install pgvector extension for PostgreSQL on Windows

title Install pgvector for PostgreSQL

echo =========================================
echo   PostgreSQL pgvector Installation
echo =========================================
echo.
echo This script will help you install the pgvector extension.
echo.

REM Check if PostgreSQL is installed
psql --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: PostgreSQL is not installed or not in PATH
    echo Please install PostgreSQL first
    pause
    exit /b 1
)

echo Detected PostgreSQL installation
psql --version
echo.

echo =========================================
echo   Installation Methods
echo =========================================
echo.
echo   [1] Automatic Installation (via SQL - Recommended)
echo   [2] Download prebuilt binaries from GitHub
echo   [3] Use PostgreSQL Stack Builder
echo   [4] Show manual installation instructions
echo   [5] Cancel
echo.
set /p choice="Choose installation method (1-5): "

if "%choice%"=="1" goto auto_install
if "%choice%"=="2" goto download_binaries
if "%choice%"=="3" goto stack_builder
if "%choice%"=="4" goto manual_instructions
if "%choice%"=="5" goto cancel
goto menu

:auto_install
cls
echo =========================================
echo   Automatic Installation
echo =========================================
echo.
echo Attempting to create pgvector extension in the database...
echo.

REM Try to create the extension
psql -U postgres -p 5432 -d AEROSPACE -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>temp_error.txt

if errorlevel 1 (
    echo.
    echo Installation failed. The extension files are not installed on the system.
    echo.
    type temp_error.txt
    del temp_error.txt
    echo.
    echo You need to install pgvector files first. Choose option 2 or 3.
    pause
    goto menu
) else (
    del temp_error.txt 2>nul
    echo.
    echo ========================================
    echo   SUCCESS!
    echo ========================================
    echo.
    echo pgvector extension has been created successfully!
    echo.
    echo You can now run the application setup.
    echo.
    pause
    exit /b 0
)

:download_binaries
cls
echo =========================================
echo   Download Prebuilt Binaries
echo =========================================
echo.
echo Steps to install pgvector:
echo.
echo 1. Go to: https://github.com/pgvector/pgvector/releases
echo.
echo 2. Download the latest release for Windows
echo    Look for: pgvector-X.X.X-postgres-XX-windows-x64.zip
echo.
echo 3. Extract the ZIP file
echo.
echo 4. Copy the files to your PostgreSQL installation:
echo    - Copy vector.dll to: C:\Program Files\PostgreSQL\18\lib\
echo    - Copy vector.control to: C:\Program Files\PostgreSQL\18\share\extension\
echo    - Copy vector--*.sql to: C:\Program Files\PostgreSQL\18\share\extension\
echo.
echo 5. Restart PostgreSQL service:
echo    - Open Services (Win + R, type services.msc)
echo    - Find "postgresql-x64-18"
echo    - Right-click and "Restart"
echo.
echo 6. Run this script again and choose option 1
echo.
echo Opening GitHub releases page in your browser...
start https://github.com/pgvector/pgvector/releases
echo.
pause
goto menu

:stack_builder
cls
echo =========================================
echo   PostgreSQL Stack Builder
echo =========================================
echo.
echo Stack Builder is included with PostgreSQL installation.
echo.
echo Steps:
echo.
echo 1. Find Stack Builder in your Start Menu
echo    Search for "Stack Builder" or "PostgreSQL Stack Builder"
echo.
echo 2. Launch Stack Builder
echo.
echo 3. Select your PostgreSQL installation
echo.
echo 4. Look for "pgvector" in the list of available extensions
echo.
echo 5. Select and install it
echo.
echo 6. Run this script again and choose option 1
echo.
echo Note: If pgvector is not available in Stack Builder,
echo       use option 2 to download prebuilt binaries.
echo.
pause
goto menu

:manual_instructions
cls
echo =========================================
echo   Manual Installation Instructions
echo =========================================
echo.
echo For Windows PostgreSQL 18:
echo.
echo Method 1: Using prebuilt binaries (Easiest)
echo ------------------------------------------
echo 1. Download from: https://github.com/pgvector/pgvector/releases
echo 2. Extract the ZIP file
echo 3. Copy files to PostgreSQL directories:
echo    vector.dll           -^> C:\Program Files\PostgreSQL\18\lib\
echo    vector.control       -^> C:\Program Files\PostgreSQL\18\share\extension\
echo    vector--*.sql files  -^> C:\Program Files\PostgreSQL\18\share\extension\
echo 4. Restart PostgreSQL service
echo 5. Run: psql -U postgres -d AEROSPACE -c "CREATE EXTENSION vector;"
echo.
echo Method 2: Building from source
echo -------------------------------
echo 1. Install Visual Studio Build Tools
echo 2. Install Git
echo 3. Clone: git clone https://github.com/pgvector/pgvector.git
echo 4. Run: nmake /F Makefile.win
echo 5. Run: nmake /F Makefile.win install
echo.
echo Method 3: Using Stack Builder
echo ------------------------------
echo 1. Open PostgreSQL Stack Builder
echo 2. Select your PostgreSQL installation
echo 3. Find and install pgvector extension
echo.
echo After installation, test with:
echo   psql -U postgres -p 5432 -d AEROSPACE -c "CREATE EXTENSION vector;"
echo.
pause
goto menu

:cancel
echo.
echo Installation cancelled.
echo.
pause
exit /b 0

:menu
echo.
echo Press any key to return to menu...
pause >nul
cls
goto auto_install
