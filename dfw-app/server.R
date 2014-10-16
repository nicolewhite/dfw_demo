library(RNeo4j)
library(rjson)
library(shiny)

graph = startGraph("http://localhost:7474/db/data/")

proximity_query = "
MATCH (p:Place)-[:IN_CATEGORY]->(c:Category),
      (p)-[:AT_GATE]->(g:Gate),
      (g)-[:IN_TERMINAL]->(t:Terminal)
WHERE c.name IN {categories} AND t.name = {terminal}
WITH p, c, g, t, ABS(g.gate - {gate}) AS dist
ORDER BY dist
RETURN p.name AS Name, c.name AS Category, g.gate AS Gate, t.name AS Terminal
"

friends_query = "
MATCH (p:Place)-[:IN_CATEGORY]->(c:Category),
      (p)-[:AT_GATE]->(g:Gate),
      (g)-[:IN_TERMINAL]->(t:Terminal)
WHERE c.name IN {categories} AND t.name = {terminal}
WITH p, c, g, t
MATCH (u:User)-[:FRIENDS_WITH]-(friend:User),
      (friend)-[:LIKES]->(p)
WHERE u.name = {user}
WITH p.name AS Name, COUNT(friend) AS friends, c.name AS Category, g.gate AS Gate, t.name AS Terminal
ORDER BY friends DESC, Name
RETURN Name, Category, Gate, Terminal
"

shinyServer(function(input, output) {
  output$proximity_query <- renderUI({
    # This is just for showing the query in HTML. This is not what a parameterized query looks like.
    # Just ignore this block.
    text = sprintf("<p style=\"font-family:courier\">
                    MATCH (p:Place)-[:IN_CATEGORY]->(c:Category),<br>
                          &nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp(p)-[:AT_GATE]->(g:Gate),<br>
                          &nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp(g)-[:IN_TERMINAL]->(t:Terminal)<br>
                    WHERE c.name IN %s AND t.name = %s<br>
                    WITH p, c, g, t, ABS(g.gate - %s) AS dist<br>
                    ORDER BY dist<br>
                    RETURN p.name AS Name, c.name AS Category, g.gate AS Gate, t.name AS Terminal
                    </p>
                    ", 
                   toJSON(as.list(input$categories1)), 
                   toJSON(input$terminal1), 
                   input$gate)
    HTML(text)
  })
  
  output$proximity_result <- renderTable({
    # This is a parameterized query. It's referring to proximity_query defined above.
    # See ?cypher in RNeo4j.
    data = cypher(graph, 
                  proximity_query,
                  categories = as.list(input$categories1),
                  terminal = input$terminal1,
                  gate = input$gate)
    if(is.null(data)){
      return(data)
    } else{
      data$Gate = as.integer(data$Gate)
      return(data)
    }
  })
  
  output$friends_query <- renderUI({
    # This is just for showing the query in HTML. This is not what a parameterized query looks like.
    # Just ignore this block.
    text = sprintf("<p style=\"font-family:courier\">
                    MATCH (p:Place)-[:IN_CATEGORY]->(c:Category),<br>
                    &nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp(p)-[:AT_GATE]->(g:Gate),<br>
                    &nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp(g)-[:IN_TERMINAL]->(t:Terminal)<br>
                    WHERE c.name IN %s AND t.name = %s<br>
                    WITH p, c, g, t<br>
                    MATCH (u:User)-[:FRIENDS_WITH]-(friend:User),<br>
                    &nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp(friend)-[:LIKES]->(p)<br>
                    WHERE u.name = %s<br>
                    WITH p.name AS Name, COUNT(friend) AS friends, c.name AS Category, g.gate AS Gate, t.name AS Terminal<br>
                    ORDER BY friends DESC<br>
                    RETURN Name, Category, Gate, Terminal
                   </p>",
                   toJSON(as.list(input$categories2)),
                   toJSON(input$terminal2),
                   toJSON(input$user))
    HTML(text)
  })
  
  output$friends_result <- renderTable({
    # This is a parameterized query. It's referring to friends_query defined above.
    # See ?cypher in RNeo4j.
    data = cypher(graph, 
                  friends_query,
                  categories = as.list(input$categories2),
                  terminal = input$terminal2,
                  user = input$user)
    if(is.null(data)){
      return(data)
    } else{
      data$Gate = as.integer(data$Gate)
      return(data)
    }
  })
}
)