#* 1: Cohort description and stratification by nonoperative strategy (Table 1)
#! The Total column serves as the cohort descriptive table, so no separate ternD table
#! is produced — this avoids ternD and ternG making independent normality calls on the
#! same variables (which previously reported mean ± SD in one table and median [IQR]
#! in another). All normality routing is therefore decided once, here.
#+ 1.1: Assemble the analysis variable set in display order, strategy first
T1_data <- raw_named |>
  select(
    # Grouping variable
    `Index Management Strategy`,
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
    `Index Management Success`,
    # Clinical course and outcomes
    Mortality, `Splenic Salvage`, `Any Major Complication`,
    `Acute Kidney Injury`, Pneumonia, `Readmission (72h)`,
    `Ventilator Days`, `ICU LOS (d)`, `Hospital LOS (d)`
  )
#+ 1.2: Build Table 1 — total cohort plus Observation vs Interventional Radiology
T1 <- ternG(
  data = T1_data,
  group_var = "Index Management Strategy",
  group_order = c("Observation", "Interventional Radiology"),
  force_ordinal = c("AAST Grade"),
  consider_normality = "ROBUST",
  smart_rename = FALSE,
  round_intg = FALSE,
  show_total = TRUE,
  table_font_size = 9,
  methods_doc = FALSE,
  table_caption = "Table 1. Demographic, clinical, and outcomes data for high-grade blunt splenic injury patients managed nonoperatively, overall and stratified by index nonoperative strategy. Patients whose index management was operative were excluded. Values are n (%), median [IQR], or mean ± SD as appropriate. The interventional radiology group is defined by intention to treat and includes patients taken to angiography who were not ultimately embolized. Splenectomy is counted as a failure of nonoperative management. Serum lactate, hematocrit, and INR were recorded in fewer than 30% of patients and are not reported. p-values < 0.05 are printed in bold.",
  abbreviation_footnote = "Abbreviations: AAST, American Association for the Surgery of Trauma; GCS, Glasgow Coma Scale; MAP, mean arterial pressure; ISS, Injury Severity Score; FAST, focused assessment with sonography for trauma; CT, computed tomography; MTP, massive transfusion protocol; ICU, intensive care unit; LOS, length of stay.",
  variable_footnote = c(
    "Index Management Success" = "No further spleen-directed procedure or splenectomy following the index strategy, excluding early (<24 h) deaths."
  ),
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "AAST Grade",
    "Lab Values"                      = "Base Deficit",
    "Blood Products (4 h)"            = "Received Blood",
    "Index Management"                = "Index Management Success",
    "Clinical Course and Outcomes"    = "Mortality"
  )
)
#+ 1.3: Restore lower-case unit labels (TernTables title-cases them)
T1 <- fix_unit_labels(T1)
