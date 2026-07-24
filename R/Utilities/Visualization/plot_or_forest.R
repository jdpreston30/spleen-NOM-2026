#' Forest plot of adjusted odds ratios from a logistic regression
#'
#' @param model A fitted `glm` (binomial). Backtick-quoted term names are cleaned.
#' @param labels Optional named character vector mapping model term -> display label.
#'   Pure function — returns a ggplot (log-scaled OR axis, reference line at 1).
plot_or_forest <- function(model, labels = NULL) {
  td <- broom::tidy(model, exponentiate = TRUE, conf.int = TRUE) |>
    dplyr::filter(term != "(Intercept)") |>
    dplyr::mutate(term = gsub("`", "", term))
  if (!is.null(labels)) td$term <- dplyr::recode(td$term, !!!labels)
  td$term <- factor(td$term, levels = rev(td$term))
  ggplot2::ggplot(td, ggplot2::aes(x = estimate, y = term)) +
    ggplot2::geom_vline(xintercept = 1, linetype = "dashed", color = "grey50") +
    ggplot2::geom_errorbarh(ggplot2::aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
    ggplot2::geom_point(size = 2.5) +
    ggplot2::scale_x_log10() +
    ggplot2::labs(x = "Adjusted odds ratio (95% CI, log scale)", y = NULL) +
    ggplot2::theme_classic(base_size = 12)
}
