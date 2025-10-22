class_name DirectedWeightedGraph

# Using an adjacency list representation. Each vertex is labelled by a string,
# and stores an array of all vertices it is adjacent to.
var edges_out_of: Dictionary[Variant, Array]
var weights: Dictionary[Variant, Array]

## Create a graph with no vertices and no edges.
func _init() -> void:
    edges_out_of = {}
    weights = {}


## Add a new vertex to the graph.
func add_vertex(vertex: Variant) -> void:
    edges_out_of[vertex] = []
    weights[vertex] = []


## Add a new edge to the graph.
func add_edge(start: Variant, end: Variant, weight: float) -> void:
    edges_out_of[start].append(end)
    weights[start].append(weight)


## Add a two way edge to the graph.
func add_two_way_edge(start: Variant, end: Variant, weight: float) -> void:
    add_edge(start, end, weight)
    add_edge(end, start, weight)


## Remove an edge in the graph if it exists.
func remove_edge(start: Variant, end: Variant) -> void:
    var end_vertices: Array[Variant] = edges_out_of[start]
    var index_to_remove = -1
    for index in range(end_vertices.size()):
        var end_vertex: Variant = end_vertices[index]
        if end_vertex == end:
            index_to_remove = index
            break

    if index_to_remove != -1:
        end_vertices.remove_at(index_to_remove)
        weights[start].remove_at(index_to_remove)


## Remove a vertex from the graph and all edges that point to that edge.
func remove_vertex(vertex: Variant) -> void:
    edges_out_of.erase(vertex)
    for other_tail_vertex in edges_out_of:
        remove_edge(other_tail_vertex, vertex)


## Determine if the given vertex is part of the graph.
func has_vertex(vertex: Variant) -> bool:
    return edges_out_of.has(vertex)
