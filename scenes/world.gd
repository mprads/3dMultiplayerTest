extends Node

@onready var main_menu: PanelContainer = $CanvasLayer/MainMenu
@onready var host_button: Button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/HostButton
@onready var join_button: Button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/JoinButton
@onready var address_entry: LineEdit = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry

const PORT := 9999
const PLAYER := preload("res://scenes/characters/player.tscn")
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)


func _add_player(peer_id) -> void:
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)


func _on_host_button_pressed() -> void:
	main_menu.hide()

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(_add_player)

	_add_player(multiplayer.get_unique_id())

func _on_join_button_pressed() -> void:
	main_menu.hide()

	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
