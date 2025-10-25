#!/bin/bash
# Automated script to push Aerospace RAG to your gronk3 repository
# Run this from the gronk3 folder on your laptop

echo "========================================"
echo "Push to gronk3 Repository"
echo "========================================"
echo ""

# Check if we're in the right directory
if [ ! -d "aerospace_rag" ]; then
    echo "ERROR: aerospace_rag folder not found!"
    echo "Please run this script from the gronk3 directory."
    echo ""
    exit 1
fi

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    git branch -M main
    echo ""
fi

# Configure git (update with your info if needed)
echo "Configuring git..."
git config user.name "SageW00"
git config user.email "your-email@example.com"
echo ""

# Add all files
echo "Adding all files to git..."
git add -A
echo ""

# Check if there are changes to commit
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "Committing changes..."
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
1. Run setup_windows.bat (Windows) or ./setup.sh (Linux/Mac)
2. Run migrate_vector_dimensions.bat/.sh
3. Launch with run_cli.bat/.sh or run_gui.bat/.sh

See README.md for complete documentation."
    echo ""
else
    echo "No changes to commit, files already committed."
    echo ""
fi

# Add remote if it doesn't exist
if ! git remote | grep -q "origin"; then
    echo "Adding gronk3 remote repository..."
    git remote add origin https://github.com/SageW00/gronk3.git
    echo ""
else
    echo "Setting gronk3 remote URL..."
    git remote set-url origin https://github.com/SageW00/gronk3.git
    echo ""
fi

# Push to GitHub
echo "========================================"
echo "Pushing to GitHub..."
echo "========================================"
echo ""
echo "Repository: https://github.com/SageW00/gronk3.git"
echo "Branch: main"
echo ""

git push -u origin main

if [ $? -ne 0 ]; then
    echo ""
    echo "========================================"
    echo "PUSH FAILED"
    echo "========================================"
    echo ""
    echo "This could be due to:"
    echo "  1. Authentication required (enter your GitHub credentials)"
    echo "  2. Branch conflicts (remote has different history)"
    echo "  3. Network issues"
    echo ""
    echo "To force push (overwrites remote):"
    echo "  git push -f origin main"
    echo ""
    echo "To pull and merge first:"
    echo "  git pull origin main --allow-unrelated-histories"
    echo "  git push origin main"
    echo ""
    exit 1
fi

echo ""
echo "========================================"
echo "SUCCESS!"
echo "========================================"
echo ""
echo "All files pushed to:"
echo "https://github.com/SageW00/gronk3"
echo ""
echo "You can now:"
echo "  1. Visit your repository on GitHub"
echo "  2. Clone it on other computers"
echo "  3. Share it with others"
echo ""
echo "Next steps:"
echo "  - Run setup_windows.bat (Windows) or ./setup.sh (Linux/Mac)"
echo "  - Run migrate_vector_dimensions script"
echo "  - Launch with run_cli or run_gui"
echo ""
