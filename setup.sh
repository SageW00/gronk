#!/bin/bash
# Setup script for Aerospace RAG application

set -e

echo "========================================="
echo "Aerospace RAG Application Setup"
echo "========================================="
echo ""

# Check Python version
echo "Checking Python version..."
python_version=$(python3 --version 2>&1 | awk '{print $2}')
echo "Python version: $python_version"
echo ""

# Check if PostgreSQL is running
echo "Checking PostgreSQL..."
if pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "✓ PostgreSQL is running on port 5432"
else
    echo "✗ PostgreSQL is not running on port 5432"
    echo "  Please start PostgreSQL and ensure it's configured correctly"
    exit 1
fi
echo ""

# Check if Ollama is running
echo "Checking Ollama..."
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "✓ Ollama is running"
else
    echo "✗ Ollama is not running"
    echo "  Please start Ollama: ollama serve"
    exit 1
fi
echo ""

# Check and pull required Ollama models
echo "Checking required Ollama models..."
echo ""

# Check text generation model (gemma3:1b)
echo "[1/2] Checking text generation model (gemma3:1b)..."
if curl -s http://localhost:11434/api/tags | grep -q "gemma3:1b"; then
    echo "✓ gemma3:1b model is available"
else
    echo "! gemma3:1b model not found"
    echo "  Pulling model (this may take a few minutes)..."
    ollama pull gemma3:1b
    echo "✓ gemma3:1b model pulled successfully"
fi
echo ""

# Check embedding model (embeddinggemma)
echo "[2/2] Checking embedding model (embeddinggemma)..."
if curl -s http://localhost:11434/api/tags | grep -q "embeddinggemma"; then
    echo "✓ embeddinggemma model is available"
else
    echo "! embeddinggemma model not found"
    echo "  Pulling model (this may take a few minutes)..."
    ollama pull embeddinggemma
    echo "✓ embeddinggemma model pulled successfully"
fi
echo ""

# Create virtual environment
echo "Creating virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✓ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi
echo ""

# Activate virtual environment and install dependencies
echo "Installing dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
echo "✓ Dependencies installed"
echo ""

# Make scripts executable
chmod +x run_cli.py
chmod +x run_gui.py
chmod +x setup.sh
chmod +x install_pgvector.sh
chmod +x uninstall.sh
echo "✓ Scripts made executable"
echo ""

# Check for pgvector extension
echo "Checking for pgvector extension..."
if psql -U postgres -p 5432 -d AEROSPACE -c "SELECT * FROM pg_extension WHERE extname='vector';" > /dev/null 2>&1; then
    echo "✓ pgvector extension is installed"
else
    echo ""
    echo "! WARNING: pgvector extension may not be installed"
    echo ""
    read -p "Would you like to install pgvector now? (y/n): " install_pgvector
    if [[ "$install_pgvector" =~ ^[Yy]$ ]]; then
        ./install_pgvector.sh
    else
        echo ""
        echo "Skipping pgvector installation."
        echo "You can install it later by running: ./install_pgvector.sh"
        echo ""
    fi
fi
echo ""

# Initialize database
echo "Initializing database..."
if ! python3 run_cli.py init; then
    echo ""
    echo "========================================="
    echo "  DATABASE INITIALIZATION FAILED"
    echo "========================================="
    echo ""
    echo "If you see a pgvector error, run:"
    echo "  ./install_pgvector.sh"
    echo ""
    echo "Then run setup again."
    echo ""
    exit 1
fi
echo ""

echo "========================================="
echo "Setup completed successfully!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Place your PDF files in:"
echo "     - data/coursenotes/<course_code>/"
echo "     - data/textbook/<course_code>/"
echo ""
echo "  2. Index your documents:"
echo "     python3 run_cli.py index"
echo ""
echo "  3. Start using the application:"
echo "     CLI: python3 run_cli.py interactive"
echo "     GUI: python3 run_gui.py"
echo ""
