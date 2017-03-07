Function Get-MVPProfileImage
{
<#
    .SYNOPSIS
        Invoke the GetMVPProfileImage REST API to retrieve your MVP profile image

    .DESCRIPTION
        Gets your MVP profile image

    .EXAMPLE
        Get-MVPProfileImage
        
        This will get your MVP profile image
#>
	[CmdletBinding()]
	Param ()
	Process
	{
		Try
		{
			$ScriptName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).mycommand

			if (-not ($global:MVPPrimaryKey -and $global:MVPAuthorizationCode))
			{
				Write-Error -Message "[$ScriptName] You need to use Set-MVPConfiguration first to set the Primary Key"
			}
			
			Write-Verbose -Message "[$ScriptName] Set the MVP Configuration (refresh)"
			Set-MVPConfiguration -SubscriptionKey $global:MVPPrimaryKey -ErrorAction Stop
			
			
			Write-Verbose -Message "[$ScriptName] Build Splatting Hashtable"
			$Splat = @{
				Uri = 'https://mvpapi.azure-api.net/mvp/api/profile/photo'
				Headers = @{
					'Ocp-Apim-Subscription-Key' = $global:MVPPrimaryKey;
					Authorization = $Global:MVPAuthorizationCode
				}
				ErrorAction = 'Stop'
			}
			
			Write-Verbose -Message "[$ScriptName] Querying API"
			Invoke-RestMethod @Splat
		}
		catch
		{
			#Write-Warning -Message "Failed to invoke the Get-MVPProfile API because $($_.Exception.Message)"
			$PSCmdlet.ThrowTerminatingError()
		}
		
	}
}