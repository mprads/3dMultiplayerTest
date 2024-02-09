extends Node

@onready var main_menu: PanelContainer = $CanvasLayer/MainMenu
@onready var host_button: Button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/HostButton
@onready var local_host_button: Button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/LocalHostButton
@onready var join_button: Button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/JoinButton
@onready var address_entry: LineEdit = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud: Control = $CanvasLayer/HUD
@onready var health_bar: ProgressBar = $CanvasLayer/HUD/HealthBar
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

const PORT := 9999
const PLAYER := preload("res://scenes/characters/player.tscn")
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed.bind(false))
	local_host_button.pressed.connect(_on_host_button_pressed.bind(true))
	join_button.pressed.connect(_on_join_button_pressed)
	multiplayer_spawner.spawned.connect(_on_multiplayer_spawned)


func _add_player(peer_id) -> void:
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)

	if player.is_multiplayer_authority():
		player.health_changed.connect(_on_player_health_changed)


func _on_host_button_pressed(local: bool) -> void:
	main_menu.hide()
	hud.show()

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)

	_add_player(multiplayer.get_unique_id())

	if !local:
		udnp_setup()


func _on_join_button_pressed() -> void:
	main_menu.hide()
	hud.show()
	var address = "localhost"
	if address_entry.text:
		address = address_entry.text
	print(address)

	enet_peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = enet_peer


func _on_multiplayer_spawned(player: Node) -> void:
	if player.is_multiplayer_authority():
		player.health_changed.connect(_on_player_health_changed)


func _on_player_health_changed(health_value: int) -> void:
	health_bar.value = health_value


func _remove_player(peer_id: int) -> void:
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()


func udnp_setup() -> void:
	var upnp = UPNP.new()
	var discover_result = upnp.discover()

	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover Failed Error %s" % discover_result)

	assert(upnp.get_gateway() && upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed Error %s" % map_result)

	print("Success address: %s" % upnp.query_external_address())
