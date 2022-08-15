class_name EstacionReparacion
extends Node2D

onready var animaciones: AnimationPlayer = $AnimationPlayer

func _on_AreaReparacion_body_entered(body: Node) -> void:
	if body is Player:
		animaciones.play("activado")


func _on_AreaReparacion_body_exited(body: Node) -> void:
	if body is Player:
		animaciones.play("default")
