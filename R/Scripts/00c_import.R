#* 0c: Data import and initial processing
#+ 0c.1: Set raw path from YAML
raw_path <- config$paths$raw_data
#+ 0c.2: Import raw data
raw <- read_excel(raw_path, sheet = "Pared")
