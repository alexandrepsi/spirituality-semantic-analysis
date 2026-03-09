# Network Centrality Analysis of the Spiritual Semantic Network
# Computes and visualises centrality measures for each node in the network.

library(tidyverse)
library(igraph)
library(ggraph)

# ── Load pre-built network ─────────────────────────────────────────────────────

if (!file.exists("data/semantic_network.rds")) {
  stop("Run analysis/semantic_network.R first to generate data/semantic_network.rds")
}

g <- readRDS("data/semantic_network.rds")

# ── Compute centrality measures ────────────────────────────────────────────────

centrality_df <- tibble(
  word        = V(g)$name,
  category    = V(g)$category,
  tradition   = V(g)$tradition,
  frequency   = V(g)$frequency,
  degree      = degree(g, normalized = TRUE),
  betweenness = betweenness(g, normalized = TRUE),
  closeness   = closeness(g, normalized = TRUE),
  eigenvector = eigen_centrality(g)$vector
)

cat("Top 10 words by degree centrality:\n")
centrality_df %>% arrange(desc(degree)) %>% slice_head(n = 10) %>% print()

cat("\nTop 10 words by betweenness centrality:\n")
centrality_df %>% arrange(desc(betweenness)) %>% slice_head(n = 10) %>% print()

cat("\nTop 10 words by eigenvector centrality:\n")
centrality_df %>% arrange(desc(eigenvector)) %>% slice_head(n = 10) %>% print()

# ── Centrality heatmap ─────────────────────────────────────────────────────────

centrality_long <- centrality_df %>%
  select(word, degree, betweenness, closeness, eigenvector) %>%
  pivot_longer(-word, names_to = "measure", values_to = "value")

top_words <- centrality_df %>%
  arrange(desc(degree)) %>%
  slice_head(n = 20) %>%
  pull(word)

p_heat <- centrality_long %>%
  filter(word %in% top_words) %>%
  ggplot(aes(x = measure, y = reorder(word, value), fill = value)) +
  geom_tile(colour = "white") +
  scale_fill_gradient(low = "white", high = "steelblue") +
  labs(
    title = "Centrality Measures for Top 20 Spiritual Terms",
    x     = "Centrality Measure",
    y     = "Word",
    fill  = "Value"
  ) +
  theme_minimal(base_size = 12)

ggsave("figures/centrality_heatmap.png", p_heat, width = 8, height = 7, dpi = 150)
cat("\nSaved: figures/centrality_heatmap.png\n")

# ── Network coloured by degree centrality ─────────────────────────────────────

V(g)$degree_norm <- centrality_df$degree[match(V(g)$name, centrality_df$word)]

set.seed(42)
p_net_central <- ggraph(g, layout = "fr") +
  geom_edge_link(alpha = 0.2, colour = "grey70") +
  geom_node_point(aes(size = degree_norm, colour = degree_norm)) +
  geom_node_text(aes(label = name, size = degree_norm), repel = TRUE, max.overlaps = 15) +
  scale_colour_gradient(low = "skyblue", high = "darkred") +
  scale_size_continuous(range = c(2, 10)) +
  labs(
    title  = "Semantic Network Coloured by Degree Centrality",
    colour = "Degree",
    size   = "Degree"
  ) +
  theme_graph(base_family = "sans")

ggsave("figures/network_centrality.png", p_net_central, width = 12, height = 10, dpi = 150)
cat("Saved: figures/network_centrality.png\n")

# ── Save centrality table ──────────────────────────────────────────────────────

readr::write_csv(centrality_df, "data/centrality_measures.csv")
cat("Saved: data/centrality_measures.csv\n")
