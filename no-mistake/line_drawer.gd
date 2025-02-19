extends Node2D

@export var max_resource: float = 100.0  # Max drawing resource
@export var line_thickness: float = 10.0  # Thickness of the line
@export var line_scene: PackedScene  # Scene for the drawn lines

var resource: float
var drawing: bool = false
var points: Array  # Stores drawn points
var temp_line: Line2D  # Temporary preview line

func _ready():
	Globals.Materials = max_resource
	temp_line = Line2D.new()
	temp_line.width = line_thickness
	temp_line.default_color = Color.BLACK  # Make it black
	add_child(temp_line)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Input.is_action_pressed("click"):
				start_drawing(get_global_mouse_position())  # Use global position
			else:
				finish_drawing()

	if event is InputEventMouseMotion and drawing and Globals.Materials > 0:
		add_point_to_line(get_global_mouse_position())  # Use global position

func start_drawing(start_pos: Vector2):
	drawing = true
	points.clear()
	points.append(start_pos)
	temp_line.clear_points()
	temp_line.add_point(start_pos)

func add_point_to_line(new_pos: Vector2):
	if points.size() > 0 and points[-1].distance_to(new_pos) > 2:
		points.append(new_pos)
		temp_line.add_point(new_pos)  # Update the temporary line
		Globals.Materials -= points[-2].distance_to(new_pos) * 0.2

func finish_drawing():
	if points.size() > 1:
		var new_line_node = line_scene.instantiate()
		new_line_node.position = points[0]
		if Input.is_action_just_released("click"):
			temp_line.clear_points()  # Set position to first point
			get_parent().add_child(new_line_node)  # Add to parent (not self) 
		# Convert points to local space for the new node
		var local_points = []
		for point in points:
			local_points.append(point - points[0])  # Make positions local to new node

		new_line_node.set_line(local_points, line_thickness)

	  # Clear preview line
	drawing = false
