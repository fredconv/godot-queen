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
    "scripts/ui/table/table_hot_seat.gd",
    "scripts/ui/table/hot_seat_privacy_overlay.gd",
    "scripts/ui/game_mode_screen.gd",
    "scripts/ui/hot_seat_lobby_screen.gd",
    "scripts/ui/multiplayer_lobby_screen.gd",
    "tests/unit/test_seat_setup.gd",
    "tests/unit/test_match_launch_config.gd",
    "tests/unit/test_table_hot_seat.gd",
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
        "Fichier multijoueur modifie. Lire .cursor/skills/dame-de-pique-multiplayer/SKILL.md et docs/MULTIPLAYER_DESIGN.md."
        "Lancer tests : test_seat_setup, test_match_launch_config, test_table_hot_seat, test_lobby_service."
        "Ne pas introduire MultiplayerSynchronizer/Spawner pour le gameplay Hearts (ADR-024)."
    ) -join " "
} | ConvertTo-Json -Compress

Write-Output $response
exit 0
