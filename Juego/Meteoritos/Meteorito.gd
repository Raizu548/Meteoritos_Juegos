class_name Meteorito
extends RigidBody2D

## Atributos Export
export var vel_lineal_base: Vector2 = Vector2(300.0, 300.0)
export var vel_ang_base: float = 3.0
export var hitpoints_base: float = 10.0

## Atributos Onready
onready var animacion_meteorito: AnimationPlayer = $AnimationPlayer

## Atributos
var hitpoints: float
var esta_en_sector: bool = true setget set_esta_en_sector
var pos_spawn_original: Vector2
var vel_spawn_original: Vector2

## Constructor
func crear(pos: Vector2, direccion: Vector2, tamanio: float):
	position = pos
	pos_spawn_original = pos
	# Calcular Masa, tamaño de Sprite y de Colisionador
	mass *= tamanio
	$Sprite.scale = Vector2.ONE * tamanio
	# radio = diametro / 2
	var radio: int = int($Sprite.texture.get_size().x / 2.3 * tamanio)
	var forma_colision: CircleShape2D = CircleShape2D.new()
	forma_colision.radius = radio
	$CollisionShape2D.shape = forma_colision
	# Calcular velocidades
	linear_velocity = (vel_lineal_base * direccion / tamanio) * generar_velocidad_aleatorio()
	vel_spawn_original = linear_velocity
	angular_velocity = (vel_ang_base / tamanio) * generar_velocidad_aleatorio()
	# Calcular hitpoints
	hitpoints = hitpoints_base * tamanio


## Getter and Setter
func set_esta_en_sector(valor: bool) -> void:
	esta_en_sector = valor


# Metodos personalizados
func recibir_danio(danio: float) -> void:
	hitpoints -= danio
	if hitpoints <= 0:
		destruirse()
	
	animacion_meteorito.play("impacto")

func destruirse() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	Eventos.emit_signal("meteorito_destruido",global_position)
	queue_free()

func generar_velocidad_aleatorio() -> float:
	randomize()
	return rand_range(1.1, 1.4)

## Metodos
func _ready() -> void:
	angular_velocity = vel_ang_base

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if esta_en_sector:
		return
	
	var mi_transform := state.get_transform()
	mi_transform.origin = pos_spawn_original
	linear_velocity = vel_spawn_original
	state.set_transform(mi_transform)
	esta_en_sector = true
