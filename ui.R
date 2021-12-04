#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)

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
)