#* 7: Figures
#+ 7.1: Ensure output directory
if (!dir.exists("Outputs/Figures")) dir.create("Outputs/Figures", recursive = TRUE)

#+ 7.2: Splenic salvage (%) by management strategy and grade
salvage_plot_data <- raw_ready |>
  filter(!is.na(splenic_salvage)) |>
  mutate(grade = factor(SpleenAIS, levels = c(4, 5), labels = c("IV", "V"))) |>
  group_by(management_strategy, grade) |>
  summarise(pct = 100 * mean(splenic_salvage == "Y"), n = n(), .groups = "drop")
p_salvage <- plot_salvage_bar(salvage_plot_data)
ggplot2::ggsave("Outputs/Figures/salvage_by_strategy_grade.png", p_salvage,
                width = 7, height = 4.5, dpi = 300, bg = "white")

#+ 7.3: Forest plot of NOM-failure model odds ratios (from 05_model.R)
p_forest <- plot_or_forest(nom_fit, labels = c(
  grade_V   = "AAST Grade V (vs IV)",
  map10     = "MAP (per 10 mmHg)",
  got_blood = "Received blood (4 h)"
))
ggplot2::ggsave("Outputs/Figures/nom_failure_forest.png", p_forest,
                width = 7, height = 3, dpi = 300, bg = "white")
