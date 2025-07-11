# hellrot_class.gd
extends PlayerClassResource

func apply_to(player):
	player.power_level += 1
	player.stamina.regeneration_rate = 2.0
	player.combat.hitbox_size = 1.2
