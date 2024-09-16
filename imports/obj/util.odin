package obj

import "core:strconv"
import "core:strings"

@(private)
parse_f32 :: proc(s: string) -> (value: f32, ok: bool) {
	return strconv.parse_f32(strings.trim(s, " "))
}

@(private)
parse_int :: proc(s: string) -> (value: int, ok: bool) {
	return strconv.parse_int(strings.trim(s, " "))
}
