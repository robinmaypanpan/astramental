class_name CellularGrid
extends Control
## This is a control that manages a building grid with a number of cells

## The scene that should be created when populating this grid
@export var cell_scene : PackedScene

var _actual_rows: int = 5
var _actual_cols: int = 5

@onready var _grid_container: GridContainer = %GridContainer

## Sets the size of this grid to the indicated number of rows/cols
func generate_grid(rows:int, cols:int):
	_actual_rows = rows
	_actual_cols = cols

	_grid_container.columns = cols

	## Clear the existing container first
	for child:Control in _grid_container.get_children():
		_grid_container.remove_child(child)
		child.queue_free()

	for r: int in range(rows):
		for c: int in range(cols):
			var cell = cell_scene.instantiate()
			cell.name = "Cell %d,%d" % [r, c]
			_grid_container.add_child(cell)

## Returns an iterator over all cells
func all_cells() -> AllCellIterator:
	return AllCellIterator.new(self, _actual_rows, _actual_cols)


## Returns the cell at the indicated row and column
func get_cell(row:int, col:int) -> Control:
	var child_index = col + row * _actual_cols
	var child:Control = _grid_container.get_child(child_index)
	return child


## Returns the cell under the provided point
func get_cell_coordinates_at_local_point(point:Vector2i) -> Vector2i:
	var my_rect := get_rect()
	if not my_rect.has_point(point):
		return Vector2i(-1,-1)
	var cell_width: int = my_rect.size.x / _actual_cols
	var cell_height:int = my_rect.size.y / _actual_rows
	var result := Vector2i(point.x / cell_width, point.y / cell_height)
	return result

## This is an iterator that will iterate over all cells in this cellular grid.
class AllCellIterator:
	## Stores a reference to the grid we're iterating over.
	var grid: CellularGrid # TODO RPG: Is this actually Pass by reference??

	## Store the current row in the iterator
	var row := 0

	## Store the current column in the iterator
	var col := 0

	## Cache the number of rows in this grid
	var rows := 0

	## Cache the number of columns in this grid
	var cols := 0


	func _init(grid: CellularGrid, rows, cols):
		self.grid = grid
		self.rows = rows
		self.cols = cols


	## Using the example from the docs on creating your own iterators, this function will
	## determine if this iterator is done running or not. It is technically private and not
	## used by anything
	func should_continue():
		return row < rows and cols > 0

	## When this iterator starts running, this will initialize our row/col values.
	func _iter_init(_arg):
		row = 0
		col = 0
		return should_continue()


	## When this iterator looks for the next item in the list, it calls this function to
	## update the position of iteration and determine if we are done or not.
	func _iter_next(_arg):
		col += 1
		if col >= cols:
			# Go to the next row
			col = 0
			row += 1
		return should_continue()


	## When the iterator goes to get any item in the list, this is how it gets it.
	func _iter_get(_arg):
		return grid.get_cell(row, col)
