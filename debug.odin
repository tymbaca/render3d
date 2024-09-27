package main

import "core:fmt"
import rl "vendor:raylib"

DEBUG :: false

debug :: proc(args: ..any) {
	when DEBUG do fmt.println(..args)
}
