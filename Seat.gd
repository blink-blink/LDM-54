extends TextureRect

var passenger: Passenger
@onready var world = get_node("../../../../..")

func _get_drag_data(at_position):
	if not passenger:
		return
	
	#update passenger
	var dragged_passenger = passenger
	var g = dragged_passenger.find_passenger_group()
	if g:
		for passenger in g:
			if passenger == dragged_passenger:
				continue
			
			var i
			var j = g.find(passenger)
			var k = g.find(dragged_passenger)
			
			var s
			if self in world.left_seats:
				s = world.left_seats
			elif self in world.right_seats:
				s = world.right_seats
			else:
				s = world.front_seats
				
			i = s.find(self)
			s[i - (j - k)].update_on_drag_seat(passenger)
	
	update_on_drag_seat(passenger)
	return dragged_passenger

func _can_drop_data(at_position, data):
	if passenger:
		return false
	
	var dropped_passenger: Passenger = data
	var g = dropped_passenger.find_passenger_group()
	if g:
		var returng = true
		for passenger in g:
			if passenger == dropped_passenger:
				continue
			
			var j = g.find(passenger)
			var k = g.find(dropped_passenger)
			
			print(j,k)
			
			if self in world.left_seats:
				returng = returng && is_seatable(world.left_seats,j,k)
			elif self in world.right_seats:
				returng = returng && is_seatable(world.right_seats,j,k)
			else:
				returng = returng && is_seatable(world.front_seats,j,k)
		return returng
	
	return true

func is_seatable(seats: Array,j,k):
	var i
	i = seats.find(self)
	if (i - (j-k)) < 0 or (i - (j-k)) >= world.num_seats:
		print("invalid index: ")
		return false
	if not seats[i - (j-k)].passenger:
		print("seatable")
		return true
	print("passenger is sitting")
	return false

func _drop_data(at_position, data):
	var dropped_passenger: Passenger = data
	
	#update game data
	var g = dropped_passenger.find_passenger_group()
	if g:
		for passenger in g:
			if passenger == dropped_passenger:
				continue
			
			var i
			var j = g.find(passenger)
			var k = g.find(dropped_passenger)
			
			var s
			if self in world.left_seats:
				s = world.left_seats
			elif self in world.right_seats:
				s = world.right_seats
			else:
				s = world.front_seats
				
			i = s.find(self)
			s[i - (j - k)].update_seat(passenger)
	
	update_seat(dropped_passenger)

func update_seat(data: Passenger):
	var texture_data = load(data.panel_texture_path)
	texture = texture_data
	passenger = data
	passenger.on_drop()

func update_on_drag_seat(data: Passenger):
	passenger.selected = true
	passenger.visible = true
	passenger = null
	texture = null
