# Rappel post-édition : fichiers IA / Lune / messages table → lancer les tests unitaires.
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
    "scripts/ai/",
    "scripts/match/match_manager.gd",
    "scripts/ui/table/table_ai",
    "scripts/ui/table/table_play_flow.gd",
    "tests/unit/test_moon",
    "tests/unit/test_adaptive",
    "tests/unit/test_ai"
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
        "Fichier IA/gameplay modifie. Executer les tests unitaires Lune/IA :"
        "tests/unit/test_moon_feasibility.gd, test_adaptive_ai_strategy.gd, test_moon_suspicion.gd, test_ai_confidence.gd"
        "Si seuils ou personnalites changes : simulation 1000 parties (simulation/)."
        "Skill projet : .cursor/skills/dame-de-pique-ai-gameplay/SKILL.md"
    ) -join " "
} | ConvertTo-Json -Compress

Write-Output $response
exit 0
