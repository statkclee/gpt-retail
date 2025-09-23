# _common.R
# 공통 라이브러리 및 설정 파일

# 필수 라이브러리 로드
library(tidyverse)
library(gt)
library(scales)
library(DT)

# Apple Gothic 폰트 설정
library(sysfonts)
library(ragg)
library(rsvg)
library(ggrepel)

# 폰트 등록
sysfonts::font_add("Apple Gothic", "/System/Library/Fonts/AppleGothic.ttf")

# knitr 그래픽 디바이스 설정
knitr::opts_chunk$set(
  dev = "ragg_png",
  dpi = 300,
  fig.retina = 2,
  message = FALSE,
  warning = FALSE,
  collapse = TRUE,
  code_overflow = "wrap",
  fig.crop = FALSE,
  comment = "#>"
)

# ggplot2 테마 설정
theme_set(
  theme_minimal() +
    theme(
      text = element_text(family = "Apple Gothic"),
      plot.title = element_text(
        family = "Apple Gothic",
        size = 14,
        face = "bold"
      ),
      plot.subtitle = element_text(family = "Apple Gothic", size = 12),
      axis.text = element_text(family = "Apple Gothic"),
      axis.title = element_text(family = "Apple Gothic"),
      legend.text = element_text(family = "Apple Gothic"),
      legend.title = element_text(family = "Apple Gothic")
    )
)

# 공통 함수 정의

# 숫자 포맷팅 함수
format_numbers <- function(data, columns = NULL) {
  if (is.null(columns)) {
    data %>%
      mutate(across(where(is.numeric), comma))
  } else {
    data %>%
      mutate(across(all_of(columns), comma))
  }
}


# 폰트 등록
sysfonts::font_add("Apple Gothic", "/System/Library/Fonts/AppleGothic.ttf")
