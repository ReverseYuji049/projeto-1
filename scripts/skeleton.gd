# Importa o Skeleton
extends CharacterBody2D

# Define os estados do Skeleton
enum SkeletonState {
	walk,
	attack,
	dead
}
# Instância do objeto/cena 'SpinningBone'
const SPINNING_BONE = preload("uid://bwtrkfq21csi6")
# Define uma variável atribuída a animação do Skeleton
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# Define uma variável atribuída a HitBox
@onready var hit_box: Area2D = $HitBox
# Define uma variável atribuída a RayCast2D (Wall Detector)
@onready var wall_detector: RayCast2D = $WallDetector
# Define uma variável atribuída a RayCast2D (Ground Detector)
@onready var ground_detector: RayCast2D = $GroundDetector
# Define uma variável atribuída a RayCast2D (Player Detector) 
@onready var player_detector: RayCast2D = $PlayerDetector
# Define uma variável que define onde o osso será arremessado 
@onready var bone_start_position: Node2D = $BoneStartPosition

# Variável constante da velocidade
const SPEED = 30.0

const JUMP_VELOCITY = -400.0

var status: SkeletonState # Recebe os valores da Enum

# Define a direção do Skeleton
var direction = 1

# Variável que define quando poderá arremessar o osso
var can_throw = true

# Começa no estado de walk
func _ready() -> void:
	go_to_walk_state()

# Função de física do Skeleton
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		SkeletonState.walk:
			walk_state(delta) # Chama a função walk
		SkeletonState.attack:
			attack_state(delta) # Chama a função attack
		SkeletonState.dead:
			dead_state(delta) # Chama a função dead
			
	move_and_slide()

func go_to_walk_state():
	status = SkeletonState.walk # Define o status como walk
	animated_sprite_2d.play("walk") # Animação de andar

func go_to_attack_state():
	status = SkeletonState.attack # Define o status como attack
	animated_sprite_2d.play("attack") # Animação de ataque
	velocity = Vector2.ZERO # Zera a velocidade do Skeleton ao atacar
	can_throw = true # Permite o ataque de osso

func go_to_dead_state():
	status = SkeletonState.dead; # Define o status como dead
	animated_sprite_2d.play("dead"); # Animação de morto
	hit_box.process_mode = Node.PROCESS_MODE_DISABLED; # Desativa a HitBox
	velocity = Vector2.ZERO; # Zera a velocidade ao ser derrotado
	
func walk_state(_delta):
	velocity.x = SPEED * direction;
	# Localiza colizão
	if wall_detector.is_colliding():
		scale.x *= -1; # Inverte a escala
		direction *= -1; # Inverte a direção
	# Localiza fim de terreno
	if not ground_detector.is_colliding():
		scale.x *= -1; # Inverte a escala
		direction *= -1; # Inverte a direção
	if player_detector.is_colliding():
		go_to_attack_state() # Chama a função de ataque

# Ataque de projétil
func attack_state(_delta):
	# Só atirará o osso, quando o frame for o 2 e o can_throw for verdadeira
	if animated_sprite_2d.frame == 2 && can_throw:
		throw_bone() # Chama a função de arremesso do osso
		can_throw = false # Só pode atacar uma vez

func dead_state(_delta):
	pass;

# Ao tomar dano, chama a função go_to_dead_state
func take_damage():
	go_to_dead_state()
	
# Arremessa o projétil de osso
func throw_bone():
	# Cria a instância do Spinning Bone
	var new_bone = SPINNING_BONE.instantiate()
	# Adiciona o osso como irmão do nó Skeleton
	add_sibling(new_bone)
	# O osso fica na mesma posição do Skeleton (BoneStartPosition)
	new_bone.position = bone_start_position.global_position 
	# O osso fica na mesma direção do Skeleton
	new_bone.set_direction(self.direction)
	

# Sinal de terminar animação
func _on_animated_sprite_2d_animation_finished() -> void:
	# Finaliza a animação de ataque e chama a função de walk
	if animated_sprite_2d.animation == "attack":
		go_to_walk_state()
		return
