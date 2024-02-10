extends Spatial

var slewAngle := 0.0
var luffAngle := -30.0
var cargo: Node = null
var nearby_load:= Globals.nearby_load
var is_load_attached := false
var joint: Node = null
var load_instance
var original_load_info

onready var craneHouse = $CraneHouse
onready var boom = $CraneHouse/Boom
onready var hook = $Hook
onready var boomTip = $CraneHouse/Boom/BoomTip
onready var cargo_empty = $Hook/CargoEmpty
onready var load_on_hook = $Load/AttachPoint
onready var audio_move = $AudioStreamPlayer3D2

export var slewSpeed := 0.3
export var luffSpeed := 0.3
export var hoistSpeed := 0.2
export var cableLength := 2.0
export var cableStiffness := 0.5




# Called when the node enters the scene tree for the first time.
func _ready():
	hook.add_to_group("hook")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_left"):
		slewAngle += slewSpeed*delta
	
		
	if Input.is_action_pressed("ui_right"):
		slewAngle -= slewSpeed*delta
	if Input.is_action_pressed("ui_up"):
		luffAngle += luffSpeed*delta
	if Input.is_action_pressed("ui_down"):
		luffAngle -= luffSpeed*delta
	if Input.is_action_pressed("HookDown"):
		cableLength += hoistSpeed*delta
	if Input.is_action_pressed("HookUp"):
		cableLength -= hoistSpeed*delta
		
	if Input.is_action_just_pressed("ui_left"):
		audio_move.play()
	if Input.is_action_just_released("ui_left"):
		audio_move.stop()
	if Input.is_action_just_pressed("ui_right"):
		audio_move.play()
	if Input.is_action_just_released("ui_right"):
		audio_move.stop()	
	if Input.is_action_just_pressed("ui_up"):
		audio_move.play()
	if Input.is_action_just_released("ui_up"):
		audio_move.stop()
	if Input.is_action_just_pressed("ui_down"):
		audio_move.play()
	if Input.is_action_just_released("ui_down"):
		audio_move.stop()
	if Input.is_action_just_pressed("HookDown"):
		audio_move.play()
	if Input.is_action_just_released("HookDown"):
		audio_move.stop()
	if Input.is_action_just_pressed("HookUp"):
		audio_move.play()
	if Input.is_action_just_released("HookUp"):
		audio_move.stop()
		
	if Input.is_action_just_pressed("ConnectLoad"):
		if not is_load_attached:
			attach_load()
			
			print("E pressed")
		else:
			detach_load()
	nearby_load = Globals.nearby_load
					
		
	
	SlewCrane()
	LuffCrane()
	
		
		
func _physics_process(delta):
	var anchor_pos = boomTip.global_transform.origin
	var hook_pos = hook.global_transform.origin
	var direction = (anchor_pos - hook_pos).normalized()
	var current_distance = anchor_pos.distance_to(hook_pos)
	
	# Calculate cable force based on distance and direction
	var excess_length = max(0, current_distance - cableLength)
	var force_magnitude = calculate_force_magnitude(excess_length) # Implement this
	var cable_force = direction * force_magnitude
	
	
	
	
	# Combine forces and apply
	#hook.add_central_force(cable_force)
	var forceAttack = Vector3(0,0.01,0)
	hook.add_force(cable_force, forceAttack)
	
# Calculates the force magnitude based on the excess length of the cable.
# `excess_length` is the amount by which the current cable length exceeds the set cable length.
# `stiffness` represents the cable's stiffness or how strongly it resists stretching.
func calculate_force_magnitude(excess_length):
	
	var damping_coefficient = 1 # Adjust this value based on desired damping effect
	var y_velocity = hook.linear_velocity.y # Get the hook's velocity in the y-axis
	
	# Calculate the damping force based on the y-axis velocity
	var damping_force = -damping_coefficient * y_velocity * hook.weight
	var force_magnitude = (excess_length * cableStiffness * hook.weight) + damping_force
	return force_magnitude
	
func SlewCrane():
	var craneHouseOrientation := Vector3(0,slewAngle,0)
	craneHouse.set_rotation_degrees(craneHouseOrientation)

func LuffCrane():
	var boomOrientation := Vector3(0,0,luffAngle)
	boom.set_rotation_degrees(boomOrientation)
	
		


func attach_load():
	
	if load_on_hook.visible == true:
		load_on_hook.visible = false
		for i in load_on_hook.get_children():
			i.set_physics_process(false)
	else:
		load_on_hook.visible = true
		for i in load_on_hook.get_children():
			i.set_physics_process(true)
#	
	if Globals.nearby_load:
		load_instance = Globals.nearby_load
		cargo_empty = $Hook/CargoEmpty 
		
		# Store the original parent before reparenting
		original_load_info = load_instance.get_parent()
		var scale = load_instance.scale
		
		# Before attempting to add the load as a child of CargoEmpty,
		# remove it from its current parent, if it has one.
		if load_instance.get_parent():
			load_instance.get_parent().remove_child(load_instance)
		
		# Now that the load is free of its previous parent, add it to CargoEmpty.
		cargo_empty.add_child(load_instance)
		
		# Reset the load's local transform to align it properly with CargoEmpty.
		# You might need to adjust this transform based on your requirements.
		#load_instance.transform = Transform()
		
		#load_instance.scale = scale
		
		is_load_attached = true
		print("Load attached to CargoEmpty")
	
	
	
	
# Function to detach the load, reversing the attachment process
func detach_load():
	# Remove or disable the joint
	print("Load detached")
	if is_load_attached:
		
		cargo_empty.remove_child(load_instance)
		if original_load_info:
			original_load_info.add_child(load_instance)
			original_load_info.global_transform = cargo_empty.global_transform
	original_load_info = null
	is_load_attached = false

