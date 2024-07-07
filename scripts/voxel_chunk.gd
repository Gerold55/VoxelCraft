# scripts/voxel_chunk.gd

extends MeshInstance3D

const CHUNK_SIZE = 16
const VOXEL_SIZE = 1.0

enum VoxelType {
	AIR,
	DIRT
}

var voxels = []
@onready var voxel_material = preload("res://materials/voxel_material.tres")

var voxel_uvs = {
	VoxelType.DIRT: [
		Vector2(0, 0), Vector2(1/4, 0),
		Vector2(0, 1/4), Vector2(1/4, 1/4)
	]
}

func _ready():
	voxels.resize(CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE)
	for i in range(voxels.size()):
		voxels[i] = VoxelType.AIR
	generate_flat_terrain()
	update_mesh()

func generate_flat_terrain():
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE / 2):
			for z in range(CHUNK_SIZE):
				set_voxel(x, y, z, VoxelType.DIRT)

func set_voxel(x, y, z, type):
	if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_SIZE and z >= 0 and z < CHUNK_SIZE:
		voxels[x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE] = type

func get_voxel(x, y, z):
	if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_SIZE and z >= 0 and z < CHUNK_SIZE:
		return voxels[x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE]
	return VoxelType.AIR

func update_mesh():
	var mesh = ArrayMesh.new()
	var vertices = []
	var normals = []
	var indices = []
	var uvs = []

	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				if get_voxel(x, y, z) != VoxelType.AIR:
					_add_voxel_mesh(vertices, normals, indices, uvs, x, y, z, get_voxel(x, y, z))

	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_NORMAL] = normals
	arrays[ArrayMesh.ARRAY_INDEX] = indices
	arrays[ArrayMesh.ARRAY_TEX_UV] = uvs

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, voxel_material)

	self.mesh = mesh

func _add_voxel_mesh(vertices, normals, indices, uvs, x, y, z, voxel_type):
	var base_index = vertices.size()
	var half_size = VOXEL_SIZE / 2.0

	var face_directions = [
		Vector3(1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(0, 1, 0),
		Vector3(0, -1, 0),
		Vector3(0, 0, 1),
		Vector3(0, 0, -1)
	]

	var face_normals = [
		Vector3(1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(0, 1, 0),
		Vector3(0, -1, 0),
		Vector3(0, 0, 1),
		Vector3(0, 0, -1)
	]

	for i in range(6):
		var direction = face_directions[i]
		var normal = face_normals[i]

		for j in range(4):
			var corner = Vector3(
				(j & 1) * direction.x + half_size * (1 - 2 * (j & 1)),
				((j >> 1) & 1) * direction.y + half_size * (1 - 2 * ((j >> 1) & 1)),
				(1 - (j & 1) * direction.z) + half_size * (1 - 2 * ((j >> 1) & 1))
			)
			vertices.append(Vector3(x, y, z) + corner * VOXEL_SIZE)
			normals.append(normal)
			uvs.append(voxel_uvs[voxel_type][j])

		indices.append(base_index + 0)
		indices.append(base_index + 1)
		indices.append(base_index + 2)
		indices.append(base_index + 0)
		indices.append(base_index + 2)
		indices.append(base_index + 3)
		base_index += 4
