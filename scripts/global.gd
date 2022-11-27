extends Node

signal instance_player(id)
signal toggle_network_setup(toogle)

func instance_node_at (node: Object, parent: Object, location: Vector3):
	var instance_node = instance_node(node, parent)
	instance_node.global_position = location
	return instance_node

func instance_node(node: Object, parent: Object):
	var node_instance = node.instance()
	parent.add_child(node_instance) 
	return node_instance
