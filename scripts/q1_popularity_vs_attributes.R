# Q1: What is the relationship between popularity and musical attributes?
# Output: q1_dataset.csv (one row per track) and q1_correlations.csv
source("scripts/helpers.R")

tracks <- load_tracks() %>%
  distinct(track_id, .keep_all = TRUE)  # each track once, even if listed under several genres

q1 <- tracks %>% select(popularity, all_of(ATTRIBUTES))
stopifnot("Unexpected missing values" = !anyNA(q1))

# Pearson correlation of each attribute with popularity
correlations <- tibble(
  attribute = ATTRIBUTES,
  correlation = sapply(ATTRIBUTES, function(a) cor(q1$popularity, q1[[a]]))
) %>% arrange(correlation)

message("  correlation with popularity (", nrow(q1), " unique tracks):")
message(paste(sprintf("    %-17s %6.3f", correlations$attribute, correlations$correlation), collapse = "\n"))

write_processed(q1, "q1_dataset.csv")
write_processed(correlations, "q1_correlations.csv")
