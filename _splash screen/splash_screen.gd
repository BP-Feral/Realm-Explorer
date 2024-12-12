extends Control

@export var menu_scene : PackedScene
@export var in_time : float = 0.5
@export var fade_in_time : float = 1.5
@export var pause_time : float = 1.5
@export var fade_out_time : float = 1.5
@export var out_time : float = 0.5
@export var splash_screen : TextureRect

@onready var error_label: Label = $CenterContainer2/ErrorLabel
@onready var quit_button: Button = $QuitButton

var AppID : String = "2415880"


func _init() -> void:
	OS.set_environment("SteamAppID", AppID)
	OS.set_environment("SteamGameID", AppID)


func _ready() -> void:
	# Initialize Steam API
	Steam.steamInit()
	# Display Splash
	fade()

func fade() -> void:
	splash_screen.modulate.a = 0.0
	var tween : Tween = self.create_tween()
	tween.tween_interval(in_time)
	tween.tween_property(splash_screen, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(pause_time)
	tween.tween_property(splash_screen, "modulate:a", 0.0, fade_out_time)
	tween.tween_interval(out_time)
	await tween.finished
	load_next_scene()


func load_next_scene() -> void:
	# Check steam is running
	if !Steam.isSteamRunning():
		print("Is Steam running: ", str(Steam.isSteamRunning()))
		display_error("You need to have Steam open in order to play the game!")
		return
	# Check if user owns the game
	if !Steam.isSubscribed():
		print("Is User subscribed: ",str(Steam.isSubscribed()))
		display_error("You don't own this game on Steam!")
		return

	# Go into the menu Scene
	get_tree().change_scene_to_packed(menu_scene)

# Display an error and the quit button
func display_error(message : String) -> void:
	error_label.text = message
	error_label.show()
	quit_button.show()

# Quit button logic
func _on_quit_button_pressed() -> void:
	get_tree().quit()
