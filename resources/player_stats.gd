extends Resource
class_name PlayerStats

@export_category("Podstawowe")
@export var class_name_str: String = "Wojownik"
@export var level: int = 1
@export var current_exp: int = 0
@export var exp_to_next_level: int = 100
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

# ── System ulepszeń za poziomy ───────────────────────────────────────────────
# Poziomy działają jak waluta. Każdy zdobyty poziom daje 1 punkt do wydania.
# Każda statystyka ma własny koszt: start 1, po każdym zakupie rośnie o 20%.

const BASE_UPGRADE_COST := 1.0   # koszt pierwszego ulepszenia każdej statystyki
const COST_GROWTH := 1.2         # mnożnik kosztu po każdym zakupie (+20%)

# Dostępne punkty (zdobyte poziomy jeszcze nie wydane). Float, bo koszty są ułamkowe.
@export var available_points: float = 0.0

# Lista statystyk, które można ulepszać, wraz z przyrostem za jeden zakup.
const UPGRADE_AMOUNTS := {
	"max_hp": 20,
	"armor": 2,
	"attack_damage": 3,
	"attack_speed": 0.05,
	"speed_multiplier": 0.02,
	"crit_chance": 0.01,
	"crit_damage": 0.05,
	"life_steal": 0.01,
	"dodge_chance": 0.01,
}

# Nazwy wyświetlane w UI.
const STAT_DISPLAY := {
	"max_hp": "HP",
	"armor": "Armor",
	"attack_damage": "Damage",
	"attack_speed": "Atk Speed",
	"speed_multiplier": "Speed",
	"crit_chance": "Crit",
	"crit_damage": "Crit Dmg",
	"life_steal": "Life Steal",
	"dodge_chance": "Dodge",
}

# Bieżący koszt każdej statystyki (osobny licznik na statystykę).
var upgrade_costs := {}

func _init() -> void:
	for stat in UPGRADE_AMOUNTS.keys():
		upgrade_costs[stat] = BASE_UPGRADE_COST

func get_upgrade_cost(stat: String) -> float:
	return upgrade_costs.get(stat, BASE_UPGRADE_COST)

func can_upgrade(stat: String) -> bool:
	return UPGRADE_AMOUNTS.has(stat) and available_points >= get_upgrade_cost(stat)

# Kupuje ulepszenie statystyki: odejmuje punkty, podnosi koszt o 20%,
# zwiększa wartość statystyki. Zwraca true, jeśli zakup się powiódł.
func upgrade_stat(stat: String) -> bool:
	if not can_upgrade(stat):
		return false

	available_points -= get_upgrade_cost(stat)
	upgrade_costs[stat] = get_upgrade_cost(stat) * COST_GROWTH

	var amount = UPGRADE_AMOUNTS[stat]
	set(stat, get(stat) + amount)

	# Powiększenie maks. HP leczy gracza o przyrost, by ulepszenie było odczuwalne.
	if stat == "max_hp":
		current_hp += amount

	emit_changed()
	return true

func level_up() -> void:
	if level < 10:
		level += 1
		available_points += 1.0
		print("LEVEL UP! Aktualny level: ", level, " | Punkty: ", available_points)

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

func add_exp(amount: int) -> void:
	if level >= 10:
		current_exp = 0
		emit_changed()
		return

	current_exp += amount
	print("Dodano EXP: ", amount, " | EXP: ", current_exp, "/", exp_to_next_level)

	while current_exp >= exp_to_next_level and level < 10:
		current_exp -= exp_to_next_level
		level_up()
		exp_to_next_level = get_exp_required_for_level(level)

	if level >= 10:
		current_exp = 0

	emit_changed()


func get_exp_required_for_level(current_level: int) -> int:
	return 100 + (current_level - 1) * 75
