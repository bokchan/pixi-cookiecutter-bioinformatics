# Common functions and utilities for {{cookiecutter.project_name}}

def get_sample_fastqs(wildcards):
    """Get FASTQ files for a given sample from samples.tsv"""
    sample_info = samples_df[samples_df["sample_id"] == wildcards.sample].iloc[0]
    return {
        "r1": sample_info["fastq_1"],
        "r2": sample_info["fastq_2"]
    }

def get_samples_by_condition(condition):
    """Get all samples for a given condition"""
    return samples_df[samples_df["condition"] == condition]["sample_id"].tolist()

# TODO: Add more helper functions as needed for your analysis
# Examples:
# - Functions to parse sample metadata
# - Functions to determine input files based on sample type
# - Functions to set resource requirements based on file sizes
# - Functions to handle different experimental designs
