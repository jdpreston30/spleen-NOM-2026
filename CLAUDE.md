# spleen-NOM-2026 — Claude Code Brief

**Single source of truth for conventions in this repo — read before writing code or giving advice.** This project is an early-stage clinical analysis being built out from a mature template; the pipeline scaffolding is in place, most analysis scripts are not yet written. When in doubt about *analytical* structure, the `PKI_Scripts/` template (see below) is the reference implementation.

---

## Project in Brief

Retrospective clinical study of **blunt splenic injury** managed non-operatively (NOM) — observation, splenic artery embolization (IR), and operative management. The analytical goal mirrors the kidney-injury template: describe the cohort, stratify outcomes by **management strategy** and by **injury grade** (`SpleenAIS`), and quantify **procedure success** across grades.

- **Raw data**: `blunt_spleen_UTD.xlsx`, sheet `"Pared"`, imported to the object `raw` by `00c_import.R` via `config$paths$raw_data`.
- ⚠️ **This is patient data.** Treat every value as potentially PHI-bearing. Never paste raw rows, free-text fields, dates/timestamps, or identifiers into commits, outputs, or external services. Free-text columns (`Comments`, `*findings`, `Indication*`, `Reason`, occupation) and `*_DTM` date-time columns are the highest-leak surfaces. Follow the project IRB/DUA as the authority.
- **Management variables** (`ARM`/`Second_ARM`/`group3`) are the management-strategy spine; their coding is **inferred, not yet confirmed** — see the `spleen-arm-variable-meaning` memory and confirm against a codebook before relying on it.

---

## Template: `PKI_Scripts/` (gitignored)

`PKI_Scripts/` is a **gitignored prior project** (penetrating kidney injury) that this repo's analysis is being **ported from**. It is the reference implementation for the pipeline shape, cleanup discipline, and table/figure approach. Key patterns to carry over:

