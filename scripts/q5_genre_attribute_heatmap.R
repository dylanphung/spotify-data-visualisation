# Q5: Are specific musical attributes dominant within certain genres? (heatmap)
# Output: q5_dataset.csv (long format: genre, attribute, scaled average)
source("scripts/helpers.R")

selected_genres <- c("pop", "rock", "hip-hop", "classical", "jazz", "metal", "country", "electronic")

# Average each attribute per genre across ALL genres in the dataset, then scale each
# attribute 0-1 across those genre averages: 1 = the highest-scoring genre of all
# genres in the dataset, 0 = the lowest. Then keep the eight genres shown in the chart.
q5 <- load_tracks() %>%
  group_by(track_genre) %>%
  summarise(across(all_of(ATTRIBUTES), mean), .groups = "drop") %>%
  mutate(across(all_of(ATTRIBUTES), minmax)) %>%
  pivot_longer(all_of(ATTRIBUTES), names_to = "attribute", values_to = "average_value") %>%
  filter(track_genre %in% selected_genres) %>%
  arrange(factor(attribute, levels = ATTRIBUTES), track_genre)

write_processed(q5, "q5_dataset.csv")
