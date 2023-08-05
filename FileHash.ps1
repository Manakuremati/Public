function All-FileHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValuefromPipeline=$true)]
        [string]$FilePath = "$(Read-Host "Please Enter a File Path")"
    )
    try {
        if([bool]$(Test-Path -Path $FilePath -PathType Any)){
            $Hash = @(
            "$((Get-FileHash -Path $FilePath -Algorithm SHA1).Hash)",
            "$((Get-FileHash -Path $FilePath -Algorithm SHA256).Hash)",
            "$((Get-FileHash -Path $FilePath -Algorithm SHA384).Hash)",
            "$((Get-FileHash -Path $FilePath -Algorithm SHA512).Hash)",
            "$((Get-FileHash -Path $FilePath -Algorithm MD5).Hash)",
            "$((Get-FileHash -Path $FilePath -Algorithm MACTripleDES).Hash)",
            "$((Get-FileHash -Path $FilePath -Algorithm RIPEMD160).Hash)"
            )
            $Output = [PSCustomObject]@{
                SHA1 = $Hash[0]
                SHA256 = $Hash[1]
                SHA384 = $Hash[2]
                SHA512 = $Hash[3]
                MD5 = $Hash[4]
                MACTripleDES = $Hash[5]
                RIPEMD160 = $Hash[6]
            }
        return $Output
        }
        
        else {
            Write-Host "File $FilePath not found" -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
        Write-Host "File: $($_.InvocationInfo.ScriptName)" -ForegroundColor Red
    }
}