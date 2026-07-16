extends Area2D

# Variável atribuída ao sprite do Spinning Bone
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Variáveis do Spinning Bone
var speed = 60 # Quantidade de pixels p/segundo
var direction = -1

func _process(delta: float) -> void:
	position.x += speed * delta * direction

# Define a direção do osso
func set_direction(skeleton_direction):
	direction = skeleton_direction
	# Rotaciona o osso se a direção for menor que 0
	animated_sprite_2d.flip_h = direction < 0

# Sinal de autodestruição
func _on_self_destruction_timeout() -> void:
	queue_free() # Libera a memória: destrói o objeto da cena

# Sinal que avisa quando entrar em uma área
func _on_area_entered(_area: Area2D) -> void:
	queue_free() # Resolve colisão

# Sinal que avisa quando colidir com um corpo
func _on_body_entered(body: Node2D) -> void:
	queue_free()
