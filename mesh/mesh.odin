package mesh

Vector3 :: [3]f32
Vector2 :: [2]f32

Face :: struct {
	vs:  [3]Vector3,
	vts: [3]Vector3,
	vns: [3]Vector3,
}

Mesh :: struct {
	name:  string,
	faces: []Face,
}
