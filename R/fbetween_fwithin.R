# library(Rcpp)
# sourceCpp('src/BW.cpp')
# sourceCpp('src/BWa.cpp')
# sourceCpp('src/BWl.cpp')
# source("R/GRP.R")
# source("R/small_helper.R")
# source("R/quick_conversion.R")

# Note: for principal innovations of this code see fsum.R and fscale.R. Old code is commented out below and was innovated in flag.R.
#  replaced give.names = TRUE with stub
fwithin <- function(x, ...) { # g = NULL, w = NULL, na.rm = TRUE, add.global.mean = FALSE,
  UseMethod("fwithin", x)
}
fwithin.default <- function(x, g = NULL, w = NULL, na.rm = TRUE, add.global.mean = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  if(is.null(g)) return(BWCpp(x,0L,0L,NULL,w,na.rm,add.global.mean)) else if (is.atomic(g)) {
    if(is.factor(g)) return(BWCpp(x,fnlevels(g),g,NULL,w,na.rm,add.global.mean)) else {
      g <- qG(g, ordered = FALSE)
      return(BWCpp(x,attr(g,"N.groups"),g,NULL,w,na.rm,add.global.mean))
    }
  } else {
    if(!is.GRP(g)) g <- GRP(g, return.groups = FALSE)
    return(BWCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean))
  }
}
fwithin.pseries <- function(x, effect = 1L, w = NULL, na.rm = TRUE, add.global.mean = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  g <- if(length(effect) == 1L) attr(x, "index")[[effect]] else interaction(attr(x, "index")[effect], drop = TRUE)
  BWCpp(x,fnlevels(g),g,NULL,w,na.rm,add.global.mean)
}
fwithin.matrix <- function(x, g = NULL, w = NULL, na.rm = TRUE, add.global.mean = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  if(is.null(g)) return(BWmCpp(x,0L,0L,NULL,w,na.rm,add.global.mean)) else if(is.atomic(g)) {
    if(is.factor(g)) return(BWmCpp(x,fnlevels(g),g,NULL,w,na.rm,add.global.mean)) else {
      g <- qG(g, ordered = FALSE)
      return(BWmCpp(x,attr(g,"N.groups"),g,NULL,w,na.rm,add.global.mean))
    }
  } else {
    if(!is.GRP(g)) g <- GRP(g, return.groups = FALSE)
    return(BWmCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean))
  }
}
fwithin.data.frame <- function(x, g = NULL, w = NULL, na.rm = TRUE, add.global.mean = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  if(is.null(g)) return(BWlCpp(x,0L,0L,NULL,w,na.rm,add.global.mean)) else if(is.atomic(g)) {
    if(is.factor(g)) return(BWlCpp(x,fnlevels(g),g,NULL,w,na.rm,add.global.mean)) else {
      g <- qG(g, ordered = FALSE)
      return(BWlCpp(x,attr(g,"N.groups"),g,NULL,w,na.rm,add.global.mean))
    }
  } else {
    if(!is.GRP(g)) g <- GRP(g, return.groups = FALSE)
    return(BWlCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean))
  }
}
fwithin.pdata.frame <- function(x, effect = 1L, w = NULL, na.rm = TRUE, add.global.mean = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  g <- if(length(effect) == 1L) attr(x, "index")[[effect]] else interaction(attr(x, "index")[effect], drop = TRUE)
  BWlCpp(x,fnlevels(g),g,NULL,w,na.rm,add.global.mean)
}
fwithin.grouped_df <- function(x, w = NULL, na.rm = TRUE, add.global.mean = FALSE,
                               keep.group_vars = TRUE, keep.w = TRUE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  g <- GRP.grouped_df(x)
  wsym <- deparse(substitute(w))
  nam <- names(x)
  gn2 <- which(nam %in% g[[5L]])
  gn <- if(keep.group_vars) gn2 else NULL
  if(!(wsym == "NULL" || is.na(wn <- match(wsym, nam)))) {
    w <- x[[wn]]
    if(any(gn2 == wn)) stop("Weights coincide with grouping variables!")
    gn2 <- c(gn2,wn)
    if(keep.w) gn <- c(gn,wn)
  }
  if(length(gn2)) {
    if(!length(gn))
      return(BWlCpp(x[-gn2],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)) else {
        ax <- attributes(x)
        attributes(x) <- NULL
        ax[["names"]] <- c(nam[gn], nam[-gn2])
        return(setAttributes(c(x[gn],BWlCpp(x[-gn2],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)), ax))
      }
  } else return(BWlCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean))
}


