Function Set-MVPContribution {
<#
    .SYNOPSIS
        Invoke the PutContribution REST API

    .DESCRIPTION
        Updates a Contribution item

    .PARAMETER ContributionTechnology
		Specifies the Contribution Technology
	
    .PARAMETER ContributionType
		Specifies the Contribution Type
	
    .PARAMETER StartDate
		Specifies the Start Date of the Contribution
	
    .PARAMETER Title
		Specifies the Title of the contribution
	
    .PARAMETER Description
		Specifies the Description of the contribution
	
    .PARAMETER ReferenceUrl
		Specifies an URL for the contribution
	
    .PARAMETER AnnualQuantity
		Specifies the Annual Quantity for the contribution
	
    .PARAMETER SecondAnnualQuantity
		Specifies a Second Annual Quantity for the contribution
	
    .PARAMETER AnnualReach
		Specifies an Annual Reach for the contribution
		
    .PARAMETER Visibility
		Specifies the Visibility for the contribution

    .EXAMPLE
        Set-MVPContribution -ContributionID 691729 -Description 'wowwwwwww!!!' 
	
		This will add a description to the Contribution ID 691729.

    .EXAMPLE
        Get-MVPContribution -ContributionId 700210 | Set-MVPContribution -Description "wwooowww!!" -Verbose
	
		Using the Pipeline, this will add a description to the Contribution ID 700210 and show the Verbose messages.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [int32]$ContributionID,

    [Parameter()]
    [string]$ContributionType='video',

    [Parameter()]
    [string]$ContributionTechnology='PowerShell',

    [Parameter()]
    [String]$StartDate = '2017/02/01',
    
    [Parameter()]
    [String]$Title='Test from mvpapi.azure-api.net',

    [Parameter()]
    [String]$Description='Description sample',
    
    [Parameter()]
    [String]$ReferenceUrl='https://github.com/lazywinadmin/MVP',
    
    [Parameter()]
    [String]$AnnualQuantity='0',
    
    [Parameter()]
    [String]$SecondAnnualQuantity='0',

    [Parameter()]    
    [String]$AnnualReach = '0',
    
    [Parameter()]
    [ValidateSet('EveryOne','Microsoft','MVP Community','Microsoft Only')]
    [String]$Visibility = 'Microsoft'
    )
