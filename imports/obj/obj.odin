package obj


import "../../mesh"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"
import "core:strings"

@(private)
Data :: struct {
	vs:      []Vertex,
	vns:     []VertexNormal,
	vts:     []VertexTexture,
	objects: []Object,
}

@(private)
Object :: struct {
	name:      string,
	smoothing: Smoothing,
	faces:     [dynamic]Face,
}

@(private)
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

@(private)
ObjectDecl :: distinct string

@(private)
Vertex :: distinct mesh.Vector3

@(private)
VertexNormal :: distinct mesh.Vector3

@(private)
VertexTexture :: distinct mesh.Vector2

@(private)
Smoothing :: distinct bool

@(private)
Face :: distinct []FacePoint

@(private)
FacePoint :: [3]int

parse_meshes :: proc(lines: []string) -> ([]mesh.Mesh, Error) {
	stmts, err := parse_stmts(lines)
	defer delete(stmts)
	if err != nil do return nil, err

	data := form_data(stmts)

	return data_to_meshs(data), nil
}

@(private)
parse_stmts :: proc(lines: []string, alloc := context.allocator) -> ([]Statement, Error) {
	context.allocator = alloc
	defer free_all(context.temp_allocator)

	stmts := make([dynamic]Statement)

	for line, i in lines {
		if len(line) == 0 do continue

		parts := strings.split(line, " ", context.temp_allocator)
		if len(parts) < 2 do return nil, Parse_Error{line = i + 1, msg = "too little parts in statement"}

		p: Statement

		argsCount := len(parts) - 1
		switch parts[0] {
		case "o":
			if argsCount != 1 do return nil, Parse_Error{line = i + 1, msg = "object stmt must have 2 parts"}

			p = ObjectDecl(strings.clone(parts[1]))

		case "v":
			if argsCount != 3 do return nil, Parse_Error{line = i + 1, msg = "vertex stmt must have 3 coords"}

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
			if argsCount != 2 do return nil, Parse_Error{line = i + 1, msg = "vertex texture stmt must have 2 coords (i don't yet support 3)"}
			x, y: f32
			ok: bool

			x, ok = parse_f32(parts[1])
			if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to float, 1st coord"}

			y, ok = parse_f32(parts[2])
			if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to float, 2st coord"}

			p = VertexTexture{x, y}
		case "vn":
			if argsCount != 3 do return nil, Parse_Error{line = i + 1, msg = "vertex normal stmt must have 3 coords"}
			x, y, z: f32
			ok: bool

			x, ok = parse_f32(parts[1])
			if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to float, 1st coord"}

			y, ok = parse_f32(parts[2])
			if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to float, 2st coord"}

			z, ok = parse_f32(parts[3])
			if !ok do return nil, Parse_Error{line = i + 1, msg = "can't parse to float, 3st coord"}

			p = VertexNormal{x, y, z}
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

		//case "s":

		case:
			continue
		}

		append(&stmts, p)
		log.debug(p)
	}

	return stmts[:], nil
}

@(private)
form_data :: proc(props: []Statement) -> Data {
	vs := make([dynamic]Vertex)
	vts := make([dynamic]VertexTexture)
	vns := make([dynamic]VertexNormal)
	objects := make([dynamic]Object)

	is_active_object := false

	for prop in props {
		switch v in prop {
		case ObjectDecl:
			is_active_object = true
			append(&objects, Object{name = string(v), faces = make([dynamic]Face)})
		case Vertex:
			append(&vs, v)
		case VertexTexture:
			append(&vts, v)
		case VertexNormal:
			append(&vns, v)
		case Face:
			if is_active_object {
				append(&objects[len(objects) - 1].faces, v) // add to last object faces
			}
		case Smoothing:
			if is_active_object {
				objects[len(objects) - 1].smoothing = v
			}
		}
	}

	return Data{vs = vs[:], objects = objects[:]}
}

@(private)
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

@(private)
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

@(private)
shit :: proc(msg := "this feature is not supported") {
	final_msg := fmt.aprint("shit: %s", msg)
	panic(final_msg)
}

@(private)
piss :: proc(msg := "this feature is not supported") {
	fmt.printf("shit: %s", msg)
}