W <- function(x, ...) { # g = NULL, w = NULL, na.rm = TRUE, add.global.mean = FALSE,
  UseMethod("W", x)
}
W.default <- function(x, g = NULL, w = NULL, na.rm = TRUE, add.global.mean = FALSE, ...) {
  fwithin.default(x, g, w, na.rm, add.global.mean, ...)
}
W.pseries <- function(x, effect = 1L, w = NULL, na.rm = TRUE, add.global.mean = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  g <- if(length(effect) == 1L) attr(x, "index")[[effect]] else interaction(attr(x, "index")[effect], drop = TRUE)
  BWCpp(x,fnlevels(g),g,NULL,w,na.rm,add.global.mean)
}
W.matrix <- function(x, g = NULL, w = NULL, na.rm = TRUE, add.global.mean = FALSE, stub = "W.", ...) {
  add_stub(fwithin.matrix(x, g, w, na.rm, add.global.mean, ...), stub)
}
W.grouped_df <- function(x, w = NULL, na.rm = TRUE, add.global.mean = FALSE,
                         stub = "W.", keep.group_vars = TRUE, keep.w = TRUE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  g <- GRP.grouped_df(x)
  wsym <- deparse(substitute(w))
  nam <- names(x)
  gn2 <- which(nam %in% g[[5L]])
  gn <- if(keep.group_vars) gn2 else NULL
  if(!(wsym == "NULL" || is.na(wn <- match(wsym, nam)))) {
    w <- x[[wn]]
    if(any(gn2 == wn)) stop("Weights coincide with grouping variables!")
    gn2 <- c(gn2,wn)
    if(keep.w) gn <- c(gn,wn)
  }
  if(length(gn2)) {
    if(!length(gn))
      return(add_stub(BWlCpp(x[-gn2],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean), stub)) else {
        ax <- attributes(x)
        attributes(x) <- NULL
        ax[["names"]] <- c(nam[gn], if(is.character(stub)) paste0(stub, nam[-gn2]) else nam[-gn2])
        return(setAttributes(c(x[gn],BWlCpp(x[-gn2],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)), ax))
      }
  } else return(add_stub(BWlCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean), stub))
}
W.pdata.frame <- function(x, effect = 1L, w = NULL, cols = is.numeric, na.rm = TRUE, add.global.mean = FALSE,
                          stub = "W.", keep.ids = TRUE, keep.w = TRUE, ...) {

  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  ax <- attributes(x)
  class(x) <- NULL
  nam <- ax[["names"]]
  g <- if(length(effect) == 1L) ax[["index"]][[effect]] else
       interaction(ax[["index"]][effect], drop = TRUE)

  if(keep.ids) {
    gn <- which(nam %in% names(ax[["index"]]))
    if(length(gn) && is.null(cols)) cols <- seq_along(x)[-gn]
  } else gn <- NULL

  if(!is.null(cols)) cols <- cols2int(cols, x, nam)

  if(is.call(w)) {
    w <- all.vars(w)
    wn <- anyNAerror(match(w, nam), "Unknown weight variable!")
    w <- x[[wn]]
    cols <- if(is.null(cols)) seq_along(x)[-wn] else cols[cols != wn]
    if(keep.w) gn <- c(gn, wn)
  }

  if(length(gn) && !is.null(cols)) {
    ax[["names"]] <- c(nam[gn], if(is.character(stub)) paste0(stub, nam[cols]) else nam[cols])
    return(setAttributes(c(x[gn], BWlCpp(x[cols],fnlevels(g),g,NULL,w,na.rm,add.global.mean)), ax))
  } else if(!length(gn)) {
    ax[["names"]] <- if(is.character(stub)) paste0(stub, nam[cols]) else nam[cols]
    return(setAttributes(BWlCpp(x[cols],fnlevels(g),g,NULL,w,na.rm,add.global.mean), ax))
  } else {
    if(is.character(stub)) {
      ax[["names"]] <- paste0(stub, nam)
      return(setAttributes(BWlCpp(x,fnlevels(g),g,NULL,w,na.rm,add.global.mean), ax))
    } else
      return(BWlCpp(`oldClass<-`(x, ax[["class"]]),fnlevels(g),g,NULL,w,na.rm,add.global.mean))
  }
}
W.data.frame <- function(x, by = NULL, w = NULL, cols = is.numeric, na.rm = TRUE,
                         stub = "W.", add.global.mean = FALSE, keep.by = TRUE, keep.w = TRUE, ...) {

  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  if(is.call(by) || is.call(w)) {
    ax <- attributes(x)
    class(x) <- NULL
    nam <- ax[["names"]]

    if(is.call(by)) {
      if(length(by) == 3L) {
        cols <- anyNAerror(match(all.vars(by[[2L]]), nam), "Unknown variables passed to by!")
        gn <- anyNAerror(match(all.vars(by[[3L]]), nam), "Unknown variables passed to by!")
      } else {
        gn <- anyNAerror(match(all.vars(by), nam), "Unknown variables passed to by!")
        cols <- if(is.null(cols)) seq_along(x)[-gn] else cols2int(cols, x, nam)
      }
      by <- if(length(gn) == 1L) at2GRP(x[[gn]]) else GRP(x, gn, return.groups = FALSE)
      if(!keep.by) gn <- NULL
    } else {
      gn <- NULL
      if(!is.null(cols)) cols <- cols2int(cols, x, nam)
      if(!is.GRP(by)) by <- if(is.null(by)) list(0L, 0L, NULL) else if(is.atomic(by)) # Necessary for if by is passed externally !!
                            at2GRP(by) else GRP(by, return.groups = FALSE)
    }

    if(is.call(w)) {
      w <- all.vars(w)
      wn <- anyNAerror(match(w, nam), "Unknown weight variable!")
      w <- x[[wn]]
      cols <- if(is.null(cols)) seq_along(x)[-wn] else cols[cols != wn]
      if(keep.w) gn <- c(gn, wn)
    }

    if(length(gn)) {
      ax[["names"]] <- c(nam[gn], if(is.character(stub)) paste0(stub, nam[cols]) else nam[cols])
      return(setAttributes(c(x[gn], BWlCpp(x[cols],by[[1L]],by[[2L]],by[[3L]],w,na.rm,add.global.mean)), ax))
    } else {
      ax[["names"]] <- if(is.character(stub)) paste0(stub, nam[cols]) else nam[cols]
      return(setAttributes(BWlCpp(x[cols],by[[1L]],by[[2L]],by[[3L]],w,na.rm,add.global.mean), ax))
    }
  } else if(!is.null(cols)) {
    ax <- attributes(x)
    x <- if(is.function(cols)) unclass(x)[vapply(x, cols, TRUE)] else unclass(x)[cols]
    ax[["names"]] <- names(x)
    setattributes(x, ax)
  }
  if(is.character(stub)) names(x) <- paste0(stub, names(x))

  if(is.null(by)) return(BWlCpp(x,0L,0L,NULL,w,na.rm,add.global.mean)) else if (is.atomic(by)) {
    if(is.factor(by)) return(BWlCpp(x,fnlevels(by),by,NULL,w,na.rm,add.global.mean)) else {
      by <- qG(by, ordered = FALSE)
      return(BWlCpp(x,attr(by,"N.groups"),by,NULL,w,na.rm,add.global.mean))
    }
  } else {
    if(!is.GRP(by)) by <- GRP(by, return.groups = FALSE)
    return(BWlCpp(x,by[[1L]],by[[2L]],by[[3L]],w,na.rm,add.global.mean))
  }
}


