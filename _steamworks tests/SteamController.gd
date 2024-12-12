extends Control

@export var LeaderBoardUserScore : PackedScene
@export var FriendCard : PackedScene


# Called when node enters the scene
func _ready() -> void:

	if !Steam.isSteamRunning():
		return

	var userID : int = Steam.getSteamID()
	var username : String = Steam.getFriendPersonaName(userID)
	print("Your steam name is " + username)
	$FriendsPanel/ScrollContainer/VBoxContainer/FriendCard.SetupCard(username, userID, {}, false)

	Steam.avatar_loaded.connect(avatarLoaded)

	Steam.getPlayerAvatar()

	# Steam cloud file writing
	Steam.file_write_async_complete.connect(_on_file_write_async_complete)
	# Steam leaderboard callback
	Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
	Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
	Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)

	getFriends()
	print("Total friends: ", Steam.getFriendCount())


# Called every frame
func _process(_delta: float) -> void:
	Steam.run_callbacks()

func avatarLoaded(_id : int, image_size : int, buffer: PackedByteArray) -> void:

	var avatarImage : Image = Image.create_from_data(image_size, image_size, false, Image.FORMAT_RGBA8, buffer)

	var texture : ImageTexture = ImageTexture.create_from_image(avatarImage)
	for i in $FriendsPanel/ScrollContainer/VBoxContainer.get_children():
		if i.ID == _id:
			i.SetCardImage(texture)


# Unlock Achievement
func _on_achieve__achievement_button_down() -> void:
	var ach_first_launch : Dictionary = Steam.getAchievement("FIRST_LAUNCH")
	
	if ach_first_launch.ret && !ach_first_launch.achieved:
		Steam.setAchievement("FIRST_LAUNCH")
		Steam.storeStats()


# Lock Achievement
func _on_remove_achievement_button_down() -> void:
	var ach_first_launch : Dictionary = Steam.getAchievement("FIRST_LAUNCH")

	if ach_first_launch.ret && ach_first_launch.achieved:
		Steam.clearAchievement("FIRST_LAUNCH")
		Steam.storeStats()


# Upload file to Steam Cloud
func _on_store_cloud_file_button_down() -> void:
	var jsonData : Dictionary = {
		"name" : "test_name",
		"age": 10,
		"kills": 100
	}
	var jsonString = JSON.stringify(jsonData)
	
	Steam.fileWriteAsync("testData", jsonString.to_utf8_buffer())


# Download file from Steam Cloud
func _on_get_cloud_file_button_down() -> void:
	if Steam.fileExists("testData"):
		var data : Dictionary = Steam.fileRead("testData", Steam.getFileSize("testData"))
		var pba : PackedByteArray = data.buf
		var jsonData = pba.get_string_from_utf8()

		print(jsonData)
	else:
		print("file does not exist")

# Remove file from Steam Cloud storage
func _on_remove_cloud_file_button_down() -> void:
	var result : bool = Steam.fileForget("testData")
	print(result)


# Write file to Steam Cloud storage
func _on_file_write_async_complete(result: bool) -> void:
	print(result)


# Get handle for specific leaderboard
func _on_get_leaderboard_button_down() -> void:
	Steam.findLeaderboard("ClearedStages")


# Obtain leaderboard data for specific handle
func _on_leaderboard_find_result(handle, found) -> void:
	print("leaderboard handle: ", str(handle), " leaderboard found: " + str(found))


# Submit a new leaderboard score
func _on_submit_leaderboard_score_button_down() -> void:
	Steam.uploadLeaderboardScore(int($SubmitLeaderboardScoreValue.text))


func _on_leaderboard_score_uploaded(success: bool, handle: int, score: Dictionary) -> void:
	print("Success: ", success, " handle is ", handle, " score: ", score)


# Download leaderboard data
func _on_get_leaderboard_score_button_down() -> void:
	Steam.downloadLeaderboardEntries(0, 10)


func _on_leaderboard_scores_downloaded(message, handle, result) -> void:
	print(message, handle, result)
	
	for children in $Leaderboards/EntriesList.get_children():
		children.queue_free()

	for i in result:
		var score = LeaderBoardUserScore.instantiate()
		score.SetUpLeaderBoardScore(i.global_rank, Steam.getFriendPersonaName(i.steam_id), i.score)
		$Leaderboards/EntriesList.add_child(score)


# Set rich presence on steam
func _on_set_rich_presence_button_down() -> void:
	Steam.setRichPresence("steam_display", "#AtMainMenu")


func _on_set_level_1_button_down() -> void:
	Steam.setRichPresence("level", str(1))
	Steam.setRichPresence("steam_display", "#Level")


# Get all friends from steam
func getFriends():
	var offlineFriends : Array
	var onlineFriends : Array
	var ingameFriends : Array
	
	for i in range(0, Steam.getFriendCount()):
		var friendID = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		
		var online = Steam.getFriendPersonaState(friendID)
		var game_name = Steam.getFriendGamePlayed(friendID)
		if friendID == 0:
			break
		var friend_name = Steam.getFriendPersonaName(friendID)
		
		var friend_data = {
			"online" : online,
			"game_name" : game_name,
			"friend_name": friend_name,
			"friend_id": friendID
		}
		
		if online == 1:
			if game_name != {}:
				ingameFriends.append(friend_data)
			else:
				onlineFriends.append(friend_data)
		else:
			friend_data.online = 0
			offlineFriends.append(friend_data)


	for i in ingameFriends:
		spawnFriendCard(i)
		Steam.getPlayerAvatar(2, i.friend_id)
	for i in onlineFriends:
		spawnFriendCard(i)
		Steam.getPlayerAvatar(2, i.friend_id)
	for i in offlineFriends:
		spawnFriendCard(i)
		Steam.getPlayerAvatar(2, i.friend_id)


# Generate profile card for friend
func spawnFriendCard(friend) -> void:

		var currentCard = FriendCard.instantiate()
		if len(friend.friend_name) > 0:
			currentCard.SetupCard(friend.friend_name, friend.friend_id, friend.game_name, friend.online)
			$FriendsPanel/ScrollContainer/VBoxContainer.add_child(currentCard)


# Quit Game
func _on_set_level_2_button_down() -> void:
	get_tree().quit()
