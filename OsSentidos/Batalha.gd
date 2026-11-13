
extends Control

var vida_chefe = 100
var vida_maxima_chefe = 100
var dano_chefe = 15

var turno_atual = 0
var chefe_derrotado = false
var game_over = false
var chefe_agindo = false

var carregando_especial = false
var chance_especial = 20

var personagens = [
	{"nome": "Artista Marcial", "vida": 100, "max": 100, "dano": 20, "defendendo": false},
	{"nome": "Confeiteira", "vida": 80, "max": 80, "dano": 25, "defendendo": false},
	{"nome": "Maestro", "vida": 120, "max": 120, "dano": 15, "defendendo": false},
	{"nome": "Desenhista", "vida": 90, "max": 90, "dano": 20, "defendendo": false},
	{"nome": "Florista", "vida": 85, "max": 85, "dano": 10, "defendendo": false}
]

var chefes = [
	{"nome": "Chefe 1", "vida": 180, "dano": 16},
	{"nome": "Chefe 2", "vida": 240, "dano": 19},
	{"nome": "Chefe 3", "vida": 300, "dano": 22},
	{"nome": "Chefe 4", "vida": 360, "dano": 25},
	{"nome": "Chefe 5", "vida": 430, "dano": 28}
]

onready var chefe_no = $Chefe

var posicao_original_chefe = Vector2()
var transicao_chefe = false

var chefe_atual = 0

onready var barra_chefe = $Chefe/BarraVidaChefe

onready var barras = [
	$Interface/StatusEquipe/StatusArtista/Vida,
	$Interface/StatusEquipe/StatusConfeiteira/Vida,
	$Interface/StatusEquipe/StatusMaestro/Vida,
	$Interface/StatusEquipe/StatusDesenhista/Vida,
	$Interface/StatusEquipe/StatusFlorista/Vida
]

onready var mensagem = $Interface/Mensagem
onready var timer_turno = $TimerTurno
var aguardando_turno = false

onready var painel_cura = $Interface/PainelCura
onready var painel_acoes = $Interface/PainelAcoes

onready var botoes_cura = [
	$Interface/PainelCura/CurarArtista,
	$Interface/PainelCura/CurarConfeiteira,
	$Interface/PainelCura/CurarMaestro,
	$Interface/PainelCura/CurarDesenhista,
	$Interface/PainelCura/CurarFlorista
]

var escolhendo_cura = false

onready var sprites_personagens = [
	$Equipe/ArtistaMarcial/Sprite,
	$Equipe/Confeiteira/Sprite,
	$Equipe/Maestro/Sprite,
	$Equipe/Desenhista/Sprite,
	$Equipe/Florista/Sprite
]

var posicoes_originais = []

func _ready():
	randomize()
	preparar_sprites()
	destacar_personagem()
	painel_cura.rect_global_position = painel_acoes.rect_global_position + Vector2(0, -20)
	painel_cura.rect_min_size = Vector2(400, 30)
	painel_acoes.show()
	painel_cura.hide()
	conectar_botoes_cura()	
	posicao_original_chefe = chefe_no.rect_position
	carregar_chefe()
	mensagem.text = "* Turno de " + personagens[0]["nome"]
	print("BATALHA INICIADA!")
	
	var musica = get_node_or_null("MusicaBatalha")

	if musica != null and musica.stream != null:
		musica.play()
		print("Musica da batalha iniciada!")
	else:
		print("ERRO: Musica da batalha nao encontrada!")

func preparar_sprites():
	for sprite in sprites_personagens:
		posicoes_originais.append(sprite.rect_position)


func diminuir_musica():
	var musica = $MusicaBatalha

	var tween = create_tween()
	tween.tween_property(
		musica,
		"volume_db",
		-40.0,
		1.5
	)

	yield(tween, "finished")
	musica.stop()

func destacar_personagem():
	for i in range(sprites_personagens.size()):
		var sprite = sprites_personagens[i]

		sprite.rect_position = posicoes_originais[i]

		if i == turno_atual and personagens[i]["vida"] > 0:
			sprite.rect_position.x += 20

func aguardar_proximo_turno():
	aguardando_turno = true
	timer_turno.start(1.5)
	yield(timer_turno, "timeout")
	aguardando_turno = false
	avancar_turno()

