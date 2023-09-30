class_name Passenger
extends Node2D

var selected: bool = false
var original_position: Vector2 = position
@onready var  WorldControl: Control = $"../.."
@onready var world = get_node("../../..")

#attributes
var panel_texture_path: String = "res://icon.svg"
var tags = []

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and selected:
			print("released")
			selected = false
			call_deferred("on_mouse_release")

func _process(delta):
	if selected:
		follow_mouse()

func add_to_passenger_group():
	pass

func follow_mouse():
	global_position = get_global_mouse_position()

func on_mouse_release():
	#if seat hover
	if world.dropped_passenger == self:
		world.dropped_passenger = null
		visible = false
	#snap to original_position
	position = original_position

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("input press")
			selected = true
			WorldControl.force_drag(self, null)
