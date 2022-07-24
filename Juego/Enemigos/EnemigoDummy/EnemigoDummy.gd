extends Node2D

## Var onready
onready var canion: Canion = $Canion

#Atributos
var hitpoints:float = 10.0

# Metodos personalizados
func recibir_danio(danio: float) -> void:
	hitpoints -= danio
	destruirse()

func destruirse() -> void:
	if hitpoints <= 0:
		queue_free()

## Metodos
func _process(_delta: float) -> void:
	canion.set_esta_disparando(true)

## Señal interna
func _on_Area2D_body_entered(body):
	if body is Player:
		body.destruir()
		
