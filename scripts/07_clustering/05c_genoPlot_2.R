setwd("/bulk/liu3zhen/research/projects/panMoGenome/main_MoTmini/25_haplotyping/01_coreHaplotyping/chr1")

##################
chr <- "chr1"

### B71 chr length and centromere
b71cent <- read.delim("/bulk/liu3zhen/research/projects/wheatBlast2.0/10-B71Ref2/2_characters/B71Ref2.centromeres", header=F)
cent_start <- b71cent[b71cent[1]==chr, 2]
cent_end <- b71cent[b71cent[1]==chr, 3]
b71len <- read.delim("~/references/fungi/magnaporthe/B71Ref2/genome/B71Ref2.length", header=F)
chrlen <- b71len[b71len[1]==chr,2]

### synteny data
syn <- read.delim("03o_chr1.synteny.10kb.bed", header=F)
head(syn)

### clustering
clust <- read.delim("04o_clust.txt")
taxa_order <- paste(chr, c("T_T47.v1", "T_T3.v1", "T_B71.v2", "T_16MOT01.v1",
                "T_OKI18.v1", "T_T21.v1", "T_NE20.v1", "T_Br48.v1",
                "T_P3.v1", "T_B2.v1"), sep="_")
clust <- clust[, c("interval", taxa_order)]
clust$chr <- gsub("\\:.*", "", clust$interval)
clust$start <- gsub("\\-.*", "", gsub(".*\\:", "", clust$interval))
clust$start <- as.numeric(as.character(clust$start))
clust$end <- gsub(".*\\-", "", gsub(".*\\:", "", clust$interval))
clust$end <- as.numeric(as.character(clust$end))
clust <- clust[order(clust$start), ]
datacols <- grep(paste0(chr, "_"), colnames(clust))
colnames(clust) <- gsub(paste0(chr, "_"), "", colnames(clust))
head(clust)

### filter
is_na_num <- apply(clust[, datacols], 1, function(x) sum(is.na(x)))
clust <- clust[is_na_num==0 & (clust$T_T47.v1 == clust$T_T3.v1), ]
head(clust)
### re-define genotyping result
for (i in 1:nrow(clust)) {
  original <- clust[i, ]
  modified <- original
  t47geno <- clust[i, "T_T47.v1"]
  if (t47geno > 0) {
    modified[original==t47geno] <- 0
    modified[original==0] <- t47geno
  }
  clust[i, ] <- modified
}


### plot
pdf(paste0("05o_", chr, ".haplotype.pdf"), width=6, height=6)

ntaxa <- length(datacols)
xmax <- chrlen
xrange <- c(1, xmax)
yrange <- c(0, ntaxa)
par(mar=c(2, 6, 3, 1))
plot(NULL, NULL, xlim=xrange, ylim=yrange, bty="n",
     xaxt="n", yaxt="n",
     xlab="", ylab="", main=chr)
###########################################################
# xaxis
###########################################################
smartaxis <- function(maxnum) {
  numdigits <- nchar(maxnum)
  unit <- 10 ^ (numdigits - 1) / (2- round((maxnum / 10 ^ numdigits), 0)) # 1 or 5 e (numdigits - 1)
  subunit <- unit / 5 
  
  numsat <- unit * (0:10)
  numsat <- numsat[numsat < maxnum]
  
  if (numdigits >= 7) {
    numlabels <- numsat / 1000000
    label.scale <- "Mb"
  } else if (numdigits < 7 & numdigits >= 4) {
    numlabels <- numsat / 1000
    label.scale <- "kb"
  } else {
    numlabels <- numsat
    label.scale <- "bp"
  }
  
  subunits <- seq(0, maxnum, by = subunit)
  subunits <- subunits[!subunits %in% c(numsat, 0)] 
  # return
  list(numsat, numlabels, label.scale, subunits)
}

xaxis_info <- smartaxis(xmax)
xaxis_values <- xaxis_info[[1]]
xaxis_labels <- xaxis_info[[2]]
xaxis_labels[length(xaxis_labels)] <- paste(xaxis_labels[length(xaxis_labels)], xaxis_info[[3]])
for (i in 1:length(xaxis_values)) {
  lines(rep(xaxis_values[i], 2), c(-0.3, ntaxa+0.6), lwd=0.5, col="gray60", xpd=T)
  text(xaxis_values[i], -0.3, pos=1, xaxis_labels[i], xpd=T)
}

###########################################################
# base bar
###########################################################
rect(1, 0, xmax, 0.6, col="gray95", border=NA)
for (i in 1:nrow(syn)) {
  rect(syn[i, 2], 0, syn[i, 3], 0.6, col="gray75", border=NA)
}
# centromere location
rect(cent_start, 0.15, cent_end, 0.45, col="red", border=NA)
###########################################################
# genotype
###########################################################
col_scheme <- c("gray30", "orange", "purple", "red", "blue", "dark green", "brown", "black")
row <- 0
for (j in datacols) {
  row <- row + 1
  for (i in 1:nrow(clust)) {
    if (sum(clust[i, datacols], na.rm=T) > 0) {
      location <- (clust[i, "start"] + clust[i, "end"]) / 2
      geno <- clust[i, j]
      points(location, row + geno * 0.2, pch=19, cex=0.3, col=col_scheme[geno + 1], xpd=T)
    }
  }
}

###########################################################
# labels
###########################################################
row <- 0
for (j in datacols) {
  row <- row + 1
  text(1, row + 0.1, colnames(clust)[j], pos=2, xpd=T)
}

dev.off()
