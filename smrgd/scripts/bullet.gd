extends Area2D

@onready var bullet_sprite_2d: Sprite2D = $Bullet_Sprite2D

const SPEED = 500
var direction = 1
const DAMAGE = 35

func _physics_process(delta):
	if direction == -1:
		bullet_sprite_2d.flip_h = true
		
	position.x += SPEED * direction * delta


func _on_body_entered(body: Node2D) -> void:
	print("The bullet hit!")
	
	var vfxToSpawn = preload("res://Scenes/vfx_bullet_hit.tscn")
	var vfxInstance = GameManager.SpawnVFX(vfxToSpawn, global_position)
	
	if direction == -1:
		vfxInstance.scale.x = -1
		
	queue_free()