func atualizar_barras():
	barra_chefe.min_value = 0
	barra_chefe.max_value = vida_maxima_chefe
	barra_chefe.value = vida_chefe
	barra_chefe.percent_visible = false

	for i in range(personagens.size()):
		barras[i].min_value = 0
		barras[i].max_value = personagens[i]["max"]
		barras[i].value = personagens[i]["vida"]
		barras[i].percent_visible = false

func carregar_chefe():
	var chefe = chefes[chefe_atual]
	carregando_especial = false
	
	var nome_animacao = "chefe" + str(chefe_atual + 1)
	$Chefe/SpriteAnimado.play(nome_animacao)

	vida_chefe = chefe["vida"]
	vida_maxima_chefe = chefe["vida"]
	dano_chefe = chefe["dano"]

	atualizar_barras()

	mensagem.text = "* " + chefe["nome"] + " apareceu!"
	print("Novo chefe: ", chefe["nome"])

func proximo_chefe():
	if transicao_chefe:
		return

	transicao_chefe = true
	aguardando_turno = true

	mensagem.text = "* CHEFE DERROTADO!"

	yield(animar_derrota_chefe(), "completed")

	chefe_atual += 1

	if chefe_atual >= chefes.size():
		chefe_derrotado = true

		mensagem.text = "* TODOS OS CHEFES FORAM DERROTADOS!"

		yield(diminuir_musica(), "completed")

		get_tree().change_scene("res://Vitoria.tscn")
		return

	turno_atual = -1
	carregando_especial = false

	carregar_chefe()

	yield(animar_entrada_chefe(), "completed")

	transicao_chefe = false
	aguardando_turno = false

	avancar_turno()

func avancar_turno():
	if chefe_derrotado or game_over:
		return

	turno_atual += 1

	if turno_atual >= personagens.size():
		ataque_chefe()
		return

	if personagens[turno_atual]["vida"] <= 0:
		avancar_turno()
		return

	destacar_personagem()
	
	mensagem.text = "* Turno de " + personagens[turno_atual]["nome"]

func atacar():
	if chefe_derrotado or game_over or aguardando_turno or escolhendo_cura or chefe_agindo:
		return

	var personagem = personagens[turno_atual]

	if personagem["vida"] <= 0:
		return

	vida_chefe -= personagem["dano"]
	vida_chefe = max(0, vida_chefe)

	atualizar_barras()

	mensagem.text = "* " + personagem["nome"] + " causou " + str(personagem["dano"]) + " de dano!"

	if vida_chefe <= 0:
		proximo_chefe()
		return

	aguardar_proximo_turno()

func ataque_chefe():
	if chefe_derrotado or game_over:
		return

	if contar_vivos() == 0:
		game_over = true
		mensagem.text = "* GAME OVER!"
		return

	chefe_agindo = true

	if carregando_especial:
		executar_especial()
		
	elif randi() % 100 < chance_especial:
		carregando_especial = true
		mensagem.text = "* O CHEFE ESTA CARREGANDO UM ATAQUE DEVASTADOR!"

	elif randi() % 100 < 35:
		ataque_em_area()

	else:
		var vivos = []

		for i in range(personagens.size()):
			if personagens[i]["vida"] > 0:
				vivos.append(i)

		var indice = vivos[randi() % vivos.size()]
		var alvo = personagens[indice]
		var dano = dano_chefe

		if alvo["defendendo"]:
			dano = int(dano / 2)
			alvo["defendendo"] = false

		alvo["vida"] = max(0, alvo["vida"] - dano)

		atualizar_barras()

		mensagem.text = "* Chefe atacou " + alvo["nome"] + "! Dano: " + str(dano)

	if contar_vivos() == 0:
		game_over = true
		mensagem.text = "* GAME OVER!"
		return

	turno_atual = -1

	yield(get_tree().create_timer(1.5), "timeout")

	chefe_agindo = false
	avancar_turno()
	
func animar_derrota_chefe():
	var tween = create_tween()

	tween.tween_property(
		chefe_no,
		"modulate",
		Color(0.6, 0.6, 0.6, 1.0),
		0.5
	)

	tween.tween_property(
		chefe_no,
		"modulate:a",
		0.0,
		0.6
	)

	yield(tween, "finished")

	chefe_no.hide()
	
