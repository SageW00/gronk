"""
RAG (Retrieval-Augmented Generation) Engine
"""

from typing import List, Dict, Any, Optional
from pathlib import Path
import numpy as np

from .config import get_config
from .database import DatabaseManager
from .ollama_client import OllamaClient
from .pdf_parser import parse_course_pdfs


class RAGEngine:
    """Main RAG engine for document retrieval and generation"""

    def __init__(self):
        self.config = get_config()
        self.db = DatabaseManager()
        self.ollama = OllamaClient()

    def initialize(self) -> None:
        """Initialize the RAG system"""
        print("Initializing Aerospace RAG System...")

        # Check Ollama connection
        if not self.ollama.check_connection():
            raise ConnectionError("Failed to connect to Ollama. Make sure Ollama is running.")

        # Connect to database
        self.db.connect()

        # Initialize schema
        self.db.init_schema()

        print("✓ RAG system initialized successfully")

    def index_documents(
        self,
        course_code: Optional[str] = None,
        content_types: List[str] = None
    ) -> None:
        """Index documents from PDFs into the database"""
        if content_types is None:
            content_types = ['coursenotes', 'textbook']

        courses = self.config.courses
        data_dir = Path(self.config.paths['data_dir'])

        # If specific course is provided, only index that course
        if course_code:
            if course_code not in courses:
                raise ValueError(f"Unknown course code: {course_code}")
            courses = {course_code: courses[course_code]}

        total_indexed = 0

        for code, name in courses.items():
            print(f"\n{'='*60}")
            print(f"Indexing: {code} - {name}")
            print(f"{'='*60}")

            try:
                # Parse PDFs
                documents = parse_course_pdfs(code, name, data_dir, content_types)

                if not documents:
                    print(f"No documents found for {code}")
                    continue

                print(f"\nGenerating embeddings for {len(documents)} chunks...")

                # Generate embeddings
                texts = [doc['text'] for doc in documents]
                embeddings = self.ollama.generate_embeddings_batch(texts)

                # Prepare batch insert
                batch_data = []
                for doc, embedding in zip(documents, embeddings):
                    embedding_list = embedding.tolist() if isinstance(embedding, np.ndarray) else embedding

                    batch_data.append((
                        doc['course_code'],
                        doc['course_name'],
                        doc['content_type'],
                        doc['file_name'],
                        doc['text'],
                        doc['chunk_index'],
                        doc['page_number'],
                        embedding_list,
                        None  # metadata
                    ))

                # Insert into database
                print(f"Inserting {len(batch_data)} chunks into database...")
                self.db.insert_documents_batch(batch_data)

                total_indexed += len(batch_data)
                print(f"✓ Successfully indexed {len(batch_data)} chunks for {code}")

            except Exception as e:
                print(f"✗ Error indexing {code}: {e}")

        print(f"\n{'='*60}")
        print(f"Total documents indexed: {total_indexed}")
        print(f"{'='*60}")

    def query(
        self,
        question: str,
        course_code: Optional[str] = None,
        top_k: int = None,
        stream: bool = False
    ) -> Dict[str, Any]:
        """Query the RAG system"""
        if top_k is None:
            top_k = self.config.rag['top_k']

        similarity_threshold = self.config.rag['similarity_threshold']

        try:
            # Generate query embedding
            print("Generating query embedding...")
            query_embedding = self.ollama.generate_embedding(question)

            # Search for similar documents
            print("Searching for relevant documents...")
            results = self.db.similarity_search(
                query_embedding,
                top_k=top_k,
                course_code=course_code,
                similarity_threshold=similarity_threshold
            )

            if not results:
                return {
                    'question': question,
                    'answer': "I couldn't find any relevant information in the aerospace course materials for your question.",
                    'sources': [],
                    'context_used': False
                }

            # Build context from retrieved documents
            context_parts = []
            sources = []

            for i, result in enumerate(results, 1):
                context_parts.append(
                    f"[Source {i}] From {result['course_name']} "
                    f"({result['content_type']}, {result['file_name']}, page {result['page_number']}):\n"
                    f"{result['text']}\n"
                )

                sources.append({
                    'course_code': result['course_code'],
                    'course_name': result['course_name'],
                    'content_type': result['content_type'],
                    'file_name': result['file_name'],
                    'page_number': result['page_number'],
                    'similarity': result['similarity']
                })

            context = "\n".join(context_parts)

            # Generate answer using context
            system_prompt = """You are an expert aerospace engineering assistant.
            Use the provided context from MIT aerospace course materials to answer questions accurately and helpfully.
            If the context doesn't contain enough information, say so.
            Explain concepts clearly and include relevant equations, principles, or examples when appropriate.
            Always cite which source you're using in your answer."""

            print("\nGenerating answer...\n")
            answer = self.ollama.generate_completion(
                prompt=question,
                context=context,
                system_prompt=system_prompt,
                stream=stream
            )

            return {
                'question': question,
                'answer': answer,
                'sources': sources,
                'context_used': True
            }

        except Exception as e:
            raise Exception(f"Query failed: {e}")

    def get_statistics(self) -> Dict[str, Any]:
        """Get system statistics"""
        total_docs = self.db.get_document_count()
        courses = self.db.get_all_courses()

        return {
            'total_documents': total_docs,
            'courses': courses,
            'configured_courses': len(self.config.courses)
        }

    def close(self) -> None:
        """Close connections"""
        self.db.disconnect()
