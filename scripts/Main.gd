extends Spatial

var player = preload("res://scenes/XBAlphaTest.tscn")

func _ready():
	get_tree().connect("network_peer_connected", self , "_player_connected")
	get_tree().connect("network_peer_disconnected", self , "_player_disconnected")
	Global.connect("instance_player", self , "_instance_player")
	rpc_config("_instance_player",MultiplayerAPI.RPC_MODE_REMOTE)

	if get_tree().network_peer != null:
		Global.emit_signal("toggle_network_setup",false)

remote func _instance_player(id):
	if get_tree().is_network_server():
		for p in Network.players:
			rpc_id(id,"_instance_player",p)
	Network.players[id] = id;
	var player_instance = player.instance()
	player_instance.set_network_master(id)
	player_instance.name = str(id)
	$Players.add_child(player_instance)
	player_instance.global_transform.origin = Vector3(0,15,0)

func _player_connected(id):
	print("Player" + str(get_tree().get_network_unique_id()) + "connected")
	print(get_tree().get_network_unique_id())
	rpc("_instance_player",get_tree().get_network_unique_id())
	

