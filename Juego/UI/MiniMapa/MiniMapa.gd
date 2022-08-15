extends MarginContainer

## Atributos export
export var escala_zoom: float = 4.0
export var tiempo_visible: float = 5.0

## Atributos onready
onready var zona_renderizado: TextureRect = $CuadroMiniMapa/ContenedorIconos/ZonaRenderizadoMinimap
onready var icono_player: Sprite = $CuadroMiniMapa/ContenedorIconos/ZonaRenderizadoMinimap/IconoPlayer
onready var icon_base: Sprite = $CuadroMiniMapa/ContenedorIconos/ZonaRenderizadoMinimap/IconBaseEnemiga
onready var icon_estacion: Sprite = $CuadroMiniMapa/ContenedorIconos/ZonaRenderizadoMinimap/IconEstacionRecarga
onready var icon_rele: Sprite = $CuadroMiniMapa/ContenedorIconos/ZonaRenderizadoMinimap/IconoRele
onready var icon_interceptor: Sprite = $CuadroMiniMapa/ContenedorIconos/ZonaRenderizadoMinimap/IconoInterceptor
onready var icon_reparacion: Sprite = $CuadroMiniMapa/ContenedorIconos/ZonaRenderizadoMinimap/IconoReparacion
onready var items_mini_map: Dictionary = {}
onready var timer_visibilidad: Timer = $TimerVisibilidad
onready var tween_visibilidad: Tween = $TweenVisibilidad

## Atributos
var escala_grilla: Vector2
var player: Player = null
var esta_activado: bool = true setget set_esta_activado

## Setters and Getters
func set_esta_activado(valor: bool) -> void:
	if valor:
		timer_visibilidad.start()
	
	esta_activado = valor
	tween_visibilidad.interpolate_property(self, "modulate", Color(1,1,1, not valor),
		Color(1,1,1, valor), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_visibilidad.start()

## Metodos
func _ready() -> void:
	set_process(false)
	timer_visibilidad.wait_time = tiempo_visible
	icono_player.position = zona_renderizado.rect_size * 0.5
	escala_grilla = zona_renderizado.rect_size / (get_viewport_rect().size * escala_zoom)
	conectar_seniales()
	

func _process(delta: float) -> void:
	if not player:
		return
	
	icono_player.rotation_degrees = player.rotation_degrees + 90
	modificar_posicion_iconos()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("minimapa"):
		set_esta_activado(not esta_activado)

## Metodos personalizados
func conectar_seniales() -> void:
	Eventos.connect("nivel_iniciado", self, "_on_nivel_iniciado")
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")
	Eventos.connect("minimapa_objeto_creado", self, "obtener_objetos_minimapa")
	Eventos.connect("minimapa_objeto_destruido", self, "quitar_objeto")

func obtener_objetos_minimapa() -> void:
	var objetos_en_ventana: Array = get_tree().get_nodes_in_group("minimapa")
	for objeto in objetos_en_ventana:
		if not items_mini_map.has(objeto):
			var sprite_icon: Sprite
			if objeto is BaseEnemiga:
				sprite_icon = icon_base.duplicate()
			elif objeto is EstacionRecarga:
				sprite_icon = icon_estacion.duplicate()
			elif objeto is EnemigoInterceptor:
				sprite_icon = icon_interceptor.duplicate()
			elif objeto is ReleMasa:
				sprite_icon = icon_rele.duplicate()
			elif objeto is EstacionReparacion:
				sprite_icon = icon_reparacion.duplicate()
				
			
			items_mini_map[objeto] = sprite_icon
			items_mini_map[objeto].visible = true
			zona_renderizado.add_child(items_mini_map[objeto])

func modificar_posicion_iconos() -> void:
	for item in items_mini_map:
		var item_icono: Sprite = items_mini_map[item]
		var offset_pos: Vector2 = item.position - player.position
		#var pos_icon: Vector2 = offset_pos * escala_grilla + (zona_renderizado.rect_size * 0.5)
		var pos_icon: Vector2 = offset_pos * escala_grilla + icono_player.position
		pos_icon.x = clamp(pos_icon.x, 0, zona_renderizado.rect_size.x)
		pos_icon.y = clamp(pos_icon.y, 0, zona_renderizado.rect_size.y)
		item_icono.position = pos_icon
		
		if zona_renderizado.get_rect().has_point(pos_icon - zona_renderizado.rect_position):
			item_icono.scale = Vector2(0.5, 0.5)
		else:
			item_icono.scale = Vector2(0.3, 0.3)

func quitar_objeto(objeto: Node2D) -> void:
	if objeto in items_mini_map:
		items_mini_map[objeto].queue_free()
		items_mini_map.erase(objeto)

## Señales externas
func _on_nivel_iniciado() -> void:
	player = DatosJuego.get_player_actual()
	obtener_objetos_minimapa()
	set_process(true)

func _on_nave_destruida(nave: NaveBase, _posicion, _explosiones) -> void:
	if nave is Player:
		player = null

## Señales internas
func _on_TimerVisibilidad_timeout() -> void:
	if esta_activado:
		set_esta_activado(false)
