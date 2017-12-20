library(lubridate)
library(stringr)

create_date_time <- function(n, origin = ymd_hms("2017-01-01 00:00:00")) {
  # Mock times use a Gaussian dist w/ 12PM as the mean
    secs_per_day <- 24 * 3600
      time_of_day <- round(rnorm(n, mean = secs_per_day / 2, sd = 8000))

  # Dates are uniformaly dist over the year
    day_of_year <- sample(0:364, n, replace = TRUE)
      origin + ddays(day_of_year) + dseconds(time_of_day)
      }

create_session <- function(start_time) {
  start_time + dminutes(round(abs(rnorm(length(start_time), mean = 30, sd = 50))))
  }


# Example: Create the start and end times for 1000 user sessions
start_time <- create_date_time(1000)
end_time <- create_session(start_time)

# Plot the session length in minutes to make sure the shape is acceptable
session_lengths <- difftime(end_time, start_time, units = 'mins')
plot(table(session_lengths), xlab = "Time (mins)", ylab = "Num Sessions", main = "Session Lengths")
