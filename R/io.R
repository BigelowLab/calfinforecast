#' Retrieve the package data path
#' @export
#' @param ... file path segments to append to the root path
#' @param root the root data path
#' @return package data path
data_path = function(...,
  root =  "/mnt/s1/projects/ecocast/corecode/R/ecopmo_forecast/calfin_forecast/inst/extdata"){
  file.path(root, ...)
}

#' Read and write raster data
#' 
#' @export
#' @param x stars object
#' @param filename chr then name of the file
#' @return for `write_raster` and `read_raster` a stars object
write_raster = function(x, 
                        filename = data_path("data.Rds")){
  saveRDS(x, filename[1])
  invisible(x)
}

#' @rdname write_raster
#' @export
read_raster = function(filename = system.file("extdata/data.Rds",
                                              package = "calfinforecast")){
  readRDS(filename[1])
}


#' Read and write the config list
#' 
#' @export
#' @param x configuration list
#' @param filename chr then name of the file
#' @return for `write_config` and `read_config` a configuration list
write_config = function(x, 
                        filename = data_path("config.yaml")){
  yaml::write_yaml(x, filename[1])
  invisible(x)
}

#' @rdname write_config
#' @export
read_config = function(filename = system.file("extdata/config.yaml",
                                              package = "calfinforecast")){
    yaml::read_yaml(filename[1])
}


#' Read a coastline
#' 
#' Made with Natural Earth. Free vector and raster map data at naturalearthdata.com.
#'  
#' @export
#' @param filename str, the filename
#' @return sfc (geometry) object
read_coastline = function(filename = system.file("extdata/coastline.Rds",
                                                 package = "calfinforecast")){
  readRDS(filename[1])
}


#' Save graphics as PNGs
#' 
#' @export
#' @param x either a ggplot object (facte wrapped by time) or a list
#'   of daily graphics
#' @param path the path to write to
save_graphics = function(x = plot_forecast(),
                         path = data_path()){
  
  if (inherits(x, "ggplot")){
    # one item
    ofile = file.path(path, "wrapped.png")
    ggplot2::ggsave(ofile,
                    plot = x)
  } else {
    # a named list
    opath = file.path(path, "images")
    ok = lapply(names(x),
      function(nm){
        ofile = file.path(opath, sprintf("%s.png", nm))
        ggplot2::ggsave(ofile,
                        plot = x[[nm]])
      })
  }
  invisible(x)
}


#' List images
#' 
#' @export
#' @param what chr either "wrapped" (default) or "daily"
#' @param path chr the path to search
#' @param chr vector of files (possibly named)
list_images = function(what = c("wrapped", "daily")[1],
                       path = system.file("extdata", package = "calfinforecast")){
  
  switch(tolower(what[1]),
         "wrapped" = file.path(path, "wrapped.png"),
         "daily" = {
           files = list.files(file.path(path, "images"), full.names = TRUE)
           names(files) = gsub(".png", "", basename(files), fixed = TRUE)
           files
         },
         stop("what option not known: ", what[1]))
}