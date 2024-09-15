package main

import rl "vendor:raylib"

update :: proc() {
	rl.UpdateCameraPro(&camera, get_movement(), get_rotation(), 0)
	debug(camera)
}

SPEED :: .6
MOUSE_SENSITIVITY :: 0.1

get_movement :: proc() -> rl.Vector3 {
	forward := pressed_f32(.W) * SPEED
	backward := pressed_f32(.S) * SPEED
	x := forward - backward

	right := pressed_f32(.D) * SPEED
	left := pressed_f32(.A) * SPEED
	y := right - left

	up := pressed_f32(.R) * SPEED
	down := pressed_f32(.F) * SPEED
	z := up - down

	return {x, y, z}
}

get_rotation :: proc() -> rl.Vector3 {
	rot := rl.GetMouseDelta() * MOUSE_SENSITIVITY

	return {rot.x, rot.y, 0}
}

pressed_f32 :: proc(key: rl.KeyboardKey) -> f32 {
	return f32(int(rl.IsKeyDown(key)))
}
