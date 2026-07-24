#* 3: Stratification by AAST grade (Table 3)
#+ 3.1: Grade first, then the analysis variables
T3_data <- raw_named |>
  select(
    `AAST Grade`,
    # Demographics
    Age, `Gender (Male)`, BMI, Race,
    # Injury features and vital signs
    GCS, MAP, `Heart Rate`, ISS,
    `FAST Positive`, `FAST+ with Hypotension`, `Contrast Extravasation (CT)`,
    `Hemoperitoneum (CT)`, `Pseudoaneurysm (CT)`, `Shattered Spleen`, `Subcapsular Hematoma`,
    # Lab values (lactate/hematocrit/INR omitted — recorded in <30% of patients)
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
#+ 3.2: Build Table 3 stratified by AAST grade (IV vs V — no grade III in this cohort)
T3 <- ternG(
  data = T3_data,
  group_var = "AAST Grade",
  group_order = c("IV", "V"),
  consider_normality = "ROBUST",
  smart_rename = FALSE,
  round_intg = FALSE,
  show_total = FALSE,
  post_hoc = TRUE,
  table_font_size = 9,
  methods_doc = FALSE,
  table_caption = "Table 3. Demographic, clinical, and outcomes data in blunt splenic injury patients stratified by AAST injury grade. This cohort comprised only grade IV and V injuries. Values are n (%), median [IQR], or mean ± SD as appropriate. p-values < 0.05 are printed in bold.",
  abbreviation_footnote = "Abbreviations: AAST, American Association for the Surgery of Trauma; GCS, Glasgow Coma Scale; MAP, mean arterial pressure; SBP, systolic blood pressure; DBP, diastolic blood pressure; ISS, Injury Severity Score; NISS, New Injury Severity Score; FAST, focused assessment with sonography for trauma; CT, computed tomography; INR, international normalized ratio; RTS, Revised Trauma Score; TRISS, Trauma and Injury Severity Score; MTP, massive transfusion protocol; COPD, chronic obstructive pulmonary disease; IR, interventional radiology; DVT, deep vein thrombosis; ARDS, acute respiratory distress syndrome; ICU, intensive care unit; LOS, length of stay.",
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "GCS",
    "Lab Values"                      = "Base Deficit",
    "Blood Products (4 h)"            = "Received Blood",
    "Index Management"                = "Index Management Success",
    "Clinical Course and Outcomes"    = "Mortality"
  )
)
