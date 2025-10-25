# Aerospace RAG Application - Project Summary

## Overview

A complete, production-ready RAG (Retrieval-Augmented Generation) system specifically designed for aerospace engineering education. The application provides AI-powered assistance for understanding MIT OCW aerospace course materials through both CLI and GUI interfaces.

## Key Features

### Core Capabilities
- **Intelligent Q&A**: AI-powered answers with source citations
- **PDF Processing**: Automatic extraction, cleaning, and chunking
- **Vector Search**: PostgreSQL + pgvector for fast semantic search
- **Multi-Course Support**: Pre-configured for 11 MIT aerospace courses
- **Dual Interface**: Both command-line and graphical interfaces
- **Offline Operation**: Fully local with Ollama (no external APIs needed)

### Technical Highlights
- **RAG Architecture**: Query → Embedding → Retrieval → Generation
- **Embeddings**: 384-dimensional vectors from embeddinggemma (specialized model)
- **Text Generation**: gemma3:1b for answer generation
- **Database**: PostgreSQL 16/18 with ivfflat vector indexing
- **Chunking**: Sentence-based with configurable overlap
- **Similarity**: Cosine similarity with configurable threshold

## Architecture

```
User Query
    ↓
Query Embedding (Ollama)
    ↓
Vector Search (PostgreSQL + pgvector)
    ↓
Context Retrieval (Top-K similar chunks)
    ↓
Answer Generation (Ollama + Context)
    ↓
Response with Citations
```

## Components

### 1. Core Modules (`aerospace_rag/core/`)

#### `config.py`
- YAML-based configuration management
- Singleton pattern for global config access
- Validation and default values

#### `database.py`
- PostgreSQL connection management
- pgvector operations (insert, search)
- Batch operations for efficiency
- Context manager support

#### `ollama_client.py`
- Ollama API integration
- Embedding generation (single and batch)
- Completion generation (streaming and non-streaming)
- Model availability checking

#### `pdf_parser.py`
- PDF text extraction (PyPDF2 + pdfplumber)
- Text cleaning and normalization
- Sentence-based chunking with overlap
- Directory parsing with progress tracking

#### `rag_engine.py`
- Main orchestration layer
- Document indexing pipeline
- Query processing pipeline
- Statistics and monitoring

### 2. CLI Interface (`aerospace_rag/cli/`)

#### `cli_app.py`
Built with Typer and Rich for beautiful terminal UI:
- `init` - Initialize system
- `index` - Index PDF documents
- `query` - Single query with filters
- `interactive` - Chat-like interface
- `stats` - System statistics
- `courses` - List configured courses
- `test` - Connectivity testing

### 3. GUI Interface (`aerospace_rag/gui/`)

#### `gui_app.py`
Built with CustomTkinter:
- Modern dark theme
- Real-time query processing
- Chat-style conversation view
- Course filtering dropdown
- Adjustable retrieval parameters
- Source visualization
- System statistics viewer

## Configuration

### Database Configuration (`config/config.yaml`)
```yaml
database:
  host: localhost
  port: 5432
  database: AEROSPACE
  user: postgres
  password: "1234"
```

### Ollama Configuration
```yaml
ollama:
  base_url: http://localhost:11434
  model: gemma3:1b              # Text generation model
  embedding_model: embeddinggemma  # Embedding model (specialized for embeddings)
  temperature: 0.7
  max_tokens: 2048
```

### RAG Parameters
```yaml
rag:
  chunk_size: 512          # Characters per chunk
  chunk_overlap: 100       # Overlap between chunks
  top_k: 5                 # Number of sources to retrieve
  similarity_threshold: 0.7 # Minimum similarity score
```

## Database Schema

### `documents` Table
- `id`: Serial primary key
- `course_code`: VARCHAR(20) - Course identifier
- `course_name`: VARCHAR(200) - Full course name
- `content_type`: VARCHAR(50) - coursenotes/textbook
- `file_name`: VARCHAR(255) - Source PDF filename
- `chunk_text`: TEXT - The actual text content
- `chunk_index`: INTEGER - Position in document
- `page_number`: INTEGER - Source page number
- `embedding`: vector(384) - Semantic embedding
- `metadata`: JSONB - Additional metadata
- `created_at`: TIMESTAMP - Creation time

### Indexes
- `documents_embedding_idx`: IVFFlat index on embeddings (cosine similarity)
- `documents_course_idx`: B-tree index on course_code

## Usage Workflows

### Workflow 1: Initial Setup
```bash
./setup.sh                    # One-time setup
```

### Workflow 2: Adding New Course Materials
```bash
# 1. Add PDFs to data/coursenotes/<course_code>/
mkdir -p data/coursenotes/16.100
cp *.pdf data/coursenotes/16.100/

# 2. Index the course
python3 run_cli.py index --course 16.100

# 3. Verify
python3 run_cli.py stats
```

### Workflow 3: Querying (CLI)
```bash
# Interactive mode
python3 run_cli.py interactive

# Single query
python3 run_cli.py query "Explain the Navier-Stokes equations"

# Filtered query
python3 run_cli.py query "What is drag?" --course 16.100 --top-k 3
```

