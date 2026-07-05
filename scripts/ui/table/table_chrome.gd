class_name TableChrome
extends RefCounted
## Barre de menu table : musique et actions transverses.


static func setup_music_controls(ctx: TableContext) -> void:
	var audio := TableServiceAccess.audio(ctx.host)
	ctx.top_menu_bar.set_music_enabled_display(audio.get_music_enabled())
	ctx.top_menu_bar.music_toggle_pressed.connect(_on_music_toggle_pressed.bind(ctx))
	ctx.top_menu_bar.music_next_pressed.connect(_on_music_next_pressed.bind(ctx))


static func _on_music_toggle_pressed(ctx: TableContext) -> void:
	var audio := TableServiceAccess.audio(ctx.host)
	var enabled: bool = not audio.get_music_enabled()
	audio.set_music_enabled(enabled)
	ctx.top_menu_bar.set_music_enabled_display(enabled)


static func _on_music_next_pressed(ctx: TableContext) -> void:
	TableServiceAccess.audio(ctx.host).play_next()
