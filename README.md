# Aerospace RAG Application

An AI-powered Retrieval-Augmented Generation (RAG) system for aerospace engineering education. This application uses Ollama (gemma3:1b), PostgreSQL with pgvector, and PDF parsing to create an intelligent assistant for MIT OCW aerospace course materials.

## 🪟 Windows Users - Quick Start!

**For Windows 11 users wanting executable (.exe) files:**

1. **Double-click `START_HERE.bat`** - This gives you a menu to setup and run everything
2. Or see **[WINDOWS_GUIDE.md](WINDOWS_GUIDE.md)** for complete Windows instructions
3. Or run **`setup_windows.bat`** → **`build_executables.bat`** to create .exe files

The build process creates:
- `AerospaceRAG-GUI.exe` - Double-click to launch the graphical interface
- `AerospaceRAG-CLI.exe` - Command-line interface

**All files are in the `dist\` folder after building!**

---

## Features

- **AI-Powered Question Answering**: Get intelligent answers to aerospace engineering questions
- **RAG System**: Retrieves relevant context from course materials before generating responses
- **Multiple Interfaces**: Both CLI and GUI for different use cases
- **Course Organization**: Supports 11 MIT OCW aerospace courses
- **PDF Processing**: Automatically parses and indexes PDF course materials
- **Vector Search**: Uses pgvector for efficient semantic similarity search
- **Source Citations**: Always shows which course materials were used to generate answers

## Supported Courses

- **2.29**: Numerical Fluid Mechanics
- **16.01**: Unified Engineering I
- **16.02**: Unified Engineering II
- **16.07**: Dynamics
- **16.13**: Aerodynamics of Viscous Fluids
- **16.20**: Structural Mechanics
- **16.50**: Introduction to Propulsion Systems
- **16.100**: Aerodynamics
- **16.121**: Analytical Subsonic Aerodynamics
- **16.333**: Aircraft Stability and Control
- **16.346**: Astrodynamics

## Prerequisites

### Required Software

1. **Python 3.8+**
   ```bash
   python3 --version
   ```

2. **PostgreSQL 16** (with pgvector extension)
   - Host: localhost
   - Port: 5433
   - Database: AEROSPACE
   - User: postgres
   - Password: sagewoo

3. **Ollama** (with gemma3:1b model)
   ```bash
   # Install Ollama
   curl -fsSL https://ollama.com/install.sh | sh

   # Start Ollama
   ollama serve

   # Pull the model (in another terminal)
   ollama pull gemma3:1b
   ```

## Installation

### Quick Setup (Recommended)

```bash
# Clone the repository
git clone <repository-url>
cd gronk

# Run the setup script
./setup.sh
```

The setup script will:
- Check system prerequisites
- Create a virtual environment
- Install Python dependencies
- Initialize the database schema
- Verify Ollama and PostgreSQL connections

### Manual Setup

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Initialize database
python3 run_cli.py init
```

## Usage

### 1. Organize Your PDFs

Place your course PDFs in the following structure:

```
data/
├── coursenotes/
│   ├── 2.29/
│   │   └── lecture_notes.pdf
│   ├── 16.01/
│   │   └── notes.pdf
│   └── ...
└── textbook/
    ├── 2.29/
    │   └── textbook.pdf
    ├── 16.01/
    │   └── textbook.pdf
    └── ...
```

### 2. Index Documents

```bash
# Index all courses
python3 run_cli.py index

# Index specific course
python3 run_cli.py index --course 16.01
```

This process:
- Extracts text from PDFs
- Splits text into chunks
- Generates embeddings using Ollama
- Stores in PostgreSQL with vector search capabilities

### 3. Query the System

#### CLI Interface

**Interactive Mode** (Recommended for exploration):
```bash
python3 run_cli.py interactive
```

**Single Query**:
```bash
python3 run_cli.py query "Explain the Bernoulli equation in aerodynamics"
```

**Filter by Course**:
```bash
python3 run_cli.py query "What is lift?" --course 16.100
```

**Adjust Source Count**:
```bash
python3 run_cli.py query "Explain thrust" --top-k 10
```

#### GUI Interface

```bash
python3 run_gui.py
```

The GUI provides:
- Modern dark theme interface
- Real-time query processing
- Source visualization
- Course filtering
- Adjustable retrieval parameters
- Chat history

### CLI Commands Reference

