class_name AiTelemetryReport
extends RefCounted
## Formate les agrégats de `AiTelemetryCollector` en rapport texte lisible.


static func format_report(telemetry_summary: Dictionary, personality_mode: String = "") -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("=== Télémétrie IA — décisions ===")
	if not personality_mode.is_empty():
		lines.append("Mode IA : %s" % personality_mode)
	lines.append(
		"Parties : %d | Manches : %d" % [
			int(telemetry_summary.get("matches_played", 0)),
			int(telemetry_summary.get("hands_played", 0)),
		]
	)
	lines.append("")

	var seats: Array = telemetry_summary.get("seats", [])
	for seat_variant: Variant in seats:
		if not seat_variant is Dictionary:
			continue
		lines.append(_format_seat_block(seat_variant))

	lines.append("--- Regret stratégique (estimation vs réalité) ---")
	for row_variant: Variant in telemetry_summary.get("regret_analysis", []):
		if not row_variant is Dictionary:
			continue
		var row: Dictionary = row_variant
		lines.append(
			"  %s : %d tentatives, taux réel %.0f%%" % [
				row.get("bucket", ""),
				int(row.get("attempts", 0)),
				float(row.get("actual_success_rate", 0.0)) * 100.0,
			]
		)

	lines.append("")
	lines.append("--- Tableau prioritaire ---")
	lines.append("Siège | Vict. | Moy/manche | Lunes | Réussite | Détection | Cassage | Coût Lune ratée | Avec tentative | Sans tentative")
	for row_variant: Variant in telemetry_summary.get("priority_table", []):
		if not row_variant is Dictionary:
			continue
		var row: Dictionary = row_variant
		lines.append(
			"  %d | %d | %.1f | %d | %.0f%% | %.0f%% | %.0f%% | %.1f | %.1f | %.1f" % [
				int(row.get("seat", -1)),
				int(row.get("wins", 0)),
				float(row.get("avg_hand_score", 0.0)),
				int(row.get("moon_attempts", 0)),
				float(row.get("moon_success_rate", 0.0)) * 100.0,
				float(row.get("moon_detection_rate", 0.0)) * 100.0,
				float(row.get("moon_break_rate_on_detected", 0.0)) * 100.0,
				float(row.get("avg_score_after_failed_moon", 0.0)),
				float(row.get("avg_hand_score_with_attempt", 0.0)),
				float(row.get("avg_hand_score_without_attempt", 0.0)),
			]
		)
	return "\n".join(lines)


static func format_seats_csv(telemetry_summary: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append(
		"seat,matches,wins,second,third,fourth,win_rate,avg_final_score,avg_hand_score,"
		+ "moon_attempts,moon_successes,moon_success_rate,moon_detected,moon_detection_rate,"
		+ "avg_detection_trick,moons_broken,break_success_rate,sacrifice_points,"
		+ "avg_score_failed_moon,avg_hand_with_attempt,avg_hand_without_attempt,detections_made"
	)
	for seat_variant: Variant in telemetry_summary.get("seats", []):
		if not seat_variant is Dictionary:
			continue
		var s: Dictionary = seat_variant
		lines.append(
			"%d,%d,%d,%d,%d,%d,%.4f,%.2f,%.2f,%d,%d,%.4f,%d,%.4f,%.2f,%d,%.4f,%d,%.2f,%.2f,%.2f,%d" % [
				int(s.get("seat", -1)),
				int(s.get("matches", 0)),
				int(s.get("wins", 0)),
				int(s.get("second", 0)),
				int(s.get("third", 0)),
				int(s.get("fourth", 0)),
				float(s.get("win_rate", 0.0)),
				float(s.get("avg_final_score", 0.0)),
				float(s.get("avg_hand_score", 0.0)),
				int(s.get("moon_attempts", 0)),
				int(s.get("moon_successes", 0)),
				float(s.get("moon_success_rate", 0.0)),
				int(s.get("moon_detected", 0)),
				float(s.get("moon_detection_rate", 0.0)),
				float(s.get("avg_detection_trick", 0.0)),
				int(s.get("moons_broken", 0)),
				float(s.get("break_success_rate", 0.0)),
				int(s.get("sacrifice_points", 0)),
				float(s.get("avg_score_after_failed_moon", 0.0)),
				float(s.get("avg_hand_score_with_attempt", 0.0)),
				float(s.get("avg_hand_score_without_attempt", 0.0)),
				int(s.get("detections_made", 0)),
			]
		)
	return "\n".join(lines)


static func _format_seat_block(seat: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()
	var seat_index: int = int(seat.get("seat", -1))
	lines.append("--- Siège %d ---" % seat_index)
	lines.append(
		"Victoires : %d (%.1f%%) | 2e:%d 3e:%d 4e:%d | Score final moyen %.1f | Manches moy. avant victoire %.1f" % [
			int(seat.get("wins", 0)),
			float(seat.get("win_rate", 0.0)) * 100.0,
			int(seat.get("second", 0)),
			int(seat.get("third", 0)),
			int(seat.get("fourth", 0)),
			float(seat.get("avg_final_score", 0.0)),
			float(seat.get("avg_hands_before_win", 0.0)),
		]
	)
	lines.append(
		"Lune : %d tentées, %d réussies (%.0f%%) | détectées %d (%.0f%%, pli moy. %.1f) | cassées %d" % [
			int(seat.get("moon_attempts", 0)),
			int(seat.get("moon_successes", 0)),
			float(seat.get("moon_success_rate", 0.0)) * 100.0,
			int(seat.get("moon_detected", 0)),
			float(seat.get("moon_detection_rate", 0.0)) * 100.0,
			float(seat.get("avg_detection_trick", 0.0)),
			int(seat.get("moons_broken", 0)),
		]
	)
	lines.append(
		"Qualité : tentatives haute conf. %d | basse conf. %d | après échec score moy. %.1f" % [
			int(seat.get("moon_attempt_high_prob", 0)),
			int(seat.get("moon_attempt_low_prob", 0)),
			float(seat.get("avg_score_after_failed_moon", 0.0)),
		]
	)
	lines.append(
		"Rentabilité manche : avec tentative %.1f pts | sans tentative %.1f pts | sacrifices %d pts (%d fois)" % [
			float(seat.get("avg_hand_score_with_attempt", 0.0)),
			float(seat.get("avg_hand_score_without_attempt", 0.0)),
			int(seat.get("sacrifice_points", 0)),
			int(seat.get("sacrifice_events", 0)),
		]
	)
	lines.append(
		"Lecture : détections émises %d | plis gagnés moy. %.1f | suite max %d | Dame prise %d" % [
			int(seat.get("detections_made", 0)),
			float(seat.get("avg_tricks_won_per_hand", 0.0)),
			int(seat.get("max_consecutive_trick_streak", 0)),
			int(seat.get("queen_taken", 0)),
		]
	)
	lines.append("")
	return "\n".join(lines)
