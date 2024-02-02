@tool
class_name PupGraphNode extends GraphNode

signal modified
@onready var title_hbox = $TitleControl/HBoxContainer
@onready var edit_button = %EditTitleButton
@onready var title_edit = %TitleEdit
@onready var title_label = %TitleLabel
@onready var control_separator = %ControlSeparator
@onready var _minsize = size

var editing_title = false
var active = false


func _ready():
	connect("resize_request",_on_resize)
	
	title_edit.connect("text_changed",_on_title_edited)
	edit_button.connect("pressed",_on_title_start_editing)
	title_edit.connect("focus_exited",_on_title_finish_editing)
	
	var new_size = Vector2(size.x,$TitleControl.size.y)
	$TitleControl.set_deferred("size",new_size)
	call_deferred("_on_resize",size)
	
	if active:
		control_separator.visible = true
		move_child(control_separator,get_child_count()-1)

func set_title(new_title):
	title_label.text = new_title
	title_edit.text = new_title

func _on_resize(new_minsize):
	new_minsize.x = max(new_minsize.x, _minsize.x)
	new_minsize.y = max(new_minsize.y, _minsize.y)
	custom_minimum_size = new_minsize
	size = new_minsize
	
	
	_on_node_modified()
	
	title_hbox.size.x = title_hbox.get_parent().size.x
	title_hbox.position = Vector2(0,-28)

# Called when the edit button is clicked.
func _on_title_start_editing():
	title_edit.editable = true
	title_edit.grab_focus()
	title_edit.visible = true
	title_label.get_parent().visible = false
	title_edit.mouse_filter = MOUSE_FILTER_STOP
	
	edit_button.self_modulate = Color.TRANSPARENT
	edit_button.mouse_filter = MOUSE_FILTER_IGNORE
	
	editing_title = true

#Called when the line edit loses focus.
func _on_title_finish_editing():
	title_edit.editable = false
	title_edit.visible = false
	title_label.text = title_edit.text
	title_label.get_parent().visible = true
	title_edit.mouse_filter = MOUSE_FILTER_IGNORE
	
	edit_button.self_modulate = Color.WHITE
	edit_button.mouse_filter = MOUSE_FILTER_STOP
	
	editing_title = false

func _on_node_modified():
	emit_signal("modified")

func _on_title_edited(_discard):
	_on_node_modified()
	#_on_resize(Vector2(max(size.x,title_hbox.size.x),size.y))

func _input(event):
	if editing_title and event is InputEventKey and event.keycode == KEY_ENTER:
		title_edit.release_focus()
