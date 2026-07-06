class_name TranslationCoverageTest
extends GdUnitTestSuite


const CSV_PATHS: Array[String] = [
	"res://translations/common.csv",
	"res://translations/menu.csv",
	"res://translations/table.csv",
	"res://translations/dialogs.csv",
	"res://translations/game.csv",
]

const SAMPLE_KEYS: Array[String] = [
	MenuKeys.TITLE,
	TableKeys.TURN_YOUR_PLAY,
	DialogKeys.HAND_END_TITLE,
	CommonKeys.BACK,
	GameKeys.SUIT_HEARTS,
]


#region csv
func test_each_csv_row_has_all_locale_columns() -> void:
	for csv_path in CSV_PATHS:
		var rows: PackedStringArray = FileAccess.get_file_as_string(csv_path).split("\n")
		for row_index in range(1, rows.size()):
			var row: String = rows[row_index].strip_edges()
			if row.is_empty():
				continue
			var columns: PackedStringArray = _parse_csv_row(row)
			assert_int(columns.size()).append_failure_message(csv_path).is_greater_equal(7)
			for column_index in range(1, 7):
				var cell: String = columns[column_index]
				if columns[0] == "CM_WINNER_PAD":
					continue
				assert_str(cell.strip_edges()).append_failure_message(
					"%s row %d col %d" % [csv_path, row_index + 1, column_index + 1]
				).is_not_empty()
#endregion


#region runtime
func test_sample_keys_translate_in_every_locale() -> void:
	for locale in LocaleCatalog.LOCALES:
		TranslationServer.set_locale(locale)
		for key in SAMPLE_KEYS:
			var translated: String = TranslationServer.translate(key)
			assert_str(translated).append_failure_message("%s @ %s" % [key, locale]).is_not_equal(key)
#endregion


static func _parse_csv_row(row: String) -> PackedStringArray:
	var columns: PackedStringArray = PackedStringArray()
	var current: String = ""
	var in_quotes: bool = false
	for i in row.length():
		var character: String = row[i]
		if character == "\"":
			in_quotes = not in_quotes
			continue
		if character == "," and not in_quotes:
			columns.append(current)
			current = ""
			continue
		current += character
	columns.append(current)
	return columns
