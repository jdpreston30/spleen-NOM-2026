#* 6: Compile tables for export
#+ 6.1: Ensure output directory exists
if (!dir.exists("Outputs/Tables")) dir.create("Outputs/Tables", recursive = TRUE)
#+ 6.2: Combine all tables into a single Word document with ternB
ternB(
  tables           = list(T1, T2, T3, T4, T5, T6),
  output_docx      = "Outputs/Tables/T1-T6.docx",
  methods_doc      = TRUE,
  methods_filename = "Outputs/Tables/T1-T6-methods.docx",
  font_family      = "Times New Roman"
)
#+ 6.3: Auto-write an aggregate QC dump to .A/output.md (gitignored) so r() self-documents
# All aggregate (counts / medians / cross-tabs / result tibbles) — no row-level data.
{
  if (!dir.exists(".A")) dir.create(".A")
  if (sink.number() > 0) sink()
  qc <- ".A/output.md"; sink(qc)
  cat("# Pipeline output (auto-written by run.R)\n\n")

  cat("## Stage dimensions\n\n```\n")
  for (nm in c("raw", "raw_selected", "raw_pared", "raw_std", "raw_derived", "raw_outcomes",
               "raw_clean", "raw_ready", "raw_corrected", "raw_named"))
    if (exists(nm)) cat(sprintf("%-14s %d x %d\n", nm, nrow(get(nm)), ncol(get(nm))))
  cat("```\n\n")

  cat("## Categorical distributions (raw_named)\n\n```\n")
  cat_vars <- c("AAST Grade", "Gender (Male)", "Race", "FAST Positive", "FAST+ with Hypotension",
                "Contrast Extravasation (CT)", "Hemoperitoneum (CT)", "Pseudoaneurysm (CT)",
                "Shattered Spleen", "Subcapsular Hematoma", "Received Blood", "MTP",
                "Index Management Success", "Index Management Strategy", "IR Procedure", "Splenectomy",
                "Mortality", "Splenic Salvage", "Acute Kidney Injury", "Pneumonia", "Sepsis",
                "Pulmonary Embolism", "DVT", "ARDS", "Unplanned Return to OR", "Readmission (72h)")
  for (v in cat_vars) if (v %in% names(raw_named)) {
    tb <- table(raw_named[[v]], useNA = "ifany")
    cat(sprintf("%-28s: %s\n", v, paste(sprintf("%s=%d", names(tb), as.integer(tb)), collapse = "  ")))
  }
  cat("```\n\n")

  cat("## Numeric summaries (raw_named)\n\n```\n")
  num_vars <- c("Age", "BMI", "MAP", "SBP", "DBP", "Heart Rate", "GCS", "ISS",
                "Base Deficit", "RBC (4h, cc)", "Whole Blood (4h, cc)", "Plasma (4h, cc)",
                "Platelets (4h, cc)", "Cryoprecipitate (4h, cc)",
                "Ventilator Days", "ICU LOS (d)", "Hospital LOS (d)")
  for (v in num_vars) if (v %in% names(raw_named)) {
    x <- raw_named[[v]]; q <- quantile(x, c(.25, .5, .75), na.rm = TRUE)
    cat(sprintf("%-22s n=%3d miss=%3d  median=%.1f [%.1f, %.1f]  range %.1f-%.1f\n",
                v, sum(!is.na(x)), sum(is.na(x)), q[2], q[1], q[3],
                min(x, na.rm = TRUE), max(x, na.rm = TRUE)))
  }
  cat("```\n\n")

  cat("## Outcomes by strategy & grade\n\n```\n")
  xt <- function(a, b) { cat(sprintf("\n%s x %s:\n", a, b))
    print(table(raw_named[[a]], raw_named[[b]], useNA = "ifany", dnn = c(a, b))) }
  xt("Index Management Strategy", "Index Management Success")
  xt("Index Management Strategy", "Splenic Salvage")
  xt("Index Management Strategy", "Mortality")
  xt("AAST Grade", "Index Management Success")
  xt("AAST Grade", "Splenic Salvage")
  cat("```\n\n")

  cat("## Table 4 — index success (n/N %)\n\n```\n");  print(as.data.frame(index_tbl));   cat("```\n\n")
  cat("## Table 4 — splenic salvage (n/N %)\n\n```\n"); print(as.data.frame(salvage_tbl)); cat("```\n\n")
  cat("## Table 5 — univariable screen\n\n```\n");      print(as.data.frame(uni_tbl));     cat("```\n\n")
  cat("## Table 6 — multivariable NOM-failure model\n\n```\n"); print(as.data.frame(or_tbl)); cat("```\n")

  sink()
  message("QC written to ", normalizePath(qc, mustWork = FALSE))
}
