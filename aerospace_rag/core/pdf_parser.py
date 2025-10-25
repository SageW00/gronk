"""
PDF parsing and text chunking utilities
"""

import PyPDF2
import pdfplumber
from pathlib import Path
from typing import List, Dict, Tuple, Optional
import re


class PDFParser:
    """Parse PDF files and extract text with chunking"""

    def __init__(self, chunk_size: int = 512, chunk_overlap: int = 100):
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap

    def extract_text_pypdf2(self, pdf_path: Path) -> List[Tuple[int, str]]:
        """Extract text from PDF using PyPDF2"""
        pages = []
        try:
            with open(pdf_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)
                for page_num, page in enumerate(pdf_reader.pages, 1):
                    text = page.extract_text()
                    if text.strip():
                        pages.append((page_num, text))
        except Exception as e:
            print(f"Warning: PyPDF2 extraction failed for {pdf_path.name}: {e}")

        return pages

    def extract_text_pdfplumber(self, pdf_path: Path) -> List[Tuple[int, str]]:
        """Extract text from PDF using pdfplumber (more accurate)"""
        pages = []
        try:
            with pdfplumber.open(pdf_path) as pdf:
                for page_num, page in enumerate(pdf.pages, 1):
                    text = page.extract_text()
                    if text and text.strip():
                        pages.append((page_num, text))
        except Exception as e:
            print(f"Warning: pdfplumber extraction failed for {pdf_path.name}: {e}")

        return pages

    def extract_text(self, pdf_path: Path) -> List[Tuple[int, str]]:
        """Extract text from PDF, trying pdfplumber first, then PyPDF2"""
        pages = self.extract_text_pdfplumber(pdf_path)

        if not pages:
            print(f"Trying PyPDF2 for {pdf_path.name}...")
            pages = self.extract_text_pypdf2(pdf_path)

        if not pages:
            raise Exception(f"Failed to extract text from {pdf_path.name}")

        return pages

    def clean_text(self, text: str) -> str:
        """Clean and normalize extracted text"""
        # Remove excessive whitespace
        text = re.sub(r'\s+', ' ', text)

        # Remove page numbers and headers (common patterns)
        text = re.sub(r'Page \d+', '', text)

        # Remove special characters but keep scientific notation
        text = re.sub(r'[^\w\s\.\,\!\?\;\:\-\(\)\[\]\=\+\*\/\^\%\$]', '', text)

        return text.strip()

    def chunk_text(self, text: str) -> List[str]:
        """Split text into overlapping chunks"""
        # Split by sentences first
        sentences = re.split(r'(?<=[.!?])\s+', text)

        chunks = []
        current_chunk = []
        current_length = 0

        for sentence in sentences:
            sentence_length = len(sentence)

            if current_length + sentence_length > self.chunk_size and current_chunk:
                # Save current chunk
                chunks.append(' '.join(current_chunk))

                # Start new chunk with overlap
                overlap_text = ' '.join(current_chunk)
                overlap_sentences = []
                overlap_length = 0

                # Add sentences from the end for overlap
                for s in reversed(current_chunk):
                    if overlap_length + len(s) <= self.chunk_overlap:
                        overlap_sentences.insert(0, s)
                        overlap_length += len(s)
                    else:
                        break

                current_chunk = overlap_sentences
                current_length = overlap_length

            current_chunk.append(sentence)
            current_length += sentence_length

        # Add remaining chunk
        if current_chunk:
            chunks.append(' '.join(current_chunk))

        return chunks

    def parse_pdf(self, pdf_path: Path) -> List[Dict]:
        """Parse PDF and return structured chunks"""
        pages = self.extract_text(pdf_path)
        all_chunks = []

        chunk_index = 0
        for page_num, page_text in pages:
            cleaned_text = self.clean_text(page_text)

            if not cleaned_text:
                continue

            chunks = self.chunk_text(cleaned_text)

            for chunk in chunks:
                if len(chunk.strip()) > 50:  # Minimum chunk size
                    all_chunks.append({
                        'text': chunk,
                        'chunk_index': chunk_index,
                        'page_number': page_num,
                        'file_name': pdf_path.name
                    })
                    chunk_index += 1

        return all_chunks

    def parse_directory(
        self,
        directory: Path,
        recursive: bool = True
    ) -> Dict[str, List[Dict]]:
        """Parse all PDFs in a directory"""
        if not directory.exists():
            raise FileNotFoundError(f"Directory not found: {directory}")

        pattern = "**/*.pdf" if recursive else "*.pdf"
        pdf_files = list(directory.glob(pattern))

        if not pdf_files:
            print(f"Warning: No PDF files found in {directory}")
            return {}

        results = {}
        for pdf_file in pdf_files:
            try:
                print(f"Parsing: {pdf_file.name}")
                chunks = self.parse_pdf(pdf_file)
                results[str(pdf_file)] = chunks
                print(f"  ✓ Extracted {len(chunks)} chunks")
            except Exception as e:
                print(f"  ✗ Error parsing {pdf_file.name}: {e}")

        return results


def parse_course_pdfs(
    course_code: str,
    course_name: str,
    data_dir: Path,
    content_types: List[str] = None
) -> List[Dict]:
    """Parse PDFs for a specific course"""
    if content_types is None:
        content_types = ['coursenotes', 'textbook']

    parser = PDFParser()
    all_documents = []

    for content_type in content_types:
        content_dir = data_dir / content_type / course_code

        if not content_dir.exists():
            print(f"Warning: Directory not found: {content_dir}")
            continue

        print(f"\nProcessing {content_type} for {course_code}...")
        results = parser.parse_directory(content_dir)

        for pdf_path, chunks in results.items():
            for chunk_data in chunks:
                all_documents.append({
                    'course_code': course_code,
                    'course_name': course_name,
                    'content_type': content_type,
                    'file_name': chunk_data['file_name'],
                    'text': chunk_data['text'],
                    'chunk_index': chunk_data['chunk_index'],
                    'page_number': chunk_data['page_number']
                })

    return all_documents
