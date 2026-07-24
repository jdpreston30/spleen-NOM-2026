#' Grouped bar of splenic salvage (%) by management strategy and AAST grade
#'
#' @param data Tibble with columns `management_strategy`, `grade` (factor IV/V),
#'   and `pct` (salvage percentage). Pure function — returns a ggplot.
plot_salvage_bar <- function(data) {
  ggplot2::ggplot(data, ggplot2::aes(x = management_strategy, y = pct, fill = grade)) +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8), width = 0.7) +
    ggplot2::geom_text(
      ggplot2::aes(label = sprintf("%.0f%%", pct)),
      position = ggplot2::position_dodge(width = 0.8),
      vjust = -0.4, size = 3
    ) +
    ggplot2::scale_y_continuous(limits = c(0, 105), expand = c(0, 0)) +
    ggplot2::scale_fill_grey(start = 0.6, end = 0.3, name = "AAST Grade") +
    ggplot2::labs(x = NULL, y = "Splenic salvage (%)") +
    ggplot2::theme_classic(base_size = 12) +
    ggplot2::theme(legend.position = "top")
}
