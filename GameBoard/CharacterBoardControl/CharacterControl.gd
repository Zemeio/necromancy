class_name CharacterBoardControl
extends Node2D

var _units := {}
var _active_unit: Unit

func initialize():
	_add_units_from_characters_to_list(_units)

func _add_units_from_characters_to_list(units):
	for child in get_children():
		var character := child as Character
		if not character: continue
		_add_board_units(character, _units)

func _add_board_units(character, _units):
	var character_units: Array = character.get_node("BoardUnits").get_children()
	
	if character_units.empty():
		print("No board units found on character: " + character.CharacterInfo.Name)
	
	for character_unit in character_units:
		if not character_unit is Unit: continue
		character_unit = character_unit as Unit
		_units[character_unit.cell] = character_unit


func get_units():
	return _units.values()

func get_active_unit():
	return _active_unit

func has_active_unit():
	return _active_unit != null
	
func has_unit_in_cell(cell):
	return _units.has(cell)

func active_unit_is_selected():
	return has_active_unit() and _active_unit.is_selected

func select_unit_on_cell(cell: Vector2):
	if not _units.has(cell):
		print("Tried to select unit on cell " + str(cell) + ", but no unit is located there.")
		return null

	_active_unit = _units[cell]
	_active_unit.is_selected = true
	return _active_unit


## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func deselect_active_unit() -> void:
	# Map Control
	_active_unit.is_selected = false


## Clears the reference to the _active_unit and the corresponding walkable cells.
func clear_active_unit() -> void:
	# Map Control
	_active_unit = null
		
func move_unit_to_cell(unit, cell):
	_units.erase(unit.cell)
	_units[cell] = unit
