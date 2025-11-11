# Example: RNA-seq Quality Control and Alignment Workflow
# This workflow demonstrates using multiple pixi environments for a complete RNA-seq analysis

rule all:
    input:
        "results/reports/multiqc_report.html",
        expand("results/aligned/{sample}.sorted.bam", sample=config["samples"]),
        "results/counts/gene_counts.tsv"

# Quality Control - uses default environment with FastQC
rule fastqc:
    input:
        "resources/raw_data/{sample}_R1.fastq.gz"
    output:
        html="results/qc/{sample}_R1_fastqc.html",
        zip="results/qc/{sample}_R1_fastqc.zip"
    shell:
        "fastqc {input} -o results/qc/"

# MultiQC aggregation - uses default environment
rule multiqc:
    input:
        expand("results/qc/{sample}_R1_fastqc.zip", sample=config["samples"])
    output:
        "results/reports/multiqc_report.html"
    shell:
        "multiqc results/qc/ -o results/reports/"

# Read trimming - uses default environment with Trimmomatic
rule trim_reads:
    input:
        r1="resources/raw_data/{sample}_R1.fastq.gz",
        r2="resources/raw_data/{sample}_R2.fastq.gz"
    output:
        r1="results/trimmed/{sample}_R1_trimmed.fastq.gz",
        r2="results/trimmed/{sample}_R2_trimmed.fastq.gz",
        r1_unpaired="results/trimmed/{sample}_R1_unpaired.fastq.gz",
        r2_unpaired="results/trimmed/{sample}_R2_unpaired.fastq.gz"
    params:
        adapters=config.get("trimmomatic_adapters", "TruSeq3-PE-2.fa"),
        quality_settings="LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36"
    threads: 4
    shell:
        """
        trimmomatic PE -threads {threads} {input.r1} {input.r2} \
            {output.r1} {output.r1_unpaired} \
            {output.r2} {output.r2_unpaired} \
            ILLUMINACLIP:{params.adapters}:2:30:10 {params.quality_settings}
        """

# STAR alignment - uses rnaseq environment
# Note: In practice, this would be run with: pixi run -e rnaseq snakemake --snakefile workflow/example_rnaseq.smk
rule star_align:
    input:
        r1="results/trimmed/{sample}_R1_trimmed.fastq.gz",
        r2="results/trimmed/{sample}_R2_trimmed.fastq.gz",
        index=config["star_index"]
    output:
        bam="results/aligned/{sample}.Aligned.out.bam",
        log="results/aligned/{sample}.Log.final.out"
    params:
        prefix="results/aligned/{sample}.",
        extra="--outSAMtype BAM Unsorted --readFilesCommand zcat"
    threads: 8
    shell:
        """
        STAR --genomeDir {input.index} \
             --readFilesIn {input.r1} {input.r2} \
             --runThreadN {threads} \
             --outFileNamePrefix {params.prefix} \
             {params.extra}
        """

# Sort BAM files - uses default environment with SAMtools
rule sort_bam:
    input:
        "results/aligned/{sample}.Aligned.out.bam"
    output:
        "results/aligned/{sample}.sorted.bam"
    threads: 4
    shell:
        "samtools sort -@ {threads} {input} -o {output}"

# Index BAM files - uses default environment with SAMtools
rule index_bam:
    input:
        "results/aligned/{sample}.sorted.bam"
    output:
        "results/aligned/{sample}.sorted.bam.bai"
    shell:
        "samtools index {input}"

# Gene quantification - uses rnaseq environment with featureCounts
rule feature_counts:
    input:
        bams=expand("results/aligned/{sample}.sorted.bam", sample=config["samples"]),
        gtf=config["gtf_file"]
    output:
        counts="results/counts/gene_counts.tsv",
        summary="results/counts/gene_counts.tsv.summary"
    params:
        extra="-t exon -g gene_id -s 0"  # Unstranded counting
    threads: 4
    shell:
        """
        featureCounts -T {threads} {params.extra} \
            -a {input.gtf} -o {output.counts} {input.bams}
        """

# Advanced QC with Qualimap - uses qc environment
rule qualimap:
    input:
        bam="results/aligned/{sample}.sorted.bam",
        bai="results/aligned/{sample}.sorted.bam.bai"
    output:
        directory("results/qc/qualimap_{sample}")
    shell:
        """
        qualimap rnaseq -bam {input.bam} -outdir {output} \
            -gtf {config[gtf_file]} --java-mem-size=4G
        """
