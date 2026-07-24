#' Summarize a binary (N/Y) outcome by management strategy and AAST grade
#'
#' n/N (%) summary of a Y/N outcome, cross-tabbed by `management_strategy` and
#' stratified by `SpleenAIS` grade (IV, V). One row per strategy plus an "ALL" row;
#' columns Grade IV / Grade V / All Grades. Spleen analog of PKI's
#' summarize_index_success (grades collapse to IV/V — no grade III in this cohort).
#'
#' @param data Data frame with `management_strategy`, `SpleenAIS`, and the outcome.
#' @param outcome Character name of the N/Y outcome column (e.g. "index_success").
#' @return Tibble: Strategy | Grade IV | Grade V | All Grades (character cells).
summarize_success <- function(data, outcome) {
  d <- data |> dplyr::filter(!is.na(.data[[outcome]]))
  pct <- function(df) {
    Yn <- sum(df[[outcome]] == "Y", na.rm = TRUE)
    N  <- sum(!is.na(df[[outcome]]))
    if (N > 0) sprintf("%d/%d (%.1f%%)", Yn, N, 100 * Yn / N) else "—"
  }
  by_group <- function(df, colname) {
    df |>
      group_by(management_strategy) |>
      group_modify(~ tibble(!!colname := pct(.x))) |>
      ungroup() |>
      mutate(management_strategy = as.character(management_strategy))
  }
  tab <- by_group(d, "All Grades") |>
    left_join(by_group(dplyr::filter(d, SpleenAIS == 4), "Grade IV"), by = "management_strategy") |>
    left_join(by_group(dplyr::filter(d, SpleenAIS == 5), "Grade V"),  by = "management_strategy")
  all_row <- tibble(
    management_strategy = "ALL",
    `All Grades` = pct(d),
    `Grade IV`   = pct(dplyr::filter(d, SpleenAIS == 4)),
    `Grade V`    = pct(dplyr::filter(d, SpleenAIS == 5))
  )
  bind_rows(tab, all_row) |>
    rename(Strategy = management_strategy) |>
    select(Strategy, `Grade IV`, `Grade V`, `All Grades`)
}
