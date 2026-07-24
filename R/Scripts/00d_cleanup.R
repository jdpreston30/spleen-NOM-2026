#* 0d: Data cleanup
#+ 0d.1: Main Data Cleanup
#- 0d.1.1: Inclusion/Exclusion
raw_selected <- raw |>
  filter(Inclusion == 1)
#- 0d.1.2: Removing useless variables
raw_pared <- raw_selected |>
  select(-c(
    # Grade duplicates — SpleenAIS is the truth grade variable
    CTGrade, SpleenAIS_A,
    # Redundant encodings of a kept variable
    ISS_A, race_n, GCSEye, GCSVerbal, GCSMotor, No_angio, ORdisposition,
    # Redundant TBI encodings — keep SevereTBI only
    TBI_grade, TBI_yes, TBI_gcs_severe, Severe_3_tbi,
    # quasi-identifiers
    Patientoccupation, Patientjobindustry, agency, DeathLocation, Dischargetospecify,
    PlaceofInjury, Inhouseconsults, EDResusConsults,
    # "*"-flag columns kept out: Intubation (ambiguous — * does NOT match IntubatedinED),
    # HIV / LP_PREHOSP_BLOOD (too rare, n=4), CT_AB / CT_HEAD_ICD10 (~85-90% yes, near-universal),
    # EDthoracotomy (n=1). NOTE: bloodany & RBC are RESCUED (confirmed * = received blood) and
    # recoded to Yes/No in 0d.1.3 — do not drop them here.
    Intubation, HIV, CT_AB, CT_HEAD_ICD10, LP_PREHOSP_BLOOD, EDthoracotomy,
    # Excel time-fragments (stored as day-fractions) and duplicated prehospital timers
    Transportationtime, transportationtimeelapsed, scenetimeelapsed, scenetimeelpsed1,
    scenetimeelpsed2, ANYPHP_ELAPSED2_MINSSC, ANYPHP_ELAPSED2SC, ANYPHP_ELAPSEDSC,
    PHP_ELAPSED_MINSSC_L, PHP_ELAPSEDSC1, PHP_ELAPSEDSC2, TEGTIME, Dayspostfirstintubationtotrach,
    # Free text redundant with coded flags
    CTfindings, IRfindings, IRfindings_A, CTangioGIBleedProtocofindings, Procedure, Procedure_A,
    material, Comments, Comments_A, angio_no_noembo, exclusion2hadItnotforbleeding3angionoembo,
    Orthosurgery, Splenectomy_A, Splenectomy_B, Splenectomy_C, Splenectomy_D,
    splenectomyfilter, splenectomyfilter_A,
    # Second-spleen-event block (95-99% missing; 2nd/3rd event captured by Needed3rdYN)
    `@2Spleen`, Reason, `@2finidings`, `@2.Embolization`, `@2Coil`, `@2Multiplecoil`,
    `@2Gelfoam`, `@2Both`, Plug_A, V164, daysafter,
    # Second-OR-event block (98-99% missing)
    IndicationOR_A, timebetweenhrs_A, ORfindings_A, Laparotomy1Laparoscopy2_A,
    ProcedureinORtospleen_A, ORGrade_A, Complication_A, ORandIR_A, firstORthenIR_A,
    firstIRthenOR_A, IRorOR_A, AnticoagulantTherapy_A, PrehospitalCPR_A,
    TimefromEDDischargetoORminutes_A, TimefromEDDischargetoORHHMM, TimefromEDDischargetoORhours,
    # Near-constant / administrative noise
    new_inclusion, Controldamage, lastQ, V5, `@OR`, `filter_$`, CTContrast, activeextrav,
    InjuryType, ReportofPhysicalAbuse, after_OR_procedure_spleen,
    Bodyregionabdomen, Bodyregionchest, Bodyregionexternal, Bodyregionextremities,
    Bodyregionface, Bodyregionhead, Bodyregionfaceorhead,
    # COVID flags — near-empty, not relevant
    ICD10DXCOVID19Positive, COVID19Positive, COVIDNegative, COVIDstatusNotTested,
    # Ultra-rare comorbidities/complications (<~5 events, no usable variance)
    HxofMyocardialInfarction, CerebrovascularAccidentCVA, Dementia,
    CurrentlyReceivingChemoforCancer, CongenitalAnomalies, DisseminatedCancer,
    FunctionallyDependentHealthStatus, SteroidUse, MajorPsychiatricIllness, ADDADHD,
    Comorbpregnancy, BleedingDisorder, CardiacArrestwCPR, PressureUlceradmitdate2017present,
    DecubitusUlceradmitpriorto2017, DeepSurgicalSiteInfection, ExtremityCompartmentSyndrome,
    OrganSpacerSurgicalSiteInfection, Osteomyelitis, StrokeCVA, SuperficialSurgicalSiteInfection,
    UnplannedIntubation, UnplannedReturntoICU, Delirium, Selfharmecode,
    Prearrivalcardiacarrest, PrehospitalCPR
  ))
