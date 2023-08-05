function Prevent-ScreenLock {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ParameterSetName="Time")]
        [Int32]$Time = $(Read-Host "Please Enter a Time"))
    $WShell = New-Object -com "WScript.shell"
    $counter = 0
    try{
        while($true){
            $WShell.sendkeys("{SCROLLLOCK}")
		    start-sleep -Milliseconds 100
		    $WShell.sendkeys("{SCROLLLOCK}")
		    $counter = $Counter + 1
		    Echo "$($Counter)"
		    start-sleep -Seconds $Time 
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
        Write-Host "File: $($_.InvocationInfo.ScriptName)" -ForegroundColor Red
    }
}