source("_common.R")
# 필요 패키지 로드

library(lubridate)

# 유통 데이터 로드
trade_data_raw <- read_csv(
  "data/2_샘플_(고수요데이터)_농식품 온·오프라인 유통 품목 판매 데이터.csv",
  locale = locale(encoding = "UTF-8")
)

# 데이터 전처리
trade_data <- trade_data_raw %>%
  mutate(
    # 주차코드에서 날짜 정보 추출 (W202434 -> 2024년 34주차)
    년도 = as.numeric(str_sub(주차코드, 2, 5)),
    주차 = as.numeric(str_sub(주차코드, 6, 7)),

    # 날짜 변환
    시작일 = ymd(주차_시작일자),
    종료일 = ymd(주차_종료일자),

    # 월, 분기, 계절 정보 추가
    월 = month(시작일),
    분기 = quarter(시작일),
    계절 = case_when(
      월 %in% c(12, 1, 2) ~ "겨울",
      월 %in% c(3, 4, 5) ~ "봄",
      월 %in% c(6, 7, 8) ~ "여름",
      월 %in% c(9, 10, 11) ~ "가을"
    ),
    계절 = factor(계절, levels = c("봄", "여름", "가을", "겨울")),

    # 유통채널 팩터화
    유통채널 = factor(유통채널, levels = c("대형마트", "체인슈퍼")),

    # 매출액을 억원 단위로 변환
    매출액_억원 = 소매_매출액_원 / 100000000,

    # 도매가격 대비 소매매출액으로 추정 소매가격 계산 (개념적)
    # 실제로는 판매량 정보가 필요하지만 상대적 비교용으로 활용
    상대적_소매가격_지수 = 소매_매출액_원 / KAMIS_도매가격_원,

    # 시계열 순서를 위한 정렬 키
    정렬키 = paste0(년도, sprintf("%02d", 주차))
  ) %>%
  arrange(정렬키, 유통채널)

trade_data |>
  ggplot(aes(x = 시작일, y = KAMIS_도매가격_원)) +
  geom_line()
