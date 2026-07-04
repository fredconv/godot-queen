extends Control
## CornerBrackets
## Surbrillance générique à 4 crochets de coin (style pixel art), réutilisée
## pour la sélection de carte (`CardView`) et le tour actif (`PlayerSeat`).
## Purement visuel : ne contient aucune règle de jeu. La couleur et les
## dimensions des crochets sont exposées pour permettre de légères variations
## entre les deux usages sans dupliquer le script.

@export var bracket_color: Color = Color("#4FC3F7")
@export var bracket_length: float = 14.0
@export var bracket_thickness: float = 3.0

func _ready() -> void:
	resized.connect(queue_redraw)

func _draw() -> void:
	_draw_corner(Vector2.ZERO, Vector2(1.0, 1.0))
	_draw_corner(Vector2(size.x, 0.0), Vector2(-1.0, 1.0))
	_draw_corner(Vector2(0.0, size.y), Vector2(1.0, -1.0))
	_draw_corner(Vector2(size.x, size.y), Vector2(-1.0, -1.0))

## Dessine un crochet en "L" à partir du coin donné, orienté vers l'intérieur
## du rectangle selon `direction` (chaque composante vaut +1 ou -1).
func _draw_corner(corner: Vector2, direction: Vector2) -> void:
	var horizontal_end: Vector2 = corner + Vector2(bracket_length * direction.x, 0.0)
	var vertical_end: Vector2 = corner + Vector2(0.0, bracket_length * direction.y)
	draw_line(corner, horizontal_end, bracket_color, bracket_thickness)
	draw_line(corner, vertical_end, bracket_color, bracket_thickness)
