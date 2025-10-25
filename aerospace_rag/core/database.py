"""
PostgreSQL database manager with pgvector support
"""

import psycopg2
from psycopg2.extras import execute_values
from typing import List, Tuple, Optional, Dict, Any
import numpy as np
from .config import get_config


class DatabaseManager:
    """Manages PostgreSQL database operations with pgvector"""

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        if config is None:
            cfg = get_config()
            config = cfg.database

        self.config = config
        self.conn = None
        self.cursor = None

    def connect(self) -> None:
        """Establish database connection"""
        try:
            self.conn = psycopg2.connect(
                host=self.config['host'],
                port=self.config['port'],
                user=self.config['user'],
                password=self.config['password'],
                database=self.config['database']
            )
            self.cursor = self.conn.cursor()
            print(f"✓ Connected to PostgreSQL database: {self.config['database']}")
        except Exception as e:
            raise ConnectionError(f"Failed to connect to database: {e}")

    def disconnect(self) -> None:
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
        print("✓ Database connection closed")

    def init_schema(self) -> None:
        """Initialize database schema with pgvector extension"""
        try:
            # Enable pgvector extension
            self.cursor.execute("CREATE EXTENSION IF NOT EXISTS vector;")

            # Create documents table
            self.cursor.execute("""
                CREATE TABLE IF NOT EXISTS documents (
                    id SERIAL PRIMARY KEY,
                    course_code VARCHAR(20) NOT NULL,
                    course_name VARCHAR(200) NOT NULL,
                    content_type VARCHAR(50) NOT NULL,
                    file_name VARCHAR(255) NOT NULL,
                    chunk_text TEXT NOT NULL,
                    chunk_index INTEGER NOT NULL,
                    page_number INTEGER,
                    embedding vector(384),
                    metadata JSONB,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            """)

            # Create index for vector similarity search
            self.cursor.execute("""
                CREATE INDEX IF NOT EXISTS documents_embedding_idx
                ON documents USING ivfflat (embedding vector_cosine_ops)
                WITH (lists = 100);
            """)

            # Create index for course lookups
            self.cursor.execute("""
                CREATE INDEX IF NOT EXISTS documents_course_idx
                ON documents (course_code);
            """)

            # Create courses table
            self.cursor.execute("""
                CREATE TABLE IF NOT EXISTS courses (
                    id SERIAL PRIMARY KEY,
                    course_code VARCHAR(20) UNIQUE NOT NULL,
                    course_name VARCHAR(200) NOT NULL,
                    description TEXT,
                    document_count INTEGER DEFAULT 0,
                    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            """)

            self.conn.commit()
            print("✓ Database schema initialized successfully")

        except Exception as e:
            self.conn.rollback()
            raise Exception(f"Failed to initialize schema: {e}")

    def insert_document(
        self,
        course_code: str,
        course_name: str,
        content_type: str,
        file_name: str,
        chunk_text: str,
        chunk_index: int,
        embedding: np.ndarray,
        page_number: Optional[int] = None,
        metadata: Optional[Dict] = None
    ) -> int:
        """Insert a document chunk with its embedding"""
        try:
            embedding_list = embedding.tolist() if isinstance(embedding, np.ndarray) else embedding

            self.cursor.execute("""
                INSERT INTO documents
                (course_code, course_name, content_type, file_name, chunk_text,
                 chunk_index, page_number, embedding, metadata)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id;
            """, (
                course_code, course_name, content_type, file_name, chunk_text,
                chunk_index, page_number, embedding_list, metadata
            ))

            doc_id = self.cursor.fetchone()[0]
            self.conn.commit()
            return doc_id

        except Exception as e:
            self.conn.rollback()
            raise Exception(f"Failed to insert document: {e}")

    def insert_documents_batch(self, documents: List[Tuple]) -> None:
        """Insert multiple documents efficiently"""
        try:
            execute_values(
                self.cursor,
                """
                INSERT INTO documents
                (course_code, course_name, content_type, file_name, chunk_text,
                 chunk_index, page_number, embedding, metadata)
                VALUES %s
                """,
                documents,
                template="(%s, %s, %s, %s, %s, %s, %s, %s, %s)"
            )
            self.conn.commit()
            print(f"✓ Inserted {len(documents)} document chunks")

        except Exception as e:
            self.conn.rollback()
            raise Exception(f"Failed to batch insert documents: {e}")

    def similarity_search(
        self,
        query_embedding: np.ndarray,
        top_k: int = 5,
        course_code: Optional[str] = None,
        similarity_threshold: float = 0.0
    ) -> List[Dict[str, Any]]:
        """Search for similar documents using cosine similarity"""
        try:
            embedding_list = query_embedding.tolist() if isinstance(query_embedding, np.ndarray) else query_embedding

            query = """
                SELECT
                    id, course_code, course_name, content_type, file_name,
                    chunk_text, chunk_index, page_number, metadata,
                    1 - (embedding <=> %s::vector) as similarity
                FROM documents
                WHERE 1 - (embedding <=> %s::vector) > %s
            """
            params = [embedding_list, embedding_list, similarity_threshold]

            if course_code:
                query += " AND course_code = %s"
                params.append(course_code)

            query += " ORDER BY embedding <=> %s::vector LIMIT %s;"
            params.extend([embedding_list, top_k])

            self.cursor.execute(query, params)
            results = self.cursor.fetchall()

            return [
                {
                    'id': r[0],
                    'course_code': r[1],
                    'course_name': r[2],
                    'content_type': r[3],
                    'file_name': r[4],
                    'text': r[5],
                    'chunk_index': r[6],
                    'page_number': r[7],
                    'metadata': r[8],
                    'similarity': float(r[9])
                }
                for r in results
            ]

        except Exception as e:
            raise Exception(f"Similarity search failed: {e}")

    def get_document_count(self, course_code: Optional[str] = None) -> int:
        """Get total document count, optionally filtered by course"""
        try:
            if course_code:
                self.cursor.execute(
                    "SELECT COUNT(*) FROM documents WHERE course_code = %s",
                    (course_code,)
                )
            else:
                self.cursor.execute("SELECT COUNT(*) FROM documents")

            return self.cursor.fetchone()[0]

        except Exception as e:
            raise Exception(f"Failed to get document count: {e}")

    def get_all_courses(self) -> List[Dict[str, Any]]:
        """Get all courses with document counts"""
        try:
            self.cursor.execute("""
                SELECT course_code, course_name, COUNT(*) as doc_count
                FROM documents
                GROUP BY course_code, course_name
                ORDER BY course_code
            """)

            results = self.cursor.fetchall()
            return [
                {
                    'course_code': r[0],
                    'course_name': r[1],
                    'document_count': r[2]
                }
                for r in results
            ]

        except Exception as e:
            raise Exception(f"Failed to get courses: {e}")

    def clear_all_documents(self) -> None:
        """Clear all documents from the database"""
        try:
            self.cursor.execute("DELETE FROM documents")
            self.conn.commit()
            print("✓ All documents cleared")

        except Exception as e:
            self.conn.rollback()
            raise Exception(f"Failed to clear documents: {e}")

    def __enter__(self):
        """Context manager entry"""
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit"""
        self.disconnect()
