"""
Configuration management for Aerospace RAG application
"""

import yaml
import os
from pathlib import Path
from typing import Dict, Any


class Config:
    """Application configuration manager"""

    def __init__(self, config_path: str = None):
        if config_path is None:
            config_path = Path(__file__).parent.parent.parent / "config" / "config.yaml"

        self.config_path = Path(config_path)
        self.config = self._load_config()

    def _load_config(self) -> Dict[str, Any]:
        """Load configuration from YAML file"""
        if not self.config_path.exists():
            raise FileNotFoundError(f"Configuration file not found: {self.config_path}")

        with open(self.config_path, 'r') as f:
            return yaml.safe_load(f)

    @property
    def database(self) -> Dict[str, Any]:
        """Get database configuration"""
        return self.config.get('database', {})

    @property
    def ollama(self) -> Dict[str, Any]:
        """Get Ollama configuration"""
        return self.config.get('ollama', {})

    @property
    def rag(self) -> Dict[str, Any]:
        """Get RAG configuration"""
        return self.config.get('rag', {})

    @property
    def courses(self) -> Dict[str, str]:
        """Get course mappings"""
        return self.config.get('courses', {})

    @property
    def paths(self) -> Dict[str, str]:
        """Get data paths"""
        return self.config.get('paths', {})

    def get(self, key: str, default: Any = None) -> Any:
        """Get configuration value by key"""
        return self.config.get(key, default)


# Global configuration instance
_config = None


def get_config(config_path: str = None) -> Config:
    """Get global configuration instance"""
    global _config
    if _config is None:
        _config = Config(config_path)
    return _config
