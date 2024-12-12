extends Control

var ID
var Name
var Game


func SetupCard(username: String, id: int, gamePlaying: Dictionary, online: bool) -> void:
	Name = username
	ID = id
	Game = gamePlaying

	if !online:
		$Name.add_theme_color_override("default_color", Color.WEB_GRAY)
	else:
		$Name.add_theme_color_override("default_color", Color.WHITE)

	if gamePlaying != {}:
		$Name.add_theme_color_override("default_color", Color.WEB_GREEN)
	$Name.text = Name

func SetCardImage(image) -> void:
	$TextureRect.texture = image
