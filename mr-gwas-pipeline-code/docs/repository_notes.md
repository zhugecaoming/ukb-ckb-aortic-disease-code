# Repository notes

This cleaned repository was derived from a larger local analysis script.

Main cleanup steps:
- removed absolute Windows paths,
- replaced dynamic `get()` usage with list-based objects,
- split the workflow into modular scripts,
- added configuration file support,
- added placeholders for data and results directories,
- documented required packages and external software.

Before public release:
1. replace `[Your Name]` in `LICENSE`,
2. edit the README title and project description,
3. confirm column names in `config/config.yml`,
4. run the workflow locally using your own files,
5. verify that no restricted data or derived outputs should remain public.
