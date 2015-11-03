#Looking at topic models for history journals
#Following the vignette by Andrew Goldstone: http://agoldst.github.io/dfrtopics/introduction.html

options(java.parameters="-Xmx2g")   # optional, but more memory for Java helps
library("dfrtopics")
library("dplyr")
library("ggplot2")
library("lubridate")
library("stringr")

data_dir <- file.path(getwd(), "jah_data")
metadata_file<-file.path(data_dir, "citations.tsv")
meta<-read_dfr_metadata(metadata_file)
counts <- read_wordcounts(list.files(file.path(data_dir, "wordcounts"), full.names=T))

#remove any short articles
# counts <- counts %>%
#   group_by(id) %>%
#   filter(sum(weight) > 300)

#filter stopwords
stoplist_file <- file.path(path.package("dfrtopics"), "stoplist", "stoplist.txt")
stoplist<-readLines(stoplist_file)
# counts %>%
#   group_by(id) %>%
#   summarize(total=sum(weight), stopped=sum(weight[word %in% stoplist]))
counts <- counts %>% wordcounts_remove_stopwords(stoplist)

#remove infrequent words so only look at top 20,000 words
counts<-counts %>%
  wordcounts_remove_rare(20000)

#get rid of words that only occur once
counts <- counts %>%
  group_by(word) %>%
  filter(sum(weight) > 1)

#prep for MALLET so that there is only one document per row
docs <- wordcounts_texts(counts)

