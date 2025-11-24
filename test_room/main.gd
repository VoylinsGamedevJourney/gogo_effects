extends Control


@onready var gogo_effects: GoGoEffects = $GoGoEffects



func _ready() -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(1)

	await timer.timeout
	gogo_effects.start_encoding()
	timer = get_tree().create_timer(5)

	await timer.timeout
	gogo_effects.stop_encoding()
