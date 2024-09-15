package main

import "core:time"
import rl "vendor:raylib"

NAME :: "render"
WIDTH :: 800
HEIGHT :: 600

camera: rl.Camera

init_window :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, NAME)
	rl.SetTargetFPS(60)

	camera.position = {0, 2, 4}
	camera.up = {0, 1, 0}
	camera.target = {0, 0, 1}
	camera.fovy = 90
	camera.projection = .PERSPECTIVE
	rl.DisableCursor()
}

main :: proc() {
	init_window()

	for !rl.WindowShouldClose() {
		update()
		draw()
	}
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	// shit here

	rl.BeginMode3D(camera)
	display()
	rl.EndMode3D()

	rl.EndDrawing()
}


display :: proc() {
	rl.DrawPlane({}, {32, 32}, rl.LIGHTGRAY)
}
