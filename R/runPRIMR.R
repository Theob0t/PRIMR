#' Split the original BAM file into amplicons using a amplicon file
#'
#' @param out Output directory
#' @param bamfile Path to the aligned BAM file
#' @param ampfile Path to the amplicon file. The file is a .txt file (tabulation) without header. The columns order is : chr, amplicon1_start, amplicon1_end, amplicon2_start, amplicon2_end, amplicon_id, gene_name and gene_strand (+ if gene's coding strand is on the forward strand, - if it's on the reverse strand 3'-5')
#' @param sample.id Character vector of length one indicating the sample name
#' @param nthreads Integer indicating the number of threads to use for parallel processing
#' @return a BAM file per amplicon in the BED file
#' @export
#'

runPRIMR = function(out="/gpfs/commons/home/tbotella/PRIMR/tests",
                    bamfile='/gpfs/commons/home/tbotella/PRIMR/data/datatest.bam',
                    ampfile='/gpfs/commons/home/tbotella/PRIMR/data/ampliconsPanel.txt',
                    sample.id='testSample',
                    nthreads=4
){
        print('PRIMER V.0.1.0')

        #runPRIMR_script=paste0(find.package('PRIMR'), '/inst/runPRIMR.sh')

        runPRIMR_script=system.file("scripts", "runPRIMR.sh", package="PRIMR")

        #cigar_correction_script= paste0(find.package('PRIMR'), '/inst/primr_cigar_correction.awk')

        cigar_correction_script = system.file("scripts", "primr_cigar_correction.awk", package="PRIMR")

        # Split the original bam file and write paths to split_bams.txt
        system(paste('bash', runPRIMR_script, out, bamfile, ampfile, sample.id, nthreads, cigar_correction_script))
}