```bash
# Initialize system
python3 run_cli.py init

# Index documents
python3 run_cli.py index [--course COURSE_CODE]

# Query system
python3 run_cli.py query "your question" [--course CODE] [--top-k N]

# Interactive mode
python3 run_cli.py interactive [--course CODE]

# View statistics
python3 run_cli.py stats

# List all courses
python3 run_cli.py courses

# Test system connectivity
python3 run_cli.py test
```

## Project Structure

```
gronk/
├── aerospace_rag/           # Main application package
│   ├── core/                # Core modules
│   │   ├── config.py        # Configuration management
│   │   ├── database.py      # PostgreSQL + pgvector operations
│   │   ├── ollama_client.py # Ollama API integration
│   │   ├── pdf_parser.py    # PDF parsing and chunking
│   │   └── rag_engine.py    # Main RAG logic
│   ├── cli/                 # Command-line interface
│   │   └── cli_app.py       # CLI application
│   └── gui/                 # Graphical user interface
│       └── gui_app.py       # GUI application
├── config/                  # Configuration files
│   └── config.yaml          # Main configuration
├── data/                    # Data directory
│   ├── coursenotes/         # Course notes PDFs
│   └── textbook/            # Textbook PDFs
├── requirements.txt         # Python dependencies
├── setup.py                 # Package setup
├── setup.sh                 # Setup script
├── run_cli.py               # CLI entry point
├── run_gui.py               # GUI entry point
└── README.md                # This file
```

## Configuration

Edit `config/config.yaml` to customize:

```yaml
database:
  host: localhost
  port: 5433
  user: postgres
  password: sagewoo
  database: AEROSPACE

ollama:
  base_url: http://localhost:11434
  model: gemma3:1b
  temperature: 0.7
  max_tokens: 2048

rag:
  chunk_size: 512
  chunk_overlap: 100
  top_k: 5
  similarity_threshold: 0.7
```

## How It Works

1. **Document Ingestion**:
   - PDFs are parsed using PyPDF2 and pdfplumber
   - Text is cleaned and split into overlapping chunks
   - Each chunk is embedded using Ollama's gemma3:1b model

2. **Vector Storage**:
   - Embeddings are stored in PostgreSQL with pgvector extension
   - Indexed for fast cosine similarity search
   - Metadata includes course info, file name, page number

3. **Query Processing**:
   - User question is embedded using the same model
   - Vector similarity search retrieves top-k relevant chunks
   - Retrieved context is provided to the LLM

4. **Answer Generation**:
   - Ollama generates response using retrieved context
   - System prompt guides the model to be an aerospace expert
   - Sources are cited with full metadata

## Troubleshooting

### PostgreSQL Connection Issues

```bash
# Check if PostgreSQL is running
pg_isready -h localhost -p 5433

# Test connection
psql -h localhost -p 5433 -U postgres -d AEROSPACE
```

### Ollama Issues

```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Restart Ollama
pkill ollama
ollama serve

# Re-pull model if needed
ollama pull gemma3:1b
```

### pgvector Extension

If you get "extension vector does not exist":

```sql
-- Connect to database
psql -h localhost -p 5433 -U postgres -d AEROSPACE

-- Install extension
CREATE EXTENSION vector;
```

### No PDFs Found

Ensure your PDFs are in the correct structure:
```
data/coursenotes/<course_code>/*.pdf
data/textbook/<course_code>/*.pdf
```

## Performance Tips

1. **Indexing**: Index documents in batches by course to manage memory
2. **Query Speed**: Lower `top_k` for faster queries (3-5 is usually sufficient)
3. **Chunk Size**: Adjust `chunk_size` in config for better context (512-1024 recommended)
4. **Model**: gemma3:1b is fast and efficient; upgrade to larger models for better accuracy

## Development

### Running Tests

```bash
# Test system connectivity
python3 run_cli.py test
```

### Adding New Courses

1. Add course to `config/config.yaml`:
```yaml
courses:
  "XX.XXX": "Course Name"
```

2. Create data directories:
```bash
mkdir -p data/coursenotes/XX.XXX
mkdir -p data/textbook/XX.XXX
```

3. Add PDFs and index:
```bash
python3 run_cli.py index --course XX.XXX
```

## Technical Details

- **Embeddings**: 384-dimensional vectors from gemma3:1b
- **Similarity**: Cosine similarity with pgvector's `<=>` operator
- **Chunking**: Sentence-based with configurable overlap
- **Database**: PostgreSQL 16 with ivfflat index for vector search

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome! Please submit pull requests or open issues for bugs and feature requests.

## Acknowledgments

- MIT OpenCourseWare for aerospace course materials
- Ollama for local LLM inference
- pgvector for PostgreSQL vector operations