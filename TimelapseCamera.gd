extends Spatial

var timer_id = 0 #random id for this timelapse (could have multiple in one game)
onready var timer = $TimelapseTimer
onready var viewport = $Viewport

var frames_to_take = 0
var frames_taken = 0

onready var timed_thread = $TimedThreadProcess
# Called when the node enters the scene tree for the first time.
func _ready():
	self.timer_id = randi()
	timed_thread.setup(self,'_threaded_func')

func start_timelapse(_transform, _wait_time, num_frames):
	
	if _wait_time < 1.0:
		print("Could not start timelapse. wait_time must be >= 1.0.")
		return 
	var dir = Directory.new()
	dir.make_dir_recursive('user://timelapses/%s/' %[timer_id])
	frames_to_take = num_frames + 1
	$Viewport/TimelapseCamera.global_transform = _transform	
	timed_thread.wait_time = _wait_time
	timed_thread.start_thread() 


func _threaded_func():
	var fname = "user://timelapses/%s/%s.png" %[timer_id,frames_taken]
	print('saving...',fname)
	var image = viewport.get_texture().get_data()
	var _err = image.save_png(fname)
	if _err == OK:
		print('...saved.')
	else:
		print('err:',_err)
	frames_taken+=1
	if frames_taken > frames_to_take:
		timed_thread.stop_thread()
		call_deferred("queue_free")
