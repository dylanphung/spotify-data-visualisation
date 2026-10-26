# Q2: Can genres be identified based on their musical attributes? (radar chart)
# Output: q2_dataset.csv (average 0-1 attribute profile per genre)
source("scripts/helpers.R")

chosen_genres <- c("hip-hop", "classical", "rock", "metal")

# Scale each attribute to 0-1 across ALL tracks first, so every genre is measured on
# the same scale. (Scaling within each genre would make each genre relative only to
# itself, hiding the differences between genres the chart is meant to show.)
q2 <- load_tracks() %>%
  mutate(across(all_of(ATTRIBUTES), minmax)) %>%
  filter(track_genre %in% chosen_genres) %>%
  group_by(track_genre) %>%
  summarise(across(all_of(ATTRIBUTES), mean), .groups = "drop")

message("  genre profiles (0 = lowest in the whole dataset, 1 = highest):")
print(as.data.frame(q2 %>% mutate(across(all_of(ATTRIBUTES), ~ round(.x, 2)))))

write_processed(q2, "q2_dataset.csv")
