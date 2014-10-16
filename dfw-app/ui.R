library(RNeo4j)
library(shiny)
graph = startGraph("http://localhost:7474/db/data/")

# Get users, categories, and terminals.
users = getLabeledNodes(graph, "User")
users = sapply(users, function(u) u$name)
categories = getLabeledNodes(graph, "Category")
categories = sapply(categories, function(c) c$name)
terminals = getLabeledNodes(graph, "Terminal")
terminals = sapply(terminals, function(t) t$name)

shinyUI(navbarPage("DFW Food & Drink Finder",
  tabPanel("Recommend by Proximity",
     sidebarLayout(
       sidebarPanel(
         strong("Show me food & drink places in the following categories"),
         checkboxGroupInput("categories1",
                            label = "",
                            choices = categories,
                            selected = sample(categories, 3)),
         strong("closest to gate"),
         numericInput("gate", 
                      label = "", 
                      value = sample(1:30, 1)),
         br(),
         strong("in terminal"),
         selectInput("terminal1", 
                     label = "", 
                     choices = terminals,
                     selected = sample(terminals, 1))
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
                     selected = sample(users, 1)),
         strong("Show me food & drink places in the following categories"),
         checkboxGroupInput("categories2",
                            label = "",
                            choices = categories,
                            selected = sample(categories, 3)),
         strong("in terminal"),
         selectInput("terminal2", 
                     label = "", 
                     choices = terminals,
                     selected = sample(terminals, 1)),
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