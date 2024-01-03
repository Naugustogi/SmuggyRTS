class_name BaseUnit

extends Node

@export var attack = 0
@export var hp = 100
@export var cost = 100
@export var ms = 1
@export var range = 75
var selectMesh: MeshInstance3D

func select():
	var material = selectMesh.get_active_material(0)
	material.set_albedo(Color("33e700"))

func unselect():
	var material = selectMesh.get_active_material(0)
	material.set_albedo(Color("33e70000"))
# Called when the node enters the scene tree for the first time.
func _ready():
	selectMesh = load("res://units/select.tscn").instantiate()
	add_child(selectMesh)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