func animar_entrada_chefe():
	chefe_no.rect_position = posicao_original_chefe + Vector2(350, 0)
	chefe_no.modulate = Color(1, 1, 1, 1)
	chefe_no.show()

	var tween = create_tween()

	tween.tween_property(
		chefe_no,
		"rect_position",
		posicao_original_chefe,
		0.7
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	yield(tween, "finished")
	
func ataque_em_area():
	var dano_area = int(dano_chefe * 0.4)

	for personagem in personagens:
		if personagem["vida"] <= 0:
			continue

		var dano = dano_area

		if personagem["defendendo"]:
			dano = int(dano / 2)
			personagem["defendendo"] = false

		personagem["vida"] = max(
			0,
			personagem["vida"] - dano
		)

	atualizar_barras()

	mensagem.text = "* O CHEFE ATACOU TODA A EQUIPE!"

func executar_especial():
	var dano_especial = int(dano_chefe * 0.8)

	for personagem in personagens:
		if personagem["vida"] <= 0:
			continue

		var dano = dano_especial

		if personagem["defendendo"]:
			dano = int(dano / 2)
			personagem["defendendo"] = false

		personagem["vida"] = max(
			0,
			personagem["vida"] - dano
		)

	carregando_especial = false
	atualizar_barras()

	mensagem.text = "* O CHEFE USOU O ATAQUE DEVASTADOR!"

func contar_vivos():
	var quantidade = 0

	for personagem in personagens:
		if personagem["vida"] > 0:
			quantidade += 1

	return quantidade

func defender():
	if chefe_derrotado or game_over or aguardando_turno or escolhendo_cura or chefe_agindo:
		return

	personagens[turno_atual]["defendendo"] = true
	mensagem.text = "* " + personagens[turno_atual]["nome"] + " esta defendendo!"
	aguardar_proximo_turno()

func abrir_selecao_cura():
	escolhendo_cura = true

	painel_acoes.hide()
	painel_cura.show()

	mensagem.text = "* Escolha quem a Florista vai curar!"

	var nomes = [
		"Artista",
		"Confeit.",
		"Maestro",
		"Desenh.",
		"Florista"
	]

	for i in range(personagens.size()):
		botoes_cura[i].text = nomes[i]
		botoes_cura[i].rect_min_size = Vector2(75, 30)
		botoes_cura[i].show()

		botoes_cura[i].disabled = personagens[i]["vida"] <= 0

func selecionar_cura(indice):
	if not escolhendo_cura:
		return

	var alvo = personagens[indice]

	if alvo["vida"] <= 0:
		return

	var vida_antes = alvo["vida"]

	alvo["vida"] = min(alvo["max"], alvo["vida"] + 20)

	var recuperado = alvo["vida"] - vida_antes

	mensagem.text = "* Florista curou " + alvo["nome"] + " em " + str(recuperado) + " pontos!"

	painel_cura.hide()
	painel_acoes.show()
	escolhendo_cura = false

	atualizar_barras()
	aguardar_proximo_turno()

func conectar_botoes_cura():
	for i in range(botoes_cura.size()):
		botoes_cura[i].connect(
			"pressed",
			self,
			"selecionar_cura",
			[i]
		)

func habilidade():
	if chefe_derrotado or game_over or aguardando_turno or escolhendo_cura or chefe_agindo:
		return

	var personagem = personagens[turno_atual]
	var nome = personagem["nome"]

	if nome == "Florista":
		abrir_selecao_cura()
		return

	var dano = 0
	var habilidade_nome = ""

	match nome:
		"Artista Marcial":
			habilidade_nome = "ATAQUE FORTE"
			dano = 35

		"Confeiteira":
			habilidade_nome = "DOCE EXPLOSIVO"
			dano = 30

		"Maestro":
			habilidade_nome = "SINFONIA PODEROSA"
			dano = 25

		"Desenhista":
			habilidade_nome = "DESENHO VIVO"
			dano = 30

	vida_chefe = max(0, vida_chefe - dano)
	atualizar_barras()

	mensagem.text = "* " + nome + " usou " + habilidade_nome + "! Dano: " + str(dano)

	if vida_chefe <= 0:
		proximo_chefe()
		return

	aguardar_proximo_turno()

func passar():
	if chefe_derrotado or game_over or aguardando_turno or escolhendo_cura or chefe_agindo:
		return

	mensagem.text = "* " + personagens[turno_atual]["nome"] + " passou o turno!"
	aguardar_proximo_turno()

func _on_Atacar_pressed():
	atacar()

func _on_Habilidade_pressed():
	habilidade()

func _on_Defender_pressed():
	defender()

func _on_Passar_pressed():
	passar()
