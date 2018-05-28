#' ---
#' title: PAH0548 Nucs
#' author: Nathan Day (nathan.day@hemoshear.com)
#' date: 2018-05-10
#' ---
#### Globals ------------------------------------------------------------------

setwd("~/Binfo/PA/PAH/PAH05/PAH0548/")
library(assayr)
library(broom)
library(openxlsx)
library(ggsci)
library(ggbeeswarm)
library(boxr)
library(tidyverse)
library(magrittr)

options(stringsAsFactors = F)
options(scipen = 1)

theme_set(theme_assayr())
scale_colour_discrete <- function(...) { ggsci::scale_color_d3(..., palette = "category20")}

plots <- list()
p_title <- "PAH0548_NucCounts"

theme_set(theme_assayr())

#### Files --------------------------------------------------------------------
meta <- getMetaData("PAH0548") %>%
    as.data.frame() %>%
    set_names(1:ncol(.))
View(meta)
meta %<>% .[c(1,2,4,7:17)]
meta %<>% set_names(c("run", "sample_id", "exp_type", "imaging_plate", "imaging_well", "cell_type",
                      "donor", "donor_pheno", "media", "tx_challenge", "tx_cmpd", "tx_conc", "tx_cmpd2", "tx_conc2"))
# combine the tx2's into a single var
cp2 <- meta$tx_cmpd2 %>% str_split(" \\+ ")
co2 <- meta$tx_conc2 %>% gsub(" ", "", .) %>% str_split(",")
tx2 <- map2_chr(cp2, co2, ~ paste(..1, ..2, sep = "_") %>% paste(collapse = " + "))
tx2 %<>% ifelse(. == "DMSO_0uM", NA, .)

meta$tx_cmpd %<>% ifelse(!is.na(tx2), paste(., tx2, sep = " + "), .)

tabla(meta$tx_challenge)
tabla(meta$tx_cmpd)
tabla(meta$media)

tabla(meta$tx_conc)
meta$tx_conc %<>% gsub(" ?uM", "", .) %>% as.numeric() %>% as.factor()

# get raw data
box_dir <- 49226756211 
box_fetch(box_dir, ".")

### Ins -------------------------------------------------------------------
raw <- readMolDev("PAH0548 nuc count.txt")
raw %<>% rename(well = well_name,
                nuc_count = nuclear_count_transfluor)

# merge meta
raw$plate %<>% gsub("0", "", .)
raw$well %<>% gsub("0", "", .)
raw %<>% rename_at(vars(plate, well), funs(paste0("imaging_", .)))

## * repeats -----
## use B's when possible
# repeats <- filter(raw, grepl("b", imaging_plate))
# raw %<>% anti_join(repeats)
# repeats$imaging_plate %<>% gsub("b", "", .)
# raw %<>% anti_join(repeats, by = c("imaging_plate", "imaging_well", "site_id")) %>%
#     bind_rows(repeats)

# join with meta
samps <- inner_join(raw, meta)
samps$nuc_count %<>% as.numeric()

pd <- position_dodge(width = .5)
plots[[1]] <- ggplot(samps, aes(x = tx_conc, y = nuc_count, label = imaging_well,
                                group = paste(imaging_plate, imaging_well), color = imaging_plate)) +
    geom_text(size = 4, alpha = .75, position = pd) +
    geom_path(alpha = .5, position = pd, show.legend = F) +
    facet_wrap(tx_challenge ~ tx_cmpd, scale = "free_x") +
    labs(title = paste0(p_title),
         y = "Nuclei per site; labled by well",
         x = "[Tx] uM")

# average by sample
nuc_avg <- samps %>% group_by(sample_id, imaging_well, tx_cmpd, tx_conc, imaging_plate, tx_challenge) %>%
    summarise(nuc_avg = mean(nuc_count),
              nuc_cm2 = nuc_avg / .1218, #4x
              nuc_well = nuc_cm2 * .95) %>% #48well
    ungroup()

plots[[2]] <- ggplot(nuc_avg, aes(x = tx_conc, y = nuc_well, color = imaging_plate)) +
    geom_text(aes(label = imaging_well), size = 4, alpha = .75, position = position_quasirandom()) +
    facet_wrap(tx_challenge ~ tx_cmpd, scale = "free_x") +
    labs(title = paste0(p_title),
         y = "Nuclei Estimated per Well",
         x = "[Tx] uM")

#### Export -------------------------------------------------------------------
pdf(paste0(p_title, ".pdf"))
walk(plots, print)
dev.off()
# outputPlotsAsPdfs(plots, paste0(p_title, ".pdf"))

nuc_avg %>%
    dplyr::select(sample_id, nuc_well) %>%
    saveRDS(paste0(p_title, ".RDS"))

# push to Box
# box_push(box_dir, ".", overwrite = TRUE)

# box_ls(box_dir) %>% as.tibble() %>% View # see the RDS's box_id
