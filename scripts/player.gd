extends CharacterBody2D # Importa o Player

# Define os estados do Player
enum PlayerState {
	idle,
	walk,
	jump
}

# Define uma variável atribuída a animação do Player
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Variáveis do Player para a velocidade, pulo, gravidade
@export var speed: float = 80.0
@export var acceleration: float = 1200.0
@export var friction: float = 1000.0
@export var jump_velocity: float = -300.0
@export var gravity: float = 980.0

var status: PlayerState # Recebe os valores do Enum

# Começa no estado idle
func _ready() -> void:
	go_to_idle_state()

# Função de física do Player
func _physics_process(delta: float) -> void:
	
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	# Mantém o Player no chão
	else:
		velocity.y = 0 
		
	# Se Player estiver em determinado status
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
	status = PlayerState.idle # Define o status como idle
	animated_sprite_2d.play("idle") # Animação de idle

func go_to_walk_state():
	status = PlayerState.walk # Define o status como andar
	animated_sprite_2d.play("walk") # Animação de andar
	
func go_to_jump_state():
	status = PlayerState.jump # Define o status como jump
	animated_sprite_2d.play("jump") # Animação de pular
	velocity.y = jump_velocity

# Roda infinitamente
func idle_state(delta: float):
	move(delta) # Chama a função move
	# Se não está parado, vai para o estado walkk
	if velocity.x != 0: # Se velocidade for diferente de 0 (não está parado)
		go_to_walk_state() # Chama a função de andar uma vez
		return
	# Se a tecla específica está pressionada, vai para o estado jump
	if Input.is_action_just_pressed("jump"): 
		go_to_jump_state() # Chama a função de pular uma vez
		return

func walk_state(delta: float):
	move(delta)
	# Se está parado, vai para o estado idle
	if velocity.x == 0:
		go_to_idle_state() # Chama a função de idle uma vez
		return
	# Permite correr e pular ao mesmo tempo
	if Input.is_action_just_pressed("jump"):
		# Se a tecla estiver pressionada, chama a função de pular uma vez
		go_to_jump_state() 
		return

# Estado de pular
func jump_state(delta: float):
	move(delta) # Chama a função move
	# Ao voltar ao chão, vai para o estado idle ou walk
	if is_on_floor(): # Se estiver no chão:
		if velocity.x == 0: 
			go_to_idle_state() # Se estiver parado, vai para o estado de idle
		else:
			go_to_walk_state() # Senão, vai para o estado de andar
		return

# Movimentação do Player
func move(delta: float):
	# Define a direção do Player (esquerda e direita)
	var direction := Input.get_axis("left", "right") 
	
	# Se direção:
	if direction:
		# Anda para frente
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
		animated_sprite_2d.flip_h = true # direita
	elif direction > 0:
		animated_sprite_2d.flip_h = false # esquerda
	
