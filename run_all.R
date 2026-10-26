# Rebuilds every dataset and chart in order. From the repository root:
#   Rscript run_all.R
#
# To redraw the charts only (from the datasets already in data/processed/):
#   Rscript scripts/plot_charts.R

scripts <- c(
  "scripts/00_join_release_years.R",
  "scripts/q1_popularity_vs_attributes.R",
  "scripts/q2_genre_profiles.R",
  "scripts/q3_energy_over_time.R",
  "scripts/q4_popularity_threshold.R",
  "scripts/q5_genre_attribute_heatmap.R",
  "scripts/q6_attribute_trends.R",
  "scripts/q7_explicit_popularity.R",
  "scripts/plot_charts.R"
)

for (s in scripts) {
  message("\n== ", s)
  source(s, local = new.env())
}
message("\nDone. Datasets are in data/processed/ and charts in charts/.")
