extends Node

#menus
@warning_ignore("UNUSED_SIGNAL")
signal selection_wheel_changed(selection : int)
#enviorment
@warning_ignore("UNUSED_SIGNAL")
signal try_place_object(position: Vector2, item: Item)
@warning_ignore("UNUSED_SIGNAL")
signal hide_marker()
@warning_ignore("UNUSED_SIGNAL")
signal show_marker()

#dialog
@warning_ignore("UNUSED_SIGNAL")
signal show_mini_dialog(tetx: String, on_confirm: Callable)
@warning_ignore("UNUSED_SIGNAL")
signal hide_mini_dialog()

#chests
@warning_ignore("UNUSED_SIGNAL")
signal open_chest()
@warning_ignore("UNUSED_SIGNAL")
signal close_chest()
#inventory
@warning_ignore("UNUSED_SIGNAL")
signal open_inventory()
@warning_ignore("UNUSED_SIGNAL")
signal open_chest_inventory(id:String)
@warning_ignore("UNUSED_SIGNAL")
signal open_crafting_menu(avaliable_recipes:Array[Recipe])
@warning_ignore("UNUSED_SIGNAL")
signal close_crafting_menu()

#comabt
@warning_ignore("UNUSED_SIGNAL")
signal player_weapon_swing_completed()
@warning_ignore("UNUSED_SIGNAL")
signal player_swapped_weapon(item:Item)
