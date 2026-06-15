extends CharacterBase
class_name Player

@onready var dash_sword: Node2D = $DashSword
@onready var jump_indicator: Node2D = $JumpIndicator
@onready var dash_attack_shape: CollisionShape2D = $DashSword/DashAttackArea/CollisionShape2D

@export_group("Movimento")
@export var BASE_SPEED := 120.0
@export var MAX_FALL_SPEED := 500.0
@export var ACCELERATION := 3000
@export var FRICTION := 3000
@export var JUMP_VELOCITY := -315.0
@export var JUMP_CUT_MULTIPLIER := 0.566

@export_group("Dash")
@export var TILE_SIZE := 16.0
@export var DASH_TILES := 4.0
@export var DASH_SPEED := 1500.0
@export var DASH_COOLDOWN := 0.35
@export var DASH_EXIT_MOMENTUM := 200.0
@export var SWORD_OFFSET_X := 0.0
@export var SWORD_OFFSET_Y := 0.0
@export var SWORD_FADE_TIME := 0.2

@export_group("Superfícies")
@export var ICE_SPEED := 150.0
@export var ICE_ACCELERATION := 350.0
@export var ICE_FRICTION := 80.0
@export var SURFACE_CHECK_Y := 10.0
@export var SURFACE_CHECK_HALF_WIDTH := 5.0
@export var ICE_EXIT_GRACE := 0.10
@export var ICE_DASH_EXIT_MOMENTUM := 100.0

@export var WEB_SPEED := 55.0
@export var WEB_ACCELERATION := 900.0
@export var WEB_FRICTION := 2500.0

@export_group("Perigos")
@export var SPIKE_DAMAGE := 1
@export var SPIKE_DAMAGE_COOLDOWN := 0.6

@export_group("Morte")
@export var DEATH_FADE_TIME := 0.3

var is_dead := false
var spike_damage_timer := 0.0
var ice_momentum_active := false
var ice_exit_timer := 0.0
var was_on_floor_last_frame := false
var jump_available := true
var is_dashing := false
var can_dash := true
var dash_cooldown_timer := 0.0
var dash_used_since_ground := false

var dash_momentum_active := false
var dash_direction := Vector2.ZERO
var dash_remaining_distance := 0.0
var sword_tween: Tween

func _ready() -> void:
	base_sprite = $AnimatedSprite2D
	
	if base_sprite and base_sprite.has_method("play"):
		base_sprite.play("regina-idle")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		die()
		return
		
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	if spike_damage_timer > 0.0:
		spike_damage_timer -= delta
	
	super(delta)

	var was_on_floor_before_move := is_on_floor()

	if is_dashing:
		update_dash(delta)
	else:
		apply_gravity(delta)
		handle_jump()
		handle_jump_cut()
		limit_fall_speed()
		handle_movement(delta)
		handle_dash_input()
		move_and_slide()
		check_enemy_contact()

	check_tile_effects()
	update_ice_momentum_state(delta)
	was_on_floor_last_frame = is_on_floor()
	update_ground_recharge(was_on_floor_before_move)
	update_jump_indicator()

func check_tile_effects() -> void:
	if has_tile_flag("death") or has_tile_flag("spikes"):
		die()
		return

@export var TILE_CHECK_OFFSET := Vector2(0, 9)

func take_damage(amount: int) -> void:
	if is_dashing:
		return
	
	die()

func is_on_ice() -> bool:
	return is_on_floor() and has_surface_flag("ice")

func is_on_web() -> bool:
	return is_on_floor() and has_surface_flag("web")

func get_tile_data(custom_data_name: StringName) -> Variant:
	var tilemaps := get_tree().get_nodes_in_group("TileMaps")
	tilemaps.reverse()
	
	for tilemap in tilemaps:
		if not tilemap is TileMapLayer:
			continue
		
		var ret = _get_tile_data_from_tilemap(custom_data_name, tilemap)
		
		if ret != null:
			return ret

	return null

func _get_tile_data_from_tilemap(custom_data_name: StringName, tilemap: TileMapLayer) -> Variant:
	var check_pos := global_position + TILE_CHECK_OFFSET
	var cell: Vector2i = tilemap.local_to_map(tilemap.to_local(check_pos))
	var data: TileData = tilemap.get_cell_tile_data(cell)
	
	if data:
		return data.get_custom_data(custom_data_name)
	
	return null

