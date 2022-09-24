
extends Spatial

var rng = RandomNumberGenerator.new()

#to be used by the diamond square algorithm, array height and width must be 2^n+1
var size = 128
var mapsize = size + 1

var map = []
var width #map dimensions
var height

var chunk = size
var roughness #scope of randval
var half
var randval #random value to be added to average position

# jitter is the amount that roughness changes between recursions.
# Best values are between 2 (very rough terrain) and 3 (gently rolling hills).
var jitter = 2.5

#arrays for MeshArray generation
var vertices = PoolVector3Array()
var UVs = PoolVector2Array()
var normals = PoolVector3Array()

onready var player = $Player
onready var egocam = $Player/Egocam
onready var camera = $Camera

var playerstart = Vector3(0,0,0) #player starting position
var camerastart = Vector3(0,0,0)

func _ready():
	
	rng.randomize()
	
	width = size
	height = size
	
func _input(event):
	
	if event.is_action_pressed("ui_focus_next"): #press Tab to toggle between cameras
		if egocam.is_current():
			camera.make_current()
		else:
			egocam.make_current()

	if event.is_action_pressed("ui_select"): #press SPACE to generate islands
		
		camerastart = Vector3(size/2, size/2+size/8, size/4)
		camera.set_translation(camerastart)
		
		diamond_square()
		
		make_terrain()
		
		#player is moved to the center of the map
		playerstart = Vector3(size/2, map[size/2][-size/2]+10, -size/2)
		player.set_translation(playerstart)


func make_terrain():
	#arrays need to be emptied. clear() does not work for some reason.
	vertices.resize(0)
	UVs.resize(0)
	normals.resize(0)
	
	#previously generated terrain is removed
	get_tree().call_group("terrains", "queue_free")
	
	for x in width-1:
		for y in height-1:
			create_quad(x,y)

	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(load("res://terrain_material.tres"))
	
	for v in vertices.size(): #vertex color for different elevations
		var heightcolor
		var sandheight = 3
		var grassheight = 17
		var rockheight = 25
		var sand = Color(0.96,0.92,0.47)
		var rock = Color(0.62,0.69,0.50)
		var grass = Color(0.13,0.69,0.02)
		var snow = Color(0.95,0.95,0.95)
		
		if vertices[v].y <= sandheight:
			heightcolor = sand
		elif vertices[v].y > sandheight && vertices[v].y <= grassheight:
			heightcolor = grass
		elif vertices[v].y > grassheight && vertices[v].y <= rockheight:
			heightcolor = rock
		else:
			heightcolor = snow
		st.add_color(heightcolor)
		st.add_normal(Vector3(0,1,0))
		st.add_uv(UVs[v])
		st.add_vertex(vertices[v])
	
	#create a new terrain MeshInstance and add it as a child
	var terrainmesh_new = MeshInstance.new()
	add_child(terrainmesh_new)
	terrainmesh_new.mesh = st.commit()
	terrainmesh_new.add_to_group("terrains") #this group is cleared before new terrain is generated
	terrainmesh_new.create_trimesh_collision()
	#uncomment the following line if you want to save the terrain as a scene
	#var _newterrain = ResourceSaver.save("res://newterrain.tres", terrainmesh_new.mesh, ResourceSaver.FLAG_COMPRESS)


func create_quad(x,y):
	
	var vert1 # vertex positions (Vector2)
	var vert2
	var vert3
	
	var side1 # sides of each triangle (Vector3)
	var side2
	
	var normal # normal for each triangle (Vector3)
	
	# triangle 1
	vert1 = Vector3(x,map[x][y],-y)
	vert2 = Vector3(x,map[x][y+1],-y-1)
	vert3 = Vector3(x+1,map[x+1][y+1],-y-1)
	vertices.push_back(vert1)
	vertices.push_back(vert2)
	vertices.push_back(vert3)
	
	UVs.push_back(Vector2(vert1.x/10, -vert1.z/10))
	UVs.push_back(Vector2(vert2.x/10, -vert2.z/10))
	UVs.push_back(Vector2(vert3.x/10, -vert3.z/10))
	
	side1 = vert2-vert1
	side2 = vert2-vert3
	normal = side1.cross(side2)
	
	for i in 3:
		normals.push_back(normal)
	
	# triangle 2
	vert1 = Vector3(x,map[x][y],-y)
	vert2 = Vector3(x+1,map[x+1][y+1],-y-1)
	vert3 = Vector3(x+1,map[x+1][y],-y)
	vertices.push_back(vert1)
	vertices.push_back(vert2)
	vertices.push_back(vert3)
	
	UVs.push_back(Vector2(vert1.x/10, -vert1.z/10))
	UVs.push_back(Vector2(vert2.x/10, -vert2.z/10))
	UVs.push_back(Vector2(vert3.x/10, -vert3.z/10))
	
	side1 = vert2-vert1
	side2 = vert2-vert3
	normal = side1.cross(side2)
	
	for i in 3:
		normals.push_back(normal)


func diamond_square():
	
	map.clear()
	chunk = size
	roughness = size/jitter
	
	for y in mapsize: #initialize and fill the array with zeroes
		map.append([])
		for x in mapsize:
			map[y].append(0)

#uncomment the following 4 lines if you want to create basic terrain. For islands you need to keep corners and edges at 0 (or whatever your waterlevel is)
#	map[0][0] = rng.randf_range(-roughness,roughness)
#	map[0][size] = rng.randf_range(-roughness,roughness)
#	map[size][0] = rng.randf_range(-roughness,roughness)
#	map[size][size] = rng.randf_range(-roughness,roughness)
		
	while chunk > 1:
		half = chunk/2
		square_step()
		diamond_step()
		chunk /= 2
		roughness /= jitter


func square_step():
	for y in range(0, size, chunk):
		for x in range(0, size, chunk):
			randval = rng.randf_range(-roughness,roughness)
			map[y+half][x+half]=float((map[y][x]+map[y][x+chunk]+map[y+chunk][x]+map[y+chunk][x+chunk])/4 + randval)


func diamond_step():
	for y in range(0, mapsize, half):
		for x in range((y+half)%chunk, mapsize, chunk):
			randval = rng.randf_range(-roughness,roughness)
			#edge cases are only relevant in the diamond step.
			#for island creation edge values are set to 0. Uncomment to create regular terrain.
			if x == 0: 
				map[y][x] = 0
				#map[y][x] = float((map[y-half][x] + map[y][x+half] + map[y+half][x])/3 + randval)
			elif x == size:
				map[y][x] = 0
				#map[y][x] = float((map[y-half][x] + map[y][x-half] + map[y+half][x])/3 + randval)
			elif y == 0:
				map[y][x] = 0
				#map[y][x] = float((map[y+half][x] + map[y][x-half] + map[y][x+half])/3 + randval)
			elif y == size:
				map[y][x] = 0
				#map[y][x] = float((map[y-half][x] + map[y][x-half] + map[y][x+half])/3 + randval)
			else:
				map[y][x] = float((map[y-half][x] + map[y][x-half] + map[y][x+half] + map[y+half][x])/4 + randval)
