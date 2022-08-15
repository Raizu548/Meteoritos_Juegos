class_name EstacionReparacion
extends Node2D


onready var animaciones: AnimationPlayer = $AnimationPlayer

## Senñales internas
func _on_AreaReparacion_body_entered(body: Node) -> void:
	if body is Player:
		animaciones.play("activado")
		body.set_en_zona_reparacion(true)


func _on_AreaReparacion_body_exited(body: Node) -> void:
	if body is Player:
		animaciones.play("default")
		body.set_en_zona_reparacion(false)


func _on_AreaColision_body_entered(body: Node) -> void:
	if body.has_method("destruir"):
		body.destruir()
