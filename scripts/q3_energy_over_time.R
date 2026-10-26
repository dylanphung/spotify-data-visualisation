# Q3: How has the average energy of songs changed over time across genres?
# Output: q3_dataset.csv (average energy per genre per year, with track counts)
source("scripts/helpers.R")

joined <- read.csv(file.path(INTERIM_DIR, "dataset_with_release.csv"))
chosen_genres <- c("pop", "classical", "jazz")

q3 <- joined %>%
  filter(track_genre %in% chosen_genres, year > 1980) %>%
  group_by(genre = track_genre, year) %>%
  summarise(avg_energy = mean(energy), n = n(), .groups = "drop") %>%
  filter(n >= MIN_TRACKS_PER_YEAR)  # drop years averaged from only a handful of songs

message(sprintf("  kept years with at least %d tracks:", MIN_TRACKS_PER_YEAR))
print(as.data.frame(q3 %>% group_by(genre) %>%
  summarise(first_year = min(year), last_year = max(year), years = n(), tracks = sum(n))))

write_processed(q3, "q3_dataset.csv")
