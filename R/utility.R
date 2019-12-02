#' Suppress object length incompatibility warnings
#'
#' @param expr expression to be evaluated.

suppress_olw <- function(expr) {
  warning_handler <- function(w) {
    msg <- "longer object length is not a multiple of shorter object length"
    if (w$message == msg) invokeRestart("muffleWarning")
  }

  withCallingHandlers(expr, warning = warning_handler)
}
