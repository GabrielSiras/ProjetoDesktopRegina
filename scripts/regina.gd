extends CharacterBase
class_name Player

@onready var tile_map_layer: TileMapLayer =$"../Floor/Web"
@onready var dash_sword: Node2D = $DashSword
@onready var jump_indicator: Node2D = $JumpIndicator

@export_group("Movimento")
@export var SPEED := 120.0
@export var ACCELERATION := 3000.0 
@export var FRICTION := 3000.0
@export var JUMP_VELOCITY := -315.0
@export var JUMP_CUT_MULTIPLIER := 0.566

@export_group("Dash")
@export var TILE_SIZE := 16.0
@export var DASH_TILES := 5.0
@export var DASH_SPEED := 1500.0
@export var DASH_COOLDOWN := 0.35
@export var DASH_EXIT_MOMENTUM := 200.0
@export var SWORD_OFFSET_X := 0.0
@export var SWORD_OFFSET_Y := 0.0
@export var SWORD_FADE_TIME := 0.2

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
		get_tree().reload_current_scene()
		return
		
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	super(delta)

	var was_on_floor_before_move := is_on_floor()

	if is_dashing:
		update_dash(delta)
	else:
		apply_gravity(delta)
		handle_jump()
		handle_jump_cut()
		handle_movement(delta)
		handle_dash_input()
		move_and_slide()

	update_ground_recharge(was_on_floor_before_move)
	update_jump_indicator()
	
	if get_tile_data("speed_modifier") == 0.4 && SPEED != 48:
		SPEED *= get_tile_data("speed_modifier")
	elif get_tile_data("speed_modifier") == null:
		SPEED = 120
		
	if(get_tile_data("death") != null):
		die()

# Varia velocidade de acordo com a tile que o player está pisando (WIP)
func get_tile_data(custom_data_name: StringName) -> Variant:
	var tilemaps: = get_tree().get_nodes_in_group("TileMaps")
	tilemaps.reverse()
	
	for tilemap in tilemaps:
		var ret = _get_tile_data_from_tilemap(custom_data_name, tilemap)
		if ret!= null:
			return ret

	return null

func _get_tile_data_from_tilemap(custom_data_name: StringName, tilemap: TileMapLayer) -> Variant:
	var cell: Vector2i = tilemap.local_to_map(position+Vector2(0,9))
	var data: TileData = tilemap.get_cell_tile_data(cell)
	if data:
		var tile_data = data.get_custom_data(custom_data_name)
		return tile_data
	
	return null


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

func hide_dash_sword() -> void:
	if dash_sword == null:
		return
	
	if sword_tween:
		sword_tween.kill()
	
	sword_tween = create_tween()
	sword_tween.tween_property(dash_sword, "modulate:a", 0.0, SWORD_FADE_TIME)
	sword_tween.tween_callback(func():
		dash_sword.visible = false
		dash_sword.modulate.a = 1.0
	)

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
	
	if not is_on_floor():
		velocity.x = dash_direction.x * DASH_EXIT_MOMENTUM
		velocity.y = 0
		dash_momentum_active = true
	else:
		var direction := Input.get_axis("ui_left", "ui_right")
		velocity.x = direction * SPEED
		velocity.y = 0
		dash_momentum_active = false

func stop_dash_momentum() -> void:
	dash_momentum_active = false
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

func check_dash_attack() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var object = collision.get_collider()
		
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

func handle_movement(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0 and base_sprite:
		base_sprite.flip_h = direction < 0
	elif base_sprite:
		base_sprite.play("regina-idle")

	var target_vel = direction * SPEED
	var accel_rate = ACCELERATION if direction != 0 else FRICTION
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
	#await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/levels/game_over.tscn")
