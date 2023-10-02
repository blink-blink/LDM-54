extends CanvasLayer

var dropped_passenger: Passenger
var passenger_queue = []
var passenger_groups = []
var left_seats = []
var right_seats = []
var front_seats = []

@export var num_seats = 8
@export var num_seats_front = 1
@onready var station = $Station
@onready var passengers = $WorldControl/Passengers
@onready var jeepney = $Jeepney
@onready var score_value_label = $Interface/MarginContainer/HBoxContainer/ScoreValueLabel
@onready var hud = $Interface

var base_quota = 100
var quota_increment = 10
var quota = 0
var stations_total = 1
var stations_till_quota = 0
var score = 0

var velocity_x = 0
const MAX_VELOCTIY_X = 30
var tween
var j_tween
var p_tween
var s_tween

static var PASSENGER_QUEUE_OFFSET = 80

#adjacency tags
enum passenger_personality {NEUTRAL, INTROVERT, SOCIAL}
enum passenger_location {ANYWHERE, FRONT, BACK, LAST}

var passenger_type = {
	"couple":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 2,
		"min count": 2,
		"max count": 2
	},
	"group":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 2,
		"min count": 3,
		"max count": 4
	},
	"quick":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 5,
		"number of stops" : 1,
		"min count": 1,
		"max count": 1
	},
	"slow":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 3,
		"min count": 1,
		"max count": 1
	},
	"introvert":{
		"personality" : passenger_personality.INTROVERT,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1
	},
	"social":{
		"personality" : passenger_personality.SOCIAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1
	},
	"shotgun":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.FRONT,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1
	},
	"elderly":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.LAST,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1
	},
	"wife":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.FRONT,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1
	}
}

func clear_passengers():
	for p in passenger_queue:
		if not p.is_seated:
			p.queue_free()
	passenger_queue.clear()

func populate_passengers(p_count):
	for i in p_count:
		spawn_passenger(passenger_type.keys()[ randi() % passenger_type.size() ])

func spawn_passenger(p):
	print(p)
	var g = []
	var j = randi_range(passenger_type[p]["min count"],passenger_type[p]["max count"])
	for i in range(0,j,1):
		var passenger_scene = load("res://passenger.tscn")
		var passenger = passenger_scene.instantiate()
		passengers.add_child(passenger)
		
		#set passenger attributes
		passenger.global_position = passengers.global_position - Vector2(PASSENGER_QUEUE_OFFSET * passenger_queue.size(),0)
		passenger.original_position = passenger.position
		passenger_queue.append(passenger)
		passenger.type_name = p
		passenger.personality = passenger_type[p]["personality"]
		passenger.location = passenger_type[p]["location"]
		passenger.profit = passenger_type[p]["profit"]
		passenger.number_of_stops = passenger_type[p]["number of stops"]
		g.append(passenger)
	
	if g.size() > 1:
		print("added to passenger group")
		passenger_groups.append(g)
	
	return j

func next_station():
	if not hud.is_visible():
		hud.visible = true
	if stations_till_quota <= 0:
		stations_till_quota = stations_total
		if quota > 0:
			game_over()
			return
		quota = base_quota
	else:
		stations_till_quota -= 1
	
	#repop passengers
	update_seats()
	clear_passengers()
	populate_passengers(4)
	#update score

func pre_next_station(is_start_game: bool):
	for p in passenger_queue:
		p.UI.visible = false
	
	#animate jeep
	if j_tween:
		j_tween.kill()
	j_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if is_start_game:
		j_tween.tween_property(jeepney,"global_position",jeepney.global_position + Vector2(500,0),1).set_delay(3)
	else:
		j_tween.tween_property(jeepney,"global_position",jeepney.global_position - Vector2(500,0),1)
		j_tween.tween_property(jeepney,"global_position",jeepney.global_position,1).set_delay(2)
	#animate passengers
	if p_tween:
		p_tween.kill()
	p_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	p_tween.tween_property(passengers,"global_position",passengers.global_position - Vector2(680,0),1)
	p_tween.tween_property(passengers,"global_position",passengers.global_position,1).set_delay(3)
	#animate station
	if s_tween:
		s_tween.kill()
	s_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	s_tween.tween_property(station,"global_position",station.global_position - Vector2(900,0),1.4)
	if is_start_game:
		s_tween.tween_property(station,"visible",true,0)
	s_tween.tween_property(station,"global_position",station.global_position + Vector2(1100,0),0)
	s_tween.tween_property(station,"global_position",station.global_position,2).set_delay(0.6)
	#animate world
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(self,"velocity_x",MAX_VELOCTIY_X,1)
	tween.tween_property(self,"velocity_x",0,2).set_delay(1)
	tween.tween_callback(next_station)

func update_seats():
	for s in left_seats:
		s.on_next_station()
	for s in right_seats:
		s.on_next_station()
	for s in front_seats:
		s.on_next_station()
			

func update_score(s):
	quota -= s
	score += s
	score_value_label.text = str(score)

func game_over():
	game_over_ui.visible = true
	hud.visible = false

func _ready():
	on_game_start()

@onready var main_menu = $MainMenu
@onready var game_over_ui = $GameOver

func on_game_start():
	main_menu.visible = true
	hud.visible = false
	
	velocity_x = MAX_VELOCTIY_X
	jeepney.global_position = jeepney.global_position - Vector2(500,0)
	station.visible = false

func _on_button_pressed():
	if p_tween:
		if p_tween.is_running():
			return
	pre_next_station(false)


func _on_start_game_pressed():
	main_menu.visible = false
	pre_next_station(true)


func _on_restart_button_pressed():
	game_over_ui.visible = false
	pre_next_station(false)


func _on_quit_button_pressed():
	get_tree().quit()
