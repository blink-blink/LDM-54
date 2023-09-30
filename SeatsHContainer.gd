extends HBoxContainer

var seat_scene = preload("res://seat.tscn")

@export var num_seats = 8
@export var num_seats_front = 1

@onready var left_seats = $LeftSeats
@onready var right_seats = $RightSeats
@onready var front_seats = $FrontSeats

# Called when the node enters the scene tree for the first time.
func _ready():
	#populate seats
	var id = 0
	for i in 2:
		for j in num_seats:
			print(i,j)
			var seat = seat_scene.instantiate()
			seat.seat_id = id
			id+=1
			if i == 0: 
				left_seats.add_child(seat)
			else:
				right_seats.add_child(seat)
	
	for i in num_seats_front:
		var seat = seat_scene.instantiate()
		seat.seat_id = id
		id+=1
		
		left_seats.add_child(seat)
		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
