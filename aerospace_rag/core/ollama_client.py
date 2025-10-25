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
                # Use zero vector as fallback
                embeddings.append(np.zeros(384, dtype=np.float32))

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
