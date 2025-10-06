class_name CharacterAnimator
extends Node2D

enum Hair
{
    None,
    Short,
    Long,
    Shaved,
    Mohawk,
    Ponytail
}

enum FacialHair
{
    None,
    ShortBeard,
    LongBeard,
    Mustache
}

enum EyeExpression
{
    Neutral,
    Bored,
    Sad,
    Angry,
    Shocked
}

enum MouthExpression
{
    Neutral,
    Happy,
    Sad
}

enum Shirt
{
    Short,
    Long
}

#Animations
 #Body
var _animation_head = preload("res://animations/character_head.tres")
var _animation_arms = preload("res://animations/character_arms.tres")
var _animation_shirt_short = preload("res://animations/character_short_shirt.tres")
var _animation_shirt_long = preload("res://animations/character_long_shirt.tres")
var _animation_pants = preload("res://animations/character_pants.tres")
var _animation_shoes = preload("res://animations/character_shoes.tres")
var _animation_armor_pieces = preload("res://animations/character_armor_pieces.tres")
 #Hair
var _animation_hair_short = preload("res://animations/character_hair_short.tres")
var _animation_hair_long = preload("res://animations/character_hair_long.tres")
var _animation_hair_shaved = preload("res://animations/character_hair_shaved.tres")
var _animation_hair_mohawk = preload("res://animations/character_hair_mohawk.tres")
var _animation_hair_ponytail = preload("res://animations/character_hair_ponytail.tres")
 #Facial Hair
var _animation_short_beard = preload("res://animations/character_short_beard.tres")
var _animation_long_beard = preload("res://animations/character_long_beard.tres")
var _animation_mustache = preload("res://animations/character_mustache.tres")
#Eyes
var _animation_eyes_neutral = preload("res://animations/character_eyes_normal.tres")
var _animation_eyes_sad = preload("res://animations/character_eyes_sad.tres")
var _animation_eyes_bored = preload("res://animations/character_eyes_bored.tres")
var _animation_eyes_angry = preload("res://animations/character_eyes_angry.tres")
var _animation_eyes_shocked = preload("res://animations/character_eyes_shocked.tres")
#Iris
var _animation_iris_neutral = preload("res://animations/character_iris_normal.tres")
var _animation_iris_bored = preload("res://animations/character_iris_bored.tres")
#Mouth
var _animation_expression_neutral = preload("res://animations/character_expression_normal.tres")
var _animation_expression_sad = preload("res://animations/character_expression_sad.tres")
var _animation_expression_happy = preload("res://animations/character_expression_smiling.tres")

#Animators
@onready var _head_animator: AnimatedSprite2D = $HeadAnimator
@onready var _eyes_animator: AnimatedSprite2D = $EyesAnimator
@onready var _iris_animator: AnimatedSprite2D = $IrisAnimator
@onready var _mouth_animator: AnimatedSprite2D = $MouthAnimator
@onready var _hair_animator: AnimatedSprite2D = $HairAnimator
@onready var _pants_animator: AnimatedSprite2D = $PantsAnimator
@onready var _shirt_animator: AnimatedSprite2D = $ShirtAnimator
@onready var _arms_animator: AnimatedSprite2D = $ArmsAnimator
@onready var _armor_animator: AnimatedSprite2D = $ArmorPiecesAnimator
@onready var _facial_hair_animator: AnimatedSprite2D = $FacialHairAnimator
@onready var _shoes_animator: AnimatedSprite2D = $ShoesAnimator

var _all_animators: Array[AnimatedSprite2D]

func _ready() -> void:
    _all_animators = [
        _head_animator, 
        _eyes_animator, 
        _iris_animator,
        _mouth_animator,
        _hair_animator,
        _pants_animator,
        _shirt_animator,
        _arms_animator,
        _armor_animator,
        _facial_hair_animator,
        _shoes_animator
        ]
    
    #Defaults
    _head_animator.sprite_frames = _animation_head
    _eyes_animator.sprite_frames = _animation_eyes_neutral
    _iris_animator.sprite_frames = _animation_iris_neutral
    _mouth_animator.sprite_frames = _animation_expression_neutral
    _hair_animator.sprite_frames = _animation_hair_short
    _pants_animator.sprite_frames = _animation_pants
    _shirt_animator.sprite_frames = _animation_shirt_short
    _arms_animator.sprite_frames = _animation_arms
    _armor_animator.sprite_frames = _animation_armor_pieces
    _facial_hair_animator.sprite_frames = _animation_short_beard
    _shoes_animator.sprite_frames = _animation_shoes
    
    CharacterPresets.set_random_character(self)
    self.play_walk_animation()
    
