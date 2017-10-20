library(tidyverse)
library(readr)
library(scales)
library(lubridate)

# Department names are long, so we're going to create abbreviations. Some
# abbreviations are probably more known than the actual department name (SEC),
# so use those abbreviations. Then if we're dealing with a "Department of X"
# shorten it to "D. x". Abbreviating these names make the scales much more
# reasonable.
abbrev <- function(x) {
  ifelse(as.character(x) == "Department of health and human services", "HHS", 
  ifelse(as.character(x) == "Securities and exchange commission", "SEC", 
  ifelse(as.character(x) == "Department of transportation", "DoT", 
         gsub("Department of (.*)", "D. \\1", x))))
}

df <- read_csv("output-2017.10.19.csv")
df <- df %>% mutate(
  agency = abbrev(agency),
  names = strsplit(names, ";"),
  rin = strsplit(rin, ";"),
  month = as.Date(cut(date, breaks = "month")))

# First let's take a look at how each document type has fluctuated throughout the years
df %>%
  count(type, month) %>%
  ggplot(aes(month, n, color=type)) +
  geom_line() +
  scale_x_date(
    labels = date_format("%Y-%m"),
    date_breaks = "1 year",
    expand=c(.01,.01)) +
  ylim(0, NA) +
  ylab("Documents") +
  xlab("Month of Publication") +
  ggtitle("Federal Register Documents Published per Month",
          subtitle = "Broken down by document type")

# All document types appear stable throughout time. Notices, by far, are the
# most common. Presidential documents are the fewest, and it may be hard to
# discern a pattern from this graph so let's take a closer look
df %>%
  filter(type == 'presidential') %>%
  count(month) %>%
  ggplot(aes(month, n)) +
  geom_line(color="#00BFC4") +
  scale_x_date(
    labels = date_format("%Y-%m"),
    date_breaks = "1 year",
    expand=c(.01,.01)) +
  ylim(0, NA) +
  ylab("Documents") +
  xlab("Month of Publication") +
  ggtitle("Federal Register Presidential Documents Published per Month")

# Wow, the number of presidential documents in the register flutuates a lot!
# Instead of looking at time linearly, what if there is a pattern grouped by month
df %>%
  filter(type == 'presidential') %>%
  mutate(mon = format(date, "%b"), monnum = month(date)) %>%
  count(mon, monnum) %>%
  arrange(monnum) %>%
  ggplot(aes(reorder(mon, monnum), n)) +
  geom_bar(stat='identity', fill='#00B1D8') +
  ylab("Documents") +
  xlab("Month of Publication") +
  ggtitle("Federal Register Presidential Documents Published per Month")

# So the president takes it easy in the winter and summer, but kicks it into
# high gear in the spring and fall.

# What are the top five agencies by number of documents in the federal register?
top_agencies = (df %>% count(agency) %>% top_n(5))$agency

# Combine the other agencies to create an "other" category
other_agencies = df %>% filter(!(agency %in% top_agencies)) %>%
  count(month) %>%
  mutate(agency = "other")

# How do the top 5 agencies compare to the rest?
df %>% filter(agency %in% top_agencies) %>%
  count(agency, month) %>%
  bind_rows(other_agencies) %>%
  ggplot(aes(month, n, color=agency)) +
  geom_line() +
  scale_x_date(
    labels = date_format("%Y-%m"),
    date_breaks = "1 year",
    expand=c(.01,.01)) +
  ylim(0, NA) +
  ylab("Documents") +
  xlab("Month of Publication") +
  ggtitle("Federal Register Documents Published: Top 5 Agencies") + 
  theme(legend.position="bottom", legend.justification = "left")

# While the top 5 agencies are somewhat close to each other, they are all
# dwarfed when other agencies are included. Let's break down the document
# types for the top 5 agencies
df %>% filter(agency %in% top_agencies) %>%
  count(agency, month, type) %>%
  ggplot(aes(month, n, color=type)) +
  geom_line(stat="identity") +
  scale_x_date(
    labels = date_format("%Y-%m"),
    date_breaks = "1 year",
    expand=c(.01,.01)) +
  ylim(0, NA) +
  ylab("Documents") +
  xlab("Month of Publication") +
  facet_grid(agency ~ .) +
  theme(legend.position="bottom", legend.justification = "left")

# All agencies appear to follow the trend of notices >> proprosed-rules and
# rules except for the department of transportation, which contains the most
# rules and the least notices. Why this might be is beyond me!
