extends CanvasLayer

func _ready():
	# Left border
	var left = ColorRect.new()
	left.color = Color(0.1, 0.1, 0.3, 0.85)
	left.set_anchor_and_offset(SIDE_LEFT, 0, 0)
	left.set_anchor_and_offset(SIDE_RIGHT, 0, 80)
	left.set_anchor_and_offset(SIDE_TOP, 0, 0)
	left.set_anchor_and_offset(SIDE_BOTTOM, 1, 0)
	add_child(left)
	
	# Right border
	var right = ColorRect.new()
	right.color = Color(0.1, 0.1, 0.3, 0.85)
	right.set_anchor_and_offset(SIDE_LEFT, 1, -80)
	right.set_anchor_and_offset(SIDE_RIGHT, 1, 0)
	right.set_anchor_and_offset(SIDE_TOP, 0, 0)
	right.set_anchor_and_offset(SIDE_BOTTOM, 1, 0)
	add_child(right)
