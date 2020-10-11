# GodotStuff

This is a collection of interesting contepts I've developed while creating Woodland Empire


TimelapseCamera.tscn

You can add this scene anywhere in the tree. It takes a global transform and sets up a camera with that transform. 

Example usage:


SomeNode.tscn


func _ready():
	
	signals.connect("add_timelapse_camera",self,"on_add_timelapse_camera")

func on_add_timelapse_camera(_transform):
	var tlc_scene = load("res://scenes/cameras/TimelapseCamera.tscn")
	var tlc_instance = tlc_scene.instance()
	add_child(tlc_instance)
	var wait_time = 1.0
	var num_frames = 30*120
	tlc_instance.start_timelapse(_transform, wait_time, num_frames)
