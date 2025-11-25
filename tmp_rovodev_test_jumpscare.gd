extends Node

## Quick Jumpscare Tester
## Attach this to a node in your nights scene to test jumpscares with SPACE key

@export var test_character: String = "TKRSprinter"  # Change this to test different characters
@export var jumpscare_manager_path: NodePath = ""

var jumpscare_manager: Node = null

func _ready() -> void:
	# Find the jumpscare manager
	if jumpscare_manager_path:
		jumpscare_manager = get_node(jumpscare_manager_path)
	else:
		# Try to find it automatically
		jumpscare_manager = get_node_or_null("/root/Nights/JumpscareManager")
		if not jumpscare_manager:
			jumpscare_manager = get_tree().root.find_child("JumpscareManager", true, false)
	
	if jumpscare_manager:
		print("[Jumpscare Tester] Ready! Press SPACE to test jumpscare for:", test_character)
	else:
		print("[Jumpscare Tester] WARNING: Could not find JumpscareManager!")

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.is_pressed():
			_test_jumpscare()

func _test_jumpscare() -> void:
	if not jumpscare_manager:
		print("[Jumpscare Tester] ERROR: No JumpscareManager found!")
		return
	
	if jumpscare_manager.has_method("trigger_jumpscare"):
		print("[Jumpscare Tester] Triggering jumpscare for:", test_character)
		jumpscare_manager.trigger_jumpscare(test_character)
	else:
		print("[Jumpscare Tester] ERROR: JumpscareManager doesn't have trigger_jumpscare method!")
