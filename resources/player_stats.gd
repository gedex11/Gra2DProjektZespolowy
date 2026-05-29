extends Resource
class_name PlayerStats

@export_category("Podstawowe")
@export var class_name_str: String = "Wojownik"
@export var level: int = 1
@export var current_hp: int = 150
@export var max_hp: int = 150
@export var armor: int = 12

@export_category("Ofensywne")
@export var attack_damage: int = 15
@export var attack_speed: float = 1.00

@export_category("Mobilność")
@export var speed_multiplier: float = 1.0

@export_category("Zaawansowane")
@export var crit_chance: float = 0.05
@export var crit_damage: float = 1.50
@export var life_steal: float = 0.02
@export var dodge_chance: float = 0.0

const WARRIOR_TABLE := [
	# [max_hp, armor, ad,  as,    speed, crit,  life_steal, dodge]
	[150,  12,  15,  1.00, 1.00, 0.05, 0.02, 0.00],
	[190,  15,  22,  1.05, 1.01, 0.05, 0.03, 0.00],
	[240,  20,  30,  1.10, 1.02, 0.06, 0.04, 0.01],
	[310,  28,  42,  1.15, 1.03, 0.07, 0.05, 0.01],
	[400,  38,  58,  1.20, 1.04, 0.08, 0.07, 0.02],
	[520,  50,  75,  1.25, 1.05, 0.10, 0.09, 0.02],
	[680,  65, 100,  1.30, 1.06, 0.12, 0.11, 0.03],
	[880,  85, 135,  1.35, 1.07, 0.14, 0.13, 0.04],
	[1100, 110, 180, 1.40, 1.08, 0.16, 0.16, 0.05],
	[1400, 150, 250, 1.50, 1.10, 0.20, 0.20, 0.07],
]

const RANGER_TABLE := [
	# [max_hp, armor, ad,  as,    speed, crit,  crit_dmg, dodge]
	[90,   5,  12,  1.20, 1.05, 0.10, 1.50, 0.05],
	[110,  7,  18,  1.35, 1.07, 0.12, 1.55, 0.07],
	[135, 10,  26,  1.50, 1.10, 0.15, 1.60, 0.10],
	[170, 14,  36,  1.70, 1.13, 0.18, 1.70, 0.12],
	[215, 18,  50,  1.90, 1.16, 0.22, 1.80, 0.15],
	[270, 24,  68,  2.10, 1.20, 0.28, 1.95, 0.18],
	[340, 32,  90,  2.30, 1.24, 0.35, 2.10, 0.22],
	[430, 42, 120,  2.50, 1.28, 0.45, 2.30, 0.26],
	[550, 55, 160,  2.75, 1.33, 0.55, 2.55, 0.30],
	[700, 70, 220,  3.00, 1.40, 0.70, 3.00, 0.40],
]

func apply_level(new_level: int) -> void:
	level = clamp(new_level, 1, 10)
	var idx := level - 1
	var row: Array

	if class_name_str == "Wojownik":
		row = WARRIOR_TABLE[idx]
		var old_max := max_hp
		max_hp       = row[0]
		armor        = row[1]
		attack_damage = row[2]
		attack_speed  = row[3]
		speed_multiplier = row[4]
		crit_chance   = row[5]
		life_steal    = row[6]
		dodge_chance  = row[7]
		current_hp = int(float(current_hp) / old_max * max_hp)

	elif class_name_str == "Strzelec":
		row = RANGER_TABLE[idx]
		var old_max := max_hp
		max_hp       = row[0]
		armor        = row[1]
		attack_damage = row[2]
		attack_speed  = row[3]
		speed_multiplier = row[4]
		crit_chance   = row[5]
		crit_damage   = row[6]
		dodge_chance  = row[7]
		current_hp = int(float(current_hp) / old_max * max_hp)

	emit_changed()

func level_up() -> void:
	if level < 10:
		apply_level(level + 1)

func take_damage(raw_damage: int) -> void:
	var mitigated := int(raw_damage * (100.0 / (100.0 + armor)))
	current_hp = max(0, current_hp - mitigated)
	emit_changed()
	if current_hp == 0:
		#smierc gracza 
		pass

func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)
	emit_changed()
