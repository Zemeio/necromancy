## Draws a selected unit's walkable tiles.
class_name UnitOverlay
extends TileMap


enum TILE_TYPE {
	MOVE = 0,
	ATTACK = 2
}


## Fills the tilemap with the cells, giving a visual representation of the cells a unit can walk.
func draw(cells: Array, tile_type) -> void:
	clear()
	for cell in cells:
		set_cellv(cell, tile_type)
