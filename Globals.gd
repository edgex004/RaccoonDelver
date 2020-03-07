extends Node

var player_one : Player
var player_two : Player

var num_players = 1

var current_level

enum ItemType {
	key,
	chest,
	potion,
	fire
}

var verbose_movements = false
var verbose_attacks = false

func debug_moves(input: String):
	if verbose_movements: print(input)

func debug_attack(input: String):
	if verbose_attacks: print(input)











