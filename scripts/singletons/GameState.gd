extends Node

#  stan postępu gry
var level2_unlocked: bool = false

# --- Globalny postęp fal (rośnie przez cały czas gry, niezależnie od poziomu) ---
var global_wave_index: int = 0     # ile fal łącznie już zrespawniono
var wave_hp_mult: float = 1.0      # narastający mnożnik HP przeciwników z fal
var wave_dmg_mult: float = 1.0     # narastający mnożnik DMG przeciwników z fal
