# Shared settings and functions used by every preprocessing script.
# Run all scripts from the repository root (e.g. `Rscript run_all.R`).

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
})

RAW_DIR <- "data/raw"
INTERIM_DIR <- "data/interim"
PROCESSED_DIR <- "data/processed"

# Audio features analysed throughout (loudness is in dB, tempo in BPM, the rest are 0-1)
ATTRIBUTES <- c("danceability", "energy", "loudness", "speechiness",
                "acousticness", "instrumentalness", "valence", "tempo")

# Year-level averages built from fewer tracks than this are too noisy to plot
MIN_TRACKS_PER_YEAR <- 20

read_raw <- function(file) {
  path <- file.path(RAW_DIR, file)
  if (!file.exists(path)) {
    stop(sprintf("Missing %s. See data/raw/README.md for where to download it.", path), call. = FALSE)
  }
  read.csv(path)
}

# The main 114k-track dataset. Note: the same track can appear once per genre it
# belongs to, so scripts that ignore genre should de-duplicate by track_id.
load_tracks <- function() {
  tracks <- read_raw("dataset.csv")
  required <- c("track_id", "track_name", "popularity", "explicit", "track_genre", ATTRIBUTES)
  missing <- setdiff(required, names(tracks))
  if (length(missing) > 0) {
    stop("dataset.csv is missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  tracks
}

# Scale to 0-1 (constant columns become 0 rather than NaN)
minmax <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (rng[2] == rng[1]) return(rep(0, length(x)))
  (x - rng[1]) / (rng[2] - rng[1])
}

write_processed <- function(df, file) {
  dir.create(PROCESSED_DIR, showWarnings = FALSE, recursive = TRUE)
  path <- file.path(PROCESSED_DIR, file)
  write.csv(df, path, row.names = FALSE)
  message(sprintf("  wrote %s (%d rows)", path, nrow(df)))
}
