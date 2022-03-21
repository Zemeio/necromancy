## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
export var grid: Resource

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _targetable_cells := []


onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _unit_path: UnitPath = $UnitPath
onready var _characters := $Characters
onready var _attack_button := $Action/Attack
onready var _turn_order: TurnOrder = $TurnOrder

enum Action {
	attack
	move
	nop
}

onready var selected_action = Action.move


func _ready() -> void:
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:
	if _characters.has_active_unit() and event.is_action_pressed("ui_cancel"):
		_characters.deselect_active_unit()
		_unit_overlay.clear()
		_unit_path.stop()
		_targetable_cells.clear()
		selected_action = Action.nop
		_attack_button.disabled = true


func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	# Map Control
	# TODO: Improve here to check if you can actually pass through the unit in this cell
	return _characters.has_unit_in_cell(cell)


## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	# Map Control
	return [unit.cell] + _flood_fill(unit.cell, unit.move_range)["empty_cells"]


## Returns an array of cells a given unit can attack using the flood fill algorithm.
func get_attackable_cells(unit: Unit, attack: Attack) -> Array:
	# Map Control
	# Occupied cells does not return the origin. If it did, it could be filtered here.
	return _flood_fill(unit.cell, attack.attack_range, true)["occupied_cells"]


## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_characters.initialize()
	_turn_order.initialize(_characters.get_units())
	start_first_turn()


func start_first_turn():
	var next_turn := _turn_order.current()
	_characters.enter_turn(next_turn)
	_enter_move_action_for_unit(next_turn)
	
	# cursor.set_cell precisa ser chamado aqui
	# Fim: turn_order.end_turn(wait)
	pass

## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int, ignore_obstacles = false) -> Dictionary:
	# Map Control
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
		if is_occupied(current) and current != cell:
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
		occupied_cells = occupied_cells,
		origin_cell = cell,
	}


## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_unit(unit: Unit, new_cell: Vector2) -> void:
	# Map Control
	if not selected_action == Action.move:
		return

	if is_occupied(new_cell) or not new_cell in _targetable_cells:
		return
	# warning-ignore:return_value_discarded
	_characters.move_unit_to_cell(unit, new_cell)
	_characters.deselect_active_unit()
	_unit_overlay.clear()
	_unit_path.stop()
	unit.walk_along(_unit_path.current_path)
	yield(unit, "walk_finished")
	# Clear active unit
	_characters.clear_active_unit()
	_targetable_cells.clear()
	selected_action = Action.nop
	_attack_button.disabled = true



## Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	# Map Control
	if not _characters.has_active_unit() or _characters.unit_once_cell_is_active(cell):
		var selected_unit = _characters.select_unit_on_cell(cell)
		if selected_unit != null:
			_enter_move_action_for_unit(selected_unit)
	elif _characters.active_unit_is_selected():
		_move_unit(_characters.get_active_unit(), cell)


func _enter_move_action_for_unit(unit):
	_targetable_cells = get_walkable_cells(unit)
	_unit_overlay.draw(_targetable_cells, _unit_overlay.TILE_TYPE.MOVE)
	_unit_path.initialize(_targetable_cells)
	_attack_button.disabled = false
	selected_action = Action.move

## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	# Map Control
	if _characters.active_unit_is_selected():
		_unit_path.draw(_characters.get_active_unit().cell, new_cell)


func _on_Attack_pressed():
	# Map Control
	if not _characters.has_active_unit():
		return
	
	var active_unit = _characters.get_active_unit()
	_targetable_cells = get_attackable_cells(active_unit, active_unit.UnitInfo.main_attack)
	_unit_overlay.draw(_targetable_cells, _unit_overlay.TILE_TYPE.ATTACK)
	_unit_path.initialize([active_unit.cell] + _targetable_cells)
	selected_action = Action.attack
