extends Node3D

var isOnArea: bool = false
@onready var anim: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isOnArea == true and Input.is_action_just_pressed("interact"):
		anim.play("Open")
	elif isOnArea == false and Input.is_action_just_pressed("interact"):
		anim.play("Close")



func _on_area_3d_body_entered(body: Node3D) -> void:
	isOnArea = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	isOnArea = false
