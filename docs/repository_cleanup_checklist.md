# Repository cleanup checklist for Nature Communications revision

## Highest-priority actions

- [ ] Rename the repository to remove the typo in `UKB--CKB-poject`
- [ ] Add a root-level `README.md`
- [ ] Add a root-level `LICENSE`
- [ ] Add a root-level `CITATION.cff`
- [ ] Add a root-level `.gitignore`
- [ ] Add a repository description and topics on GitHub
- [ ] Create a tagged release for the revision used in the manuscript
- [ ] Archive the tagged release in Zenodo and add the DOI after deposit

## Clarity and manuscript alignment

- [ ] Identify a single **primary** prediction module
- [ ] Remove or archive `prediction-model-xgboost-code/` if it duplicates the UKB integrated pipeline
- [ ] Mark any non-manuscript scripts as archival/development only
- [ ] Replace generic phrases such as “cleaned and shareable version” or “cleaned template” with manuscript-specific descriptions
- [ ] Update MR README to state the actual instrument thresholds and methods used in the paper
- [ ] Update prediction README to describe explicit input files rather than opaque in-memory objects
- [ ] Check whether CKB PAF code is manuscript-relevant; if not, remove or label it as non-primary

## Reproducibility

- [ ] Harmonize R-version reporting across modules or explain differences
- [ ] Add package versions / `renv.lock` / session info
- [ ] Record PLINK version and clumping parameters for MR
- [ ] Record random seed(s) for prediction-model splits and training
- [ ] Remove all absolute local paths
- [ ] Confirm that no participant-level data or sensitive derived outputs are committed

## Manuscript-facing consistency checks

- [ ] Ensure every Methods subsection maps to one code module
- [ ] Ensure every main figure/table has one primary generating script
- [ ] Fix any duplicated or inconsistent figure numbering in the manuscript text
- [ ] Update code availability statement with final repository URL and DOI
- [ ] Update data availability statement to reflect UKB and CKB controlled-access policies

## Small but important fixes

- [ ] Replace `[Your Name]` in submodule MIT license files where it still appears
- [ ] Ensure README filenames and folder names are consistent across modules
- [ ] Add GitHub topics such as `uk-biobank`, `china-kadoorie-biobank`, `mendelian-randomization`, `xgboost`, `survival-analysis`
