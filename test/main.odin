package main

import "../imports/obj"
import "core:fmt"
import "core:os"
import "core:strings"
import ui "vendor:microui"
import rl "vendor:raylib"

main :: proc() {
	ctx := new(ui.Context)
	ui.init(ctx)
	ui.begin_window(ctx, "hello")
}
