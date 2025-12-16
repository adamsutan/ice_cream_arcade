extends Node

# Default difficulty klo mw ganti dibawah ini
var difficulty = "rush"
var pause_instance = null

# Game stats buat leaderboard nanti, jadi ya skrg blom work cm stats ini bakal masuk ke server
var current_score: int = 0
var high_score: int = 0

func reset_score():
	current_score = 0

func update_high_score():
	if current_score > high_score:
		high_score = current_score
