library(RNeo4j)
library(shiny)
graph = startGraph("http://localhost:7474/db/data/")

users = getLabeledNodes(graph, "User")
users = sapply(users, function(u) u$name)
categories = getLabeledNodes(graph, "Category")
categories = sapply(categories, function(c) c$name)

shinyUI(navbarPage("DFW Food & Drink Finder",
  tabPanel("Recommend by Proximity",
     sidebarLayout(
       sidebarPanel(
         strong("Show me food & drink places in the following categories"),
         checkboxGroupInput("categories1",
                            label = "",
                            choices = categories,
                            selected = c("Coffee", "Bar")),
         strong("closest to gate"),
         numericInput("gate", 
                      label = "", 
                      value = 10),
         br(),
         strong("in terminal"),
         selectInput("terminal1", 
                     label = "", 
                     choices = list("A", "B", "C", "D", "E"),
                     selected = "A")
       ),
       mainPanel(
         h3("Query"),
         htmlOutput("proximity_query"),
         h3("Result"),
         tableOutput("proximity_result")
       )
     )
  ),
  tabPanel("Recommend by Friends",
     sidebarLayout(
       sidebarPanel(
         strong("Logged in as user:"),
         selectInput("user",
                     label = "",
                     choices = users,
                     selected = "Alice"),
         strong("Show me food & drink places in the following categories"),
         checkboxGroupInput("categories2",
                            label = "",
                            choices = categories,
                            selected = c("Coffee", "Bar")),
         strong("in terminal"),
         selectInput("terminal2", 
                     label = "", 
                     choices = list("A", "B", "C", "D", "E"),
                     selected = "A"),
         strong("that my friends like.")
       ),
       mainPanel(
         h3("Query"),
         htmlOutput("friends_query"),
         h3("Result"),
         tableOutput("friends_result")
       )
     )
  )
))