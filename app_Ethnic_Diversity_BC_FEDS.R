#When working properly, this Shiny app gives the user a chance to select one ethnocultural group, self identified
# from the 2021 census, and to highlight how many of each group lived within a specific riding ("Federal Electoral District")

library(shiny)
library(leaflet)
library(htmltools)
library(openxlsx)

ethnoculturalgroups = as.vector(read.xlsx("data_here/list_of_nationalities.xlsx"))



# Define UI for application that draws a histogram
ui <- fluidPage(
    # Application title
    titlePanel("BC Electoral Districts--Ethnic Groups"),
    
    
    #The user of the app selects the ethnocultural group to look up, here 
    sidebarPanel(
      selectizeInput(
        inputId = "selectedethnogroup",
        label = "Input an ethnocultural group", 
        choices = ethnoculturalgroups,
        selected = NULL, 
        multiple = FALSE, 
        width = '100%', 
        options = list(
          'plugins' = list('remove_button'),
          'create' = TRUE,
          'persist' = TRUE
        )
      )
    ),
    
    mainPanel(leafletOutput("BCFEDS"))
    
    
    
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$BCFEDS <- renderLeaflet(
    {
      #Moving the logic over here
     
      source("support_file_for_app.R")
      
      #Find what the user input is and use it to create a dataframe which has the distributions of the selected naitonal 
      #group across FEDs in British Columbia
      keyhere = input$selectedethnogroup
      #See the function in the source file 
      extracted_group_map = extract_bind_specific_group(nationalgroup = keyhere, mapdatainput = bc_fed_nova)
    
      #The standard code for a leafleft map
      BCFEDS <- leaflet()
      BCFEDS <- addTiles(BCFEDS)
      BCFEDS <- setView(BCFEDS, lng = -122.8, lat = 49.3, zoom = 8)
      BCFEDS <- addPolygons(data = extracted_group_map, map = BCFEDS)
      BCFEDS <- addMarkers(map = BCFEDS, lng = extracted_group_map$X , lat = extracted_group_map$Y, 
                           popup =  paste("In 2021, the estimated number of", keyhere, "in the district of ", extracted_group_map$ED_NAMEE, "was ", extracted_group_map$V12 ))
    }
  )

}

# Run the application 
shinyApp(ui = ui, server = server)
