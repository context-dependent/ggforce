#' Annotate areas with rectangles
#'
#' This geom lets you annotate sets of points via rectangles. The rectangles are
#' simply scaled to the range of the data and as with the the other
#' `geom_mark_*()` geoms expanded and have rounded corners.
#'
#' @inheritSection geom_mark_circle Annotation
#' @inheritSection geom_mark_circle Filtering
#' @section Aesthetics:
#' geom_mark_rect understand the following aesthetics (required aesthetics are
#' in bold):
#'
#' - **x**
#' - **y**
#' - filter
#' - label
#' - description
#' - color
#' - fill
#' - group
#' - size
#' - linetype
#' - alpha
#'
#' @inheritParams geom_mark_circle
#'
#' @author Thomas Lin Pedersen
#' @family mark geoms
#'
#' @name geom_mark_rect
#' @rdname geom_mark_rect
#'
#' @examples
#' ggplot(iris, aes(Petal.Length, Petal.Width)) +
#'   geom_mark_rect(aes(fill = Species, filter = Species != 'versicolor')) +
#'   geom_point()
NULL

#' @rdname ggforce-extensions
#' @format NULL
#' @usage NULL
#' @importFrom ggplot2 ggproto zeroGrob
#' @export
GeomMarkRect <- ggproto('GeomMarkRect', GeomShape,
    setup_data = function(self, data, params) {
        if (!is.null(data$filter)) {
            self$removed <- data[!data$filter, c('x', 'y', 'PANEL')]
            data <- data[data$filter, ]
        }
        do.call(rbind, lapply(split(data, data$group), function(d) {
            if (nrow(d) == 1) return(d)
            x_range <- range(d$x)
            y_range <- range(d$y)
            d_new <- data.frame(x = x_range[c(1, 1, 2, 2)],
                                y = y_range[c(1, 2, 2, 1)])
            d$x <- NULL
            d$y <- NULL
            unique(cbind(d_new, d[rep(1,4), ]))
        }))
    },
    draw_panel = function(self, data, panel_params, coord, expand = unit(5, 'mm'),
                          radius = unit(2.5, 'mm'),
                          label.margin = margin(2, 2, 2, 2, 'mm'),
                          label.width = NULL, label.minwidth = unit(50, 'mm'),
                          label.hjust = 0, label.buffer = unit(10, 'mm'),
                          label.fontsize = 12, label.family = '',
                          label.fontface = c('bold', 'plain'), label.fill = 'white',
                          label.colour = 'black', con.colour = 'black', con.size = 0.5,
                          con.type = 'elbow', con.linetype = 1, con.border = 'one',
                          con.cap = unit(3, 'mm'), con.arrow = NULL) {
        if (nrow(data) == 0) return(zeroGrob())

        coords <- coord$transform(data, panel_params)

        coords <- coords[order(coords$group), ]

        # For gpar(), there is one entry per polygon (not one entry per point).
        # We'll pull the first value from each group, and assume all these values
        # are the same within each group.
        first_idx <- !duplicated(coords$group)
        first_rows <- coords[first_idx, ]

        label <- NULL
        ghosts <- NULL
        if (!is.null(coords$label) || !is.null(coords$description)) {
            label <- first_rows
            is_ghost <- which(self$removed$PANEL == coords$PANEL[1])
            if (length(is_ghost) > 0) {
                ghosts <- self$removed[is_ghost, ]
                ghosts <- coord$transform(ghosts, panel_params)
                ghosts <- list(x = ghosts$x, y = ghosts$y)
            }
        }


        rectEncGrob(coords$x, coords$y, default.units = "native",
                 id = coords$group, expand = expand, radius = radius,
                 label = label, ghosts = ghosts,
                 mark.gp = gpar(
                     col = first_rows$colour,
                     fill = alpha(first_rows$fill, first_rows$alpha),
                     lwd = first_rows$size * .pt,
                     lty = first_rows$linetype
                 ),
                 label.gp = gpar(
                     col = label.colour,
                     fill = label.fill,
                     fontface = label.fontface,
                     fontfamily = label.family,
                     fontsize = label.fontsize
                 ),
                 con.gp = gpar(
                     col = con.colour,
                     fill = con.colour,
                     lwd = con.size * .pt,
                     lty = con.linetype
                 ),
                 label.margin = label.margin,
                 label.width = label.width,
                 label.minwidth = label.minwidth,
                 label.hjust = label.hjust,
                 label.buffer = label.buffer,
                 con.type = con.type,
                 con.border = con.border,
                 con.cap = con.cap,
                 con.arrow = con.arrow
        )
    },
    default_aes = GeomMarkCircle$default_aes
)
#' @rdname geom_mark_rect
#' @export
geom_mark_rect <- function(mapping = NULL, data = NULL, stat = "identity",
                           position = "identity", expand = unit(5, 'mm'),
                           radius = unit(2.5, 'mm'),
                           label.margin = margin(2, 2, 2, 2, 'mm'),
                           label.width = NULL, label.minwidth = unit(50, 'mm'),
                           label.hjust = 0, label.fontsize = 12, label.family = '',
                           label.fontface = c('bold', 'plain'), label.fill = 'white',
                           label.colour = 'black', label.buffer = unit(10, 'mm'),
                           con.colour = 'black', con.size = 0.5,
                           con.type = 'elbow', con.linetype = 1, con.border = 'one',
                           con.cap = unit(3, 'mm'), con.arrow = NULL, ...,
                           na.rm = FALSE, show.legend = NA, inherit.aes = TRUE) {
    layer(
        data = data,
        mapping = mapping,
        stat = stat,
        geom = GeomMarkRect,
        position = position,
        show.legend = show.legend,
        inherit.aes = inherit.aes,
        params = list(
            na.rm = na.rm,
            expand = expand,
            radius = radius,
            label.margin = label.margin,
            label.width = label.width,
            label.minwidth = label.minwidth,
            label.fontsize = label.fontsize,
            label.family = label.family,
            label.fontface = label.fontface,
            label.hjust = label.hjust,
            label.fill = label.fill,
            label.colour = label.colour,
            label.buffer = label.buffer,
            con.colour = con.colour,
            con.size = con.size,
            con.type = con.type,
            con.linetype = con.linetype,
            con.border = con.border,
            con.cap = con.cap,
            con.arrow = con.arrow,
            ...
        )
    )
}

