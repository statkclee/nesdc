# 중앙선거여론조사심의위원회
library(rvest)
library(magrittr)
library(dplyr)
library(readr)

# 현시점 여론조사결과 등록 수집 ---------------
url <- "https://www.nesdc.go.kr/portal/bbs/B0000005/list.do?menuNo=200467"
html <- read_html(url)

rows <- html |> html_elements("div.board") |> 
  html_nodes("a.row.tr") 

data <- rows %>% 
  map_df(~{
    tibble(
      등록번호 = html_text(html_node(., xpath = ".//span[1]")),
      조사기관명 = html_text(html_node(., xpath = ".//span[2]")),
      조사의뢰자 = html_text(html_node(., xpath = ".//span[3]")),
      여론조사_명칭 = html_text(html_node(., xpath = ".//span[4]")),
      등록일 = html_text(html_node(., xpath = ".//span[5]")),
      시도 = html_text(html_node(., xpath = ".//span[6]"))
    )
}) |> 
  mutate(등록번호 = as.integer(등록번호),
         등록일 = as.Date(등록일, format = "%Y-%m-%d"))

# 이전시점 여론조사결과 등록 수집 ---------------
old_data <- read_csv("nesdc.csv")

oldest_reg_no <- old_data |> 
  arrange(desc(등록번호)) |> 
  slice_max(n = 1, order_by = 등록번호) |> 
  pull(등록번호) 

# 현시점과 이전시점 여론조사 등록 결과 비교 -------

latest_reg_no <- data |> 
  slice_max(n = 1, order_by = 등록번호) |> 
  pull(등록번호) 

if(latest_reg_no > oldest_reg_no){
  
  reg_msg <- paste0("등록번호(", latest_reg_no, " 외) 여론조사가 등록되었습니다.")
  ntfy::ntfy_send(reg_msg, topic = Sys.getenv("NESDC_TOPIC"))
  
} else {
  
  ntfy::ntfy_send("현재, 새로 등록된 여론조사가 없습니다.", topic = Sys.getenv("NESDC_TOPIC"))
  
}

# 최신 여론조사등록 -------
data |> write_csv("nesdc.csv")