func has_tile_flag(custom_data_name: StringName) -> bool:
	return has_tile_flag_at_offset(custom_data_name, TILE_CHECK_OFFSET)

func has_tile_flag_at_offset(custom_data_name: StringName, offset: Vector2) -> bool:
	var tilemaps := get_tree().get_nodes_in_group("TileMaps")
	tilemaps.reverse()
	
	for node in tilemaps:
		if not node is TileMapLayer:
			continue
		
		var tilemap := node as TileMapLayer
		
		if tilemap.tile_set == null:
			continue
		
		if tilemap.tile_set.get_custom_data_layer_by_name(custom_data_name) == -1:
			continue
		
		var check_pos: Vector2 = global_position + offset
		var cell: Vector2i = tilemap.local_to_map(tilemap.to_local(check_pos))
		var data: TileData = tilemap.get_cell_tile_data(cell)
		
		if data and data.get_custom_data(custom_data_name) == true:
			return true
	
	return false

func has_surface_flag(custom_data_name: StringName) -> bool:
	var offsets: Array[Vector2] = [
		Vector2(0, SURFACE_CHECK_Y),
		Vector2(-SURFACE_CHECK_HALF_WIDTH, SURFACE_CHECK_Y),
		Vector2(SURFACE_CHECK_HALF_WIDTH, SURFACE_CHECK_Y)
	]
	
	for offset in offsets:
		if has_tile_flag_at_offset(custom_data_name, offset):
			return true
	
	return false

func update_ground_recharge(was_on_floor_before_move: bool) -> void:
	var grounded := is_on_floor()

	if grounded:
		can_dash = true
		jump_available = true

		if not was_on_floor_before_move:
			dash_used_since_ground = false

		if dash_momentum_active:
			stop_dash_momentum()
	else:
		if was_on_floor_before_move and dash_used_since_ground:
			can_dash = false

func update_jump_indicator() -> void:
	if jump_indicator == null:
		return
	
	jump_indicator.visible = jump_available and not is_on_floor()

func show_dash_sword() -> void:
	if dash_sword == null:
		return
	
	if sword_tween:
		sword_tween.kill()
	
	var direction_sign := 1
	
	if dash_direction.x < 0:
		direction_sign = -1
	
	dash_sword.visible = true
	dash_sword.modulate.a = 1.0
	dash_sword.position = Vector2(SWORD_OFFSET_X * direction_sign, SWORD_OFFSET_Y)
	dash_sword.scale.x = direction_sign
	
	if dash_attack_shape:
		dash_attack_shape.set_deferred("disabled", false)

func hide_dash_sword() -> void:
	if dash_sword == null:
		return
	
	if sword_tween:
		sword_tween.kill()
		
	if dash_attack_shape:
		dash_attack_shape.set_deferred("disabled", true)
	
	sword_tween = create_tween()
	sword_tween.tween_property(dash_sword, "modulate:a", 0.0, SWORD_FADE_TIME)
	sword_tween.tween_callback(func():
		dash_sword.visible = false
		dash_sword.modulate.a = 1.0
	)
	
func _on_dash_attack_area_body_entered(body: Node2D) -> void:
	if not is_dashing:
		return
		
	if body is BaseEnemy:		
		body.take_damage(1)
		
		is_dashing = false
		can_dash = true
		jump_available = true
		dash_used_since_ground = false
		dash_remaining_distance = 0.0
		hide_dash_sword()
		
		velocity.x = 0
		velocity.y = JUMP_VELOCITY
		
		move_and_slide()

func update_dash(delta: float) -> void:
	var step := DASH_SPEED * delta
	
	if step > dash_remaining_distance:
		step = dash_remaining_distance
	
	velocity = dash_direction * (step / delta)
	move_and_slide()
	
	check_dash_attack()
	
	if not is_dashing:
		return
	
	dash_remaining_distance -= step
	
	if dash_remaining_distance <= 0.0:
		end_dash()

func end_dash() -> void:
	is_dashing = false
	dash_remaining_distance = 0.0
	hide_dash_sword()
	
	if is_on_ice():
		velocity.x = dash_direction.x * ICE_DASH_EXIT_MOMENTUM
		velocity.y = 0
		ice_momentum_active = true
		ice_exit_timer = ICE_EXIT_GRACE
		dash_momentum_active = false
	elif not is_on_floor():
		velocity.x = dash_direction.x * DASH_EXIT_MOMENTUM
		velocity.y = 0
		dash_momentum_active = true
	else:
		var direction := Input.get_axis("ui_left", "ui_right")
		velocity.x = direction * BASE_SPEED
		velocity.y = 0
		dash_momentum_active = false

