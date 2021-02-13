library(data.table)
library(tidyr)
library(ggplot2)
library(ggrepel)

#' Compare two different metrics files
#' useful when tweaking pipeline or metrics

new_metrics <- fread('data/metrics.csv')  # most recent metrics output
old_metrics <- fread('data/metrics_master.csv')  # previous metrics output

new_label <- 'isolabel-fix'
old_label <- 'master'
comparison <- paste(new_label, old_label, sep = '_')

new_metrics[, type := 'new']
old_metrics[, type := 'old']

dt <- 
  rbind(old_metrics, new_metrics, fill = T) %>%
  melt(
    id.vars = c('V1', 'type'),
    variable.name = 'metric',
    value.name = 'score'
  ) %>%
  separate(
    col = 'V1', 
    sep = '/',
    into = c(NA, 'scenario', 'output', 'scaling',
             'feature_selection', 'method_out')
  ) %>%
  separate(
    col = 'method_out',
    into = c('method', 'output_type'),
    sep = '_'
  ) %>%
  pivot_wider(
    names_from = 'type',
    values_from = 'score'
  ) %>% as.data.table

dt <- dt[!grepl('*_raw', metric)]
dt[, label := ifelse(
  abs(old - new) >= 0.01, 
  paste(round(old, 2), round(new, 2), sep = ','), 
  NA)
]

ggplot(dt, aes(old, new, col = method)) +
  geom_abline(slope = 1, intercept = 0, col = "grey") +
  geom_point(size = 1) +
  xlim(0, 1) + ylim(0, 1) +
  facet_wrap(.~metric) +
  geom_text_repel(aes(label = label,  col = method), size = 3, max.overlaps = NA) +
  labs(
    title = paste("Metrics Comparison:", comparison),
    x = old_label,
    y = new_label
  ) +
  theme_classic() +
  theme(legend.position = 'bottom')

ggsave(
  file.path('data', 'sanity', paste(comparison, 'png', sep = '.')),
  width = 7, height = 7
)
