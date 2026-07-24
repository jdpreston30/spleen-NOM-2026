#* 2: Stratification by management strategy (Table 2)
#+ 2.1: Reuse the Table 1 variable set, strategy first
T2_data <- T1_data |>
  select(`Index Management Strategy`, everything())
#+ 2.2: Build Table 2 stratified by index management strategy
T2 <- ternG(
  data = T2_data,
  group_var = "Index Management Strategy",
  group_order = c("Observation", "Interventional Radiology", "Operative"),
  force_ordinal = c("AAST Grade"),
  consider_normality = "ROBUST",
  smart_rename = FALSE,
  round_intg = FALSE,
  show_total = FALSE,
  post_hoc = TRUE,
  table_font_size = 9,
  methods_doc = FALSE,
  table_caption = "Table 2. Demographic, clinical, and outcomes data in blunt splenic injury patients stratified by index management strategy. Values are n (%), median [IQR], or mean ± SD as appropriate. Nonoperative management comprised observation and interventional radiology (embolization or diagnostic angiography). p-values < 0.05 are printed in bold.",
  abbreviation_footnote = "Abbreviations: AAST, American Association for the Surgery of Trauma; GCS, Glasgow Coma Scale; MAP, mean arterial pressure; SBP, systolic blood pressure; DBP, diastolic blood pressure; ISS, Injury Severity Score; NISS, New Injury Severity Score; FAST, focused assessment with sonography for trauma; CT, computed tomography; INR, international normalized ratio; RTS, Revised Trauma Score; TRISS, Trauma and Injury Severity Score; MTP, massive transfusion protocol; COPD, chronic obstructive pulmonary disease; IR, interventional radiology; DVT, deep vein thrombosis; ARDS, acute respiratory distress syndrome; ICU, intensive care unit; LOS, length of stay.",
  variable_footnote = c(
    "Index Management Success" = "No further spleen-directed procedure or splenectomy following the index strategy, excluding early (<24 h) deaths."
  ),
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "AAST Grade",
    "Lab Values"                      = "Initial Lactate",
    "Blood Products (4 h)"            = "Received Blood",
    "Comorbidities"                   = "Diabetes",
    "Index Management"                = "Index Management Success",
    "Clinical Course and Outcomes"    = "Mortality"
  )
)
