extends Spatial

const SECS_IN_A_MIN := 60
const MINS_IN_AN_HOUR := 60
const SECS_IN_AN_HOUR := MINS_IN_AN_HOUR * SECS_IN_A_MIN
const HOURS_IN_A_DAY := 24
const DAY_PERIOD := HOURS_IN_A_DAY * SECS_IN_AN_HOUR # Duration of a day in seconds.
const SUN_MIDNIGHT_LATITUDE: float = -105.0 # Latitude at 00:00.


export var cycle_period: int = 20 # Duration of a cycle in seconds.
export var current_time: int = 0 setget set_time # Current time of the day in seconds.
var cycle_time: float = 0 setget _set_cycle_time
export(float, -180, 180, 1) var sun_longitude := 0.0 setget set_sun_longitude

export(Array, Resource) var sky_colors := []
export(Array, int) var sky_color_times := []
export var paused: bool = false



onready var world_env := $WorldEnvironment
onready var background_sky: ProceduralSky = world_env.environment.background_sky
onready var sun_light := $WorldEnvironment/SunLight


func _ready() -> void:
	assert(len(sky_colors) == len(sky_color_times))
	set_sun_longitude(sun_longitude)


func _physics_process(delta: float) -> void:
	if not paused:
		_set_cycle_time(cycle_time + delta)


func _set_cycle_time(value: float) -> void:
	value = fposmod(value, cycle_period)
	cycle_time = value
	set_time(int(range_lerp(value, 0, cycle_period, 0, DAY_PERIOD)))


# Sets the properties of the enviroment to match the specified time of the day.
# day_time is the time of the day in seconds, between [0, DAY_PERIOD).
func set_time(day_time: int) -> void:
	current_time = day_time
	cycle_time = range_lerp(day_time, 0, DAY_PERIOD, 0, cycle_period)
	if not is_instance_valid(world_env):
		# Return if there is no child.
		return
	# warning-ignore:narrowing_conversion
	day_time = fposmod(day_time, DAY_PERIOD)
	var weight := inverse_lerp(0, DAY_PERIOD, day_time)
	# Interpolate parameters.
	# Light rotation.
	sun_light.rotation.x = lerp(deg2rad(-SUN_MIDNIGHT_LATITUDE), deg2rad(-SUN_MIDNIGHT_LATITUDE) - 2*PI, weight)
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


func set_sun_longitude(value: float) -> void:
	value = clamp(value, -180.0, 180.0)
	sun_longitude = value
	
	if not is_instance_valid(background_sky):
		# Return if there is no child.
		return
	
	background_sky.sun_longitude = value
	sun_light.rotation.y = PI - deg2rad(value)


# Useful getters and setters.

func set_time_hhmmss(hours: int, mins: int, secs: int) -> void:
	set_time(hours * SECS_IN_AN_HOUR + mins * SECS_IN_A_MIN + secs)


func get_hours() -> int:
# warning-ignore:integer_division
	return int(floor(current_time / SECS_IN_AN_HOUR))

func get_mins() -> int:
# warning-ignore:integer_division
	return int(floor((current_time - get_hours() * SECS_IN_AN_HOUR) / SECS_IN_A_MIN))

func get_secs() -> int:
	return int(floor(current_time - get_hours() * SECS_IN_AN_HOUR - get_mins() * SECS_IN_A_MIN))


func get_time_to_string() -> String:
	return str(get_hours()) + ":" + str(get_mins()) + ":" + str(get_secs())
