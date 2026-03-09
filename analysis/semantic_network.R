# Semantic Network Analysis of Spiritual Vocabulary
# Constructs and visualizes a semantic similarity network of spiritual terms.

library(tidyverse)
library(readr)
library(igraph)
library(ggraph)

# ── Load data ──────────────────────────────────────────────────────────────────

extended_words <- read_csv("data/extended_spiritual_words.csv", show_col_types = FALSE)

# ── Build co-category similarity matrix ───────────────────────────────────────
# Two words are connected if they share the same category or tradition.
# Edge weight is the product of their frequencies (proxy for semantic salience).

words <- extended_words %>%
  select(word, category, tradition, frequency) %>%
  distinct(word, .keep_all = TRUE)

n <- nrow(words)
adj_matrix <- matrix(0, nrow = n, ncol = n, dimnames = list(words$word, words$word))

for (i in seq_len(n)) {
  for (j in seq_len(n)) {
    if (i != j) {
      same_category  <- words$category[i]  == words$category[j]
      same_tradition <- words$tradition[i] == words$tradition[j]
      if (same_category || same_tradition) {
        adj_matrix[i, j] <- words$frequency[i] * words$frequency[j]
      }
    }
  }
}

# ── Create igraph object ───────────────────────────────────────────────────────

g <- graph_from_adjacency_matrix(
  adj_matrix,
  mode    = "undirected",
  weighted = TRUE,
  diag    = FALSE
)

# Attach node attributes
V(g)$category  <- words$category[match(V(g)$name, words$word)]
V(g)$tradition <- words$tradition[match(V(g)$name, words$word)]
V(g)$frequency <- words$frequency[match(V(g)$name, words$word)]
V(g)$degree    <- degree(g)

cat(sprintf("Network: %d nodes, %d edges\n", vcount(g), ecount(g)))

# ── Detect communities ─────────────────────────────────────────────────────────

set.seed(42)
communities <- cluster_louvain(g)
V(g)$community <- membership(communities)
cat(sprintf("Communities detected: %d\n", length(communities)))

# ── Visualize semantic network ─────────────────────────────────────────────────

set.seed(42)
p_net <- ggraph(g, layout = "fr") +
  geom_edge_link(aes(width = weight, alpha = weight), colour = "grey70", show.legend = FALSE) +
  geom_node_point(aes(size = frequency, colour = category)) +
  geom_node_text(aes(label = name), repel = TRUE, size = 3, max.overlaps = 20) +
  scale_edge_width(range = c(0.3, 2)) +
  scale_edge_alpha(range = c(0.2, 0.6)) +
  scale_size_continuous(range = c(3, 10)) +
  labs(
    title  = "Semantic Network of Spiritual Vocabulary",
    colour = "Category",
    size   = "Frequency"
  ) +
  theme_graph(base_family = "sans")

ggsave("figures/semantic_network.png", p_net, width = 12, height = 10, dpi = 150)
cat("Saved: figures/semantic_network.png\n")

# ── Save graph object for downstream analyses ──────────────────────────────────

saveRDS(g, "data/semantic_network.rds")
cat("Saved: data/semantic_network.rds\n")
