class_name SectorMeteoritos
extends Node2D

## Atributos export
export var cantidad_meteoritos: int = 10
export var intervalo_spawn: float = 1.2

## Atributos
var spawnerArray: Array

## Constructor
func crear(pos: Vector2, meteoritos: int) -> void:
	global_position = pos
	cantidad_meteoritos = meteoritos

## Metodos
func _ready() -> void:
	almacenar_spawners()
	conectar_seniales_detectores()
	$TimerSpawner.wait_time = intervalo_spawn

## Metodos personalizados
func almacenar_spawners() -> void:
	for spawner in $Spawner.get_children():
		spawnerArray.append(spawner)

func spawner_aleatorio() -> int:
	randomize()
	# Retorna un numero aleatorio entre 0 - el tamaño del arreglo
	return randi() % spawnerArray.size()

func conectar_seniales_detectores() -> void:
	for detector in $DetectorFueraZona.get_children():
		detector.connect("body_entered",self,"_on_detector_body_entered")

## Señales internas
func _on_SpawnTimer_timeout() -> void:
	if cantidad_meteoritos == 0:
		$TimerSpawner.stop()
		return
	
	spawnerArray[spawner_aleatorio()].spawnear_meteorito()
	cantidad_meteoritos -= 1

func _on_detector_body_entered(body: Node) -> void:
	body.set_esta_en_sector(false)
