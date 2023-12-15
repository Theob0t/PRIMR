#' Amplicons Panel
#'
#' An example of an amplicon panel .txt file. Each row is an amplicon.
#' Columns order is: chromosome, amplicon 1 start position, amplicon 1 end position, amplicon 2 start position, amplicon 2 end position, amplicon id, gene_name, gene strand.
#' Order of amplicon is based on 5'-3' direction. File has no header.
#'
#' @format A data.frame
#' \describe{
#'   \item{Col1}{chromosome}
#'   \item{Col2}{amplicon 1 start position}
#'   \item{Col3}{amplicon 1 end position}
#'   \item{Col4}{amplicon 2 start position}
#'   \item{Col5}{amplicon 2 end position}
#'   \item{Col6}{amplicon id}
#'   \item{Col7}{gene name}
#'   \item{Col8}{gene strand}
#' }
#' @concept data
#'
"amplicons"

#' Amplicons Panel (complete)
#'
#' The amplicon panel used in the original manuscript. Each row is an amplicon.
#' Columns order is: chromosome, amplicon 1 start position, amplicon 1 end position, amplicon 2 start position, amplicon 2 end position, amplicon id, gene_name, gene strand.
#' Order of amplicon is based on 5'-3' direction. File has no header.
#'
#' @format A data.frame
#' \describe{
#'   \item{Col1}{chromosome}
#'   \item{Col2}{amplicon 1 start position}
#'   \item{Col3}{amplicon 1 end position}
#'   \item{Col4}{amplicon 2 start position}
#'   \item{Col5}{amplicon 2 end position}
#'   \item{Col6}{amplicon id}
#'   \item{Col7}{gene name}
#'   \item{Col8}{gene strand}
#' }
#' @concept data
#'
"amplicons_full"
