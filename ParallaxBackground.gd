extends ParallaxBackground

var velocity_x = 20
@onready var world = $".."

func _physics_process(delta):
	scroll_offset -= Vector2(world.velocity_x,0)
