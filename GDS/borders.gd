extends CanvasLayer

# Dairy-fresh side borders per the GDD palette - sky blue with a cream trim,
# instead of the old flat dark blue bars.
const SKY_BLUE := Color(0.35, 0.75, 0.95, 0.9)
const CREAM_TRIM := Color(0.99, 0.98, 0.93, 1.0)

func _ready():
	# Left border
	var left = ColorRect.new()
	left.color = SKY_BLUE
	left.set_anchor_and_offset(SIDE_LEFT, 0, 0)
	left.set_anchor_and_offset(SIDE_RIGHT, 0, 80)
	left.set_anchor_and_offset(SIDE_TOP, 0, 0)
	left.set_anchor_and_offset(SIDE_BOTTOM, 1, 0)
	add_child(left)

	var left_trim = ColorRect.new()
	left_trim.color = CREAM_TRIM
	left_trim.set_anchor_and_offset(SIDE_LEFT, 0, 76)
	left_trim.set_anchor_and_offset(SIDE_RIGHT, 0, 80)
	left_trim.set_anchor_and_offset(SIDE_TOP, 0, 0)
	left_trim.set_anchor_and_offset(SIDE_BOTTOM, 1, 0)
	add_child(left_trim)

	# Right border
	var right = ColorRect.new()
	right.color = SKY_BLUE
	right.set_anchor_and_offset(SIDE_LEFT, 1, -80)
	right.set_anchor_and_offset(SIDE_RIGHT, 1, 0)
	right.set_anchor_and_offset(SIDE_TOP, 0, 0)
	right.set_anchor_and_offset(SIDE_BOTTOM, 1, 0)
	add_child(right)

	var right_trim = ColorRect.new()
	right_trim.color = CREAM_TRIM
	right_trim.set_anchor_and_offset(SIDE_LEFT, 1, -80)
	right_trim.set_anchor_and_offset(SIDE_RIGHT, 1, -76)
	right_trim.set_anchor_and_offset(SIDE_TOP, 0, 0)
	right_trim.set_anchor_and_offset(SIDE_BOTTOM, 1, 0)
	add_child(right_trim)
