# ========================
# 농산물 관심도 뉴스 데이터 분석
# ========================

source("_common.R")

# 필요 패키지 로드
library(lubridate)
library(stringdist)
library(fuzzyjoin)

# ========================
# 1. 데이터 로드 및 전처리
# ========================

# 농산물 관심도 데이터 로드
news_data_raw <- read_csv(
  "data/3_샘플_(고수요데이터)_모바일 기사 기반 농산물 관심도 데이터.csv",
  locale = locale(encoding = "UTF-8")
)

# 데이터 전처리
news_data <- news_data_raw %>%
  # 날짜 및 시간 변환
  mutate(
    날짜 = ymd(`년-월-일`),
    접속_시간 = ymd_hm(`접속 시간`),
    접속_시 = hour(접속_시간),
    접속_분 = minute(접속_시간),
    체류시간_초 = `사용 시간`
  ) %>%
  # 변수명 정리
  rename(
    플랫폼 = `출처 플랫폼`,
    카테고리 = `카테고리`,
    성별 = `성별`,
    연령대 = `연령대`,
    직업군 = `직업군`,
    시 = `지역_시`,
    구 = `지역_구`,
    제목 = `제목`,
    URL = `검색사이트 URL`,
    언론사ID = `언론사 ID`,
    언론사 = `언론사 이름`,
    기사번호 = `기사번호`,
    섹션 = `플랫폼 기준 색션`,
    키워드 = `매칭 키워드`
  ) %>%
  # 키워드 정제 및 농산물 분류
  mutate(
    키워드_정제 = str_trim(str_remove_all(키워드, '"')),
    키워드_정제 = ifelse(키워드_정제 == "", "기타", 키워드_정제),
    # 농산물 키워드 필터링
    농산물여부 = case_when(
      str_detect(
        키워드_정제,
        "딸기|바나나|호두|과일|배추|채소|콩나물|녹차|보리|감귤|오렌지|토마토|사과|마늘|생강|버섯|대파|아보카도|고구마|깻잎|리치|귀리|양파|고추|땅콩|수수"
      ) ~
        TRUE,
      키워드_정제 %in% c("생활", "경제", "사회") ~ FALSE,
      TRUE ~ TRUE # 기타 키워드는 농산물로 간주
    )
  ) %>%
  # 농산물 관련 데이터만 필터링
  filter(농산물여부 == TRUE) %>%
  # factor 변환
  mutate(
    플랫폼 = factor(플랫폼, levels = c("네이버", "다음", "기타")),
    성별 = factor(성별, levels = c("남성", "여성")),
    연령대 = factor(
      연령대,
      levels = c("10대", "20대", "30대", "40대", "50대", "60대", "70대", "80대")
    ),
    직업군 = factor(직업군),
    키워드_정제 = factor(키워드_정제)
  )

cat("전처리 완료 - 총", nrow(news_data), "건의 농산물 관련 뉴스\n")

# ========================
# 2. 중복 제목 제거
# ========================

# 유사 제목 제거 함수 (Jaro-Winkler 유사도 기반)
remove_similar_titles <- function(data, threshold = 0.85) {
  titles <- data$제목
  keep_indices <- c(1) # 첫 번째는 무조건 유지

  for (i in 2:length(titles)) {
    # 이전 유지된 제목들과 비교
    similarities <- sapply(titles[keep_indices], function(x) {
      stringsim(titles[i], x, method = "jw")
    })

    # 유사도가 threshold 미만이면 유지
    if (max(similarities) < threshold) {
      keep_indices <- c(keep_indices, i)
    }
  }

  return(data[keep_indices, ])
}

# 중복 제목 제거 실행
unique_news <- remove_similar_titles(news_data, threshold = 0.85)

cat("중복 제거 완료 - 유니크 뉴스:", nrow(unique_news), "건\n")
cat("제거율:", round((1 - nrow(unique_news) / nrow(news_data)) * 100, 1), "%\n")

# 유니크 제목 저장
unique_news %>%
  select(제목) %>%
  write_delim("data/3_unique_news_title.txt", "\n")

# ========================
# 3. 뉴스 분류 매칭
# ========================

# 뉴스 분류 데이터 로드
news_classified <- read_csv("data/3_news_classified.csv")

# 제목 정규화 함수
normalize_title <- function(title) {
  title %>%
    str_replace_all('"', '') %>%
    str_replace_all("'", '') %>%
    str_replace_all("[[:punct:]]", " ") %>% # 모든 구두점을 공백으로
    str_squish() %>% # 연속된 공백 제거
    tolower()
}

# 유사도 기반 조인 (95% 이상)
news_with_category <- news_data %>%
  mutate(제목_정규화 = normalize_title(제목)) %>%
  stringdist_left_join(
    news_classified %>%
      mutate(뉴스제목_정규화 = normalize_title(뉴스제목)),
    by = c("제목_정규화" = "뉴스제목_정규화"),
    max_dist = 0.05, # 95% 유사도 (1 - 0.95)
    method = "jw", # Jaro-Winkler 거리
    distance_col = "similarity_score"
  ) %>%
  select(-제목_정규화, -뉴스제목_정규화, -뉴스제목)

# ========================
# 4. 결과 확인 및 저장
# ========================

# 매칭 결과 확인
total_news <- nrow(news_data)
matched_news <- sum(!is.na(news_with_category$대분류))
match_rate <- round(matched_news / total_news * 100, 1)

cat("\n=== 뉴스 분류 매칭 결과 ===\n")
cat("전체 뉴스 수:", total_news, "건\n")
cat("분류 매칭된 뉴스 수:", matched_news, "건\n")
cat("매칭률:", match_rate, "%\n")


# 최종 데이터셋 저장
news_with_category |>
  write_rds("data/3_news_with_category.rds")
