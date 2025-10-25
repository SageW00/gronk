# PyInstaller spec file for Aerospace RAG GUI executable
# Creates a standalone Windows application with no console window

# -*- mode: python ; coding: utf-8 -*-

import os

block_cipher = None

# Check for icon file
icon_file = 'aerospace_rag_icon.ico'
if not os.path.exists(icon_file):
    print("⚠️  Warning: Icon file not found. Building without icon.")
    print("   Run: python aerospace_rag/utils/create_icon.py")
    icon_file = None

a = Analysis(
    ['run_gui.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('config/config.yaml', 'config'),
        ('aerospace_rag', 'aerospace_rag'),
    ],
    hiddenimports=[
        'psycopg2',
        'psycopg2._psycopg',
        'pgvector',
        'ollama',
        'customtkinter',
        'tkinter',
        'tkinter.ttk',
        'PyPDF2',
        'pdfplumber',
        'PIL',
        'PIL._imagingtk',
        'PIL._tkinter_finder',
        'numpy',
        'numpy.core._multiarray_umath',
        'yaml',
        'pkg_resources.py2_warn',
        'pkg_resources.markers',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'matplotlib',
        'scipy',
        'pandas',
        'jupyter',
        'notebook',
        'IPython',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='Aerospace RAG Assistant',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,  # No console window - pure GUI application
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=icon_file,
    uac_admin=False,  # Don't require admin
    uac_uiaccess=False,
    version='version_info.txt' if os.path.exists('version_info.txt') else None,
)
