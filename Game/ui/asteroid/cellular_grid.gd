class_name CellularGrid
extends Control
## This is a control that manages a building grid with a number of cells

## The scene that should be created when populating this grid
@export var cell_scene : PackedScene

var grid_height: int = 5
var grid_width: int = 5

@onready var grid_container: GridContainer = %GridContainer

## Sets the size of this grid to the indicated size
func generate_grid(new_grid_width:int, new_grid_height:int):
	grid_height = new_grid_height
	grid_width = new_grid_width

	grid_container.columns = new_grid_width

	## Clear the existing container first
	for child:Control in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()

	for r: int in range(new_grid_height):
		for c: int in range(new_grid_width):
			var cell = cell_scene.instantiate()
			cell.name = "Cell %d,%d" % [r, c]
			grid_container.add_child(cell)

## Returns an iterator over all cells
func all_cells() -> AllCellIterator:
	return AllCellIterator.new(self)


## Returns the cell at the indicated x and y position
func get_cell(x:int, y:int) -> Control:
	var child_index = x + y * grid_width
	var child:Control = grid_container.get_child(child_index)
	return child


## Returns the cell under the provided point
func get_cell_coordinates_at_local_point(point:Vector2i) -> Vector2i:
	var my_rect := get_rect()
	if not my_rect.has_point(point):
		return Vector2i(-1,-1)
	var cell_width: int = my_rect.size.x / grid_width
	var cell_height:int = my_rect.size.y / grid_height
	var result := Vector2i(point.x / cell_width, point.y / cell_height)
	return result

## This is an iterator that will iterate over all cells in this cellular grid.
class AllCellIterator:
	## Stores a reference to the grid we're iterating over.
	var grid: CellularGrid # TODO RPG: Is this actually Pass by reference??

	## Store the current column in the iterator
	var x := 0

	## Store the current row in the iterator
	var y := 0


	func _init(init_grid: CellularGrid):
		self.grid = init_grid


	## Using the example from the docs on creating your own iterators, this function will
	## determine if this iterator is done running or not. It is technically private and not
	## used by anything
	func should_continue():
		return y < self.grid.grid_height and self.grid.grid_width > 0

	## When this iterator starts running, this will initialize our x/y values.
	func _iter_init(_arg):
		x = 0
		y = 0
		return should_continue()


	## When this iterator looks for the next item in the list, it calls this function to
	## update the position of iteration and determine if we are done or not.
	func _iter_next(_arg):
		x += 1
		if x >= self.grid.grid_width:
			# Go to the next row
			x = 0
			y += 1
		return should_continue()


	## When the iterator goes to get any item in the list, this is how it gets it.
	func _iter_get(_arg):
		return grid.get_cell(x, y)
