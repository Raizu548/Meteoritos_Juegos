class_name EnemigoOrbital
extends EnemigoBase

## Atributos export
export var rango_max_ataque: float = 1400.0
export var velocidad: float = 400.0

## Atributos onready
onready var detector_obstaculo: RayCast2D = $DetectorObstaculo

## Atributo
var base_duenia: Node2D
var ruta: Path2D
var path_follow: PathFollow2D

## Constructor
func crear(pos: Vector2, duenia: Node2D, ruta_duenia: Path2D) -> void:
	global_position = pos
	base_duenia = duenia
	ruta = ruta_duenia
	path_follow = PathFollow2D.new()
	ruta.add_child(path_follow)

## Metodos
func _ready() -> void:
	Eventos.connect("base_destruida",self,"_on_base_destruida")
	# TEmporal
	canion.set_esta_disparando(true)

func _process(delta: float) -> void:
	path_follow.offset += velocidad * delta
	position = path_follow.global_position

## Metodos personalizados
func rotar_hacia_player() -> void:
	.rotar_hacia_player()
	if dir_player.length() > rango_max_ataque or detector_obstaculo.is_colliding():
		canion.set_esta_disparando(false)
	else:
		canion.set_esta_disparando(true)

## Señales externas
func _on_base_destruida(base: Node2D, _pos) -> void:
	if base == base_duenia:
		destruir()
