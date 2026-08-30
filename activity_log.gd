extends PanelContainer


const MAX_ENTRIES: int = 5


var entries: Array[String] = []


@onready var entries_label: Label = \
	$MarginContainer/VBoxContainer/Entries


func _ready() -> void:
	Events.activity_logged.connect(
		_on_activity_logged
	)

	_refresh()


func _on_activity_logged(message: String) -> void:
	entries.push_front(message)

	if entries.size() > MAX_ENTRIES:
		entries.resize(MAX_ENTRIES)

	_refresh()


func _refresh() -> void:
	if entries.is_empty():
		entries_label.text = "Waiting for activity..."
		return

	var output: String = ""

	for i in range(entries.size()):
		if i > 0:
			output += "\n"

		output += entries[i]

	entries_label.text = output
