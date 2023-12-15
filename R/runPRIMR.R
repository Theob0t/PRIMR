#' Split the original BAM file into amplicons using a amplicon file
#'
#' @param out Output directory
#' @param bamfile Path to the aligned BAM file
#' @param ampfile Path to the amplicon file. The file is a .txt file (tabulation) without header. The columns order is : chr, amplicon1_start, amplicon1_end, amplicon2_start, amplicon2_end, amplicon_id, gene_name and gene_strand (+ if gene's coding strand is on the forward strand, - if it's on the reverse strand 3'-5')
#' @param sample.id Character vector of length one indicating the sample name
#' @param nthreads Integer indicating the number of threads to use for parallel processing
#' @import dplyr
#' @import reshape2
#' @import grDevices
#' @import graphics
#' @import utils
#' @import ggplot2
#' @return Create a folder with the reads that pass PRIMR QC, a filtered BAM file, a barplot as pdf for read counts pre/post filtering and a tmp folder with all intermediate files
#' @export
#'

runPRIMR = function(out = "/gpfs/commons/home/tbotella/PRIMR/tests",
                    bamfile = '/gpfs/commons/home/tbotella/PRIMR/data/datatest.bam',
                    ampfile = '/gpfs/commons/home/tbotella/PRIMR/data/ampliconsPanel.txt',
                    sample.id = 'testSample',
                    nthreads = 4
){



        runPRIMR_script = system.file("runPRIMR.sh", package = "PRIMR")

        cigar_correction_script = system.file("primr_cigar_correction.awk", package =
                                                      "PRIMR")

        # Split the original bam file and write paths to split_bams.txt
        system(
                paste(
                        'bash',
                        runPRIMR_script,
                        out,
                        bamfile,
                        ampfile,
                        sample.id,
                        nthreads,
                        cigar_correction_script
                )
        )

        # Get number of reads pre/post filtering
        bamfile.length = as.integer(system(paste0("wc -l < ", bamfile), intern = TRUE))
        filtered.bamfile.length = as.integer(system(
                paste0(
                        "wc -l < ",
                        out,
                        '/',
                        sample.id,
                        '/',
                        sample.id,
                        '_PRIMR_filtered.bam'
                ),
                intern = TRUE
        ))


        # Plot barplot
        values = c(bamfile.length, filtered.bamfile.length)
        data <-
                data.frame(variables = c("Original .BAM", "PRIMR Filtered .BAM"),
                           values = values)

        p1 = ggplot(data, aes_string(x = "variables", y = "values", fill = "variables")) +
                geom_bar(stat = "identity", position = "dodge") +
                ylab("Number of Reads") + xlab('') + ggtitle(sample.id) +
                scale_fill_manual(values = c("Original .BAM" = "brown", "PRIMR Filtered .BAM" = "#dda15e")) +
                theme_minimal(base_size = 12) + theme(
                        legend.position = "none",
                        axis.text.x = element_text(size = 12, face = "bold"),
                        plot.title = element_text(hjust = 0.5)
                ) +
                geom_text(
                        aes(label = format(values, big.mark = ",")),
                        vjust = -0.5,
                        color = 'black',
                        position = position_dodge(width = 0.9)
                )



        ggsave(filename = paste0(out, '/', sample.id, '/', "barplot.pdf"),
               plot = p1)

        return(p1)
}

