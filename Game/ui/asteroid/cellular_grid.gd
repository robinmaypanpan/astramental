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


## Returns the cell at the indicated row and column
func get_cell(row:int, col:int) -> Control:
	var child_index = col + row * _actual_cols	
	var child:Control = _grid_container.get_child(child_index)
	print("Requested %d,%d and got %s" % [row, col, child.name])
	return child
