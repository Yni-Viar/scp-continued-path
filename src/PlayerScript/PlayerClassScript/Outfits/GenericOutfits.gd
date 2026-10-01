extends MeshInstance3D
## Apply seasonal outfits
## Applied only for built-in classes.
## Made by Yni, licensed under MIT License.

@export var christmas_material: Array[Material]
@export var halloween_material: Array[Material]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match Settings.current_season:
		Settings.Season.CHRISTMAS:
			for i in range(christmas_material.size()):
				if christmas_material[i] == null:
					continue
				set_surface_override_material(i, christmas_material[i])
		Settings.Season.HALLOWEEN:
			for i in range(halloween_material.size()):
				if halloween_material[i] == null:
					continue
				set_surface_override_material(i, halloween_material[i])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
