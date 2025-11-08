extends Enemy

func __find_target():
	if target_path and has_node(target_path):
		return get_node(target_path)
	else:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			return players[0]

func __die():
	queue_free()
