#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#packages <- c("shiny","shinyFiles")

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Verde River Wild and Scenic River Riverine Environmental Flow Decision Support System (REFDSS)"),
   
   # Sidebar where inputs will go 
   sidebarLayout(position = "right",
      sidebarPanel(h3("Inputs"),
                   textInput("reachName","Reach Name"),
                   fileInput("hydrograph","Hydrograph of Flow Scenario (.csv)"),
                   shinyDirButton("wd","Select Folder","Choose Working Directory")),
      
      # Main panel with description of DSS
      mainPanel(
         h3("Description"),
         p("This app will synthesize hydraulic models, habitat suitability criteria, flow scenarios,
           and other model outputs in support of environmental flow decisions."),
         h3("Instructions")
      )
   ),
   tabsetPanel(
     tabPanel("Fish","Contents")
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  shinyDirChoose(input,"wd")
  
}

# Run the application 
shinyApp(ui = ui, server = server)

