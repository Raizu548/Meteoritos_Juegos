class_name BaseEnemiga
extends Node2D

## Atributos Export
export var hitpoints: float = 30.0

## Atributos onready
onready var impacto_sfx: AudioStreamPlayer2D = $ImpactoSFX

## Atributos
var esta_destruida: bool = false

## Metodo
func _ready() -> void:
	$AnimationPlayer.play(elegir_animacion_aleatoria())

## Metodos Personalizados
func elegir_animacion_aleatoria() -> String:
	randomize()
	var num_anim: int = $AnimationPlayer.get_animation_list().size() - 1
	var indice_anim_aleatoria: int = randi() % num_anim +1
	var lista_animacion: Array = $AnimationPlayer.get_animation_list()
	return lista_animacion[indice_anim_aleatoria]

func recibir_danio(danio:float) -> void:
	hitpoints -= danio
	
	if hitpoints <= 0 and not esta_destruida:
		esta_destruida = true
		destruir()
	
	impacto_sfx.play()

func destruir() -> void:
	var posiciones_partes = [
		$Sprites/Sprite.global_position,
		$Sprites/Sprite2.global_position,
		$Sprites/Sprite3.global_position,
		$Sprites/Sprite4.global_position
	]
	
	Eventos.emit_signal("base_destruida",posiciones_partes)
	queue_free()

## Señales internas
func _on_AreaColision_body_entered(body: Node) -> void:
	if body.has_method("destruir"):
		body.destruir()
