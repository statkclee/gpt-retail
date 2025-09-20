# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Korean-language Quarto book project titled "AI가 밝혀낸 유통 고수요 데이터의 진실" (AI's Discovery of High-Demand Retail Data Truth), focusing on AI and data science with ChatGPT. The book is divided into three main parts: Basic Knowledge, AI Coding, and Case Studies.

## Build and Development Commands

### Primary Commands
- **Build the book**: `quarto render`
- **Preview the book**: `quarto preview` (runs on port 7771)
- **Build PDF version**: `quarto render --to bitPublish-pdf`

### Working with Specific Chapters
- **Render single chapter**: `quarto render [chapter].qmd`
- **Preview single chapter**: `quarto preview [chapter].qmd`

## High-Level Architecture

### Content Structure
The book follows a three-part structure defined in `_quarto.yml`:

1. **Part 1: Basic Knowledge** (`basic_*.qmd`)
   - ChatGPT fundamentals, prompt engineering, IDE integration, API usage
   
2. **Part 2: AI Coding** (`coding_*.qmd`)
   - Prompt techniques, context engineering, OpenAI/Claude integration, IDE tools
   
3. **Part 3: Case Studies** (`proj_*.qmd`)
   - Penguin analysis (R and Python versions), market analysis, survey analysis, car data analysis

### Technical Stack
- **Framework**: Quarto book project with multilingual support (Korean primary)
- **Extensions**: WebR, Pyodide, Shinylive for interactive code execution
- **Rendering**: Supports HTML and PDF output (bitPublish-pdf format)
- **Python Environment**: Uses `pandas_env` kernel for Jupyter notebooks
- **Freeze**: Auto-freeze enabled for computational results

### Key Directories
- `_freeze/`: Cached computational results for each chapter
- `_extensions/`: Quarto extensions including bitPublish (Korean PDF), webr, pyodide, shinylive
- `data/`: Sample datasets and resources used in examples
- `images/`: Visual assets for the book
- `docs/`: Output directory for rendered book

### Integration Features
- **Interactive Code**: WebR for R code, Pyodide for Python code execution in browser
- **Shinylive**: Interactive Shiny applications embedded in chapters
- **Lightbox**: Image viewing enhancement enabled
- **Cross-references**: Chapter-based cross-referencing system

## Important Considerations

### Language and Localization
- Primary language is Korean (`lang: ko-KR`)
- Date format: Korean style (YYYY년 MM월 DD일)
- Custom Korean labels for abstract and references sections

### Git Workflow
- Main branch is `main`
- Multiple modified files tracked in git status
- Avoid committing freeze files unless computational results change

### Development Tips
- Port 7771 is configured for preview to avoid conflicts
- Browser auto-open is disabled for preview
- Render excludes `.Rmd` files (only `.qmd` processed)
- Audio files (`*.mp3`, `*.wav`) included as resources