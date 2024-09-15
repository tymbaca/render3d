package mesh

Vector3 :: [3]f32
Vector2 :: [2]f32

Vertex :: Vector3

Face :: struct {
	vs: [3]Vertex,
	n:  Vector3,
}

Mesh :: struct {
	name: string,
	fs:   []Face,
}
