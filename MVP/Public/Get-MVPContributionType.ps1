Function Get-MVPContributionType
{
<#
    .SYNOPSIS
        Invoke the GetContributionTypes REST API to retrieve contribution types

    .DESCRIPTION
        Gets a list of contribution types

    .EXAMPLE
        Get-MVPContributionType

        List all the contribution types
#>
	[CmdletBinding()]
	Param ()
	Begin { }
	Process
	{
		try
		{
			$ScriptName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).mycommand
			
			Write-Verbose -Message "[$ScriptName] Verify if the MVPConnection is set"
			if (-not ($global:MVPPrimaryKey -and $global:MVPAuthorizationCode))
			{
				
				Write-Warning -Message "[$ScriptName] You need to use Set-MVPConfiguration first to set the Primary Key"
			}
			else
			{
				
				Write-Verbose -Message "[$ScriptName] Refresh the MVPConnection"
				Set-MVPConfiguration -SubscriptionKey $global:MVPPrimaryKey
				
				Write-Verbose -Message "[$ScriptName] Build splatting hashtable"
				$Splat = @{
					Uri = 'https://mvpapi.azure-api.net/mvp/api/contributions/contributiontypes'
					Headers = @{
						'Ocp-Apim-Subscription-Key' = $global:MVPPrimaryKey
						Authorization = $Global:MVPAuthorizationCode
					}
					ErrorAction = 'Stop'
				}
				
				Write-Verbose -Message "[$ScriptName] Query Rest API"
				[PSCustomObject[]](Invoke-RestMethod @Splat)
			}
		}
		catch
		{
			#Write-Warning -Message "Failed to invoke the GetContributionTypes API because $($_.Exception.Message)"
			$PSCmdlet.ThrowTerminatingError($_)
		}
		
	}
	End { }
}