#Nivel.gd
class_name Nivel
extends Node2D

## Var export
export var explosion: PackedScene = null
export var meteorito: PackedScene = null
export var explosion_meteorito: PackedScene = null
export var sector_meteoritos: PackedScene = null
export var tiempo_transicion_camara: float = 1.0

## Atributos Onready
onready var contenedor_proyectiles:Node
onready var contenedor_meteoritos: Node
onready var contenedor_sector_meteoritos: Node
onready var camara_nivel: Camera2D = $CameraNivel
onready var camara_jugador: Camera2D = $Player/CamaraPlayer

## Atributos
var cantidad_meteoritos: int

## Metodos
func _ready() -> void:
	conectar_seniales()
	crear_contenedores()


## Metodos personalizados
func conectar_seniales() -> void:
	Eventos.connect("disparo", self, "_on_disparo")
	Eventos.connect("nave_destruida",self,"_on_nave_destruida")
	Eventos.connect("spawn_meteorito",self,"_on_spawn_meteoritos")
	Eventos.connect("meteorito_destruido",self,"_on_explosion_meteorito")
	Eventos.connect("nave_en_sector_peligro",self,"_on_nave_en_sector_peligro")


func crear_contenedores() -> void:
	contenedor_proyectiles = Node.new()
	contenedor_proyectiles.name = "ContenedorProyectiles"
	add_child(contenedor_proyectiles)
	contenedor_meteoritos = Node.new()
	contenedor_meteoritos.name = "ContenedorMeteoritos"
	add_child(contenedor_meteoritos)
	contenedor_sector_meteoritos = Node.new()
	contenedor_sector_meteoritos.name = "ContenedorSectorMeteoritos"
	add_child(contenedor_sector_meteoritos)


func crear_sector_meteoritos(centro_camara: Vector2, numero_peligro: int) -> void:
	cantidad_meteoritos = numero_peligro
	var new_sector_meteoritos: SectorMeteoritos = sector_meteoritos.instance()
	new_sector_meteoritos.crear(centro_camara,numero_peligro)
	camara_nivel.global_position = centro_camara
	contenedor_sector_meteoritos.add_child(new_sector_meteoritos)
	camara_nivel.zoom = camara_jugador.zoom
	camara_nivel.devolver_zoom_original()
	transicion_camara(camara_jugador.global_position, 
		camara_nivel.global_position, camara_nivel, tiempo_transicion_camara)


func transicion_camara(desde: Vector2, hasta: Vector2, camara_actual: Camera2D,
					tiempo_transicion: float) -> void:
	$TweenCamara.interpolate_property(camara_actual,"global_position", desde, hasta,
		tiempo_transicion, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camara_actual.current = true
	$TweenCamara.start()


func descontar_meteorito() -> void:
	cantidad_meteoritos -= 1
	print(cantidad_meteoritos)
	if cantidad_meteoritos <= 0:
		contenedor_sector_meteoritos.get_child(0).queue_free()
		camara_jugador.set_puede_hacer_zoom(true)
		var zoom_actual = camara_jugador.zoom
		camara_jugador.zoom = camara_nivel.zoom
		camara_jugador.zoom_suavizado(zoom_actual.x, zoom_actual.y, 1.0)
		transicion_camara(
			camara_nivel.global_position, 
			$Player.global_position, 
			camara_jugador, 
			tiempo_transicion_camara *0.10
			)

## Conexion selañes externas
func _on_disparo(proyectil: Proyectil) -> void:
	contenedor_proyectiles.add_child(proyectil)

func _on_nave_destruida(posicion: Vector2, num_explosiones: int) -> void:
	for _i in range(num_explosiones):
		var new_explosion: Node2D = explosion.instance()
		new_explosion.global_position = posicion
		add_child(new_explosion)
		yield(get_tree().create_timer(0.6),"timeout")

func _on_spawn_meteoritos(pos_spawn: Vector2, dir_meteorito: Vector2, tamanio: float) -> void:
	var new_meteorito: Meteorito = meteorito.instance()
	new_meteorito.crear(pos_spawn, dir_meteorito, tamanio)
	contenedor_meteoritos.add_child(new_meteorito)

func _on_explosion_meteorito(pos: Vector2) -> void:
	descontar_meteorito()
	var new_explosion: ExplosionMeteorito = explosion_meteorito.instance()
	new_explosion.global_position = pos
	add_child(new_explosion)

func _on_nave_en_sector_peligro(centro_cam: Vector2, tipo_peligro: String, num_peligros: int) -> void:
	if tipo_peligro == "Meteorito":
		# Vamos a crear dinamicamente al SectorMeteoritos
		crear_sector_meteoritos(centro_cam, num_peligros)
	elif tipo_peligro == "Enemigo":
		pass

# Señales internas
func _on_TweenCamara_tween_completed(object: Object, key: NodePath) -> void:
	if object.name == "CameraPlayer":
		object.global_position = $Player.global_position
