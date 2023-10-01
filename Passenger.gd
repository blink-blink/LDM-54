class_name Passenger
extends Node2D

@onready var original_position: Vector2 = position
@onready var  WorldControl: Control = $"../.."
@onready var world = get_node("../../..")
@onready var label = $Label

static var GROUP_OFFSET_ON_DRAG = 20

var selected: bool = false
var selected_group: int

#attributes
var panel_texture_path: String = "res://icon.svg"
@onready var personality = world.passenger_personality.NEUTRAL
@onready var location = world.passenger_location.ANYWHERE
var profit = 10
var number_of_stops = 2
var adj_count = 0
var is_seated: bool = false

func _input(event):
	#on mouse release
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and selected:
			var g = find_passenger_group()
			if g:
				for passenger in g:
					passenger.on_release()
			else:
				on_release()
			

func _process(delta):
	if selected:
		follow_mouse()

func add_to_passenger_group(i: int):
	if not world.passenger_groups[i]:
		print("passenger group:",i," doesn't exist")
		return
	
	world.passenger_groups[i].append(self)

func add_to_new_passenger_group():
	var passenger_group = []
	passenger_group.append(self)
	world.passenger_groups.append(passenger_group)

func find_passenger_group():
	var i = 0
	for group in world.passenger_groups:
		if group.has(self):
			return group
	return null

func follow_mouse():
	global_position = get_global_mouse_position()

func on_drop():
	is_seated = true
	visible = false

func on_release():
	selected = false
	position = original_position
	adj_count = 0
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var g = find_passenger_group()
			if g:
				print("passenger in group:", world.passenger_groups.find(g))
				for passenger in g:
					passenger.selected = true
			else:
				selected = true
			
			WorldControl.force_drag(self, null)
