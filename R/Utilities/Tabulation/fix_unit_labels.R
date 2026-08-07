#' Restore intended lower-case unit labels in a built table
#'
#' TernTables title-cases variable labels, which turns unit strings such as "cc"
#' into "Cc". The tern builders return plain data frames, so the row labels can be
#' corrected in place after the table is built (attributes are preserved).
#'
#' @param tbl A table returned by ternD/ternG/ternStyle.
#' @return The same object with unit strings restored to lower case.
fix_unit_labels <- function(tbl) {
  col <- if ("Variable" %in% names(tbl)) "Variable" else names(tbl)[1]
  x <- as.character(tbl[[col]])
  x <- gsub("\\bCc\\b", "cc", x)
  x <- gsub("\\bMl\\b", "mL", x)
  x <- gsub("\\bMmhg\\b", "mmHg", x)
  tbl[[col]] <- x
  tbl
}
