setwd("/bulk/liu3zhen/research/projects/panMoGenome/main_MoTmini/02_tree/05_miniC")

datapath="_predout/"
outfiles <- dir(path=datapath, pattern="filt.fq.gz.final.csv")

allout <- NULL
for (efile in outfiles) {
  fp_efile <- paste0(datapath, "/", efile)
  out <- read.csv(fp_efile)
  if (is.null(allout)) {
    allout <- out
  } else {
    allout <- rbind(allout, out)
  }
}

allout <- data.frame(allout)
head(allout)

allout$isolate <- gsub(".R[12].filt.fq.gz", "", allout$data)

minic <- tapply(allout$mini_percent, allout$isolate, mean)
minic.df <- data.frame(MiniC=minic, Isolate=rownames(minic))

write.table(minic.df, "2o_MoLT.minic.txt", quote=F, row.names=F, sep="\t")
