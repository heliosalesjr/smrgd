extends CharacterBody2D
class_name EnemyController

const SPEED = 50
var direction = -1
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_2d_forward = $CollisionShape2D/RayCast2D_Forward
@onready var ray_cast_2d_downward = $CollisionShape2D/RayCast2D_Downward
@onready var area_2d_container: Node2D = $Area2D_Container

var currentHealth = 100
var isDead = false

var IsAttacking = false

func _process(_delta):
	UpdateAnimation()

func _physics_process(_delta):
	if is_on_floor() == false:
		velocity.y = 300
	
	if isDead:
		return
	
	if IsAttacking:
		if animated_sprite_2d.is_playing() == false:
			IsAttacking = false
		else:
			return
	
	if ray_cast_2d_forward.is_colliding() || ray_cast_2d_downward.is_colliding() == false:
		direction = -direction
		ray_cast_2d_forward.target_position.x = -ray_cast_2d_forward.target_position.x
		ray_cast_2d_downward.position.x = -ray_cast_2d_downward.position.x
		area_2d_container.scale.x = -direction
	
	velocity.x = direction * SPEED
	
	move_and_slide()
	
func UpdateAnimation():
	if isDead:
		return
		
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x > 0
	
	if IsAttacking == false:
		animated_sprite_2d.play("Walk")
	elif animated_sprite_2d.animation != "Attack":
		animated_sprite_2d.play("Attack")
		
func ApplyDamage(damage : int):
	if isDead:
		return
		
	currentHealth -= damage
	
	if currentHealth <= 0:
		isDead = true
		animated_sprite_2d.play("Die")
		set_collision_layer_value(3,false)
		await get_tree().create_timer(2).timeout
		queue_free()


func _on_area_2d_player_detector_body_entered(body: Node2D) -> void:
	IsAttacking = true
