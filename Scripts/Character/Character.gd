class_name Character
extends Node

export var MAXHP = 100 #O valor máximo de HP do personagem
var CURHP #O valor atual de HP do personagem
var ATK   #O dano que o personagem dá em um ataque comum
var FACTION #A Facção do personagem. 1 é aliado, 2 é inimigo e 3 é neutro.
var UNDEAD #Booleano. Determina se o personagem é um morto vivo, e, portanto, controlável pelo necromante. 
#var POS posição do personagem no mapa
#var MP controla a quantidade de magia que um personagem pode usar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func damage(var dmg, var type): #Chamada para calcular o dano recebido pela unidade por um ataque inimigo
	#É chamada pela função Attack de outro personagem, recebendo como parâmetro o tipo elemental do ataque (Físico, Fogo ou Elétrico)
	#Calcula o dano com base nas resistências elementais e dano recebido (podemos adicionar mais tipos elementais e defesas depois). 
	pass
	
func attack(Attack): #Uma das ações básicas de cada personagem. Executa um ataque simples em um oponente com base nas características do personagem.
	#Seleciona um oponente válido no alcance do personagem, chama a função Damage do oponente enviando como parâmetro o dano e elemento (físico) do ataque.
	pass

func magic(): #Abre o menu de feitiços do personagem, ou permite que NPCs usem magias
	pass
	
func item(): #Abre o inventário do personagem, ou permite que NPCs usem items
	pass
	
func skill(): #Permite que cada personagem jogável acesse um menu com suas ações únicas. Permite que certos inimigos realizem ações únicas.
	pass

func onDeath(): #Determina o que acontece quando a unidade chega em 0 HP.
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
