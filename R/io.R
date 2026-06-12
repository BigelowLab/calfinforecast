#' Read and write raster data
#' 
#' @export
#' @param x stars object
#' @param filename chr then name of the file
#' @return for `write_raster` and `read_raster` a stars object
write_raster = function(x, 
                        filename = "/mnt/s1/projects/ecocast/corecode/R/ecopmo_forecast/calfin_forecast/inst/extdata/data.rds"){
  saveRDS(x, filename[1])
  invisible(x)
}

#' @rdname write_raster
#' @export
read_raster = function(filename = system.file("extdata/data.rds",
                                              package = "calfin_forecast")){
  readRDS(filename[1])
}


#' Read and write the config list
#' 
#' @export
#' @param x configuration list
#' @param filename chr then name of the file
#' @return for `write_config` and `read_config` a configuration list
write_config = function(x, 
                        filename = filename = "/mnt/s1/projects/ecocast/corecode/R/ecopmo_forecast/calfin_forecast/inst/extdata/config.yaml"){
  yaml::write_yaml(x, filename[1])
  invisible(x)
}

#' @rdname write_config
#' @export
read_raster = function(filename = system.file("extdata/config.yaml",
                                              package = "calfin_forecast")){
    yaml::read_yaml(filename[1])
}
