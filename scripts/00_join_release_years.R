# Builds the dataset for the over-time questions (3 and 6).
# Output: data/interim/dataset_with_release.csv
#
# The main dataset has genres but no release years. The second dataset ("Spotify 1.2M+
# Songs") has release years and the same audio features, but no genres. Matching
# individual songs between them only works for about 9% of tracks, because Spotify gives
# every release of a song (album, single, compilation) its own ID and the two datasets
# barely overlap. So instead, each artist's genres are taken from the main dataset and
# applied to that artist's songs in the 1.2M dataset: if an artist's tracks are labelled
# pop in the main dataset, their songs count towards pop.
source("scripts/helpers.R")

tracks <- load_tracks()
releases <- read_raw("tracks_features.csv")

# Lower-case, trimmed text for matching
clean_text <- function(x) tolower(trimws(x))

# Main dataset lists artists as "Artist One;Artist Two" -> use the first (primary) artist
first_artist_semicolon <- function(x) clean_text(sub(";.*$", "", x))

# 1.2M dataset lists artists as "['Artist One', 'Artist Two']" -> use the first
first_artist_list <- function(x) {
  m <- regexpr("(?<=')[^']+(?=')|(?<=\")[^\"]+(?=\")", x, perl = TRUE)
  out <- rep(NA_character_, length(x))
  out[m > 0] <- regmatches(x, m)
  clean_text(out)
}

# Every genre each artist appears under in the main dataset
artist_genres <- tracks %>%
  transmute(artist_key = first_artist_semicolon(artists), track_genre) %>%
  filter(artist_key != "") %>%
  distinct()

# One row per song in the 1.2M dataset. A song released several times (album, single,
# compilation) is kept once, with its earliest year as the original release year.
songs <- releases %>%
  transmute(title_key = clean_text(name),
            artist_key = first_artist_list(artists),
            year = suppressWarnings(as.integer(year)),
            energy, loudness, tempo) %>%
  filter(!is.na(artist_key), !is.na(year), year > 1900) %>%
  arrange(year) %>%
  distinct(title_key, artist_key, .keep_all = TRUE)

# An artist listed under several genres contributes their songs to each of them
joined <- songs %>%
  inner_join(artist_genres, by = "artist_key", relationship = "many-to-many")

message(sprintf("  %d unique songs in the 1.2M dataset; %d of them by artists found in the main dataset",
                nrow(songs), n_distinct(joined$title_key, joined$artist_key)))
message(sprintf("  artists matched: %d of %d",
                n_distinct(joined$artist_key), n_distinct(artist_genres$artist_key)))

if (nrow(joined) == 0) {
  stop("No artists matched, so questions 3 and 6 can't be built. Check that tracks_features.csv ",
       "is the dataset listed in data/raw/README.md.", call. = FALSE)
}

dir.create(INTERIM_DIR, showWarnings = FALSE, recursive = TRUE)
write.csv(joined, file.path(INTERIM_DIR, "dataset_with_release.csv"), row.names = FALSE)
message(sprintf("  wrote %s (%d rows)", file.path(INTERIM_DIR, "dataset_with_release.csv"), nrow(joined)))
