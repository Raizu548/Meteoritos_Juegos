class_name Canion
extends Node2D

## Atributos export
export var proyectil: PackedScene = null
export var cadencia_disparo: float = 0.8
export var velocidad_proyectil: int = 100
export var danio_proyectil: int = 1

## Atributos onready
onready var timer_enfriamiento: Timer = $TiempoEnfirmaiento
onready var disparo_sfx: AudioStreamPlayer2D = $DisparoSFX
onready var esta_enfriando: bool = true
onready var esta_disparando: bool = false setget set_esta_disparando

## Atributos
var puntos_disparo: Array = []
var puede_disparar: bool = false setget set_puede_disparar

## Setters y Getters
func set_esta_disparando(disparando: bool) -> void:
	esta_disparando = disparando

func set_puede_disparar(puede_d: bool) -> void:
	puede_disparar = puede_d

## Metodos
func _ready() -> void:
	almacenar_puntos_disparos()
	timer_enfriamiento.wait_time = cadencia_disparo

func _process(_delta: float) -> void:
	if esta_disparando and esta_enfriando and puede_disparar:
		disparar()

## Metodos personalizado
func almacenar_puntos_disparos() -> void:
	for nodo in get_children():
		if nodo is Position2D:
			puntos_disparo.append(nodo)


func disparar() -> void:
	esta_enfriando = false
	disparo_sfx.play()
	timer_enfriamiento.start()
	for punto_disparo in puntos_disparo:
		var new_proyectil: Proyectil = proyectil.instance()
		new_proyectil.crear(punto_disparo.global_position,get_owner().rotation,
			velocidad_proyectil,danio_proyectil)
		Eventos.emit_signal("disparo", new_proyectil)


func _on_TiempoEnfirmaiento_timeout() -> void:
	esta_enfriando = true
