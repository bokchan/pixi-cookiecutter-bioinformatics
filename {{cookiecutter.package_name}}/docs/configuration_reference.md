# Configuration Reference

This document provides comprehensive configuration options for professional bioinformatics workflows.

## Configuration Files Overview

```
config/
├── config.yaml          # Main analysis parameters
├── samples.tsv          # Sample metadata and experimental design
└── schemas/             # Validation schemas (optional)
    ├── config.schema.yaml
    └── samples.schema.yaml
```

## Main Configuration (`config/config.yaml`)

### Project Metadata
```yaml
# Project identification and context
project:
  name: "RNA-seq Differential Expression Analysis"
  description: "Comparative transcriptomics of treatment vs control"
  version: "1.0.0"
  author: "Lab Name"
  contact: "researcher@institution.edu"

# Analysis reproducibility
workflow:
  snakemake_version: ">=8.20"
  creation_date: "2024-01-15"
  last_modified: "2024-01-20"
```

### Data Organization
```yaml
# Directory structure configuration
data:
  # Raw sequencing data location
  raw_data_dir: "resources/raw_data"

  # Reference data location
  reference_dir: "resources/external"

  # Analysis output location
  results_dir: "results"

  # Temporary files (can be on fast storage)
  temp_dir: "workspace"

  # Final reports and publications
  reports_dir: "results/reports"
```

### Reference Datasets
```yaml
reference:
  # Genome assembly information
  genome:
    fasta: "resources/external/GRCh38.primary_assembly.genome.fa"
    version: "GRCh38.p14"
    source: "GENCODE"

  # Gene annotation
  annotation:
    gtf: "resources/external/gencode.v44.primary_assembly.annotation.gtf"
    version: "GENCODE v44"
    feature_type: "gene"  # for featureCounts

  # Pre-built indices (create if not available)
  indices:
    star: "resources/external/star_index_GRCh38"
    bwa: "resources/external/bwa_index/GRCh38"
    salmon: "resources/external/salmon_index_gencode44"

  # Variant calling resources (optional)
  known_variants:
    dbsnp: "resources/external/dbsnp_146.hg38.vcf.gz"
    mills_indels: "resources/external/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"
```

### Analysis Parameters
```yaml
analysis:
  # Computational resources
  resources:
    default_threads: 4
    max_threads: 16
    default_memory: "8GB"
    max_memory: "64GB"

  # Quality thresholds
  quality_control:
    min_read_quality: 20        # Phred score
    min_read_length: 50         # Post-trimming
    max_n_content: 5            # Percentage

  # Analysis-specific parameters
  rna_seq:
    # Library preparation
    library_type: "fr-firststrand"  # or "fr-unstranded", "fr-secondstrand"

    # Alignment parameters
    star:
      outFilterMultimapNmax: 20
      outFilterMismatchNmax: 999
      outFilterMismatchNoverLmax: 0.04
      alignIntronMin: 20
      alignIntronMax: 1000000

    # Quantification parameters
    salmon:
      library_type: "ISR"      # Inward Stranded Reverse
      validate_mappings: true
      gc_bias: true
      seq_bias: true

    # Gene counting
    feature_counts:
      feature_type: "exon"
      attribute_type: "gene_id"
      strand_specificity: 2     # 0=unstranded, 1=stranded, 2=reverse

  # Variant calling (if applicable)
  variant_calling:
    # Caller selection
    caller: "gatk"  # or "freebayes", "bcftools"

    # GATK parameters
    gatk:
      java_opts: "-Xmx8g"
      stand_call_conf: 30.0
      stand_emit_conf: 10.0

    # Filtering criteria
    filters:
      snp_filter: "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5"
      indel_filter: "QD < 2.0 || FS > 200.0 || MQRankSum < -12.5"
```

### Tool-Specific Configuration
```yaml
# Tool parameters organized by analysis stage
tools:
  # Quality control
  fastqc:
    adapters: "auto"
    kmers: 7

  multiqc:
    config: "config/multiqc_config.yaml"
    ignore_dirs: ["tmp", "temp", "scratch"]

  trimmomatic:
    adapters: "TruSeq3-PE-2.fa"
    leading: 3
    trailing: 3
    sliding_window: "4:15"
    min_length: 36

  # Alignment tools
  star:
    sjdb_overhang: 100  # read_length - 1
    genome_load: "NoSharedMemory"

  bwa:
    algorithm: "mem"
    mark_shorter_splits: true

  # Processing tools
  samtools:
    sort_memory: "2G"
    threads: 4

  # Analysis tools
  deseq2:
    alpha: 0.05
    lfc_threshold: 0.0
    cook_cutoff: true
```

## Sample Metadata (`config/samples.tsv`)

