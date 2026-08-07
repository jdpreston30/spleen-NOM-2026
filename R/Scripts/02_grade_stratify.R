#* 2: Stratification by AAST grade (Table 2)
#+ 2.1: Same variable set as Table 1, grouped by grade instead of strategy
# Total column is shown so the table stands alone. Normality routing is left entirely to
# ternG's own assessment in every table — no force_* overrides.
T2_data <- raw_named |>
  select(
    # Grouping variable
    `AAST Grade`,
    # Demographics
    Age, `Gender (Male)`, BMI, Race,
    # Injury features and vital signs
    GCS, MAP, `Heart Rate`, ISS,
    `FAST Positive`, `FAST+ with Hypotension`, `Contrast Extravasation (CT)`,
    `Hemoperitoneum (CT)`, `Pseudoaneurysm (CT)`, `Shattered Spleen`, `Subcapsular Hematoma`,
    # Lab values
    `Base Deficit`,
    # Blood products (4 h)
    `Received Blood`, `RBC (4h, cc)`, `Whole Blood (4h, cc)`, `Plasma (4h, cc)`, MTP,
    # Index management
    `Index Management Success`, `Index Management Strategy`,
    # Clinical course and outcomes
    Mortality, `Splenic Salvage`, `Any Major Complication`,
    `Acute Kidney Injury`, Pneumonia, `Readmission (72h)`,
    `Ventilator Days`, `ICU LOS (d)`, `Hospital LOS (d)`
  )
#+ 2.2: Build Table 2 stratified by AAST grade (IV vs V — no grade III in this cohort)
T2 <- ternG(
  data = T2_data,
  group_var = "AAST Grade",
  group_order = c("IV", "V"),
  consider_normality = "ROBUST",
  smart_rename = FALSE,
  round_intg = FALSE,
  show_total = TRUE,
  table_font_size = 9,
  methods_doc = FALSE,
  table_caption = "Table 2. Demographic, clinical, and outcomes data in nonoperatively managed blunt splenic injury patients stratified by AAST injury grade. This cohort comprised only grade IV and V injuries. Values are n (%), median [IQR], or mean ± SD as appropriate. p-values < 0.05 are printed in bold.",
  abbreviation_footnote = "Abbreviations: AAST, American Association for the Surgery of Trauma; GCS, Glasgow Coma Scale; MAP, mean arterial pressure; ISS, Injury Severity Score; FAST, focused assessment with sonography for trauma; CT, computed tomography; MTP, massive transfusion protocol; ICU, intensive care unit; LOS, length of stay.",
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "GCS",
    "Lab Values"                      = "Base Deficit",
    "Blood Products (4 h)"            = "Received Blood",
    "Index Management"                = "Index Management Success",
    "Clinical Course and Outcomes"    = "Mortality"
  )
)
#+ 2.3: Restore lower-case unit labels
T2 <- fix_unit_labels(T2)
