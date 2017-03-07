Function Remove-MVPConfiguration
{
	<#
	.SYNOPSIS
		Function to remove the global variables and perform a gracefully sign out
	
	.DESCRIPTION
		Function to remove the global variables and perform a gracefully sign out
	
	.PARAMETER ClientID
		Specifies the ClientID
	
	.EXAMPLE
		Remove-MVPConfiguration
#>
	[CmdletBinding()]
	Param (
		[Parameter()]
		[string]$ClientID = '0000000048193351'
	)
	Begin
	{
		$RedirectUri = 'https://login.live.com/oauth20_desktop.srf'
	}
	Process
	{
		try
		{
			$ScriptName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).mycommand
			
			If ($global:MVPOauth2)
			{
				
				# GET https://login.live.com/oauth20_logout.srf?client_id={client_id}&redirect_uri={redirect_uri}
				Write-Verbose -Message "[$ScriptName] Attempt to gracefully sign out"
				$HashTable = @{
					Uri = 'https://login.live.com/oauth20_logout.srf?client_id={0}&redirect_uri={1}' -f $ClientID, $RedirectUri
					ErrorAction = 'Stop'
				}
				
				
				Invoke-WebRequest @HashTable
				
				$global:MVPOauth2 = $null
				Write-Verbose -Message 'Successfully signed out'
				
			}
			If ($MVPPrimaryKey)
			{
				$global:MVPPrimaryKey = $null
			}
			If ($MVPAuthorizationCode)
			{
				$global:MVPAuthorizationCode = $null
			}
		}
		catch
		{
			$PSCmdlet.ThrowTerminatingError($_)
		}
	}
	End { }
}