setwd("/Users/xintongshi/Desktop")

library(shiny)
library(shinythemes)
library(dplyr)
library(googleway)

api_key <- "AIzaSyDf1PV2oOfqc0CbW0KUU9QP8k9HlgtJ3ns"
restaurants <- read.csv("all_restaurants.csv")

ui <- fluidPage(theme=shinytheme("cosmo"),
  
  titlePanel("Chicken Sandwich Wars"),
  
  sidebarLayout(
    
    sidebarPanel(
      h3("Note the button is black. This is different from the previous app."),
      actionButton("button", "A button")
    ), 
    
    mainPanel(
      tabsetPanel(
        tabPanel("Plot"), 
        tabPanel("Summary"), 
        tabPanel("Table")
      )
    )
  ),
  h3("Using renderUI and uiOutput"),
  uiOutput("my_output_UI"),
  textInput("mytext", ""),
  actionButton("mybutton", "Click to add to selections"),
  
  tags$h1("US Chicken Sandwich Restaurants"),
  fluidRow(
    column(
      width = 3,
      selectInput(inputId = "inputState", label = "Select state:", multiple = TRUE, choices = sort(restaurants$state), selected = "GA")
    ),
    column(
      width = 9,
      google_mapOutput(outputId = "map")
    )
  )
)

server <- function(input, output) {
  
  output$my_output_UI <- renderUI({
    
    list(
      h4(style = "color:blue;", "My selection list"),
      selectInput(inputId = "myselect", label="", choices = selections)
    )
  })
  
  # initial selections
  selections <- c("Chick-fil-A", "Popeyes", "KFC", "Wendy's", "McDonald's", "Burger King", "Carl's Jr.")
  
  # use observe event to notice when the user clicks the button
  # update the selection list. Note the double assignment <<-
  observeEvent(input$mybutton,{
    selections <<- c(input$mytext, selections)
    updateSelectInput(session, "myselect", choices = selections, selected = selections[1])
  })
  
  
  data <- reactive({
    restaurants %>%
      filter(state %in% input$inputState) %>%
      mutate(INFO = paste0(name, " | ", city, ", ", state))
  })
  output$map <- renderGoogle_map({
    google_map(data = data(), key = api_key) %>%
      add_markers(lat = "latitude", lon = "longitude", mouse_over = "INFO")
  })
}

shinyApp(ui = ui, server = server)