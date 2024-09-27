package main

import "core:fmt"
import "core:time"
import "geo"
import "imports/obj"
import "mesh"
import "object"
import "render"
import rl "vendor:raylib"

NAME :: "render"
WIDTH :: 800
HEIGHT :: 600

_camera: rl.Camera
_objects: [dynamic]object.Object

init :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, NAME)
	rl.SetTargetFPS(60)

	_camera.position = {0, 2, 4}
	_camera.up = {0, 1, 0}
	_camera.target = {0, 0, 1}
	_camera.fovy = 90
	_camera.projection = .PERSPECTIVE
	rl.DisableCursor()

	meshes, err := obj.load("cube.obj")
	if err != nil {
		panic(fmt.aprint(err))
	}

	for msh in meshes {
		o := object.new(msh)
		append(&_objects, o)
	}
}

main :: proc() {
	init()

	for !rl.WindowShouldClose() {
		update()
		draw()
	}
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	// shit here

	rl.BeginMode3D(_camera)

	for o in _objects {
		render.render(o)
	}

	rl.EndMode3D()

	rl.EndDrawing()
}
