package obj

import "../../mesh"
import "core:fmt"
import "core:os"

Data :: struct {
	vs:      []V,
	vns:     []VN,
	vts:     []VT,
	objects: []Object,
}

Object :: struct {
	name:  string,
	s:     S,
	faces: [dynamic]F,
}

Stmt :: union {
	O,
	V,
	VN,
	VT,
	F,
	S,
}

Parse_Error :: union {
	string,
}

O :: distinct string
V :: distinct mesh.Vector3
VN :: distinct mesh.Vector3
VT :: distinct mesh.Vector2
S :: distinct bool
F :: distinct [][3]int

parse_mesh :: proc(lines: []string) -> (msh: mesh.Mesh, err: Parse_Error) {
	props := make([dynamic]Stmt)
	defer delete(props)

	for line in lines {
		p := parse_prop(line) or_return
		append(&props, p)
	}

	data := form_data(props[:])

	return
}

parse_prop :: proc(line: string) -> (Stmt, Parse_Error) {
	if len(line) == 0 {

	}

	panic("")
}

form_data :: proc(props: []Stmt) -> Data {
	vs := make([dynamic]V)
	objects := make([dynamic]Object)

	active_object: Object
	is_active_object := false

	for prop in props {
		switch p in prop {
		case O:
			if is_active_object {
				append(&objects, active_object)
			}

			active_object = Object {
				name  = string(p),
				faces = make([dynamic]F),
			}
		case V:
			append(&vs, p)
		case VN:
			piss()
		case VT:
			piss()
		case F:
			append(&active_object.faces, p)
		case S:
			piss()
		}
	}

	return Data{vs = vs[:], objects = objects[:]}
}

data_to_meshs :: proc(data: Data) -> []mesh.Mesh {
	meshs := make([dynamic]mesh.Mesh, 0, len(data.objects))

	for object in data.objects {
		for face in object.faces {
			if len(face) != 3 {
				shit("watch you n-gones dumbass (i don't care if it's 4 or 2 or 0)")
			}

			// for now only support first argument in `f` objects - `v`
			for point in face {
				v_idx := point[0] - 1 // because .obj uses 1-based indexing (hello tj)


			}
		}
	}
}

shit :: proc(msg := "this feature is not supported") {
	final_msg := fmt.aprint("shit: %s", msg)
	panic(final_msg)
}

piss :: proc(msg := "this feature is not supported") {
	fmt.printf("shit: %s", msg)
}
