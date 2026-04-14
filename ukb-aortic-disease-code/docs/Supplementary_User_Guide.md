# Supplementary User Guide for the Public Analysis Code

## Title
**User guide for the UK Biobank aortic disease analysis code and processed-data workflow**

## 1. Purpose of this supplement
This guide is intended for readers who are not expert R users but need to understand how the public code package is organized and how it should be used to reproduce the main UK Biobank analysis steps.

The guide explains:
- what each script does,
- what input files are needed,
- what output each step produces,
- how the primary endpoint is defined,
- how the chronic-condition models are fitted, and
- how to run the figure scripts.

## 2. What is included in the repository
The repository contains:
- **analysis scripts** (`scripts/`)
- **path configuration template** (`config/`)
- **variable and file dictionaries** (`data_dictionary/`)
- **example data files** showing the expected column structure (`example_data/`)
- **documentation templates** for the manuscript (`docs/`)
- **archived original scripts** (`archive/original_scripts/`)

## 3. Important note on data access
This repository does **not** contain participant-level UK Biobank or China Kadoorie Biobank data.

To use the code:
1. obtain permission to access the relevant cohort data,
2. store those files locally in a folder such as `data-raw/`,
3. rename the local files according to `data_dictionary/input_file_manifest.csv`, and
4. run the scripts from the repository root.

Do **not** upload restricted participant-level data to a public repository.

## 4. Software requirements
The code was written in **R 4.5.1** and uses the following main packages:
- `data.table`
- `dplyr`
- `readxl`
- `survival`
- `AF`
- `riskRegression`
- `ggplot2`
- `rlang`
- `tidyr`

To install missing packages, run:

```r
source("scripts/00_install_packages.R")
```

## 5. Local folder setup
A recommended local structure is:

```text
project-root/
├── config/
├── data-raw/
├── data-processed/
├── results/
├── scripts/
├── docs/
├── data_dictionary/
└── example_data/
```

Then copy:

```text
config/analysis_config_template.R
```

to

```text
config/analysis_config.R
```

and edit it if your local folders differ.

## 6. Input files needed
The scripts expect the following local inputs for the UKB workflow:

- `ukb_baseline.csv`
- `ukb_education.csv`
- `ukb_death_registry.csv`
- `ukb_hes_outcomes.csv`
- `ukb_opcs_source.csv`
- `ukb_opcs4_codes.xlsx`
- `ukb_chronic_conditions.csv`

Additional optional files referenced by the original project include:
- `ukb_aortic_cause.csv`
- `ukb_gene_sex.csv`
- `ukb_factor.csv`
- `ukb_medication.csv`

The exact mapping from the authors' original local filenames to the standardized repository filenames is given in:

```text
data_dictionary/input_file_manifest.csv
```

## 7. Variable dictionary
A compact variable dictionary is provided in:

```text
data_dictionary/ukb_variable_dictionary.csv
```

This includes the key variables used in the models, their UK Biobank UDI identifiers, and short descriptions.

## 8. Step-by-step workflow

### Step 1. Build the cleaned covariate table
Run:

```r
source("scripts/01_build_ukb_covariates.R")
```

This script:
- reads the baseline UKB table,
- calculates total physical activity in **MET** units,
- derives grouped centre, income, education, race, smoking, and drinking variables,
- writes:

```text
data-processed/ukb_covariates_clean.csv
```

### Step 2. Build aortic subtype indicators
Run:

```r
source("scripts/02_build_aortic_subtypes.R")
```

This script reads the wide diagnosis matrix and derives indicator/date columns for the major subtype groups used in the uploaded code:
- `I700`
- `I710`
- `I711`
- `I713`
- `Iqt`

The ICD-10 grouping used for each subtype is documented in:

```text
data_dictionary/aortic_outcome_code_map.csv
```

The output is:

```text
data-processed/ukb_aortic_subtypes.csv
```

### Step 3. Build the overall primary endpoint
Run:

```r
source("scripts/03_build_primary_endpoint.R")
```

This script merges:
- cleaned covariates,
- aortic subtype indicators,
- death-related support,
- OPCS4-derived operative events.

