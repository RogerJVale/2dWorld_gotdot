extends Node

func hide_children(node: Node):
	for child in node.get_children():
		child.visible = false

func hide_all_children(node: Node):
	for child in node.get_children():
		child.visible = false
		hide_all_children(child)

func remove_all_children(node: Node):
	for child in node.get_children():
		child.queue_free()

func print_caller():
	var stack = get_stack()
	if stack.size() > 1:
		print("Caller:", stack[2]["function"])
		print("Caller file:", stack[2]["source"])
	else:
		print("No caller found")

func generate_uuid() -> String:
	var t = Time.get_unix_time_from_system()
	return str(t, "_", randi(), "_", randi())

func generate_random_string(length := 8) -> String:
	var chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var result := ""
	for i in length:
		result += chars[randi() % chars.length()]
	return result

## Returns the world size given a tilemap
func calculate_world_size(tilemap_layer: TileMapLayer)->Vector2:
	var used = tilemap_layer.get_used_rect()
	var tile_size = tilemap_layer.tile_set.tile_size
	return used.size * tile_size
