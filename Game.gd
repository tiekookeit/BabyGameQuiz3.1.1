extends Node2D
#algumas cosntantes podem ser transformadas em variáveis para que seja possível usar os diversos tipos de jogos
#(animais, cores, letras ...) na mesma cena, alterando apenas o path das imagens e dos sons

const numBotoes :int = 4 #cotador do número de botões na tela 
var numOpcoes :int #= 10 #contador de imagens de animais
var imagemPath: String #= "res://Assets/Imagens/Animais/"
var somPath: String #= "res://Assets/Sons/Animais/"
var lingua: String #= "ptBr"

var elemento = [Elemento.new(),Elemento.new(),Elemento.new(),Elemento.new()]

var respostaCerta: int
var elementoUltimoSorteio = Elemento.new()
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
	if idioma == "ptBr":
		$btnVoltar.text = "VOLTAR"
		$somOndeEsta.stream = load("res://Assets/Sons/ptbrOnde.wav")
	if idioma == "es":
		$btnVoltar.text = "VOLVER"
		$somOndeEsta.stream = load("res://Assets/Sons/esOnde.wav")
	if idioma == "enUs":
		$btnVoltar.text = "BACK"
		$somOndeEsta.stream = load("res://Assets/Sons/enUsOnde.wav")
		
func _defineJogo(jogo):
	if jogo == ("Animais"):
		imagemPath = "res://Assets/Imagens/Animais/"
		somPath = "res://Assets/Sons/Animais/"
		numOpcoes = 10
		$fundo/AnimatedSprite.play("jogoAnimais")
	if jogo == ("Cores"):
		imagemPath = "res://Assets/Imagens/Cores/"
		somPath = "res://Assets/Sons/Cores/"
		numOpcoes = 4
	if jogo == ("Frutas"):
		imagemPath = "res://Assets/Imagens/Frutas/"
		somPath  = "res://Assets/Sons/Frutas/"
		numOpcoes = 4
		$fundo/AnimatedSprite.play("padrao")
	if jogo == ("Letras"):
		imagemPath = "res://Assets/Imagens/Letras/"
		somPath = "res://Assets/Sons/Letras/"
		numOpcoes = 26
		$fundo/AnimatedSprite.play("jogoLetras")
	if jogo == ("Numeros"):
		imagemPath = "res://Assets/Imagens/Numeros/"
		somPath = "res://Assets/Sons/Numeros/"
		numOpcoes = 10
		$fundo/AnimatedSprite.play("padrao")
		
func _defineElementos():
	#Sorteia os elementos da rodada
	elemento[0]._setup(randi() % numOpcoes)
	while elemento[0]._getIndex() == elementoUltimoSorteio._getIndex(): #Evita que a resposta certa da última rodada apareça em jogo
		elemento[0]._setup(randi() % numOpcoes)
	elemento[1]._setup(randi() % numOpcoes)
	while (elemento[0]._getIndex() == elemento[1]._getIndex() or elemento[1]._getIndex() == elementoUltimoSorteio._getIndex()):
		elemento[1]._setup(randi() % numOpcoes)
	elemento[2]._setup(randi() % numOpcoes)
	while (elemento[2]._getIndex() == elemento[0]._getIndex()) or (elemento[2]._getIndex() == elemento[1]._getIndex() or elemento[1]._getIndex() == elementoUltimoSorteio._getIndex()):
		elemento[2]._setup(randi() % numOpcoes)
	elemento[3]._setup(randi() % numOpcoes)
	while (elemento[3]._getIndex() == elemento[0]._getIndex()) or (elemento[3]._getIndex() == elemento[1]._getIndex()) or (elemento[3]._getIndex() == elemento[2]._getIndex() or elemento[3]._getIndex() == elementoUltimoSorteio._getIndex()):
		elemento[3]._setup(randi() % numOpcoes)
	
	#Define as imagens dos botões
	for i in numBotoes:
		get_node("btn" + str(i)).texture_normal = (load(imagemPath + str(elemento[i]._getIndex()) + ".png"))
	#Sorteia a resposta de certa
	respostaCerta = randi() % 4
	$somTipoElemento.stream = load(somPath + lingua + "/tipoElemento.wav")
	$somElemento.stream = load(somPath + lingua + "/" + str(elemento[respostaCerta]._getIndex()) + ".wav")
	elementoUltimoSorteio._setup(elemento[respostaCerta]._getIndex())
	
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
	$somTipoElemento.play()

func _on_somTipoElemento_finished():
	$somElemento.play()

func _process(delta):
	$Label.text = str(get_tree().get_nodes_in_group("grpBaloes").size())
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