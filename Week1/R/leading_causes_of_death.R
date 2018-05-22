# Week 1: Plotting leading causes of death with ggplot2
# 2018-05-20
# HemoShear Data Science Study Group


library(dplyr)
library(ggplot2)
library(magrittr)
library(readr)

theme_set(theme_bw())

# We put our data in this directory within the Docker container
dir('/data')

# Read in the leading causes of death from opendata.gov
d <- read_csv("/data/NCHS_-_Leading_Causes_of_Death__United_States.csv")
colnames(d)

# Rename columns so that they are readable and easy to type
colnames(d) <- c("year", "cause_id", "cause_name", "state", 
                 "deaths", "adj_death_rate")

# It is always a good idea to investigate each variable first
# Verify that the dates range from 1999-2015
range(d$year)
# See causes of death that have been recorded
unique(d$cause_name)

# There is an entry called United States, which is a combination of 
# other rows
unique(d$state)

d <- filter(d, state != "United States")

# Let's suppose we are interested in how the number
#  of unintentional injuries is changing in Oregon
d_inj <- filter(d, cause_name == 'Unintentional Injuries',
                state == c("Oregon"))

# We should build up a plot to show these data. It is
#  sensible to start with points, because we have one
#  number for unintentional deaths per year in Oregon
ggplot(d_inj, aes(x=year, y=deaths)) +
  geom_point()

# We can see that the number of unintentional deaths has been generally rising
# in Oregon from 1999 to 2015. We only know this because we were the ones manipulating the data,
# so we need to make it clear to others what the data represent by 
# adding labels
ggplot(d_inj, aes(x=year, y=deaths)) +
  geom_point() +
  labs(x='Year', y='Deaths from unintentional injuries in Oregon')


# Next, we might want to emphasize the points are dependent on 
#   one another by adding line segments to connect them. In this case,
#   there is a time-dependence between the points. For example,
#   the number of unintentional deaths in 2010 depends on the
#   the number in 2009, just like the population of the state 
#   in 2010 depends on the populuation in 2009. Unless the number
#   of points is very large, it is a good idea to add points in 
#   addition to lines. 
ggplot(d_inj, aes(x=year, y=deaths)) +
  geom_point() +
  geom_line() +
  labs(x='Year', y='Deaths from unintentional injuries in Oregon')

# Let's expand our plot to include data from Washington and Colorado.
# Since there are multiple states in this set, we will need to distinguish
#  the lines by an additional aesthetic. Color is a reasonable choice.
d_inj <- filter(d, cause_name == 'Unintentional Injuries',
                state %in% c("Oregon", "Washington", "Colorado"))

ggplot(d_inj, aes(x=year, y=deaths, color=state)) +
  geom_point() +
  geom_line() +
  labs(x='Year', y='Deaths from unintentional \ninjuries in Oregon')

# We can also map the state to linetype in the case where color blindness
#   may be an issue.
p <- ggplot(d_inj, aes(x=year, y=deaths, 
                  linetype=state)) +
  geom_point() +
  geom_line() +
  labs(x='Year', y='Deaths from unintentional \ninjuries in Oregon')
# So far, we have been looking at our plots in the RStudio window.
# Often, we will need to save these visualizations and share them with 
#  others. 
ggsave(p, filename = 'results/unintentional_deaths.png',
       width=5, height=3)

# Our plot looks good, but the x-axis text is a bit small. We can
#  simply add on to our previous plot
p <- p +
  theme(axis.text.x = element_text(size=rel(1.5)),
        axis.text.y = element_text(size=rel(1.5)))

ggsave(p, filename = 'results/unintentional_deaths.png',
       width=5, height=3)

d_inj <- dplyr::filter(d, cause_name == 'Unintentional Injuries',
                       year == 2015)
ggplot(d_inj, aes(x=state, y=deaths)) +
  geom_col() 

# This is not very informative
ggplot(d_inj, aes(x=state, y=deaths)) +
  geom_col() +
  labs(x='State', y='Deaths from unintentional \n injuries in 2015') +
  theme(axis.text.x = element_text(angle=30, vjust=1, hjust=1))


d_inj %<>%
  arrange(-deaths)


d_inj$state %<>% factor(levels = d_inj$state)

ggplot(d_inj, aes(x=state, y=deaths)) +
  geom_col() +
  labs(y= 'Deaths from unintentional injuries in 2015') +
  theme(axis.text.x = element_text(angle=30, vjust=1, hjust=1))

