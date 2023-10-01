extends CanvasLayer

var dropped_passenger: Passenger
var passenger_groups = []
var left_seats = []
var right_seats = []
var front_seats = []

@export var num_seats = 8
@export var num_seats_front = 1

func populate_passengers():
	pass

func _ready():
	#test
	var passenger: Passenger = $WorldControl/Passengers/Passenger
	var passenger2: Passenger = $WorldControl/Passengers/Passenger2
	#var passenger3: Passenger = $WorldControl/Passengers/Passenger3
	
	passenger.add_to_new_passenger_group()
	passenger2.add_to_passenger_group(0)
	#passenger3.add_to_passenger_group(0)