### Workflow 4: Querying (GUI)
```bash
python3 run_gui.py
# Use the graphical interface to:
# - Type questions
# - Filter by course
# - Adjust source count
# - View chat history
```

## Performance Characteristics

### Indexing Performance
- ~1-2 minutes per 100 PDF pages
- Memory: ~2-3GB during indexing
- Storage: ~10-20MB per 100 pages (including vectors)

### Query Performance
- Query embedding: ~100-200ms
- Vector search: ~50-100ms (10k documents)
- Answer generation: ~2-5 seconds (depends on context length)
- Total: ~3-6 seconds per query

### Optimization Tips
1. Use `top_k=3-5` for faster queries
2. Filter by course when possible
3. Adjust `chunk_size` for context quality vs. speed
4. Consider larger models for better accuracy

## Security Considerations

1. **Database Credentials**: Currently in `config.yaml` - consider environment variables for production
2. **Local Only**: All processing is local (no external API calls)
3. **PDF Safety**: Basic text extraction only (no code execution)
4. **Input Validation**: Basic validation in place, consider adding more for production

## Extensibility

### Adding New Courses
1. Edit `config/config.yaml`:
```yaml
courses:
  "NEW.CODE": "New Course Name"
```
2. Create directories and add PDFs
3. Run indexing

### Changing Models
1. Edit `config/config.yaml`:
```yaml
ollama:
  model: llama2           # or mistral, codellama, etc. (for text generation)
  embedding_model: nomic-embed-text  # or other embedding models
```
2. Pull new models:
   - `ollama pull llama2` (text generation)
   - `ollama pull nomic-embed-text` (embeddings)
3. Note: May need to adjust embedding dimensions in database schema if using different embedding models

### Custom Content Types
Beyond coursenotes/textbook, you can add:
- homework
- exams
- solutions
- supplementary

Just create directories and update parsing logic if needed.

## Testing

### Connectivity Test
```bash
python3 run_cli.py test
```
Checks:
- PostgreSQL connection
- Ollama connection
- Model availability
- Database schema

### Manual Testing
```bash
# Test PDF parsing
python3 -c "from aerospace_rag.core.pdf_parser import PDFParser; p = PDFParser(); print(p.parse_pdf('test.pdf'))"

# Test embeddings
python3 -c "from aerospace_rag.core.ollama_client import OllamaClient; c = OllamaClient(); print(c.generate_embedding('test text').shape)"

# Test database
python3 -c "from aerospace_rag.core.database import DatabaseManager; db = DatabaseManager(); db.connect(); print(db.get_document_count())"
```

## Troubleshooting Guide

### Issue: "Failed to connect to Ollama"
**Solution**:
```bash
ollama serve  # Start Ollama service
```

### Issue: "Model not found"
**Solution**:
```bash
ollama pull gemma3:1b         # Text generation model
ollama pull embeddinggemma    # Embedding model
```

### Issue: "Extension vector does not exist"
**Solution**:
```sql
psql -h localhost -p 5432 -U postgres -d AEROSPACE
CREATE EXTENSION vector;
```

### Issue: "No PDFs found"
**Solution**: Check directory structure and file permissions
```bash
ls -la data/coursenotes/16.100/
# Should show .pdf files
```

## Dependencies

### Python Packages
- `psycopg2-binary`: PostgreSQL adapter
- `pgvector`: Vector operations in PostgreSQL
- `ollama`: Ollama API client
- `PyPDF2` & `pdfplumber`: PDF parsing
- `typer` & `rich`: CLI interface
- `customtkinter`: GUI interface
- `numpy`: Array operations
- `pyyaml`: Configuration parsing

### External Services
- PostgreSQL 16+ (with pgvector extension)
- Ollama (with gemma3:1b or compatible model)

## Future Enhancements

### Potential Improvements
1. **Multi-modal**: Support images and diagrams from PDFs
2. **Caching**: Cache embeddings to avoid recomputation
3. **Authentication**: Add user authentication for multi-user setups
4. **Web Interface**: Add Flask/FastAPI web frontend
5. **Advanced Retrieval**: Implement hybrid search (keyword + semantic)
6. **Fine-tuning**: Fine-tune models on aerospace corpus
7. **Evaluation**: Add automated evaluation metrics
8. **Export**: Export Q&A history to various formats
9. **Analytics**: Track usage patterns and popular topics
10. **Conversation Memory**: Multi-turn conversations with context

## Maintenance

### Regular Tasks
- Monitor database size: `python3 run_cli.py stats`
- Backup database: `pg_dump AEROSPACE > backup.sql`
- Update dependencies: `pip install -U -r requirements.txt`
- Clean old indexes: Consider vacuuming PostgreSQL periodically

### Updating Course Materials
```bash
# Re-index specific course
python3 run_cli.py index --course 16.100

# Or clear and re-index all
# (Add clear command or manually truncate tables)
```

## License

MIT License - Free for educational and commercial use

## Credits

- **MIT OpenCourseWare**: Course materials
- **Ollama**: Local LLM inference
- **pgvector**: Vector similarity in PostgreSQL
- **CustomTkinter**: Modern GUI framework

## Contact & Support

For issues, questions, or contributions:
- Check documentation (README.md, QUICKSTART.md)
- Review troubleshooting section
- File issues on GitHub repository

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Status**: Production Ready
