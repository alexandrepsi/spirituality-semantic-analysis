# Clustering Analysis of Spiritual Vocabulary
# Groups spiritual terms into clusters based on semantic category and frequency profiles.

library(tidyverse)
library(readr)
library(cluster)
library(factoextra)

# ── Load data ──────────────────────────────────────────────────────────────────

extended_words <- read_csv("data/extended_spiritual_words.csv", show_col_types = FALSE)

# ── Prepare numeric feature matrix ────────────────────────────────────────────

# Encode categorical variables and combine with frequency for clustering
words_clean <- extended_words %>%
  distinct(word, .keep_all = TRUE) %>%
  mutate(
    category_num  = as.numeric(factor(category)),
    tradition_num = as.numeric(factor(tradition)),
    valence_num   = ifelse(valence == "positive", 1, -1)
  )

features <- words_clean %>%
  select(frequency, category_num, tradition_num, valence_num) %>%
  scale()

rownames(features) <- words_clean$word

# ── Determine optimal number of clusters (Elbow method) ───────────────────────

set.seed(42)
p_elbow <- fviz_nbclust(features, kmeans, method = "wss") +
  labs(title = "Elbow Method for Optimal k")

ggsave("figures/elbow_plot.png", p_elbow, width = 7, height = 5, dpi = 150)
cat("Saved: figures/elbow_plot.png\n")

# ── K-means clustering ─────────────────────────────────────────────────────────

set.seed(42)
k_opt <- 5  # Chosen based on domain knowledge and elbow plot
km_result <- kmeans(features, centers = k_opt, nstart = 25)

words_clean <- words_clean %>%
  mutate(cluster = factor(km_result$cluster))

cat("\nCluster sizes:\n")
print(table(words_clean$cluster))

# ── Cluster visualization ──────────────────────────────────────────────────────

p_cluster <- fviz_cluster(
  km_result,
  data        = features,
  geom        = "point",
  ellipse     = TRUE,
  ellipse.type = "convex",
  palette     = "jco",
  ggtheme     = theme_minimal()
) +
  labs(title = "K-Means Clustering of Spiritual Terms (k = 5)")

ggsave("figures/cluster_kmeans.png", p_cluster, width = 9, height = 7, dpi = 150)
cat("Saved: figures/cluster_kmeans.png\n")

# ── Cluster frequency bar chart ────────────────────────────────────────────────

p_freq <- words_clean %>%
  count(cluster, category) %>%
  ggplot(aes(x = cluster, y = n, fill = category)) +
  geom_col(position = "stack") +
  labs(
    title = "Composition of Clusters by Category",
    x     = "Cluster",
    y     = "Number of Words",
    fill  = "Category"
  ) +
  theme_minimal(base_size = 13)

ggsave("figures/cluster_freq.png", p_freq, width = 8, height = 5, dpi = 150)
cat("Saved: figures/cluster_freq.png\n")

# ── Hierarchical clustering ────────────────────────────────────────────────────

dist_matrix <- dist(features, method = "euclidean")
hc_result   <- hclust(dist_matrix, method = "ward.D2")

png("figures/dendrogram.png", width = 1400, height = 700, res = 120)
plot(
  hc_result,
  main  = "Hierarchical Clustering of Spiritual Terms",
  xlab  = "",
  ylab  = "Height",
  cex   = 0.75
)
rect.hclust(hc_result, k = k_opt, border = "tomato")
dev.off()
cat("Saved: figures/dendrogram.png\n")

# ── Print cluster profiles ─────────────────────────────────────────────────────

cat("\nCluster profiles (mean frequency by cluster and category):\n")
words_clean %>%
  group_by(cluster, category) %>%
  summarise(mean_freq = mean(frequency), n = n(), .groups = "drop") %>%
  arrange(cluster, desc(mean_freq)) %>%
  print(n = 40)
