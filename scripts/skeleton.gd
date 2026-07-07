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
# Define uma variável atribuída a RayCast2D (Wall Detector)
@onready var wall_detector: RayCast2D = $WallDetector
# Define uma variável atribuída a RayCast2D (Ground Detector)
@onready var ground_detector: RayCast2D = $GroundDetector

# Variável constante da velocidade
const SPEED = 30.0

const JUMP_VELOCITY = -400.0

var status: SkeletonState # Recebe os valores da Enum

# Define a direção do Skeleton
var direction = 1

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

func dead_state(_delta):
	pass;

# Ao tomar dano, chama a função go_to_dead_state
func take_damage():
	go_to_dead_state()
