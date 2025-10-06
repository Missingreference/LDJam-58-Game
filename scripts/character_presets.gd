class_name CharacterPresets

static var skin_colors = [
    # Light Tones
    Color("fff0e2"), # Very Fair (Cool)
    Color("ffd9b3"), # Fair (Warm)
    Color("f9d6b9"), # Fair (Neutral)
    Color("ffca93"), # Light (Warm)
    Color("f2b887"), # Light (Peachy)
    # Medium Tones
    Color("e3a16e"), # Tan (Warm)
    Color("d8996e"), # Olive
    Color("c7855b"), # Dark Tan (Warm)
    Color("b37b56"), # Mid-Brown (Neutral)
    # Dark Tones
    Color("a0694e"), # Mid-Brown (Warm)
    Color("8c5a45"), # Dark (Neutral)
    Color("613d2f"), # Dark (Cool)
    Color("4a2d25")  # Very Dark
]

# A wide mix of natural and fantasy hair colors.
static var hair_colors = [
    # Blondes & Whites
    Color("d1d1d1"), # Light Grey
    Color("b9c2c7"), # Silver
    Color("848d94"), # Steel Grey
    # Blondes
    Color("ffe899"), # Platinum Blonde
    Color("f4d166"), # Golden Blonde
    Color("d1b48c"), # Ash Blonde
    Color("d9a066"), # Dirty Blonde
    # Browns
    Color("b0744a"), # Light Brown
    Color("865a3c"), # Medium Brown
    Color("6e5a4b"), # Ash Brown
    Color("59382f"), # Dark Brown
    # Reds
    Color("d1804c"), # Strawberry Blonde
    Color("d1624c"), # Ginger
    Color("ae4c34"), # Auburn
    # Blacks
    Color("322522"), # Off-Black
    Color("1e1e1e"), # Black
    # Uncommon / Dyed (Muted)
    Color("6b3b3b"), # Deep Maroon
    Color("4a546b"), # Slate Blue
    Color("4a6356")  # Dark Teal
]

# Common, uncommon, and fantasy eye colors.
static var eye_colors = [
    Color("a0afb5"), # Steel Blue
    Color("5482b4"), # Blue
    Color("429363"), # Green
    Color("9d9f59"), # Hazel
    Color("b0744a"), # Amber
    Color("744f3a"), # Brown
    Color("4a2d25"), # Dark Brown
    Color("322522"), # Almost Black
    Color("848d94"), # Grey
]

# A large wardrobe of colors for shirts, jackets, and tops.
static var shirt_colors = [
    # --- Whites, Beiges & Greys (Homespun, Undyed, Worn) ---
    Color("fefefb"), # Bleached Linen
    Color("e0d6c0"), # Cream / Undyed Wool
    Color("c8c2b8"), # Light Stone Grey
    Color("a8a29a"), # Mid Grey / Worn Cloth
    Color("848d94"), # Slate Grey
    Color("6b6b6b"), # Charcoal
    Color("444444"), # Dark Slate
    # --- Browns (Earth, Leather, Faded) ---
    Color("bda871"), # Tan / Light Hide
    Color("a08a6f"), # Faded Brown
    Color("9d7f63"), # Undyed Leather
    Color("8c5a45"), # Russet Brown
    Color("744f3a"), # Earth Brown
    # --- Muted Natural Dyes ---
    #Color("b55a4c"), # Terracotta / Madder Red
    #Color("a24545"), # Faded Crimson / Maroon
    #Color("d1804c"), # Ochre / Weld Yellow
    Color("9d9f59"), # Olive / Lichen Green
    Color("5a6e5a"), # Moss Green
    Color("3e7d44"), # Forest Green
    Color("63778a"), # Washed Blue / Woad
    #Color("4a689d"), # Indigo / Denim
    Color("5d4a6b"),  # Heather / Muted Purple
    # Neutrals
    Color("a0694e"), # Brown
    Color("848d94"), # Light Grey
    Color("555555"), # Charcoal
    Color("222222")  # Black
]

