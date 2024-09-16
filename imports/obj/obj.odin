package obj


import "../../mesh"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"
import "core:strings"

Data :: struct {
	vs:      []Vertex,
	vns:     []VertexNormal,
	vts:     []VertexTexture,
	objects: []Object,
}

Object :: struct {
	name:  string,
	s:     Smoothing,
	faces: [dynamic]Face,
}

Statement :: union {
	ObjectDecl,
	Vertex,
	VertexNormal,
	VertexTexture,
	Face,
	Smoothing,
}

Error :: union {
	Parse_Error,
}

Parse_Error :: struct {
	line: int,
	msg:  string,
}

ObjectDecl :: distinct string
Vertex :: distinct mesh.Vector3
VertexNormal :: distinct mesh.Vector3
VertexTexture :: distinct mesh.Vector2
Smoothing :: distinct bool
Face :: distinct []FacePoint

FacePoint :: [3]int

parse_mesh :: proc(lines: []string) -> ([]mesh.Mesh, Error) {
	stmts, err := parse_stmts(lines)
	defer delete(stmts)
	if err != nil do return nil, err

	data := form_data(stmts)

	return data_to_meshs(data), nil
}

parse_stmts :: proc(lines: []string, alloc := context.allocator) -> ([]Statement, Error) {
	context.allocator = alloc
	defer free_all(context.temp_allocator)

	stmts := make([dynamic]Statement)

	for line, i in lines {
		if len(line) == 0 do continue

		parts := strings.split(line, " ", context.temp_allocator)
		if len(parts) < 2 do return nil, Parse_Error{line = i + 1, msg = "too little parts in statement"}

		p: Statement

		switch parts[0] {
		case "o":
			if len(parts) != 2 do return nil, Parse_Error{line = i + 1, msg = "object stmt must have 2 parts"}

			p = ObjectDecl(strings.clone(parts[1]))

		case "v":
			if len(parts) != 4 do return nil, Parse_Error{line = i + 1, msg = "vertex stmt must have 3 coords"}

			x, y, z: f32
			ok: bool

			x, ok = parse_f32(parts[1])
			if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to float, 1st coord"}

			y, ok = parse_f32(parts[2])
			if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to float, 2st coord"}

			z, ok = parse_f32(parts[3])
			if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to float, 3st coord"}

			p = Vertex{x, y, z}

		case "vt":
			// TODO
			continue
		case "vn":
			// TODO
			continue
		case "f":
			if len(parts) < 4 do return nil, Parse_Error{line = i + 1, msg = "face stmt must have at least 3 points"}
			points := make([dynamic]FacePoint, 0, len(parts) - 1)
			// TODO trim all stuff

			for &raw_point in parts[1:] {
				raw_point = strings.trim(raw_point, " ")
				point_parts := strings.split(raw_point, "/", context.temp_allocator)

				if len(point_parts) != 3 do return nil, Parse_Error{line = i + 1, msg = "currently supported only full (3-field) face point info"}

				v_idx, vt_idx, vn_idx: int
				ok: bool

				v_idx, ok = parse_int(point_parts[0])
				if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to int"}

				vt_idx, ok = parse_int(point_parts[1])
				if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to int"}

				vn_idx, ok = parse_int(point_parts[2])
				if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to int"}

				append(&points, FacePoint{v_idx, vt_idx, vn_idx})
			}

			p = Face(points[:])

		case:
			continue
		}

		append(&stmts, p)
		log.debug(p)
	}

	return stmts[:], nil
}

form_data :: proc(props: []Statement) -> Data {
	vs := make([dynamic]Vertex)
	objects := make([dynamic]Object)

	active_object: Object
	is_active_object := false

	for prop in props {
		switch p in prop {
		case ObjectDecl:
			if is_active_object {
				append(&objects, active_object)
			}

			active_object = Object {
				name  = string(p),
				faces = make([dynamic]Face),
			}
		case Vertex:
			append(&vs, p)
		case VertexNormal:
			piss()
		case VertexTexture:
			piss()
		case Face:
			append(&active_object.faces, p)
		case Smoothing:
			piss()
		}
	}

	return Data{vs = vs[:], objects = objects[:]}
}

data_free :: proc(data: Data) {
	delete(data.vs)
	delete(data.vts)
	delete(data.vns)
	delete(data.objects)
	for obj in data.objects {
		delete(obj.name) // WARN: maybe we will delete the name
		delete(obj.faces)
	}
}

data_to_meshs :: proc(data: Data) -> []mesh.Mesh {
	meshs := make([dynamic]mesh.Mesh, 0, len(data.objects))

	for object in data.objects {
		msh := mesh.Mesh {
			name = object.name,
		}

		mesh_faces := make([dynamic]mesh.Face, 0, len(object.faces))

		for face in object.faces {
			if len(face) != 3 {
				shit("watch you n-gones dumbass (i don't care if it's 4 or 2 or 0)")
			}

			mesh_face: mesh.Face
			for point, i in face {
				v_idx := point[0] - 1 // because .obj uses 1-based indexing (hello tj)
				mesh_face.vs[i] = mesh.Vector3(data.vs[v_idx])

				// vt_idx := point[1] - 1
				// mesh_face.vts[i] = data.vts[vt_idx]

				// vn_idx := point[2] - 1
				// mesh_face.vns[i] = data.vns[vn_idx]
			}

			append(&mesh_faces, mesh_face)
		}

		msh.faces = mesh_faces[:]
		append(&meshs, msh)
	}

	return meshs[:]
}

shit :: proc(msg := "this feature is not supported") {
	final_msg := fmt.aprint("shit: %s", msg)
	panic(final_msg)
}

piss :: proc(msg := "this feature is not supported") {
	fmt.printf("shit: %s", msg)
}
