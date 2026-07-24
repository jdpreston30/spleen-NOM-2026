#* 1: Descriptive statistics (Table 1)
#+ 1.1: Assemble the analysis variable set in display order
T1_data <- raw_named |>
  select(
    # Demographics
    Age, `Gender (Male)`, BMI, Race,
    # Injury features and vital signs
    `AAST Grade`, GCS, MAP, `Heart Rate`, ISS,
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
#+ 1.2: Build Table 1
T1 <- ternD(
  data = T1_data,
  consider_normality = "ROBUST",
  smart_rename = FALSE,
  round_intg = FALSE,
  table_font_size = 9,
  methods_doc = FALSE,
  table_caption = "Table 1. Demographic, clinical, and outcomes data for the blunt splenic injury cohort. Values are n (%), median [IQR], or mean ± SD as appropriate. Index management success and splenic salvage exclude early (<24 h) deaths; splenectomy is not counted as index management success. Serum lactate, hematocrit, and INR were recorded in fewer than 30% of patients and are not reported.",
  abbreviation_footnote = "Abbreviations: AAST, American Association for the Surgery of Trauma; GCS, Glasgow Coma Scale; MAP, mean arterial pressure; SBP, systolic blood pressure; DBP, diastolic blood pressure; ISS, Injury Severity Score; NISS, New Injury Severity Score; FAST, focused assessment with sonography for trauma; CT, computed tomography; INR, international normalized ratio; RTS, Revised Trauma Score; TRISS, Trauma and Injury Severity Score; MTP, massive transfusion protocol; COPD, chronic obstructive pulmonary disease; IR, interventional radiology; DVT, deep vein thrombosis; ARDS, acute respiratory distress syndrome; ICU, intensive care unit; LOS, length of stay.",
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "AAST Grade",
    "Lab Values"                      = "Base Deficit",
    "Blood Products (4 h)"            = "Received Blood",
    "Index Management"                = "Index Management Success",
    "Clinical Course and Outcomes"    = "Mortality"
  )
)
