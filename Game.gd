extends Node2D

#cotador do número de botões na tela 
const numBotoes :int = 4
var imagemPath: String 
var somPath: String 
var numOpcoes :int # contador de imagens dentro de imagemPath
var lingua: String 
var elementosEncontrados: Array = []
var elementoTemp
var ultimoElmento
var index: int
var respostaCerta: int
var move = false
var score:int

func _ready():
	randomize()
	_novo_jogo()

func _novo_jogo():
	$timFim.wait_time = 3
	move = false
	$aniAudiencia.position.y = 690
	_habilitaBotoes()
	_defineElementos()
	_pergunta()

func _defineIdioma(idioma):
	lingua = idioma
	match(lingua):
		"ptBr":
			$somOndeEsta.stream = load("res://Assets/Sons/ptbrOnde.wav")
		"es":
			$somOndeEsta.stream = load("res://Assets/Sons/esOnde.wav")
		"enUs":
			$somOndeEsta.stream = load("res://Assets/Sons/enUsOnde.wav")

func _defineJogo(jogo):
	match(jogo):
		"Animais":
			imagemPath = "res://Assets/Imagens/Animais/"
			somPath = "res://Assets/Sons/Animais/"
			$fundo/AnimatedSprite.play("jogoAnimais")
		"Cores":
			imagemPath = "res://Assets/Imagens/Cores/"
			somPath = "res://Assets/Sons/Cores/"
			$fundo/AnimatedSprite.play("jogoAnimais")
		"Frutas":
			imagemPath = "res://Assets/Imagens/Frutas/"
			somPath  = "res://Assets/Sons/Frutas/"
			$fundo/AnimatedSprite.play("jogoAlimentos")
		"Letras":
			imagemPath = "res://Assets/Imagens/Letras/"
			somPath = "res://Assets/Sons/Letras/"
			$fundo/AnimatedSprite.play("jogoLetras")
		"Numeros":
			imagemPath = "res://Assets/Imagens/Numeros/"
			somPath = "res://Assets/Sons/Numeros/"
			$fundo/AnimatedSprite.play("jogoAlimentos")
		"Alimentos":
			imagemPath = "res://Assets/Imagens/Alimentos/"
			somPath = "res://Assets/Sons/Alimentos/"
			$fundo/AnimatedSprite.play("jogoAlimentos")
	_encontrarElementos(imagemPath)

func _defineElementos():
	#Sorteia os elementos da rodada
	for j in numBotoes:
		index = rand_range(j, numOpcoes + 1)
		elementoTemp = elementosEncontrados[j]
		elementosEncontrados[j] = elementosEncontrados[index]
		elementosEncontrados[index] = elementoTemp
		get_node("btn" + str(j)).texture_normal = (load(imagemPath + str(elementosEncontrados[j]) + ".png"))
	#Sorteia a resposta de certa
	respostaCerta = randi() % numBotoes
	while elementosEncontrados[respostaCerta] == ultimoElmento:
		respostaCerta = randi() % numBotoes
	
	ultimoElmento = elementosEncontrados[respostaCerta]
	$somTipoElemento.stream = load(somPath + lingua + "/tipoElemento.wav")
	$somElemento.stream = load(somPath + lingua + "/" + str(elementosEncontrados[respostaCerta]) + ".wav")
		
func _on_btn0_pressed():
	_verifica(0)

func _on_btn1_pressed():
	_verifica(1)
	
func _on_btn2_pressed():
	_verifica(2)

func _on_btn3_pressed():
	_verifica(3)
	
func _pergunta():
	#pergunta ao jogador onde está a opção sorteada
	$somOndeEsta.play()
	
func _verifica(var resposta):
	#verifica se a opção escolhida pelo jogador é a correta
	if resposta == respostaCerta:
		get_node("btn"+str(resposta)).set("modulate","FFFF0F")
		_desabilitaBotoes()
		score = score + 1
		if score >= 4:
			_baloes()
			score = 0
		else:
			move = true
			$somAudiencia.play()	
		$timFim.start()
	else:
		#resposta errada
		$somErro.play()
		get_node("btn"+str(resposta)).set("disaled",true)
		get_node("btn"+str(resposta)).set("modulate","3e3e3e")
		score = 0
	
func _on_btnVoltar_pressed():
	self.get_parent().call("_habilita_botoes")
	self.get_parent().call("_on_btnOk_pressed")
	self.queue_free()

func _on_somOndeEsta_finished():
	var somTipoElementoCheck = File.new()
	if somTipoElementoCheck.file_exists(somPath + lingua + "/tipoElemento.wav"):
		$somTipoElemento.play()
	else:
		$somElemento.play()
	
func _on_somTipoElemento_finished():
	$somElemento.play()

func _process(delta):
	if move == true and $aniAudiencia.position.y > 400:
		$aniAudiencia.move_local_y(-25, true)

func _on_btnOuvir_pressed():
	_pergunta()

func _on_timFim_timeout():
	$timFim.wait_time = 0.1
	if get_tree().get_nodes_in_group("grpBaloes").size() == 0:
	#f self.get_children().is_in_group("baloes") > 0:
		_novo_jogo()
	else:
		$timFim.start()
	
func _desabilitaBotoes():
	for i in numBotoes:
		get_node("btn" + str(i)).set("disabled", true)
	$btnOuvir.set("disabled", true)
	$btnVoltar.set("disabled", true)

func _habilitaBotoes():
	for i in numBotoes:
		get_node("btn" + str(i)).set("disabled", false)
		get_node("btn"+str(i)).set("modulate","ffffffff")
	$btnOuvir.set("disabled", false)
	$btnVoltar.set("disabled", false)

func _baloes():
	var balao = preload("res://Ballon.tscn")
	$somFim.play()
	for i in rand_range(20,30):
		var baloes = balao.instance()
		baloes.position.x = rand_range(-400,350)
		add_child(baloes)
		baloes.add_to_group("grpBaloes")
		
"""

func _encontrarElementos(var path):
	numOpcoes = -1
	var dir = Directory.new()
	var file = File.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		$Label.text = $Label.text + "Dentro do While \n"
		file = dir.get_next()
		$Label.text = $Label.text + str(file.get_extension()) + " \n"
		if file == "":
			$Label.text = $Label.text + " - file = aspas aspas \n"
			break
		elif (file.get_extension()) == "png":
			numOpcoes = numOpcoes + 1
			elementosEncontrados.append(str(file.get_basename()))
			$Label.text = $Label.text + " - Achei arquivos .png \n"
	dir.list_dir_end()
	$Label.text = $Label.text + " - Depois do while"
"""

func _encontrarElementos(var path):
	numOpcoes = -1
	var dir = Directory.new()
	var file = File.new()
	dir.open(path)
	dir.list_dir_begin()
	$Label.text = $Label.text + "entrando no while \n"
	while true:
		file = dir.get_next()
		$Label.text = $Label.text + "found " + str(file.get_basename())
		$Label.text = $Label.text + " -> " + str(file.get_extension()) + " \n"
		if file == "":
			break
		elif (file.get_extension()) == "png":
			numOpcoes = numOpcoes + 1
			elementosEncontrados.append(str(file.get_basename()))
	dir.list_dir_end()
	$Label.text = $Label.text + " fim do while"