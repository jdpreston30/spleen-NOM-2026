#* 4: Sub-analysis within the IR arm — embolized vs not embolized (Table 4)
#! Requested by the surgical team: of patients taken to IR, compare those who were
#! embolized against those who underwent angiography without embolization.
#! NOTE: the non-embolized group is small; this is descriptive and underpowered.
#+ 4.1: Restrict to the IR arm and assemble the comparison variables
T4_data <- raw_named |>
  filter(`Index Management Strategy` == "Interventional Radiology") |>
  select(
    `IR Procedure`,
    # Demographics
    Age, `Gender (Male)`, BMI,
    # Injury features and vital signs
    `AAST Grade`, GCS, MAP, `Heart Rate`, ISS,
    `FAST Positive`, `FAST+ with Hypotension`, `Contrast Extravasation (CT)`,
    `Hemoperitoneum (CT)`, `Pseudoaneurysm (CT)`, `Shattered Spleen`, `Subcapsular Hematoma`,
    # Lab values
    `Base Deficit`,
    # Blood products (4 h)
    `Received Blood`, `RBC (4h, cc)`, MTP,
    # Outcomes
    `Index Management Success`, `Splenic Salvage`, Mortality, `Any Major Complication`,
    `ICU LOS (d)`, `Hospital LOS (d)`
  ) |>
  droplevels()
#+ 4.2: Build Table 5 stratified by IR procedure type
T4 <- ternG(
  data = T4_data,
  group_var = "IR Procedure",
  group_order = c("Diagnostic Angiogram", "Embolization"),
  consider_normality = "ROBUST",
  smart_rename = FALSE,
  round_intg = FALSE,
  show_total = TRUE,
  table_font_size = 9,
  methods_doc = FALSE,
  table_caption = "Table 4. Comparison of patients within the interventional radiology arm who underwent splenic artery embolization versus angiography without embolization. Values are n (%), median [IQR], or mean ± SD as appropriate. The non-embolized group is small, so comparisons are descriptive and underpowered. p-values < 0.05 are printed in bold.",
  abbreviation_footnote = "Abbreviations: AAST, American Association for the Surgery of Trauma; GCS, Glasgow Coma Scale; MAP, mean arterial pressure; ISS, Injury Severity Score; FAST, focused assessment with sonography for trauma; CT, computed tomography; MTP, massive transfusion protocol; ICU, intensive care unit; LOS, length of stay.",
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "AAST Grade",
    "Lab Values"                      = "Base Deficit",
    "Blood Products (4 h)"            = "Received Blood",
    "Outcomes"                        = "Index Management Success"
  )
)

#+ Restore lower-case unit labels
T4 <- fix_unit_labels(T4)
