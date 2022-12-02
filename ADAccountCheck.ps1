function Check-ADUserActivity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [Alias('samaccountname','user')]
        [string]$Identity = $(Read-Host "Please Enter Username")
    )
    try {
        if([bool]$(Get-ADUser -Filter {sAMAccountName -eq $Identity})){
            $ADUser = Get-ADUser -Identity $Identity -Properties *            
            # Get all DCs
            $DCs = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName | Sort-Object
            # Get the newest logon date from all DCs and get last bad password attempt
            $NewestLogonDate = $null
            $LastBadPasswordAttempt = $null
            foreach($DC in $DCs){
                $ADUserfromDC = Get-ADUser -Identity $Identity -Server $DC -Properties LastLogon,LastBadPasswordAttempt
                $LogonDate = $ADUserfromDC | Select-Object -ExpandProperty LastLogon
                $BadPasswordAttempt = $ADUserfromDC | Select-Object -ExpandProperty LastBadPasswordAttempt
                if($LogonDate -gt $NewestLogonDate){
                    $NewestLogonDate = $LogonDate
                }
                if($BadPasswordAttempt -gt $LastBadPasswordAttempt){
                    $LastBadPasswordAttempt = $BadPasswordAttempt
                }
            }
            # Create pscustomobject for output
            $Output = [PSCustomObject]@{
                Firstname = $ADUser.GivenName
                Lastname = $ADUser.Surname
                SamAccountName = $ADUser.SamAccountName
                DistinguishedName = $ADUser.DistinguishedName
                Lockedout = $ADUser.lockedout
                IsActive = $ADUser.Enabled
                LastLogon = [datetime]::FromFileTime($NewestLogonDate)                
                LastBadPasswordAttempt = $LastBadPasswordAttempt
                pwdLastSet = [datetime]::FromFileTime($ADUser.pwdLastSet)
                PasswordExpired = $ADUser.PasswordExpired
                PasswordNeverExpires = $ADUser.PasswordNeverExpires
            }
            # Write output to stdout
            return $Output
        }
        else{
            Write-Host "User $Identity not found" -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
        Write-Host "File: $($_.InvocationInfo.ScriptName)" -ForegroundColor Red
    }
}