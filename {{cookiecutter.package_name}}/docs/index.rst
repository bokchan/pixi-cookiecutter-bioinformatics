.. {{ cookiecutter.project_name }} documentation master file, created by
   sphinx-quickstart.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

{{ cookiecutter.project_name }}
==============================================

Professional bioinformatics analysis template with pixi dependency management and Snakemake workflows.

Quick Start
-----------

.. code-block:: bash

   # Setup environment and directories
   pixi install
   pixi run setup-dirs

   # Configure analysis
   # Edit config/config.yaml and config/samples.tsv

   # Run analysis
   pixi run pipeline-dry  # validate
   pixi run pipeline      # execute

Documentation
-------------

.. toctree::
   :maxdepth: 2
   :caption: User Guide

   getting-started
   commands

.. toctree::
   :maxdepth: 2
   :caption: Development Guide

   workflow_development
   dependency_management
   configuration_reference
   examples/README



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
