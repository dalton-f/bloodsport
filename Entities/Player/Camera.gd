extends Camera3D

func _camera_shake(time: float, strength: float):
	var elapsed_time := 0.0

	while elapsed_time < time:
		var offset := Vector3(randf_range(-strength, strength), randf_range(-strength, strength), 0.0)
		
		transform.origin += offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame
