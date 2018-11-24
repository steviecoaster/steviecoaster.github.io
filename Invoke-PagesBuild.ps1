<#
    .SYNOPSIS
    Sends a request to the Github Pages API to trigger a Pages build for the repository.
    .DESCRIPTION
    Uses Invoke-WebRequest method to send a POST request to the Github Pages API. This request is directed at the repository
    API URL, and requires an OAuth token with appropriate permissions to be specified in order for the request to be
    accepted by the API.
    .PARAMETER Token
    Specify the OAuth API Token with which to query the Github API. If a token is not provided, or the provided token does
    not have sufficient permissions, the request will typically respond with a 404 error for any non-publicly-available
    information, such as Pages build statuses and build requests.
    .PARAMETER Username
    Specify the username of the github account the pages repo is attached to.
    .PARAMETER Repository
    Specify the repository name as it appears in the Github URL.
    .EXAMPLE
    Invoke-PagesBuild.ps1 -Token $ApiToken -Username 'GithubUser' -Repository 'GithubUser.github.io'
    .NOTES
    A 404 response may be **either** a malformed URI, caused by specifying the wrong username or repository name,
    **OR** it can also be a rejected token. Github's API opts to send a 404 response rather than a flat out rejection if the
    authentication token is rejected.
    .LINK
    https://developer.github.com/v3/repos/pages/
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory)]
    [Alias('ApiKey','ApiToken','AuthToken')]
    [ValidateNotNullOrEmpty()]
    [string]
    $Token,

    [Parameter(Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Username = $env:SYSTEM_TEAMPROJECT -replace '\..+$',

    [Parameter(Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Repository = $env:SYSTEM_TEAMPROJECT
)

Write-Host "Building API parameters" -ForegroundColor Blue
$ApiParams = @{
    Uri     = "https://api.github.com/repos/$Username/$Repository/pages/builds"
    Method  = 'POST'
    Headers = @{
        Authorization = 'token {0}' -f $Token
        Accept        = 'application/vnd.github.mister-fantastic-preview+json'
    }
}
'Query URI: {0}' -f $ApiParams['Uri'] | Write-Host -ForegroundColor Blue
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "Querying Github..." -ForegroundColor Blue
Invoke-RestMethod @ApiParams


#region Update TwitterTitle variable for the tweet.
Write-Host "Setting Current Date" -ForegroundColor Blue
$Date = Get-Date -Format yyyy-MM-dd
Write-Host "Date is $Date" -ForegroundColor Blue
Write-Host (Get-ChildItem | Select -Expand Basename) -ForegroundColor Green

Write-Host "$PSScriptRoot" -ForegroundColor Green
$BlogPostFile = Get-ChildItem -Path $PSScriptRoot\_posts |
                Where-Object {$_.Name -match "$Date"} |
                Select-Object -ExpandProperty Name

$BlogPostFile -match "\d-([a-z-!]+)\.md"

$UrlEnding = $matches[1]

Write-Host "##vso[task.setvariable variable=BlogPostTitle]$UrlEnding"

Function New-ShortUri {
    <#
    .SYNOPSIS
    Generate tiny url from a web link
    .DESCRIPTION
    Take a long, unseemly URI from online, and turn it into a short link for distribution or social media
    .PARAMETER Uri
    The long URI you wish to shorten
    .EXAMPLE
    New-ShortUri -Uri https://www.superlongdomainname/with/weird/page/links.htm
    
    #>

    [cmdletBinding(HelpUri ='https://github.com/steviecoaster/PSSysadminToolkit/blob/Dev/Help/New-ShortUri.md')]
    [Alias('ShortUri')]
    Param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [String]
        $Uri
 
    )

    Process {

        

        $ShortUri = Invoke-WebRequest -Uri "https://tinyurl.com/api-create.php?url=$Uri" | Select-Object -ExpandProperty Content

        

        $UriObject = [pscustomobject]@{

            LongUri  = $Uri
            ShortUri = $ShortUri
        }

        $UriObject

    }

}

$BlogUrl = "https://steviecoaster.github.io/$UrlEnding"

$ShortLink = New-ShortUri -Uri $BlogUrl  | Select -Expand ShortUri
Write-Host "##vso[task.setvariable variable=BlogUrl]$ShortLink"