# Word Embedding Analysis of Spiritual Vocabulary
# Uses text2vec to train GloVe embeddings on a synthetic spiritual corpus,
# then visualises the embedding space with PCA.
# NOTE: In a production project, replace the synthetic corpus with real texts.

library(tidyverse)
library(readr)
library(text2vec)

# ── Load data ──────────────────────────────────────────────────────────────────

extended_words <- read_csv("data/extended_spiritual_words.csv", show_col_types = FALSE)
vocab_words    <- unique(extended_words$word)

# ── Build a minimal synthetic corpus ──────────────────────────────────────────
# Each "document" is a window of semantically related words drawn from the
# same category/tradition, so that co-occurrence is meaningful.

set.seed(42)
corpus_docs <- extended_words %>%
  group_by(category) %>%
  summarise(text = paste(word, collapse = " "), .groups = "drop") %>%
  pull(text)

# Repeat documents to increase co-occurrence counts
corpus_docs <- rep(corpus_docs, times = 10)

# ── Tokenise and build vocabulary ─────────────────────────────────────────────

tokens <- space_tokenizer(corpus_docs)
it     <- itoken(tokens, progressbar = FALSE)
vocab  <- create_vocabulary(it)
vocab  <- prune_vocabulary(vocab, term_count_min = 2)

vectorizer <- vocab_vectorizer(vocab)

# ── Build term co-occurrence matrix ───────────────────────────────────────────

tcm <- create_tcm(it, vectorizer, skip_grams_window = 5L)

# ── Fit GloVe embeddings ───────────────────────────────────────────────────────

glove_model <- GlobalVectors$new(rank = 50, x_max = 10)
wv_main     <- glove_model$fit_transform(tcm, n_iter = 20, convergence_tol = 0.001, n_threads = 1)
wv_context  <- glove_model$components
word_vectors <- wv_main + t(wv_context)

cat(sprintf("Word vector matrix: %d × %d\n", nrow(word_vectors), ncol(word_vectors)))

# ── PCA for visualisation ──────────────────────────────────────────────────────

# Filter to words present in both the extended dataset and the embedding
common_words <- intersect(rownames(word_vectors), vocab_words)
wv_subset    <- word_vectors[common_words, , drop = FALSE]

pca_result <- prcomp(wv_subset, center = TRUE, scale. = TRUE)
pca_df     <- as.data.frame(pca_result$x[, 1:2]) %>%
  tibble::rownames_to_column("word") %>%
  left_join(extended_words %>% distinct(word, category, tradition), by = "word")

p_embed <- ggplot(pca_df, aes(x = PC1, y = PC2, colour = category, label = word)) +
  geom_point(size = 3, alpha = 0.8) +
  ggrepel::geom_text_repel(size = 3, max.overlaps = 15) +
  labs(
    title  = "Word Embeddings of Spiritual Terms (PCA)",
    x      = "PC1",
    y      = "PC2",
    colour = "Category"
  ) +
  theme_minimal(base_size = 13)

# ggrepel may not be installed; fall back gracefully
tryCatch(
  ggsave("figures/word_embeddings.png", p_embed, width = 10, height = 8, dpi = 150),
  error = function(e) {
    p_embed_plain <- p_embed + geom_text(size = 3, vjust = -0.5)
    ggsave("figures/word_embeddings.png", p_embed_plain, width = 10, height = 8, dpi = 150)
  }
)
cat("Saved: figures/word_embeddings.png\n")

# ── Nearest neighbours ────────────────────────────────────────────────────────

find_neighbours <- function(target_word, word_vecs, n = 5) {
  if (!target_word %in% rownames(word_vecs)) {
    message(sprintf("'%s' not found in embeddings.", target_word))
    return(invisible(NULL))
  }
  query <- word_vecs[target_word, , drop = FALSE]
  sims  <- sim2(word_vecs, query, method = "cosine", norm = "l2")
  sims  <- sort(sims[, 1], decreasing = TRUE)
  sims  <- sims[names(sims) != target_word]
  head(sims, n)
}

probe_words <- c("meditation", "God", "compassion", "nirvana")
for (w in probe_words) {
  cat(sprintf("\nNearest neighbours of '%s':\n", w))
  nn <- find_neighbours(w, word_vectors)
  if (!is.null(nn)) print(round(nn, 4))
}
