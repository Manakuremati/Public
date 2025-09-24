function ScreenAlive {
    [CmdletBinding()]
    param (
        [int]$DelaySeconds = 5
    )
    $ES_CONTINUOUS        = 2147483648
    $ES_SYSTEM_REQUIRED   = 1
    $ES_DISPLAY_REQUIRED  = 2
    $executionFlags = $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED
    $signature = @"
	[DllImport("kernel32.dll")]
	public static extern uint SetThreadExecutionState(uint esFlags);
"@
    Add-Type -MemberDefinition $signature -Name "PowerHelper" -Namespace "WinAPI" -PassThru | Out-Null

    try {
        Write-Host "ScreenAlive started – keeping the system alive (ping every $DelaySeconds sec)."
        while ($true) {
            [WinAPI.PowerHelper]::SetThreadExecutionState($executionFlags) | Out-Null
            $now = Get-Date -Format "HH:mm:ss"
            Write-Host "[$now] Ping sent"
            Start-Sleep -Seconds $DelaySeconds
        }
    }
    finally {
        [WinAPI.PowerHelper]::SetThreadExecutionState($ES_CONTINUOUS) | Out-Null
        Write-Host "ScreenAlive stopped – default power settings restored." -ForegroundColor Yellow
    }
}