fbetween <- function(x, ...) { # g = NULL, w = NULL, na.rm = TRUE, fill = FALSE,
  UseMethod("fbetween", x)
}
fbetween.default <- function(x, g = NULL, w = NULL, na.rm = TRUE, fill = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  if(is.null(g)) return(BWCpp(x,0L,0L,NULL,w,na.rm,fill,TRUE)) else if (is.atomic(g)) {
    if(is.factor(g)) return(BWCpp(x,fnlevels(g),g,NULL,w,na.rm,fill,TRUE)) else {
      g <- qG(g, ordered = FALSE)
      return(BWCpp(x,attr(g,"N.groups"),g,NULL,w,na.rm,fill,TRUE))
    }
  } else {
    if(!is.GRP(g)) g <- GRP(g, return.groups = FALSE)
    return(BWCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,fill,TRUE))
  }
}
fbetween.pseries <- function(x, effect = 1L, w = NULL, na.rm = TRUE, fill = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  g <- if(length(effect) == 1L) attr(x, "index")[[effect]] else interaction(attr(x, "index")[effect], drop = TRUE)
  BWCpp(x,fnlevels(g),g,NULL,w,na.rm,fill,TRUE)
}
fbetween.matrix <- function(x, g = NULL, w = NULL, na.rm = TRUE, fill = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  if(is.null(g)) return(BWmCpp(x,0L,0L,NULL,w,na.rm,fill,TRUE)) else if(is.atomic(g)) {
    if(is.factor(g)) return(BWmCpp(x,fnlevels(g),g,NULL,w,na.rm,fill,TRUE)) else {
      g <- qG(g, ordered = FALSE)
      return(BWmCpp(x,attr(g,"N.groups"),g,NULL,w,na.rm,fill,TRUE))
    }
  } else {
    if(!is.GRP(g)) g <- GRP(g, return.groups = FALSE)
    return(BWmCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,fill,TRUE))
  }
}
fbetween.data.frame <- function(x, g = NULL, w = NULL, na.rm = TRUE, fill = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  if(is.null(g)) return(BWlCpp(x,0L,0L,NULL,w,na.rm,fill,TRUE)) else if(is.atomic(g)) {
    if(is.factor(g)) return(BWlCpp(x,fnlevels(g),g,NULL,w,na.rm,fill,TRUE)) else {
      g <- qG(g, ordered = FALSE)
      return(BWlCpp(x,attr(g,"N.groups"),g,NULL,w,na.rm,fill,TRUE))
    }
  } else {
    if(!is.GRP(g)) g <- GRP(g, return.groups = FALSE)
    return(BWlCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,fill,TRUE))
  }
}
fbetween.pdata.frame <- function(x, effect = 1L, w = NULL, na.rm = TRUE, fill = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  g <- if(length(effect) == 1L) attr(x, "index")[[effect]] else interaction(attr(x, "index")[effect], drop = TRUE)
  BWlCpp(x,fnlevels(g),g,NULL,w,na.rm,fill,TRUE)
}
fbetween.grouped_df <- function(x, w = NULL, na.rm = TRUE, fill = FALSE,
                               keep.group_vars = TRUE, keep.w = TRUE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  g <- GRP.grouped_df(x)
  wsym <- deparse(substitute(w))
  nam <- names(x)
  gn2 <- which(nam %in% g[[5L]])
  gn <- if(keep.group_vars) gn2 else NULL
  if(!(wsym == "NULL" || is.na(wn <- match(wsym, nam)))) {
    w <- x[[wn]]
    if(any(gn2 == wn)) stop("Weights coincide with grouping variables!")
    gn2 <- c(gn2,wn)
    if(keep.w) gn <- c(gn,wn)
  }
  if(length(gn2)) {
    if(!length(gn))
      return(BWlCpp(x[-gn2],g[[1L]],g[[2L]],g[[3L]],w,na.rm,fill,TRUE)) else {
        ax <- attributes(x)
        attributes(x) <- NULL
        ax[["names"]] <- c(nam[gn], nam[-gn2])
        return(setAttributes(c(x[gn],BWlCpp(x[-gn2],g[[1L]],g[[2L]],g[[3L]],w,na.rm,fill,TRUE)), ax))
      }
  } else return(BWlCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,fill,TRUE))
}


