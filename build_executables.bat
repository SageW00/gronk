@echo off
REM Build Windows executables for Aerospace RAG Application

echo =========================================
echo Building Aerospace RAG Executables
echo =========================================
echo.

REM Activate virtual environment
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo ERROR: Virtual environment not found
    echo Please run setup_windows.bat first
    pause
    exit /b 1
)

REM Ensure required packages are installed
echo Checking required packages...
pip show pyinstaller >nul 2>&1
if errorlevel 1 (
    echo Installing PyInstaller...
    pip install pyinstaller
)

pip show pillow >nul 2>&1
if errorlevel 1 (
    echo Installing Pillow (for icon generation)...
    pip install pillow
)
echo.

REM Create application icon
echo =========================================
echo Creating application icon...
echo =========================================
python aerospace_rag/utils/create_icon.py
if errorlevel 1 (
    echo Warning: Icon creation failed, continuing without icon
)
echo.

REM Create dist directory if it doesn't exist
if not exist "dist" mkdir dist

REM Build CLI executable
echo =========================================
echo Building CLI executable...
echo =========================================
pyinstaller --clean --noconfirm aerospace_rag_cli.spec
if errorlevel 1 (
    echo ERROR: CLI build failed
    pause
    exit /b 1
)
echo CLI executable created: dist\AerospaceRAG-CLI.exe
echo.

REM Build GUI executable
echo =========================================
echo Building GUI executable...
echo =========================================
pyinstaller --clean --noconfirm aerospace_rag_gui.spec
if errorlevel 1 (
    echo ERROR: GUI build failed
    pause
    exit /b 1
)
echo GUI executable created: dist\"Aerospace RAG Assistant.exe"
echo.

REM Copy config and data directories to dist
echo Copying configuration and data directories...
if not exist "dist\config" mkdir dist\config
copy /Y config\config.yaml dist\config\config.yaml >nul
if not exist "dist\data" mkdir dist\data
if not exist "dist\data\coursenotes" mkdir dist\data\coursenotes
if not exist "dist\data\textbook" mkdir dist\data\textbook
echo.

REM Create README in dist
echo Creating README in dist folder...
(
echo Aerospace RAG Application - Windows Executables
echo.
echo Contents:
echo   - AerospaceRAG-CLI.exe: Command-line interface
echo   - AerospaceRAG-GUI.exe: Graphical user interface
echo   - config\config.yaml: Configuration file
echo   - data\: Place your PDF files here
echo.
echo Quick Start:
echo   1. Ensure PostgreSQL 16/18 is running on port 5432
echo   2. Ensure Ollama is running with required models:
echo      - ollama pull gemma3:1b (text generation)
echo      - ollama pull embeddinggemma (embeddings)
echo   3. Double-click AerospaceRAG-GUI.exe to launch the GUI
echo   4. Or run AerospaceRAG-CLI.exe from command prompt
echo.
echo For detailed instructions, see the main README.md
) > dist\README.txt
echo.

REM Create desktop shortcut helper script
echo Creating desktop shortcut helper...
(
echo @echo off
echo REM Desktop Shortcut Creator for Aerospace RAG
echo.
echo set SCRIPT=%%TEMP%%\CreateShortcut.vbs
echo set DESKTOP=%%USERPROFILE%%\Desktop
echo set TARGET=%%~dp0Aerospace RAG Assistant.exe
echo.
echo ^(
echo   echo Set oWS = WScript.CreateObject^("WScript.Shell"^)
echo   echo sLinkFile = "%%DESKTOP%%\Aerospace RAG Assistant.lnk"
echo   echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
echo   echo oLink.TargetPath = "%%TARGET%%"
echo   echo oLink.WorkingDirectory = "%%~dp0"
echo   echo oLink.Description = "AI-Powered Aerospace Learning Assistant"
echo   echo oLink.Save
echo ^) ^> %%SCRIPT%%
echo.
echo cscript //nologo %%SCRIPT%%
echo del %%SCRIPT%%
echo.
echo echo.
echo echo Desktop shortcut created successfully!
echo echo You can now launch Aerospace RAG from your desktop.
echo pause
) > dist\Create_Desktop_Shortcut.bat
echo.

echo =========================================
echo Build completed successfully!
echo =========================================
echo.
echo Executables created in 'dist' folder:
echo   - Aerospace RAG Assistant.exe  (Main GUI application)
echo   - AerospaceRAG-CLI.exe         (Command-line interface)
echo   - Create_Desktop_Shortcut.bat  (Creates desktop shortcut)
echo.
echo To create a desktop shortcut:
echo   1. Go to the 'dist' folder
echo   2. Double-click "Create_Desktop_Shortcut.bat"
echo   3. Launch from desktop icon!
echo.
echo You can now:
echo   1. Copy the 'dist' folder to any Windows computer
echo   2. Run Create_Desktop_Shortcut.bat
echo   3. Double-click the desktop icon to launch
echo.
echo Note: You still need PostgreSQL and Ollama running
echo       on the target machine with both models installed:
echo       - gemma3:1b (text generation)
echo       - embeddinggemma (embeddings)
echo.
pause
