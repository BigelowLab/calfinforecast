
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

Args = argparser::arg_parser("Copy a calfin forecast and make a graphic",
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
  parse_args()

OUTPATH = file.path(Args$path, "inst")
Args$date = as.Date(Args$date)
Args$depth = parse_argument(Args$depth)
Args$variable = parse_argument(Args$variable)
dates = c(Args$date - 5, Args$date + 10)
andpath = andreas::copernicus_path(Args$region)
mwpath = andreas::copernicus_path("mthw")

charlier::start_logger(file.path(mwpath, "log"))

MWDB = mthw::read_database(file.path(mwpath, Args$region)) |>
  dplyr::filter(depth %in% Args$depth, 
                name %in% Args$variable)
CDB = andreas::read_database(andpath, multi = TRUE) |>
  dplyr::ungroup() |>
  dplyr::filter(depth %in% Args$depth, 
                name %in% Args$variable, 
                period == "day") 

if(FALSE){
  key = tibble(region = Args$region[1],
               name = "temp",
               depth = "sur")
  grp = filter(MWDB,
               region == key$region,
               name == key$name,
               depth == key$depth)
}

# Here we perform the computations and saving the package data
# the function looks outside of its own scope for variables - lazy, I know!
main = function(){
  MWDB |>
    dplyr::group_by(region, name, depth) |>
    dplyr::group_map(
      function(grp, key){
        charlier::info("working on %s %s %s", 
                       key$region[1],
                       key$name[1],
                       key$depth[1])
        cdb = dplyr::filter(CDB,
                            name == key$name,
                            depth == key$depth)
        mwe = mthw::generate_wave(
          db = grp,
          dates = dates,
          region = key$region,
          cDB = cdb)
        mwd = mthw::encode_wave(mwe)
        filename = mthw_filename(region = key$region,
                                 variable = key$name,
                                 depth = key$depth)
        charlier::info("writing data %s", filename)
        write_raster(mwd, filename)
      }, .keep = TRUE)
  return(0)
}

# Here we make and save graphics (just for the date)
# the function looks outside of its own scope for variables - lazy, I know!
graphics = function() { 
  for (reg in Args$region){
    filename = mthw_filename(region = reg, 
                             variable = "temp",
                             depth = "sur",
                             path = OUTPATH)
    sstd = read_raster(filename) |>
      slice_date(Args$date)
    filename = mthw_filename(region = reg, 
                             variable = "sal",
                             depth = "sur",
                             path = OUTPATH)
    sssd = read_raster(filename) |>
      slice_date(Args$date)
    filename = mthw_filename(region = reg, 
                             variable = "temp",
                             depth = "bot",
                             path = OUTPATH)
    sbtd = read_raster(filename) |>
      slice_date(Args$date)
    
    
    gg = plot_mwd_list(list(sst = sstd, sss = sssd, sbt = sbtd), # tempd, sald,
                       title = sprintf("Marine Thermohaline Waves, %s",
                                       format(Args$date, "%Y-%m-%d")))
    filename = mthw_filename(region = reg, 
                             variable = "mwd",
                             depth = "sur-bot",
                             extension = ".png",
                             path = OUTPATH)
    charlier::info("writing graphics %s", filename)
    ggplot2::ggsave(filename, plot = gg)
  }
  return(0)
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
  r = main()
  if (r <= 0) r = graphics()
  if (r <= 0) r = git()
  quit(save = "no", status = r)
}
