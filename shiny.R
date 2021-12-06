setwd("/Users/xintongshi/Desktop")

library(shiny)
library(shinythemes)
library(dplyr)
library(googleway)
library(ggplot2)
library(wordcloud2)

api_key <- "AIzaSyDf1PV2oOfqc0CbW0KUU9QP8k9HlgtJ3ns"
restaurants <- read.csv("all_restaurants.csv")
reviews <- read.csv("all_chains_cs_reviews.csv")
popeyes_df <- read.csv("628_tfidf_csv/Popeyes.csv")
burgerking_df <- read.csv("628_tfidf_csv/BurgerKing.csv")
kfc_df <- read.csv("628_tfidf_csv/KFC.csv")
mcdonalds_df <- read.csv("628_tfidf_csv/McDonalds.csv")
wendys_df <- read.csv("628_tfidf_csv/Wendys.csv")
chickfila_df <- read.csv("628_tfidf_csv/Chick-fil-A.csv")
carlsjr_df <- read.csv("628_tfidf_csv/CarlsJr.csv")

ui <- fluidPage(theme=shinytheme("cosmo"),
  
  titlePanel("Chicken Sandwich Wars"),
  
  sidebarLayout(
    
    sidebarPanel(
      uiOutput("select_var1"),
      uiOutput("select_var2"),
      uiOutput("select_var3")
    ), 
    
    mainPanel(
      tabsetPanel(
        tabPanel("Plot"), 
        tabPanel("Review Keywords", wordcloud2Output('wordcloud2')), 
        tabPanel("Star Ratings",plotOutput("hist"))
      )
    )
  ),
  
  tags$h1("Map of US Chicken Sandwich Restaurants"),
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
  

  tab <- reactive({ 
    
    restaurants %>% 
      filter(name == input$var1)
    
  })
  
  hist_data <- reactive({ 
    
    new = reviews %>% 
      filter(name == input$var1)%>% 
      filter(state == input$var2)%>% 
      filter(business_id == input$var3)
    return(new)
  })
  
  
  
  output$select_var1 <- renderUI({
    
    selectizeInput('var1', 'Select Name', choices = c("select" = "", levels(restaurants$name)))
    
  })
  
  output$select_var2 <- renderUI({
    choice_var2 <- reactive({
      reviews %>% 
        filter(name == input$var1) %>% 
        pull(state) %>% 
        as.character()
      
    })
    selectizeInput('var2', 'Select State', choices = c("select" = "", choice_var2()))
    
  })
  
  output$select_var3 <- renderUI({
    choice_var3 <- reactive({
      reviews %>% 
        filter(name == input$var1) %>% 
        filter(state == input$var2) %>% 
        pull(business_id) %>% 
        as.character()
      
    })
    selectizeInput('var3', 'Select Restaurant', choices = c("select" = "", choice_var3()))
    
  })
  
  output$hist <- renderPlot({
    ggplot(hist_data(), aes(x=stars_y)) + 
      geom_histogram(binwidth=0.5) + 
      xlim(c(1,5))+ylim(c(0,10))+
      labs(x = "Stars", y = "count") +
      ggtitle("Star Ratings for this restaurant")
  }) 
  #word cloud data
  wc_data <- reactive({
    if(input$var1 == "Popeyes")
      res = popeyes_df[,c("term","weight")]
    
    else if(input$var1 == "KFC")
      res = kfc_df[,c("term","weight")]
    
    else if(input$var1 == "Wendy's")
      res = wendys_df[,c("term","weight")]
    
    else if(input$var1 == "Chick-fil-A")
      res = chickfila_df[,c("term","weight")]
    
    else if(input$var1 == "Carl's Jr.")
      res = carlsjr_df[,c("term","weight")]
    
    else if(input$var1 == "McDonald's")
      res = mcdonalds_df[,c("term","weight")]
    
    else(input$var1 == "Burger King")
      res = burgerking_df[,c("term","weight")]
    return(res)
  })
  
  output$wordcloud2 <- renderWordcloud2({
    # wordcloud2(demoFreqC, size=input$size)
    wordcloud2(wc_data())
  })
  
  
  
  data <- reactive({
    restaurants %>%
      filter(state %in% input$inputState) %>%
      mutate(INFO = paste0(name, " | ", city, ", ", state," | ","stars:", stars, " | ","hours",hours))
  })
  output$map <- renderGoogle_map({
    google_map(data = data(), key = api_key) %>%
      add_markers(lat = "latitude", lon = "longitude", mouse_over = "INFO")
  })
}

shinyApp(ui = ui, server = server)