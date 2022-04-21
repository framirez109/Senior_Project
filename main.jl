using JuMP
using Graphs
using GLPK
using GraphPlot
using GraphIO
import Cairo
import Fontconfig

# Read the Petersen graph edge list in from the text file contained in this directory

graph = Graphs.loadgraph("cubic30.txt", "graph_key", GraphIO.EdgeListFormat())
 
# Convert the directed graph into a simple graph
graph = Graphs.SimpleGraph(graph)

# Draw the Petersen graph with vertex labels

GraphPlot.gplot(graph, nodelabel = 1:Graphs.nv(graph))
