class_name SimulationArchive
extends RefCounted
## Archive horodatée des runs de simulation + index consultable.


const RESULTS_ROOT: String = "simulation/results"
const RUNS_DIR: String = "simulation/results/runs"
const INDEX_JSON_PATH: String = "simulation/results/index.json"
const INDEX_CSV_PATH: String = "simulation/results/index.csv"
const LAST_CSV_PATH: String = "simulation/results/last_run.csv"
const LAST_JSON_PATH: String = "simulation/results/last_summary.json"
const LAST_REPORT_PATH: String = "simulation/results/last_report.txt"
const LAST_TELEMETRY_JSON_PATH: String = "simulation/results/last_telemetry.json"
const LAST_TELEMETRY_REPORT_PATH: String = "simulation/results/last_telemetry_report.txt"

const INDEX_CSV_HEADER: String = (
	"run_id,timestamp,personality_mode,count,start_seed,completed,"
	+ "wins_0,wins_1,wins_2,wins_3,"
	+ "win_rate_0,win_rate_1,win_rate_2,win_rate_3,"
	+ "avg_hands,avg_score_0,avg_score_1,avg_score_2,avg_score_3,"
	+ "matches_csv,summary_json,report_txt"
)


func save_run(
	count: int,
	start_seed: int,
	results: Array[Dictionary],
	summary: Dictionary,
	report_text: String,
	strategy_label: String = "HeuristicStrategy",
	telemetry_summary: Dictionary = {},
	telemetry_report: String = ""
) -> Dictionary:
	var run_id := _make_run_id(count, start_seed)
	var run_dir := "%s/%s" % [RUNS_DIR, run_id]
	var matches_path := "%s/matches.csv" % run_dir
	var summary_path := "%s/summary.json" % run_dir
	var report_path := "%s/report.txt" % run_dir
	var telemetry_json_path := "%s/telemetry.json" % run_dir
	var telemetry_csv_path := "%s/telemetry_by_seat.csv" % run_dir
	var telemetry_report_path := "%s/telemetry_report.txt" % run_dir

	var enriched_summary := summary.duplicate(true)
	enriched_summary["run_id"] = run_id
	enriched_summary["timestamp"] = _iso_timestamp()
	enriched_summary["start_seed"] = start_seed
	enriched_summary["strategy"] = strategy_label
	enriched_summary["paths"] = {
		"run_dir": run_dir,
		"matches_csv": matches_path,
		"summary_json": summary_path,
		"report_txt": report_path,
		"telemetry_json": telemetry_json_path,
		"telemetry_csv": telemetry_csv_path,
		"telemetry_report_txt": telemetry_report_path,
	}

	_write_csv(matches_path, results)
	_write_text(summary_path, JSON.stringify(enriched_summary, "\t"))
	_write_text(report_path, report_text)
	if not telemetry_summary.is_empty():
		_write_text(telemetry_json_path, JSON.stringify(telemetry_summary, "\t"))
		_write_text(telemetry_csv_path, AiTelemetryReport.format_seats_csv(telemetry_summary))
		_write_text(telemetry_report_path, telemetry_report)

	_copy_file(matches_path, LAST_CSV_PATH)
	_copy_file(summary_path, LAST_JSON_PATH)
	_write_text(LAST_REPORT_PATH, report_text)
	if not telemetry_summary.is_empty():
		_copy_file(telemetry_json_path, LAST_TELEMETRY_JSON_PATH)
		_write_text(LAST_TELEMETRY_REPORT_PATH, telemetry_report)

	_append_to_index(enriched_summary, report_path)

	return enriched_summary


static func _make_run_id(count: int, start_seed: int) -> String:
	var datetime := Time.get_datetime_dict_from_system()
	return "%04d%02d%02d_%02d%02d%02d_count%d_seed%d" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute,
		datetime.second,
		count,
		start_seed,
	]


static func _iso_timestamp() -> String:
	var datetime := Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02dT%02d:%02d:%02d" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute,
		datetime.second,
	]


func _append_to_index(summary: Dictionary, report_path: String) -> void:
	var entries: Array = _load_index_json()
	entries.append({
		"run_id": summary["run_id"],
		"timestamp": summary["timestamp"],
		"personality_mode": summary.get("strategy", ""),
		"count": summary["match_count"],
		"start_seed": summary["start_seed"],
		"strategy": summary.get("strategy", ""),
		"completed_matches": summary["completed_matches"],
		"wins_by_seat": summary["wins_by_seat"],
		"win_rates": summary["win_rates"],
		"avg_hands_per_match": summary["avg_hands_per_match"],
		"avg_final_scores": summary["avg_final_scores"],
		"paths": summary["paths"],
	})
	_write_text(INDEX_JSON_PATH, JSON.stringify(entries, "\t"))
	_write_index_csv(entries)


func _load_index_json() -> Array:
	if not FileAccess.file_exists(INDEX_JSON_PATH):
		return []
	var file := FileAccess.open(INDEX_JSON_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Array:
		return parsed
	return []


func _write_index_csv(entries: Array) -> void:
	var lines: PackedStringArray = PackedStringArray([INDEX_CSV_HEADER])
	for entry_variant: Variant in entries:
		if not entry_variant is Dictionary:
			continue
		var entry: Dictionary = entry_variant
		var wins: Array = entry.get("wins_by_seat", [0, 0, 0, 0])
		var rates: Array = entry.get("win_rates", [0.0, 0.0, 0.0, 0.0])
		var avg_scores: Array = entry.get("avg_final_scores", [0.0, 0.0, 0.0, 0.0])
		var paths: Dictionary = entry.get("paths", {})
		lines.append(
			"%s,%s,%s,%d,%d,%d,%d,%d,%d,%d,%.4f,%.4f,%.4f,%.4f,%.2f,%.1f,%.1f,%.1f,%.1f,%s,%s,%s" % [
				entry.get("run_id", ""),
				entry.get("timestamp", ""),
				entry.get("personality_mode", ""),
				int(entry.get("count", 0)),
				int(entry.get("start_seed", 0)),
				int(entry.get("completed_matches", 0)),
				int(wins[0]), int(wins[1]), int(wins[2]), int(wins[3]),
				float(rates[0]), float(rates[1]), float(rates[2]), float(rates[3]),
				float(entry.get("avg_hands_per_match", 0.0)),
				float(avg_scores[0]), float(avg_scores[1]), float(avg_scores[2]), float(avg_scores[3]),
				paths.get("matches_csv", ""),
				paths.get("summary_json", ""),
				paths.get("report_txt", ""),
			]
		)
	_write_text(INDEX_CSV_PATH, "\n".join(lines))


static func _write_csv(path: String, results: Array[Dictionary]) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SimulationArchive: impossible d'écrire %s" % path)
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


static func _write_text(path: String, content: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SimulationArchive: impossible d'écrire %s" % path)
		return
	file.store_string(content)
	file.close()


static func _copy_file(source_path: String, dest_path: String) -> void:
	if not FileAccess.file_exists(source_path):
		return
	var source := FileAccess.open(source_path, FileAccess.READ)
	if source == null:
		return
	var content := source.get_as_text()
	source.close()
	_write_text(dest_path, content)