func reset():
    for animator in _all_animators:
        animator.stop()
        animator.frame = 0
    
    _set_animation("idle1")
    
func _set_animation(animation: String):
    for animator in _all_animators:
        animator.animation = animation

func play_idle1_animation():
    reset()
    _set_animation("idle1")
    for animator in _all_animators:
        animator.play()
                
func play_idle2_animation():
    reset()
    _set_animation("idle2")
    for animator in _all_animators:
        animator.play()
        
func play_idle3_animation():
    reset()
    _set_animation("idle3")
    for animator in _all_animators:
        animator.play()
        
func play_idle4_animation():
    reset()
    _set_animation("idle4")
    for animator in _all_animators:
        animator.play()
        
func play_walk_animation():
    reset()
    _set_animation("walk")
    for animator in _all_animators:
        animator.play()
        
func stop_animating():
    for animator in _all_animators:
        animator.pause()

func set_hair(hair: Hair):
    match hair:
        Hair.None:
            _hair_animator.visible = false
        Hair.Short:
            _hair_animator.visible = true
            _hair_animator.sprite_frames = _animation_hair_short
        Hair.Long:
            _hair_animator.visible = true
            _hair_animator.sprite_frames = _animation_hair_long
        Hair.Shaved:
            _hair_animator.visible = true
            _hair_animator.sprite_frames = _animation_hair_shaved
        Hair.Mohawk:
            _hair_animator.visible = true
            _hair_animator.sprite_frames = _animation_hair_mohawk
        Hair.Ponytail:
            _hair_animator.visible = true
            _hair_animator.sprite_frames = _animation_hair_ponytail
            
func set_facial_hair(facial_hair: FacialHair):
    match facial_hair:
        FacialHair.None:
            _facial_hair_animator.visible = false
        FacialHair.ShortBeard:
            _facial_hair_animator.visible = true
            _facial_hair_animator.sprite_frames = _animation_short_beard
        FacialHair.LongBeard:
            _facial_hair_animator.visible = true
            _facial_hair_animator.sprite_frames = _animation_long_beard
        FacialHair.Mustache:
            _facial_hair_animator.visible = true
            _facial_hair_animator.sprite_frames = _animation_mustache
    
func set_eye_expression(eye_expression: EyeExpression):
    match eye_expression:
        EyeExpression.Neutral:
            _eyes_animator.sprite_frames = _animation_eyes_neutral
            _iris_animator.sprite_frames = _animation_iris_neutral
        EyeExpression.Bored:
            _eyes_animator.sprite_frames = _animation_eyes_bored
            _iris_animator.sprite_frames = _animation_iris_bored
        EyeExpression.Sad:
            _eyes_animator.sprite_frames = _animation_eyes_sad
            _iris_animator.sprite_frames = _animation_iris_neutral
        EyeExpression.Angry:
            _eyes_animator.sprite_frames = _animation_eyes_angry
            _iris_animator.sprite_frames = _animation_iris_neutral
        EyeExpression.Shocked:
            _eyes_animator.sprite_frames = _animation_eyes_shocked
            _iris_animator.sprite_frames = _animation_iris_neutral
    
func set_mouth_expression(mouth_expression: MouthExpression):
    _mouth_animator.visible = true
    match mouth_expression:
        MouthExpression.Neutral:
            _mouth_animator.sprite_frames = _animation_expression_neutral
        MouthExpression.Happy:
            _mouth_animator.sprite_frames = _animation_expression_happy
        MouthExpression.Sad:
            _mouth_animator.sprite_frames = _animation_expression_sad
    
func set_shirt(shirt: Shirt):
    _shirt_animator.visible = true
    match shirt:
        Shirt.Short:
            self.move_child(_shirt_animator, 6)
            _shirt_animator.sprite_frames = _animation_shirt_short
        Shirt.Long:
            self.move_child(_shirt_animator, 7)
            _shirt_animator.sprite_frames = _animation_shirt_long

func enable_armor():
    _armor_animator.visible = true
    
func disable_armor():
    _armor_animator.visible = false
    
#Color Functions
func set_skin_color(color: Color):
    _head_animator.self_modulate = color
    _mouth_animator.self_modulate = color
    _arms_animator.self_modulate = color
    
func set_hair_color(color: Color):
    _hair_animator.self_modulate = color
    _facial_hair_animator.self_modulate = color
    
func set_eye_color(color: Color):
    _iris_animator.self_modulate = color
    
func set_shirt_color(color: Color):
    _shirt_animator.self_modulate = color

func set_pants_color(color: Color):
    _pants_animator.self_modulate = color
    
func set_shoes_color(color: Color):
    _shoes_animator.self_modulate = color
    
