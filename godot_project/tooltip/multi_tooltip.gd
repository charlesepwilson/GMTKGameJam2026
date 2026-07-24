class_name MultiTooltip
extends VBoxContainer


func show_tooltip():
	for tooltip in get_children():
		tooltip.show_tooltip()

func hide_tooltip():
	for tooltip in get_children():
		tooltip.hide_tooltip()

