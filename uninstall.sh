#!/bin/bash
# Uninstall script for Aerospace RAG Application - Linux/Mac

set -e

echo "========================================="
echo "  AEROSPACE RAG APPLICATION"
echo "  Uninstaller"
echo "========================================="
echo ""
echo "This will remove the application files and data."
echo ""

# Function to display menu
show_menu() {
    echo "What would you like to remove?"
    echo ""
    echo "  [1] Remove everything (recommended for clean uninstall)"
    echo "  [2] Remove application only (keep data and database)"
    echo "  [3] Remove build files only (keep source and data)"
    echo "  [4] Cancel"
    echo ""
}

# Function to remove virtual environment
remove_venv() {
    if [ -d "venv" ]; then
        echo "Removing virtual environment..."
        rm -rf venv
        echo "  ✓ Virtual environment removed"
    fi
}

# Function to remove build files
remove_build() {
    if [ -d "dist" ]; then
        echo "Removing executables..."
        rm -rf dist
        echo "  ✓ Executables removed"
    fi

    if [ -d "build" ]; then
        rm -rf build
        echo "  ✓ Build folder removed"
    fi

    # Remove .spec files
    if ls *.spec 1> /dev/null 2>&1; then
        rm -f *.spec
        echo "  ✓ PyInstaller specs removed"
    fi
}

# Function to remove Python cache
remove_cache() {
    echo "Cleaning Python cache..."
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    echo "  ✓ Python cache cleaned"
}

# Function to remove data
remove_data() {
    if [ -d "data/coursenotes" ]; then
        rm -rf data/coursenotes/*
        touch data/coursenotes/.gitkeep
        echo "  ✓ Course notes removed"
    fi

    if [ -d "data/textbook" ]; then
        rm -rf data/textbook/*
        touch data/textbook/.gitkeep
        echo "  ✓ Textbook files removed"
    fi
}

# Function to drop database
drop_database() {
    echo ""
    echo "Dropping PostgreSQL database..."

    if command -v psql &> /dev/null; then
        psql -U postgres -p 5432 -c "DROP DATABASE IF EXISTS AEROSPACE;" 2>/dev/null && \
            echo "  ✓ Database dropped successfully" || \
            echo "  ! Could not drop database (you may need to do this manually)"
    else
        echo "  ! psql not found - database not dropped"
    fi
}

# Complete uninstall
remove_all() {
    clear
    echo "========================================="
    echo "  COMPLETE UNINSTALL"
    echo "========================================="
    echo ""
    echo "This will remove:"
    echo "  - Virtual environment (venv folder)"
    echo "  - Build files (dist, build folders)"
    echo "  - Python cache files (__pycache__)"
    echo "  - PDF data files"
    echo ""
    echo "WARNING: This will also DROP the PostgreSQL database!"
    echo ""
    read -p "Are you sure? Type 'YES' to confirm: " confirm

    if [ "$confirm" != "YES" ]; then
        echo "Uninstall cancelled."
        exit 0
    fi

    echo ""
    echo "Removing application files..."

    remove_venv
    remove_build
    remove_cache
    remove_data
    drop_database

    echo ""
    echo "========================================="
    echo "  UNINSTALL COMPLETE"
    echo "========================================="
    echo ""
    echo "All application files and data have been removed."
    echo ""
    echo "To completely remove:"
    echo "  1. Delete this folder: $(pwd)"
    echo "  2. Uninstall Ollama (if not needed)"
    echo "  3. Uninstall PostgreSQL (if not needed)"
    echo ""
    echo "Thank you for using Aerospace RAG!"
    echo ""
}

# Application-only uninstall
remove_app() {
    clear
    echo "========================================="
    echo "  APPLICATION UNINSTALL"
    echo "========================================="
    echo ""
    echo "This will remove:"
    echo "  - Virtual environment (venv folder)"
    echo "  - Build files (dist, build folders)"
    echo "  - Python cache files"
    echo ""
    echo "This will KEEP:"
    echo "  - Your PDF data files"
    echo "  - PostgreSQL database"
    echo "  - Source code"
    echo ""
    read -p "Continue? (y/n): " confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi

    echo ""
    echo "Removing application files..."

    remove_venv
    remove_build
    remove_cache

    echo ""
    echo "Application removed successfully!"
    echo "Your data files and database are preserved."
    echo ""
}

# Build files cleanup
cleanup_build() {
    clear
    echo "========================================="
    echo "  BUILD FILES CLEANUP"
    echo "========================================="
    echo ""
    echo "This will remove:"
    echo "  - Build files (dist, build folders)"
    echo "  - Python cache files"
    echo ""
    echo "This will KEEP:"
    echo "  - Virtual environment"
    echo "  - Source code"
    echo "  - PDF data"
    echo "  - Database"
    echo ""
    read -p "Continue? (y/n): " confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        exit 0
    fi

    echo ""
    echo "Cleaning build files..."

    remove_build
    remove_cache

    echo ""
    echo "Build files cleaned successfully!"
    echo "You can rebuild executables with: ./build_executables.sh"
    echo ""
}

# Main menu
show_menu
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        remove_all
        ;;
    2)
        remove_app
        ;;
    3)
        cleanup_build
        ;;
    4)
        echo ""
        echo "Uninstall cancelled."
        echo ""
        exit 0
        ;;
    *)
        echo ""
        echo "Invalid choice. Uninstall cancelled."
        echo ""
        exit 1
        ;;
esac
