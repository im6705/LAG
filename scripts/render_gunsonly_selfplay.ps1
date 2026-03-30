param(
    [string]$Python = "python",
    [string]$ExperimentName = "guns_test",
    [string]$ScenarioName = "1v1/GunsOnlyDogfight/Selfplay",
    [string]$AlgorithmName = "ppo",
    [int]$Seed = 1,
    [string]$Gpu = "0",
    [string]$ModelDir = "",
    [string]$RenderIndex = "latest",
    [string]$RenderOpponentIndex = "latest",
    [switch]$Cpu
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $scriptDir

try {
    if (-not $ModelDir) {
        $baseDir = Join-Path $scriptDir ("results\SingleCombat\" + ($ScenarioName -replace "/", "\") + "\" + $AlgorithmName + "\" + $ExperimentName)
        if (-not (Test-Path $baseDir)) {
            throw "Model directory base not found: $baseDir"
        }

        $latestRun = Get-ChildItem $baseDir -Directory |
            Where-Object { $_.Name -like "run*" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if (-not $latestRun) {
            throw "No run* directory found under: $baseDir"
        }

        $ModelDir = $latestRun.FullName
    }

    $acmiPath = Join-Path $scriptDir ("results\SingleCombat\" + ($ScenarioName -replace "/", "\") + "\" + $AlgorithmName + "\" + $ExperimentName + "\render\" + $ExperimentName + ".txt.acmi")

    $args = @(
        "render/render_jsbsim.py",
        "--env-name", "SingleCombat",
        "--algorithm-name", $AlgorithmName,
        "--scenario-name", $ScenarioName,
        "--experiment-name", $ExperimentName,
        "--seed", $Seed,
        "--n-training-threads", "1",
        "--n-rollout-threads", "1",
        "--model-dir", $ModelDir,
        "--use-selfplay",
        "--render-index", $RenderIndex,
        "--render-opponent-index", $RenderOpponentIndex
    )

    if (-not $Cpu) {
        $env:CUDA_VISIBLE_DEVICES = $Gpu
        $args += "--cuda"
    }

    Write-Host "Starting render:"
    Write-Host "  scenario=$ScenarioName"
    Write-Host "  experiment=$ExperimentName"
    Write-Host "  model_dir=$ModelDir"
    Write-Host "  render_index=$RenderIndex"
    Write-Host "  render_opponent_index=$RenderOpponentIndex"
    Write-Host "  output=$acmiPath"
    if ($Cpu) {
        Write-Host "  device=cpu"
    } else {
        Write-Host "  device=gpu:$Gpu"
    }

    & $Python @args
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
