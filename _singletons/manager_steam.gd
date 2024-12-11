class_name ManagerSteam
extends Node

var AppID : String = "2415880"

func _init() -> void:
	
	OS.set_environment("SteamAppID", AppID)
	OS.set_environment("SteamGameID", AppID)

	Steam.steamInit()
	var isRunning : bool = Steam.isSteamRunning()

	if !isRunning:
		print("ERROR: Steam is not running!")
		return

	print("Steam is running!")
