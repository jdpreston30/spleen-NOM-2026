#* 4: Index success and splenic salvage by strategy and grade (Table 4)
#+ 4.1: Build the two n/N (%) sub-tables (early deaths already excluded via NA outcomes)
index_tbl   <- summarize_success(raw_ready, "index_success")
salvage_tbl <- summarize_success(raw_ready, "splenic_salvage")
#+ 4.2: Stack with section-header rows, relabel ALL and strategy display names
relabel <- function(tbl) tbl |>
  mutate(Strategy = dplyr::recode(Strategy, "ALL" = "All Management Strategies"))
T4_data <- bind_rows(
  tibble(Strategy = "Index Management Success", `Grade IV` = "", `Grade V` = "", `All Grades` = ""),
  relabel(index_tbl),
  tibble(Strategy = "Splenic Salvage", `Grade IV` = "", `Grade V` = "", `All Grades` = ""),
  relabel(salvage_tbl)
)
#+ 4.3: Style Table 4
T4 <- ternStyle(
  tbl = T4_data,
  table_caption = "Table 4. Index management success and splenic salvage stratified by index management strategy and AAST injury grade. Cells are n/N (%). Splenectomy is counted as a failure of both index management and salvage; early (<24 h) deaths are excluded.",
  subheader_rows = c("Index Management Success", "Splenic Salvage"),
  manual_italic_indent = c("Observation", "Interventional Radiology", "Operative", "All Management Strategies"),
  header_format_follow = TRUE,
  col1_header = "Variable\n   Index Management Strategy",
  font_size = 9
)
