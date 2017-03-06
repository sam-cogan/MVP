﻿Function Remove-MVPConfiguration {
[CmdletBinding()]
Param(
    [Parameter()]
    [string]$ClientID='0000000048193351'
)
Begin {
    $RedirectUri  = 'https://login.live.com/oauth20_desktop.srf'
}
Process {
    If ($MVPOauth2) {
        # GET https://login.live.com/oauth20_logout.srf?client_id={client_id}&redirect_uri={redirect_uri}
        Write-Verbose -Message 'Attempt to gracefully sign out'
        $HashTable = @{
            Uri = 'https://login.live.com/oauth20_logout.srf?client_id={0}&redirect_uri={1}' -f $ClientID,$RedirectUri
            ErrorAction = 'Stop'
        }
        try {
            $r = Invoke-WebRequest @HashTable
            $global:MVPOauth2 = $null
            Write-Verbose -Message 'Successfully signed out'
        } catch {
            Throw $_
        }
    }
    If ($MVPPrimaryKey) {
        $global:MVPPrimaryKey = $null
    }
    If ($MVPAuthorizationCode) {
        $global:MVPAuthorizationCode = $null
    }
}
End {}
}