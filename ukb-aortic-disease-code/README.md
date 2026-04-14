# UKB aortic disease analysis: GitHub-ready code package

This repository is a cleaned and publication-oriented reorganization of the original R scripts used for the UK Biobank (UKB) part of the aortic disease project.

It is designed to help reviewers and readers:
1. understand the analytic workflow,
2. reproduce the main processing and modelling steps locally, and
3. identify which files, variables, and outputs belong to each part of the analysis.

## What is included

- `scripts/`: cleaned R scripts with relative paths and modular helper functions
- `config/`: editable path template for local execution
- `data_dictionary/`: variable dictionary, input-file manifest, aortic endpoint code map, and the 42-condition list
- `docs/`: non-expert user guide, repository notes, and manuscript statement templates
- `example_data/`: toy/example files showing the expected input/output format
- `archive/original_scripts/`: the original uploaded R scripts, preserved for traceability

## Important data-access note

This repository intentionally **does not** contain participant-level UK Biobank or China Kadoorie Biobank data.

Recommended practice:
- keep restricted participant-level files in a **local-only** folder such as `data-raw/`
- share code, documentation, variable dictionaries, and summary-level outputs publicly
- deposit any participant-level derived dataset only through the access route permitted by the data provider and your approvals

## Expected local folder layout

```text
project-root/
├── config/
├── data-raw/              # restricted local data only; do not upload
├── data-processed/
├── results/
├── scripts/
├── docs/
├── data_dictionary/
└── example_data/
```

## Required input files

See `data_dictionary/input_file_manifest.csv` for the full mapping from the original local filenames to the standardized repository filenames.

At minimum, the UKB workflow expects local copies of:
- `ukb_baseline.csv`
- `ukb_education.csv`
- `ukb_death_registry.csv`
- `ukb_hes_outcomes.csv`
- `ukb_opcs_source.csv`
- `ukb_opcs4_codes.xlsx`
- `ukb_chronic_conditions.csv`

## Quick start

### 1. Prepare the repository
- Copy `config/analysis_config_template.R` to `config/analysis_config.R`
- Edit the local folder names if needed
- Place your restricted raw files into `data-raw/` using the standardized names listed in `data_dictionary/input_file_manifest.csv`

### 2. Install packages
Run:

```r
source("scripts/00_install_packages.R")
```

### 3. Run the analysis in order
Run either:

```r
source("scripts/run_all.R")
```

or run step by step:

```r
source("scripts/01_build_ukb_covariates.R")
source("scripts/02_build_aortic_subtypes.R")
source("scripts/03_build_primary_endpoint.R")
source("scripts/04_prepare_analysis_dataset.R")
source("scripts/05_run_primary_cox_models.R")
source("scripts/06_run_multimorbidity_models.R")
source("scripts/07_run_paf_models.R")
source("scripts/08_run_competing_risk_models.R")
```

Plotting scripts can then be run separately:
```r
source("scripts/09_plot_sex_stratified_forest.R")
source("scripts/10_plot_personalized_forest.R")
```

## Workflow summary

### Step 1. Build covariates
`scripts/01_build_ukb_covariates.R`
- reads the baseline UKB table
- calculates MET from low/moderate/vigorous activity
- derives centre, income, education, race, smoking, and drinking variables
- writes `data-processed/ukb_covariates_clean.csv`

### Step 2. Build aortic subtype indicators
`scripts/02_build_aortic_subtypes.R`
- reads the wide ICD-10 outcome matrix
- derives subtype indicators and first dates for:
  - I70.0
  - I71.0
  - I71.1 / I71.2
  - I71.3 / I71.4
  - I71.5 / I71.6 / I71.8 / I71.9
- writes `data-processed/ukb_aortic_subtypes.csv`

### Step 3. Build the overall primary endpoint
`scripts/03_build_primary_endpoint.R`
- merges covariates, subtype indicators, death support, and OPCS4-derived procedural events
- derives the earliest aortic event date (`AN_date`)
- derives follow-up time to aortic disease (`AN_ctime`)
- writes `data-processed/ukb_primary_aortic_endpoint.csv`

### Step 4. Merge chronic conditions
`scripts/04_prepare_analysis_dataset.R`
- merges the primary endpoint with the 42-condition disease file
- writes `data-processed/ukb_analysis_dataset.csv`

### Step 5. Run primary Cox models
`scripts/05_run_primary_cox_models.R`
- excludes participants whose aortic event occurred before the chronic condition date
- fits Cox proportional hazards models for each chronic condition
- applies FDR correction
- writes `results/primary_cox_results.csv`

### Step 6. Run multimorbidity models
`scripts/06_run_multimorbidity_models.R`
- recreates the multimorbidity count variable
- fits the multimorbidity-by-sex Cox model
- writes summary outputs to `results/`

### Step 7. Run PAF analyses
`scripts/07_run_paf_models.R`
- calculates adjusted PAFs using `AF::AFcoxph`
- writes `results/paf_results.csv`

### Step 8. Run competing-risk sensitivity analysis
`scripts/08_run_competing_risk_models.R`
- creates a death indicator and death date
- runs a CSC competing-risk model
- currently defaults to `hyp` to match the original sensitivity-analysis script
- writes summary output to `results/`

## Example data

The files in `example_data/` are **not real participant-level study data**.
They are provided only to show the expected column structure for:
- a processed analysis dataset,
- a sex-stratified forest plot input file, and
- a personalized forest-plot input file.
