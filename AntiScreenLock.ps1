function ScreenAlive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int]$DelaySeconds = 5
    )

    $ES_CONTINUOUS        = 0x80000000
    $ES_SYSTEM_REQUIRED   = 0x00000001
    $ES_DISPLAY_REQUIRED  = 0x00000002
    $executionFlags = $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED

    $signature = @"
	[DllImport("kernel32.dll")]
    public static extern uint SetThreadExecutionState(uint esFlags);
"@
    Add-Type -MemberDefinition $signature -Name "PowerHelper" -Namespace "WinAPI" -PassThru | Out-Null

    try {
        Write-Host "ScreenAlive started – keeping the session alive (ping every $DelaySeconds sec)."

        while ($true) {
            [WinAPI.PowerHelper]::SetThreadExecutionState($executionFlags) | Out-Null

            $now = Get-Date -Format "HH:mm:ss"
            Write-Host "[$now] Ping sent – system stays awake."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
    finally {
        [WinAPI.PowerHelper]::SetThreadExecutionState($ES_CONTINUOUS) | Out-Null
        Write-Host "`nScreenAlive stopped – default power settings restored." -ForegroundColor Yellow
    }
}
