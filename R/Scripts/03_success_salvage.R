#* 3: Index success and splenic salvage by strategy and grade (Table 3)
#+ 3.1: Build the two n/N (%) sub-tables (early deaths already excluded via NA outcomes)
index_tbl   <- summarize_success(raw_ready, "index_success")
salvage_tbl <- summarize_success(raw_ready, "splenic_salvage")
#+ 3.2: Stack with section-header rows, relabel ALL and strategy display names
relabel <- function(tbl) tbl |>
  mutate(Strategy = dplyr::recode(Strategy, "ALL" = "All Management Strategies"))
T3_data <- bind_rows(
  tibble(Strategy = "Index Management Success", `Grade IV` = "", `Grade V` = "", `All Grades` = ""),
  relabel(index_tbl),
  tibble(Strategy = "Splenic Salvage", `Grade IV` = "", `Grade V` = "", `All Grades` = ""),
  relabel(salvage_tbl)
)
#+ 3.3: Style Table 4
T3 <- ternStyle(
  tbl = T3_data,
  table_caption = "Table 3. Nonoperative management success and splenic salvage stratified by index nonoperative strategy and AAST injury grade. Cells are n/N (%). Splenectomy is counted as a failure of both nonoperative management and salvage; early (<24 h) deaths are excluded.",
  subheader_rows = c("Index Management Success", "Splenic Salvage"),
  manual_italic_indent = c("Observation", "Interventional Radiology", "All Management Strategies"),
  header_format_follow = TRUE,
  col1_header = "Variable\n   Index Management Strategy",
  font_size = 9
)
