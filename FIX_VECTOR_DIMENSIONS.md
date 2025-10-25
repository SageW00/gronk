# Fixing Vector Dimension Mismatch Error

## The Problem

If you see this error:
```
✗ Error: Query failed: Similarity search failed: different vector dimensions 384 and 768
```

This means your database was created with the wrong vector dimensions for the `embeddinggemma` model.

### Why This Happens

- **Old schema**: Database created with 384 dimensions (old default)
- **New model**: embeddinggemma produces 768-dimensional vectors
- **Mismatch**: Can't search 768-dim vectors in 384-dim database

---

## The Solution (Quick Fix)

### Option 1: Automatic Migration (Recommended)

I've created migration scripts that will fix this automatically:

**Linux/Mac:**
```bash
./migrate_vector_dimensions.sh
```

**Windows:**
```cmd
migrate_vector_dimensions.bat
```

This will:
1. ✅ Drop the old documents table (384 dimensions)
2. ✅ Recreate it with 768 dimensions
3. ✅ Rebuild indexes
4. ⚠️ **Delete all existing indexed documents** (you'll need to re-index)

### Option 2: Manual SQL Fix

If you prefer to do it manually:

```bash
# Connect to database
psql -U postgres -p 5432 -d AEROSPACE

# Run these commands:
DROP TABLE IF EXISTS documents CASCADE;

CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL,
    course_name VARCHAR(200) NOT NULL,
    content_type VARCHAR(50) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    chunk_text TEXT NOT NULL,
    chunk_index INTEGER NOT NULL,
    page_number INTEGER,
    embedding vector(768),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX documents_embedding_idx
ON documents USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

CREATE INDEX documents_course_idx
ON documents (course_code);

\q
```

---

## After Migration

Once the database is fixed, you need to re-index your documents:

### Step 1: Re-index Documents

**Index all courses:**
```bash
python3 run_cli.py index
```

**Or index specific course:**
```bash
python3 run_cli.py index --course 16.100
```

### Step 2: Verify It Works

```bash
# Test a query
python3 run_cli.py query "What is aerodynamics?"

# Or use interactive mode
python3 run_cli.py interactive
```

You should see results without any dimension errors!

---

## Understanding Vector Dimensions

Different embedding models produce different vector sizes:

| Model | Dimensions | Best For |
|-------|-----------|----------|
| embeddinggemma | 768 | Semantic search (current) |
| nomic-embed-text | 768 | Semantic search |
| all-MiniLM-L6-v2 | 384 | Fast, lightweight |
| gemma3:1b | Varies | Text generation (not for embeddings!) |

**Why 768?**
- embeddinggemma is optimized for 768 dimensions
- Better semantic understanding
- Industry standard for many embedding models

---

## Preventing This in the Future

The latest version of the code (after this fix) automatically uses 768 dimensions.

If you're setting up fresh:
1. ✅ Pull latest code
2. ✅ Run `./setup.sh` or `setup_windows.bat`
3. ✅ Database will be created with correct dimensions

---

## FAQ

### Q: Will I lose my indexed documents?
**A:** Yes, you need to re-index after migration. Your PDFs are safe, just run indexing again.

### Q: How long does re-indexing take?
**A:** ~1-2 minutes per 100 PDF pages. Plan accordingly.

### Q: Can I avoid re-indexing?
**A:** No, old embeddings are 384-dim and incompatible with new 768-dim system.

### Q: What if I want to use a different model?
**A:** Edit `config/config.yaml` and change `embedding_model`, then ensure database dimensions match that model's output.

### Q: How do I check current dimension in database?
```sql
psql -U postgres -p 5432 -d AEROSPACE -c "SELECT atttypmod FROM pg_attribute WHERE attrelid = 'documents'::regclass AND attname = 'embedding';"
```
Output should be: `772` (which is 768 + 4 for metadata)

---

## Step-by-Step Full Reset

If you want a completely fresh start:

### 1. Stop Everything
```bash
# Stop Ollama
pkill ollama  # or Ctrl+C in ollama serve window
```

### 2. Reset Database
```bash
# Run migration
./migrate_vector_dimensions.sh  # Linux/Mac
# or
migrate_vector_dimensions.bat  # Windows
```

### 3. Verify Models
```bash
ollama list
# Should show:
#   gemma3:1b
#   embeddinggemma
```

### 4. Restart Ollama
```bash
ollama serve
```

### 5. Re-index Documents
```bash
python3 run_cli.py index
```

### 6. Test
```bash
python3 run_cli.py query "test query"
```

✅ Should work without errors!

---

## Technical Details

### Old Schema (384 dimensions):
```sql
embedding vector(384)
```

### New Schema (768 dimensions):
```sql
embedding vector(768)
```

### Why CREATE TABLE IF NOT EXISTS Didn't Prevent This:
- The table existed (created during first setup)
- `IF NOT EXISTS` doesn't check column definitions
- Old 384-dim table stayed, but new embeddings were 768-dim
- Caused mismatch error during queries

---

## Still Having Issues?

1. **Check Ollama is running:**
   ```bash
   curl http://localhost:11434/api/tags
   ```

2. **Verify models are pulled:**
   ```bash
   ollama list
   ```

3. **Check database connection:**
   ```bash
   pg_isready -h localhost -p 5432
   ```

4. **Run diagnostics:**
   ```bash
   ./diagnose_ollama.sh  # or .bat on Windows
   ```

5. **Check vector dimension:**
   ```bash
   psql -U postgres -p 5432 -d AEROSPACE -c "\d+ documents"
   # Look for: embedding | vector(768)
   ```

---

## Need More Help?

- ✅ See [OLLAMA_SETUP_GUIDE.md](OLLAMA_SETUP_GUIDE.md) for Ollama setup
- ✅ See [README.md](README.md) for general documentation
- ✅ Run `./diagnose_ollama.sh` to check system health

---

**Last Updated:** After fixing vector dimension mismatch
**Status:** ✅ Fixed - Database now uses 768 dimensions
