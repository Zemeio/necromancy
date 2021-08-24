extends "res://Scripts/Character.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	MAXHP = 100
	CURHP = 100
	FACTION = 1
	ATK = 25
	UNDEAD = true
	pass # Replace with function body.

func Damage(var dmg, var type): #Chamada para calcular o dano recebido pela unidade por um ataque inimigo
	#É chamada pela função Attack de outro personagem, recebendo como parâmetro o tipo elemental do ataque (Físico, Fogo ou Elétrico)
	#Calcula o dano com base nas resistências elementais e dano recebido (podemos adicionar mais tipos elementais e defesas depois). 
	#escrever fórmula que calcula o dano recebido com base no tipo do dano e dmg (Físico, Fogo, Elétrico)
	var t1 = 0
	var t2 = 0
	var t3 = 0
	if type == 1:
		t1 = 1
	if type == 2:
		t2 = 1
	if type == 3:
		t3 = 0
	CURHP = CURHP - (dmg * t1) - (dmg * t2) - (dmg * t3)
	pass
	
func Attack(): #Uma das ações básicas de cada personagem. Executa um ataque simples em um oponente com base nas características do personagem.
	#Seleciona um oponente válido no alcance do personagem, chama a função Damage do oponente enviando como parâmetro o dano e elemento (físico) do ataque.
	pass

func Magic(): #Abre o menu de feitiços do personagem, ou permite que NPCs usem magias
	#Esqueletos não podem usar magia
	pass
	
func Item(): #Abre o inventário do personagem, ou permite que NPCs usem items
	pass
	
func Skill(): #Permite que cada personagem jogável acesse um menu com suas ações únicas. Permite que certos inimigos realizem ações únicas.
	#Esqueletos não possuem habilidades únicas
	pass

func onDeath(): #Determina o que acontece quando a unidade chega em 0 HP.
	#O esqueleto se torna inerte, e pode ser revivido pelo necromante
	pass
