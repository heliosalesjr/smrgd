extends CharacterBody2D
class_name PlayerController

const SPEED = 170
const JUMP_VELOCITY = -450
const GRAVITY = 1800
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shooting_point = $Shooting_Point

var AirborneLastFrame = false

var isShooting = false
const SHOOT_DURATION = 0.249

enum PlayerState {Normal,Hurt,Dead, Uncontrollable}

var currentState : PlayerState = PlayerState.Normal:
	set(new_value):
		currentState = new_value
		match currentState:
			PlayerState.Hurt:
				if is_on_floor():
					animated_sprite_2d.play("Hit_Stand")
				else:
					animated_sprite_2d.play("Hit_Jump")
			PlayerState.Dead:
				animated_sprite_2d.play("Die")
				set_collision_layer_value(2,false)
				GameManager.PlayerIsDead()
			PlayerState.Uncontrollable:
				set_collision_layer_value(2,false)


var currentHealth:
	set(new_value):
		currentHealth = new_value
		emit_signal("playerHealthUpdated",currentHealth,MAX_HEALTH)
const MAX_HEALTH = 100

var currentCoin = 0:
	set(new_value):
		currentCoin = new_value
		emit_signal("playerCoinUpdated",currentCoin)

signal playerHealthUpdated(newValue, maxValue)
signal playerCoinUpdated(newValue)

func _ready():
	currentHealth = MAX_HEALTH
	GameManager.player = self
	GameManager.playerOriginalPos = position

func _process(_delta):
	UpdateAnimation()


func _physics_process(delta):
	if is_on_floor() == false:
		velocity.y += GRAVITY * delta
		AirborneLastFrame = true
	elif  AirborneLastFrame:
		PlayLandVFX()
		AirborneLastFrame = false
	
	if currentState == PlayerState.Hurt || currentState == PlayerState.Dead || currentState == PlayerState.Uncontrollable:
		velocity.x = 0
		move_and_slide()
		return
	
		
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		PlayJumpUpVFX()
		
	var direction = Input.get_axis("Left","Right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0
	
	
	if Input.is_action_just_pressed("Shoot"):
		TryToShoot()
	
	
	if Input.is_action_just_pressed("Down") && is_on_floor():
		position.y += 3
		
	move_and_slide()


func UpdateAnimation():
	
	if currentState == PlayerState.Dead:
		return
	elif currentState == PlayerState.Hurt:
		if animated_sprite_2d.is_playing():
			return
		else:
			currentState = PlayerState.Normal
	
	
	
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
		if velocity.x < 0:
			shooting_point.position.x = -26
		else:
			shooting_point.position.x = 26
		
	if is_on_floor():
		if abs(velocity.x) >= 0.1:
			
			var playingAnimationFrame = animated_sprite_2d.frame
			var playingAnimationName = animated_sprite_2d.animation
			
			if isShooting:
				animated_sprite_2d.play("Shoot_Run")
				
				if playingAnimationName == "Run":
					animated_sprite_2d.frame = playingAnimationFrame
			else:
				if playingAnimationName == "Shoot_Run" && animated_sprite_2d.is_playing():
					pass
				else:	
					animated_sprite_2d.play("Run")
						
		else:
			if isShooting:
				animated_sprite_2d.play("Shoot_Stand")
			else:
				animated_sprite_2d.play("Idle")
	else:
		animated_sprite_2d.play("Jump")
		
		if isShooting:
			animated_sprite_2d.play("Shoot_Jump")		
			

func PlayJumpUpVFX():
	var vfxToSpawn = preload("res://Scenes/vfx_jump_up.tscn")
	GameManager.SpawnVFX(vfxToSpawn,global_position)
	
	
func PlayLandVFX():
	var vfxToSpawn = preload("res://Scenes/vfx_land.tscn")	
	GameManager.SpawnVFX(vfxToSpawn,global_position)
	
	

func Shoot():
	var bulletToSpawn = preload("res://Scenes/bullet.tscn")
	var bulletInstance = GameManager.SpawnVFX(bulletToSpawn,shooting_point.global_position)
	
	if animated_sprite_2d.flip_h:
		bulletInstance.direction = -1
	else:
		bulletInstance.direction = 1
		
		


func TryToShoot():
	if isShooting:
		return
		
	isShooting = true
	Shoot()
	PlayFireVFX()
	await get_tree().create_timer(SHOOT_DURATION).timeout
	isShooting = false
	



func PlayFireVFX():
	var vfxToSpawn = preload("res://Scenes/vfx_player_fire.tscn")
	var vfxInstance = GameManager.SpawnVFX(vfxToSpawn,shooting_point.global_position)
	
	if animated_sprite_2d.flip_h:
		vfxInstance.scale.x = -1



func ApplyDamage(damage:int):
	if currentState == PlayerState.Hurt || currentState == PlayerState.Dead:
		return
		
	currentHealth -= damage
	currentState = PlayerState.Hurt
	
	if currentHealth <= 0:
		currentHealth = 0
		currentState = PlayerState.Dead


func CollectedCoin(value:int):
	currentCoin += value
	
	if currentHealth < MAX_HEALTH:
		currentHealth += value * 3
		if currentHealth > MAX_HEALTH:
			currentHealth = MAX_HEALTH


func SwitchStateToUncontrollable():
	currentState = PlayerState.Uncontrollable
