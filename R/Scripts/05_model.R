#* 5: Predictors of nonoperative management (NOM) failure (Tables 5 & 6)
#+ 5.1: NOM cohort, outcome, and candidate predictors
# NOM = observation + IR arms, excluding early (<24 h) deaths.
# NOM failure = index management did not succeed (further spleen procedure or splenectomy).
nom_data <- raw_ready |>
  filter(management_strategy %in% c("Observation", "Interventional Radiology"), !early_death) |>
  mutate(
    nom_failure = as.integer(index_success == "N"),
    grade_V   = as.integer(SpleenAIS == 5),
    map10     = MAP / 10,
    age       = Age,
    male      = as.integer(Gender == "Male"),
    fast_pos  = as.integer(Fast_P_N == 1),
    fast_hypo = as.integer(Fast_hypoten == 1),
    got_blood = as.integer(bloodany == "Yes"),
    ct_extrav = as.integer(CTextrav == 1),
    ct_pseudo = as.integer(CT_pseudoane == 1),
    ct_hemop  = as.integer(CT_Hemoperitoneum == 1)
  )
cat(sprintf("NOM model: n=%d, failures=%d (%.0f%%)\n",
            nrow(nom_data), sum(nom_data$nom_failure), 100 * mean(nom_data$nom_failure)))

#+ 5.2: Univariable candidate screen (Table 5) — each unadjusted, complete-case per predictor
# Pre-specified candidates. CT findings are ~40% missing, so each univariable fit uses
# its own complete cases (n reported). This is a transparent landscape, NOT model selection.
candidates <- c(
  "AAST Grade V (vs IV)"        = "grade_V",
  "MAP (per 10 mmHg)"           = "map10",
  "Age (per year)"              = "age",
  "Male sex"                    = "male",
  "FAST positive"               = "fast_pos",
  "FAST+ with hypotension"      = "fast_hypo",
  "Received blood (4 h)"        = "got_blood",
  "Contrast extravasation (CT)" = "ct_extrav",
  "Pseudoaneurysm (CT)"         = "ct_pseudo",
  "Hemoperitoneum (CT)"         = "ct_hemop"
)
uni_rows <- lapply(names(candidates), function(lbl) {
  v <- candidates[[lbl]]
  f <- glm(reformulate(v, "nom_failure"), data = nom_data, family = binomial)
  co <- summary(f)$coefficients
  est <- co[2, "Estimate"]; se <- co[2, "Std. Error"]; pv <- co[2, "Pr(>|z|)"]
  used <- !is.na(nom_data[[v]])
  tibble(
    Predictor     = lbl,
    n             = as.character(sum(used)),
    Events        = as.character(sum(nom_data$nom_failure[used])),
    `OR (95% CI)` = sprintf("%.2f (%.2f–%.2f)", exp(est), exp(est - 1.96 * se), exp(est + 1.96 * se)),
    `p-value`     = ifelse(pv < 0.001, "<0.001", sprintf("%.3f", pv))
  )
})
uni_tbl <- bind_rows(uni_rows)
T5 <- ternStyle(
  tbl = uni_tbl,
  table_caption = "Table 5. Univariable associations of candidate predictors with nonoperative management failure. Unadjusted odds ratios; each row uses complete cases for that predictor (n shown). CT findings were recorded in ~60% of patients. This is a screening landscape, not a model-selection procedure. p-values < 0.05 are printed in bold.",
  bold_sig = TRUE,
  font_size = 9
)

#+ 5.3: Multivariable model (Table 6) — pre-specified, complete predictors only
# Three complete predictors chosen a priori (severity, hemodynamics, transfusion) given
# the event count (~36) caps the model at ~3 predictors (≈10 events/predictor).
nom_fit <- glm(nom_failure ~ grade_V + map10 + got_blood, data = nom_data, family = binomial)
or_tbl <- broom::tidy(nom_fit, exponentiate = TRUE, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  transmute(
    Predictor    = dplyr::recode(term,
      grade_V   = "AAST Grade V (vs IV)",
      map10     = "MAP (per 10 mmHg)",
      got_blood = "Received blood (4 h)"),
    `Odds Ratio` = sprintf("%.2f", estimate),
    `95% CI`     = sprintf("%.2f–%.2f", conf.low, conf.high),
    `p-value`    = ifelse(p.value < 0.001, "<0.001", sprintf("%.3f", p.value))
  )
T6 <- ternStyle(
  tbl = or_tbl,
  table_caption = sprintf("Table 6. Multivariable logistic regression for predictors of nonoperative management failure (n = %d, %d failures). Pre-specified predictors; adjusted odds ratios with 95%% CIs. p-values < 0.05 are printed in bold.",
                          nrow(nom_data), sum(nom_data$nom_failure)),
  bold_sig = TRUE,
  font_size = 9
)
