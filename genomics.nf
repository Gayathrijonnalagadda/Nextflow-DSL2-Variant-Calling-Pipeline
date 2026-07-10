#!/usr/bin/env nextflow

// Module INCLUDE statements
include { SAMTOOLS_INDEX } from './modules/samtools_index.nf'
include{ GATK_HAPLOTYPECALLER } from './modules/gatk_haplotypecaller.nf'
include { GATK_JOINTGENOTYPING } from './modules/gatk_jointgenotyping.nf'
/*
 * Pipeline parameters
 */
 
 params {
    //primary input
    //input //: Path 
  //restoring the type annotation to send input in a file
     input: Path
	//files need to run gatk
	reference: Path
	reference_index: Path
	reference_dict: Path
	intervals: Path
	//base name for final output file
	cohort_name: String
	}
workflow {

    main:
    // Create input channel
	reads_ch = channel.fromPath(params.input)
	//updating the channel to parse csv input
	           .splitCsv(header: true)
			   .map { row -> file(row.reads_bam) }
	
	//loading the file paths for accessory files
	ref_file = file(params.reference)
	ref_file_index = file(params.reference_index)
	ref_file_dict = file (params. reference_dict)
	intervals_file = file(params.intervals)

    // Call processes
	SAMTOOLS_INDEX(reads_ch)
	
	//temporary diagnostics
	reads_ch.view()
	SAMTOOLS_INDEX.out.view()
	
	//calling variants
	GATK_HAPLOTYPECALLER(
	SAMTOOLS_INDEX.out,
	ref_file,
	ref_file_index,
	ref_file_dict,
	intervals_file
	)
    
	//collevct variant calling outputs across samples
	all_gvcfs_ch = GATK_HAPLOTYPECALLER.out.vcf.collect()
    all_idxs_ch = GATK_HAPLOTYPECALLER.out.idx.collect()
	
	// Combine GVCFs into a GenomicsDB data store and apply joint genotyping
    GATK_JOINTGENOTYPING(
        all_gvcfs_ch,
        all_idxs_ch,
        intervals_file,
        params.cohort_name,
        ref_file,
        ref_file_index,
        ref_file_dict
    )
	
    publish:
    // Declare outputs to publish
	indexed_bam = SAMTOOLS_INDEX.out
	gvcf = GATK_HAPLOTYPECALLER.out.vcf
	gvcf_idx = GATK_HAPLOTYPECALLER.out.idx
	joint_vcf = GATK_JOINTGENOTYPING.out.vcf
    joint_vcf_idx = GATK_JOINTGENOTYPING.out.idx
}

output {
    // Configure publish targets
	indexed_bam {
	  path 'bam'
	}
	//variant calls
	gvcf {
	  path 'gvcf'
	}
	gvcf_idx {
      path 'gvcf'
    }	
    joint_vcf {
       path '.'
    }
	joint_vcf_idx {
	   path '.'
	}
	
}
