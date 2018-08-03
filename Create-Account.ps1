#Setup required variables
$uri = "/api/account/get-account"

$parameters = Get-Content -Raw -Path configuration.json | ConvertFrom-Json

$url = $parameters.baseUrl + $uri
$accessKey = $parameters.accessKey
$secretKey = $parameters.secreyKey
$appId = $parameters.appID
$appKey = $parameters.appKey


#Generate request header values
$hdrDate = (Get-Date).ToUniversalTime().ToString("ddd, dd MMM yyyy HH:mm:ss UTC")
$requestId = [guid]::NewGuid().guid


#Create the HMAC SHA1 of the Base64 decoded secret key for the Authorization header
$sha = New-Object System.Security.Cryptography.HMACSHA1
$sha.key = [Convert]::FromBase64String($secretKey)
$sig = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($hdrDate + ":" + $requestId + ":" + $uri + ":" + $appKey))
$sig = [Convert]::ToBase64String($sig)


#Create Headers
$headers = @{"Authorization" = "MC " + $accessKey + ":" + $sig;
                "x-mc-date" = $hdrDate;
                "x-mc-app-id" = $appId;
                "x-mc-req-id" = $requestId;
                "Content-Type" = "application/json"}


#Create post body
$postBody = "{
                    ""data"": [
                        {
                            ""accountName"": ""String"",
                            ""addressLine1"": ""String"",
                            ""country"": ""String"",
                            ""city"": ""String"",
                            ""state"": ""String"",
                            ""postalCode"": ""String"",
                            ""companyRegistrationNumber"": ""String"",
                            ""contactEmail"": ""String"",
                            ""contactName"": ""String"",
                            ""telephone"": ""String"",
                            ""numberOfUsers"": 10,
                            ""adminPassword"": ""String"",
                            ""forcePasswordChange"": False,
                            ""mailPlatform"": ""String"",
                            ""maximumRetention"": 30,
                            ""umbrellaAccounts"": [
                                ""String""
                            ],
                            ""products"": [
                                9702
                            ]
                        }
                    ]
                }"


#Send Request
$response = Invoke-RestMethod -Method Post -Headers $headers -Body $postBody -Uri $url


#Print the response
$response.data