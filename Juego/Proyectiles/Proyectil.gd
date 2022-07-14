class_name Proyectil
extends Area2D


## Atributos
var velocidad: Vector2 = Vector2.ZERO
var danio: float = 2.0

## Constructor
func crear(pos: Vector2, dir: float, vel: float, danio_p: int) -> void:
	position = pos
	rotation = dir
	velocidad = Vector2(vel,0).rotated(dir)

## Metodos Personalizado
func daniar(otro_cuerpo: CollisionObject2D) -> void:
	if otro_cuerpo.has_method("recibir_danio"):
		otro_cuerpo.recibir_danio(danio)
	
	queue_free()


## Metodos
func _physics_process(delta: float) -> void:
	position += velocidad * delta

## Señales internas
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Proyectil_area_entered(area: Area2D) -> void:
	daniar(area)

func _on_Proyectil_body_entered(body: Node) -> void:
	daniar(body)
