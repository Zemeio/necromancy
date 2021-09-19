## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
export var grid: Resource

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}
var _active_unit: Unit
var _targetable_cells := []

onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _unit_path: UnitPath = $UnitPath
onready var _characters = $Characters
onready var _attack_button = $Action/Attack


enum Action {
	attack
	move
	nop
}

onready var selected_action = Action.move


func _ready() -> void:
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()


func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return _units.has(cell)


## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	return [unit.cell] + _flood_fill(unit.cell, unit.move_range)["empty_cells"]


## Returns an array of cells a given unit can attack using the flood fill algorithm.
func get_attackable_cells(unit: Unit, attack: Attack) -> Array:
	return _flood_fill(unit.cell, attack.attack_range)["all_cells"]


## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()

	for child in _characters.get_children():
		var character := child as Character
		if not character: continue
		var units = character.get_node("BoardUnits").get_children()
		for unit_child in units:
			var unit := unit_child as Unit
			if not unit:
				continue
			_units[unit.cell] = unit


## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int, ignore_obstacles = false) -> Dictionary:
	var all_cells := []
	var empty_cells := []
	var occupied_cells := []
	var stack := [cell]
	while not stack.empty():
		var current = stack.pop_back()
		if not grid.is_within_bounds(current):
			continue
		if current in all_cells:
			continue

		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		all_cells.append(current)
		if is_occupied(current):
			occupied_cells.append(current)
		else:
			empty_cells.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				if not ignore_obstacles:
					continue
			if coordinates in all_cells:
				continue

			stack.append(coordinates)
	return {
		all_cells = all_cells,
		empty_cells = empty_cells,
		occupied_cells = occupied_cells
	}


## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	if not selected_action == Action.move:
		return

	if is_occupied(new_cell) or not new_cell in _targetable_cells:
		return
	# warning-ignore:return_value_discarded
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.current_path)
	yield(_active_unit, "walk_finished")
	_clear_active_unit()


## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return

	_active_unit = _units[cell]
	_active_unit.is_selected = true
	_targetable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_targetable_cells)
	_unit_path.initialize(_targetable_cells)
	_attack_button.disabled = false
	selected_action = Action.move


## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


## Clears the reference to the _active_unit and the corresponding walkable cells.
func _clear_active_unit() -> void:
	_active_unit = null
	_targetable_cells.clear()
	selected_action = Action.nop
	_attack_button.disabled = true


## Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_active_unit(cell)


## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)


func _on_Attack_pressed():
	if not _active_unit:
		return
	
	_targetable_cells = get_attackable_cells(_active_unit, _active_unit.UnitInfo.main_attack)
	_unit_overlay.draw(_targetable_cells)
	selected_action = Action.attack
