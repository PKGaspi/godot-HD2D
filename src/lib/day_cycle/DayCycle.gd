extends Spatial


export var length: float = 20 # Length of a cycle in senconds.
export(Array, Resource) var sky_colors := []
export(Array, float) var sky_color_splits := []

export var paused: bool = false setget set_paused


onready var world_env := $WorldEnvironment
onready var sun_light := $WorldEnvironment/SunLight
onready var tween := $Tween


func _ready() -> void:
	assert(len(sky_colors) == len(sky_color_splits))
	tween.connect("tween_all_completed", self, "start_cycle")
	start_cycle()


func start_cycle() -> void:
	var longitude = PI - deg2rad(world_env.environment.background_sky.sun_longitude)
	tween.interpolate_property(sun_light, "rotation", Vector3(PI, longitude, 0), Vector3(3 * PI, longitude, 0), length, Tween.TRANS_LINEAR)
	tween.interpolate_property(world_env.environment.background_sky, "sun_latitude", 180.0, -180.0, length, Tween.TRANS_LINEAR)
	var sum_splits = 0
	for i in range(len(sky_colors)):
		var color = sky_colors[i]
		var next_color = sky_colors[i + 1 if i + 1 < len(sky_colors) else 0] 
		tween.interpolate_property(world_env.environment.background_sky, "sky_top_color", color.sky_top_color, next_color.sky_top_color, sky_color_splits[i] * length, Tween.TRANS_LINEAR, Tween.EASE_IN, sum_splits * length)
		tween.interpolate_property(world_env.environment.background_sky, "sky_horizon_color", color.sky_horizon_color, next_color.sky_horizon_color, sky_color_splits[i] * length, Tween.TRANS_LINEAR, Tween.EASE_IN, sum_splits * length)
		tween.interpolate_property(world_env.environment.background_sky, "ground_bottom_color", color.ground_bottom_color, next_color.ground_bottom_color, sky_color_splits[i] * length, Tween.TRANS_LINEAR, Tween.EASE_IN, sum_splits * length)
		tween.interpolate_property(world_env.environment.background_sky, "ground_horizon_color", color.ground_horizon_color, next_color.ground_horizon_color, sky_color_splits[i] * length, Tween.TRANS_LINEAR, Tween.EASE_IN, sum_splits * length)
		tween.interpolate_property(world_env.environment.background_sky, "sun_color", color.sun_color, next_color.sun_color, sky_color_splits[i] * length, Tween.TRANS_LINEAR, Tween.EASE_IN, sum_splits * length)
		sum_splits += sky_color_splits[i]
	tween.start()


func set_paused(value: bool) -> void:
	if not is_instance_valid(tween):
		call_deferred("set_paused", value)
		return
	
	paused = value
	if value:
		tween.stop_all()
	else:
		tween.resume_all()

