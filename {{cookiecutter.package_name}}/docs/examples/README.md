# Configuration and Workflow Examples

This directory contains comprehensive examples for different types of bioinformatics analyses. Use these as references when setting up your own analysis.

## Getting Started

1. **Choose your analysis type** from the examples below
2. **Copy relevant sections** from the example config files to your `config/config.yaml`
3. **Adapt the sample metadata** using examples from `samples_extended.tsv`
4. **Use workflow examples** as templates for your `workflow/Snakefile`

## Available Examples

### Configuration Files

- **`config_rna_seq.yaml`** - Complete RNA-seq differential expression analysis
- **`config_variant_calling.yaml`** - Genome-wide variant detection pipeline
- **`samples_extended.tsv`** - Extended sample metadata examples for different experiment types

### Workflow Templates

- **`workflows/rna_seq_complete.smk`** - Complete RNA-seq pipeline (QC → Alignment → Counting → DE analysis)
- **`workflows/variant_calling_complete.smk`** - Full variant calling pipeline (coming soon)
- **`workflows/single_cell_rna_seq.smk`** - Single-cell RNA-seq analysis (coming soon)

## Usage Tips

### For Beginners
- Start with the minimal skeleton in your main config files
- Add complexity gradually as needed
- Use TODO comments to track what needs customization

### For Advanced Users
- Copy entire example sections for rapid setup
- Mix and match configurations for complex analyses
- Use examples as validation for your custom workflows

## Common Analysis Types

### RNA-seq Analysis
```bash
# Copy RNA-seq config sections
cp docs/examples/config_rna_seq.yaml config/config.yaml

# Adapt sample metadata
# Edit config/samples.tsv based on samples_extended.tsv examples

# Use complete workflow as template
cp docs/examples/workflows/rna_seq_complete.smk workflow/Snakefile
```

### Variant Calling
```bash
# Copy variant calling config
cp docs/examples/config_variant_calling.yaml config/config.yaml

# Adapt for your samples
# Edit config/samples.tsv for variant calling format
```

## Customization Guidelines

1. **Always update file paths** to match your reference data locations
2. **Adjust resource allocations** (threads, memory) based on your system
3. **Modify parameters** based on your experimental design and quality requirements
4. **Add new sections** as needed for specialized analyses

## Contributing Examples

If you develop workflows for new analysis types, consider contributing them back:
1. Create config and workflow examples
2. Add documentation
3. Submit a pull request

This helps the entire bioinformatics community!
