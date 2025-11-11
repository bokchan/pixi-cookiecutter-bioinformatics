# Dependency Management and Tool Integration

This template uses pixi for reproducible dependency management with a focus on professional bioinformatics workflows.

## Environment Architecture

The project follows a **minimal environment strategy** optimized for development efficiency:

### Default Environment
**Core Dependencies**: Python scientific stack + Snakemake workflow engine
**Purpose**: Minimal base for workflow orchestration and custom analysis

### Development Environment (`dev`)
**Additional Tools**: Code formatting (ruff), type checking (ty), testing (pytest)
**Usage**: `pixi run -e dev <command>` or use predefined tasks (`pixi run fmt`, `pixi run test`)

## Adding Bioinformatics Tools

### Method 1: Direct Dependencies (Recommended)
Add tools directly to `pyproject.toml` for project-specific requirements:

```toml
[tool.pixi.dependencies]
# Core workflow tools (always available)
snakemake = ">=8.20"

# Add your analysis tools
fastqc = "*"
multiqc = "*"
samtools = "*"
star = "*"
gatk4 = "*"
# ... other tools as needed
```

### Method 2: Feature-Based Environments
For complex projects requiring tool isolation:

```toml
[tool.pixi.feature.rnaseq.dependencies]
star = "*"
salmon = "*"
hisat2 = "*"

[tool.pixi.feature.variants.dependencies]
bwa = "*"
gatk4 = "*"
vcftools = "*"

[tool.pixi.environments]
rnaseq = { features = ["rnaseq"], solve-group = "analysis" }
variants = { features = ["variants"], solve-group = "analysis" }
```

Usage: `pixi run -e rnaseq star --help`

## Workflow Integration

### Snakemake Integration
Tools are available within Snakemake rules without environment specification:

```python
# In workflow/Snakefile
rule quality_control:
    input: "data/sample.fastq.gz"
    output: "results/qc/sample_fastqc.html"
    shell: "fastqc {input} -o results/qc/"

rule align_reads:
    input:
        reads=["data/{sample}_R1.fastq.gz", "data/{sample}_R2.fastq.gz"],
        index="resources/star_index"
    output: "results/{sample}.bam"
    threads: 8
    shell:
        "star --genomeDir {input.index} "
        "--readFilesIn {input.reads} "
        "--runThreadN {threads} "
        "--outSAMtype BAM SortedByCoordinate"
```

### Conda/Mamba Integration (Alternative)
For existing conda workflows, pixi supports conda channels:

```toml
[tool.pixi.dependencies]
# Bioconda packages work seamlessly
fastqc = { version = "*", channel = "bioconda" }
star = { version = "*", channel = "bioconda" }
```

## Best Practices

### For Development
1. **Start minimal**: Add tools as needed rather than preloading comprehensive toolsets
2. **Use solve groups**: Group related environments to share dependencies efficiently
3. **Lock versions**: Use `pixi.lock` for reproducible environments across systems
4. **Document dependencies**: Comment tool choices in `pyproject.toml`

### For Production
1. **Pin critical tools**: Specify exact versions for analysis-critical software
2. **Test compatibility**: Validate tool combinations before production use
3. **Environment isolation**: Use separate environments for conflicting tool versions
4. **CI/CD integration**: Test workflows with locked environments

### Tool Selection Guidelines
- **Prefer conda-forge**: Generally better maintained than platform-specific repositories
- **Use bioconda for specialized tools**: Bioinformatics-specific packages
- **Check tool maturity**: Prefer established tools with active maintenance
- **Consider alternatives**: Some tools have multiple packaging variants

## Platform Support

### Cross-Platform Compatibility
Specify platforms in `pyproject.toml` for team environments:

```toml
[tool.pixi.project]
platforms = ["linux-64", "osx-64", "osx-arm64", "win-64"]
```

### Platform-Specific Considerations
- **Apple Silicon (M1/M2)**: Some tools may require `osx-64` emulation
- **Linux HPC**: Consider `linux-aarch64` for ARM-based clusters
- **Windows**: Limited bioinformatics tool support; use WSL2 when possible

## Troubleshooting

### Common Issues
```bash
# Dependency conflicts
pixi clean cache     # Clear solver cache
pixi install         # Reinstall with fresh resolution

# Tool not available
pixi search <tool>   # Search available packages
pixi list           # Show installed packages

# Environment debugging
pixi shell          # Activate environment for debugging
pixi info           # Show environment details
```

### Performance Optimization
```bash
# Parallel installation
pixi install --no-lockfile-update  # Skip lock updates during development

# Environment caching
# Pixi automatically caches environments for faster subsequent installs
```

### Advanced Configuration
```toml
# Custom channels and priorities
[tool.pixi.project]
channels = ["conda-forge", "bioconda", "defaults"]

# Environment-specific configurations
[tool.pixi.target.linux-64.dependencies]
intel-openmp = "*"  # Linux-specific optimizations
```

## Migration from Conda/Mamba

If migrating from existing conda environments:

1. **Export environment**: `conda env export > environment.yml`
2. **Convert dependencies**: Add packages to `[tool.pixi.dependencies]`
3. **Test compatibility**: Verify tools work together in pixi
4. **Update workflows**: Remove conda-specific activation commands

## Contributing Guidelines

When adding new tools to the template:
1. **Justify additions**: Document why the tool is essential for the template
2. **Test compatibility**: Ensure new tools don't conflict with existing ones
3. **Update documentation**: Add usage examples and configuration guidance
4. **Consider alternatives**: Evaluate if existing tools can meet the need
