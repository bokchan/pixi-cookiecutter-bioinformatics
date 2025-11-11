# Workflow Development Guide

This guide covers workflow development practices for professional bioinformatics analysis using Snakemake.

## Project Structure

```
workflow/
├── Snakefile              # Main workflow entry point
├── rules/                 # Modular rule definitions
│   ├── common.smk        # Shared functions and validation
│   ├── quality_control.smk
│   ├── alignment.smk
│   └── analysis.smk
├── scripts/              # Analysis scripts (Python, R, shell)
├── envs/                 # Conda environment definitions (if using)
└── schemas/              # Configuration validation schemas
```

## Workflow Best Practices

### 1. Modular Design
Break workflows into logical modules:

```python
# workflow/Snakefile
include: "rules/common.smk"
include: "rules/quality_control.smk"
include: "rules/alignment.smk"
include: "rules/analysis.smk"

# Define target outputs
rule all:
    input:
        expand("results/qc/{sample}_fastqc.html", sample=SAMPLES),
        expand("results/aligned/{sample}.bam", sample=SAMPLES),
        "results/reports/multiqc_report.html"
```

### 2. Configuration Management
Use structured configuration with validation:

```python
# workflow/rules/common.smk
import pandas as pd
from snakemake.utils import validate

# Load and validate configuration
configfile: "config/config.yaml"
validate(config, schema="schemas/config.schema.yaml")

# Load samples with validation
samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)
validate(samples, schema="schemas/samples.schema.yaml")
SAMPLES = samples.index.tolist()
```

### 3. Resource Management
Define appropriate resource requirements:

```python
rule align_reads:
    input:
        reads=["resources/raw_data/{sample}_R1.fastq.gz",
               "resources/raw_data/{sample}_R2.fastq.gz"],
        index=config["reference"]["star_index"]
    output:
        bam="results/aligned/{sample}.bam",
        log="results/aligned/{sample}.Log.final.out"
    threads: 8
    resources:
        mem_mb=32000,
        runtime=120
    shell:
        """
        star --genomeDir {input.index} \
             --readFilesIn {input.reads} \
             --runThreadN {threads} \
             --outSAMtype BAM SortedByCoordinate \
             --outFileNamePrefix results/aligned/{wildcards.sample}.
        """
```

### 4. Error Handling and Validation
Implement robust error handling:

```python
rule validate_input:
    input:
        fastq="resources/raw_data/{sample}_R1.fastq.gz"
    output:
        validated=touch("results/validation/{sample}.validated")
    run:
        import gzip
        # Check if file is valid gzipped FASTQ
        try:
            with gzip.open(input.fastq, 'rt') as f:
                first_line = f.readline()
                if not first_line.startswith('@'):
                    raise ValueError(f"Invalid FASTQ format: {input.fastq}")
        except Exception as e:
            raise WorkflowError(f"Input validation failed: {e}")
```

## Configuration Schemas

### Configuration Schema (`schemas/config.schema.yaml`)
```yaml
$schema: "http://json-schema.org/draft-07/schema#"
description: "Configuration validation for bioinformatics workflow"

type: object
properties:
  samples:
    type: string
    description: "Path to samples metadata file"

  reference:
    type: object
    properties:
      genome:
        type: string
        description: "Path to reference genome FASTA"
      annotation:
        type: string
        description: "Path to gene annotation GTF"
      star_index:
        type: string
        description: "Path to STAR index directory"
    required: ["genome", "annotation"]

  analysis:
    type: object
    properties:
      threads:
        type: integer
        minimum: 1
        maximum: 64
        default: 4
      quality_threshold:
        type: integer
        minimum: 0
        maximum: 40
        default: 20

required: ["samples", "reference"]
```

### Samples Schema (`schemas/samples.schema.yaml`)
```yaml
$schema: "http://json-schema.org/draft-07/schema#"
description: "Sample metadata validation"

type: object
properties:
  sample:
    type: array
    items:
      type: string
      pattern: "^[A-Za-z0-9_-]+$"
    uniqueItems: true

  condition:
    type: array
    items:
      type: string
      enum: ["control", "treatment"]

  batch:
    type: array
    items:
      type: string

required: ["sample"]
```

## Advanced Workflow Patterns

### 1. Conditional Rules
Execute rules based on configuration:

