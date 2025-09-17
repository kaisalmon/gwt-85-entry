extends Node3D

var fadein_time = 0.8
var timer = 0.0

func _ready() -> void:
    $CanvasLayer/Fadeout.color.a = 1.0

func _process(delta: float) -> void:
    if timer < fadein_time:
        timer += delta
        $CanvasLayer/Fadeout.color.a = lerp(1.0, 0.0, timer / fadein_time)
        