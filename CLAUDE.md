# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Korean-language Quarto book project titled "AI가 밝혀낸 유통 고수요 데이터의 진실" focusing on AI and data science with ChatGPT. The book targets Korean audiences with three progressive parts: basic knowledge, AI coding techniques, and real-world case studies.

## Build and Development Commands

### Core Rendering Commands
- **Build entire book**: `quarto render` (outputs to `docs/`)
- **Preview with live reload**: `quarto preview` (port 7771, browser disabled)
- **Build Korean PDF**: `quarto render --to bitPublish-pdf`
- **Single chapter**: `quarto render [chapter].qmd`

### Freeze Cache Management
- **Clear all freeze cache**: `quarto clean --freeze`
- **Force rebuild chapter**: `rm -rf _freeze/[chapter-name]/` then render
- **Check freeze status**: `quarto inspect freeze`

### Validation and Testing
- **Check project structure**: `quarto check`
- **Validate extensions**: `quarto list extensions`
- **Preview specific format**: `quarto preview --to html`

## High-Level Architecture

### Dual-Language Execution Environment
The project uses both R (knitr) and Python (pandas_env kernel) for computational content. Chapters with heavy computation are auto-frozen to ensure reproducible builds without re-execution.

**Key computational chapters**: `coding_openai.qmd` (1,284 lines), `coding_ide.qmd` (1,415 lines), `basic_gpt.qmd` (635 lines).

### Interactive Code Execution System
Three parallel systems enable in-browser code execution:
- **WebR**: R code execution via `{webr-r}` code blocks
- **Pyodide**: Python execution via `{pyodide-python}` blocks
- **Shinylive**: Interactive Shiny apps via `{shinylive-r}` blocks

### Multi-Format Publishing Pipeline
- **HTML**: Primary output with interactive features enabled
- **PDF**: Korean-optimized via `bitPublish` extension with custom fonts
- **Resources**: Audio files (MP3/WAV) automatically included

### Extension Architecture
10 extensions provide core functionality:
- `bit2r/bitPublish`: Korean PDF typesetting
- `coatless/webr`, `coatless-quarto/pyodide`: Interactive execution
- `quarto-ext/shinylive`: Interactive Shiny applications
- `debruine/glossary`: Terminology management
- `sellorm/social-embeds`: Social media integration

## Content Organization and Workflow

### Chapter Structure
Three-part progression with specific content types:
- **Part 1** (basic_*.qmd): Conceptual foundations, minimal computation
- **Part 2** (coding_*.qmd): Heavy computational content, requires freeze management
- **Part 3** (proj_*.qmd): Case studies with real datasets from `/data/`

### Adding New Chapters
1. Create `.qmd` file following naming convention
2. Add to `_quarto.yml` chapters section under appropriate part
3. For computational content, ensure first render to establish freeze cache
4. Use Korean section headers and maintain lang consistency

### Data and Resource Management
- **Large datasets**: Store in `/data/`, reference via relative paths
- **Audio resources**: Automatically included via `resources` config
- **Images**: Store in `/images/`, use for both HTML and PDF outputs
- **Cache**: Computational results cached in `_freeze/` - commit when results change

## Korean Localization Requirements

### Language Configuration
- Primary language: `ko-KR` with custom date formatting
- Section titles use Korean terms ("초록", "참고문헌")
- Cross-references configured with empty prefixes for Korean style

