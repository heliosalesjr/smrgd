extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var value = 1

func _on_body_entered(body):
	animated_sprite_2d.play("Collected")
	var player = body as PlayerController
	if player:
		player.CollectedCoin(value)

func _process(delta):
	if animated_sprite_2d.is_playing() == false:
		queue_free()
