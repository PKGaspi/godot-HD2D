extends Spatial

const DAY_PERIOD := 24 * 60 * 60 # Duration of a real life day in seconds.
const SUN_MIDNIGHT_LATITUDE: float = -105.0 # Latitude at 00:00.


export var cycle_period: int = 20 # Duration of a cycle in seconds.
export var current_time: int = 0 setget set_time # Current time of the day in seconds.
export(Array, Resource) var sky_colors := []
export(Array, int) var sky_color_times := []
export var paused: bool = false setget set_paused
#TODO: Add longitude param.



onready var world_env := $WorldEnvironment
onready var background_sky: ProceduralSky = world_env.environment.background_sky
onready var sun_light := $WorldEnvironment/SunLight
onready var tween := $Tween


func _ready() -> void:
	assert(len(sky_colors) == len(sky_color_times))
	#set_time(21 * 3600)
	if not paused:
		start_cycle(current_time)


func _on_tween_all_completed() -> void:
	start_cycle(current_time)


func start_cycle(time: int = 0) -> void:
	tween.interpolate_property(self, "current_time", time, time + DAY_PERIOD, cycle_period, Tween.TRANS_LINEAR)
	tween.connect("tween_all_completed", self, "_on_tween_all_completed")
	tween.start()


func stop_cycle() -> void:
	tween.reset_all()
	tween.disconnect("tween_all_completed", self, "_on_tween_all_completed")


# Sets the properties of the enviroment to match the specified time of the day.
# day_time is the time of the day in seconds, between [0, DAY_PERIOD).
func set_time(day_time: int) -> void:
	current_time = day_time
	if not is_instance_valid(world_env):
		call_deferred("set_time", day_time)
		return
	# warning-ignore:narrowing_conversion
	day_time = fposmod(day_time, DAY_PERIOD)
	var weight := inverse_lerp(0, DAY_PERIOD, day_time)
	var longitude = PI - deg2rad(world_env.environment.background_sky.sun_longitude)
	# Interpolate parameters.
	# Light rotation.
	sun_light.rotation = lerp(Vector3(deg2rad(-SUN_MIDNIGHT_LATITUDE), longitude, 0), Vector3(deg2rad(-SUN_MIDNIGHT_LATITUDE) - 2*PI, longitude, 0), weight)
	# Sun latitude.
	var sun_latitude = -rad2deg(sun_light.rotation.x)
	while sun_latitude > 180:
		sun_latitude -= 360
	background_sky.sun_latitude = sun_latitude
	# Colors.
	var i := 0
	for time in sky_color_times:
		if day_time <= time:
			break
		i += 1
	
	var color_weight: float = inverse_lerp(sky_color_times[int(fposmod(i-1, len(sky_colors)))], sky_color_times[int(fposmod(i, len(sky_colors)))], day_time)
	var current_colors: SkyColors = sky_colors[int(fposmod(i-1, len(sky_colors)))]
	var next_colors: SkyColors = sky_colors[int(fposmod(i, len(sky_colors)))]
	
	background_sky.sky_top_color = lerp(current_colors.sky_top_color, next_colors.sky_top_color, color_weight)
	background_sky.sky_horizon_color = lerp(current_colors.sky_horizon_color, next_colors.sky_horizon_color, color_weight)
	background_sky.ground_bottom_color = lerp(current_colors.ground_bottom_color, next_colors.ground_bottom_color, color_weight)
	background_sky.ground_horizon_color = lerp(current_colors.ground_horizon_color, next_colors.ground_horizon_color, color_weight)
	background_sky.sun_color = lerp(current_colors.sun_color, next_colors.sun_color, color_weight)


func set_paused(value: bool) -> void:
	if not is_instance_valid(tween):
		call_deferred("set_paused", value)
		return
	
	paused = value
	if value:
		tween.stop_all()
	else:
		tween.resume_all()