# A versatile set of colors for pants, shorts, and skirts.
static var pants_colors = [
    Color("e0d6c0"), # Cream / Light Khaki
    Color("bda871"), # Tan / Khaki
    Color("9d9f59"), # Olive Drab
    Color("8c5a45"), # Medium Brown
    Color("5a4332"), # Dark Brown
    Color("4a546b"), # Dark Slate
    Color("6b6b6b"), # Charcoal Grey
    Color("444444"), # Dark Grey
    Color("333333"), # Off-Black
    Color("1e1e1e"),  # Black
    # --- Greys & Blacks ---
    Color("a8a29a"), # Light Grey Wool
    Color("848d94"), # Slate Grey
    Color("6b6b6b"), # Charcoal
    Color("444444"), # Dark Slate
    Color("333333"), # Off-Black
    Color("1e1e1e"), # Black
    # --- Browns & Tans ---
    Color("e0d6c0"), # Light Khaki / Canvas
    Color("bda871"), # Tan
    Color("a08a6f"), # Faded Brown
    Color("8c5a45"), # Sturdy Brown
    Color("744f3a"), # Earth Brown
    Color("5a4332"), # Dark Earth
    Color("4a2d25"), # Very Dark Brown
    # --- Other Muted Tones ---
    Color("9d9f59"), # Olive Drab
    Color("4a689d"), # Dark Denim / Indigo
    Color("3e7d44")  # Forest Green
]

# A good range of colors for shoes, boots, and footwear.
static var shoe_colors = [
    Color("9d7f63"), # Light Leather
    Color("b0744a"), # Tan Suede
    Color("865a3c"), # Medium Brown
    Color("6b4a3a"), # Brown Leather
    Color("5a382f"), # Dark Leather
    Color("4a2d25"), # Dark Leather
    Color("555555"), # Grey
    Color("222222"), # Black
    Color("333333"), # Worn Black
    Color("5a4332"), # Oiled Leather
]

static func set_random_character(character_animator: CharacterAnimator):
    set_random_skin_color(character_animator)
    set_random_hair_color(character_animator)
    set_random_eye_color(character_animator)
    set_random_shirt_color(character_animator)
    set_random_pants_color(character_animator)
    set_random_shoe_color(character_animator)
    
    var enable_armor = Globals.rng.randi_range(0, 2) == 0
    if enable_armor:
        character_animator.enable_armor()
    else:
        character_animator.disable_armor()
    
    var safe_combination = false
    while !safe_combination:
        var eye_expression: CharacterAnimator.EyeExpression = RandomUtils.pick_random_enum(CharacterAnimator.EyeExpression)
        var facial_hair: CharacterAnimator.FacialHair = RandomUtils.pick_random_enum(CharacterAnimator.FacialHair)
        var hair: CharacterAnimator.Hair = RandomUtils.pick_random_enum(CharacterAnimator.Hair)
        var mouth_expression: CharacterAnimator.MouthExpression = RandomUtils.pick_random_enum(CharacterAnimator.MouthExpression)
        var shirt: CharacterAnimator.Shirt = RandomUtils.pick_random_enum(CharacterAnimator.Shirt)
        
        safe_combination = true
        
        #Check for ugly looking combination
        if facial_hair == CharacterAnimator.FacialHair.Mustache && hair == CharacterAnimator.Hair.Ponytail:
            safe_combination = false
        if facial_hair == CharacterAnimator.FacialHair.Mustache && hair == CharacterAnimator.Hair.Long:
            safe_combination = false
        
        if safe_combination:
            character_animator.set_eye_expression(eye_expression)
            character_animator.set_facial_hair(facial_hair)
            character_animator.set_hair(hair)
            character_animator.set_mouth_expression(mouth_expression)
            character_animator.set_shirt(shirt)
        

static func set_random_skin_color(character_animator: CharacterAnimator):
    character_animator.set_skin_color(RandomUtils.pick_random(skin_colors))

static func set_random_hair_color(character_animator: CharacterAnimator):
    character_animator.set_hair_color(RandomUtils.pick_random(hair_colors))

static func set_random_eye_color(character_animator: CharacterAnimator):
    character_animator.set_eye_color(RandomUtils.pick_random(eye_colors))
    
static func set_random_shirt_color(character_animator: CharacterAnimator):
    character_animator.set_shirt_color(RandomUtils.pick_random(shirt_colors))
    
static func set_random_pants_color(character_animator: CharacterAnimator):
    character_animator.set_pants_color(RandomUtils.pick_random(pants_colors))

static func set_random_shoe_color(character_animator: CharacterAnimator):
    character_animator.set_shoes_color(RandomUtils.pick_random(shoe_colors))
