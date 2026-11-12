extends Control

func _ready():
	$Jogar.add_color_override("font_color_hover", Color("#ffd966"))
	$Creditos.add_color_override("font_color_hover", Color("#ffd966"))
	$Sair.add_color_override("font_color_hover", Color("#ffd966"))
	$AudioStreamPlayer.play()
	print("Música carregada: ", $AudioStreamPlayer.stream != null)
	print("Música tocando: ", $AudioStreamPlayer.playing)
	print("Volume: ", $AudioStreamPlayer.volume_db)
		
func _on_Jogar_pressed():
	Transicao.mudar_cena("res://Batalha.tscn")

func _on_Creditos_pressed():
	Transicao.mudar_cena("res://Vitoria.tscn")

func _on_Sair_pressed():
	get_tree().quit()
