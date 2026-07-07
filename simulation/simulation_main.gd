extends Node
## Scène d'entrée du simulateur (charge les autoloads du projet).


const DEFAULT_COUNT: int = 1000
const DEFAULT_START_SEED: int = 1


func _ready() -> void:
	var args := _parse_args(OS.get_cmdline_user_args())
	var count: int = int(args.get("count", DEFAULT_COUNT))
	var start_seed: int = int(args.get("seed", DEFAULT_START_SEED))

	var simulator := MatchSimulator.new()
	var telemetry := AiTelemetryCollector.new()
	var results: Array[Dictionary] = []
	results.resize(count)

	for index in range(count):
		results[index] = simulator.play_match(start_seed + index, telemetry)

	var stats := BatchStats.new()
	var summary: Dictionary = stats.summarize(results)
	var telemetry_summary: Dictionary = telemetry.summarize()
	summary["telemetry"] = telemetry_summary
	var mode_label: String = AiPersonalityCatalog.get_mode_label()
	var report_text: String = stats.format_report(summary, mode_label)
	var telemetry_report: String = AiTelemetryReport.format_report(telemetry_summary, mode_label)
	print(report_text)
	print("")
	print(telemetry_report)
	print(AiPersonalityCatalog.format_table_line())

	var archive := SimulationArchive.new()
	var saved: Dictionary = archive.save_run(
		count, start_seed, results, summary, report_text, mode_label, telemetry_summary, telemetry_report
	)

	print("")
	print("=== Fichiers enregistrés ===")
	print("Dossier du run : %s" % saved["paths"]["run_dir"])
	print("Index global   : %s" % SimulationArchive.INDEX_CSV_PATH)
	print("Dernière copie : %s" % SimulationArchive.LAST_REPORT_PATH)

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
		index += 1
	return parsed
