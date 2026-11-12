extends CanvasLayer

onready var fade = $Fade

var em_transicao = false

func _ready():
	fade.color = Color(0, 0, 0, 1)
	fade.show()

	var tween = create_tween()
	tween.tween_property(
		fade, "color:a", 0.0, 0.5
	)

func mudar_cena(caminho):
	if em_transicao:
		return

	em_transicao = true

	var tween = create_tween()
	tween.tween_property(
		fade, "color:a", 1.0, 0.5
	)

	yield(tween, "finished")

	get_tree().change_scene(caminho)

	fade.color.a = 1.0

	var tween_entrada = create_tween()
	tween_entrada.tween_property(
		fade, "color:a", 0.0, 0.5
	)

	yield(tween_entrada, "finished")

	em_transicao = false
