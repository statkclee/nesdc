# Quotes to Scrape 웹사이트에서 오늘의 명언
library(rvest)
library(magrittr)

url <- "https://quotes.toscrape.com"
html <- read_html(url)

row <- html |> html_elements(".quote")

daily_quote <- row |> html_element(".text") |> html_text2() %>% .[1]

daily_author <- row |> html_element(".author") |> html_text2() %>% .[1]

quote_msg <- paste0(daily_author, ": ", daily_quote)

ntfy::ntfy_send(quote_msg, topic = Sys.getenv("NTFY_QUOTE_TOPIC"))



