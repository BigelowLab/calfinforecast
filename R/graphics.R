#' Plot a forecast
#' 
#' @export
#' @param x stars object
#' @param wrap logical, if TRUE create a facet wrapped single image, otherwise
#'   a list of ggplot objects are returned.  If only one time is provided in 
#'   x then this ignored and a list is returned
#' @param crop NULL or bbox to crop the data
#' @return either a single ggplot object (facet wrapped by time) or 
#'   a list of ggplot objects (one per unit of time)
plot_forecast = function(x = read_raster(),
                         wrap = TRUE,
                         crop = NULL){
  coastline = read_coastline()
  d = dim(x)
  if (length(d) == 2 || d[3] == 1) wrap = FALSE
  time = stars::st_get_dimension_values(s, "time")
  
  if (!is.null(crop)){
    coastline = sf::st_crop(coastline, crop)
    s = sf::st_crop(s, crop)
  }
  
  if (wrap){
    gg = ggplot2::ggplot() +
      stars::geom_stars(data = s,
                        na.action = na.omit) +
      viridis::scale_fill_viridis(limits = c(0,1)) + 
      ggplot2::geom_sf(data = coastline, color = "orange") + 
      ggplot2::labs(fill = "likelihood", x= "lon", y = "lat") + 
      ggplot2::facet_wrap(~time)
  } else {
    gg = lapply(seq_along(time),
                function(i){
                  ggplot2::ggplot() +
                    stars::geom_stars(data = dplyr::slice(s, "time", i),
                                      na.action = na.omit) +
                    viridis::scale_fill_viridis(limits = c(0,1)) + 
                    ggplot2::geom_sf(data = coastline, color = "orange") +  
                    ggplot2::labs(title = format(time[1], "%Y-%m-%d"),
                                  fill = "likelihood",
                                  x= "lon", y = "lat")
                })
    names(gg) = format(time, "%Y-%m-%d")
    
  }
  invisible(gg)
}