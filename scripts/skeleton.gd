# Importa o Skeleton
extends CharacterBody2D

# Define os estados do Skeleton
enum SkeletonState {
	walk,
	dead
}

# Define uma variável atribuída a animação do Skeleton
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# Define uma variável atribuída a HitBox
@onready var hit_box: Area2D = $HitBox

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var status: SkeletonState # Recebe os valores da Enum

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
		SkeletonState.dead:
			dead_state(delta) # Chama a função dead
			
	move_and_slide()

func go_to_walk_state():
	status = SkeletonState.walk # Define o status como walk
	animated_sprite_2d.play("walk") # Animação de andar

func go_to_dead_state():
	status = SkeletonState.dead # Define o status como dead
	animated_sprite_2d.play("dead") # Animação de morto
	hit_box.process_mode = Node.PROCESS_MODE_DISABLED # Desativa a HitBox
	
func walk_state(_delta):
	pass

func dead_state(_delta):
	pass

# Ao tomar dano, chama a função go_to_dead_state
func take_damage():
	go_to_dead_state()
