# Q4: Is there a threshold in musical attributes that separates high-popularity songs?
# Output: q4_dataset.csv (one row per track, popularity labelled High or Low)
source("scripts/helpers.R")

threshold <- 70  # popularity above this counts as "High"

q4 <- load_tracks() %>%
  distinct(track_id, .keep_all = TRUE) %>%  # each track once
  select(popularity, all_of(ATTRIBUTES)) %>%
  mutate(popularity = ifelse(popularity > threshold, "High", "Low"))

message(sprintf("  %d of %d unique tracks have popularity above %d",
                sum(q4$popularity == "High"), nrow(q4), threshold))
message("  median of each attribute:")
print(as.data.frame(q4 %>% group_by(popularity) %>%
  summarise(across(all_of(ATTRIBUTES), ~ round(median(.x), 3)))))

write_processed(q4, "q4_dataset.csv")
