package main

import "../imports/obj"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	defer free_all(context.allocator)
	data, ok := os.read_entire_file("cube.obj")
	if !ok do panic("shit")

	lines := strings.split_lines(string(data))
	meshes, err := obj.parse_meshes(lines)
	if err != nil {
		panic(fmt.aprint(err))
	}

	fmt.println(meshes[0])
}
