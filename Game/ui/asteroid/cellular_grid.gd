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
func get_cell_under_local_point(point:Vector2i) -> Vector2i:
	var my_rect := get_rect()
	if not my_rect.has_point(point):
		return Vector2i(-1,-1)
	var cell_width: int = my_rect.size.x / _actual_cols
	var cell_height:int = my_rect.size.y / _actual_rows
	var result := Vector2i(point.x / cell_width, point.y / cell_height)
	return result


class AllCellIterator:
	var grid: CellularGrid
	var row := 0
	var col := 0
	var rows := 0
	var cols := 0


	func _init(grid: CellularGrid, rows, cols):
		self.grid = grid
		self.rows = rows
		self.cols = cols


	func should_continue():
		return row < rows and cols > 0


	func _iter_init(arg):
		row = 0
		col = 0
		return should_continue()


	func _iter_next(arg):
		col += 1
		if col >= cols:
			# Go to the next row
			col = 0
			row += 1
		return should_continue()


	func _iter_get(arg):
		return grid.get_cell(row, col)
