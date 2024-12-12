extends Panel

func SetUpLeaderBoardScore(rank, user_name: String, score: int) -> void:
	$HBoxContainer/Rank.text = str(rank)
	$HBoxContainer/Name.text = user_name
	$HBoxContainer/Score.text = str(score)