Begin {}
Process {
		try
		{
			$ScriptName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).mycommand
			
			if (-not ($global:MVPPrimaryKey -and $global:MVPAuthorizationCode))
			{
				
				Write-Warning -Message "[$ScriptName] You need to use Set-MVPConfiguration first to set the Primary Key"
				
			}
			else
			{
				Write-Verbose -Message "[$ScriptName] Refresh the MVPConnection"
				Set-MVPConfiguration -SubscriptionKey $MVPPrimaryKey -erroraction stop
				
				Write-Verbose -Message "[$ScriptName] Build splatting hashtable"
				$Splat = @{
					Uri = 'https://mvpapi.azure-api.net/mvp/api/contributions'
					Headers = @{
						'Ocp-Apim-Subscription-Key' = $global:MVPPrimaryKey
						Authorization = $Global:MVPAuthorizationCode
						ContentType = 'application/json'
					}
					Method = 'PUT'
					ContentType = 'application/json'
					ErrorAction = 'Stop'
				}
				
				# Retrieve contribution
				Write-Verbose -Message "[$ScriptName] Retrieve contribution ID = $ContributionID"
				$CurrentContributionObject = Get-MVPContribution -ID $ContributionID -errorAction Stop
				
				if ($CurrentContributionObject)
				{
					
					if ($PSBoundParameters['ContributionType'])
					{
						# Verify the Contribution Type
						Write-Verbose -Message "[$ScriptName] Retrieve contribution Type = $ContributionType"
						$type = Get-MVPContributionType -errorAction Stop | Where-Object { $_.name -eq $ContributionType }
					}
					else
					{
						Write-Verbose -Message "[$ScriptName] Use Contribution Type = $($CurrentContributionObject.ContributionType)"
						$type = $CurrentContributionObject.ContributionType
					}
					
					if ($PSBoundParameters['ContributionTechnology'])
					{
						# Verify the Contribution Technology/Area
						Write-Verbose -Message "[$ScriptName] Retrieve Contribution Area = $ContributionTechnology"
						$Technology = Get-MVPContributionArea -All -errorAction Stop | Where-Object { $_.name -eq $ContributionTechnology }
					}
					else
					{
						Write-Verbose -Message "[$ScriptName] Use Contribution Area = $($CurrentContributionObject.ContributionTechnology)"
						$Technology = $CurrentContributionObject.ContributionTechnology
					}
					
					# Get the Visibility
					if ($PSBoundParameters['Visibility'])
					{
						Write-Verbose -Message "[$ScriptName] Retrieve Contribution Visibility = $Visibility"
						$VisibilityObject = Get-MVPContributionVisibility -erroraction stop | Where-Object { $_.Description -eq $Visibility }
					}
					else
					{
						Write-Verbose -Message "[$ScriptName] Use Contribution Visibility = $($CurrentContributionObject.Visibility)"
						$VisibilityObject = $CurrentContributionObject.Visibility
					}
					
					if (-not $PSBoundParameters['StartDate']) { $StartDate = $CurrentContributionObject.StartDate }
					if (-not $PSBoundParameters['Title']) { $Title = $CurrentContributionObject.Title }
					if (-not $PSBoundParameters['Description']) { $Description = $CurrentContributionObject.Description }
					if (-not $PSBoundParameters['ReferenceUrl']) { $ReferenceUrl = $CurrentContributionObject.ReferenceUrl }
					if (-not $PSBoundParameters['AnnualQuantity']) { $AnnualQuantity = $CurrentContributionObject.AnnualQuantity }
					if (-not $PSBoundParameters['SecondAnnualQuantity']) { $SecondAnnualQuantity = $CurrentContributionObject.SecondAnnualQuantity }
					if (-not $PSBoundParameters['AnnualReach']) { $AnnualReach = $CurrentContributionObject.AnnualReach }
					
					
					Write-Verbose -Message "[$ScriptName] Preparing Body..."
					$Body = @"
{
  "ContributionId": $ContributionID,
  "ContributionTypeName": "$($type.name)",
  "ContributionType": {
    "Id": "$($type.id)",
    "Name": "$($type.name)",
    "EnglishName": "$($type.englishname)"
  },
  "ContributionTechnology": {
    "Id": "$($Technology.id)",
    "Name": "$($Technology.name)",
    "AwardName": "$($Technology.awardname)",
    "AwardCategory": "$($Technology.awardcategory)"
  },
  "StartDate": "$StardDate",
  "Title": "$Title",
  "ReferenceUrl": "$ReferenceUrl",
  "Visibility": {
    "Id": $($VisibilityObject.id),
    "Description": "$($VisibilityObject.Description)",
    "LocalizeKey": "$($VisibilityObject.LocalizeKey)"
  },
  "AnnualQuantity": $AnnualQuantity,
  "SecondAnnualQuantity": $SecondAnnualQuantity,
  "AnnualReach": $AnnualReach,
  "Description": "$Description"
}
"@
					if ($type -and $Technology)
					{
						try
						{
							Write-Verbose -Message "[$ScriptName] About to update contribution $($ContributionID) with Body $($Body)"
							Invoke-RestMethod @Splat -Body $Body
						}
						catch
						{
							Write-Warning -Message "[$ScriptName] Failed to invoke the PutContribution API because $($_.Exception.Message)"
						}
					}
					else
					{
						Write-Warning -Message "[$ScriptName] Either contributiontype or contributionarea isn't recognized"
					}
				}
				else
				{
					Write-Warning -Message "[$ScriptName] ContributionId $($ContributionID) probably not found"
				}
			}
		}
		catch
		{
			$PSCmdlet.ThrowTerminatingError($_)
		}
	}
	End {}
}