extends Node


signal selection_wheel_changed(selection : int)

signal try_place_object(position: Vector2, item: Item)

signal hide_marker()
signal show_marker()


signal show_mini_dialog(tetx: String, on_confirm: Callable)
signal hide_mini_dialog()

signal open_chest()
signal close_chest()


signal open_inventory()
signal open_chest_inventory(id:String)
