class_name Escudo
extends Area2D

## Var export
export var energia: float = 8.0
export var radio_desgaste: float = -1.6

## Var onredy
onready var animaciones: AnimationPlayer = $AnimationPlayer

## Var Atributos
var esta_activado: bool = false setget ,get_esta_activado


## Setter and Getters
func get_esta_activado() -> bool:
	return esta_activado

## Metodos
func _ready() -> void:
	set_process(false)
	controlar_colisionador(true)

func _process(delta: float) -> void:
	energia += radio_desgaste * delta
	
	if energia <= 0.0:
		desactivar()

## Metodosa personalizado
func controlar_colisionador(esta_desactivado: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", esta_desactivado)

func activar() -> void:
	if energia <= 0.0:
		return
	
	esta_activado = true
	controlar_colisionador(false)
	animaciones.play("activando")

func desactivar() -> void:
	set_process(false)
	esta_activado = false
	controlar_colisionador(true)
	animaciones.play_backwards("activando")

## Señales internas
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "activando" and esta_activado:
		animaciones.play("activado")
		set_process(true)


func _on_body_entered(body: Node) -> void:
	body.queue_free()
