extends Control
## ConfirmDialog
## Boîte de dialogue générique de confirmation (Oui/Non), utilisée pour
## confirmer une action destructrice (ex. quitter une partie en cours, voir
## `scripts/ui/table.gd`). Masquée par défaut, affichée via `open()`.
## Purement visuel : aucune règle de jeu, aucune décision métier ici.

signal confirmed
signal cancelled

@onready var _message_label: Label = $Panel/Content/MessageLabel

## Affiche la boîte de dialogue. `message` permet de personnaliser le texte ;
## laissé vide, le texte déjà défini dans la scène est conservé.
func open(message: String = "") -> void:
	if message != "":
		_message_label.text = message
	visible = true

func close() -> void:
	visible = false

func _on_btn_confirm_yes_pressed() -> void:
	close()
	confirmed.emit()

func _on_btn_confirm_no_pressed() -> void:
	close()
	cancelled.emit()
