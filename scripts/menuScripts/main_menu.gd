extends Control

@export var HostGameScene : PackedScene
@export var JoinGameScene : PackedScene
@export var OptionsScene : PackedScene
@export var CollectionScene : PackedScene

@export var SteamWorksTestScene : PackedScene

@export var playerImage : TextureRect
@export var playerName : Label

@export var main_view : CenterContainer

@export var HostGameButton : Button
@export var JoinGameButton : Button


func _ready():
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	Steam.getPlayerAvatar()
	playerName.text = " " + Steam.getPersonaName()		


func _on_button_host_game_button_down() -> void:
	for children in main_view.get_children():
		children.queue_free()
	main_view.add_child(HostGameScene.instantiate())


func _on_button_join_game_button_down() -> void:
	for children in main_view.get_children():
		children.queue_free()
	main_view.add_child(JoinGameScene.instantiate())


func _on_button_options_button_down() -> void:
	for children in main_view.get_children():
		children.queue_free()
	main_view.add_child(OptionsScene.instantiate())


func _on_button_collection_button_down() -> void:
	for children in main_view.get_children():
		children.queue_free()
	main_view.add_child(CollectionScene.instantiate())


func _on_button_quit_button_down() -> void:
	get_tree().quit()


func _on_avatar_loaded(_id : int, image_size : int, buffer: PackedByteArray) -> void:
	var avatarImage : Image = Image.create_from_data(image_size, image_size, false, Image.FORMAT_RGBA8, buffer)
	var texture : ImageTexture = ImageTexture.create_from_image(avatarImage)
	texture.set_size_override(Vector2i(50, 50))
	playerImage.texture = texture


func _on_button_steam_test_button_down() -> void:
	get_tree().root.add_child(SteamWorksTestScene.instantiate())
	hide()
