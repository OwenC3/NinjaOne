
using namespace System.Management.Automation
#Requires -Version 7
function New-NinjaOneOrganisation {
    <#
        .SYNOPSIS
            Creates a new organisation using the NinjaOne API.
        .DESCRIPTION
            Create an organisation using the NinjaOne v2 API.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( SupportsShouldProcess = $true, ConfirmImpact = 'Medium' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # The ID of the organisation to use as a template.
        [string]$templateOrganizationId,
        # An object containing the organisation to create.
        [Parameter(Mandatory = $true)]
        [object]$organisation,
        # Show the organisation that was created.
        [switch]$show
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'templateOrganizationId=' parameter by removing it from the set parameters.
    if ($templateOrganizationId) {
        $Parameters.Remove('templateOrganizationId') | Out-Null
    }
    # Workaround to prevent the query string processor from adding an 'organisation=' parameter by removing it from the set parameters.
    if ($organisation) {
        $Parameters.Remove('organisation') | Out-Null
    }
    # Workaround to prevent the query string processor from adding an 'show=' parameter by removing it from the set parameters.
    if ($show) {
        $Parameters.Remove('show') | Out-Null
    }
    try {
        $QSCollection = New-NinjaOneQuery -CommandName $CommandName -Parameters $Parameters
        $Resource = 'v2/organizations'
        $RequestParams = @{
            Method = 'POST'
            Resource = $Resource
            QSCollection = $QSCollection
            Body = $organisation
        }
        if ($PSCmdlet.ShouldProcess("Organisation '$($organisation.name)'", 'Create')) {
            $OrganisationCreate = New-NinjaOnePOSTRequest @RequestParams
            if ($show) {
                Return $OrganisationCreate
            } else {
                Write-Information "Organisation '$($OrganisationCreate.name)' created."
            }
        }
    } catch {
        New-NinjaOneError -ErrorRecord $_
    }
}