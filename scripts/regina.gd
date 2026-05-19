extends CharacterBase
class_name Player

@onready var hearts_container: HBoxContainer = %HeartsContainer

@export_group("Movimento")
@export var SPEED := 350.0
@export var ACCELERATION := 1500.0
@export var FRICTION := 1200.0
@export var JUMP_VELOCITY := -400.0

@export_group("Dash")
@export var DASH_SPEED_H := 1000.0
@export var DASH_SPEED_V := 500.0
@export var DASH_DURATION := 0.2
@export var DASH_COOLDOWN := 0.4

var is_dashing := false
var can_dash := true
var dash_cooldown_timer := 0.0

func _ready() -> void:
    base_sprite = $AnimatedSprite2D
    
    if base_sprite and base_sprite.has_method("play"):
        base_sprite.play("regina-idle")

func _physics_process(delta: float) -> void:
    if dash_cooldown_timer > 0.0:
        dash_cooldown_timer -= delta
    
    super(delta)

    if is_on_floor():
        can_dash = true

    if not is_dashing:
        apply_gravity(delta)
        handle_jump()
        handle_movement(delta)
        handle_dash_input()
        
    else:
        check_dash_attack()
    
    move_and_slide()

func check_dash_attack() -> void:
    for i in range(get_slide_collision_count()):
        var collision = get_slide_collision(i)
        var object = collision.get_collider()
        
        if object is BaseEnemy:
            object.take_damage(1)
            
            dash_cooldown_timer = 0.0
            is_dashing = false
            can_dash = true
            
            velocity.y = JUMP_VELOCITY
            break

func handle_jump() -> void:
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

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

func start_dash() -> void:
    var input_vec := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var is_flipped = base_sprite.flip_h if base_sprite else false
    var default_dir = Vector2.LEFT if is_flipped else Vector2.RIGHT
    var dash_dir : Vector2 = input_vec.normalized() if input_vec != Vector2.ZERO else default_dir
    
    is_dashing = true
    can_dash = false
    
    velocity = Vector2(dash_dir.x * DASH_SPEED_H, dash_dir.y * DASH_SPEED_V)
    
    await get_tree().create_timer(DASH_DURATION).timeout
    
    if is_dashing:
        is_dashing = false
        velocity = dash_dir * SPEED
        dash_cooldown_timer = DASH_COOLDOWN


func _on_damage_taken() -> void:
    update_hearts_ui()
    print("Regina herdada tomou dano! Vida atual: ", current_health)

func die() -> void:
    print("Regina foi derrotada! Reiniciando fase...")
    get_tree().reload_current_scene()

func update_hearts_ui() -> void:
    if hearts_container == null: return
    
    var hearts = hearts_container.get_children()
    
    for i in range(hearts.size()):
        if hearts[i].has_node("AnimatedSprite2D"):
            var sprite_heart = hearts[i].get_node("AnimatedSprite2D") as AnimatedSprite2D
            
            hearts[i].visible = true
            
            if i < current_health:
                if sprite_heart.animation != "full":
                    sprite_heart.animation = "full"
                    sprite_heart.play()
            else:
                if sprite_heart.animation != "empty":
                    sprite_heart.animation = "empty"
                    sprite_heart.play()
