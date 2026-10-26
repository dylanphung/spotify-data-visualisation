# Draws the seven charts from the processed datasets and saves them to charts/.
# Run from the repository root after the q1-q7 scripts (run_all.R does this).
source("scripts/helpers.R")
suppressPackageStartupMessages(library(ggplot2))

CHART_DIR <- "charts"
dir.create(CHART_DIR, showWarnings = FALSE)

GENRE_COLOURS <- c(classical = "#4E79A7", "hip-hop" = "#F28E2B", metal = "#59A14F",
                   rock = "#E15759", pop = "#B07AA1", jazz = "#76B7B2", "r-n-b" = "#EDC948",
                   country = "#9C755F", electronic = "#BAB0AC")

theme_set(theme_minimal(base_size = 12) +
            theme(plot.title = element_text(face = "bold"),
                  plot.title.position = "plot",
                  panel.grid.minor = element_blank(),
                  strip.text = element_text(face = "bold"),
                  panel.spacing = unit(1.4, "lines")))

save_chart <- function(plot, file, width = 10, height = 6) {
  path <- file.path(CHART_DIR, file)
  ggsave(path, plot, width = width, height = height, dpi = 150, bg = "white")
  message("  saved ", path)
}

read_processed <- function(file) read.csv(file.path(PROCESSED_DIR, file))

# ---- Q1: popularity vs each attribute (binned averages + linear trend) ----
q1 <- read_processed("q1_dataset.csv")
q1_cor <- read_processed("q1_correlations.csv")
q1_labels <- setNames(sprintf("%s (r = %.2f)", q1_cor$attribute, q1_cor$correlation), q1_cor$attribute)

q1_binned <- q1 %>%
  pivot_longer(all_of(ATTRIBUTES), names_to = "attribute", values_to = "value") %>%
  group_by(attribute) %>%
  mutate(bin = ntile(value, 20)) %>%
  group_by(attribute, bin) %>%
  summarise(value = mean(value), popularity = mean(popularity), .groups = "drop") %>%
  mutate(attribute = factor(q1_labels[attribute], levels = q1_labels[ATTRIBUTES]))

p1 <- ggplot(q1_binned, aes(value, popularity)) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, colour = "grey60", linewidth = 0.7) +
  geom_point(colour = "#4E79A7", size = 1.8) +
  facet_wrap(~attribute, scales = "free_x", ncol = 4) +
  labs(title = "1. How does popularity relate to musical attributes?",
       subtitle = "Average popularity of tracks grouped into 20 equal-sized bins per attribute, with a linear trend",
       x = NULL, y = "Average popularity")
save_chart(p1, "q1.png")

# ---- Q2: genre profiles (radar chart) ----
q2 <- read_processed("q2_dataset.csv") %>%
  pivot_longer(all_of(ATTRIBUTES), names_to = "attribute", values_to = "value")
angles <- setNames(pi / 2 - 2 * pi * (seq_along(ATTRIBUTES) - 1) / length(ATTRIBUTES), ATTRIBUTES)

radar_points <- q2 %>%
  mutate(angle = angles[attribute], x = value * cos(angle), y = value * sin(angle),
         order = match(attribute, ATTRIBUTES)) %>%
  arrange(track_genre, order)
rings <- expand.grid(level = c(0.25, 0.5, 0.75, 1), attribute = ATTRIBUTES) %>%
  mutate(angle = angles[attribute], x = level * cos(angle), y = level * sin(angle),
         order = match(attribute, ATTRIBUTES)) %>%
  arrange(level, order)
spokes <- data.frame(attribute = ATTRIBUTES, angle = angles)

p2 <- ggplot() +
  geom_polygon(data = rings, aes(x, y, group = level), fill = NA, colour = "grey85") +
  geom_segment(data = spokes, aes(x = 0, y = 0, xend = cos(angle), yend = sin(angle)), colour = "grey85") +
  geom_text(data = spokes, aes(x = 1.18 * cos(angle), y = 1.12 * sin(angle), label = attribute), size = 3.6) +
  geom_polygon(data = radar_points, aes(x, y, group = track_genre, fill = track_genre, colour = track_genre),
               alpha = 0.12, linewidth = 0.9) +
  geom_point(data = radar_points, aes(x, y, colour = track_genre), size = 1.6) +
  scale_fill_manual(values = GENRE_COLOURS, name = "Genre") +
  scale_colour_manual(values = GENRE_COLOURS, name = "Genre") +
  coord_equal(xlim = c(-1.4, 1.4), ylim = c(-1.2, 1.2)) +
  labs(title = "2. Can genres be identified by their musical attributes?",
       subtitle = "Average of each attribute, scaled 0-1 across all 114,000 tracks (rings at 0.25, 0.5, 0.75, 1)") +
  theme_void(base_size = 12) +
  theme(plot.title = element_text(face = "bold"), plot.title.position = "plot",
        plot.margin = margin(10, 10, 10, 10))
