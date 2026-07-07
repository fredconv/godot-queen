class_name BatchStats
extends RefCounted
## Agrège les résultats de N parties simulées.


func summarize(results: Array[Dictionary]) -> Dictionary:
	var wins_by_seat: Array[int] = [0, 0, 0, 0]
	var total_hands: int = 0
	var completed: int = 0
	var score_totals: Array[int] = [0, 0, 0, 0]

	for result: Dictionary in results:
		if result.get("match_completed", false):
			completed += 1
		var winner: int = int(result.get("winner_index", -1))
		if winner >= 0 and winner < HeartsRules.PLAYER_COUNT:
			wins_by_seat[winner] += 1
		total_hands += int(result.get("hand_count", 0))
		var scores: Array = result.get("final_scores", [])
		for seat in range(mini(scores.size(), HeartsRules.PLAYER_COUNT)):
			score_totals[seat] += int(scores[seat])

	var match_count: int = results.size()
	var win_rates: Array[float] = []
	for seat in range(HeartsRules.PLAYER_COUNT):
		var rate: float = float(wins_by_seat[seat]) / float(match_count) if match_count > 0 else 0.0
		win_rates.append(rate)

	return {
		"match_count": match_count,
		"completed_matches": completed,
		"wins_by_seat": wins_by_seat,
		"win_rates": win_rates,
		"avg_hands_per_match": float(total_hands) / float(match_count) if match_count > 0 else 0.0,
		"avg_final_scores": _averages(score_totals, match_count),
	}


func format_report(summary: Dictionary, personality_mode: String = "") -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("=== Simulation Dame de Pique ===")
	if not personality_mode.is_empty():
		lines.append("Mode IA : %s" % personality_mode)
	lines.append("Parties : %d (%d terminées)" % [
		summary["match_count"],
		summary["completed_matches"],
	])
	lines.append("Manches moyennes / partie : %.1f" % summary["avg_hands_per_match"])
	lines.append("")
	if personality_mode.is_empty():
		lines.append("Victoires par siège :")
	else:
		lines.append("Victoires par siège (%s) :" % personality_mode)
	var wins: Array = summary["wins_by_seat"]
	var rates: Array = summary["win_rates"]
	var avg_scores: Array = summary["avg_final_scores"]
	for seat in range(HeartsRules.PLAYER_COUNT):
		lines.append(
			"  Siège %d : %d victoires (%.1f%%) — score final moyen %.1f" % [
				seat,
				int(wins[seat]),
				float(rates[seat]) * 100.0,
				float(avg_scores[seat]),
			]
		)
	return "\n".join(lines)


static func _averages(totals: Array[int], count: int) -> Array[float]:
	var averages: Array[float] = []
	for total in totals:
		averages.append(float(total) / float(count) if count > 0 else 0.0)
	return averages
