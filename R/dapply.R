
dapply <- function(X, FUN, ..., MARGIN = 2, parallel = FALSE,
                   mc.cores = 1L, return = c("same", "matrix", "data.frame"), drop = TRUE) {
  rowwl <- switch(MARGIN, `1` = TRUE, `2` = FALSE, stop("MARGIN only supports 2 - columns or 1 - rows"))
  aplyfun <- if(parallel) function(...) mclapply(..., mc.cores = mc.cores) else lapply
  if(is.atomic(X)) {
    dX <- dim(X)
    if(length(dX) != 2L) stop("dapply cannot handle vectors or higher-dimensional arrays")
    res <- if(rowwl) aplyfun(.Call(Cpp_mrtl, X, FALSE, 0L), FUN, ...) else aplyfun(.Call(Cpp_mctl, X, FALSE, 0L), FUN, ...)
    lx1 <- length(res[[1L]])
    if(lx1 == 1L && drop) return(`names<-`(unlist(res, use.names = FALSE), dimnames(X)[[if(rowwl) 1L else 2L]]))
    switch(return[1L], same = {
             ax <- attributes(X)
             retmatl <- TRUE
           }, matrix = {
             ax <- list(dim = dX, dimnames = dimnames(X))
             retmatl <- TRUE
           }, data.frame = {
             dn <- dimnames(X)
             ax <- list(names = dn[[2L]],
                        row.names = if(is.null(dn[[1L]])) .set_row_names(dX[1L]) else dn[[1L]],
                        class = "data.frame")
             retmatl <- FALSE
           }, stop("Unknown return option!"))
  } else {
    ax <- attributes(X)
    attributes(X) <- NULL
    res <- if(rowwl) aplyfun(.Call(Cpp_mrtl, do.call(cbind, X), FALSE, 0L), FUN, ...) else aplyfun(X, FUN, ...)
    lx1 <- length(res[[1L]])
    if(lx1 == 1L && drop) return(`names<-`(unlist(res, use.names = FALSE), if(rowwl) charorNULL(ax[["row.names"]]) else ax[["names"]]))
    dX <- c(length(X[[1L]]), length(X))
    switch(return[1L], same = retmatl <- FALSE, matrix = {
      ax <- list(dim = dX, dimnames = list(charorNULL(ax[["row.names"]]), ax[["names"]]))
      retmatl <- TRUE
    }, data.frame = {
      ax <- list(names = ax[["names"]],
                 row.names = if(is.null(ax[["row.names"]])) .set_row_names(dX[1L]) else ax[["row.names"]],
                 class = "data.frame")
      retmatl <- FALSE
    }, stop("Unknown return option!"))
  }
  if(retmatl) {
    if(rowwl) {
      if(lx1 != dX[2L]) {
        ax[["dim"]][2L] <- lx1
        ax[["dimnames"]] <- list(ax[["dimnames"]][[1L]], if(!is.null(nx1 <- names(res[[1L]]))) nx1 else if(lx1 == 1L)
          deparse(substitute(FUN)) else paste0(deparse(substitute(FUN)), seq_len(lx1)))
      }
      res <- matrix(unlist(res, use.names = FALSE), ncol = lx1, byrow = TRUE)
    } else {
      if(lx1 != dX[1L]) {
        ax[["dim"]][1L] <- lx1
        ax[["dimnames"]] <- list(if(!is.null(nx1 <- names(res[[1L]]))) nx1 else if(lx1 == 1L)
          deparse(substitute(FUN)) else paste0(deparse(substitute(FUN)), seq_len(lx1)), ax[["dimnames"]][[2L]])
      }
      res <- do.call(cbind, res)
    }
  } else {
    if(rowwl) {
      if(lx1 != dX[2L]) ax[["names"]] <- if(!is.null(nx1 <- names(res[[1L]]))) nx1 else if(lx1 == 1L)
        deparse(substitute(FUN)) else paste0(deparse(substitute(FUN)), seq_len(lx1))
      res <- .Call(Cpp_mctl, matrix(unlist(res, use.names = FALSE), ncol = lx1, byrow = TRUE), FALSE, 0L) # definitely faster than do.call(rbind, X)
    } else if(lx1 != dX[1L])
      ax[["row.names"]] <- if(!is.null(nx1 <- names(res[[1L]]))) nx1 else .set_row_names(lx1) # could also make deparse(substitute(FUN)), but that is not so typical for data.frames !
  }
  setAttributes(res, ax)
}

