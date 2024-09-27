package main

import "object"
import rl "vendor:raylib"

SPEED :: .2
MOUSE_SENSITIVITY :: .1
MOVE_SPEED :: .5

update :: proc() {
	if rl.IsKeyDown(.LEFT) {
		object.rotate(&_objects[0], +0.5, 0, 0)
	}
	if rl.IsKeyDown(.RIGHT) {
		object.rotate(&_objects[0], -0.5, 0, 0)
	}
	if rl.IsKeyDown(.UP) {
		_objects[0].position.y += MOVE_SPEED
	}
	if rl.IsKeyDown(.DOWN) {
		_objects[0].position.y -= MOVE_SPEED
	}

	//--------------------------------------------------------------------------------------------------

	rl.UpdateCameraPro(&_camera, get_movement(), get_rotation(), 0)
	debug(_camera)


	/*
	wp := rl.GetWindowPosition()
	debug(wp)
	if rl.IsKeyDown(.LEFT) {
		wp.x -= 10
	}
	if rl.IsKeyDown(.RIGHT) {
		wp.x += 10
	}
	if rl.IsKeyDown(.UP) {
		wp.y -= 10
	}
	if rl.IsKeyDown(.DOWN) {
		wp.y += 10
	}
	rl.SetWindowPosition(i32(wp.x), i32(wp.y))
    */
}

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
