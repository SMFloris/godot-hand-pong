extends CharacterBody2D

var speed = 400
var direction = Vector2(1, 0).normalized()

@onready var collisionShape = $"CollisionShape2D"

func _ready():
	reset_ball()

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		direction = direction.bounce(collision.get_normal())

func _process(delta: float):
	if position.x < 0:
		print("Player 2 scores!")
		reset_ball()
	elif position.x > get_viewport_rect().size.x:
		print("Player 1 scores!")
		reset_ball()

func _draw():
	draw_circle(collisionShape.position, 10, Color(1, 1, 1))

func reset_ball():
	position = get_viewport_rect().size / 2
	direction = Vector2(randf_range(-1, 1), randf_range(-0.5, 0.5)).normalized()
	queue_redraw()
