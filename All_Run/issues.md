# Data issues & decisions — spleen-NOM-2026

## Questions for the surgical team
- I excluded anyone in the "inclusion" column with 0. Is this correct?
- Any usage of the "Multicenter" column?
- CTGrade and SpleenAIS differ for 20 patients (SpleenAIS used as the truth grade).
- Do we consider patients who went to OR and got splenectomy a "success" for index management analysis? In Courtney's PKI analysis, we considered nephrectomy a failure. I imagine we apply the same standard here (splenectomy at any point = failure). — **RESOLVED: yes, splenectomy = failure.**
- A patient who got angio but no embo — IR group or observation/CM? In PKI, angio-no-embo stayed in the "IR" index group (original intent was IR). — **RESOLVED: kept in the IR arm; `ir_procedure` distinguishes embolization vs diagnostic angiogram.**
- Early death (<24 h) is hard to count in a success/failure analysis; PKI excluded them from that analysis (still reported descriptively). Apply the same here? — **RESOLVED: yes, early deaths excluded (NA) from index success, splenic salvage, and survival-dependent course variables (LOS, complications).**
- Confirm the validity of the early-death coding. — **VALIDATED: `mortality==1 & hospital LOS <24h` (n=12); cross-checked against DeathLocation (early deaths cluster in ED/OR/PACU), ED→OR disposition, and crash markers.**

## Scope decision (surgical team, 2026-07-24): NOM-only cohort
- **Patients whose index management was operative are EXCLUDED from all analysis.** They are retained only as descriptive/figure context ("just for us to talk about for the fun alluvial figure"). Analysis cohort = Observation + IR.
- **Patients who had surgery first and IR later are also excluded** ("since initial surgery, still not technically NOM"). Verified in the data: **zero** `ARM 2/3` patients had an operation first, so `ARM != 1` cleanly captures the NOM cohort.
- **Patients who failed NOM and later went to OR are RETAINED** — that is the NOM-failure outcome.
- **IR arm is intention-to-treat**: patients taken to angiography without embolization stay in the IR group (matching PKI), with a dedicated sub-analysis (Table 5) comparing embolized vs non-embolized.
- **Consequence:** the paper can no longer make OR-vs-NOM comparisons, and the dramatic salvage contrast (3% operative vs ~90% NOM) is lost; the message becomes "NOM preserves ~90% of spleens." Table 2 also drops from a 3-group to a 2-group comparison, so all p-values change.
- **Note:** the team referred to "the fun alluvial figure you made" — no alluvial exists yet for the spleen project (that was Courtney's PKI figure). If they want one showing all patients including the operative arm, it still needs to be built.

## Modelling decisions (documented)
- **Predictors are pre-specified on clinical grounds, not selected by p-value.** Grade is retained regardless of significance (severity confounder). ISS was rejected as a predictor because it is computed post hoc (not known at the NOM-decision timepoint). MAP was chosen over a dichotomized SBP<90 as the hemodynamic axis (continuous, ~99% complete, available at presentation).
- **Transfusion axis = MTP activation, not "received any blood."** Rationale: MTP specifically marks massive hemorrhage, whereas any-transfusion is a low bar (53% of the cohort). MTP was not a candidate at initial model specification only because its two era-specific source columns made it appear 71% missing; once reconciled during cleaning it became complete and analyzable. Both variables are reported univariably in Table 5. Note the AIC difference between the two model versions is negligible (185.1 vs 186.5) and is *not* the basis for the choice.
- **Model size is capped at 3 predictors** (~36 failure events ≈ 12 events per predictor). MTP and "received blood" are not strongly collinear (φ = 0.26), but including both would drop to ~9 events per predictor and was avoided.

## Data integrity / quality issues (discovered during cleaning & QC)

### Corrected / handled in the pipeline
- **BMI = 255.9 (ID 465):** recorded Height was 57.5 cm (physically impossible), which drove the BMI. Height and BMI nulled; Weight (84.6 kg) retained. Fix documented in `00d` step `0d.4`.
- **`999` sentinel:** used across many columns as "not applicable / missing." Confirmed never a real value (all real ranges far below 999) and converted globally to `NA` (`0d.1.3`).
- **`*` placeholder:** means "yes" in flag columns. Confirmed for `bloodany`/`RBC` (rescued → Yes/No). `Intubation` `*` was ambiguous (did NOT match `IntubatedinED`) → dropped. `HIV`/`CT_AB`/`CT_HEAD_ICD10`/`LP_PREHOSP_BLOOD`/`EDthoracotomy` dropped (too rare or near-universal). Note `*` means "missing" (not "yes") in the `_A` time columns.
- **MTP split by era:** `MTPmid2020ampprior` (pre-) + `MBPmid2020current` (post-mid-2020) coalesced into a single period-spanning `MTP` flag (`0d.3.2`); still ~46% missing.
- **21 fully-empty columns** removed from the source sheet (`.A/clean.py`).
- **Text-stored numerics** (labs/vitals) coerced with `readr::parse_number`, handling `"not done"`, `"transfer"`, `"150, unk"`, etc.
- **Whitespace/case:** trimmed globally; `EDDisposition` "ICU" spellings merged, `IntubatedinED` "No, No" → "No", `ArrivedFrom` "0" → `NA`.

### OPEN — need a decision
- **Zero vitals:** `SBP`/`DBP` (and therefore derived `MAP`) have a minimum of 0 — likely arrest-on-arrival or data-entry zeros. **Currently left as-is (treated as real).** No PKI precedent (PKI had no zero-vitals handling). Decision needed: null zeros as missing, or keep as true arrest values? Affects the SBP/DBP/MAP medians.
- **Age ≥ 90 (max 95):** for HIPAA Safe Harbor de-identification, ages ≥ 89/90 should be reported as "≥90" in any published table. Analysis currently uses true age; a display cap is not yet applied.

### Known limitations vs the PKI analysis (documented; accepted)
- **Grade is IV/V only** — `SpleenAIS` has no grade III, so grade stratification is 2-level (PKI was III/IV/V).
- **Operative detail = splenectomy Y/N only** — no splenorrhaphy / partial-splenectomy / exploration-only granularity (PKI had renorrhaphy / topical hemostatic / packing / exploration-only).
- **No `TXA`, no serial/max lactate, no creatinine** — reported in PKI, not available here.
- **Sparse labs dropped from tables** — lactate (84% missing, mostly "not done"), hematocrit (71%), INR (72%) omitted (footnoted); base deficit (36% missing) retained. Severity reported as ISS only (NISS/RTS/TRISS dropped to match PKI).
- **Blood-product volumes ~33% missing and blank ≠ 0** (genuine missingness, not zeros) — `bloodany` (complete) is the resuscitation indicator; volumes reported descriptively only.
- **CT-finding variables ~40% missing** — inherent to how CT detail was coded.
- **NOM-failure model is subject to selection bias** — the model is fit only among patients *selected* for nonoperative management (observation + IR); the unstable/highest-risk patients went straight to OR and are excluded. Associations therefore reflect predictors *within the NOM-selected population*, not the full injured cohort, and can show paradoxical signs (e.g., FAST-positive appeared protective univariably). State explicitly as a limitation.

### Data-structure notes (no action)
- `ID` ranges beyond the row count (e.g., 465) — a de-identified study/enrollment ID with gaps, NOT an MRN. The MRN and other identifiers live only in the identified `.sav`, which is never committed. (See PHI boundary.)
