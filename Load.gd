extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var crane := "res://Crane.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body.is_in_group("hook"): # Check if the entered body is the hook
		# Notify the hook that it's in proximity to this load
		Globals.nearby_load = $AttachPoint
		print (Globals.nearby_load)
		print("Hook is near the load")


func _on_Area_body_exited(body):
	if body.is_in_group("hook") and Globals.nearby_load == $RigidBody: # Ensure it's the same load
		Globals.nearby_load = null
		print("Hook has left the load")
	
