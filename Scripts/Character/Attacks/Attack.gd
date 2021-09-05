class_name Attack
extends Resource

enum AttackType {

	# Normal
	physical

	# Elemental
	fire
	eletric
	
	# Healing
	heal
	undead
}

enum TargetNumber {
	single_target
	AOE
}

export var attack_range: int = 1
export var damage: int = 1
export(AttackType) var attack_type = AttackType.physical
export(TargetNumber) var target_number = TargetNumber.single_target
