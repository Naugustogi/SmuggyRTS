extends CharacterBody3D

@export var cameraPivot: Node3D

func _is_near_ground(currCamera):
	var space_state = currCamera.get_world_3d().direct_space_state
	var start = Vector3(currCamera.position.x, currCamera.position.y + 1000, currCamera.position.z)
	var end = Vector3(currCamera.position.x, currCamera.position.y - 300, currCamera.position.z)
	var query = PhysicsRayQueryParameters3D.create(start, end)
	var result = space_state.intersect_ray(query)
	if result:
		return result.position.y
	else:
		return 0
	
var currentMousePos = Vector2(0, 0)
var pressed = false
var currentRotation = 0
var selected_unit = null
	 
func _select_unit():
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var camera3d = cameraPivot.get_node("Camera3D")
	var from = camera3d.project_ray_origin(mousepos)
	var to = from + camera3d.project_ray_normal(mousepos) * 1000.0
	var query = PhysicsRayQueryParameters3D.create(from, to)

	var result = space_state.intersect_ray(query)
	if selected_unit:
		selected_unit.unselect()
		selected_unit = null
	if result and result.collider:
		print(result.collider.name)
		print(result.collider.is_in_group("unit"))
		if result.collider.is_in_group("unit") and result.collider != selected_unit:
			result.collider.select()
			selected_unit = result.collider
			
func _move_unit():
	if !selected_unit:
		return
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var camera3d = cameraPivot.get_node("Camera3D")
	var from = camera3d.project_ray_origin(mousepos)
	var to = from + camera3d.project_ray_normal(mousepos) * 1000.0
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	if !result or !result.collider or result.collider.name != "HTerrain":
		return
	selected_unit.look_at(result.position, Vector3.UP)
	selected_unit.position = result.position

func _physics_process(delta):
	# We create a local variable to store the input direction.
	var new_pos = 5 if Input.is_action_pressed("shift") else 2
	var terrain_y = _is_near_ground(cameraPivot)
	var is_near = terrain_y + 50 > cameraPivot.position.y
	if is_near:
		cameraPivot.position.y = terrain_y + 50

	var rotation = cameraPivot.get_global_transform().basis
	var forward = -rotation.z * new_pos
	var backward = rotation.z * new_pos
	var left = -rotation.x * new_pos
	var right = rotation.x * new_pos
	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		cameraPivot.position += right
	if Input.is_action_pressed("move_left"):
		cameraPivot.position += left
	if Input.is_action_pressed("move_back"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		cameraPivot.position += backward
	if Input.is_action_pressed("move_forward"):
		cameraPivot.position += forward
		
	if Input.is_action_just_released("scroll_up") and terrain_y - cameraPivot.position.y < -52:
		cameraPivot.position.y -= 10
		
	if Input.is_action_just_released("scroll_down"):
		cameraPivot.position.y += 10
		
	if Input.is_action_just_pressed("scroll_press"):
		currentMousePos = get_viewport().get_mouse_position()
		currentRotation = cameraPivot.rotation.y
		pressed = true
		
	if Input.is_action_just_released("scroll_press"):
		pressed = false
	if Input.is_action_just_pressed("lmb"):
		_select_unit()
	
	if Input.is_action_pressed("rmb"):
		_move_unit()
	
	if pressed:
		cameraPivot.rotation.y = currentRotation + (currentMousePos.x - get_viewport().get_mouse_position().x) / 100

