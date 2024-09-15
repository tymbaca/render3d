package main

import "core:fmt"
import rl "vendor:raylib"

debug :: proc(args: ..any) {
	fmt.println(..args)
}
