getMetaData <- function(study_id, device = FALSE, fully_parse = TRUE) {
    # manually adjusted for new experiments
    box_files <- c(101838632791, 161176997524, 161176997524, 33980749645,
                   185483159790, 71120788417, 243555362303, 101346468166,
                   161176997524, 161176997524) %>%
        set_names(c("PAH", "PAU", "PAG", "RNO",
                    "HEM", "RSQ", "PAD", "PAF",
                    "PAC", "PAB"))
    # manually map for sheet names of interest
    if (device == FALSE) {
      sheet_names <- c("PAH", "PAU_Huh7", "PAG_HepG2", "RNO07 Static",
                       "RNO20 (PBMC)", "HEM01", "RSQ05 MF", "RSQ01 Primary Heps Static",
                       "RNO21 (PAHTEE)","RNO08 - fibroblasts", "PAD", "PAF",
                       "PAC_Cardiomyocytes", "PAB_PBMCs") %>%
          set_names(c("PAH", "PAU", "PAG", "RNO07",
                      "RNO20", "HEM", "RSQ05", "RSQ01",
                      "RNO21", "RNO08", "PAD", "PAF",
                      "PAC", "PAB")) }
    if (device == TRUE) {
      sheet_names <- c("RNO07 Device") %>%
        set_names("RNO07")
    }
    result <- tibble() # container var
    for ( si in study_id ) {
        program <- gsub("^(\\D{3}).*", "\\1", si)
        box_file <- box_files[program]

        if ( program %in% c("RNO", "RSQ") ) {
            program <- gsub("^(\\D{3}\\d{2}).*", "\\1", si)
        }

        box_which <- sheet_names[program]

        meta <- box_read_excel(box_file, which = box_which, col_names = T, col_types = "text")

        if (fully_parse) {
            meta %<>% dplyr::filter(`STUDY NAME` == si)
        }
        result %<>% dplyr::bind_rows(meta)
    }
    return(result)
}
