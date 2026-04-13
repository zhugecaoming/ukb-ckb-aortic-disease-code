# Repository notes

This repository was rebuilt so that the main scripts directly contain the uploaded analytical logic.

Key changes from the desktop/server versions:

- removed hard-coded local absolute paths
- centralized repeated UKB preprocessing steps into helper functions
- kept subtype-specific logic for `I700`, `I710`, `I711/I712`, `I713/I714`, and `I715/I716/I718/I719`
- preserved the original XGBoost, sex forest plot, and custom forest plot workflows in the main code tree

Before release, check:

1. local paths in `config/config.yml`
2. exact column positions in UKB-derived files
3. date parsing of hospital and death dates
4. disease exposure variable names and their `*_date` counterparts
5. package availability for `AF`, `riskRegression`, and `shapviz`
