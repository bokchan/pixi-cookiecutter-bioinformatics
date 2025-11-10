# {{cookiecutter.project_name}}

{% if cookiecutter.license == "None" %}![License](https://img.shields.io/badge/license-None-black){% else %}[![License](https://img.shields.io/github/license/{{cookiecutter.github_username}}/{{cookiecutter.package_name}})]({{cookiecutter.project_url}}/blob/main/LICENSE){% endif %}
[![Powered by: Pixi](https://img.shields.io/badge/Powered_by-Pixi-facc15)](https://pixi.sh)
[![Code style: ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)
[![Typing: ty](https://img.shields.io/badge/typing-ty-EFC621.svg)](https://github.com/astral-sh/ty)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/{{cookiecutter.github_username}}/{{cookiecutter.package_name}}/test.yml?branch=main&logo=github-actions)]({{cookiecutter.project_url}}/actions/)
[![Codecov](https://img.shields.io/codecov/c/github/{{cookiecutter.github_username}}/{{cookiecutter.package_name}})](https://codecov.io/gh/{{cookiecutter.github_username}}/{{cookiecutter.package_name}})

Project Organization
------------
```
├── .coveragerc        <- Configuration for coverage.py
├── .editorconfig      <- EditorConfig for consistent coding style
├── .envrc             <- Environment configuration for direnv
├── .github/           <- GitHub workflows and configuration
│   └── workflows/
│       └── test.yml   <- CI/CD pipeline configuration
├── .gitignore         <- Git ignore file
├── .pre-commit-config.yaml <- Pre-commit hooks configuration
├── LICENSE            <- Project license file
├── README.md          <- The top-level README for developers using this project
├── pyproject.toml     <- Project configuration and dependencies
├── config/            <- Configuration options for the analysis
│   ├── config.yaml    <- Snakemake config file
│   └── samples.tsv    <- A metadata table for all the samples run in the analysis
│
├── docs/              <- A default Sphinx project; see sphinx-doc.org for details
│
├── img/               <- A place to store images associated with the project/pipeline, e.g.
│                         a figure of the pipeline DAG
│
├── notebooks/         <- Jupyter notebooks. Naming convention is a number (for ordering),
│                         the creator's initials, and a short `-` delimited description, e.g.
│                         `1.0-jqp-initial-data-exploration`
│
├── references/        <- Data dictionaries, manuals, and all other explanatory materials
│
├── reports/           <- Generated analysis as HTML, PDF, LaTeX, etc.
│   └── figures/       <- Generated graphics and figures to be used in reporting
│
├── resources/         <- Place for data. By default excluded from the git repository
│   ├── external/      <- Data from third party sources
│   └── raw_data/      <- The original, immutable data dump
│
├── sandbox/           <- A place to test scripts and ideas. By default excluded from the git repository
│
├── scripts/           <- A place for short shell or python scripts
│
├── src/               <- Source code for use in this project
│   └── __init__.py    <- Makes src a Python module
│
├── tests/             <- Unit tests for the project
│   ├── __init__.py    <- Makes tests a Python module
│   └── test_stub.py   <- Example test file
│
├── workflow/          <- Place to store the main pipeline for rerunning all the analysis
│   ├── envs/          <- Contains different conda environments in .yaml format for running the pipeline
│   ├── rules/         <- Contains .smk files that are included by the main Snakefile
│   ├── scripts/       <- Contains different R or python scripts used by the script: directive in Snakemake
│   └── Snakefile      <- Contains the main entrypoint to the pipeline
│
├── workspace/         <- Space for intermediate results in the pipeline. By default excluded from the git repository
│
└── {{cookiecutter.package_name}}/  <- Main Python package
    ├── __init__.py    <- Makes package a Python module
    ├── py.typed       <- Marker file for type information
    └── {{cookiecutter.package_name}}.py <- Main module file
```
--------

## Credits
This package was created with [Cookiecutter](https://github.com/audreyr/cookiecutter) and the cookiecutter project templates from [jevandezande/pixi-cookiecutter](https://github.com/jevandezande/pixi-cookiecutter) and [maxplanck-ie/cookiecutter-bioinformatics-project](https://github.com/maxplanck-ie/cookiecutter-bioinformatics-project)
