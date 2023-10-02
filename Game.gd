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
@onready var score_value_label = $Interface/MarginContainer/VBoxContainer/HBoxContainer/ScoreValueLabel
@onready var quota_label = $Interface/MarginContainer/VBoxContainer/QuotaLabel
@onready var stations_till_quota_label = $Interface/MarginContainer/VBoxContainer/STQLabel
@onready var hud = $Interface

var base_quota = 100
var quota_increment = 10
var quota = 0
var stations_total = 5
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
	"normal":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1,
		"description": "Can be placed anywhere. Occupies one seat for two stops and gives 10 profit."
	},
	"couple":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 10,
		"number of stops" : 2,
		"min count": 2,
		"max count": 2,
		"description": "Can be placed anywhere. Occupies two seats for two stops and gives 20 profit."
	},
	"group":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 10,
		"number of stops" : 2,
		"min count": 3,
		"max count": 4,
		"description": "Can be placed anywhere. Occupies three or four seats for two stops and gives 10 profit for each passenger."
	},
	"quick":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 5,
		"number of stops" : 1,
		"min count": 1,
		"max count": 1,
		"description": "Can be placed anywhere. Occupies one seat for one stop and gives 5 profit."
	},
	"slow":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 20,
		"number of stops" : 3,
		"min count": 1,
		"max count": 1,
		"description": "Can be placed anywhere. Occupies one seat for three stops and gives 20 profit."
	},
	"introvert":{
		"personality" : passenger_personality.INTROVERT,
		"location" : passenger_location.ANYWHERE,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1,
		"description": "Must be placed either the front or the edge seats. Occupies one seat for two stops and gives 10 profit."
	},
	"social":{
		"personality" : passenger_personality.SOCIAL,
		"location" : passenger_location.ANYWHERE,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1,
		"description": "Must be placed in between two other passengers. Occupies one seat for two stops and gives 10 profit."
	},
	"shotgun":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.FRONT,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1,
		"description": "Must be placed only in the front seat. Occupies one seat for two stops and gives 10 profit."
	},
	"elderly":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.LAST,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1,
		"description": "Must be placed only in the last seat. Occupies one seat for two stops and gives 10 profit."
	},
	"wife":{
		"personality" : passenger_personality.NEUTRAL,
		"location" : passenger_location.FRONT,
		"profit": 10,
		"number of stops" : 2,
		"min count": 1,
		"max count": 1,
		"description": "Must be placed only in the front seat. Occupies one seat for two stops and gives no profit but doubles incoming profit from other passengers."
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
	if (is_wife_sitting() or is_wife_in_queue()) and p == "wife":
		p = "normal"
	
	var g = []
	var j = randi_range(passenger_type[p]["min count"],passenger_type[p]["max count"])
	var n = randi_range(1,2)
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
		passenger.description = passenger_type[p]["description"]
		if p == "group":
			passenger.set_sprite_texture(p,n)
		else:
			passenger.set_sprite_texture(p,0)
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
		base_quota += quota_increment
		quota = base_quota
		quota_label.text = "Quota: "+str(quota)
	stations_till_quota -= 1
	stations_till_quota_label.text = "Stations till Quota: "+str(stations_till_quota)
	
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
			

func is_wife_sitting():
	if front_seats[0].passenger:
		if front_seats[0].passenger.type_name == "wife":
			return true
	return false

func is_wife_in_queue():
	for p in passenger_queue:
		if p.type_name == "wife":
			return true
	return false

func update_score(s):
	if is_wife_sitting():
		s*=2
	quota -= s
	if quota < 0:
		quota = 0
	score += s
	score_value_label.text = str(score)
	quota_label.text = "Quota: "+str(quota)

func game_over():
	game_over_ui.visible = true
	hud.visible = false
	var game_over_score = $GameOver/PanelContainer/MarginContainer/VBoxContainer/GameOverScoreLabel
	game_over_score.text = "Score: " + str(score)

func _ready():
	on_game_start()

@onready var main_menu = $MainMenu
@onready var game_over_ui = $GameOver

func on_game_start():
	main_menu.visible = true
	hud.visible = false
	
	velocity_x = MAX_VELOCTIY_X
	stations_till_quota = stations_total
	quota = base_quota
	stations_till_quota_label.text = "Stations till Quota: "+str(stations_till_quota)
	quota_label.text = "Quota: "+str(quota)
	jeepney.global_position = jeepney.global_position - Vector2(500,0)
	station.visible = false

func reset_game():
	for s in left_seats:
		s.remove_passenger()
	for s in right_seats:
		s.remove_passenger()
	for s in front_seats:
		s.remove_passenger()

func _on_button_pressed():
	if p_tween:
		if p_tween.is_running():
			return
	var beep = $Beep
	beep.play()
	pre_next_station(false)


func _on_start_game_pressed():
	main_menu.visible = false
	pre_next_station(true)


func _on_restart_button_pressed():
	game_over_ui.visible = false
	reset_game()
	pre_next_station(false)


func _on_quit_button_pressed():
	get_tree().quit()
