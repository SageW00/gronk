@echo off
REM Migration script to fix vector dimensions from 384 to 768
REM This script will update the database schema for embeddinggemma

echo ========================================
echo Vector Dimension Migration Tool
echo ========================================
echo.
echo This will update the database to support 768-dimensional vectors
echo for the embeddinggemma model.
echo.
echo WARNING: This will delete all existing indexed documents!
echo You will need to re-index your PDFs after this.
echo.
set /p confirm="Continue? (yes/no): "

if /i not "%confirm%"=="yes" (
    echo Migration cancelled.
    exit /b 0
)

echo.
echo Connecting to PostgreSQL...
echo.

psql -U postgres -p 5432 -d AEROSPACE -c "DROP TABLE IF EXISTS documents CASCADE;"
psql -U postgres -p 5432 -d AEROSPACE -c "CREATE TABLE documents (id SERIAL PRIMARY KEY, course_code VARCHAR(20) NOT NULL, course_name VARCHAR(200) NOT NULL, content_type VARCHAR(50) NOT NULL, file_name VARCHAR(255) NOT NULL, chunk_text TEXT NOT NULL, chunk_index INTEGER NOT NULL, page_number INTEGER, embedding vector(768), metadata JSONB, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
psql -U postgres -p 5432 -d AEROSPACE -c "CREATE INDEX documents_embedding_idx ON documents USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);"
psql -U postgres -p 5432 -d AEROSPACE -c "CREATE INDEX documents_course_idx ON documents (course_code);"
psql -U postgres -p 5432 -d AEROSPACE -c "CREATE TABLE IF NOT EXISTS courses (id SERIAL PRIMARY KEY, course_code VARCHAR(20) UNIQUE NOT NULL, course_name VARCHAR(200) NOT NULL, description TEXT, document_count INTEGER DEFAULT 0, last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

if errorlevel 1 (
    echo.
    echo X Migration failed!
    echo Please check the error messages above.
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Migration completed successfully!
echo ==========================================
echo.
echo Database now supports 768-dimensional vectors.
echo.
echo Next steps:
echo 1. Index your documents: python run_cli.py index
echo 2. Start using the app!
echo.
pause
