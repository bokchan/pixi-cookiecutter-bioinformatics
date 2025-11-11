Commands Reference
==================

This project uses pixi for task management and dependency isolation.

Core Analysis Commands
----------------------

**Project Setup:**

.. code-block:: bash

   pixi run setup-dirs    # Create directory structure
   pixi run help-setup    # Display setup guide

**Workflow Execution:**

.. code-block:: bash

   pixi run pipeline-dry  # Validate workflow (dry run)
   pixi run pipeline      # Execute complete analysis
   pixi run clean         # Clean temporary files

Development Commands
-------------------

**Code Quality:**

.. code-block:: bash

   pixi run fmt          # Format code with ruff
   pixi run lint         # Lint code with ruff
   pixi run types        # Type checking with ty
   pixi run test         # Run test suite
   pixi run snkfmt       # Format Snakemake files
   pixi run all          # Run all QC checks

**Environment Management:**

.. code-block:: bash

   pixi info             # Show environment info
   pixi install          # Install/update dependencies
   pixi shell            # Activate environment shell

Workflow Customization
---------------------

**Snakemake Integration:**

All workflow commands use Snakemake with 4 cores by default. Customize in ``pyproject.toml``:

.. code-block:: toml

   [tool.pixi.tasks]
   pipeline = "snakemake --cores 8 --resources mem_mb=32000"

**Adding Custom Commands:**

Add new tasks to ``pyproject.toml``:

.. code-block:: toml

   [tool.pixi.tasks]
   my-analysis = "snakemake --snakefile workflow/my_analysis.smk"

See ``docs/examples/`` for workflow templates and configuration examples.
