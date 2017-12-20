library(lubridate)
library(stringr)
library(jsonlite)

# Input Format: data.frame
# 
# Output Format:
# {"index":{}}
# {"is_inactive": "0", "created": "2017-01-01 12:30:00", "tenant_id": "1", "book_key": "970851715", "created_by_user": "449", "published_book_build_id": "NULL", "published": "2017-01-01 12:30:00", "publisher_id": "1", "id": "383"}
# 
# Note - This script always sets the 'mapping type' to "doc"
# See https://www.elastic.co/guide/en/elasticsearch/reference/6.x/removal-of-types.html
#
bulk_load_format <- function(x, index = NA) {
  metadata <- str_c('{"index":{', 
                    ifelse(is.na(index), "", metadata <- str_c('"_index": "', index, '", "_type": "doc"')),
                    '}}')
  rows <- sapply(1:nrow(x), function(n) toJSON(x[n, ]))
  rows <- str_sub(rows, start = 2, end = str_length(rows) - 1)
  as.vector(sapply(rows, function(row) c(metadata, row)))
}


# setwd('/home/larry/Github-Public')
filenames <- list.files(pattern = "*.csv")
x <- lapply(filenames, function(filename) {
  print(sprintf("Processing File: %s", filename))
  x <- read.csv(filename, header = TRUE)
  index <- str_sub(filename, end = -5)
  bulk_load_format(x, index)
})

# Transform the list into a vector and perform a sanity check
names(x) <- filenames
len <- sum(sapply(x, length))  # Sanity Check
x <- do.call(c, x)
if (len != length(x)) stop(warning("The lengths don't match!"))  

# Write the JSON data to disk
write(x, file = 'bulk_load.json')
