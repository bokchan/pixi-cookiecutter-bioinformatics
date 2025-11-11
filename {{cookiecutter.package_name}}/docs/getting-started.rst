Getting Started
===============

Quick Setup for Bioinformatics Analysis
---------------------------------------

This template provides a production-ready bioinformatics workflow environment using pixi for dependency management and Snakemake for workflow orchestration.

**Prerequisites:**
 - `pixi <https://pixi.sh>`_ installed
 - Basic familiarity with Snakemake workflows
 - Reference genome and annotation files

**1. Environment Setup**

.. code-block:: bash

   # Install dependencies
   pixi install

   # Create project structure
   pixi run setup-dirs

**2. Configure Analysis**

.. code-block:: bash

   # Edit configuration files
   vim config/config.yaml     # Analysis parameters
   vim config/samples.tsv     # Sample metadata

**3. Run Analysis**

.. code-block:: bash

   # Dry run to validate workflow
   pixi run pipeline-dry

   # Execute full pipeline
   pixi run pipeline

**Advanced Configuration**

See ``docs/examples/`` for complete configuration examples:
 - RNA-seq differential expression
 - Variant calling pipelines
 - Quality control workflows

**Development Workflow**

.. code-block:: bash

   # Code formatting and linting
   pixi run fmt
   pixi run lint

   # Run tests
   pixi run test
