class_name CharacterInfo
extends Resource


export var Name = ""
export var MAXHP = 100 #O valor máximo de HP do personagem
var CURHP #O valor atual de HP do personagem
var ATK   #O dano que o personagem dá em um ataque comum
var FACTION #A Facção do personagem. 1 é aliado, 2 é inimigo e 3 é neutro.
var UNDEAD #Booleano. Determina se o personagem é um morto vivo, e, portanto, controlável pelo necromante. 
#var POS posição do personagem no mapa
#var MP controla a quantidade de magia que um personagem pode usar

# type: Attack
export var main_attack: Resource

export var act_speed := 5
