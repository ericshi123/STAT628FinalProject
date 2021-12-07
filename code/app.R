# setwd("/Users/xintongshi/Desktop")

library(shiny)
library(shinythemes)
library(dplyr)
library(googleway)
library(ggplot2)
library(wordcloud2)

api_key <- "AIzaSyDf1PV2oOfqc0CbW0KUU9QP8k9HlgtJ3ns"
restaurants <- read.csv("all_restaurants.csv")
reviews <- read.csv("all_chains_cs_reviews.csv")
popeyes <- read.csv("cleaned_Popeyes.csv")
burgerking <- read.csv("cleaned_BurgerKing.csv")
kfc <- read.csv("cleaned_KFC.csv")
mcdonalds <- read.csv("cleaned_McDonalds.csv")
wendys <- read.csv("cleaned_Wendys.csv")
chickfila <- read.csv("cleaned_Chick_fil_A.csv")
carlsjr <- read.csv("cleaned_CarlsJr.csv")
all_ratings <- read.csv("all_review_rating.csv")
app_data <- read.csv("app_data.csv")

name = rep("Popeyes", nrow(popeyes))
popeyes_new = cbind(name,popeyes)
name1 = rep("KFC", nrow(kfc))
kfc_new = cbind(name1,kfc)
colnames(kfc_new) = colnames(popeyes_new)
name2 = rep("Wendy's", nrow(wendys))
wendys_new = cbind(name2,wendys)
colnames(wendys_new) = colnames(popeyes_new)
name3 = rep("Chick-fil-A", nrow(chickfila))
chickfila_new = cbind(name3,chickfila)
colnames(chickfila_new) = colnames(popeyes_new)
name4 = rep("Carl's Jr.", nrow(carlsjr))
carlsjr_new = cbind(name4,carlsjr)
colnames(carlsjr_new) = colnames(popeyes_new)
name5 = rep("McDonald's", nrow(mcdonalds))
mcdonalds_new = cbind(name5,mcdonalds)
colnames(mcdonalds_new) = colnames(popeyes_new)
name6 = rep("Burger King", nrow(burgerking))
burgerking_new = cbind(name6,burgerking)
colnames(burgerking_new) = colnames(popeyes_new)
tfidf = rbind(popeyes_new,kfc_new,wendys_new,chickfila_new,carlsjr_new,mcdonalds_new,burgerking_new)



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
                            tabPanel("Suggestions",h5(textOutput("suggest")),h5(textOutput("suggest_all"))), 
                            tabPanel("Review Keywords", wordcloud2Output('wordcloud2')), 
                            tabPanel("Star Ratings",plotOutput("hist"))
                        )
                    )
                ),
                
                tags$h1("Map of US Chicken Sandwich Restaurants"),
                fluidRow(
                    column(
                        width = 3,
                        uiOutput("select_var4")
                    ),
                    column(
                        width = 9,
                        google_mapOutput(outputId = "map")
                    )
                )
)