It then creates:
- `AN_date`: earliest qualifying aortic event date
- `AN_ctime`: follow-up time from baseline to the aortic event
- `AN`: overall incident aortic disease indicator

Output:

```text
data-processed/ukb_primary_aortic_endpoint.csv
```

### Step 4. Merge chronic conditions
Run:

```r
source("scripts/04_prepare_analysis_dataset.R")
```

This step merges the primary endpoint with the 42 chronic-condition table and writes:

```text
data-processed/ukb_analysis_dataset.csv
```

### Step 5. Run the primary Cox models
Run:

```r
source("scripts/05_run_primary_cox_models.R")
```

For each chronic condition, the script:
1. excludes participants whose aortic event occurred before the chronic-condition date,
2. constructs the analysis dataset,
3. fits a Cox proportional hazards model,
4. extracts hazard ratios and 95% confidence intervals,
5. applies FDR correction across the 42 tests.

Output:

```text
results/primary_cox_results.csv
```

### Step 6. Run the multimorbidity analysis
Run:

```r
source("scripts/06_run_multimorbidity_models.R")
```

This step recreates the multimorbidity count used in the original project and fits the multimorbidity-by-sex interaction model.

Outputs:
- `results/multimorbidity_model_summary.txt`
- `results/multimorbidity_analysis_dataset.csv`

### Step 7. Run the PAF analysis
Run:

```r
source("scripts/07_run_paf_models.R")
```

This script computes adjusted population attributable fractions using the Greenland-Drescher method implemented in `AF::AFcoxph`.

Output:

```text
results/paf_results.csv
```

### Step 8. Run the competing-risk analysis
Run:

```r
source("scripts/08_run_competing_risk_models.R")
```

This script:
- derives a death indicator and death date,
- builds competing-risk follow-up time,
- uses `riskRegression::CSC` to fit a cause-specific hazards model.

By default, it reproduces the example exposure used in the original sensitivity-analysis script (`hyp`).

Output:

```text
results/competing_risk_summary_hyp.txt
```

## 9. Figure scripts

### Sex-stratified forest plot
Run:

```r
source("scripts/09_plot_sex_stratified_forest.R")
```

This uses:

```text
example_data/example_sex_stratified_results.csv
```

and writes:

```text
results/figures/sex_stratified_forest.png
```

### Personalized forest plot
Run:

```r
source("scripts/10_plot_personalized_forest.R")
```

This uses:

```text
example_data/example_personalized_forest_input.csv
```

and writes:

```text
results/figures/personalized_forest_example.png
```

## 10. One-command execution
To run the full workflow in sequence:

```r
source("scripts/run_all.R")
```

## 11. Expected outputs for reviewers and readers
A reader who follows the workflow should be able to inspect:
- how covariates were derived,
- how the aortic disease endpoint was built,
- how each chronic condition enters the model,
- how multimorbidity was defined,
- how PAFs were computed, and
- how the sensitivity analyses and plots were generated.

## 12. What should be shared publicly
The following files are suitable for public release:
- code,
- variable dictionaries,
- file manifests,
- figure scripts,
- non-sensitive example data,
- summary-level results,
- manuscript statement templates,
- the present user guide.

## 13. What should remain controlled-access unless explicitly permitted
The following should **not** be uploaded publicly unless your approvals explicitly allow it:
- participant-level UKB data,
- participant-level CKB data,
- participant-level derived datasets containing restricted records,
- local configuration files that point to private storage locations.

## 14. Troubleshooting

### Problem: the config file is missing
Create:

```text
config/analysis_config.R
```

by copying the template in the same folder.

### Problem: a raw input file cannot be found
Check the standardized filename in:

```text
data_dictionary/input_file_manifest.csv
```

### Problem: a disease variable is missing
Check whether the chronic-condition file contains both:
- the disease indicator column, and
- its corresponding `_date` column.

### Problem: the figure scripts fail
Start with the example files in `example_data/` and confirm the required input columns match the example structure.

## 15. Files prepared for the manuscript revision
This repository package is accompanied by:
- `README.md`
- `docs/Code_Availability_template.md`
- `docs/Data_Availability_template.md`
- this Supplementary User Guide

These materials can be submitted together to satisfy requests for code transparency, reproducibility support, and non-expert usability documentation.
