extends Area2D

# Variáveis do Spinning Bone
var speed = 100 # Quantidade de pixels p/segundo
var direction = -1

func _process(delta: float) -> void:
	position.x += speed * delta * direction
