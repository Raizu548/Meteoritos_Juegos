class_name NaveBase
extends RigidBody2D

# Enums
enum ESTADO{SPAWN, VIVO, INVENCIBLE, MUERTO}

## Atributos export
export var hitspoint: float = 20.0
export var numero_explosiones = 1

## Atributos
var estado_actual:int = ESTADO.SPAWN

## Atributos onready
onready var colisionador: CollisionShape2D = $CollisionShape2D
onready var canion: Canion = $Canion
onready var impactoSFX: AudioStreamPlayer = $ImpactoSFX
onready var barra_salud: ProgressBar = $BarraSalud


## Metodos custom
func controlador_estados(nuevo_estado: int) -> void:
	match nuevo_estado:
		ESTADO.SPAWN:
			colisionador.set_deferred("disabled",true)
			canion.set_puede_disparar(false)
		ESTADO.VIVO:
			canion.set_puede_disparar(true)
			colisionador.set_deferred("disabled",false)
		ESTADO.INVENCIBLE:
			colisionador.set_deferred("disabled",true)
		ESTADO.MUERTO:
			canion.set_puede_disparar(true)
			colisionador.set_deferred("disabled",true)
			Eventos.emit_signal("nave_destruida",self, global_position, numero_explosiones)
			queue_free()
		_:
			print("Error de estado")
	
	estado_actual = nuevo_estado


func recibir_danio(danio: float) -> void:
	impactoSFX.play()
	hitspoint -= danio
	if hitspoint <= 0:
		destruir()
	
	barra_salud.controlar_barra(hitspoint, true)

func destruir() -> void:
	controlador_estados(ESTADO.MUERTO)


## Metodos
func _ready() -> void:
	barra_salud.set_valores(hitspoint)
	controlador_estados(estado_actual)


## Señales internas
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		controlador_estados(ESTADO.VIVO)

func _on_Player_body_entered(body: Node) -> void:
	if body is Meteorito:
		body.destruirse()
		destruir()
