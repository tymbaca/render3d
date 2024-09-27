package mesh

import "../geo"

Face :: struct {
	vs:  [3]geo.Vector3,
	vts: [3]geo.Vector3,
	vns: [3]geo.Vector3,
}

Mesh :: struct {
	name:  string,
	faces: []Face,
}
