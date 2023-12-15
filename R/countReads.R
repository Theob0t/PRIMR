#' Counts number of reads for each gene in each barcodes
#'
#' @param out Output directory
#' @param qnames.path Path to the qnames file made with runPRIMR() function
#' @param format Return the counts matrix in a gene by cells format ('seurat'), in a cells by genes format ('anndata'), or both ('both')
#' @param sample.id Character vector of length one indicating the sample name
#' @import dplyr
#' @import reshape2
#' @import utils
#' @return The filtered counts matrix
#' @export
#'


countReads = function(out = '/path.to.ouput.dir/',
                      qnames.path = '/path.to.qnames/',
                      format = 'both',
                      sample.id = 'test_small') {
  if (!file.exists(paste0(out, '/', sample.id))) {
    stop("The qnames file does not exist: ", out)
  }

  out = paste0(out, '/', sample.id)

  qnames = utils::read.table(qnames.path, header = FALSE, sep = ":")

  # group by cells (V9) and gene (V10) and return number of reads per cell per gene
  counts <- qnames %>%
    count(.data$V9,  .data$V10)

  # convert matrix long to wide format
  counts <-
    reshape2::dcast(counts,  counts$V9 ~ counts$V10, value.var = 'n')

  # replace NAs (0 reads/barcodes) in the counts matrix by 0
  counts[is.na(counts)] <- 0

  # make V9 (barcodes) the row names and delete V9
  counts <- data.frame(counts, row.names = counts$`counts$V9`)

  # remove barcodes columns
  counts$counts.V9 = NULL

  print('----SAVING COUNTS MATRIX----')
  if (format == 'both') {
    write.csv(counts,
              paste0(out, '/', sample.id, '_cellxgene.csv'),
              row.names = TRUE)
    write.csv(t(counts),
              paste0(out, '/', sample.id, '_genexcell.csv'),
              row.names = TRUE)
  } else if (format == 'seurat') {
    write.csv(t(counts),
              paste0(out, '/', sample.id, '_genexcell.csv'),
              row.names = TRUE)
  } else if (format == 'anndata') {
    write.csv(counts,
              paste0(out, '/', sample.id, '_cellxgene.csv'),
              row.names = TRUE)
  }
}
