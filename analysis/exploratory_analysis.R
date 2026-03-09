# Exploratory Analysis of Spiritual Vocabulary
# This script performs exploratory data analysis on the spiritual words datasets.

library(tidyverse)
library(readr)
library(ggplot2)

# ── Load data ──────────────────────────────────────────────────────────────────

spiritual_words <- read_csv("data/spiritual_words.csv", show_col_types = FALSE)
extended_words  <- read_csv("data/extended_spiritual_words.csv", show_col_types = FALSE)

cat("Core dataset:\n")
glimpse(spiritual_words)

cat("\nExtended dataset:\n")
glimpse(extended_words)

# ── Summary statistics ─────────────────────────────────────────────────────────

cat("\nSummary of core dataset:\n")
print(summary(spiritual_words))

cat("\nWord counts by category (core):\n")
spiritual_words %>%
  count(category, sort = TRUE) %>%
  print()

cat("\nWord counts by category (extended):\n")
extended_words %>%
  count(category, sort = TRUE) %>%
  print()

cat("\nWord counts by tradition (extended):\n")
extended_words %>%
  count(tradition, sort = TRUE) %>%
  print()

# ── Frequency distribution ─────────────────────────────────────────────────────

# Top 20 words by frequency (core dataset)
top_words <- spiritual_words %>%
  arrange(desc(frequency)) %>%
  slice_head(n = 20)

p_freq <- ggplot(top_words, aes(x = reorder(word, frequency), y = frequency, fill = category)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 20 Spiritual Words by Frequency",
    x     = "Word",
    y     = "Relative Frequency",
    fill  = "Category"
  ) +
  theme_minimal(base_size = 13)

ggsave("figures/word_frequency.png", p_freq, width = 8, height = 6, dpi = 150)
cat("\nSaved: figures/word_frequency.png\n")

# ── Category distribution ──────────────────────────────────────────────────────

p_cat <- extended_words %>%
  count(category) %>%
  ggplot(aes(x = reorder(category, n), y = n, fill = category)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Distribution of Words by Category (Extended Dataset)",
    x     = "Category",
    y     = "Count"
  ) +
  theme_minimal(base_size = 13)

ggsave("figures/category_distribution.png", p_cat, width = 8, height = 5, dpi = 150)
cat("Saved: figures/category_distribution.png\n")

# ── Tradition distribution ─────────────────────────────────────────────────────

p_trad <- extended_words %>%
  count(tradition) %>%
  ggplot(aes(x = reorder(tradition, n), y = n, fill = tradition)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Number of Terms per Spiritual Tradition",
    x     = "Tradition",
    y     = "Count"
  ) +
  theme_minimal(base_size = 13)

ggsave("figures/tradition_distribution.png", p_trad, width = 8, height = 5, dpi = 150)
cat("Saved: figures/tradition_distribution.png\n")

# ── Frequency by category ──────────────────────────────────────────────────────

p_box <- ggplot(extended_words, aes(x = reorder(category, frequency, median), y = frequency, fill = category)) +
  geom_boxplot(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Frequency Distribution by Category",
    x     = "Category",
    y     = "Relative Frequency"
  ) +
  theme_minimal(base_size = 13)

ggsave("figures/freq_by_category.png", p_box, width = 8, height = 5, dpi = 150)
cat("Saved: figures/freq_by_category.png\n")
