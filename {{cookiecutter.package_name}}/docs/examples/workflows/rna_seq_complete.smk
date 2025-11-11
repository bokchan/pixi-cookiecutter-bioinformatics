# Complete RNA-seq workflow example
# Copy and modify rules for your analysis

import pandas as pd

configfile: "config/config.yaml"
samples_df = pd.read_csv("config/samples.tsv", sep="\t")
SAMPLES = samples_df["sample_id"].tolist()

include: "rules/common.smk"

rule all:
    input:
        "results/qc/multiqc_report.html",
        expand("results/aligned/{sample}.bam", sample=SAMPLES),
        "results/counts/gene_counts.tsv",
        "results/differential_expression/deseq2_results.csv"

rule fastqc:
    input:
        r1="resources/raw_data/{sample}_R1.fastq.gz",
        r2="resources/raw_data/{sample}_R2.fastq.gz"
    output:
        html_r1="results/qc/{sample}_R1_fastqc.html",
        html_r2="results/qc/{sample}_R2_fastqc.html"
    threads: config["quality_control"]["fastqc"]["threads"]
    conda: "../envs/qc.yaml"
    shell:
        "fastqc {input.r1} {input.r2} --outdir results/qc --threads {threads}"

rule trim_adapters:
    input:
        r1="resources/raw_data/{sample}_R1.fastq.gz",
        r2="resources/raw_data/{sample}_R2.fastq.gz",
        adapters=config["trimming"]["adapters"]
    output:
        r1="results/trimmed/{sample}_R1_trimmed.fastq.gz",
        r2="results/trimmed/{sample}_R2_trimmed.fastq.gz"
    threads: config["trimming"]["threads"]
    conda: "../envs/trimming.yaml"
    shell:
        """
        trimmomatic PE -threads {threads} {input.r1} {input.r2}
        {output.r1} /tmp/{wildcards.sample}_R1_unpaired.fastq.gz
        {output.r2} /tmp/{wildcards.sample}_R2_unpaired.fastq.gz
        ILLUMINACLIP:{input.adapters}:2:30:10
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:{config[trimming][quality_threshold]}
        MINLEN:{config[trimming][min_length]}
        """

rule align_star:
    input:
        r1="results/trimmed/{sample}_R1_trimmed.fastq.gz",
        r2="results/trimmed/{sample}_R2_trimmed.fastq.gz",
        index=config["reference"]["index_dir"]
    output:
        bam="results/aligned/{sample}.bam"
    threads: config["alignment"]["star"]["threads"]
    conda: "../envs/alignment.yaml"
    shell:
        """
        STAR --runThreadN {threads}
             --genomeDir {input.index}
             --readFilesIn {input.r1} {input.r2}
             --readFilesCommand zcat
             --outFileNamePrefix results/aligned/{wildcards.sample}.
             --outSAMtype BAM SortedByCoordinate
        mv results/aligned/{wildcards.sample}.Aligned.sortedByCoord.out.bam {output.bam}
        """

rule count_genes:
    input:
        bams=expand("results/aligned/{sample}.bam", sample=SAMPLES),
        annotation=config["reference"]["annotation"]
    output:
        counts="results/counts/gene_counts.tsv"
    threads: config["resources"]["default_threads"]
    conda: "../envs/counting.yaml"
    shell:
        """
        featureCounts -T {threads} -t {config[expression][feature_type]}
        -g {config[expression][attribute]} -a {input.annotation}
        -o {output.counts} {input.bams}
        """

rule differential_expression:
    input:
        counts="results/counts/gene_counts.tsv",
        samples="config/samples.tsv"
    output:
        results="results/differential_expression/deseq2_results.csv"
    conda: "../envs/r_analysis.yaml"
    script:
        "../scripts/run_deseq2.R"

rule multiqc:
    input:
        expand("results/qc/{sample}_R{read}_fastqc.html", sample=SAMPLES, read=[1,2]),
        expand("results/aligned/{sample}.bam", sample=SAMPLES)
    output:
        "results/qc/multiqc_report.html"
    conda: "../envs/qc.yaml"
    shell:
        "multiqc results/ --outdir results/qc"
