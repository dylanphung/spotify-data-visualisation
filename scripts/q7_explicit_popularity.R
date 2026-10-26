# Q7: How does explicit content influence the popularity of songs across genres?
# Output: q7_dataset.csv (average popularity by genre and explicit flag, with track counts)
source("scripts/helpers.R")

selected_genres <- c("pop", "hip-hop", "rock", "metal", "country")

q7 <- load_tracks() %>%
  filter(track_genre %in% selected_genres) %>%
  mutate(explicit = ifelse(as.logical(explicit), "True", "False")) %>%
  group_by(track_genre, explicit) %>%
  summarise(average_popularity = mean(popularity), n = n(), .groups = "drop")

message("  tracks per group (small groups make the averages unreliable):")
print(as.data.frame(q7 %>% mutate(average_popularity = round(average_popularity, 1))))

write_processed(q7, "q7_dataset.csv")
