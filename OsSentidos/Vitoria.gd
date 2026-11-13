extends Control

func _on_VoltarMenu_pressed():
	Transicao.mudar_cena("res://MenuInicial.tscn")
	
func _ready():
	var musica = get_node_or_null("MusicaVitoria")

	if musica != null and musica.stream != null:
		musica.play()
		print("Musica da vitoria iniciada!")
	else:
		print("ERRO: Musica da vitoria nao encontrada!")