- **Management-strategy spine**: three mutually exclusive groups; every outcome viewed both *by strategy* and *by injury grade*, then success cross-tabbed by both.
- **Derived "index success"**: success unless a later procedure occurred; `NA` for early (<24 h) deaths so mortality doesn't contaminate denominators.
- **`00d` cleanup discipline**: (1) confounding control by targeted NA-ing (group-specific vars set `NA` outside their group; survival-dependent outcomes `NA`'d for early deaths); (2) **derive-then-validate** — build a recode from a logic tree, then gate it against the source column with `stopifnot()`; (3) split analysis object (`raw_joined`) from display-renamed object (`raw_named`).
- **Tables** via `TernTables` (`ternD` descriptive, `ternG` grouped, `ternStyle` manual styling). **Do not** hand-roll table formatting.

---

## Pipeline

**Single entry point**: `All_Run/run.R` sources everything in order — config → `00a` env → `00b` setup → numbered analysis scripts. Run a full pass before interactive work.

```
R/Scripts/
  00a_environment_setup.R   renv verify → install/load packages from DESCRIPTION Imports
  00b_setup.R               source all of R/Utilities/ recursively → options → conflicted
  00c_import.R              read raw data from config$paths$raw_data
  00d_cleanup.R             clean, derive, validate → raw_joined / raw_named
  01_*, 02_*, ...           analysis scripts (grow as project develops)
R/Utilities/                sourced recursively by 00b — role-based subdirs:
  Analysis/                 model/summary functions (e.g. summarize_index_success)
  Helpers/                  stateless reusable helpers + load_dynamic_config.R
  Preprocessing/            data-shaping helpers
  Tabulation/               table builders
  Visualization/            plot_*.R (one pure plot function per file)
  Terminal/                 utils_terminal.R — interactive dev shortcuts
All_Run/
  config_dynamic.yaml       machine-specific paths (laptop/desktop auto-detect)
  run.R                     master runner
Outputs/                    generated tables/figures
.A/                         scratch: quick diagnostics, not part of the pipeline
```

**Environment**: packages are managed by `renv`; the package list is read from `DESCRIPTION` (`Imports`). `JDP.repo` is a global tool, ignored by renv. `TernTables` installs from r-universe (CRAN-compatible) — no `devtools`/`remotes` needed.

---

## Config / YAML system

Machine-specific paths live in `All_Run/config_dynamic.yaml` and are resolved by `R/Utilities/Helpers/load_dynamic_config.R`, which:
- Auto-detects the machine by matching `$HOME` against the `computers:` block (`laptop` = `/Users/jdp2019`, `desktop` = `/Users/JoshsMacbook2015`).
- Substitutes `{user_home}`, `{onedrive_path}`, `{figures_path}`, and `{base_data_path}` templates into every value under `paths:`.
- Assigns the resolved list to `config` in `.GlobalEnv`.

**To add a path**: put it under `paths:` using the `{…}` templates so it resolves per-machine (e.g. `raw_data: "{user_home}/Desktop/blunt_spleen_UTD.xlsx"`). Reference it in scripts as `config$paths$<key>`. **Never hard-code an absolute path in a script.** Add a new machine by adding an entry to `computers:`.

---

## Core Code Rules

**Pipe**: always native `|>`. Never `%>%`.

**Pipeline object naming (non-negotiable)**: always assign each pipeline stage to a **new, descriptively-named** tibble — never reassign to the same name. `raw_selected <- raw_selected |> ...` is forbidden. Chain distinct names that describe what happened (e.g. `raw |> filter()` → `raw_selected` → `select()` → `raw_pared` → `mutate()` → `raw_derived`). This keeps every intermediate inspectable and makes the transformation history readable.

**Comment hierarchy** (no extra blank lines between sections; code immediately follows the header):

```r
#* 1: Major section
#+ 1.2: Subsection
#- 1.2.1: Detail block
#! Note / metadata annotation (e.g. output path, caveat, assumption)
# inline explanation
```

Each subheader = one executable block for Cmd+Enter navigation.

**Comment line wrapping**: narrative/prose comments must **not** be soft-wrapped at column 80. Each sentence or logical thought goes on one continuous line. Break a comment block only to separate distinct items (listing variables, showing a formula, a new paragraph after a blank `#` line) — never mid-clause to satisfy a column limit.

**Bracketing of `#-` blocks** (by statement count):
- **Single statement** (one pipeline or one assignment): NO braces. Code sits directly under the header, unindented.
- **Multiple statements**: wrap in `{ }` with indentation, and add a `# brief comment` before each logical step (except the first if the header names it).

```r
#- 1.2.1: Single assignment — no braces
raw_joined <- raw |> filter(SpleenAIS >= 3)

#- 1.2.2: Multiple steps — braces required
{
  # derive the recode
  x <- ...
  # validate against source column
  stopifnot(...)
}
```

**Helper modularization (non-negotiable)**: any **stateless, reusable** helper (formatters, label builders, summary functions callable from any script) lives in its own file under `R/Utilities/` in the role-appropriate subdir. `00b_setup.R` sources all of `R/Utilities/` recursively, so anything added is available everywhere automatically. Test: *could this function be called unchanged from a different script?* Yes → its own Helpers/ (or Analysis/, Tabulation/…) file. No (a closure capturing script-local state) → inline is fine.

**Separate computation from presentation**: analysis scripts run models and store named objects; table/figure scripts consume those objects and format. Plot functions in `R/Utilities/Visualization/` are pure (return a ggplot, no data loading or stats). Don't inline ad hoc ggplot or table-styling logic in analysis scripts.

**Conflicts**: resolved explicitly via `conflicted` in `00b_setup.R`. Add `conflicts_prefer()` calls there as needed rather than relying on load order.

---

## Interactive / Terminal Helpers

Defined in `R/Utilities/Terminal/utils_terminal.R` (sourced by `00b`). Single-letter convenience functions — **not** part of the reproducible pipeline:

- `r()` → sources `All_Run/run.R` (full pipeline)
- `d()` → sources `.A/diagnostic.R` (quick scratch checks against loaded objects like `raw`)
- `m()` → evaluate math expressions in render files
- `cr()` → generate `comment_report.R` (section-heading index across scripts)

New interactive shortcuts go here, documented with a roxygen-style comment block matching the existing style.

## `.A/` Scratch Workflow

`.A/` holds one-off diagnostics, not pipeline code. Write a targeted diagnostic block to `.A/diagnostic.R`, run `d()`, read the output — prefer one focused diagnostic over blind trial-and-error edits. Keep PHI out of anything that could be committed (`.A/` should be gitignored; verify).

---

## Pipeline (built out)

`00a` env → `00b` setup → `00c` import → `00d` cleanup (drop → standardize → derive `management_strategy`/`ir_procedure`/`early_death`/`index_success`/`splenic_salvage` → Tier-2 types/flags → `MAP`/`MTP` → `raw_named` display frame) → `01` Table 1 (`ternD`) → `02` Table 2 by strategy (`ternG`) → `03` Table 3 by grade IV/V (`ternG`) → `04` Table 4 success+salvage (`summarize_success` + `ternStyle`) → `05` NOM-failure model (`glm` + `ternStyle`) → `06` compile to docx (`ternB`).

Object chain in `00d`: `raw → raw_selected → raw_pared → raw_std → raw_derived → raw_outcomes → raw_clean → raw_ready → raw_named`.