func stop_dash_momentum() -> void:
	dash_momentum_active = false
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = direction * BASE_SPEED
	else:
		velocity.x = 0

func check_enemy_contact() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var object := collision.get_collider()
		
		if object == null:
			continue
		
		if object is BaseEnemy:
			if is_dashing:
				object.take_damage(1)
				
				is_dashing = false
				can_dash = true
				jump_available = true
				dash_used_since_ground = false
				dash_remaining_distance = 0.0
				hide_dash_sword()
				
				velocity.y = JUMP_VELOCITY
				return
			else:
				die()
				return

func check_dash_attack() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var object = collision.get_collider()
		
		if object == null:
			continue
		
		print("Dash colidiu com: ", object.name, " | É BaseEnemy? ", object is BaseEnemy)
		
		if object is BaseEnemy:
			if is_dashing:
				object.take_damage(1)
				
				is_dashing = false
				can_dash = true
				jump_available = true
				dash_used_since_ground = false
				dash_remaining_distance = 0.0
				hide_dash_sword()
				
				velocity.y = JUMP_VELOCITY
				break
			else:
				die()
				break

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and jump_available:
		velocity.y = JUMP_VELOCITY
		jump_available = false

func handle_jump_cut() -> void:
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

func limit_fall_speed() -> void:
	velocity.y = min(velocity.y, MAX_FALL_SPEED)

func update_ice_momentum_state(delta: float) -> void:
	if is_on_ice():
		ice_momentum_active = true
		ice_exit_timer = ICE_EXIT_GRACE
		return
	
	if not is_on_floor():
		return
	
	var just_landed := not was_on_floor_last_frame and is_on_floor()
	
	if just_landed:
		ice_momentum_active = false
		ice_exit_timer = 0.0
		return
	
	if ice_momentum_active:
		ice_exit_timer -= delta
		
		if ice_exit_timer <= 0.0:
			ice_momentum_active = false

func handle_movement(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0 and base_sprite:
		base_sprite.flip_h = direction < 0
	elif base_sprite:
		base_sprite.play("regina-idle")

	var current_speed := BASE_SPEED
	var accel_rate := ACCELERATION if direction != 0 else FRICTION
	
	if is_on_web():
		current_speed = WEB_SPEED
		accel_rate = WEB_ACCELERATION if direction != 0 else WEB_FRICTION
	elif ice_momentum_active or is_on_ice():
		current_speed = ICE_SPEED
		accel_rate = ICE_ACCELERATION if direction != 0 else ICE_FRICTION

	var target_vel := direction * current_speed
		
	velocity.x = move_toward(velocity.x, target_vel, accel_rate * delta)

func handle_dash_input() -> void:
	var ready_cooldown = (dash_cooldown_timer <= 0.0)
	if Input.is_action_just_pressed("dash") and can_dash and ready_cooldown:
		start_dash()

func recharge_dash() -> void:
	can_dash = true

func start_dash() -> void:
	var input_vec := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var is_flipped = base_sprite.flip_h if base_sprite else false
	var default_dir = Vector2.LEFT if is_flipped else Vector2.RIGHT
	
	dash_direction = input_vec.normalized() if input_vec != Vector2.ZERO else default_dir
	
	# Deixa o dash apenas horizontal
	dash_direction.y = 0
	
	if dash_direction.x == 0:
		dash_direction = default_dir
	
	dash_direction = dash_direction.normalized()
	
	is_dashing = true
	can_dash = false
	dash_used_since_ground = true
	dash_cooldown_timer = DASH_COOLDOWN
	
	dash_remaining_distance = TILE_SIZE * DASH_TILES
	
	velocity = Vector2.ZERO
	
	show_dash_sword()

func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	call_deferred("_reload_current_scene_with_fade")

func _reload_current_scene_with_fade() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	
	var fade := ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	canvas.add_child(fade)
	get_tree().current_scene.add_child(canvas)
	
	var tween := get_tree().create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, DEATH_FADE_TIME)
	
	await tween.finished
	
	GameManager.respawn_player()
	
	is_dead = false
	set_physics_process(true)
	
	var tween_out := get_tree().create_tween()
	tween_out.tween_property(fade, "modulate:a", 0.0, DEATH_FADE_TIME)
	
	await tween_out.finished
	canvas.queue_free()
	
