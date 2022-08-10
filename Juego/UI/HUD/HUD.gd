extends CanvasLayer

## Atributos onready
onready var info_zona_carga: ContenedorInformacion = $InfoZonaCarga
onready var info_meteoritos: ContenedorInformacion = $InfoMeteoritos
onready var info_timepo_restante: ContenedorInformacion = $InfoTiempoRestante
onready var info_laser: ContenedorInformacionEnergia = $InfoLaser
onready var info_escudos: ContenedorInformacionEnergia = $InfoEscudos

## Metodos
func _ready() -> void:
	conectar_seniales()

## Metodos personalizados
func conectar_seniales() -> void:
	Eventos.connect("nivel_iniciado", self, "fade_out")
	Eventos.connect("nivel_terminado", self, "fade_in")
	Eventos.connect("detecto_zona_recarga", self,"_on_detecto_zona_recarga")
	Eventos.connect("cambio_numero_meteoritos", self, "_on_actualizar_info_meteoritos")
	Eventos.connect("actualizar_tiempo", self, "_on_actualizar_info_tiempo")
	Eventos.connect("cambio_energia_laser", self, "_on_actualizar_energia_laser")
	Eventos.connect("ocultar_energia_laser", info_laser, "ocultar")
	Eventos.connect("cambio_energia_escudo", self, "_on_actualizar_energia_escudo")
	Eventos.connect("ocultar_energia_escudo", info_escudos, "ocultar")
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")


func fade_in() -> void:
	$FadeCanvas/AnimationPlayer.play("fade_in")

func fade_out() -> void:
	$FadeCanvas/AnimationPlayer.play_backwards("fade_in")

## Señales externas
func _on_detecto_zona_recarga(en_zona: bool) -> void:
	if en_zona:
		info_zona_carga.mostrar_suavizado()
	else:
		info_zona_carga.ocultar_suavizado()

func _on_actualizar_info_meteoritos(numero: int) -> void:
	info_meteoritos.mostrar_suavizado()
	info_meteoritos.modificar_texto("Meteoritos Restantes\n {cantidad}".format({"cantidad":numero}))

func _on_actualizar_info_tiempo(tiempo_restante: int) -> void:
# warning-ignore:narrowing_conversion
	var minutos: int = float(tiempo_restante * 0.01666666666667)
	var segundos: int = tiempo_restante % 60
	info_timepo_restante.modificar_texto("Tiempo restante\n%02d:%02d" % [minutos, segundos])
	
	if tiempo_restante % 10 == 0:
		info_timepo_restante.mostrar_suavizado()
	
	if tiempo_restante == 11:
		info_timepo_restante.set_auto_ocultar(false)
	elif tiempo_restante == 0:
		info_timepo_restante.ocultar()

func _on_actualizar_energia_laser(energia_max: float, energia_actual: float) -> void:
	info_laser.mostrar()
	info_laser.actualizar_energia(energia_max, energia_actual)

func _on_actualizar_energia_escudo(energia_max: float, energia_actual: float) -> void:
	info_escudos.mostrar()
	info_escudos.actualizar_energia(energia_max, energia_actual)

func _on_nave_destruida(nave: NaveBase, _posicion, _explosion) -> void:
	if nave is Player:
		get_tree().call_group("contenedor_info", "set_esta_activado", false)
		get_tree().call_group("contenedor_info", "ocultar")
