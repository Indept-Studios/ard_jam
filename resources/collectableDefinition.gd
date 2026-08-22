class_name CollectableDefinition extends Resource

enum EffectType {
	SPEED,
	EXPLOSION,
	INVULNERABLE,
	SPIRIT_TARGET
}

@export var texture: Texture2D
@export var effect_type: EffectType
@export var radius: float = 0.0
@export var duration: float = 0.0
@export var strength: float = 1.0
@export var color: Color = Color.WHITE