B <- function(x, ...) { # g = NULL, w = NULL, na.rm = TRUE, fill = FALSE,
  UseMethod("B", x)
}
B.default <- function(x, g = NULL, w = NULL, na.rm = TRUE, fill = FALSE, ...) {
  fbetween.default(x, g, w, na.rm, fill, ...)
}
B.pseries <- function(x, effect = 1L, w = NULL, na.rm = TRUE, fill = FALSE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  g <- if(length(effect) == 1L) attr(x, "index")[[effect]] else interaction(attr(x, "index")[effect], drop = TRUE)
  BWCpp(x,fnlevels(g),g,NULL,w,na.rm,fill,TRUE)
}
B.matrix <- function(x, g = NULL, w = NULL, na.rm = TRUE, fill = FALSE, stub = "B.", ...) {
  add_stub(fbetween.matrix(x, g, w, na.rm, fill, ...), stub)
}
B.grouped_df <- function(x, w = NULL, na.rm = TRUE, fill = FALSE,
                         stub = "B.", keep.group_vars = TRUE, keep.w = TRUE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  g <- GRP.grouped_df(x)
  wsym <- deparse(substitute(w))
  nam <- names(x)
  gn2 <- which(nam %in% g[[5L]])
  gn <- if(keep.group_vars) gn2 else NULL
  if(!(wsym == "NULL" || is.na(wn <- match(wsym, nam)))) {
    w <- x[[wn]]
    if(any(gn2 == wn)) stop("Weights coincide with grouping variables!")
    gn2 <- c(gn2,wn)
    if(keep.w) gn <- c(gn,wn)
  }
  if(length(gn2)) {
    if(!length(gn))
      return(add_stub(BWlCpp(x[-gn2],g[[1L]],g[[2L]],g[[3L]],w,na.rm,fill,TRUE), stub)) else {
        ax <- attributes(x)
        attributes(x) <- NULL
        ax[["names"]] <- c(nam[gn], if(is.character(stub)) paste0(stub, nam[-gn2]) else nam[-gn2])
        return(setAttributes(c(x[gn],BWlCpp(x[-gn2],g[[1L]],g[[2L]],g[[3L]],w,na.rm,fill,TRUE)), ax))
      }
  } else return(add_stub(BWlCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,fill,TRUE), stub))
}
B.pdata.frame <- function(x, effect = 1L, w = NULL, cols = is.numeric, na.rm = TRUE, fill = FALSE,
                          stub = "B.", keep.ids = TRUE, keep.w = TRUE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  ax <- attributes(x)
  class(x) <- NULL
  nam <- ax[["names"]]
  g <- if(length(effect) == 1L) ax[["index"]][[effect]] else
    interaction(ax[["index"]][effect], drop = TRUE)

  if(keep.ids) {
    gn <- which(nam %in% names(ax[["index"]]))
    if(length(gn) && is.null(cols)) cols <- seq_along(x)[-gn]
  } else gn <- NULL

  if(!is.null(cols)) cols <- cols2int(cols, x, nam)

  if(is.call(w)) {
    w <- all.vars(w)
    wn <- anyNAerror(match(w, nam), "Unknown weight variable!")
    w <- x[[wn]]
    cols <- if(is.null(cols)) seq_along(x)[-wn] else cols[cols != wn]
    if(keep.w) gn <- c(gn, wn)
  }

  if(length(gn) && !is.null(cols)) {
    ax[["names"]] <- c(nam[gn], if(is.character(stub)) paste0(stub, nam[cols]) else nam[cols])
    return(setAttributes(c(x[gn], BWlCpp(x[cols],fnlevels(g),g,NULL,w,na.rm,fill,TRUE)), ax))
  } else if(!length(gn)) {
    ax[["names"]] <- if(is.character(stub)) paste0(stub, nam[cols]) else nam[cols]
    return(setAttributes(BWlCpp(x[cols],fnlevels(g),g,NULL,w,na.rm,fill,TRUE), ax))
  } else {
    if(is.character(stub)) {
      ax[["names"]] <- paste0(stub, nam)
      return(setAttributes(BWlCpp(x,fnlevels(g),g,NULL,w,na.rm,fill,TRUE), ax))
    } else
      return(BWlCpp(`oldClass<-`(x, ax[["class"]]),fnlevels(g),g,NULL,w,na.rm,fill,TRUE))
  }
}
B.data.frame <- function(x, by = NULL, w = NULL, cols = is.numeric, na.rm = TRUE,
                         fill = FALSE, stub = "B.", keep.by = TRUE, keep.w = TRUE, ...) {
  if(!missing(...)) stop("Unknown argument ", dotstostr(...))
  if(is.call(by) || is.call(w)) {
    ax <- attributes(x)
    class(x) <- NULL
    nam <- ax[["names"]]

    if(is.call(by)) {
      if(length(by) == 3L) {
        cols <- anyNAerror(match(all.vars(by[[2L]]), nam), "Unknown variables passed to by!")
        gn <- anyNAerror(match(all.vars(by[[3L]]), nam), "Unknown variables passed to by!")
      } else {
        gn <- anyNAerror(match(all.vars(by), nam), "Unknown variables passed to by!")
        cols <- if(is.null(cols)) seq_along(x)[-gn] else cols2int(cols, x, nam)
      }
      by <- if(length(gn) == 1L) at2GRP(x[[gn]]) else GRP(x, gn, return.groups = FALSE)
      if(!keep.by) gn <- NULL
    } else {
      gn <- NULL
      if(!is.null(cols)) cols <- cols2int(cols, x, nam)
      if(!is.GRP(by)) by <- if(is.null(by)) list(0L, 0L, NULL) else if(is.atomic(by)) # Necessary for if by is passed externally !!
                            at2GRP(by) else GRP(by, return.groups = FALSE)
    }

    if(is.call(w)) {
      w <- all.vars(w)
      wn <- anyNAerror(match(w, nam), "Unknown weight variable!")
      w <- x[[wn]]
      cols <- if(is.null(cols)) seq_along(x)[-wn] else cols[cols != wn]
      if(keep.w) gn <- c(gn, wn)
    }

    if(length(gn)) {
      ax[["names"]] <- c(nam[gn], if(is.character(stub)) paste0(stub, nam[cols]) else nam[cols])
      return(setAttributes(c(x[gn], BWlCpp(x[cols],by[[1L]],by[[2L]],by[[3L]],w,na.rm,fill,TRUE)), ax))
    } else {
      ax[["names"]] <- if(is.character(stub)) paste0(stub, nam[cols]) else nam[cols]
      return(setAttributes(BWlCpp(x[cols],by[[1L]],by[[2L]],by[[3L]],w,na.rm,fill,TRUE), ax))
    }
  } else if(!is.null(cols)) {
    ax <- attributes(x)
    x <- if(is.function(cols)) unclass(x)[vapply(x, cols, TRUE)] else unclass(x)[cols]
    ax[["names"]] <- names(x)
    setattributes(x, ax)
  }
  if(is.character(stub)) names(x) <- paste0(stub, names(x))

  if(is.null(by)) return(BWlCpp(x,0L,0L,NULL,w,na.rm,fill,TRUE)) else if (is.atomic(by)) {
    if(is.factor(by)) return(BWlCpp(x,fnlevels(by),by,NULL,w,na.rm,fill,TRUE)) else {
      by <- qG(by, ordered = FALSE)
      return(BWlCpp(x,attr(by,"N.groups"),by,NULL,w,na.rm,fill,TRUE))
    }
  } else {
    if(!is.GRP(by)) by <- GRP(by, return.groups = FALSE)
    return(BWlCpp(x,by[[1L]],by[[2L]],by[[3L]],w,na.rm,fill,TRUE))
  }
}





