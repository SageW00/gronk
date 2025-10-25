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

# Check if gemma3:1b model is available
echo "Checking for gemma3:1b model..."
if curl -s http://localhost:11434/api/tags | grep -q "gemma3:1b"; then
    echo "✓ gemma3:1b model is available"
else
    echo "! gemma3:1b model not found"
    echo "  Pulling model (this may take a while)..."
    ollama pull gemma3:1b
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
echo "✓ Scripts made executable"
echo ""

# Initialize database
echo "Initializing database..."
python3 run_cli.py init
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
