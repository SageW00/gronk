# Quick Start Guide - Aerospace RAG

Get up and running in 5 minutes!

## Prerequisites Checklist

- [ ] Python 3.8+ installed
- [ ] PostgreSQL 16/18 running on port 5432
- [ ] Database "AEROSPACE" exists with user "postgres" (password: "1234")
- [ ] Ollama installed and running (`ollama serve`)
- [ ] gemma3:1b model pulled (`ollama pull gemma3:1b`)

## Installation (2 minutes)

```bash
# 1. Clone and navigate to the repository
git clone <repo-url>
cd gronk

# 2. Run automated setup
./setup.sh
```

That's it! The setup script handles everything automatically.

## Add Your First Course (1 minute)

```bash
# 1. Create a course directory (example: 16.100 - Aerodynamics)
mkdir -p data/coursenotes/16.100

# 2. Add your PDF files
cp /path/to/your/aerospace_pdfs/*.pdf data/coursenotes/16.100/

# 3. Index the documents
python3 run_cli.py index --course 16.100
```

## Start Using! (30 seconds)

### Option 1: CLI (Interactive Mode)

```bash
python3 run_cli.py interactive
```

Then type questions like:
- "What is the Bernoulli equation?"
- "Explain lift and drag forces"
- "How does a turbofan engine work?"

### Option 2: GUI

```bash
python3 run_gui.py
```

A beautiful dark-themed interface will open where you can:
- Ask questions in the text box
- Filter by course
- Adjust number of sources
- See cited references for all answers

### Option 3: CLI (Single Query)

```bash
python3 run_cli.py query "What is the relationship between angle of attack and lift?"
```

## Example Workflow

```bash
# Test system connectivity
python3 run_cli.py test

# List all configured courses
python3 run_cli.py courses

# Index all courses with PDFs
python3 run_cli.py index

# View statistics
python3 run_cli.py stats

# Start asking questions!
python3 run_cli.py interactive
```

## Common Questions

**Q: How many PDFs do I need?**
A: Even 1 PDF is enough to get started! The more the better.

**Q: What PDF types are supported?**
A: Any standard PDF with extractable text (not scanned images).

**Q: How long does indexing take?**
A: ~1-2 minutes per 100 pages, depending on your hardware.

**Q: Can I use a different model?**
A: Yes! Edit `config/config.yaml` and change the `model` field. Try `llama2`, `mistral`, or any other Ollama model.

**Q: Where are embeddings stored?**
A: In your PostgreSQL database with the pgvector extension.

**Q: Can I add my own courses?**
A: Absolutely! Edit `config/config.yaml` and add your course code and name.

## Troubleshooting Quick Fixes

### "Failed to connect to Ollama"
```bash
ollama serve
```

### "Failed to connect to database"
```bash
pg_isready -h localhost -p 5432
# If not running, start PostgreSQL
```

### "Model not found"
```bash
ollama pull gemma3:1b
```

### "No PDFs found"
Check your directory structure:
```bash
ls data/coursenotes/16.100/  # Should show your PDF files
```

## Next Steps

1. Read the full [README.md](README.md) for advanced features
2. Explore CLI commands: `python3 run_cli.py --help`
3. Customize `config/config.yaml` for your needs
4. Add more courses and PDFs!

## Need Help?

- Check [README.md](README.md) for detailed documentation
- Look at the Troubleshooting section
- Test connectivity: `python3 run_cli.py test`

Happy learning!