# Previous Versions: also allow column indices and names, and properly adding (keeping) w to data -> updated code innovated in fscale.R
# W.grouped_df <- function(x, w = NULL, na.rm = TRUE, add.global.mean = FALSE, give.names = FALSE, keep.group_vars = TRUE, drop.w = TRUE, ...) {
#   g <- GRP.grouped_df(x)
#   wsym <- deparse(substitute(w))
#   nam <- names(x)
#   gn <- match(names(g[[4L]]), nam)
#   gn2 = gn <- gn[!is.na(gn)]
#   if(!(wsym == "NULL" || is.na(wn <- match(wsym, nam)))) {
#     w <- x[[wn]]
#     if(any(gn == wn)) stop("Weights coincide with grouping variables!")
#     if(drop.w) if(!length(gn)) x[[wn]] <- NULL else if(keep.group_vars) gn <- c(gn,wn) else gn2 <- c(gn2,wn)
#   }
#   if(length(gn)) {
#     if(keep.group_vars)
#       return(give_nam(BWlCpp(x[-gn],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean), give.names)) else {
#         ax <- attributes(x)
#         attributes(x) <- NULL
#         ax[["names"]] <- c(nam[gn], if(give.names) paste0("W.",nam[-gn2]) else nam[-gn2])
#         return(`attributes<-`(c(x[gn],BWlCpp(x[-gn2],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)), ax))
#       }
#   } else return(give_nam(BWlCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean), give.names))
# }
# W.pdata.frame <- function(X, effect = 1L, w = NULL, Xcols = is.numeric, na.rm = TRUE, add.global.mean = FALSE, give.names = FALSE, drop.xt = FALSE, drop.w = TRUE, ...) {
#   ax <- attributes(X)
#   nam <- ax[["names"]]
#   gn <- match(names(ax[["index"]]), nam)
#   gn2 = gn <- gn[!is.na(gn)]
#   g <- if(length(effect) == 1L) ax[["index"]][[effect]] else interaction(ax[["index"]][effect], drop = TRUE)
#   if(!is.null(Xcols)) {
#     if(is.function(Xcols)) Xcols <- seq_along(X)[!vapply(X, Xcols, TRUE)] else if(is.character(Xcols))
#       Xcols <- seq_along(X)[-match(Xcols, nam)] else if(is.logical(Xcols))
#         Xcols <- seq_along(X)[!Xcols] else if(is.numeric(Xcols))
#           Xcols <- seq_along(X)[-Xcols] else stop("Xcols needs to be a function, column names, indices or a logical vector")
#         if(drop.xt) gn <- c(gn, Xcols) else if(length(gn)) gn2 <- c(gn2, Xcols) else gn <- Xcols
#   }
#   if(!is.null(w)) {
#     if(is.call(w)) w <- all.vars(w)
#     if(length(w) == 1) {
#       wn <- match(w, nam)
#       if(any(gn == wn)) stop("Weights coincide with grouping variables!")
#       w <- X[[wn]]
#       if(drop.w) if(!length(gn)) X[[wn]] <- NULL else if(drop.xt) gn <- c(gn,wn) else gn2 <- c(gn2,wn)
#     }
#   }
#   if(length(gn)) {
#     if(drop.xt)
#       return(give_nam(BWlCpp(X[-gn],fnlevels(g),g,NULL,w,na.rm,add.global.mean), give.names)) else {
#         attributes(X) <- NULL
#         ax[["names"]] <- c(nam[gn], if(give.names) paste0("W.",nam[-gn2]) else nam[-gn2])
#         return(`attributes<-`(c(X[gn],BWlCpp(X[-gn2],fnlevels(g),g,NULL,w,na.rm,add.global.mean)), ax))
#       }
#   } else return(give_nam(BWlCpp(X,fnlevels(g),g,NULL,w,na.rm,add.global.mean), give.names))
# }
# W.data.frame <- function(X, xt = NULL, w = NULL, Xcols = is.numeric, na.rm = TRUE,
#                          add.global.mean = FALSE, give.names = FALSE, drop.xt = FALSE, drop.w = TRUE, ...) {
#   if(!is.null(w)) {
#     if(is.call(w)) w <- all.vars(w)
#     if(length(w) == 1) {
#       v <- w
#       w <- X[[w]]
#       if(drop.w) X[[v]] <- NULL
#     }
#   }
#   if(is.null(xt)) {
#     if(is.null(Xcols)) return(give_nam(BWlCpp(X,0L,0L,NULL,w,na.rm,add.global.mean), give.names)) else {
#       if(is.function(Xcols)) Xcols <- vapply(X, Xcols, TRUE)
#       return(give_nam(BWlCpp(X[Xcols],0L,0L,NULL,w,na.rm,add.global.mean), give.names))
#     }
#   } else if (is.atomic(xt) || is.call(xt)) {
#     if(is.call(xt) || length(xt) != nrow(X)) {
#       nam <- names(X)
#       if(is.call(xt) && length(xt) == 3) {
#         v <- match(all.vars(xt[[2L]]), nam)
#         xt <- match(all.vars(xt[[3L]]), nam)
#       } else {
#         if(is.call(xt)) xt <- match(all.vars(xt), nam) else if(is.character(xt)) xt <- match(xt, nam)
#         v <- if(is.null(Xcols)) seq_along(X)[-xt] else if(is.function(Xcols))
#           setdiff(which(vapply(X, Xcols, TRUE)), xt) else if(is.character(Xcols))
#             match(Xcols, nam) else Xcols
#       }
#       g <- GRP(X, xt, return.groups = FALSE)
#       if(drop.xt)
#         return(give_nam(BWlCpp(X[v],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean), give.names)) else {
#           ax <- attributes(X)
#           ax[["names"]] <- c(nam[xt], if(give.names) paste0("W.", nam[v]) else nam[v])
#           attributes(X) <- NULL
#           return(`attributes<-`(c(X[xt],BWlCpp(X[v],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)), ax))
#         }
#     } else if(is.factor(xt)) return(give_nam(BWlCpp(X,fnlevels(xt),xt,NULL,w,na.rm,add.global.mean), give.names)) else {
#       xt <- qG(xt, ordered = FALSE)
#       return(give_nam(BWlCpp(X,attr(xt,"N.groups"),xt,NULL,w,na.rm,add.global.mean), give.names))
#     }
#   } else {
#     if(!all(class(xt) == "GRP")) xt <- GRP(xt, return.groups = FALSE)
#     if(is.null(Xcols)) return(give_nam(BWlCpp(X,xt[[1L]],xt[[2L]],xt[[3L]],w,na.rm,add.global.mean), give.names)) else {
#       if(is.function(Xcols)) Xcols <- vapply(X, Xcols, TRUE)
#       return(give_nam(BWlCpp(X[Xcols],xt[[1L]],xt[[2L]],xt[[3L]],w,na.rm,add.global.mean), give.names))
#     }
#   }
# }




