# This is the Rocker RStudio Dockerfile modified to install
#   additional R packages

# inherit image 
FROM rocker/rstudio-stable:latest
# update our package list
RUN apt update
# need xml2 for the R package xml2
RUN apt install -y libxml2-dev
# install R packages
RUN Rscript -e "install.packages(c('ggplot2', 'dplyr', 'magrittr', 'egg', 'xml2', 'rvest', 'tidyverse'))"
RUN Rscript -e "install.packages(c('caTools', 'bitops'))"
