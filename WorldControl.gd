extends Control

var selected_passenger: Passenger

func _get_drag_data(at_position):
	print("dragged data")
	return selected_passenger