# OLD / Experimental:
# W.pdata.frame <- function(x, w = NULL, Xcols = is.numeric, na.rm = TRUE, add.global.mean = FALSE, give.names = FALSE, drop.xt = FALSE, drop.w = TRUE, ...) {
#   g <- attr(x, "index")[[1L]]
#   res <- BWlCpp(x,fnlevels(g),g,NULL,w,na.rm,add.global.mean)
#   if(give.names) attr(res, "names") <- paste0("W.", attr(res, "names"))
#   return(res)
# }
# W.data.frame <- function(x, g = NULL, w = NULL, na.rm = TRUE, add.global.mean = FALSE, give.names = FALSE, ...) {
#   if(is.null(g)) res <- BWlCpp(x,0L,0L,NULL,w,na.rm,add.global.mean) else if (is.atomic(g)) {
#     if(is.factor(g)) res <- BWlCpp(x,fnlevels(g),g,NULL,w,na.rm,add.global.mean) else {
#       g <- qG(g, ordered = FALSE)
#       res <- BWlCpp(x,attr(g,"N.groups"),g,NULL,w,na.rm,add.global.mean)
#     }
#   } else {
#     if(!is.GRP(g)) g <- GRP(g, return.groups = FALSE)
#     res <- BWlCpp(x,g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)
#   }
#   if(give.names) attr(res, "names") <- paste0("W.", attr(res, "names"))
#   return(res)
# }
# W.data.frame2 <- function(X, xt = NULL, w = NULL, Xcols = is.numeric, na.rm = TRUE, add.global.mean = FALSE, give.names = FALSE, drop.xt = FALSE, ...) {
#   if(!is.null(xt) && is.atomic(xt) && length(xt) != nrow(X)) {
#     xtind <- TRUE
#     xt <- unclass(X)[xt]
#   } else if(is.call(xt)) {
#     xtind <- TRUE
#     if(length(xt) == 3) {
#       v <- all.vars(xt[[2L]])
#       xt <- GRP(unclass(X)[all.vars(xt[[3L]])],  return.groups = FALSE)
#       X <- X[v]
#       Xcols = NULL
#     } else {
#       v <- all.vars(xt)
#       xt <- GRP(unclass(X)[v],  return.groups = FALSE)
#       X <- X[-match(v,names(X))]
#     }
#   } else xtind <- FALSE
#   if(!is.null(Xcols)) X <- if(is.function(Xcols)) X[vapply(X, Xcols, TRUE)] else X[Xcols]
#
#   if(is.null(xt)) res <- BWlCpp(X,0L,0L,NULL,w,na.rm,add.global.mean) else if (is.atomic(xt)) {
#     if(is.factor(xt)) res <- BWlCpp(X,fnlevels(xt),xt,NULL,w,na.rm,add.global.mean) else {
#       xt <- qG(xt, ordered = FALSE)
#       res <- BWlCpp(X,attr(xt,"N.groups"),xt,NULL,w,na.rm,add.global.mean)
#     }
#   } else {
#     if(!all(class(xt) == "GRP")) xt <- GRP(xt, return.groups = FALSE)
#     res <- BWlCpp(X,xt[[1L]],xt[[2L]],xt[[3L]],w,na.rm,add.global.mean)
#   }
#   if(give.names) attr(res, "names") <- paste0("W.", attr(res, "names"))
#   if(xtind && !drop.xt) {
#     ar <- attributes(res)
#     res <- c(xt, res)
#     ar[["names"]] <- c(names(xt), ar[["names"]])
#     attributes(res) <- ar
#   }
#   return(res)
# }
#
# W.data.frame3 <- function(X, xt = NULL, w = NULL, Xcols = is.numeric, na.rm = TRUE, add.global.mean = FALSE, give.names = FALSE, drop.xt = FALSE, ...) {
#   if(is.null(xt)) {
#     if(is.null(Xcols)) res <- BWlCpp(X,0L,0L,NULL,w,na.rm,add.global.mean) else {
#       if(is.function(Xcols)) Xcols <- vapply(X, Xcols, TRUE)
#       res <- BWlCpp(X[Xcols],0L,0L,NULL,w,na.rm,add.global.mean)
#     }
#     if(give.names) attr(res, "names") <- paste0("W.", attr(res, "names"))
#     return(res)
#   } else if (is.atomic(xt)) {
#     if(length(xt) != nrow(X)) {
#       if(is.character(xt)) xt <- match(xt, names(X))
#       g <- GRP(X, xt, return.groups = FALSE) # best ??
#       if(!is.null(Xcols)) xt <- if(is.function(Xcols)) unique.default(c(xt, which(!vapply(X, Xcols, TRUE)))) else
#         c(xt, if(is.character(Xcols)) setdiff(names(X), Xcols) else names(X)[-Xcols])
#       if(drop.xt) {
#         res <- BWlCpp(X[-xt],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)
#         if(give.names) attr(res, "names") <- paste0("W.", attr(res, "names"))
#         return(res)
#       } else {
#         ax <- attributes(X)
#         ax[["names"]] <- c(ax[["names"]][xt], if(give.names) paste0("W.", ax[["names"]][-xt]) else ax[["names"]][-xt]) # best !!
#         attributes(X) <- NULL
#         return(`attributes<-`(c(X[xt], BWlCpp(X[-xt],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)), ax))
#       }
#     } else if(is.factor(xt)) res <- BWlCpp(X,fnlevels(xt),xt,NULL,w,na.rm,add.global.mean) else {
#       xt <- qG(xt, ordered = FALSE)
#       res <- BWlCpp(X,attr(xt,"N.groups"),xt,NULL,w,na.rm,add.global.mean)
#     }
#   } else if(is.call(xt)) {
#     nam <- names(X)
#     if(length(xt) == 3) {
#       v <- match(all.vars(xt[[2L]]), nam)
#       xt <- match(all.vars(xt[[3L]]), nam)
#     } else {
#       xt <- match(all.vars(xt), nam)
#       v <- if(is.null(Xcols)) seq_along(X)[-xt] else if(is.function(Xcols))
#         setdiff(which(vapply(X, Xcols, TRUE)), xt) else if(is.character(Xcols))
#           match(Xcols, nam) else Xcols
#     }
#     g <- GRP(X, xt, return.groups = FALSE)
#     if(drop.xt) {
#       res <- BWlCpp(X[v],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)
#       if(give.names) attr(res, "names") <- paste0("W.", attr(res, "names"))
#       return(res)
#     } else {
#       ax <- attributes(X)
#       ax[["names"]] <- c(nam[xt], if(give.names) paste0("W.", nam[v]) else nam[v])
#       attributes(X) <- NULL
#       return(`attributes<-`(c(X[xt],BWlCpp(X[v],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)), ax))
#     }
#   } else {
#     if(!all(class(xt) == "GRP")) xt <- GRP(xt, return.groups = FALSE)
#     res <- BWlCpp(X,xt[[1L]],xt[[2L]],xt[[3L]],w,na.rm,add.global.mean)
#     if(give.names) attr(res, "names") <- paste0("W.", attr(res, "names"))
#     return(res)
#   }
# }
#
# give_nam <- function(x, gn) {
#   if(!gn) return(x)
#   attr(x, "names") <- paste0("W.", attr(x, "names"))
#   x
# }
#
# W.data.frame4 <- function(X, xt = NULL, w = NULL, Xcols = is.numeric, na.rm = TRUE,
#                           add.global.mean = FALSE, give.names = FALSE, drop.xt = FALSE, ...) {
#   if(is.null(xt)) {
#     if(is.null(Xcols)) return(give_nam(BWlCpp(X,0L,0L,NULL,w,na.rm,add.global.mean), give.names)) else {
#       if(is.function(Xcols)) Xcols <- vapply(X, Xcols, TRUE)
#       return(give_nam(BWlCpp(X[Xcols],0L,0L,NULL,w,na.rm,add.global.mean), give.names))
#     }
#   } else if (is.atomic(xt) || is.call(xt)) {
#     if(is.call(xt) || length(xt) != nrow(X)) {
#       nam <- names(X)
#       if(is.call(xt) && length(xt) == 3) {
#         v <- match(all.vars(xt[[2L]]), nam)
#         xt <- match(all.vars(xt[[3L]]), nam)
#       } else {
#         if(is.call(xt)) xt <- match(all.vars(xt), nam) else if(is.character(xt)) xt <- match(xt, nam)
#         v <- if(is.null(Xcols)) seq_along(X)[-xt] else if(is.function(Xcols))
#           setdiff(which(vapply(X, Xcols, TRUE)), xt) else if(is.character(Xcols))
#             match(Xcols, nam) else Xcols
#       }
#       g <- GRP(X, xt, return.groups = FALSE)
#       if(drop.xt)
#         return(give_nam(BWlCpp(X[v],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean), give.names)) else {
#           ax <- attributes(X)
#           ax[["names"]] <- c(nam[xt], if(give.names) paste0("W.", nam[v]) else nam[v])
#           attributes(X) <- NULL
#           return(`attributes<-`(c(X[xt],BWlCpp(X[v],g[[1L]],g[[2L]],g[[3L]],w,na.rm,add.global.mean)), ax))
#         }
#     } else if(is.factor(xt)) return(give_nam(BWlCpp(X,fnlevels(xt),xt,NULL,w,na.rm,add.global.mean), give.names)) else {
#       xt <- qG(xt, ordered = FALSE)
#       return(give_nam(BWlCpp(X,attr(xt,"N.groups"),xt,NULL,w,na.rm,add.global.mean), give.names))
#     }
#   } else {
#     if(!all(class(xt) == "GRP")) xt <- GRP(xt, return.groups = FALSE)
#     if(is.null(Xcols)) return(give_nam(BWlCpp(X,xt[[1L]],xt[[2L]],xt[[3L]],w,na.rm,add.global.mean), give.names)) else {
#       if(is.function(Xcols)) Xcols <- vapply(X, Xcols, TRUE)
#       return(give_nam(BWlCpp(X[Xcols],xt[[1L]],xt[[2L]],xt[[3L]],w,na.rm,add.global.mean), give.names))
#     }
#   }
# }
#