```python
def get_trimming_input(wildcards):
    if config.get("trimming", {}).get("enabled", False):
        return f"results/trimmed/{wildcards.sample}_R1.fastq.gz"
    else:
        return f"resources/raw_data/{wildcards.sample}_R1.fastq.gz"

rule align_reads:
    input:
        reads=get_trimming_input
    output:
        "results/aligned/{sample}.bam"
    # ... rest of rule
```

### 2. Checkpoint Rules
Handle dynamic outputs:

```python
checkpoint split_samples:
    input:
        "resources/sample_list.txt"
    output:
        directory("results/split_samples/")
    shell:
        "split_samples.py {input} {output}"

def aggregate_split_results(wildcards):
    checkpoint_output = checkpoints.split_samples.get(**wildcards).output[0]
    return expand("results/processed/{sample}.txt",
                  sample=glob_wildcards(os.path.join(checkpoint_output, "{sample}.txt")).sample)
```

### 3. Report Generation
Include automated reporting:

```python
rule generate_report:
    input:
        qc="results/qc/multiqc_report.html",
        counts="results/counts/gene_counts.tsv",
        config="config/config.yaml"
    output:
        report="results/reports/analysis_report.html"
    script:
        "scripts/generate_report.py"

# Add to workflow report
report: "results/reports/workflow_report.html"
```

## Testing and Validation

### Unit Tests for Rules
```python
# tests/test_rules.py
import subprocess
import tempfile
import os

def test_fastqc_rule():
    with tempfile.TemporaryDirectory() as tmpdir:
        # Create test input
        test_fastq = os.path.join(tmpdir, "test.fastq.gz")
        # ... create minimal test file

        # Run rule
        cmd = f"snakemake --snakefile workflow/Snakefile --directory {tmpdir} --cores 1 results/qc/test_fastqc.html"
        result = subprocess.run(cmd, shell=True, capture_output=True)

        assert result.returncode == 0
        assert os.path.exists(os.path.join(tmpdir, "results/qc/test_fastqc.html"))
```

### Integration Testing
```bash
# Test complete workflow on minimal dataset
pixi run pipeline-dry  # Validate workflow structure
pixi run test-dataset  # Run on test data
```

## Performance Optimization

### 1. Resource Profiling
```python
# Enable resource monitoring
rule resource_intensive_task:
    input: "large_file.bam"
    output: "results/processed.txt"
    benchmark: "benchmarks/{rule}.benchmark.txt"
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 16000
    # ... rule definition
```

### 2. Cluster Integration
```python
# cluster.yaml
__default__:
  partition: "general"
  time: "01:00:00"
  mem: "8G"

align_reads:
  partition: "highmem"
  time: "06:00:00"
  mem: "32G"
  cpus-per-task: 8
```

### 3. Caching and Reuse
```python
# Enable workflow caching
rule expensive_computation:
    input: "input.txt"
    output: "results/cache/expensive_result.txt"
    cache: True  # Enable result caching
    shell: "expensive_tool {input} > {output}"
```

## Deployment Strategies

### 1. Container Integration
```python
# Use containers for reproducibility
rule containerized_analysis:
    input: "data.txt"
    output: "results/analysis.txt"
    container: "docker://biocontainers/tool:version"
    shell: "tool analyze {input} {output}"
```

### 2. Cloud Deployment
```bash
# Submit to cloud executor
snakemake --executor cloud-batch \
          --cloud-batch-region us-west-2 \
          --default-resources mem_mb=8000 runtime=60
```

### 3. HPC Integration
```bash
# Submit to SLURM cluster
snakemake --executor slurm \
          --default-resources slurm_account=myaccount \
          --jobs 100
```

## Documentation Standards

### 1. Rule Documentation
```python
rule well_documented_rule:
    """
    Perform quality control analysis on raw sequencing data.

    This rule runs FastQC on input FASTQ files to assess:
    - Base quality distributions
    - Sequence length distributions
    - Adapter contamination
    - Overrepresented sequences

    Input:
        Raw FASTQ files from sequencing

    Output:
        HTML quality control reports

    Resources:
        - CPU: 1 core
        - Memory: 2GB
        - Runtime: ~10 minutes per file
    """
    input: "data/{sample}.fastq.gz"
    output: "results/qc/{sample}_fastqc.html"
    shell: "fastqc {input} -o results/qc/"
```

### 2. Workflow Documentation
Include comprehensive README sections:
- Analysis objectives
- Input data requirements
- Configuration parameters
- Expected outputs
- Troubleshooting guide
- Citation information
