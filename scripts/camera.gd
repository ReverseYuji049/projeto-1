extends Camera2D

var target: Node2D # Player como alvo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_target()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = target.position # Pega a posição do alvo para segui-la
	
func get_target():
	# Pega a árvore da hierarquia onde o objeto estiver.
	# Pega todos os nós do grupo Player.
	var nodes = get_tree().get_nodes_in_group("Player") # Lista de nós
	# Situação de erro: não encontrou o Player.
	if nodes.size() == 0:
		push_error("Player não encontrado.")
		return
		
	# Se encontrou o Player (o primeiro nó): retorna o Player
	target = nodes[0]
	
