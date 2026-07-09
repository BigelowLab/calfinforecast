suppressPackageStartupMessages({
  library(calfinforecast)
  library(shiny)
  library(bslib)
  library(bigelowshinytheme)
  library(dplyr)
})

# bigelowshinytheme::copy_www(dest = "inst/shiny")

IMAGEFILES = calfinforecast::list_images("daily")
DATES = names(IMAGEFILES) |> as.Date()
DATE = Sys.Date()
ORIGIN = as.Date("1970-01-01")
##### UI ######

ui <- shiny::fluidPage(
  theme = bigelowshinytheme::bigelow_theme(),
  includeCSS("www/additionalStyles.css"),
  
  # Header
  bigelowshinytheme::bigelow_header(
    h2("Calanus finmarchicus (Cfin) Forecast"), 
    h6("Cape Hatteras to Flemish Cap")),
  
  # Main content
  bigelowshinytheme::bigelow_main_body(
    # Introduction
    p("Cfin forecast for the likely appearance of a patch of high abundance using Coperncius data layers"),
    br(),
    
    bigelowshinytheme::bigelow_card(
      headerContent = "Patch Likelihood", 
      footerContent = NULL, 
      sliderInput("dateSlider",
                  label = "Date",
                  min = min(DATES), max = max(DATES),
                  value = DATE),
      plotOutput("imageOutput",
                  width = "25%",
                  height = "25%") ,
    bigelowshinytheme::bigelow_footer("Data courtesy of Copernicus Marine Data Store and Ecomon/AZMP")
    ) # card
  ) # main_body
) #fluidPage

server <- function(input, output, session) {
  
  output$imageOutput <- renderImage({
    
    width  <- session$clientData$imageOutput_width
    height <- session$clientData$imageOutput_height
    date =  as.Date(input$dateSlider, origin = ORIGIN) |> 
      format(format = "%Y-%m-%d")
    
    list(src = IMAGEFILES[date],
         width  = session$clientData$imageOutput_width,
         height = session$clientData$imageOutput_height,
         alt = paste("Date", date))
  }, delete = FALSE)
  
}

# Applying ggplot styling and render app
# bigelowshinytheme::bigelow_style_plots()
shinyApp(ui, server)

