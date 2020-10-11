extends Spatial

class_name TimedThreadProcess
export var use_thread:bool = true
export var autostart_timer:bool = false
export var wait_time:float = 1.0

var timer:Timer
var thread:Thread
var mutex:Mutex
var semaphore:Semaphore
var should_exit:bool = false
var _is_setup = false
var _has_started = false



var object
var method_name:String
var logger = logging.get_logger("TimedThreadProcess.gd")


#timed_threads,timed_thread_timers
func _ready():
	add_to_group(groups.TIMED_THREADS)
	thread = Thread.new()
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	timer = Timer.new()
	timer.set_one_shot(false)
	timer.set_wait_time(self.wait_time)
	timer.set_autostart(self.autostart_timer)
	timer.add_to_group(groups.TIMED_THREAD_TIMERS)
	add_child(timer)
	timer.connect("timeout",self,"post")
	
func _thread_func(userdata):
	print("Thread started")
	if not use_thread:
		print("not threaded, returning!!!!!!!!!!!!!!!!!!!")
		return
	while true:
		
		semaphore.wait()
		mutex.lock()
		if should_exit:
			print('exiting in thread')
			break
		mutex.unlock()

		object.call(method_name)
		

func post():	
	#print('posting: %s' %[self.method_name])
	if !_is_setup:
		print("posted to thread that isn't set up! (%s)"%[self.method_name])
		return
	if ! _has_started:
		print("posted to thread that hasn't started! (%s)"%[self.method_name])
		return
	

	if use_thread:
		semaphore.post()
	else:
		#print('calling directly!!!!!!')
		object.call(method_name)


func setup(_object,_method_name):
	
	if _is_setup or _has_started:
		print("Can't re-setup this thread!")
		assert(false)
	
	if ! _object.has_method(_method_name):
		print("%s does not have method %s" %[_object, _method_name])
	
	
	self.object = _object
	self.method_name = _method_name
	self._is_setup = true
	logger.info("Thread setup","thread_(%s)" %[self.method_name])
		
	if not use_thread:
		print("Not starting thread!!!!!!!!!!!!!!!!")
		return

func start_thread():
	if ! _is_setup:
		print("thread not set up yet, missing call to  .setup(object, method_name)")
		assert(false)
	if _has_started:
		print('thread already started, returning')
		assert(false)
		return
	mutex.lock()
	should_exit = false
	mutex.unlock()
	var _err = thread.start(self,"_thread_func", null)
	print("thread starting (%s) status: %s" %[self.method_name, _err])
	if _err == OK:
		logger.info("Thread started OK","thread_(%s)" %[self.method_name])
		_has_started = true

func stop_thread():
	mutex.lock()
	should_exit = true
	mutex.unlock()
	semaphore.post()
		
	
func _kill():
	stop_thread()
	if thread.is_active():
		print('thread (%s) is active, waiting...' % [self.method_name])
		thread.wait_to_finish()
		print('thread (%s) finished' % [self.method_name])
	print('finished killing (%s)' % [self.method_name])
	
func _exit_tree():
	
	print('exiting tree (%s)' %[self.method_name])
	_kill()
	
