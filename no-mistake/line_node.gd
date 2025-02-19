extends StaticBody2D

@onready var line: Line2D = $Line2D
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D
var hitbox = load("res://line_collision_point.tscn")
var points: Array  # Stores line points
var thickness: float
var splitting: bool = false  # Prevent multiple calls

func set_line(new_points: Array, new_thickness: float):
	points = optimize_points(new_points)  # Remove close points & add extra ones
	thickness = new_thickness
	$Line2D.width = thickness
	$Line2D.default_color = Color.BLACK
	$Line2D.clear_points()

	for point in points:
		$Line2D.add_point(point)

	create_collision_shape(points, thickness)

func optimize_points(input_points: Array) -> Array:
	""" Cleans up points by removing close ones and adding extra ones when too far apart. """
	var min_distance = 20.0  # Remove points if they are closer than this
	var max_distance = 20.0  # Add extra points if two are further apart than this
	var optimized_points = []

	for i in range(input_points.size()):
		if i == 0:
			optimized_points.append(input_points[i])
			continue

		var last_point = optimized_points[-1]
		var current_point = input_points[i]
		var distance = last_point.distance_to(current_point)

		# Skip adding this point if it's too close to the previous one
		if distance < min_distance:
			continue

		# Add extra points if the distance is too large
		if distance > max_distance:
			var num_extra_points = ceil(distance / max_distance)
			for j in range(1, num_extra_points):
				var t = float(j) / num_extra_points
				optimized_points.append(last_point.lerp(current_point, t))

		optimized_points.append(current_point)

	return optimized_points

func create_collision_shape(points: Array, thickness: float):
	if points.size() < 2:
		return

	var polygon = PackedVector2Array()
	var half_width = thickness * 0.5

	var top_edge = PackedVector2Array()
	var bottom_edge = PackedVector2Array()

	for i in range(points.size()):
		var p1 = points[i]

		# Get direction to the next point, or use previous if it's the last point
		var direction = (points[i + 1] - p1).normalized() if i < points.size() - 1 else (p1 - points[i - 1]).normalized()
		var perpendicular = Vector2(-direction.y, direction.x) * half_width

		# Add the top and bottom edges separately
		top_edge.append(p1 + perpendicular)
		bottom_edge.append(p1 - perpendicular)

	# Reverse the bottom edge to properly close the polygon
	bottom_edge.reverse()

	# Combine both edges to form the final polygon
	polygon.append_array(top_edge)
	polygon.append_array(bottom_edge)

	$CollisionPolygon2D.polygon = polygon
	for i in $Line2D.get_point_count():
		
		var p = $Line2D.get_point_position(i)
		var l = hitbox.instantiate()
		l.position = p
		l.point_ID = i
		add_child(l)


var split_id = 0  # Unique ID to prevent duplicate splits

func split_line_at_gap(index: int, gap_size: float = 10.0):
	"""Splits the line at index `index`, deletes the old line, and creates two new lines with a gap."""
	if splitting:
		return  # Prevent duplicate splits

	splitting = true  # Lock function to prevent multiple executions

	if index < 1 or index >= points.size() - 1:
		print("❌ Invalid split index:", index)
		splitting = false
		return

	print("✂ Splitting line at index:", index, "with gap:", gap_size)

	if not is_inside_tree():
		splitting = false
		return  # Prevent running after queue_free

	var parent = get_parent()
	if not parent:
		print("❌ No parent found!")
		splitting = false
		return

	# Store world position before deletion
	var world_position = global_position  

	var split_point = points[index]
	var direction = (points[index + 1] - points[index - 1]).normalized()

	# Move the new endpoints slightly apart to create a gap
	var first_end = split_point - direction * (gap_size * 0.5)
	var second_start = split_point + direction * (gap_size * 0.5)

	# Create the two new point lists
	var first_segment = points.slice(0, index) + [first_end]
	var second_segment = [second_start] + points.slice(index + 1, points.size())

	# Generate a unique split ID
	split_id += 1
	var current_split_id = split_id


	# Wait a frame to ensure the node is fully deleted
	await get_tree().process_frame  

	# If a new split was called, ignore this one
	if current_split_id != split_id:
		splitting = false
		return

	# Create two new lines
	var first_line = load("res://line_node.tscn").instantiate()
	var second_line = load("res://line_node.tscn").instantiate()

	# Keep the same global position (DO NOT CHANGE IT)
	first_line.global_position = world_position
	second_line.global_position = world_position

	# DO NOT adjust global_position, just use the points directly
	first_line.set_line(first_segment, thickness)
	second_line.set_line(second_segment, thickness)

	# Add new lines to parent safely
	parent.add_child(first_line)
	parent.add_child(second_line)

	splitting = false  # Unlock after splitting is complete
	queue_free()
