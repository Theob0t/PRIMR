---
title: "PRIMR Pipeline"
author: "Theo Botella"
date: "2023-12-14"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{PRIMR Pipeline}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



This vignette explain how to use PRIMR

# Overview

1. Run PRIMR
2. Genreate Counts Matrix

## Load PRIMR


```r
library(PRIMR)

library(dplyr)
library(reshape2)
```


## Inputs


```r
out=system.file("vignettes", "outs", package="PRIMR")
bamfile=system.file("vignettes/data", "datatest.bam", package="PRIMR")
ampfile=system.file("vignettes/data", "ampliconsPanel.txt", package="PRIMR")
sample.id='testPRIMR'
nthreads=40
```


## runPRIMR 


```r
runPRIMR_script=system.file("scripts", "runPRIMR.sh", package="PRIMR")
cigar_correction_script = system.file("scripts", "primr_cigar_correction.awk", package="PRIMR")


runPRIMR(out=out, bamfile=bamfile, ampfile=ampfile,sample.id=sample.id,nthreads=nthreads)
#> [1] "PRIMER V.0.1.0"
```

## countReads


```r
qnames.path=paste0(out,'/',sample.id,'/filtered_qnames/qnames_',sample.id,'.txt')
format='seurat'

countReads(out=out, qnames.path=qnames.path, sample.id=sample.id, format=format)
#> [1] "----SAVING COUNTS MATRIX----"
```

