extends Spatial

const DAY_PERIOD := 24 * 60 * 60 # Duration of a real life day in seconds.
const SUN_MIDNIGHT_LATITUDE: float = -105.0 # Latitude at 00:00.


export var cycle_period: int = 20 # Duration of a cycle in seconds.
export var current_time: int = 0 setget set_time # Current time of the day in seconds.
var cycle_time: float = 0 setget _set_cycle_time
export(Array, Resource) var sky_colors := []
export(Array, int) var sky_color_times := []
export var paused: bool = false
#TODO: Add longitude param.



onready var world_env := $WorldEnvironment
onready var background_sky: ProceduralSky = world_env.environment.background_sky
onready var sun_light := $WorldEnvironment/SunLight


func _ready() -> void:
	assert(len(sky_colors) == len(sky_color_times))


func _physics_process(delta: float) -> void:
	if not paused:
		_set_cycle_time(cycle_time + delta)


func _set_cycle_time(value: float) -> void:
	value = fposmod(value, cycle_period)
	cycle_time = value
	set_time(range_lerp(value, 0, cycle_period, 0, DAY_PERIOD))

# Sets the properties of the enviroment to match the specified time of the day.
# day_time is the time of the day in seconds, between [0, DAY_PERIOD).
func set_time(day_time: int) -> void:
	current_time = day_time
	cycle_time = range_lerp(day_time, 0, DAY_PERIOD, 0, cycle_period)
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

