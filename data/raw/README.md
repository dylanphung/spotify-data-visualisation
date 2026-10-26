# Raw data

The raw datasets aren't stored in this repository. Download them into this folder with these exact file names:

| File | Dataset | Used for |
|---|---|---|
| `dataset.csv` | **Spotify Tracks Dataset** by Maharshi Pandya: 114,000 tracks across 114 genres, with popularity and audio features (BSD licence). Available on [Hugging Face](https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset) and Kaggle. | All questions |
| `tracks_features.csv` | **Spotify 1.2M+ Songs** (Kaggle): about 1.2 million tracks with audio features and release years. | Questions 3 and 6 |

Then, from the repository root:

```bash
Rscript run_all.R
```
