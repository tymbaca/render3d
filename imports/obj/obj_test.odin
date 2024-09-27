package obj

import "../../mesh"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:reflect"
import "core:strings"
import "core:testing"

@(test, private)
test_parse_mesh :: proc(t: ^testing.T) {
	context.logger = log.create_console_logger(.Debug)
	defer free_all()

	input := `
o Plane
v -1.000000 0.000000 1.000000
v 1.000000 0.000000 1.000000
v -1.000000 0.000000 -1.000000
v 1.000000 0.000000 -1.000000

vn -0.0000 1.0000 -0.0000
vt 0.000000 0.000000
vt 1.000000 0.000000
vt 1.000000 1.000000
vt 0.000000 1.000000
s 0

f 1/1/1 2/2/1 4/3/1 # 3/4/1
` // need comment support

	want := []mesh.Mesh {
		{
			name = "Plane",
			faces = []mesh.Face {
				{
					vs = [3]mesh.Vector3{{-1, 0, 1}, {1, 0, 1}, {1, 0, -1}},
					vts = [3]mesh.Vector3{{0, 0, 0}, {1, 0, 0}, {1, 1, 0}},
					vns = [3]mesh.Vector3{{0, 1, 0}, {0, 1, 0}, {0, 1, 0}},
				},
			},
		},
	}

	got, err := parse_meshes(strings.split_lines(input))
	log.debug(got)

	log.info("got:", got)
	log.info("want:", want)
	assert(reflect.equal(got, want))
}

@(test, private)
test_parse_stmts :: proc(t: ^testing.T) {
	//context.logger = log.create_console_logger(.Debug)
	defer free_all()

	input := `
o Plane
v -1.000000 0.000000 1.000000
v 1.000000 0.000000 1.000000
v -1.000000 0.000000 -1.000000
v 1.000000 0.000000 -1.000000

vn -0.0000 1.0000 -0.0000
vt 0.000000 0.000000
vt 1.000000 0.000000
vt 1.000000 1.000000
vt 0.000000 1.000000
s 0

f 1/1/1 2/2/1 4/3/1 3/4/1
`
	want := []Statement {
		/*
		ObjectDecl("Plane"),
		Vertex{-1, 0, 1},
		Vertex{1, 0, 1},
		Vertex{-1, 0, -1},
		Vertex{1, 0, -1},
		VertexNormal{0, 1, 0},
		VertexTexture{0, 0},
		VertexTexture{1, 0},
		VertexTexture{1, 1},
		VertexTexture{0, 1},
		Smoothing(false),
        */
		Face{{1, 1, 1}, {2, 2, 1}, {4, 3, 1}, {3, 4, 1}},
	}
	got := []Statement {
		/*
		ObjectDecl("Plane"),
		Vertex{-1, 0, 1},
		Vertex{1, 0, 1},
		Vertex{-1, 0, -1},
		Vertex{1, 0, -1},
		VertexNormal{0, 1, 0},
		VertexTexture{0, 0},
		VertexTexture{1, 0},
		VertexTexture{1, 1},
		VertexTexture{0, 1},
		Smoothing(false),
        */
		Face{{1, 1, 1}, {2, 2, 1}, {4, 3, 1}, {3, 4, 1}},
	}

	// Call
	// got, err := parse_stmts(strings.split_lines(input))
	// if err != nil {
	// 	testing.fail_now(t, "error during parse")
	// }

	//testing.expect(t, err == nil, "error")
	testing.expect(t, len(got) == len(want), "diff len")
	testing.expect(t, reflect.equal(got, want), "diff content")
	for _, i in got {
		if !reflect.equal(got[i], want[i]) {
			testing.errorf(t, "expected %v, got %v", got[i], want[i])
		}
	}
}