#- 0d.1.3: Standardize missingness + rescue the blood flags
# Global: trim whitespace; convert "", common NA-tokens, and the 999 sentinel to real
# NA (999 confirmed always a not-applicable sentinel, never a real value). "*" is NOT
# globally nulled — it means "yes" in the rescued blood flags, recoded explicitly first.
{
  na_tokens <- c("", "na", "n/a", "n\\a", "nan", "null", "none", "nil",
                 ".", "-", "--", "?", "unknown", "unk", "missing", "tbd", "999")
  clean_cell <- function(x) {
    if (is.character(x)) {
      x <- trimws(x)
      x[tolower(x) %in% na_tokens] <- NA_character_
      x
    } else if (is.numeric(x)) {
      x[x == 999] <- NA
      x
    } else x
  }
  raw_std <- raw_pared |>
    # Rescue blood flags first (before global cleanup): * = received, blank/other = not
    mutate(
      bloodany = factor(ifelse(!is.na(bloodany) & trimws(as.character(bloodany)) == "*",
                               "Yes", "No"), levels = c("No", "Yes")),
      RBC      = factor(ifelse(!is.na(RBC) & trimws(as.character(RBC)) == "*",
                               "Yes", "No"), levels = c("No", "Yes"))
    ) |>
    mutate(across(!c(bloodany, RBC), clean_cell))
  # Validate: no "999" survives anywhere; blood flags are clean 2-level factors
  n999 <- sum(vapply(raw_std, function(x)
    if (is.factor(x)) 0L else sum(trimws(as.character(x)) == "999", na.rm = TRUE),
    integer(1)))
  stopifnot(
    n999 == 0,
    identical(levels(raw_std$bloodany), c("No", "Yes")),
    identical(levels(raw_std$RBC), c("No", "Yes")),
    !anyNA(raw_std$bloodany), !anyNA(raw_std$RBC)
  )
}
#+ 0d.2: Deriving analysis variables
#- 0d.2.1: Management strategy — recode ARM/Second_ARM into descriptive labels
# Mirrors the PKI IR grouping: ARM 3 = the angiography/IR pathway (whether or not
# an embolization was ultimately performed). ARM 1 = operative; ARM 2 = observation.
# ir_procedure is the within-IR sub-type (embolization vs diagnostic angiogram only),
# analogous to PKI's IR_max1_derived, and is NA outside the IR arm.
{
  raw_derived <- raw_std |>
    mutate(
      management_strategy = factor(
        case_when(
          ARM == 1 ~ "Operative",
          ARM == 3 ~ "Interventional Radiology",   # embolization + angio-only both here
          ARM == 2 ~ "Observation",
          TRUE     ~ NA_character_
        ),
        levels = c("Observation", "Interventional Radiology", "Operative")
      ),
      ir_procedure = factor(
        case_when(
          ARM != 3        ~ NA_character_,
          Second_ARM == 3 ~ "Embolization",
          Second_ARM == 4 ~ "Diagnostic Angiogram",
          TRUE            ~ NA_character_
        ),
        levels = c("Diagnostic Angiogram", "Embolization")
      )
    )
  # Validate: strategy fully classified and internally consistent; ir_procedure
  # present for exactly the IR arm and matching Second_ARM.
  stopifnot(
    !anyNA(raw_derived$management_strategy),
    all((raw_derived$management_strategy == "Operative")    == (raw_derived$ARM == 1)),
    all((raw_derived$management_strategy == "Interventional Radiology") == (raw_derived$ARM == 3)),
    all((raw_derived$management_strategy == "Observation")  == (raw_derived$ARM == 2)),
    all(is.na(raw_derived$ir_procedure) == (raw_derived$ARM != 3)),
    all((raw_derived$ir_procedure == "Embolization")[raw_derived$ARM == 3] ==
        (raw_derived$Second_ARM == 3)[raw_derived$ARM == 3])
  )
}
#- 0d.2.2: Early death, index success, and splenic salvage (PKI standard)
# early_death (<24h from arrival) is excluded (set NA) from the success/salvage
# outcomes, matching PKI's death_24h handling. Splenectomy counts as a FAILURE of
# both index management and salvage — analogous to nephrectomy in PKI.
# los_hrs is the numeric form of HOSP_LOS_HRS (stored as text in the sheet).
{
  raw_outcomes <- raw_derived |>
    mutate(
      los_hrs     = suppressWarnings(as.numeric(HOSP_LOS_HRS)),
      early_death = !is.na(mortality) & mortality == 1 & !is.na(los_hrs) & los_hrs < 24,
      index_success = factor(
        case_when(
          early_death                              ~ NA_character_,
          splenectomy == 1                         ~ "N",   # organ removed — not a success
          Second_P_spleen == 1 | Needed3rdYN == 1  ~ "N",   # needed a further procedure
          TRUE                                     ~ "Y"
        ),
        levels = c("N", "Y")
      ),
      splenic_salvage = factor(
        case_when(
          early_death       ~ NA_character_,
          splenectomy == 1  ~ "N",   # lost the spleen
          TRUE              ~ "Y"
        ),
        levels = c("N", "Y")
      )
    )
  # Validate: early_death fully defined; outcomes NA iff early death; failure logic exact
  no_ed <- !raw_outcomes$early_death
  stopifnot(
    !anyNA(raw_outcomes$early_death),
    all(is.na(raw_outcomes$index_success)   == raw_outcomes$early_death),
    all(is.na(raw_outcomes$splenic_salvage) == raw_outcomes$early_death),
    all((raw_outcomes$splenic_salvage == "N")[no_ed] == (raw_outcomes$splenectomy == 1)[no_ed]),
    all((raw_outcomes$index_success == "Y")[no_ed] ==
        (raw_outcomes$splenectomy == 0 & raw_outcomes$Second_P_spleen == 0 &
           raw_outcomes$Needed3rdYN == 0)[no_ed])
  )
}
#+ 0d.3: Tier-2 cleanup — types, flags, categoricals (analysis set)
#- 0d.3.1: Coerce text-stored numerics, recode YES/blank flags to No/Yes, normalize
# key categoricals. Decisions: antiplateletschart dropped (only 1 positive); tox coded
# Positive/Negative/NA(=not tested); Embolization/Access/Clossure/FAST left raw for now.
{
  num_char <- c("lacticacidmmolL", "LabsBaseDeficitAccess", "LabsHematocrit", "LabsINR",
                "RTS", "TRISS", "Temperature", "Height", "Weight", "resp_rate",
                "pre_hospital_SBP", "Pre_HR", "TimetofirstCT", "ICUDays")
  flag_cols <- c("Diabetes", "Cirrhosis", "ChronicObstructivePulmonaryDisease",
                 "CongestiveHeartFailure", "HypertensionRequiringMedication", "CurrentSmoker",
                 "AlcoholuseDisorder", "ChronicRenalFailure", "AnticoagulantTherapy",
                 "AcuteKidneyInjury", "Pneumonia", "Sepsis", "PulmonaryEmbolism",
                 "DVTThrombophlebitis", "UnplannedReturntoOR", "AcuteLungInjuryARDS",
                 "Readmissionwithin72hours")
  # blank/NA -> No; "YES" -> Yes
  yn_flag <- function(x)
    factor(ifelse(!is.na(x) & toupper(trimws(as.character(x))) == "YES", "Yes", "No"),
           levels = c("No", "Yes"))
  # tox: Positive / Negative / NA(not tested)
  tox3 <- function(x) {
    x <- trimws(as.character(x))
    factor(case_when(
      grepl("^Yes", x, ignore.case = TRUE)        ~ "Positive",
      grepl("Not Tested", x, ignore.case = TRUE)  ~ NA_character_,
      grepl("^No", x, ignore.case = TRUE)         ~ "Negative",
      TRUE                                        ~ NA_character_
    ), levels = c("Negative", "Positive"))
  }
  raw_clean <- raw_outcomes |>
    mutate(across(all_of(num_char), ~ suppressWarnings(readr::parse_number(.x)))) |>
    mutate(across(all_of(flag_cols), yn_flag)) |>
    mutate(
      Gender                  = factor(Gender),
      Race                    = factor(case_when(
        is.na(Race)                         ~ NA_character_,
        Race == "White"                     ~ "White",
        Race == "Black or African American" ~ "Black",
        TRUE                                ~ "Other"
      ), levels = c("White", "Black", "Other")),
      ModeofArrival           = factor(ModeofArrival),
      Admittingservice        = factor(na_if(trimws(Admittingservice), "Not Applicable")),
      ResponseActivationLevel = factor(na_if(trimws(ResponseActivationLevel), "Not Applicable")),
      IntubatedinED = factor(ifelse(trimws(IntubatedinED) == "No, No", "No",
                                    trimws(IntubatedinED)), levels = c("No", "Yes")),
      ArrivedFrom   = factor(na_if(trimws(ArrivedFrom), "0")),
      EDDisposition = factor(case_when(
        grepl("ICU", EDDisposition)                 ~ "ICU",
        grepl("Floor", EDDisposition)               ~ "Floor",
        grepl("Telemetry|Step-Down", EDDisposition) ~ "Step-Down",
        grepl("Operating", EDDisposition)           ~ "Operating Room",
        grepl("Not Applicable", EDDisposition)      ~ NA_character_,
        TRUE                                        ~ EDDisposition
      )),
      etoh_use = tox3(ToxicologyETOHuseIndicator),
      drug_use = tox3(ToxicologyDruguseIndicator)
    ) |>
    select(-antiplateletschart)
  # Validate: numerics coerced, flags are complete No/Yes factors, antiplatelets gone
  stopifnot(
    all(vapply(raw_clean[num_char], is.numeric, logical(1))),
    all(vapply(raw_clean[flag_cols], function(x)
      is.factor(x) && !anyNA(x) && identical(levels(x), c("No", "Yes")), logical(1))),
    !("antiplateletschart" %in% names(raw_clean)),
    is.factor(raw_clean$EDDisposition), is.factor(raw_clean$Gender)
  )
}
#- 0d.3.2: Derive MAP and a period-spanning MTP flag
# MAP = (2*DBP + SBP)/3. MTP coalesces the two era-specific fields (pre- vs post-mid-2020)
# into one flag covering the whole period, then drops the source columns.
{
  raw_ready <- raw_clean |>
    mutate(
      MAP = (2 * VitalsDBP + VitalsSBP) / 3,
      MTP = factor(case_when(
        toupper(trimws(as.character(MTPmid2020ampprior))) == "YES" ~ "Yes",
        toupper(trimws(as.character(MBPmid2020current)))  == "YES" ~ "Yes",
        toupper(trimws(as.character(MTPmid2020ampprior))) == "NO"  ~ "No",
        TRUE                                                       ~ NA_character_
      ), levels = c("No", "Yes"))
    ) |>
    select(-c(MTPmid2020ampprior, MBPmid2020current))
  stopifnot(is.numeric(raw_ready$MAP), is.factor(raw_ready$MTP))
}
#+ 0d.4: Data oddities corrections (documented manual fixes)
# One patient has an implausibly low recorded height (<120 cm) that produces an
# impossible BMI (>80). Recomputing BMI from height/weight reproduces the bad value,
# confirming the height is the error, so both height and BMI are nulled (weight kept).
{
  raw_corrected <- raw_ready |>
    mutate(
      Height = if_else(!is.na(Height) & Height < 120, NA_real_, Height),
      BMI    = if_else(!is.na(BMI) & (BMI >= 80 | BMI < 12), NA_real_, BMI)
    )
  stopifnot(
    max(raw_corrected$BMI, na.rm = TRUE) < 80,
    all(is.na(raw_corrected$Height) | raw_corrected$Height >= 120)
  )
}
#+ 0d.5: Display-renamed analysis frame for table production (raw_named)
# Recode binaries to Yes/No and grade to IV/V, then rename to publication labels.
# (Early deaths are retained in course variables here; note in table captions.)
{
  yn <- function(x) factor(ifelse(x == 1, "Yes", "No"), levels = c("No", "Yes"))
  raw_named <- raw_corrected |>
    mutate(
      `AAST Grade`    = factor(dplyr::recode(as.character(SpleenAIS), "4" = "IV", "5" = "V"),
                               levels = c("IV", "V")),
      `Gender (Male)` = factor(ifelse(Gender == "Male", "Y", "N"), levels = c("N", "Y")),
      Mortality       = yn(mortality),
      `FAST Positive` = yn(Fast_P_N),
      `FAST+ with Hypotension`      = yn(Fast_hypoten),
      `Contrast Extravasation (CT)` = yn(CTextrav),
      `Hemoperitoneum (CT)`         = yn(CT_Hemoperitoneum),
      `Pseudoaneurysm (CT)`         = yn(CT_pseudoane),
      `Shattered Spleen`            = yn(Shattered),
      `Subcapsular Hematoma`        = yn(Subcapsualr_hematoma),
      Splenectomy                   = yn(splenectomy),
      # Composite of the major complications (rare individually); NA for early deaths
      `Any Major Complication` = factor(case_when(
        early_death ~ NA_character_,
        AcuteKidneyInjury == "Yes" | Pneumonia == "Yes" | Sepsis == "Yes" |
          PulmonaryEmbolism == "Yes" | DVTThrombophlebitis == "Yes" |
          AcuteLungInjuryARDS == "Yes" | UnplannedReturntoOR == "Yes" ~ "Yes",
        TRUE ~ "No"
      ), levels = c("No", "Yes")),
      # Exclude early (<24 h) deaths from survival-dependent course/outcome
      # variables (PKI standard) — they didn't survive long enough to be at risk.
      across(c(TotalVentDays, TotalICUdays, TotalHospitalDays,
               AcuteKidneyInjury, Pneumonia, Sepsis, PulmonaryEmbolism,
               DVTThrombophlebitis, AcuteLungInjuryARDS, UnplannedReturntoOR,
               Readmissionwithin72hours),
             ~ replace(.x, early_death, NA))
    ) |>
    rename(
      GCS = GCSTotal, SBP = VitalsSBP, DBP = VitalsDBP, `Heart Rate` = VitalsPulseRate,
      `Initial Lactate` = lacticacidmmolL, `Base Deficit` = LabsBaseDeficitAccess,
      Hematocrit = LabsHematocrit, INR = LabsINR,
      `Received Blood` = bloodany,
      `Whole Blood (4h, cc)` = Wholeblood4hrsCCs, `RBC (4h, cc)` = Blood4hrsCCs,
      `Plasma (4h, cc)` = Plasma4hrsCCs, `Platelets (4h, cc)` = Platelets4hrsCCs,
      `Cryoprecipitate (4h, cc)` = Cryoprecipitate4hrsCCs,
      COPD = ChronicObstructivePulmonaryDisease, `Congestive Heart Failure` = CongestiveHeartFailure,
      Hypertension = HypertensionRequiringMedication, `Current Smoker` = CurrentSmoker,
      `Alcohol Use Disorder` = AlcoholuseDisorder, `Chronic Renal Failure` = ChronicRenalFailure,
      `Anticoagulant Therapy` = AnticoagulantTherapy,
      `Index Management Success` = index_success, `Index Management Strategy` = management_strategy,
      `IR Procedure` = ir_procedure, `Splenic Salvage` = splenic_salvage,
      `Acute Kidney Injury` = AcuteKidneyInjury, `Pulmonary Embolism` = PulmonaryEmbolism,
      DVT = DVTThrombophlebitis, ARDS = AcuteLungInjuryARDS,
      `Unplanned Return to OR` = UnplannedReturntoOR, `Readmission (72h)` = Readmissionwithin72hours,
      `Ventilator Days` = TotalVentDays, `ICU LOS (d)` = TotalICUdays, `Hospital LOS (d)` = TotalHospitalDays
    )
}

