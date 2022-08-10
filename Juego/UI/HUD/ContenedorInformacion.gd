class_name ContenedorInformacion
extends NinePatchRect

## Atributos export
export var auto_ocultar: bool = false setget set_auto_ocultar

## Atributos onready
onready var texto_contenedor: Label = $Label
onready var auto_ocultar_timer: Timer = $AutoOcultarTimer
onready var animaciones: AnimationPlayer = $AnimationPlayer

## Atributos
var esta_activado: bool = true setget set_esta_activado

## Getters and Setters
func set_auto_ocultar(ocultar: bool) -> void:
	auto_ocultar = ocultar

func set_esta_activado(valor: bool) -> void:
	esta_activado = valor

## Metodos Personalizados
func mostrar() -> void:
	if esta_activado:
		animaciones.play("mostrar")

func ocultar() -> void:
	if not esta_activado:
		animaciones.stop()
	animaciones.play("ocultar")

func mostrar_suavizado() -> void:
	if not esta_activado:
		return
	animaciones.play("mostrar_suavizado")
	if auto_ocultar:
		auto_ocultar_timer.start()

func ocultar_suavizado() -> void:
	if esta_activado:
		animaciones.play("ocultar_suavizado")

func modificar_texto(text: String) -> void:
	texto_contenedor.text = text

## Señal interna
func _on_AutoOcultarTimer_timeout() -> void:
	ocultar_suavizado()
