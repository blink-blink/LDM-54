extends HBoxContainer

var seat_scene = preload("res://seat.tscn")

@onready var left_seats = $LeftSeats
@onready var right_seats = $RightSeats
@onready var front_seats = $FrontSeats
@onready var world = $"../../.."

func _ready():
	#populate seats
	for i in 2:
		for j in world.num_seats:
			print(i,j)
			var seat = seat_scene.instantiate()
			if i == 0: 
				world.left_seats.append(seat)
				left_seats.add_child(seat)
			else:
				world.right_seats.append(seat)
				right_seats.add_child(seat)
	
	for i in world.num_seats_front:
		var seat = seat_scene.instantiate()
		world.front_seats.append(seat)
		
		front_seats.add_child(seat)
	
