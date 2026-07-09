# Rappel post-édition multijoueur → tests unitaires + skill projet.
$inputRaw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($inputRaw)) { exit 0 }

try {
    $payload = $inputRaw | ConvertFrom-Json
} catch {
    exit 0
}

$path = ""
if ($payload.PSObject.Properties.Name -contains "file_path") {
    $path = [string]$payload.file_path
} elseif ($payload.PSObject.Properties.Name -contains "path") {
    $path = [string]$payload.path
}

if ([string]::IsNullOrWhiteSpace($path)) { exit 0 }

$normalized = $path -replace "\\", "/"
$patterns = @(
    "scripts/network/",
    "scripts/match/match_launch_config.gd",
    "scripts/match/match_mode.gd",
    "scripts/match/moon_suspicion_event.gd",
    "scripts/ui/table/table_hot_seat.gd",
    "scripts/ui/table/hot_seat_privacy_overlay.gd",
    "scripts/ui/table/table_seat_display_map.gd",
    "scripts/ui/table/table_trick_display.gd",
    "scripts/ui/table/table_human_hand.gd",
    "scripts/ui/table/table_dealing.gd",
    "scripts/ui/table/table_play_flow.gd",
    "scripts/ui/table/table_hand_start.gd",
    "scripts/ui/table/table_disconnect_flow.gd",
    "scripts/network/disconnect_state.gd",
    "scripts/ui/table/moon_suspicion_manager.gd",
    "scripts/ui/table/moon_suspicion_banner.gd",
    "scripts/ui/game_mode_screen.gd",
    "scripts/ui/hot_seat_lobby_screen.gd",
    "scripts/ui/multiplayer_lobby_screen.gd",
    "scenes/table/moon_suspicion_banner.tscn",
    "tests/unit/test_seat_setup.gd",
    "tests/unit/test_match_launch_config.gd",
    "tests/unit/test_table_hot_seat.gd",
    "tests/unit/test_table_seat_display_map.gd",
    "tests/unit/test_moon_suspicion_manager.gd",
    "tests/unit/test_disconnect_state.gd",
    ".cursor/architecture/dame-de-pique/lessons-learned.md",
    "docs/MULTIPLAYER"
)

$matched = $false
foreach ($pattern in $patterns) {
    if ($normalized -like "*$pattern*") {
        $matched = $true
        break
    }
}

if (-not $matched) { exit 0 }

$response = @{
    agent_message = @(
        "Fichier multijoueur modifie. Lire .cursor/skills/dame-de-pique-multiplayer/SKILL.md (+ reference.md) et docs/MULTIPLAYER_DESIGN.md."
        "Tests : test_seat_setup, test_match_launch_config, test_table_hot_seat, test_table_seat_display_map, test_moon_suspicion_manager, test_disconnect_state."
        "Dépannage : .cursor/architecture/dame-de-pique/lessons-learned.md (autoload circulaire, banner freed, hot seat pivot)."
        "Hot seat : TableSeatDisplayMap pour affichage ; pas ctx.seats[logical_seat] (ADR-025)."
        "Pas de MultiplayerSynchronizer/Spawner pour le gameplay Hearts (ADR-024)."
    ) -join " "
} | ConvertTo-Json -Compress

Write-Output $response
exit 0
