# Q6: Does the trend in energy correlate with other attributes over time, by genre?
# Output: q6_dataset.csv (long format: year, genre, attribute, scaled average)
source("scripts/helpers.R")

joined <- read.csv(file.path(INTERIM_DIR, "dataset_with_release.csv"))
selected_genres <- c("hip-hop", "r-n-b", "pop", "classical")
trend_attributes <- c("energy", "tempo", "loudness")

yearly <- joined %>%
  filter(track_genre %in% selected_genres, year > 1980) %>%
  group_by(year, track_genre) %>%
  summarise(across(all_of(trend_attributes), mean), n = n(), .groups = "drop") %>%
  filter(n >= MIN_TRACKS_PER_YEAR)

# How closely each attribute's yearly average tracks energy, per genre
correlations <- yearly %>%
  group_by(track_genre) %>%
  summarise(years = n(),
            energy_vs_tempo = cor(energy, tempo),
            energy_vs_loudness = cor(energy, loudness),
            .groups = "drop")
message("  correlation of yearly averages with energy:")
print(as.data.frame(correlations %>% mutate(across(where(is.numeric) & !years, ~ round(.x, 2)))))

# Scale each attribute 0-1 within each genre, so the three lines share one axis and each
# genre's own ups and downs are visible (this chart compares lines within a genre, not
# genres with each other; scaling doesn't change the correlations)
q6 <- yearly %>%
  group_by(track_genre) %>%
  mutate(across(all_of(trend_attributes), minmax)) %>%
  ungroup() %>%
  select(-n) %>%
  pivot_longer(all_of(trend_attributes), names_to = "attribute", values_to = "average_value") %>%
  arrange(factor(attribute, levels = trend_attributes), year, track_genre)

write_processed(q6, "q6_dataset.csv")
write_processed(correlations, "q6_correlations.csv")
