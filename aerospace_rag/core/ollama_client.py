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
            error_msg = str(e).lower()
            if 'not found' in error_msg or 'pull' in error_msg:
                raise Exception(
                    f"❌ Embedding model '{self.embedding_model}' not found!\n\n"
                    f"Please pull the model first:\n"
                    f"  ollama pull {self.embedding_model}\n\n"
                    f"Or run the setup script again to auto-install models."
                )
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
            error_msg = str(e).lower()
            if 'not found' in error_msg or 'pull' in error_msg:
                raise Exception(
                    f"❌ Text generation model '{self.model}' not found!\n\n"
                    f"Please pull the model first:\n"
                    f"  ollama pull {self.model}\n\n"
                    f"Or run the setup script again to auto-install models."
                )
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
        """Check if the configured models are available"""
        try:
            models_response = ollama.list()

            # Debug: Show raw API response structure
            print(f"🔍 DEBUG - Raw Ollama API response type: {type(models_response)}")
            print(f"🔍 DEBUG - Response keys: {models_response.keys() if isinstance(models_response, dict) else 'Not a dict'}")

            # Handle different API response structures
            model_names = []

            if isinstance(models_response, dict):
                # Try different possible structures
                if 'models' in models_response:
                    models_list = models_response['models']
                    print(f"🔍 DEBUG - Found 'models' key, type: {type(models_list)}")

                    if isinstance(models_list, list) and len(models_list) > 0:
                        # Check first item structure
                        first_item = models_list[0]
                        print(f"🔍 DEBUG - First model structure: {first_item}")

                        # Extract names based on structure
                        for m in models_list:
                            if isinstance(m, dict):
                                # Try different possible keys
                                name = m.get('name') or m.get('model') or m.get('id') or str(m)
                                model_names.append(name)
                            elif isinstance(m, str):
                                model_names.append(m)
                            else:
                                model_names.append(str(m))
                else:
                    # Maybe models are at root level
                    print(f"🔍 DEBUG - No 'models' key, checking root level")
                    model_names = list(models_response.keys())
            elif isinstance(models_response, list):
                # Response is directly a list
                print(f"🔍 DEBUG - Response is a list")
                for m in models_response:
                    if isinstance(m, dict):
                        name = m.get('name') or m.get('model') or m.get('id') or str(m)
                        model_names.append(name)
                    else:
                        model_names.append(str(m))

            # Clean up None values
            model_names = [m for m in model_names if m and m != 'None']

            print(f"✅ Detected Ollama models: {model_names}")

            if not model_names:
                print("⚠️  Warning: No models found!")
                print(f"   Raw response: {models_response}")
                return False

            missing_models = []

            # Helper function to check if model exists (handles version tags)
            def model_exists(target_model, available_models):
                """Check if model exists, handling tags like :latest"""
                if not target_model or not available_models:
                    return False

                # Direct match
                if target_model in available_models:
                    return True
                # Check with :latest tag
                if f"{target_model}:latest" in available_models:
                    return True
                # Check if any model starts with the target name
                for model in available_models:
                    model_str = str(model)
                    if model_str.startswith(f"{target_model}:"):
                        return True
                    # Handle case where stored model has tags but we're looking for base
                    if ':' in model_str and model_str.split(':')[0] == target_model.split(':')[0]:
                        return True
                return False

            # Check text generation model
            if not model_exists(self.model, model_names):
                missing_models.append(self.model)
                print(f"❌ Text model '{self.model}' not found")
            else:
                print(f"✓ Text model '{self.model}' is available")

            # Check embedding model
            if not model_exists(self.embedding_model, model_names):
                missing_models.append(self.embedding_model)
                print(f"❌ Embedding model '{self.embedding_model}' not found")
            else:
                print(f"✓ Embedding model '{self.embedding_model}' is available")

            if missing_models:
                print(f"\n⚠️  Missing models: {', '.join(missing_models)}")
                print(f"Available models: {model_names}")
                print(f"\nTo fix, run:")
                for model in missing_models:
                    print(f"  ollama pull {model}")
                return False

            return True

        except KeyError as e:
            print(f"❌ Failed to parse model list - KeyError: {e}")
            print(f"   This usually means the Ollama API structure changed.")
            print(f"   Please run: ollama list")
            print(f"   And share the output so we can fix the parser.")
            return False
        except Exception as e:
            print(f"❌ Failed to check model availability: {e}")
            print(f"   Error type: {type(e).__name__}")
            import traceback
            print(f"   Traceback: {traceback.format_exc()}")
            return False

    def pull_model(self, model_name: Optional[str] = None) -> bool:
        """Pull a model from Ollama"""
        try:
            target_model = model_name if model_name else self.model
            print(f"Pulling model: {target_model}...")
            ollama.pull(target_model)
            print(f"✓ Model {target_model} pulled successfully")
            return True

        except Exception as e:
            print(f"❌ Failed to pull model {target_model}: {e}")
            return False

    def pull_all_models(self) -> bool:
        """Pull both text generation and embedding models"""
        print("\n" + "="*60)
        print("📦 Pulling required Ollama models...")
        print("="*60 + "\n")

        success = True

        # Pull text generation model
        print(f"[1/2] Pulling text generation model: {self.model}")
        if not self.pull_model(self.model):
            success = False

        print()  # Blank line

        # Pull embedding model (only if different from text model)
        if self.embedding_model != self.model:
            print(f"[2/2] Pulling embedding model: {self.embedding_model}")
            if not self.pull_model(self.embedding_model):
                success = False
        else:
            print(f"[2/2] Embedding model same as text model, skipping...")

        print("\n" + "="*60)
        if success:
            print("✅ All models pulled successfully!")
        else:
            print("❌ Some models failed to pull. Please check the errors above.")
        print("="*60 + "\n")

        return success
