#* ALL RUN — spleen-NOM-2026
# Master pipeline runner. Source this file to execute the full analysis.
# Each script is sourced in order; 00x scripts handle environment, packages,
# and utility loading before numbered analysis scripts begin.
# Edit config_dynamic.yaml before running on a new machine.
{
source("R/Utilities/Helpers/load_dynamic_config.R")
config <- load_dynamic_config(computer = "auto", config_path = "All_Run/config_dynamic.yaml")
source("R/Scripts/00a_environment_setup.R")
source("R/Scripts/00b_setup.R")
source("R/Scripts/00c_import.R")
source("R/Scripts/00d_cleanup.R")
#+ Analysis scripts
source("R/Scripts/01_descriptive.R")     # Table 1
source("R/Scripts/02_mgmt_stratify.R")   # Table 2 (by management strategy)
source("R/Scripts/03_grade_stratify.R")  # Table 3 (by AAST grade)
source("R/Scripts/04_success_salvage.R") # Table 4 (success + salvage)
source("R/Scripts/05_model.R")           # Tables 5 & 6 (univariable screen + NOM-failure model)
source("R/Scripts/06_compile.R")         # Compile T1-T6 to docx
source("R/Scripts/07_figure.R")          # Figures (salvage bar + OR forest)
}