### Typography and Branding
- Font stack: Noto Sans KR (headings), Noto Serif KR (body)
- Brand colors defined in `_brand.yml` (blue primary: #2780e3)
- Footer includes Korean R Users Group attribution

## Development Considerations

### Performance and Optimization
- Preview port 7771 configured to avoid conflicts
- Browser auto-open disabled for development workflow
- Freeze system prevents unnecessary re-computation of heavy chapters
- Lightbox enabled for enhanced image viewing

### Git Workflow
- Main branch deployment, no feature branching currently
- Exclude `_freeze/` from frequent commits unless computational results change
- Include rendered `docs/` for GitHub Pages deployment

### Troubleshooting Common Issues
- **Freeze errors**: Clear specific chapter cache and re-render
- **Extension conflicts**: Check extension compatibility in `_quarto.yml`
- **Korean font issues**: Ensure proper font installation for PDF output
- **Large file handling**: Use Git LFS for datasets over 100MB

### R

#### 코딩 스타일
- **tidyverse 스타일**: 모든 R 코드는 tidyverse 원칙을 따름
- **표 생성**: gt 패키지 사용
  - `cols_width()`: 컬럼 너비는 pct() 함수로 퍼센트 지정
  - `tab_options(table.width = pct())`: 테이블 전체 너비도 퍼센트로 설정
- **그래프**: ggplot2 사용
- **폰트 관리**: sysfonts, ragg, rsvg 패키지 조합 사용
  - Apple Gothic 폰트를 모든 theme, geom_text 등에 적용
  - `library(sysfonts)`, `library(ragg)`, `library(rsvg)` 사용
  - knitr 그래픽 디바이스를 ragg_png로 설정

#### 예시 코드
```r
# 폰트 설정
library(sysfonts)
library(ragg)
library(rsvg)

# 폰트 등록
sysfonts::font_add("Apple Gothic", "/System/Library/Fonts/AppleGothic.ttf")

# knitr 그래픽 디바이스 설정
knitr::opts_chunk$set(
  dev = "ragg_png",
  dpi = 300,
  fig.retina = 2
)

# gt 테이블
data %>%
  gt() %>%
  cols_width(
    컬럼1 ~ pct(30),
    컬럼2 ~ pct(70)
  ) %>%
  tab_options(
    table.width = pct(80),
    table.font.size = px(12),
    column_labels.background.color = "#f8f9fa"    
  ) %>%
  opt_table_font(font = "Apple Gothic")

# ggplot 그래프
ggplot(data, aes(x, y)) +
  geom_col() +
  geom_text(aes(label = value), family = "Apple Gothic") +
  theme(text = element_text(family = "Apple Gothic"))
```

### Quarto

#### 코드 청크 문법
- **YAML 스타일 옵션**: Quarto는 YAML 스타일 청크 옵션 사용 권장
- **라벨링**: `#| label: chunk-name` 형식 사용
- **옵션 설정**: `#|` 접두사로 각 옵션을 별도 라인에 작성
- **가독성**: 코드와 옵션이 명확히 분리되어 가독성 향상

#### 코드 청크 예시

`````markdown
# 기본 설정
```{r}
#| include: false
#| label: setup
source("_common.R")
```

# 데이터 로드
```{r}
#| label: load-data
#| echo: true
#| warning: false
data <- read_csv("data/file.csv")
```

# 시각화
```{r}
#| label: plot-example
#| fig-cap: "데이터 시각화 예시"
#| fig-width: 8
#| fig-height: 6
ggplot(data, aes(x, y)) +
  geom_point()
```

# 테이블
```{r}
#| label: table-example
#| tbl-cap: "데이터 요약 테이블"
data %>%
  cols_width(
    컬럼1 ~ pct(30),
    컬럼2 ~ pct(70)
  ) %>%
  tab_options(
    table.width = pct(80),
    table.font.size = px(12),
    column_labels.background.color = "#f8f9fa"    
  ) %>%
  opt_table_font(font = "Apple Gothic")
```
`````

#### 주요 옵션
- `#| include: false`: 결과 숨김
- `#| echo: false`: 코드 숨김
- `#| warning: false`: 경고 메시지 숨김
- `#| message: false`: 메시지 숨김
- `#| fig-cap: "설명"`: 그림 캡션
- `#| tbl-cap: "설명"`: 테이블 캡션
- `#| label: name`: 청크 라벨 (크로스 레퍼런스용)
