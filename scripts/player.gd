# Importa o Player
extends CharacterBody2D 

# Define os estados do Player
enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck,
	slide,
	hurt
}

# Define uma variável atribuída a animação do Player
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Define uma variável atribuída ao colisor do Player
@onready var collison_shape_2d: CollisionShape2D = $CollisionShape2D

# Define uma variável atribuída ao colisor da HitBox
@onready var hit_box_collision_shape_2d: CollisionShape2D = $HitBox/CollisionShape2D

#Define uma variável atribuída ao timer do Player
@onready var reload_timer: Timer = $ReloadTimer

# Variáveis do Player para a velocidade, pulo, gravidade, desaceleração
@export var max_speed: float = 140.0
@export var acceleration: float = 800.0
@export var deceleration: float = 700.0
@export var ground_deceleration: float = 900.0
@export var air_deceleration: float = 150.0
@export var slide_deceleration: float = 120.0
@export var jump_velocity: float = -300.0
@export var gravity: float = 1000.0

var status: PlayerState # Recebe os valores do Enum

# Controla a direção
var direction = 0

# Contagem de pulos
var jump_count = 0

# Limite de pulos
@export var max_jump_count = 2

# Começa no estado idle
func _ready() -> void:
	go_to_idle_state()

# Função de física do Player
func _physics_process(delta: float) -> void:
	
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	# Mantém o Player no chão
	#else:
		#move_and_slide()
		
	# Se Player estiver em determinado status
	match status:
		PlayerState.idle:
			idle_state(delta) # Chama a função idle
		PlayerState.walk:
			walk_state(delta) # Chama a função walk
		PlayerState.jump:
			jump_state(delta) # Chama a função jump
		PlayerState.fall:
			fall_state(delta) # Chama a função fall
		PlayerState.duck:
			duck_state(delta) # Chama a função duck 
		PlayerState.slide:
			slide_state(delta) # Chama a função slide
		PlayerState.hurt:
			hurt_state(delta) # Chama o estado de machucado
			
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
	jump_count += 1 # incrementa a contagem de pulos

func go_to_fall_state():
	status = PlayerState.fall # Define o status como fall
	animated_sprite_2d.play("fall") # Animação de queda
	
func go_to_duck_state():
	status = PlayerState.duck # Define o status como duck
	animated_sprite_2d.play("duck") # Animação de agachar
	set_small_collider()
	
# Sai do estado de duck
func exit_from_duck_state():
	set_large_collider() # Define o colisor largo
	
func go_to_slide_state():
	status = PlayerState.slide # Define o status como slide
	animated_sprite_2d.play("slide") # Animação de deslizar
	set_small_collider() # Define o colizor pequeno

# Sai do estado de slide
func exit_from_slide_state():
	set_large_collider()

func go_to_hurt_state():
	status = PlayerState.hurt # Define o status como hurt
	animated_sprite_2d.play("hurt") # Animação de machucado
	velocity.x = 0 # Zera a velocidade ao morrer
	reload_timer.start() # Inicia o tempo de reload

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
	# Se a tecla específica está pressionada, vai para o estado duck (apenas uma vez)
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

# Estado de andar
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
	
	# Deslizar
	if Input.is_action_just_pressed("duck"):
		# Se estiver andando e apertar para baixo, chama a função deslizar
		go_to_slide_state()
		return
	
	# Se não estiver no chão, chama o estado de queda
	if !is_on_floor():
		jump_count += 1 # Impede o pulo triplo no ar
		go_to_fall_state()
		return

# Estado de pular
func jump_state(delta: float):
	# Chama a função move
	move(delta) 
	
	# Pulo duplo
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	
	# Quando cair no chão ao pular, irá para o estado de queda
	if velocity.y > 0:
		go_to_fall_state()
		return
		
# Estado de queda
func fall_state(delta: float):
	# Chama a função move
	move(delta) 
	
	# Pulo duplo
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	# Ao voltar ao chão, vai para o estado idle ou walk
	if is_on_floor(): # Se estiver no chão:
		jump_count = 0 # Zera a contagem de pulos
		if velocity.x == 0: 
			go_to_idle_state() # Se estiver parado, vai para o estado de idle
		else:
			go_to_walk_state() # Senão, vai para o estado de andar
		return
	
		
# Estado de agachar
func duck_state(_delta):
	# Chama a função de atualizar direção
	update_direction()
	# Se a tecla não estiver pressionada
	if Input.is_action_just_released("duck"):
		exit_from_duck_state() # Sai do estado de agachar
		go_to_idle_state() # Volta ao estado de idle
		return

func slide_state(delta):
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	
	if Input.is_action_just_released("duck"):
		exit_from_slide_state()
		go_to_walk_state()
		return
	if velocity.x == 0:
		exit_from_slide_state()
		go_to_duck_state()
		return
		
func hurt_state(_delta):
	pass
	
# Movimentação do Player
func move(delta: float):
	
	# Chama a função de atualizar a direção
	update_direction()
		
	# Se direção:
	if direction:
		# Anda para frente
		velocity.x = move_toward(
			velocity.x,
			direction * max_speed,
			acceleration * delta
		)
	else:
		var decel = ground_deceleration if is_on_floor() else air_deceleration
		velocity.x = move_toward(
			velocity.x,
			0,
			decel * delta
		)

func update_direction():
	# Define a direção do Player (esquerda e direita)
	direction = Input.get_axis("left", "right") 
	
	# Verificação da direção
	if direction < 0:
		animated_sprite_2d.flip_h = true # direita
	elif direction > 0:
		animated_sprite_2d.flip_h = false # esquerda

# Verifica se o jogador pode pular
func can_jump() -> bool:
	return jump_count < max_jump_count

func set_small_collider():
	collison_shape_2d.shape.size.x = 12.0
	collison_shape_2d.shape.size.y = 10.0
	collison_shape_2d.position.y = 3.0
	
	hit_box_collision_shape_2d.shape.size.y = 10.0
	hit_box_collision_shape_2d.position.y = 3.0
	
func set_large_collider():
	collison_shape_2d.shape.size.x = 12.0
	collison_shape_2d.shape.size.y = 15.0
	collison_shape_2d.position.y = 0.5
	
	hit_box_collision_shape_2d.shape.size.y = 15.0
	hit_box_collision_shape_2d.position.y = 0.5
	
# Lógica de colisão entre HitBoxs
func _on_hit_box_area_entered(area: Area2D) -> void:
	# Se a área colidida estiver no grupo dos inimigos
	if area.is_in_group("Enemies"):
		hit_enemy(area) # Chama a função hit_enemy()
	elif area.is_in_group("Lethal Area"):
		hit_lethal_area()
# Colisão com um inimigo
func hit_enemy(area: Area2D):
	# Inimigo morto
	if velocity.y > 0:
		# Derrota o inimigo
		area.get_parent().take_damage() # Pode causar bugs
		go_to_jump_state()
	# Player morto
	else:
		if status != PlayerState.hurt:
			go_to_hurt_state()

# Colisão com a lethal area
func hit_lethal_area():
	go_to_hurt_state()

# Reset da Cena
func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
