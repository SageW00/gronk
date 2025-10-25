# Complete Ollama Setup Guide for Aerospace RAG

This guide will walk you through installing Ollama and getting both required models working.

## What You Need

You need **3 things**:
1. ✅ Ollama (the AI model runner)
2. ✅ gemma3:1b (for generating answers)
3. ✅ embeddinggemma (for understanding your questions)

---

## Step 1: Install Ollama

Choose your operating system:

### 🪟 Windows

**Download and Install:**
1. Go to: https://ollama.com/download/windows
2. Download the `.exe` installer
3. Run the installer (double-click)
4. Follow the installation wizard (just click "Next" → "Install")
5. Ollama will automatically start after installation

**Verify Installation:**
Open Command Prompt (search "cmd" in Start menu) and type:
```cmd
ollama --version
```

You should see something like: `ollama version 0.x.x`

---

### 🍎 macOS

**Install via Terminal:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**Or Download from Website:**
1. Go to: https://ollama.com/download/mac
2. Download the `.zip` file
3. Extract and drag Ollama to Applications
4. Open Ollama from Applications

**Verify Installation:**
Open Terminal and type:
```bash
ollama --version
```

---

### 🐧 Linux

**Install via Script:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**Verify Installation:**
```bash
ollama --version
```

---

## Step 2: Start Ollama Service

Ollama needs to be **running in the background** for the models to work.

### Windows

**Option 1: Ollama Usually Auto-Starts**
- After installation, Ollama runs automatically
- Look for Ollama icon in system tray (bottom-right, near clock)

**Option 2: Start Manually**
Open Command Prompt and run:
```cmd
ollama serve
```

**Keep this window open!** This is your Ollama server.

---

### Mac/Linux

Open a terminal window and run:
```bash
ollama serve
```

**Keep this terminal open!** This is your Ollama server.

You should see:
```
Ollama is running
```

---

## Step 3: Pull the Required Models

**Open a NEW terminal/command prompt** (keep the `ollama serve` window open!)

### Pull gemma3:1b (Text Generation Model)

```bash
ollama pull gemma3:1b
```

This will:
- Download ~2GB of data
- Take 5-15 minutes depending on your internet
- Show a progress bar

You should see:
```
pulling manifest
pulling... 100%
success
```

### Pull embeddinggemma (Embedding Model)

```bash
ollama pull embeddinggemma
```

This will:
- Download ~300MB of data
- Take 1-5 minutes
- Show a progress bar

You should see:
```
pulling manifest
pulling... 100%
success
```

---

## Step 4: Verify Models Are Installed

Run this command:
```bash
ollama list
```

You should see **both models** in the list:
```
NAME                ID              SIZE      MODIFIED
gemma3:1b           abc123...       2.0 GB    X minutes ago
embeddinggemma      def456...       274 MB    X minutes ago
```

✅ If you see both models, you're ready to go!

---

## Step 5: Test the Models

### Test gemma3:1b
```bash
ollama run gemma3:1b "What is aerodynamics?"
```

You should get a text response about aerodynamics.

### Test embeddinggemma
```bash
ollama run embeddinggemma "test"
```

