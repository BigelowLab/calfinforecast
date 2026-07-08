
# usage: copy_forecast.R [--] [--help] [--species SPECIES] [--version VERSION]
# 
# Copy a calfin forecast and make a graphic
# 
# flags:
#   -h, --help     show this help message and exit
# 
# optional arguments:
#   -s, --species  the species [default: calfin]
#   -v, --version  the version [default: v1.01]



suppressPackageStartupMessages({
  library(ecopmodb)
  library(dplyr)
  library(argparser)
  library(stars)
  library(charlier)
})

Args = argparser::arg_parser("Copy an ecomon forecast and make a graphic",
                             name = "copy_forecast.R", 
                             hide.opts = TRUE) |>
  add_argument("--species",
               help = "the species",
               default = "calfin",
               type = "character") |>  
  add_argument("--version",
               help = "the version",
               default = 'v1.01',
               type = "character") |>
  add_argument("--start_date",
               help = "the starting date",
               default = format(Sys.Date(), '%Y-%m-%d'),
               type = "character") |>
  add_argument("--path",
               help = "the destination path",
               default = "/mnt/ecocast/corecode/R/ecopmo_forecast/calfinforecast") |>
  add_argument("--crop",
               help = "the region to crop to, 'none' to skip cropping",
               default = "gom") |>
  parse_args()

OUTPATH = file.path(Args$path, "inst/extdata")
date = as.Date(Args$start_date, format = '%Y-%m-%d')
dates = seq(from = date - 5, to = date + 10, by = 'day')
CROP = Args$crop

cfg = ecopmodb::read_configuration(species = Args$species,
                                   version = Args$version)
#path = ecopmodb::version_path(cfg)
db  = ecopmodb::read_database(cfg) |>
  dplyr::filter(per == "day",
                type == "q050",
                .data$date %in% dates)

#' Copy the raw data 
#' @return stars object
copy_rawdata = function(db, cfg, outpath, crop){
  rawfiles = ecopmodb::compose_filename(db, cfg)
  s = stars::read_stars(rawfiles, 
                        along = list(time = db$date)) |>
    rlang::set_names("q050")
  if (crop[1] != "none") {
    cr = calfinforecast::get_bb(crop)
    s = sf::st_crop(s, cr)
  }
  calfinforecast::write_raster(s)
}

# Here rebuild and install the package then push
# the function looks outside of its own scope for variables - lazy, I know!
git = function(){
  devtools::document(Args$path)
  devtools::install(Args$path, upgrade = FALSE)
  
  orig = setwd(Args$path)
  
  # add
  ok = system("git add *")
  
  # commit
  date = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  msg = sprintf("git commit -a -m 'auto update %s'", date)
  ok = system(msg)
  
  # now push
  ok = system("git push origin main")
  setwd(orig)
  return(0)
}

if (!interactive()){
  s = copy_rawdata(db, cfg, OUTPATH, CROP)
  cfg = calfinforecast::write_config(cfg)
  gg = calfinforecast::plot_forecast(s,wrap = TRUE) |>
    calfinforecast::save_graphics()
  gg = calfinforecast::plot_forecast(s,wrap = FALSE) |>
    calfinforecast::save_graphics()
  r = git()
  quit(save = "no", status = r)
}