### Basic Format
```tsv
sample	condition	batch	replicate	read1	read2
sample1	control	1	1	sample1_R1.fastq.gz	sample1_R2.fastq.gz
sample2	control	1	2	sample2_R1.fastq.gz	sample2_R2.fastq.gz
sample3	treatment	1	1	sample3_R1.fastq.gz	sample3_R2.fastq.gz
sample4	treatment	1	2	sample4_R1.fastq.gz	sample4_R2.fastq.gz
```

### Extended Metadata
```tsv
sample	condition	batch	sex	age	tissue	library_prep	sequencing_date	notes
ctrl_01	control	batch1	F	25	liver	TruSeq	2024-01-10	high_quality
ctrl_02	control	batch1	M	30	liver	TruSeq	2024-01-10
treat_01	drug_A	batch1	F	28	liver	TruSeq	2024-01-15
treat_02	drug_A	batch2	M	32	liver	TruSeq	2024-01-20	batch_effect_check
```

### Validation Rules
- **sample**: Unique identifier (no spaces or special characters)
- **condition**: Experimental conditions for comparison
- **batch**: Technical batches for batch effect analysis
- **read1/read2**: FASTQ file paths (relative to `raw_data_dir`)

## Environment-Specific Configuration

### Development Environment
```yaml
# config/dev_config.yaml
analysis:
  resources:
    default_threads: 2
    max_memory: "8GB"

# Subset data for faster testing
data:
  test_samples: ["sample1", "sample2"]  # Only process these samples

tools:
  star:
    genome_load: "LoadAndKeep"  # Faster for multiple runs
```

### Production Environment
```yaml
# config/prod_config.yaml
analysis:
  resources:
    default_threads: 16
    max_memory: "128GB"

# Full dataset processing
quality_control:
  strict_filtering: true

tools:
  star:
    genome_load: "LoadAndExit"  # Memory efficient for clusters
```

## Validation Schemas

### Configuration Schema (`schemas/config.schema.yaml`)
```yaml
$schema: "http://json-schema.org/draft-07/schema#"

type: object
properties:
  project:
    type: object
    required: ["name"]

  reference:
    type: object
    properties:
      genome:
        type: object
        properties:
          fasta:
            type: string
            pattern: "\\.(fa|fasta)(\\.gz)?$"
        required: ["fasta"]
    required: ["genome"]

  analysis:
    type: object
    properties:
      resources:
        type: object
        properties:
          default_threads:
            type: integer
            minimum: 1
            maximum: 128

required: ["project", "reference", "analysis"]
```

## Best Practices

### 1. Configuration Management
- **Version control**: Track configuration changes with git
- **Environment separation**: Use different configs for dev/test/prod
- **Validation**: Use schemas to catch configuration errors early
- **Documentation**: Comment complex parameter choices

### 2. Parameter Selection
- **Literature review**: Base parameters on established protocols
- **Pilot studies**: Test parameters on subset of data first
- **Tool documentation**: Follow tool-specific best practices
- **Reproducibility**: Document rationale for non-default parameters

### 3. Scalability Considerations
- **Resource scaling**: Configure based on available hardware
- **Batch processing**: Group samples efficiently for cluster jobs
- **Storage optimization**: Use appropriate temporary directories
- **Parallelization**: Balance threads vs. memory requirements

### 4. Quality Control Integration
- **Threshold setting**: Set appropriate quality cutoffs
- **Checkpoint validation**: Validate data at each processing step
- **Error handling**: Configure graceful failure modes
- **Reporting**: Generate comprehensive quality reports

## Common Configuration Patterns

### Multi-Species Analysis
```yaml
species:
  human:
    reference:
      genome: "resources/GRCh38/genome.fa"
      annotation: "resources/GRCh38/annotation.gtf"
  mouse:
    reference:
      genome: "resources/GRCm39/genome.fa"
      annotation: "resources/GRCm39/annotation.gtf"
```

### Time Course Experiments
```yaml
time_points: ["0h", "2h", "6h", "12h", "24h"]
comparisons:
  - ["2h", "0h"]
  - ["6h", "0h"]
  - ["12h", "0h"]
  - ["24h", "0h"]
```

### Paired Analysis (Treatment vs Control)
```yaml
contrasts:
  - name: "treatment_vs_control"
    numerator: "treatment"
    denominator: "control"
    covariates: ["batch", "sex"]
```

## Troubleshooting Configuration Issues

### Common Problems
1. **File path errors**: Use absolute paths or ensure relative paths are correct
2. **Resource conflicts**: Ensure thread/memory requests don't exceed available resources
3. **Parameter incompatibility**: Check tool documentation for valid parameter combinations
4. **Schema validation**: Use `snakemake --lint` to validate configuration

### Debugging Tips
```bash
# Validate configuration
snakemake --lint

# Test configuration parsing
snakemake --configfile config/config.yaml --dryrun

# Debug specific rules
snakemake --debug-dag rule_name
```