# Notes about this version: same as dapply 3 (compact), but takingdrop case before !! -> faster !! and also solving issue with row.names for matrices -> row and column names must be of same type !! as.matrix.data.frame converst row.names to character !!
# Before v1.3.0
# dapply <- function(X, FUN, ..., MARGIN = 2, parallel = FALSE,
#                    mc.cores = 1L, return = c("same","matrix","data.frame"), drop = TRUE) {
#   ax <- attributes(X)
#   arl <- is.atomic(X) # is.array, faster !
#   rowwl <- switch(MARGIN, `1` = TRUE, `2` = FALSE, stop("MARGIN only supports 2 - columns or 1 - rows"))
#   retmatl <- switch(return[1L], same = arl, matrix = TRUE, data.frame = FALSE, stop("Unknown return option!"))
#   aplyfun <- if(parallel) function(...) mclapply(..., mc.cores = mc.cores) else lapply
#   if(arl) {
#     dX <- dim(X)
#     if(length(dX) != 2L) stop("dapply cannot handle vectors or higher-dimensional arrays")
#     res <- if(rowwl) aplyfun(.Call(Cpp_mrtl, X, FALSE, 0L), FUN, ...) else aplyfun(.Call(Cpp_mctl, X, FALSE, 0L), FUN, ...)
#     lx1 <- length(res[[1L]])
#     if(lx1 == 1L && drop) return(`names<-`(unlist(res, use.names = FALSE), ax[["dimnames"]][[if(rowwl) 1L else 2L]]))
#     if(!retmatl) {
#       dn <- dimnames(X) # ax[["dimnames"]] # best ? -> use res instead of reassigning X ! -> no memory loss !
#       ax <- list(names = dn[[2L]], row.names = if(is.null(dn[[1L]])) .set_row_names(dX[1L]) else dn[[1L]],
#                  class = "data.frame") # c( ... , ax[!(names(ax) %in% c("dim","dimnames","class"))]) # don't know why one would need this !
#     }
#   } else {
#     attributes(X) <- NULL
#     dX <- c(length(X[[1L]]), length(X)) # much faster than dim(X) on a list !
#     res <- if(rowwl) aplyfun(.Call(Cpp_mrtl, do.call(cbind, X), FALSE, 0L), FUN, ...) else aplyfun(X, FUN, ...) # do.call(cbind, X) is definitely faster than unlist(X, use.names = FALSE) and attaching dim attribute
#     lx1 <- length(res[[1L]])
#     if(lx1 == 1L && drop) return(`names<-`(unlist(res, use.names = FALSE), if(rowwl) charorNULL(ax[["row.names"]]) else ax[["names"]]))
#     if(retmatl) ax <- list(dim = dX, dimnames = list(charorNULL(ax[["row.names"]]), ax[["names"]]))
#     # c(..., ax[!(names(ax) %in% c("names","row.names","class"))]) # don't know why one would need this !
#   }
#   if(retmatl) {
#     if(rowwl) {
#       if(lx1 != dX[2L]) {
#         ax[["dim"]][2L] <- lx1
#         ax[["dimnames"]] <- list(ax[["dimnames"]][[1L]], if(!is.null(nx1 <- names(res[[1L]]))) nx1 else if(lx1 == 1L)
#           deparse(substitute(FUN)) else paste0(deparse(substitute(FUN)), seq_len(lx1)))
#       }
#       res <- matrix(unlist(res, use.names = FALSE), ncol = lx1, byrow = TRUE)
#     } else {
#       if(lx1 != dX[1L]) {
#         ax[["dim"]][1L] <- lx1
#         ax[["dimnames"]] <- list(if(!is.null(nx1 <- names(res[[1L]]))) nx1 else if(lx1 == 1L)
#           deparse(substitute(FUN)) else paste0(deparse(substitute(FUN)), seq_len(lx1)), ax[["dimnames"]][[2L]])
#       }
#       res <- do.call(cbind, res)
#     }
#   } else {
#     if(rowwl) {
#       if(lx1 != dX[2L]) ax[["names"]] <- if(!is.null(nx1 <- names(res[[1L]]))) nx1 else if(lx1 == 1L)
#         deparse(substitute(FUN)) else paste0(deparse(substitute(FUN)), seq_len(lx1))
#       res <- .Call(Cpp_mctl, matrix(unlist(res, use.names = FALSE), ncol = lx1, byrow = TRUE), FALSE, 0L) # definitely faster than do.call(rbind, X)
#     } else if(lx1 != dX[1L])
#       ax[["row.names"]] <- if(!is.null(nx1 <- names(res[[1L]]))) nx1 else .set_row_names(lx1) # could also make deparse(substitute(FUN)), but that is not so typical for data.frames !
#   }
#   setAttributes(res, ax)
# }