server <- function(input, output,session) {
    
    
    tab <- reactive({ 
        
        restaurants %>% 
            filter(name == input$var1)
        
    })

    
    
    
    output$select_var1 <- renderUI({
        
        selectizeInput('var1', 'Select Name', choices = c("select" = "", levels(app_data$name.x)))
        
    })
    
    output$select_var2 <- renderUI({
        req(input$var1)
        choice_var2 <- reactive({
            app_data %>%
                filter(name.x == input$var1) %>%
                pull(state) %>%
                as.character()

        })
        selectizeInput('var2', 'Select State', choices = c("select" = "", choice_var2()))

    })
    
    
    
    output$select_var3 <- renderUI({
        req(input$var1)
        req(input$var2)
        choice_var3 <- reactive({
            app_data %>% 
                filter(name.x == input$var1) %>% 
                filter(state == input$var2) %>%
                pull(address) %>% 
                as.character()
            
        })
        selectizeInput('var3', 'Select Restaurant', choices = c("select" = "", choice_var3()))
        
    })
    
    
    choice_var2 <- reactive({
        app_data %>%
            filter(name.x == input$var1) %>%
            pull(state) %>%
            as.character()
        
    })
    choice_var3 <- reactive({
        app_data %>% 
            filter(name.x == input$var1) %>% 
            filter(state == input$var2) %>%
            pull(address) %>% 
            as.character()
    })
    
    observeEvent(
        input$var1,
        updateSelectizeInput(session, "var2", "Select State", 
                          choices = choice_var2()))
    
    
    # Update as soon as Month gets populated according to the year and month selected
    observeEvent(
        input$var2,
        updateSelectInput(session, "var3", "Select Restaurant", 
                          choices = choice_var3()))
    
    hist_data <- reactive({ 
        
        new = app_data %>% 
            filter(name.x == input$var1)%>% 
            filter(state == input$var2)%>%
            filter(address == input$var3)
        return(new)
    })
    
    output$hist <- renderPlot({
        ggplot(hist_data(), aes(x=stars)) + 
            geom_histogram(binwidth=0.5) + 
            xlim(c(1,5))+ylim(c(0,10))+
            labs(x = "Stars", y = "count") +
            ggtitle("Star Ratings for this restaurant")
    }) 
    #word cloud data
    wc_data <- reactive({
        
        tfidf %>% 
            filter(name == input$var1) %>% 
            select(term,weight)
        
    })
    
    output$wordcloud2 <- renderWordcloud2({
        # wordcloud2(demoFreqC, size=input$size)
        wordcloud2(wc_data(),size = 0.5)
    })
    

    a = c("Popeyes","Employees are sometimes being described as rude. Reduce mistakes in orders. Keep the food warm.Reduce waiting time for customers. Understaffed.")
    b = c("KFC","Keep the food warm. Compared to Popeyes alot. Health concerns. Understaffed. Too greasy for some customers.")
    c = c("Wendy's","Sauces, especially Mayo needs improvement. Reduce mistakes in orders. Reduce waiting time. Sandwiches are sometimes described as dry.")
    d = c("Chick-fil-A","Reduce mistakes in orders. Breakfast are popular. Keep up the quality.")
    e = c("Carl's Jr.","Prices are expensive. Sauce are needs improvement.Bread are tough. Reduce waiting time for customers. Employee performance aren't satisfactory.")
    f = c("McDonald's","Sandwiches are dry. Sauces, especially mayo needs improvement. Need more staff. Employees are sometimes being described as rude. Reduce waiting time for customers. Reduce mistakes in orders.")
    g = c("Burger King","Reduce mistakes in orders. Make sure nothing is overcooked or burnt. Sauces, especially Mayo needs improvement. Sandwiches are too dry sometimes.")
    suggest_df = data.frame(rbind(a,b,c,d,e,f,g))
    colnames(suggest_df) = c("chain","suggestions")
    
    #reactive suggestions
    suggest_data <- reactive({
        suggest_df %>% 
            filter(chain == input$var1) %>% 
            pull(suggestions) %>% 
            as.character
    })
    output$suggest <- renderText({ suggest_data() })
    output$suggest_all <- renderText({ "We have found that the two largest areas of concern for guests that gave negative reviews about chicken sandwiches are about receiving a cold and soggy sandwich and/or having to wait in line. Our suggestion to eliminate these issues is to install a just in time kitchen system, so that sandwiches are not being waited for, but are not old, cold, or soggy. On the contrary, we can see that the most frequently used words in the best reviews are new, crispy, fast, and hot. Therefore, one other suggestion is to continue to introduce new menu items, as guests seem to be intrigued and like trying new items.
" })
    
    output$select_var4 <- renderUI({
        selectInput(inputId = "inputState", label = "Select state:", multiple = FALSE, choices = sort(restaurants$state), selected = "GA")
    })
    
    
    google_data <- reactive({
        req(input$inputState)
        restaurants %>%
            filter(state %in% input$inputState) %>%
            mutate(INFO = paste0(name, " | ", city, ", ", state," | ","stars:", stars, " | ","hours",hours))
    })
    output$map <- renderGoogle_map({
        google_map(data = google_data(), key = api_key) %>%
            add_markers(lat = "latitude", lon = "longitude", mouse_over = "INFO")
    })
    
}

shinyApp(ui = ui, server = server)