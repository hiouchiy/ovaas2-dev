# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Login Azure with service principal
$appId = $env:AZURE_SP_APP_ID
$secret = $env:AZURE_SP_PASSWORD
$tenantId = $env:AZURE_SP_TENANT
$securedSecret = ConvertTo-SecureString $secret -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential($appId, $securedSecret)
Connect-AzAccount -ServicePrincipal -Tenant $tenantId -Credential $creds

# Check if resource group is already exist. If not, create new resource group
Get-AzResourceGroup -Name $env:ACI_RESOURCE_GROUP_NAME -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent)
{
    New-AzResourceGroup -Name $env:ACI_RESOURCE_GROUP_NAME -Location japaneast
}

# Check if azure container group is already exist. 
# If exist, check if it is terminated. If terminated, Start the container group. 
# If not, create new container group. 
Get-AzContainerGroup -Name $env:ACI_CONTAINER_GROUP_NAME -ResourceGroupName $env:ACI_RESOURCE_GROUP_NAME -ErrorVariable notPresentAci -ErrorAction SilentlyContinue
if ($notPresentAci)
{
    $ACISTATE = Get-AzContainerGroup -Name $env:ACI_CONTAINER_GROUP_NAME -ResourceGroupName $env:ACI_RESOURCE_GROUP_NAME | Select-Object ProvisioningState,State
    if (($ACISTATE.ProvisioningState -eq "Succeeded") -And ($ACISTATE.State -eq "Succeeded"))
    {
        # Invoke-AzResourceActionでコンテナを起動する。-ResourceGroupNameにはコンテナを作成したリソースグループ、
        # -ResourceNameにはコンテナ名を指定する。
        Invoke-AzResourceAction -ResourceGroupName $env:ACI_RESOURCE_GROUP_NAME -ResourceName $env:ACI_CONTAINER_GROUP_NAME -Action Start -ResourceType Microsoft.ContainerInstance/containerGroups -Force -ApiVersion "2019-12-01"
    }
} else {
    New-AzContainerGroup -ResourceGroupName $env:ACI_RESOURCE_GROUP_NAME -Name $env:ACI_CONTAINER_GROUP_NAME `
        -Image mcr.microsoft.com/azure-cli/tools -OsType Linux `
        -IpAddressType Public `
        -Command "/bin/bash -c ""az login --service-principal --username $env:AZURE_SP_APP_ID --password $env:AZURE_SP_PASSWORD --tenant $env:AZURE_SP_TENANT && cd && git clone https://github.com/hiouchiy/ovaas2-dev.git && cd ovaas2-dev/BE/aci && source DeploySourceCode.sh && cd""" `
        -RestartPolicy OnFailure
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
