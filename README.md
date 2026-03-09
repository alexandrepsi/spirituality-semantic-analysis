# Global Semantic Structure of Spirituality

A research project analyzing the semantic relationships and global structure of spiritual concepts using computational linguistics and network analysis in R.

## Overview

This project investigates the semantic network of spirituality-related words using corpus linguistics, word embeddings, network analysis, and clustering techniques. The goal is to map the conceptual landscape of spirituality across different traditions and contexts.

## Project Structure

```
spirituality-semantic-analysis/
├── data/
│   ├── spiritual_words.csv          # Core spiritual vocabulary dataset
│   └── extended_spiritual_words.csv # Extended dataset with additional terms
├── analysis/
│   ├── exploratory_analysis.R       # Exploratory data analysis
│   ├── semantic_network.R           # Semantic network construction and visualization
│   ├── clustering_analysis.R        # Clustering of spiritual concepts
│   ├── word_embedding_analysis.R    # Word embedding analysis
│   └── network_centrality.R         # Network centrality metrics
├── figures/                         # Generated plots and visualizations
├── notebooks/
│   └── exploratory_notebook.Rmd     # R Markdown notebook for exploration
├── docs/
│   └── theoretical_framework.md     # Theoretical background and framework
├── CITATION.cff                     # Citation information
└── README.md
```

## Requirements

- R (≥ 4.0.0)
- RStudio (recommended)

### R Packages

```r
install.packages(c(
  "tidyverse", "readr", "ggplot2", "igraph", "ggraph",
  "quanteda", "tidytext", "text2vec", "cluster", "factoextra"
))
```

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/alexandrepsi/spirituality-semantic-analysis.git
   cd spirituality-semantic-analysis
   ```

2. Open RStudio and set the working directory:
   ```r
   setwd("/path/to/spirituality-semantic-analysis")
   ```

3. Run the analyses in order:
   ```r
   source("analysis/exploratory_analysis.R")
   source("analysis/semantic_network.R")
   source("analysis/clustering_analysis.R")
   source("analysis/word_embedding_analysis.R")
   source("analysis/network_centrality.R")
   ```

4. To generate the full report, open `notebooks/exploratory_notebook.Rmd` in RStudio and click **Knit**.

## Outputs

Generated figures are saved to the `figures/` directory:
- `semantic_network.png` – Semantic network visualization
- `cluster_freq.png` – Cluster frequency plot
- `word_embeddings.png` – Word embedding visualization

## Theoretical Framework

See [`docs/theoretical_framework.md`](docs/theoretical_framework.md) for the theoretical background and methodology.

## Citation

If you use this work, please cite it using the information in [`CITATION.cff`](CITATION.cff).

## License

This project is released under the MIT License.
