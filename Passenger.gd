class_name Passenger
extends Node2D

@onready var original_position: Vector2 = position
@onready var  WorldControl: Control = $"../.."
@onready var world = get_node("../../..")
@onready var UI = $UI
@onready var label = $UI/TypeLabel
@onready var sprite = $Sprite

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
var type_name: String
var description: String

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
	UI.visible = false
	is_seated = true
	visible = false

func on_release():
	UI.visible = true
	selected = false
	position = original_position
	adj_count = 0

const SPRITE_TEXTURE_PATH = "res://Assets/Characters/Full/"
const PROFILE_TEXTURE_PATH = "res://Assets/Characters/Profile/"

func set_sprite_texture(s: String,g: int):
	var texture_data
	
	if ResourceLoader.exists(SPRITE_TEXTURE_PATH+s+".png"):
		texture_data = load(SPRITE_TEXTURE_PATH+s+".png")
		panel_texture_path = PROFILE_TEXTURE_PATH+s+".png"
	elif ResourceLoader.exists(SPRITE_TEXTURE_PATH+s+"1.png"):#variants
		var x = 0
		for i in 4:
			if ResourceLoader.exists(SPRITE_TEXTURE_PATH+s+str(i)+".png"):
				x+=1
		var y = randi_range(1,x)
		print(SPRITE_TEXTURE_PATH+s+str(y)+".png")
		texture_data = load(SPRITE_TEXTURE_PATH+s+str(y)+".png")
		panel_texture_path = PROFILE_TEXTURE_PATH+s+str(y)+".png"
	elif g > 0:#group
		var j = 0
		for i in 4:
			if ResourceLoader.exists(SPRITE_TEXTURE_PATH+s+str(g)+"."+str(i+1)+".png"):
				j+=1
		var k = randi_range(1,j)
		
		print(SPRITE_TEXTURE_PATH+s+str(g)+"."+str(k)+".png")
		texture_data = load(SPRITE_TEXTURE_PATH+s+str(g)+"."+str(k)+".png")
		panel_texture_path = PROFILE_TEXTURE_PATH+s+str(g)+"."+str(k)+".png"
	else:
		var x = 0
		for i in 4:
			if ResourceLoader.exists(SPRITE_TEXTURE_PATH+s+str(i+1)+".1.png"):
				x+=1
		
		var y = randi_range(1,x)
		var j = 0
		for i in 4:
			if ResourceLoader.exists(SPRITE_TEXTURE_PATH+s+str(y)+"."+str(i+1)+".png"):
				j+=1
		var k = randi_range(1,j)
		
		print(x,j)
		print(SPRITE_TEXTURE_PATH+s+str(y)+"."+str(k)+".png")
		texture_data = load(SPRITE_TEXTURE_PATH+s+str(y)+"."+str(k)+".png")
		panel_texture_path = PROFILE_TEXTURE_PATH+s+str(y)+"."+str(k)+".png"
	
	sprite.texture = texture_data

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var g = find_passenger_group()
			if g:
				print("passenger in group:", world.passenger_groups.find(g))
				for passenger in g:
					passenger.selected = true
					passenger.UI.visible = false
			else:
				UI.visible = false
				selected = true
			
			WorldControl.force_drag(self, null)


@onready var tooltip = $UI/Tootip
@onready var tooltip_button = $UI/TooltipButton

func _on_area_2d_mouse_entered():
	if tooltip.visible:
		return
	label.visible = true
	label.text = type_name
	tooltip_button.visible = true

func _on_area_2d_mouse_exited():
	label.visible = false
	tooltip_button.visible = false

func _on_tooltip_button_pressed():
	tooltip.visible = true
	label.visible = false
	tooltip_button.visible = false
	var type_name_label = $UI/Tootip/PanelContainer/MarginContainer/VBoxContainer/TypeName
	type_name_label.text = type_name
	var type_desc_label = $UI/Tootip/PanelContainer/MarginContainer/VBoxContainer/TypeDesc
	type_desc_label.text = description

func _on_tooltip_exit_button_pressed():
	tooltip.visible = false
