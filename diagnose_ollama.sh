#!/bin/bash
# Ollama Diagnostic Script for Aerospace RAG
# This script checks if Ollama is set up correctly

echo "========================================"
echo "Ollama Setup Diagnostic Tool"
echo "========================================"
echo ""

ISSUES=0

# Check 1: Is Ollama installed?
echo "[1/6] Checking if Ollama is installed..."
if command -v ollama &> /dev/null; then
    VERSION=$(ollama --version 2>&1)
    echo "✅ PASS: Ollama is installed ($VERSION)"
else
    echo "❌ FAIL: Ollama is not installed"
    echo "   → Install from: https://ollama.com/download"
    ISSUES=$((ISSUES + 1))
fi
echo ""

# Check 2: Is Ollama running?
echo "[2/6] Checking if Ollama service is running..."
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "✅ PASS: Ollama service is running on port 11434"
else
    echo "❌ FAIL: Ollama service is not running"
    echo "   → Start it with: ollama serve"
    echo "   → Keep that terminal window open"
    ISSUES=$((ISSUES + 1))
fi
echo ""

# Check 3: Is gemma3:1b installed?
echo "[3/6] Checking for gemma3:1b model..."
if curl -s http://localhost:11434/api/tags 2>&1 | grep -q "gemma3:1b"; then
    echo "✅ PASS: gemma3:1b model is installed"
else
    echo "❌ FAIL: gemma3:1b model is not installed"
    echo "   → Install with: ollama pull gemma3:1b"
    echo "   → This will download ~2GB (takes 5-15 minutes)"
    ISSUES=$((ISSUES + 1))
fi
echo ""

# Check 4: Is embeddinggemma installed?
echo "[4/6] Checking for embeddinggemma model..."
if curl -s http://localhost:11434/api/tags 2>&1 | grep -q "embeddinggemma"; then
    echo "✅ PASS: embeddinggemma model is installed"
else
    echo "❌ FAIL: embeddinggemma model is not installed"
    echo "   → Install with: ollama pull embeddinggemma"
    echo "   → This will download ~300MB (takes 1-5 minutes)"
    ISSUES=$((ISSUES + 1))
fi
echo ""

# Check 5: Can we list models?
echo "[5/6] Listing all installed models..."
if command -v ollama &> /dev/null; then
    echo ""
    ollama list
    echo ""
else
    echo "⚠️  SKIP: Ollama not installed"
fi
echo ""

# Check 6: Test embedding generation
echo "[6/6] Testing embedding generation..."
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    if curl -s http://localhost:11434/api/tags 2>&1 | grep -q "embeddinggemma"; then
        echo "✅ PASS: Can generate embeddings"
    else
        echo "⚠️  SKIP: embeddinggemma not installed"
    fi
else
    echo "⚠️  SKIP: Ollama service not running"
fi
echo ""

# Summary
echo "========================================"
echo "DIAGNOSTIC SUMMARY"
echo "========================================"
echo ""

if [ $ISSUES -eq 0 ]; then
    echo "🎉 SUCCESS! Everything is set up correctly!"
    echo ""
    echo "You can now run:"
    echo "  ./setup.sh            # Set up Aerospace RAG"
    echo "  python3 run_cli.py    # Run the CLI"
    echo "  python3 run_gui.py    # Run the GUI"
    echo ""
else
    echo "⚠️  Found $ISSUES issue(s) that need to be fixed."
    echo ""
    echo "Quick Fix Commands:"
    echo ""

    if ! command -v ollama &> /dev/null; then
        echo "1. Install Ollama:"
        echo "   curl -fsSL https://ollama.com/install.sh | sh"
        echo ""
    fi

    if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "2. Start Ollama service:"
        echo "   ollama serve"
        echo "   (Keep this terminal open!)"
        echo ""
    fi

    if ! curl -s http://localhost:11434/api/tags 2>&1 | grep -q "gemma3:1b"; then
        echo "3. Pull gemma3:1b model:"
        echo "   ollama pull gemma3:1b"
        echo ""
    fi

    if ! curl -s http://localhost:11434/api/tags 2>&1 | grep -q "embeddinggemma"; then
        echo "4. Pull embeddinggemma model:"
        echo "   ollama pull embeddinggemma"
        echo ""
    fi

    echo "After fixing, run this diagnostic again:"
    echo "  ./diagnose_ollama.sh"
    echo ""
fi

echo "For detailed help, see: OLLAMA_SETUP_GUIDE.md"
echo ""
