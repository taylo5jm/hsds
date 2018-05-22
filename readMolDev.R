readMolDev <- function (file, measurements = NULL, verbose = TRUE) 
{
    if (grepl("\\.txt", file)) {
        out_ncol_max <- max(count.fields(file = file, sep = "\t"))
        output <- read.table(file = file, sep = "\t", fill = T, 
                             col.names = 1:out_ncol_max, stringsAsFactors = F)
    }
    else if (grepl("\\.xlsx", file)) {
        output <- openxlsx::read.xlsx(file, colNames = FALSE)
    }
    else {
        stop("This function only parses xlsx or txt files")
    }
    output %<>% tibble::as.tibble()
    output %<>% dplyr::mutate_all(dplyr::funs(gsub("ATF$", "", 
                                                   .)))
    meta_info <- grep(".*Name \\[Plate Info\\].*", unlist(output[, 
                                                                 1]), value = T) %>% unname()
    run_names <- gsub(".*=([A-Z]{3}[0-9]{4}(-?|-\\d+)).*", "\\1", 
                      meta_info) %>% gsub("-$", "", .)
    plate_nums <- gsub(".*Plate ?(\\d*|\\d*b).*", "\\1", meta_info, 
                       ignore.case = T)
    plate_starts <- grep("(Well Name|Plate ID)", unlist(output[, 
                                                               1])) + 1
    plate_stops <- grep("^\\d$", unlist(output[, 1])) - 1
    plate_stops <- plate_stops[-1]
    plate_stops <- c(plate_stops, nrow(output))
    id_row <- droplevels(output[(plate_starts[1] - 1), ]) %>% 
        unlist() %>% na.omit()
    names(id_row) <- 1:length(id_row)
    always_ids <- c("Plate ID", "Well Name", "Site ID", "MEASUREMENT SET ID")
    if (is.null(measurements)) {
        measure_ids <- id_row[!id_row %in% always_ids]
        if (verbose) {
            message("Parsing the following columns: ", paste(measure_ids, 
                                                             collapse = ", "))
        }
        measures <- names(measure_ids) %>% as.numeric()
    }
    else {
        measures <- purrr::map(measurements, ~grep(., id_row, 
                                                   ignore.case = TRUE)) %>% unlist() %>% unique() %>% 
            as.numeric()
    }
    well_name <- grep("Well Name", id_row)
    site_id <- grep("Site ID", id_row)
    columns_we_want <- c(well_name, site_id, measures) %>% as.numeric()
    c_names <- id_row[columns_we_want]
    plates <- tibble::tibble()
    for (p in 1:length(plate_starts)) {
        p_start <- plate_starts[p]
        p_stop <- plate_stops[p]
        p_num <- plate_nums[p]
        r_name <- run_names[p]
        p_df <- output[p_start:p_stop, ]
        p_df <- p_df[, columns_we_want]
        colnames(p_df) <- c_names
        p_df$plate <- p_num
        p_df$run <- r_name
        p_df %<>% dplyr::select(run, plate, tidyselect::everything())
        if (p_df[1, 3] != "6") {
            plates <- rbind(plates, p_df)
        }
    }
    colnames(plates) <- make.names(colnames(plates)) %>% gsub("\\.$", 
                                                              "", .) %>% gsub("\\.{1,2}", "_", .) %>% tolower()
    plates %<>% dplyr::mutate_at(.vars = measures, .funs = as.numeric)
    return(tibble::as.tibble(plates))
}
