"""
Ollama client for embeddings and completions
"""

import ollama
import numpy as np
from typing import List, Dict, Any, Optional
from .config import get_config


class OllamaClient:
    """Client for interacting with Ollama API"""

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        if config is None:
            cfg = get_config()
            config = cfg.ollama

        self.config = config
        self.model = config.get('model', 'gemma3:1b')
        self.embedding_model = config.get('embedding_model', 'gemma3:1b')
        self.temperature = config.get('temperature', 0.7)
        self.max_tokens = config.get('max_tokens', 2048)

    def generate_embedding(self, text: str) -> np.ndarray:
        """Generate embedding for text using Ollama"""
        try:
            response = ollama.embeddings(
                model=self.embedding_model,
                prompt=text
            )

            embedding = np.array(response['embedding'], dtype=np.float32)
            return embedding

        except Exception as e:
            error_msg = str(e)
            # Check if it's the common "model doesn't support embeddings" error
            if "does not support embeddings" in error_msg or "status code: 500" in error_msg:
                print("\n" + "="*60)
                print("ERROR: Wrong model for embeddings")
                print("="*60)
                print(f"\nThe model '{self.embedding_model}' does not support embeddings.")
                print("\nYou need to use an embedding-specific model.")
                print("\nTo fix this:")
                print("  1. Pull the embedding model:")
                print(f"     ollama pull embeddinggemma")
                print("\n  2. Your config should have:")
                print(f"     embedding_model: embeddinggemma")
                print("\n  3. Or run the setup script again to auto-configure")
                print("="*60 + "\n")
            raise Exception(f"Failed to generate embedding: {e}")

    def generate_embeddings_batch(self, texts: List[str]) -> List[np.ndarray]:
        """Generate embeddings for multiple texts"""
        embeddings = []
        for i, text in enumerate(texts):
            try:
                embedding = self.generate_embedding(text)
                embeddings.append(embedding)

                if (i + 1) % 10 == 0:
                    print(f"  Generated {i + 1}/{len(texts)} embeddings")

            except Exception as e:
                print(f"Warning: Failed to generate embedding for text {i}: {e}")
                # Use zero vector as fallback (embeddinggemma uses 768 dimensions)
                embeddings.append(np.zeros(768, dtype=np.float32))

        return embeddings

    def generate_completion(
        self,
        prompt: str,
        context: Optional[str] = None,
        system_prompt: Optional[str] = None,
        stream: bool = False
    ) -> str:
        """Generate completion using Ollama"""
        try:
            messages = []

            # Add system prompt if provided
            if system_prompt:
                messages.append({
                    'role': 'system',
                    'content': system_prompt
                })

            # Add context if provided
            if context:
                messages.append({
                    'role': 'user',
                    'content': f"Context:\n{context}\n\nQuestion: {prompt}"
                })
            else:
                messages.append({
                    'role': 'user',
                    'content': prompt
                })

            if stream:
                return self._generate_streaming(messages)
            else:
                response = ollama.chat(
                    model=self.model,
                    messages=messages,
                    options={
                        'temperature': self.temperature,
                        'num_predict': self.max_tokens
                    }
                )

                return response['message']['content']

        except Exception as e:
            raise Exception(f"Failed to generate completion: {e}")

    def _generate_streaming(self, messages: List[Dict]) -> str:
        """Generate completion with streaming"""
        try:
            full_response = ""
            stream = ollama.chat(
                model=self.model,
                messages=messages,
                stream=True,
                options={
                    'temperature': self.temperature,
                    'num_predict': self.max_tokens
                }
            )

            for chunk in stream:
                if 'message' in chunk and 'content' in chunk['message']:
                    content = chunk['message']['content']
                    full_response += content
                    print(content, end='', flush=True)

            print()  # New line after streaming
            return full_response

        except Exception as e:
            raise Exception(f"Streaming generation failed: {e}")

    def check_connection(self) -> bool:
        """Check if Ollama is running and accessible"""
        try:
            # Try to list models
            models = ollama.list()
            return True
        except Exception as e:
            print(f"Failed to connect to Ollama: {e}")
            return False

    def check_model_available(self) -> bool:
        """Check if the configured model is available"""
        try:
            models = ollama.list()
            model_names = [m['name'] for m in models.get('models', [])]

            if self.model not in model_names:
                print(f"Warning: Model {self.model} not found in Ollama")
                print(f"Available models: {model_names}")
                return False

            return True

        except Exception as e:
            print(f"Failed to check model availability: {e}")
            return False

    def pull_model(self) -> bool:
        """Pull the configured model from Ollama"""
        try:
            print(f"Pulling model: {self.model}")
            ollama.pull(self.model)
            print(f"✓ Model {self.model} pulled successfully")
            return True

        except Exception as e:
            print(f"Failed to pull model: {e}")
            return False

    def check_models_available(self) -> tuple[bool, List[str]]:
        """Check if both text generation and embedding models are available"""
        try:
            models = ollama.list()
            model_names = [m['name'] for m in models.get('models', [])]

            missing_models = []

            if self.model not in model_names:
                missing_models.append(self.model)

            if self.embedding_model not in model_names:
                missing_models.append(self.embedding_model)

            return len(missing_models) == 0, missing_models

        except Exception as e:
            print(f"Failed to check model availability: {e}")
            return False, []

    def pull_required_models(self) -> bool:
        """Pull both text generation and embedding models"""
        try:
            models_to_pull = [self.model, self.embedding_model]
            # Remove duplicates
            models_to_pull = list(set(models_to_pull))

            print(f"\nPulling required Ollama models...")
            print(f"  - Text generation: {self.model}")
            print(f"  - Embeddings: {self.embedding_model}")
            print()

            for model in models_to_pull:
                print(f"Pulling {model}... (this may take a few minutes)")
                ollama.pull(model)
                print(f"✓ {model} pulled successfully\n")

            return True

        except Exception as e:
            print(f"Failed to pull models: {e}")
            return False

    def validate_models(self) -> bool:
        """Validate that both models are available and working"""
        print("Validating Ollama models...")

        all_available, missing = self.check_models_available()

        if not all_available:
            print("\n" + "="*60)
            print("ERROR: Missing Ollama Models")
            print("="*60)
            print("\nThe following models are not installed:")
            for model in missing:
                print(f"  - {model}")
            print("\nTo install missing models:")
            for model in missing:
                print(f"  ollama pull {model}")
            print("\nOr run the setup script to auto-install:")
            print("  Windows: setup_windows.bat")
            print("  Linux/Mac: ./setup.sh")
            print("="*60 + "\n")
            return False

        print(f"✓ Text generation model: {self.model}")
        print(f"✓ Embedding model: {self.embedding_model}")
        return True