# Helpers -----------------------------------------------------------------

rectEncGrob <- function(x = c(0, 0.5, 1, 0.5), y = c(0.5, 1, 0.5, 0), id = NULL,
                        id.lengths = NULL, expand = 0, radius = 0, concavity = 2,
                        label = NULL, ghosts = NULL, default.units = "npc",
                        name = NULL, mark.gp = gpar(), label.gp = gpar(),
                        con.gp = gpar(), label.margin = margin(), label.width = NULL,
                        label.minwidth = unit(50, 'mm'), label.hjust = 0,
                        label.buffer = unit(10, 'mm'), con.type = 'elbow', con.border = 'one',
                        con.cap = unit(3, 'mm'), con.arrow = NULL, vp = NULL) {
    mark <- shapeGrob(x = x, y = y, id = id, id.lengths = id.lengths,
                      expand = expand, radius = radius,
                      default.units = default.units, name = name, gp = mark.gp,
                      vp = vp)
    if (!is.null(label)) {
        label <- lapply(seq_len(nrow(label)), function(i) {
            grob <- labelboxGrob(label$label[i], 0, 0, label$description[i],
                                 gp = label.gp, pad = label.margin, width = label.width,
                                 min.width = label.minwidth, hjust = label.hjust)
            if (con.border == 'all') {
                grob$children[[1]]$gp$col = con.gp$col
                grob$children[[1]]$gp$lwd = con.gp$lwd
                grob$children[[1]]$gp$lty = con.gp$lty
            }
            grob
        })
        labeldim <- lapply(label, function(l) {
            c(convertWidth(grobWidth(l), 'mm', TRUE),
              convertHeight(grobHeight(l), 'mm', TRUE))
        })
        ghosts <- lapply(ghosts, unit, default.units)
    } else {
        labeldim <- NULL
    }
    gTree(mark = mark, label = label, labeldim = labeldim,
          ghosts = ghosts, con.gp = con.gp, con.type = con.type,
          con.cap = as_mm(con.cap, default.units), con.border = con.border,
          con.arrow = con.arrow, name = name, vp = vp, cl = 'rect_enc')
}
#' @importFrom grid makeContent setChildren gList
#' @export
makeContent.rect_enc <- function(x) {
    mark <- x$mark
    if (inherits(mark, 'shape')) mark <- makeContent(mark)
    if (!is.null(x$label)) {
        polygons <- Map(function(x, y) list(x = x, y = y),
                        x = split(as.numeric(mark$x), mark$id),
                        y = split(as.numeric(mark$y), mark$id))
        labels <- make_label(labels = x$label, dims = x$labeldim, polygons = polygons,
                             ghosts = x$ghosts, buffer = x$buffer, con_type = x$con.type,
                             con_border = x$con.border, con_cap = x$con.cap,
                             con_gp = x$con.gp, anchor_mod = 3, arrow = x$con.arrow)
        setChildren(x, do.call(gList, c(list(mark), labels)))
    } else {
        setChildren(x, gList(mark))
    }
}
