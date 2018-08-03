<#
.SYNOPSIS
    Get baseurl, access and secret key
#>

param (
       [parameter(Mandatory=$true)]
       [string]$appID,
       [parameter(Mandatory=$true)]
       [string]$appKey
    )


$creds = Get-Credential
$discoverPostBody = @{"data" = ,@{"emailAddress" = $creds.UserName}}
$discoverPostBodyJson = ConvertTo-Json $discoverPostBody
$discoverRequestId = [guid]::NewGuid().guid
$request_date = Get-Date -Format R

$discoverRequestHeaders = @{"x-mc-date" = $request_date; "x-mc-req-id" = $discoverRequestId; "x-mc-app-id" = $appID; "Content-Type" = "application/json"}
$discoveryData = Invoke-RestMethod -Method Post -Headers $discoverRequestHeaders -Body $discoverPostBodyJson -Uri "https://api.mimecast.com/api/login/discover-authentication"
$baseUrl = $discoveryData.data.region.api

"Base URL:" + $baseUrl

$uri = $baseUrl + "/api/login/login"
$requestId = [guid]::NewGuid().guid
$netCred = $creds.GetNetworkCredential()
$PlainPassword = $netCred.Password
$credsBytes = [System.Text.Encoding]::ASCII.GetBytes($creds.UserName + ":" + $PlainPassword)
$creds64 = [System.Convert]::ToBase64String($credsBytes)
$headers = @{"Authorization" = "Basic-Cloud " + $creds64; "x-mc-app-id" = $appID; "x-mc-req-id" = $requestId; "Content-Type" = "application/json"}
$postBody = @{"data" = ,@{"username" = $creds.UserName}}
$postBodyJson = ConvertTo-Json $postBody
$data = Invoke-RestMethod -Method Post -Headers $headers -Body $postBodyJson -Uri $uri
"Access key: " + $data.data.accessKey
"Secret key: " + $data.data.secretKey

#Write it out to a json file
$json = @{"appID" = $appID; "appKey" = $appKey;"baseUrl" = $baseUrl; "accessKey" = $data.data.accessKey; "secreyKey" = $data.data.secretKey}

$json | ConvertTo-Json | Out-File 'configuration.json'