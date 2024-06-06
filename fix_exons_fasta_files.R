############################################
# Install required packages
############################################
install.packages("data.table")
install.packages("dplyr")
install.packages("GenomicRanges")
install.packages("BSgenome")
BiocManager::install("BSgenome.Hsapiens.UCSC.hg38")
BiocManager::install("biomaRt", force = TRUE)
install.packages("yaml")

# Load required libraries
library(data.table)
library(dplyr)
library("GenomicRanges")
library("BSgenome")
library(BSgenome.Hsapiens.UCSC.hg38)
library(biomaRt)
library(yaml)

############################################
# Functions
############################################

getSequence <- function(gr=merge.bbmap.results.gr[as.character(strand(merge.bbmap.results.gr))=="+"], genome=Hsapiens, ucscToEnsembl=1, upflank=0, strand="+", addMetadata=TRUE)
{
  if(addMetadata){
    values(gr)$seq<-rep( "null", length(gr) )
  } else{
    mcols(gr) <- DataFrame(seq=rep( "null", length(gr) ))  
  }
  
  for(chr in (sort(unique(seqnames(gr))))){
    # message(chr)
    gr.select <- gr[seqnames(gr)==chr]
    if(ucscToEnsembl){
      chr.ucsc<-noquote(paste0("chr",chr))
    } else{ chr.ucsc<-chr }
    if(chr=="MT" || chr=="chrMT"){chr.ucsc="chrM"}
    
    chr.seq <- genome[[chr.ucsc]]
    
    if(upflank>0){
      
      if(strand=="+"){
        
        start <- start(gr.select) - upflank
        
        start[start<1] <- 1
        seq <- DNAStringSet(Views(chr.seq, start=start, end=end(gr.select)))
        
      } else{
        
        end <- end(gr.select) + upflank
        
        end[end>length(chr.seq)] <- length(chr.seq)
        seq <- DNAStringSet(Views(chr.seq, start=start(gr.select), end=end))
        
        
      }
      
    } else {
      seq <- DNAStringSet(Views(chr.seq, start=start(gr.select), end=end(gr.select)))  
    }
    
    if(strand=="-"){
      seq <- reverseComplement(DNAStringSet(seq))  
    }
    
    gr[seqnames(gr)==chr]$seq <- seq
    
  }
  
  return (gr);
}

clean_bed_convert <- function(annotation = UTR5, type = "UTR5", cols, biotypes = types) {
  annotation <- annotation[complete.cases(annotation[, 2:3]), ]
  colnames(annotation) <- cols
  annotation$type = type
  annotation$strand <- as.character(annotation$strand)
  annotation[strand == "-1", strand := "-"]
  annotation[strand == "1", strand := "+"]
  annotation$transcript.id = paste0(annotation$gene.id, "@", annotation$gene.name, "@", annotation$transcript)
  
  setnames(biotypes, c(3, 4), c("transcript", "transcript.type"))
  annotation <- merge(annotation, biotypes[, c("transcript", "transcript.type")], by = "transcript", all.x = TRUE)
  annotation$biotype = paste0(annotation$gene.type, "|", annotation$transcript.type)
  return(annotation[, c("chromosome", "start", "end", "exon.rank", "strand", "transcript.id", "exon.id", "biotype", "type")])
}

# Function to read transcript names from a file
readTranscriptFile <- function(file_path) {
  return(readLines(file_path))
}

