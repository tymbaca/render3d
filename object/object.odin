package object

import "../geo"
import "../mesh"
import rl "vendor:raylib"

Object :: struct {
	mesh:     mesh.Mesh,
	position: geo.Vector3,
	rotation: quaternion128,
	render:   proc(o: Object),
}

RenderType :: enum {
	RAYLIB,
}

new :: proc(mesh: mesh.Mesh, position := geo.Vector3{}, type := RenderType.RAYLIB) -> Object {
	o := Object {
		mesh     = mesh,
		position = position,
	}

	switch type {
	case .RAYLIB:
		o.render = render_rl
	}

	o->render()

	return o
}

render_rl :: proc(o: Object) {
	for face in o.mesh.faces {
		color := normal_to_color(face.vns[0])
		t1 := apply_transform(face.vs[0], o)
		t2 := apply_transform(face.vs[1], o)
		t3 := apply_transform(face.vs[2], o)

		rl.DrawTriangle3D(t1, t2, t3, color)
	}
}

apply_transform :: proc(v: geo.Vector3, o: Object) -> geo.Vector3 {
	v := v
	//v = apply_rotation(v, o.rotation)
	v = rl.Vector3RotateByAxisAngle(v, {0, 0, 1}, 1)
	v = apply_position(v, o.position)

	return v
}

rotate :: proc(o: ^Object, x, y, z: f32) {
	o.rotation += quaternion128(rl.QuaternionFromEuler(z, y, x))
}

apply_position :: proc(v: geo.Vector3, p: geo.Vector3) -> geo.Vector3 {
	return v + p
}

apply_rotation :: proc(v: geo.Vector3, r: quaternion128) -> geo.Vector3 {
	return rl.Vector3RotateByQuaternion(v, rl.Quaternion(r))
}

normal_to_color :: proc(n: geo.Vector3) -> rl.Color {
	return {lerp_normal_to_byte(n.r), lerp_normal_to_byte(n.g), lerp_normal_to_byte(n.b), 255}
}

lerp_normal_to_byte :: proc(n: f32) -> u8 {
	return u8(rl.Lerp(0, 255, n))
}
