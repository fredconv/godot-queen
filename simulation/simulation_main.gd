extends Node
## Scène d'entrée du simulateur (charge les autoloads du projet).


const DEFAULT_COUNT: int = 1000
const DEFAULT_START_SEED: int = 1
const DEFAULT_CSV_PATH: String = "simulation/results/last_run.csv"
const DEFAULT_JSON_PATH: String = "simulation/results/last_summary.json"


func _ready() -> void:
	var args := _parse_args(OS.get_cmdline_user_args())
	var count: int = int(args.get("count", DEFAULT_COUNT))
	var start_seed: int = int(args.get("seed", DEFAULT_START_SEED))
	var csv_path: String = str(args.get("csv", DEFAULT_CSV_PATH))
	var json_path: String = str(args.get("json", DEFAULT_JSON_PATH))

	var simulator := MatchSimulator.new()
	var results: Array[Dictionary] = []
	results.resize(count)

	for index in range(count):
		results[index] = simulator.play_match(start_seed + index)

	var stats := BatchStats.new()
	var summary: Dictionary = stats.summarize(results)
	print(stats.format_report(summary))

	_write_csv(csv_path, results)
	_write_summary_json(json_path, summary)
	print("\nCSV  : %s" % csv_path)
	print("JSON : %s" % json_path)

	get_tree().quit()


static func _parse_args(user_args: PackedStringArray) -> Dictionary:
	var parsed: Dictionary = {}
	var index := 0
	while index < user_args.size():
		var token: String = user_args[index]
		if token == "--count" and index + 1 < user_args.size():
			parsed["count"] = user_args[index + 1].to_int()
			index += 2
			continue
		if token == "--seed" and index + 1 < user_args.size():
			parsed["seed"] = user_args[index + 1].to_int()
			index += 2
			continue
		if token == "--csv" and index + 1 < user_args.size():
			parsed["csv"] = user_args[index + 1]
			index += 2
			continue
		if token == "--json" and index + 1 < user_args.size():
			parsed["json"] = user_args[index + 1]
			index += 2
			continue
		index += 1
	return parsed


static func _write_summary_json(path: String, summary: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Impossible d'écrire %s" % path)
		return
	file.store_string(JSON.stringify(summary, "\t"))
	file.close()


static func _write_csv(path: String, results: Array[Dictionary]) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Impossible d'écrire %s" % path)
		return
	file.store_line("seed,winner,hand_count,score_0,score_1,score_2,score_3,completed")
	for result: Dictionary in results:
		var scores: Array = result.get("final_scores", [0, 0, 0, 0])
		file.store_line(
			"%d,%d,%d,%d,%d,%d,%d,%s" % [
				int(result.get("seed", 0)),
				int(result.get("winner_index", -1)),
				int(result.get("hand_count", 0)),
				int(scores[0]),
				int(scores[1]),
				int(scores[2]),
				int(scores[3]),
				str(result.get("match_completed", false)).to_lower(),
			]
		)
	file.close()
