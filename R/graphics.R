#' Plot a forecast
#' 
#' @export
#' @param x stars object
#' @param wrap logical, if TRUE create a facet wrapped single image, otherwise
#'   a list of ggplot objects are returned.  If only one time is provided in 
#'   x then this ignored and a list is returned
#' @param crop NULL or bbox to crop the data
#' @param add_sites logical, if TRUE add site locations as open circles
#' @param add_zones logical, if TRUE add lobster zones
#' @return either a single ggplot object (facet wrapped by time) or 
#'   a list of ggplot objects (one per unit of time)
plot_forecast = function(x = read_raster(),
                         wrap = length(dim(x)) > 2,
                         crop = NULL,
                         add_sites = !wrap,
                         add_zones = add_sites){
  coastline = read_coastline()
  sites = read_dmr_gzmp()
  site_shape = "circle open"
  site_color = "white"
  zones = read_dmr_zones()
  zone_color = "gray"
  
    
  if (!is.null(crop)){
    coastline = sf::st_crop(coastline, crop)
    x = st_crop(x, crop)
  }
  
  if (length(dim(x)) == 2){
    time = as.Date("1776-07-02")
  } else {
    time = stars::st_get_dimension_values(x, "time")
  }

  
  if (wrap){
    gg = ggplot2::ggplot() +
      stars::geom_stars(data = x,
                        na.action = na.omit) +
      viridis::scale_fill_viridis(limits = c(0,1)) + 
      ggplot2::geom_sf(data = coastline, color = "orange") + 
      ggplot2::labs(fill = "likelihood", x= "lon", y = "lat") + 
      #ggplot2::coord_sf() + 
      ggplot2::facet_wrap(~time)
    if (add_zones){
      gg = gg + 
        ggplot2::geom_sf(data = zones,
                         color = zone_color)
    }
    if (add_sites){
      gg = gg + 
        ggplot2::geom_sf(data = sites, 
                         shape = site_shape, 
                         color = site_color)
    }
  } else {
    gg = lapply(seq_along(time),
                function(i){
                  g = ggplot2::ggplot() +
                    stars::geom_stars(data = dplyr::slice(x, "time", i),
                                      na.action = na.omit) +
                    viridis::scale_fill_viridis(limits = c(0,1)) + 
                    ggplot2::geom_sf(data = coastline, color = "orange") +  
                    ggplot2::labs(title = format(time[i], "%Y-%m-%d"),
                                  fill = "likelihood",
                                  x= "lon", y = "lat")# + 
                    #ggplot2::coord_sf()
                  if (add_zones){
                    g = g + 
                      ggplot2::geom_sf(data = zones,
                                       color = zone_color)
                  }
                  if (add_sites){
                    g = g + 
                      ggplot2::geom_sf(data = sites, 
                                       shape = site_shape, 
                                       color = site_color)
                  }
                  return(g)
                })
    names(gg) = format(time, "%Y-%m-%d")
  }
  invisible(gg)
}