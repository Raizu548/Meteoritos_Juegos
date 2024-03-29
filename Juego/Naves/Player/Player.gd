class_name Player
extends NaveBase

## Atributo export
export var potencia_motor: int = 30
export var potencia_rotacion: int = 200
export var estela_maxima: int = 150
export var regeneracion: float = 0.1

## Atributos
var empuje: Vector2 = Vector2.ZERO
var dir_rotacion: int = 0
var en_zona_reparacion: bool = false setget set_en_zona_reparacion
var vida_max: float

## Atributos onready
onready var escudo: Escudo = $Escudo
onready var laser: RayoLaser = $LaserBeam2D
onready var estela: Estela = $EstelaPuntoInicial/Trail2D
onready var motor_sfx: Motor = $MotorSFX

## Setters and Getters
func get_laser() -> RayoLaser:
	return laser

func get_escudo() -> Escudo:
	return escudo

func set_en_zona_reparacion(valor: bool) -> void:
	en_zona_reparacion = valor

## Metodos
func _ready() -> void:
	DatosJuego.set_player_actual(self)
	vida_max = hitspoint

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
	elif event.is_action_pressed("mover_atras"):
		estela.set_max_points(0)
	
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
	if en_zona_reparacion:
		recuperar_vida()


## Metodos personalizados
func player_input() -> void:
	if not esta_input_activado():
		return
	
	# Empuje
	empuje = Vector2.ZERO
	if Input.is_action_pressed("mover_adelante"):
		empuje = Vector2(potencia_motor, 0)
		motor_sfx.sonido_on()
	elif Input.is_action_pressed("mover_atras"):
		empuje = Vector2(-potencia_motor, 0)
		motor_sfx.sonido_on()
	
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

func esta_input_activado() -> bool:
	if estado_actual in [ESTADO.MUERTO, ESTADO.SPAWN]:
		return false
	return true

func desactivar_controles() -> void:
	controlador_estados(ESTADO.SPAWN)
	empuje = Vector2.ZERO
	motor_sfx.sonido_off()
	laser.set_is_casting(false)

func recuperar_vida() -> void:
	hitspoint += regeneracion
	clamp(hitspoint,0,vida_max)
	barra_salud.controlar_barra(hitspoint, true)
