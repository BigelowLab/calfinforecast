#' Plot a forecast
#' 
#' @export
#' @param x stars object
#' @param wrap logical, if TRUE create a facet wrapped single image, otherwise
#'   a list of ggplot objects are returned.  If only one time is provided in 
#'   x then this ignored and a list is returned
#' @return either a single ggplot object (facet wrapped by time) or 
#'   a list of ggplot objects (one per unit of time)
plot_forecast = function(x = read_raster(),
                         wrap = TRUE){
  coastline = read_coastline()
  d = dim(x)
  if (length(d) == 2 || d[3] == 1) wrap = FALSE
  time = stars::st_get_dimension_values(s, "time")
  
  if (wrap){
    gg = ggplot2::ggplot() +
      stars::geom_stars(data = s) +
      ggplot2::geom_sf(data = coastline, color = "orange") + 
      ggplot2::facet_wrap(~time)
  } else {
    gg = lapply(seq_along(time),
                function(i){
                  ggplot2::ggplot() +
                    stars::geom_stars(data = dplyr::slice(s, "time", i)) +
                    ggplot2::geom_sf(data = coastline, color = "orange") +  
                    ggplot2::labs(title = format(time[1], "%Y-%m-%d"))
                })
    names(gg) = format(time, "%Y-%m-%d")
    
  }
  invisible(gg)
}