extends Node2D

var landmarks = []  # Stores received landmark positions
var connections = [  # MediaPipe hand connections
	[0, 1], [1, 2], [2, 3], [3, 4],  # Thumb
	[0, 5], [5, 6], [6, 7], [7, 8],  # Index
	[0, 9], [9, 10], [10, 11], [11, 12],  # Middle
	[0, 13], [13, 14], [14, 15], [15, 16],  # Ring
	[0, 17], [17, 18], [18, 19], [19, 20],  # Pinky
	[5, 9], [9, 13], [13, 17],  # Palm
]

func _ready():
	print("HandLandmarks.gd is running.")

func update_landmarks(new_landmarks):
	""" Update landmark positions with received data """
	landmarks = new_landmarks
	queue_redraw()  # Request a redraw

func average_position():
	var average = Vector2(0, 0)
	for l in landmarks:
		average += l
	return average / len(landmarks)

func _draw():
	""" Draw hand landmarks and connections """
	if landmarks.size() != 21:
		return  # Ensure we have all 21 landmarks

	# Draw connections
	for conn in connections:
		var start = landmarks[conn[0]]
		var end = landmarks[conn[1]]
		draw_line(start, end, Color(1, 1, 1), 2)

	# Draw landmarks as circles
	for i in range(landmarks.size()):
		draw_circle(landmarks[i], 5, Color(1, 0, 0))