save_chart(p2, "q2.png", width = 9, height = 7.5)

# ---- Q3: average energy over time by genre ----
q3 <- read_processed("q3_dataset.csv")
p3 <- ggplot(q3, aes(year, avg_energy, colour = genre)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.4) +
  scale_colour_manual(values = GENRE_COLOURS, guide = "none") +
  scale_x_continuous(breaks = seq(1985, 2015, 10)) +
  facet_wrap(~genre, ncol = 3) +
  labs(title = "3. How has the average energy of songs changed over time?",
       subtitle = "Average energy per release year (years with fewer than 20 songs are omitted)",
       x = "Release year", y = "Average energy")
save_chart(p3, "q3.png", height = 4.5)

# ---- Q4: attribute distributions for high vs low popularity ----
q4 <- read_processed("q4_dataset.csv") %>%
  pivot_longer(all_of(ATTRIBUTES), names_to = "attribute", values_to = "value") %>%
  mutate(attribute = factor(attribute, levels = ATTRIBUTES),
         popularity = factor(popularity, levels = c("High", "Low")))
p4 <- ggplot(q4, aes(popularity, value, fill = popularity)) +
  geom_boxplot(outlier.size = 0.3, outlier.alpha = 0.05, width = 0.6) +
  scale_fill_manual(values = c(High = "#F28E2B", Low = "#BAB0AC"), guide = "none") +
  facet_wrap(~attribute, scales = "free_y", ncol = 4) +
  labs(title = "4. Is there a threshold that separates popular songs from the rest?",
       subtitle = "High = popularity above 70 (3% of tracks), Low = everything else",
       x = NULL, y = NULL)
save_chart(p4, "q4.png")

# ---- Q5: genre x attribute heatmap ----
q5 <- read_processed("q5_dataset.csv") %>%
  mutate(attribute = factor(attribute, levels = ATTRIBUTES),
         track_genre = factor(track_genre, levels = rev(sort(unique(track_genre)))))
p5 <- ggplot(q5, aes(attribute, track_genre, fill = average_value)) +
  geom_tile(colour = "white", linewidth = 0.8) +
  geom_text(aes(label = sprintf("%.2f", average_value),
                colour = average_value > 0.6), size = 3.4, show.legend = FALSE) +
  scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "grey20")) +
  scale_fill_gradient(low = "#F1F4F8", high = "#2E5A88", limits = c(0, 1), name = "Scaled\naverage") +
  labs(title = "5. Which attributes dominate each genre?",
       subtitle = "1 = highest-scoring genre out of all 114 genres in the dataset, 0 = lowest",
       x = NULL, y = NULL) +
  theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 30, hjust = 1))
save_chart(p5, "q5.png", height = 5.5)

# ---- Q6: energy, tempo and loudness over time by genre ----
q6 <- read_processed("q6_dataset.csv")
q6_cor <- read_processed("q6_correlations.csv")
q6_labels <- setNames(sprintf("%s\nenergy vs tempo r = %.2f, vs loudness r = %.2f",
                              q6_cor$track_genre, q6_cor$energy_vs_tempo, q6_cor$energy_vs_loudness),
                      q6_cor$track_genre)
q6 <- q6 %>% mutate(genre_label = q6_labels[track_genre],
                    attribute = factor(attribute, levels = c("energy", "tempo", "loudness")))
p6 <- ggplot(q6, aes(year, average_value, colour = attribute)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 0.9) +
  scale_colour_manual(values = c(energy = "#E15759", tempo = "#4E79A7", loudness = "#59A14F"), name = NULL) +
  scale_x_continuous(breaks = seq(1985, 2015, 10)) +
  facet_wrap(~genre_label, ncol = 2) +
  labs(title = "6. Do energy trends move with other attributes over time?",
       subtitle = "Yearly averages, each attribute scaled 0-1 within each genre (years with fewer than 20 songs omitted)",
       x = "Release year", y = "Scaled yearly average (0 = genre's lowest year, 1 = highest)") +
  theme(legend.position = "top")
save_chart(p6, "q6.png", height = 7)

# ---- Q7: popularity of explicit vs clean tracks ----
q7 <- read_processed("q7_dataset.csv") %>%
  mutate(explicit = factor(ifelse(explicit == "True", "Explicit", "Clean"), levels = c("Clean", "Explicit")))
p7 <- ggplot(q7, aes(track_genre, average_popularity, fill = explicit)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  geom_text(aes(label = paste0("n = ", n)), position = position_dodge(width = 0.8),
            vjust = -0.5, size = 3.2, colour = "grey30") +
  scale_fill_manual(values = c(Clean = "#BAB0AC", Explicit = "#E15759"), name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(title = "7. How does explicit content affect popularity across genres?",
       subtitle = "Average popularity, with the number of tracks behind each bar",
       x = NULL, y = "Average popularity") +
  theme(legend.position = "top")
save_chart(p7, "q7.png", height = 5.5)
