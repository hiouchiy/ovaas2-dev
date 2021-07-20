# Input bindings are passed in via param block.
param([string] $QueueItem, $TriggerMetadata)

$WORKSPACE_NAME,$STORAGE_ACCOUNT_NAME,$AZURE_FUNCTIONS_NAME = $QueueItem.Split(",")
Write-Host "PowerShell queue trigger function processed work item: $WORKSPACE_NAME,$STORAGE_ACCOUNT_NAME,$AZURE_FUNCTIONS_NAME"

$appId = $env:AZURE_SP_APP_ID
$secret = $env:AZURE_SP_PASSWORD
$tenantId = $env:AZURE_SP_TENANT
$securedSecret = ConvertTo-SecureString $secret -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential($appId, $securedSecret)
Connect-AzAccount -ServicePrincipal -Tenant $tenantId -Credential $creds

$ResourceGroupName = $WORKSPACE_NAME
$StorageAccountName = $STORAGE_ACCOUNT_NAME
$Region = "japaneast"
$AzureFunctionsName = $AZURE_FUNCTIONS_NAME
New-AzResourceGroup -Name $ResourceGroupName -Location $Region

New-AzStorageAccount `
    -ResourceGroupName $ResourceGroupName `
    -Name $StorageAccountName `
    -SkuName Standard_LRS `
    -Location $Region

New-AzFunctionApp `
    -Name $AzureFunctionsName `
    -ResourceGroupName $ResourceGroupName `
    -StorageAccount $StorageAccountName `
    -FunctionsVersion 3 `
    -RuntimeVersion 3.8 `
    -Runtime python `
    -Location $Region

$uri = "http://localhost:7072/api/HttpTriggerUpdateWorkspaceInfo"
$header = @{
    #"Content-Type" = "application/json"
}
$body = @{
    "workspace"="aaaaaa";
    "storageaccount" ="strageA";
    "azurefunc"="funcA";
    "user"="userA"
}
$response = Invoke-WebRequest -Method "POST" -Uri $uri -Headers $header -Body ($body|ConvertTo-Json) -ContentType 'application/json'
Write-host ("{0} : {1}" -f $response.StatusCode, $response.content)

# Write out the queue message and insertion time to the information log.
Write-Host "PowerShell queue trigger function processed work item: $QueueItem"
Write-Host "Queue item insertion time: $($TriggerMetadata.InsertionTime)"
