#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    # return a list of UI elements
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
    
}
