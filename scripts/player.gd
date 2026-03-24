extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump
}

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var speed: float = 80.0
@export var acceleration: float = 1200.0
@export var friction: float = 1000.0
@export var jump_velocity: float = -300.0
@export var gravity: float = 980.0

var status: PlayerState # Recebe os valores do Enum

# Começa no estado idle
func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	# Mantém o Player no chão
	else:
		velocity.y = 0 
		
	match status:
		PlayerState.idle:
			idle_state(delta) # Chama a função idle
		PlayerState.walk:
			walk_state(delta) # Chama a função walk
		PlayerState.jump:
			jump_state(delta) # Chama a função jump
	
	# Movimentação final	
	move_and_slide()   
	
# Rodam uma vez
func go_to_idle_state():
	status = PlayerState.idle
	animated_sprite_2d.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	animated_sprite_2d.play("walk")
	
func go_to_jump_state():
	status = PlayerState.jump
	animated_sprite_2d.play("jump")
	velocity.y = jump_velocity

# Roda infinitamente
func idle_state(delta: float):
	move(delta)
	# Se não está parado, vai para o estado walkk
	if velocity.x != 0:
		go_to_walk_state() 
		return
	# Se a tecla específica está pressionada, vai para o estado jump
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state() 
		return

func walk_state(delta: float):
	move(delta)
	# Se está parado, vai para o estado idle
	if velocity.x == 0:
		go_to_idle_state() 
		return
	# Permite correr e pular ao mesmo tempo
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func jump_state(delta: float):
	move(delta)
	# Ao voltar ao chão, vai para o estado idle ou walk
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

# Movimentação do Player
func move(delta: float):
	var direction := Input.get_axis("left", "right")

	if direction:
		velocity.x = move_toward(
			velocity.x,
			direction * speed,
			acceleration * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			friction * delta
		)
	# Verificação da direção
	if direction < 0:
		animated_sprite_2d.flip_h = true
	elif direction > 0:
		animated_sprite_2d.flip_h = false
	