# Function to retrieve information for specified transcripts
getTranscriptInfo <- function(version=version, input=input_dir, file=transcrit_file) {
  # download data from ensembl
  ensembl = useEnsembl(biomart = "ensembl", dataset = "hsapiens_gene_ensembl", version = version)
  target_transcripts <- c(readTranscriptFile(transcript_file))
  message('Transcripts are:')
  message(length(unique(target_transcripts)))
  types <- getBM(attributes = c('ensembl_gene_id', 'gene_biotype', 'ensembl_transcript_id', 'transcript_biotype'),
                 filters = 'ensembl_transcript_id',
                 values = unique(target_transcripts),
                 mart = ensembl)
  
  UTR3 <- getBM(attributes = c('chromosome_name', '3_utr_start', '3_utr_end', 'ensembl_exon_id', 'rank', 'strand', 'ensembl_gene_id', 'external_gene_name', 'ensembl_transcript_id', 'gene_biotype'),
                filters = 'ensembl_transcript_id',
                values = unique(target_transcripts), mart = ensembl)
  
  UTR5 <- getBM(attributes = c('chromosome_name', '5_utr_start', '5_utr_end', 'ensembl_exon_id', 'rank', 'strand', 'ensembl_gene_id', 'external_gene_name', 'ensembl_transcript_id', 'gene_biotype'),
                filters = 'ensembl_transcript_id',
                values = unique(target_transcripts), mart = ensembl)
  
  CDS <- getBM(attributes = c('chromosome_name', 'genomic_coding_start', 'genomic_coding_end', 'ensembl_exon_id', 'rank', 'strand', 'ensembl_gene_id', 'external_gene_name', 'ensembl_transcript_id', 'gene_biotype'),
               filters = 'ensembl_transcript_id',
               values = unique(target_transcripts), mart = ensembl)
  
  # fix exon file
  cols <- c("chromosome", "start", "end", "exon.id", "exon.rank", "strand", "gene.id", "gene.name", "transcript", "gene.type")
  
  ensembl.UTR5 <- clean_bed_convert(as.data.table(UTR5), "UTR5", cols, types)
  ensembl.UTR3 <- clean_bed_convert(as.data.table(UTR3), "UTR3", cols, types)
  ensembl.CDS <- clean_bed_convert(as.data.table(CDS), "CDS", cols, types)
  
  protein.coding <- as.data.table(rbind(ensembl.CDS, ensembl.UTR3, ensembl.UTR5))
  protein.coding <- protein.coding[,c('chromosome', 'start', 'end', 'strand', 'transcript.id', 'type')]
  #protein.coding$strand <- ifelse(protein.coding$strand == "+", 1, -1)
  protein.coding$chromosome <- paste0("chr",protein.coding$chromosome)
  protein.coding[chromosome == "chrMT", chromosome := "chrM"]
  
  gets_spliced_seq <- function(exons.table = protein.coding, output.file = fi2) {
    exons.table <- protein.coding
    exons.plus <- exons.table[strand == "+"]
    exons.minus <- exons.table[strand == "-"]
    exons.plus.gr <- makeGRangesFromDataFrame(as.data.frame(exons.plus), seqnames.field = "chromosome", start.field = "start",
                                              end.field = "end", strand.field = "strand", keep.extra.columns = TRUE)
    exons.minus.gr <- makeGRangesFromDataFrame(as.data.frame(exons.minus), seqnames.field = "chromosome", start.field = "start",
                                               end.field = "end", strand.field = "strand", keep.extra.columns = TRUE)
    gen <- "BSgenome.Hsapiens.UCSC.hg38::Hsapiens"
    exons.plus.gr <- getSequence(exons.plus.gr, genome = BSgenome.Hsapiens.UCSC.hg38::Hsapiens, ucscToEnsembl = 0, upflank = 0, strand = "+")
    exons.minus.gr <- getSequence(exons.minus.gr, genome = BSgenome.Hsapiens.UCSC.hg38::Hsapiens, ucscToEnsembl = 0, upflank = 0, strand = "-")
    
    exons.plus.dt <- setDT(as.data.frame(exons.plus.gr))
    exons.minus.dt <- setDT(as.data.frame(exons.minus.gr))
    
    exons.grouped.plus <- exons.plus.dt %>% group_by(transcript.id, seqnames, strand) %>%
      arrange(start) %>%
      summarise(transcript.seq = paste(seq, collapse = "")) %>%
      ungroup() %>% as.data.table()
    
    exons.grouped.minus <- exons.minus.dt %>% group_by(transcript.id, seqnames, strand) %>%
      arrange(desc(start)) %>%
      summarise(transcript.seq = paste(seq, collapse = "")) %>%
      ungroup() %>% as.data.table()
    
    transcripts <- rbind(exons.grouped.minus, exons.grouped.plus)
    transcripts$header = paste0(">", transcripts$seqnames, ":", transcripts$transcript.id, "|", transcripts$strand)
    write.table(transcripts[, c("header", "transcript.seq")], file = output.file, sep = "\n", quote = FALSE, col.names = FALSE, row.names = FALSE)
    return(transcripts)
  }
  
  fi2 <- paste0(input_dir, "/ensembl", version, ".protein.coding.CDS.UTRs.fa")
  transcripts.seq <- gets_spliced_seq(protein.coding, output.file = fi2)
  
  protein.coding$score <- 1
  protein.coding <- protein.coding[, c('chromosome', 'start', 'end', 'transcript.id', 'score', 'strand', 'type')]
  # create fasta for transcripts
  write.table(protein.coding, file = paste0(input_dir, "/ensembl", version, ".protein.coding.CDS.UTRs.tab"),
              quote = FALSE, col.names = F, row.names = FALSE, sep = "\t")
}

############################################
# Set variables
############################################

# the version of ensembl can be set here
version <- '100'

# transcripts list can be at the working directory
input_dir <- getwd()

# setting the name of the file with transcript names
transcript_file <- paste0(input_dir, '/transcript_id_list.txt')

# calling main function
getTranscriptInfo(version, input_dir, transcript_file)


