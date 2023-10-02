extends TextureRect

var passenger: Passenger
var is_locked: bool = false
@onready var world = get_node("../../../../..")

func _get_drag_data(at_position):
	if not passenger or is_locked:
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
			
			var s = get_seat_group()
				
			i = s.find(self)
			s[i - (j - k)].update_on_drag_seat(passenger)
	
	update_on_drag_seat(passenger)
	return dragged_passenger

func _can_drop_data(at_position, data):
	if passenger:
		return false
	
	#adj
	var adj_l: Passenger
	var adj_r: Passenger
	var adj_count = 0
	
	#group
	var dropped_passenger: Passenger = data
	var g = dropped_passenger.find_passenger_group()
	var returng = true
	
	var s = get_seat_group()
	var i = s.find(self)
	
	if g:
		for passenger in g:
			if passenger == dropped_passenger:
				continue
			
			var j = g.find(passenger)
			var k = g.find(dropped_passenger)
			
#			print("i:",i,"j:",j,"k:",k,i+(j-k))
			returng = returng && is_seatable(s,j,k)
			
			if j == g.size() - 1 and i - (j-k)-1 >= 0:
				if s[i - (j-k)-1].passenger:
					adj_count += 1
					adj_l = s[i - (j-k)-1].passenger 
			if j == 0  and i - (j-k)+1 <= s.size() - 1:
				if s[i - (j-k)+1].passenger:
					adj_count += 1
					adj_r = s[i - (j-k)+1].passenger 
	else:
		if i-1 >= 0:
			if s[i-1].passenger:
				print("left p")
				adj_count += 1
				adj_l = s[i-1].passenger
		if i < s.size()-1:
			if s[i+1].passenger:
				adj_count += 1
				adj_r = s[i+1].passenger
	
	dropped_passenger.adj_count = adj_count
	print(adj_count)
	
	#loc check
	if dropped_passenger.location == world.passenger_location.FRONT and s != world.front_seats:
		return false
	if dropped_passenger.location == world.passenger_location.BACK and s == world.front_seats:
		return false
	if dropped_passenger.location == world.passenger_location.LAST and i > 0:
		return false
	
	#adj check
	if adj_l:
		if adj_l.personality == world.passenger_personality.INTROVERT and adj_l.adj_count >= 1:
#			print("introvert on left has two adj")
			return false
	if adj_r:
		if adj_r.personality == world.passenger_personality.INTROVERT and adj_r.adj_count >= 1:
			return false
	
	if dropped_passenger.personality == world.passenger_personality.INTROVERT and adj_count > 1:
		return false
	if dropped_passenger.personality == world.passenger_personality.SOCIAL and adj_count < 2:
		return false
		
	return returng && true

func get_seat_group():
	if self in world.left_seats:
		return world.left_seats
	elif self in world.right_seats:
		return world.right_seats
	else:
		return world.front_seats

func is_seatable(seats: Array,j,k):
	var i
	i = seats.find(self)
	if (i - (j-k)) < 0 or (i - (j-k)) >= world.num_seats:
#		print("invalid index: ")
		return false
	if seats[i - (j-k)].passenger:
#		print("passenger is sitting")
		return false
#	print("seatable")
	return true

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
			s[i - (j-k)].update_seat(passenger)
	
	update_seat(dropped_passenger)

func update_seat(data: Passenger):
	var texture_data = load(data.panel_texture_path)
	texture = texture_data
	passenger = data
	passenger.on_drop()

func on_next_station():
	if passenger:
		if not is_locked:
			is_locked = true
		passenger.number_of_stops -= 1
		if passenger.number_of_stops <= 0:
			world.update_score(passenger.profit)
			is_locked = false
			passenger.queue_free()
			passenger = null
			texture = null

func remove_passenger():
	passenger = null
	texture = null

func update_on_drag_seat(data: Passenger):
	passenger.selected = true
	passenger.visible = true
	remove_passenger()
