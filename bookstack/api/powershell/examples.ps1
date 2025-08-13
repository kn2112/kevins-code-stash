# BookStack API: auth header builder
param($Base, $TokenId, $TokenSecret)
$Headers = @{ Authorization = "Token $TokenId:$TokenSecret"; "Content-Type"="application/json" }

# Smoke tests
Invoke-RestMethod -Method GET -Uri "$Base/api/shelves" -Headers $Headers

# Create & delete throwaway book
$body = @{ name="Playground"; description="Temp" } | ConvertTo-Json
$test = Invoke-RestMethod -Method POST -Uri "$Base/api/books" -Headers $Headers -Body $body
Invoke-RestMethod -Method DELETE -Uri "$Base/api/books/$($test.id)" -Headers $Headers
