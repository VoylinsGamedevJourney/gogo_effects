class_name GoGoEffects
extends Node


signal _encoding_started
signal _encoding_flushed
signal _encoding_finished
signal _encoding_error(message: String)


@export_group("Target")
## The viewport to capture the frames from. If empty, it will capture the main viewport.
@export var viewport: SubViewport
## The path where the video will get saved to.
@export_global_file("*.mp4", "*.mkv", "*.webm") var output_path: String = "test.mp4"

@export_group("Video settings")
## The FPS of the output video.
## NOTE: During recording, the game engine will be forced to match this FPS!
@export_range(1, 240) var framerate: int = 30
@export var codec: GoGoEffectsEncoder.VIDEO_CODEC = GoGoEffectsEncoder.V_H264
## Preset only applies when using H264 encoding.
@export var preset: GoGoEffectsEncoder.H264_PRESETS = GoGoEffectsEncoder.H264_PRESET_MEDIUM
## Lower CRF gives better quality, but increases render times. Bellow 18, difference isn't noticable. 51 is worst quality.
@export_range(0, 52, 1) var crf: int = 23
## B-frames can improve the compression of a video as it looks to previous and future frames to make up the image.
@export_range(0, 60, 1) var b_frames: int = 0

@export_group("Advanced")
@export var thread_count: int = 4
@export var capture_buffer_size: int = 5


var _encoder: GoGoEffectsEncoder
var _is_encoding: bool = false
var _sending_frame_failed: bool = false
var _thread: Thread
var _mutex: Mutex
var _frame_buffer: Array[Image] = []
var _previous_max_fps: int = 0
var _previous_physics_fps: int = 0
var _active_viewport: Viewport
var _written_frames: int = 0



func _ready() -> void:
	_encoder = GoGoEffectsEncoder.new()
	_thread = Thread.new()
	_mutex = Mutex.new()


func _notification(what: int) -> void:
	# safety check: ensure recording stops if project quits.
	if what == NOTIFICATION_PREDELETE and _is_encoding:
		stop_encoding()


func _print(message: String) -> void:    print("GoGoEffects: %s." % message)
func _printerr(message: String) -> void: printerr("GoGoEffects: %s!" % message)


func _capture_loop() -> void:
	var frame_index: int = 0

	# Wait for first frame to be fully drawn.
	await RenderingServer.frame_post_draw

	while _is_encoding:
		# Capture image from GPU.
		var image: Image = _active_viewport.get_texture().get_image()

		# Add to buffer + update index.
		_frame_buffer[frame_index] = image
		frame_index = (frame_index + 1) % capture_buffer_size
		_written_frames += 1

		# Check if buffer full or ready.
		if frame_index == 0:
			if _thread.is_started():
				await _thread.wait_to_finish()
			_thread.start(_flush_buffer_to_encoder.bind(_frame_buffer.duplicate()))

		# Check for possible error during frame sending.
		if _sending_frame_failed:
			if _thread.is_started():
				await _thread.wait_to_finish()

			stop_encoding()

		# Wait for next frame.
		await RenderingServer.frame_post_draw

	# Final flush.
	if _thread.is_started():
		await _thread.wait_to_finish()

	# Send whatever is left.
	if frame_index > 0:
		var remaining_frames: Array[Image] = _frame_buffer.slice(0, frame_index)

		_flush_buffer_to_encoder(remaining_frames)

	await RenderingServer.frame_post_draw
	_encoding_flushed.emit()


func _flush_buffer_to_encoder(frames: Array[Image]) -> void:
	for image: Image in frames:
		if image == null: continue

		var success: bool = _encoder.send_frame(image)
		if not success:
			_printerr("Error sending frame to FFmpeg")
			_mutex.lock()
			_sending_frame_failed = true
			_mutex.unlock()
			return


func start_encoding() -> void:
	if _is_encoding:
		_printerr("Already recording")
		return

	# Figure out viewport.
	_active_viewport = viewport if viewport else get_viewport()

	if not _active_viewport:
		_encoding_error.emit("No valid viewport found")
		return

	if _active_viewport.size.x % 2 == 1 or _active_viewport.size.y % 2 == 1:
		_printerr("Viewport size causes issues, make certain that both length and height can be divided by 2")
		return

	# Setup encoder.
	_encoder.set_file_path(ProjectSettings.globalize_path(output_path))
	_encoder.set_video_codec_id(codec)
	_encoder.set_framerate(float(framerate))
	_encoder.set_resolution(_active_viewport.size)
	_encoder.set_crf(crf)
	_encoder.set_h264_preset(preset)
	_encoder.set_threads(thread_count)
	_encoder.set_b_frames(b_frames)
	_encoder.enable_debug()

	# Open encoder.
	if not _encoder.open(_active_viewport.get_texture().get_image().get_format() == Image.FORMAT_RGBA8):
		_encoding_error.emit("Failed to open encoder")
		return

	# Sync engine time.
	_previous_max_fps = Engine.max_fps
	_previous_physics_fps = Engine.physics_ticks_per_second

	Engine.max_fps = framerate
	Engine.physics_ticks_per_second = framerate

	_is_encoding = true
	_sending_frame_failed = false
	_written_frames = 0

	_frame_buffer.clear()
	_frame_buffer.resize(capture_buffer_size)
	_frame_buffer.fill(null)

	_encoding_started.emit()

	# Start the capture loop.
	_capture_loop()


func stop_encoding() -> void:
	print_stack()
	if not _is_encoding:
		return

	# Wait for the thread to finish flushing.
	_is_encoding = false
	await _encoding_flushed

	# Restore engine settings.
	Engine.max_fps = _previous_max_fps
	Engine.physics_ticks_per_second = _previous_physics_fps

	# Closing encoder and finishing video
	_encoder.close()
	_encoding_finished.emit()

	_print("Recording saved to %s" % output_path)
	_print("Frames written: %s" % _written_frames)
	_print("Video duration %s" % (_written_frames / framerate))
