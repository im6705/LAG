param(
    [string]$Python = "python",
    [string]$ExperimentName = "guns_v1",
    [int]$Seed = 1,
    [string]$Gpu = "0",
    [int]$RolloutThreads = 32,
    [int]$EvalRolloutThreads = 1,
    [switch]$Cpu
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $scriptDir

try {
    $args = @(
        "train/train_jsbsim.py",
        "--env-name", "SingleCombat",
        "--algorithm-name", "ppo",
        "--scenario-name", "1v1/GunsOnlyDogfight/Selfplay",
        "--experiment-name", $ExperimentName,
        "--seed", $Seed,
        "--n-training-threads", "1",
        "--n-rollout-threads", $RolloutThreads,
        "--log-interval", "1",
        "--save-interval", "1",
        "--use-selfplay",
        "--selfplay-algorithm", "fsp",
        "--n-choose-opponents", "1",
        "--use-eval",
        "--n-eval-rollout-threads", $EvalRolloutThreads,
        "--eval-interval", "1",
        "--eval-episodes", "1",
        "--num-mini-batch", "5",
        "--buffer-size", "3000",
        "--num-env-steps", "1e8",
        "--lr", "3e-4",
        "--gamma", "0.99",
        "--ppo-epoch", "4",
        "--clip-params", "0.2",
        "--max-grad-norm", "2",
        "--entropy-coef", "1e-3",
        "--hidden-size", "128 128",
        "--act-hidden-size", "128 128",
        "--recurrent-hidden-size", "128",
        "--recurrent-hidden-layers", "1",
        "--data-chunk-length", "8"
    )

    if (-not $Cpu) {
        $env:CUDA_VISIBLE_DEVICES = $Gpu
        $args += "--cuda"
    }

    Write-Host "Starting training:"
    Write-Host "  scenario=1v1/GunsOnlyDogfight/Selfplay"
    Write-Host "  experiment=$ExperimentName"
    Write-Host "  seed=$Seed"
    Write-Host "  rollout_threads=$RolloutThreads"
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
