class_name EstacionRecarga
extends Node2D

## Atributo export
export var energia: float = 6.0
export var radio_energia_entregada: float = 0.05

## Atributos onready
onready var carga_sfx: AudioStreamPlayer = $CargaSFX

## Atributos
var nave_player: Player = null
var player_en_zona: bool = false

## Metodos
func _unhandled_input(event: InputEvent) -> void:
	if not puede_recargar(event):
		return
	
	controlar_energia()
	
	if event.is_action("recargar_escudo"):
		nave_player.get_escudo().controlar_energia(radio_energia_entregada)
	elif event.is_action("recargar_laser"):
		nave_player.get_laser().controlar_energia(radio_energia_entregada)

## Metodos Personalizado
func puede_recargar(event: InputEvent) -> bool:
	var hay_input = event.is_action("recargar_escudo") or event.is_action("recargar_laser")
	if hay_input and player_en_zona and energia > 0.0:
		if !carga_sfx.playing:
			carga_sfx.play()
		return true
	
	return false

func controlar_energia() -> void:
	energia -= radio_energia_entregada
	if energia <= 0.0:
		$VacioSFX.play()

## Señales internas
func _on_AreaColision_body_entered(body):
	if body.has_method("destruir"):
		body.destruir()

# Aplica gravedad cuando entra en el area
func _on_AreaRecarga_body_entered(body):
	if body is Player:
		player_en_zona = true
		nave_player = body
		
	body.set_gravity_scale(0.1)


func _on_AreaRecarga_body_exited(body):
	if body is Player:
		player_en_zona = false
	
	body.set_gravity_scale(0.0)
