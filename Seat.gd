extends TextureRect

var passenger: Passenger
var seat_id: int
@onready var world = get_node("../../../../..")

func _get_drag_data(at_position):
	if not passenger:
		return
	
	passenger.selected = true
	passenger.visible = true
	
	#update passenger
	var dragged_passenger = passenger
	passenger = null
	texture = null
	return dragged_passenger

func _can_drop_data(at_position, data):
	return data is Passenger

func _drop_data(at_position, data):
	#update game data
	world.dropped_passenger = data
	#update texture
	var texture_data = load(data.panel_texture_path)
	texture = texture_data
	passenger = data
