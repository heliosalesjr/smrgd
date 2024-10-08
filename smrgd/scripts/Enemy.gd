extends CharacterBody2D

const SPEED = 50
var direction = -1
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_2d_forward: RayCast2D = $CollisionShape2D/RayCast2D_Forward
@onready var ray_cast_2d_downward: RayCast2D = $CollisionShape2D/RayCast2D_Downward


func _process(delta):
	UpdateAnimation()

func _physics_process(delta):
	if is_on_floor() == false:
		velocity.y = 300
	
	if ray_cast_2d_forward.is_colliding() || ray_cast_2d_downward.is_colliding() == false:
		direction = -direction
		ray_cast_2d_forward.target_position.x = -ray_cast_2d_forward.target_position.x
		ray_cast_2d_downward.target_position.x = -ray_cast_2d_downward.target_position.x
	velocity.x = direction * SPEED
	
	move_and_slide()
	
func UpdateAnimation():
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x > 0
		
	animated_sprite_2d.play("Walk")
