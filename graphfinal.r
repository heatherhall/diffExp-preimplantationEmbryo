twocell <- read.table("~/Dropbox/Genomics/E-GEOD-29397.processed.1/Original_Data/new_signif_GO_2-cell_stage_human_embryo.txt",sep="\t",stringsAsFactors=FALSE)
fourcell <- read.table("~/Dropbox/Genomics/E-GEOD-29397.processed.1/Original_Data/new_signif_GO_4-cell_stage_human_embryo.txt",sep="\t")
sixcell <- read.table("~/Dropbox/Genomics/E-GEOD-29397.processed.1/Original_Data/new_signif_GO_6-cell_stage_human_embryo.txt",sep="\t")
eightcell <- read.table("~/Dropbox/Genomics/E-GEOD-29397.processed.1/Original_Data/new_signif_GO_8_to_10-cell_stage_human_embryo.txt",sep="\t")
morula <- read.table("~/Dropbox/Genomics/E-GEOD-29397.processed.1/Original_Data/new_signif_GO_morula_stage_human_embryo.txt",sep="\t")
blastocyst <- read.table("~/Dropbox/Genomics/E-GEOD-29397.processed.1/Original_Data/new_signif_GO_blastocyst_stage_human_embryo.txt",sep="\t")
oocyte <- read.table("~/Dropbox/Genomics/E-GEOD-29397.processed.1/Original_Data/new_signif_GO_Metaphase_II_Oocyte.txt",sep="\t")

twocell$V0 <- apply(twocell,1,function(row) "2 Cell")
fourcell$V0 <- apply(fourcell,1,function(row) "4 Cell")
sixcell$V0 <- apply(sixcell,1,function(row) "6 Cell")
eightcell$V0 <- apply(eightcell,1,function(row) "8-10 Cell")
morula$V0 <- apply(morula,1,function(row) "Morula")
blastocyst$V0 <- apply(blastocyst,1,function(row) "Blastocyst")
oocyte$V0 <- apply(oocyte,1,function(row) "Oocyte")


data = data.frame(rbind(twocell,fourcell,sixcell,eightcell,morula,blastocyst,oocyte))
samp = c(oocyte$V0,twocell$V0,fourcell$V0,sixcell$V0,eightcell$V0,blastocyst$V0,morula$V0)
library(ggplot2)

GO_Terms = c(data$V1)
genenum = c(data$V3)
depth = c(data$V2)
samples= c(data$V0)

## orders the samples in the level order requested
samples <- factor(samples, levels= c("Oocyte","2 Cell","4 Cell","6 Cell","8-10 Cell","Blastocyst","Morula"))
goterms2 <- factor(GO_Terms, levels = c(" other (P-Value > 0.01)(0)", " development(2)", " cellular process(2)", 
                                         " reproduction(3)", " sexual reproduction(4)", " bone remodeling(4)", 
                                         " fertilization(5)", " ossification(5)", " aromatic amino acid family metabolism(6)", 
                                         " antigen processing, endogenous antigen via MHC class I(6)", 
                                         " cytoskeleton-dependent intracellular transport(6)", " antigen presentation, endogenous antigen(6)", 
                                         " G-protein coupled receptor protein signaling pathway(6)", " fertilization (sensu Metazoa)(6)", 
                                         " microtubule-based movement(7)", " protein polymerization(7)", 
                                         " microtubule polymerization(8)"))

#plot the stacked bar plot
ggplot(data, aes(x = samples)) +geom_bar(aes(weight=genenum, fill = GO_Terms),colour = "grey") +xlab("Developmental State") + ylab("Number of Genes") + labs(title = "Differentially Expressed Genes During Embryonic Development\n-A Comparison with Embryonic Stem Cells-") + theme(plot.title = element_text(size = 27))

png("~/Desktop/pic.png")

