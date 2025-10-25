#!/bin/bash
# Migration script to fix vector dimensions from 384 to 768
# This script will update the database schema for embeddinggemma

echo "========================================"
echo "Vector Dimension Migration Tool"
echo "========================================"
echo ""
echo "This will update the database to support 768-dimensional vectors"
echo "for the embeddinggemma model."
echo ""
echo "⚠️  WARNING: This will delete all existing indexed documents!"
echo "You will need to re-index your PDFs after this."
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Migration cancelled."
    exit 0
fi

echo ""
echo "Connecting to PostgreSQL..."

# Drop existing documents table and recreate with correct dimensions
psql -U postgres -p 5432 -d AEROSPACE << 'EOF'

-- Drop the old table and index
DROP TABLE IF EXISTS documents CASCADE;

-- Recreate with 768 dimensions for embeddinggemma
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

-- Recreate index for vector similarity search
CREATE INDEX documents_embedding_idx
ON documents USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Recreate index for course lookups
CREATE INDEX documents_course_idx
ON documents (course_code);

-- Keep courses table (no changes needed)
CREATE TABLE IF NOT EXISTS courses (
    id SERIAL PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(200) NOT NULL,
    description TEXT,
    document_count INTEGER DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

\echo ''
\echo '=========================================='
\echo 'Migration completed successfully!'
\echo '=========================================='
\echo ''
\echo 'Database now supports 768-dimensional vectors.'
\echo ''
\echo 'Next steps:'
\echo '1. Index your documents: python3 run_cli.py index'
\echo '2. Start using the app!'
\echo ''

EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Migration successful!"
    echo ""
    echo "Next steps:"
    echo "  1. Re-index your documents:"
    echo "     python3 run_cli.py index"
    echo ""
    echo "  2. Start querying:"
    echo "     python3 run_cli.py interactive"
    echo ""
else
    echo ""
    echo "❌ Migration failed!"
    echo "Please check the error messages above."
    echo ""
fi
