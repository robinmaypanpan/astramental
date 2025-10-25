class_name DirectedWeightedGraph
extends Node
## Represent a directed weighted graph.

# Using an adjacency list representation. Each vertex is labelled by a string,
# and stores an array of all vertices it is adjacent to.

## Given a vertex, return all vertices adjacent to that vertex.
var edges_out_of: Dictionary[Variant, Array]
## Given a vertex, return the weights of all the edges leaving that vertex.
## The ith entry of weights corresponds to the ith entry of `edges_out_of`.
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
	weights.erase(vertex)
	for other_tail_vertex in edges_out_of:
		remove_edge(other_tail_vertex, vertex)


## Determine if the given vertex is part of the graph.
func has_vertex(vertex: Variant) -> bool:
	return edges_out_of.has(vertex)


## Get the weight of the given edge. If the edge doesn't exist, return 0.0.
func get_weight(start: Variant, end: Variant) -> float:
	if not has_vertex(start):
		return 0.0
	var index = edges_out_of[start].find(end)
	if index != -1:
		return weights[start][index]
	else:
		return 0.0


## Set the weight of the given edge to the new weight.
func set_weight(start: Variant, end: Variant, new_weight: float) -> void:
	if has_vertex(start):
		var index = edges_out_of[start].find(end)
		if index != -1:
			weights[start][index] = new_weight
