# Codebase Genius Assignment 2

**Codebase Genius** is an intelligent documentation and analysis framework that automatically maps, analyzes, and documents software repositories.  
It extract structure, relationships, and high-impact insights from any codebase—producing developer-ready documentation and visual summaries.

---

## Overview

The system is composed of two main components:

### 1. **Backend (Jaseci + Python)**
- Implements autonomous **Jac-based agents**:
  - **Supervisor** – orchestrates the workflow and determines analysis order.
  - **Repo Mapper** – clones and maps repository structures.
  - **Code Analyzer** – extracts logical and semantic context from source files.
  - **Doc Genie** – generates natural-language summaries and technical docs.
- Uses supporting Python modules for:
  - Repository utilities (`git_utils.py`)
  - Parsing and diagram generation (`parser.py`, `diagram_gen.py`)
- Produces structured outputs in Markdown.

### 2. **Frontend (Streamlit)**
- Provides a simple interface to trigger documentation runs.
- Displays repository summaries and generated Markdown.
- Allows uploading of GitHub URLs.

---

##  Project Structure

```
codebase_genius/
├── backend/
│   ├── agents/              # Jac agents handling repo mapping, analysis, and doc generation
│   ├── py_modules/          # Python helpers for Git, parsing, and visualization
│   ├── outputs/             # Generated artifacts: diagrams, summaries, logs, and extracted insights
│   ├── server.jac           # Main Jaseci entrypoint (Supervisor node)
│   ├── requirements.txt     # Backend dependencies
├── frontend/
│   ├── app.py               # Streamlit/Flask frontend entry
│   ├── requirements.txt     # Frontend dependencies
```

---

##  Installation

### Prerequisites
- Python 3.9+
- [Jaseci](https://github.com/Jaseci-Labs/jaseci)
- Git
- pip/pip3 / virtualenv

### 1. Install dependencies (Setup)

```bash
# Create project directory and navigate into it
mkdir codebase_genius && cd codebase_genius

# Create and activate virtual environment
python3 -m venv venv
venv\Scripts\activate

# Clone repository
git clone https://github.com/AntonyJosephy/genAiCourse.git
cd genAiCourse/codebase_genius

# Install backend dependencies
pip install -r backend/requirements.txt

# Install frontend dependencies
pip install -r frontend/requirements.txt

# Install runtime dependencies
pip install gitpython tree_sitter jaseci

# Pre-pin pyarrow to avoid long resolution/ Or use constraints.txt
pip install "pyarrow==22.0.0"
# Use contraints.txt
```bash
`pyarrow==22.0.0`
`prompt_toolkit==3.0.51`
`pyasn1==0.5.0
```
```bash
pip install -r backend/requirements.txt -r frondend/requirements.txt -c constraints.txt
```
```
### 2. Clone `tree-sitter-python` grammar:
```bash
git clone https://github.com/tree-sitter/tree-sitter-python vendor/tree-sitter-python
```
---

##  Usage

### 3. Start Jaseci and load supervisor (main.jac)
```bash
jaseci serv actions start
jsctl launch backend/agents/main.jac
```

### Launch Frontend
```bash
streamlit run frontend/app.py
```

Then open your browser at **http://localhost:8501**.

---

##  How It Works

1. **Input:** A GitHub URL.  
2. **Repo Mapper:** Clones and indexes repository structure.  
3. **Code Analyzer:** Parses and evaluates the code.  
4. **Doc Genie:** Generates Markdown summaries.  
5. **Supervisor:** Aggregates all outputs into a coherent README.

---

## Dependencies

Backend:
`jaseci`, `gitpython`,`networkx`, `pygments`, `pyarrow`

Frontend:
`streamlit`, `requests`, `markdown`

---

##  Acknowledgements
- [Jaseci Labs](https://jaseci.org/) for the Jac agent framework.    
- The developer community advancing AI-assisted documentation.
