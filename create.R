library(RNeo4j)

options(stringsAsFactors = F)
terminal.a = read.csv("A.csv", na.strings = "")
terminal.b = read.csv("B.csv", na.strings = "")
terminal.c = read.csv("C.csv", na.strings = "")
terminal.d = read.csv("D.csv", na.strings = "")
terminal.e = read.csv("E.csv", na.strings = "")

data = rbind(terminal.a, 
             terminal.b, 
             terminal.c, 
             terminal.d, 
             terminal.e)

graph = startGraph("http://localhost:7474/db/data/")

addConstraint(graph, "Place", "name")
addConstraint(graph, "Terminal", "name")
addConstraint(graph, "Category", "name")
addIndex(graph, "Gate", "gate")

a = createNode(graph, "Terminal", name = "A")
b = createNode(graph, "Terminal", name = "B")
c = createNode(graph, "Terminal", name = "C")
d = createNode(graph, "Terminal", name = "D")
e = createNode(graph, "Terminal", name = "E")

# Terminal A has 39 gates.
for(i in 1:39) {
  gate = createNode(graph, "Gate", gate = i)
  createRel(gate, "IN_TERMINAL", a)
}

# Terminal B has 49 gates.
for(i in 1:49) {
  gate = createNode(graph, "Gate", gate = i)
  createRel(gate, "IN_TERMINAL", b)
}

# Terminal C has 39 gates.
for(i in 1:39) {
  gate = createNode(graph, "Gate", gate = i)
  createRel(gate, "IN_TERMINAL", c)
}

# Terminal D has 40 gates.
for(i in 1:40) {
  gate = createNode(graph, "Gate", gate = i)
  createRel(gate, "IN_TERMINAL", d)
}

# Terminal E has 38 gates.
for(i in 1:38) {
  gate = createNode(graph, "Gate", gate = i)
  createRel(gate, "IN_TERMINAL", e)
}

# Add food & drink places and their locations.
query = "
MERGE (p:Place {name:{place}})
MERGE (c:Category {name:{category}})
MERGE (g:Gate {gate:{gate}})-[:IN_TERMINAL]->(:Terminal {name:{terminal}})
MERGE (p)-[:IN_CATEGORY]->(c)
MERGE (p)-[r:AT_GATE]->(g)

FOREACH(a IN (CASE WHEN {additional_info} = 'NA' THEN [] ELSE [{additional_info}] END) |
  SET r.additional_info = a
)
"

tx = newTransaction(graph)

for(i in 1:nrow(data)) {
  appendCypher(tx,
               query,
               place = data$Name[i],
               category = data$Category[i],
               gate = data$Gate[i],
               terminal = data$Terminal[i],
               additional_info = data$Additional.Info[i])
}

commit(tx)

# Create ten pretend users.
addConstraint(graph, "User", "name")

createNode(graph, "User", name = "Alice")
createNode(graph, "User", name = "Bob")
createNode(graph, "User", name = "Charles")
createNode(graph, "User", name = "David")
createNode(graph, "User", name = "Elaine")
createNode(graph, "User", name = "Forrest")
createNode(graph, "User", name = "Greta")
createNode(graph, "User", name = "Hank")
createNode(graph, "User", name = "Ian")
createNode(graph, "User", name = "Jan")

# Create random friendships.
users = getLabeledNodes(graph, "User")
users = sapply(users, function(u) u$name)

query = "
MATCH (u1:User {name:{user1}})
MATCH (u2:User {name:{user2}})
MERGE (u1)-[:FRIENDS_WITH]-(u2)
"

x = 1:length(users)

for(i in x) {
  user1 = users[i]
  friends = sample(x[x != i], size = sample(3:5, size = 1))
  for(j in friends) {
    user2 = users[j]
    cypher(graph, 
           query, 
           user1 = user1, 
           user2 = user2)
  }
}

# Create random LIKES between Users and Places with random weights.
places = getLabeledNodes(graph, "Place")
places = sapply(places, function(p) p$name)

query = "
MATCH (u:User {name:{user}})
MATCH (p:Place {name:{place}})
MERGE (u)-[l:LIKES]->(p)
SET l.weight = {weight}
"

for(i in x) {
  user = users[i]
  likes = sample(1:length(places), size = sample(10:20, size = 1))
  for(j in likes) {
    place = places[j]
    weight = sample(1:10, size = 1)
    cypher(graph,
           query,
           user = user,
           place = place,
           weight = weight)
  }
}
