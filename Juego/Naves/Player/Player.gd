class_name Player
extends RigidBody2D

# Enums
enum ESTADO{SPAWN, VIVO, INVENCIBLE, MUERTO}

## Atributos export
export var potencia_motor: int = 20
export var potencia_rotacion: int = 200
export var estela_maxima: int = 150
export var hitspoint: float = 15.0

## Atributos
var empuje: Vector2 = Vector2.ZERO
var dir_rotacion: int = 0
var estado_actual:int = ESTADO.SPAWN

## Atributos onready
onready var canion: Canion = $Canion
onready var laser: RayoLaser = $LaserBeam2D
onready var estela: Estela = $EstelaPuntoInicial/Trail2D
onready var motor_sfx: Motor = $MotorSFX
onready var colisionador: CollisionShape2D = $CollisionShape2D
onready var impactoSFX: AudioStreamPlayer = $ImpactoSFX
onready var escudo: Escudo = $Escudo

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
			Eventos.emit_signal("nave_destruida",global_position, 3)
			queue_free()
		_:
			print("Error de estado")
	
	estado_actual = nuevo_estado

func esta_input_activado() -> bool:
	if estado_actual in [ESTADO.MUERTO, ESTADO.SPAWN]:
		return false
	return true

func recibir_danio(danio: float) -> void:
	impactoSFX.play()
	hitspoint -= danio
	if hitspoint <= 0:
		destruir()

func destruir() -> void:
	controlador_estados(ESTADO.MUERTO)




## Metodos
func _ready() -> void:
	controlador_estados(estado_actual)

func _unhandled_input(event: InputEvent) -> void:
	if not esta_input_activado():
		return
	
	# Disparo Rayo
	if event.is_action_pressed("disparo_secundario"):
		laser.set_is_casting(true)
	
	if event.is_action_released("disparo_secundario"):
		laser.set_is_casting(false)
	
	# Control Estela y sonido motor
	if event.is_action_pressed("mover_adelante"):
		estela.set_max_points(estela_maxima)
		motor_sfx.sonido_on()
	elif event.is_action_pressed("mover_atras"):
		estela.set_max_points(0)
		motor_sfx.sonido_on()
	
	if (event.is_action_released("mover_adelante") or event.is_action_released("mover_atras")):
		motor_sfx.sonido_off()
	
	# Control Escudo
	if event.is_action_pressed("escudo") and not escudo.get_esta_activado():
		escudo.activar()

func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	apply_torque_impulse(dir_rotacion * potencia_rotacion)
	apply_central_impulse(empuje.rotated(rotation))

func _process(_delta: float) -> void:
	player_input()
	
func player_input() -> void:
	if not esta_input_activado():
		return
	
	# Empuje
	empuje = Vector2.ZERO
	if Input.is_action_pressed("mover_adelante"):
		empuje = Vector2(potencia_motor, 0)
	elif Input.is_action_pressed("mover_atras"):
		empuje = Vector2(-potencia_motor, 0)
	
	# Rotacion
	dir_rotacion = 0
	if Input.is_action_pressed("rotar_horario"):
		dir_rotacion += 1
	elif Input.is_action_pressed("rotar_antihorario"):
		dir_rotacion -= 1
	
	# Disparo
	if Input.is_action_just_pressed("disparo_principal"):
		canion.set_esta_disparando(true)
	if Input.is_action_just_released("disparo_principal"):
		canion.set_esta_disparando(false)


## Señales
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		controlador_estados(ESTADO.VIVO)

func _on_Player_body_entered(body: Node) -> void:
	if body is Meteorito:
		body.destruirse()
		destruir()
