"""
Debug script to check Ollama API structure
Run this to see exactly what ollama.list() returns
"""

import sys

print("="*60)
print("Ollama API Structure Debugger")
print("="*60)
print()

# Try to import ollama
try:
    import ollama
    print("✓ ollama module imported successfully")
except ImportError as e:
    print(f"✗ Failed to import ollama: {e}")
    print()
    print("Fix: pip install ollama")
    sys.exit(1)

print()

# Try to connect
try:
    print("Checking Ollama connection...")
    models = ollama.list()
    print("✓ Ollama connection successful")
except Exception as e:
    print(f"✗ Failed to connect to Ollama: {e}")
    print()
    print("Make sure Ollama is running:")
    print("  ollama serve")
    sys.exit(1)

print()
print("="*60)
print("RAW API RESPONSE:")
print("="*60)
print()
print(f"Type: {type(models)}")
print(f"Value: {models}")
print()

# Check if it's a ListResponse object
if hasattr(models, 'models'):
    print("Response is a LISTRESPONSE OBJECT (ollama._types.ListResponse)")
    print("✓ Has 'models' attribute")
    print()

    models_list = models.models
    print(f"models attribute type: {type(models_list)}")
    print(f"Number of models: {len(models_list)}")
    print()

    if len(models_list) > 0:
        print("First model structure:")
        first = models_list[0]
        print(f"  Type: {type(first)}")
        print(f"  Attributes: {dir(first)}")
        print()

        if hasattr(first, 'model'):
            print(f"  ✓ Has .model attribute: {first.model}")
        if hasattr(first, 'size'):
            print(f"  ✓ Has .size attribute: {first.size}")
        if hasattr(first, 'modified_at'):
            print(f"  ✓ Has .modified_at attribute: {first.modified_at}")

        print()
        print("All models:")
        for i, m in enumerate(models_list):
            if hasattr(m, 'model'):
                print(f"  [{i}] {m.model}")
            else:
                print(f"  [{i}] {m}")

elif isinstance(models, dict):
    print("Response is a DICT")
    print(f"Keys: {list(models.keys())}")
    print()

    if 'models' in models:
        print("Found 'models' key!")
        models_list = models['models']
        print(f"  Type: {type(models_list)}")
        print(f"  Length: {len(models_list) if isinstance(models_list, list) else 'N/A'}")

        if isinstance(models_list, list) and len(models_list) > 0:
            print()
            print("First model structure:")
            first = models_list[0]
            print(f"  Type: {type(first)}")
            print(f"  Value: {first}")

            if isinstance(first, dict):
                print(f"  Keys: {list(first.keys())}")

            print()
            print("All models:")
            for i, m in enumerate(models_list):
                print(f"  [{i}] {m}")

elif isinstance(models, list):
    print("Response is a LIST")
    print(f"Length: {len(models)}")
    print()

    if len(models) > 0:
        print("First item:")
        first = models[0]
        print(f"  Type: {type(first)}")
        print(f"  Value: {first}")

        if isinstance(first, dict):
            print(f"  Keys: {list(first.keys())}")

        print()
        print("All items:")
        for i, m in enumerate(models):
            print(f"  [{i}] {m}")

else:
    print(f"Response is: {type(models)}")
    print(f"Value: {models}")

print()
print("="*60)
print("ANALYSIS:")
print("="*60)
print()

# Try to extract model names
model_names = []

try:
    # Handle ListResponse object (ollama._types.ListResponse)
    if hasattr(models, 'models'):
        print("Extracting from ListResponse object...")
        for m in models.models:
            if hasattr(m, 'model'):
                model_name = m.model
                model_names.append(model_name)
                print(f"✓ Found model: {model_name}")
            else:
                model_names.append(str(m))
                print(f"✓ Found model: {str(m)}")

    # Handle dict-based response
    elif isinstance(models, dict) and 'models' in models:
        print("Extracting from dict response...")
        for m in models['models']:
            if isinstance(m, dict):
                # Try different keys
                name = m.get('name') or m.get('model') or m.get('id')
                if name:
                    model_names.append(name)
                    print(f"✓ Found model: {name}")
            elif isinstance(m, str):
                model_names.append(m)
                print(f"✓ Found model: {m}")

    print()
    print(f"Total models found: {len(model_names)}")
    print(f"Model names: {model_names}")

except Exception as e:
    print(f"✗ Error parsing models: {e}")
    import traceback
    print(traceback.format_exc())

print()
print("="*60)
print("WHAT TO DO:")
print("="*60)
print()

if model_names:
    print("✓ Models were detected successfully!")
    print()
    print("If the app still doesn't work, please share this output.")
else:
    print("✗ No models were detected.")
    print()
    print("Please:")
    print("  1. Share this entire output")
    print("  2. Run: ollama list")
    print("  3. Share that output too")
    print()
    print("This will help fix the parser!")

print()
input("Press Enter to exit...")
