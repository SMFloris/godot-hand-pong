extends Node2D

var socket = WebSocketPeer.new()

var time_accumulator = 0.0
var FRAME_RATE = Engine.get_frames_per_second()
var FRAME_TIME = 1.0 / FRAME_RATE  # 0.0333s per frame

@onready var hand_landmark_scene: PackedScene = preload("res://hand_landmarks.tscn")

@export var num_hands: int = 2
var hand_landmarks = []
var childrenAreReady = false
var windowSize = DisplayServer.window_get_size()

var frame_counter = 0
const FRAME_INTERVAL = 2

func _ready():
	socket.connect_to_url("ws://localhost:8765")
	for ih in num_hands:
		hand_landmarks.append(hand_landmark_scene.instantiate())
		add_child(hand_landmarks[ih])

func move_player(playerNo, averagePositionOfLandmarks):
	if playerNo == 1:
		$"%Player1".position.y = averagePositionOfLandmarks.y
	else:
		$"%Player2".position.y = averagePositionOfLandmarks.y

func powerup_player(playerNo, gesture):
	if gesture.category != "Closed_Fist":
		return
	if playerNo == 1:
		$"%Player1".powerup(1)
	else:
		$"%Player2".powerup(-1)

func _process(delta):
	time_accumulator += delta
	
	if not childrenAreReady:
		var allAreReady = true
		for ih in num_hands:
			if not hand_landmarks[ih].is_node_ready():
				allAreReady = false
		if not allAreReady:
			return
		else:
			childrenAreReady = true

	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var pkt := socket.get_packet()
			if socket.was_string_packet():
				var data = JSON.parse_string(pkt.get_string_from_utf8())
				# print(data, data.has("hand_landmarks"),hand_landmarks and hand_landmarks.is_node_ready())

				var leftIdx = -1
				var rightIdx = -1
				if data and data.has("handedness") and childrenAreReady:
					var idx = 0
					for handed in data["handedness"]:
						if handed[0].hand == "Left":
							leftIdx = idx;
						else:
							rightIdx = idx
						idx += 1

				if leftIdx and rightIdx:
					leftIdx = 0
					rightIdx = 1
				
				if data and data.has("hand_landmarks") and childrenAreReady:
					var idx = 0
					for hand_landmark in data["hand_landmarks"]:
						var new_landmarks = []
						for lm in hand_landmark:
							new_landmarks.append(Vector2(lm["x"] * windowSize.x, lm["y"] * windowSize.y)) # Scale to screen
						if leftIdx == idx:
							hand_landmarks[0].update_landmarks(new_landmarks)
							move_player(0, hand_landmarks[0].average_position())
						else:
							hand_landmarks[1].update_landmarks(new_landmarks)
							move_player(1, hand_landmarks[1].average_position())
						idx += 1
				#if data and data.has("gestures") and childrenAreReady:
					#var idx = 0
					#for gesture in data["gestures"]:
						#if leftIdx == idx:
							#powerup_player(0, gesture[0])
						#elif rightIdx == idx:
							#powerup_player(1, gesture[0])
						#idx += 1
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.