You should see it load (embeddings don't generate text, but this confirms it works).

Press `Ctrl+D` or type `/bye` to exit.

---

## Step 6: Run the Aerospace RAG Setup

Now that Ollama is ready, run the setup:

### Windows
```cmd
setup_windows.bat
```

### Mac/Linux
```bash
./setup.sh
```

The setup script will:
- ✅ Detect that Ollama is running
- ✅ Verify both models are installed
- ✅ Configure everything automatically

---

## 🔧 Troubleshooting

### Problem 1: "ollama: command not found"

**Solution:**

**Windows:**
1. Close and reopen Command Prompt
2. Or add to PATH manually:
   - Search "Environment Variables" in Start
   - Edit PATH variable
   - Add: `C:\Users\YourName\AppData\Local\Programs\Ollama`

**Mac/Linux:**
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/usr/local/bin"
source ~/.bashrc  # or ~/.zshrc
```

---

### Problem 2: "Failed to connect to Ollama"

**This means Ollama is not running!**

**Solution:**
1. Open a terminal/command prompt
2. Run: `ollama serve`
3. Keep this window open
4. In a NEW window, run your setup or query

**Windows Alternative:**
- Check system tray for Ollama icon
- Right-click → Start/Restart

---

### Problem 3: "Model not found"

**Solution:**
```bash
# Re-pull the models
ollama pull gemma3:1b
ollama pull embeddinggemma

# Verify they're there
ollama list
```

---

### Problem 4: Models Are Slow to Download

**This is normal!**

- gemma3:1b: ~2GB (5-15 minutes)
- embeddinggemma: ~300MB (1-5 minutes)

**Tips:**
- Use a stable internet connection
- Don't interrupt the download
- If it fails, just run `ollama pull` again

---

### Problem 5: "Port already in use"

**Solution:**
```bash
# Kill existing Ollama process
# Windows:
taskkill /F /IM ollama.exe

# Mac/Linux:
pkill ollama

# Then restart
ollama serve
```

---

### Problem 6: Can't Access http://localhost:11434

**Test if Ollama is running:**

**Windows (Command Prompt):**
```cmd
curl http://localhost:11434/api/tags
```

**Mac/Linux:**
```bash
curl http://localhost:11434/api/tags
```

**If you get an error:**
- Ollama is not running → Run `ollama serve`

**If you see JSON output:**
- ✅ Ollama is running correctly!

---

## 📋 Quick Reference Card

| Step | Command | What It Does |
|------|---------|--------------|
| 1 | Install from ollama.com | Installs Ollama |
| 2 | `ollama serve` | Starts Ollama server |
| 3 | `ollama pull gemma3:1b` | Downloads text model |
| 4 | `ollama pull embeddinggemma` | Downloads embedding model |
| 5 | `ollama list` | Shows installed models |
| 6 | `./setup.sh` or `setup_windows.bat` | Sets up Aerospace RAG |

---

## 🎯 Expected Workflow

**Terminal/Command Prompt 1:**
```bash
ollama serve
# Leave this running!
```

**Terminal/Command Prompt 2:**
```bash
# Pull models (one-time)
ollama pull gemma3:1b
ollama pull embeddinggemma

# Verify
ollama list

# Run setup
./setup.sh  # or setup_windows.bat
```

---

## ✅ How to Know Everything is Working

Run this test:
```bash
curl http://localhost:11434/api/tags
```

You should see JSON with both models:
```json
{
  "models": [
    {"name": "gemma3:1b", ...},
    {"name": "embeddinggemma", ...}
  ]
}
```

✅ If you see this, you're 100% ready!

---

## 🆘 Still Having Issues?

**Check this checklist:**
- [ ] Ollama is installed (`ollama --version` works)
- [ ] Ollama server is running (`ollama serve` in one terminal)
- [ ] gemma3:1b is downloaded (`ollama list` shows it)
- [ ] embeddinggemma is downloaded (`ollama list` shows it)
- [ ] Can access http://localhost:11434 (curl test works)

**If ALL are checked and it still doesn't work:**

1. Restart Ollama:
   ```bash
   # Kill it
   pkill ollama  # or Ctrl+C in the ollama serve window

   # Start fresh
   ollama serve
   ```

2. Check logs:
   ```bash
   # Windows
   %USERPROFILE%\.ollama\logs

   # Mac/Linux
   ~/.ollama/logs
   ```

3. Reinstall Ollama:
   - Uninstall current version
   - Download fresh from ollama.com
   - Reinstall

---

## 💡 Pro Tips

1. **Keep `ollama serve` running in the background**
   - It needs to run whenever you use the Aerospace RAG app

2. **Models are stored locally**
   - Windows: `C:\Users\YourName\.ollama\models`
   - Mac: `~/.ollama/models`
   - Linux: `~/.ollama/models`

3. **To update models:**
   ```bash
   ollama pull gemma3:1b
   ollama pull embeddinggemma
   ```

4. **To remove a model:**
   ```bash
   ollama rm gemma3:1b
   ```

5. **To see model info:**
   ```bash
   ollama show gemma3:1b
   ```

---

## 🚀 Next Steps After Setup

Once Ollama is working:

1. **Run the Aerospace RAG setup**
   ```bash
   ./setup.sh  # or setup_windows.bat
   ```

2. **Index some documents**
   ```bash
   python3 run_cli.py index
   ```

3. **Start using the app!**
   ```bash
   # CLI
   python3 run_cli.py interactive

   # GUI
   python3 run_gui.py

   # Windows EXE (after building)
   dist\AerospaceRAG-GUI.exe
   ```

---

**Need more help?** Share the specific error message you're seeing and I can help debug it!
