<#
  .SYNOPSIS
  Will create a new immutable Storage Account and Blob Container in Azure.

  .PARAMETER ResourceGroup
  The Name of the exitsing Resource Group

  .PARAMETER StorageAccount
  The Name to give the new Storage Account

  .PARAMETER Container
  The Name to give the new Container

  .PARAMETER Location
  (Optional) The Azure Region; defaults to East US

  .LINK
  https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-immutable-storage#getting-started

  .NOTES
  Requires current version of Az PoSh module --
  Install-Module -Name Az -AllowClobber -Scope CurrentUser
  https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-2.5.0

  .EXAMPLE
  .\create-consentstorage.ps1 -ResourceGroupName {{ resourceGroupName }} -StorageAccountName {{ storageAccountName }} -ContainerName {{ containerName }} -AzureSubscriptionId {{ subscriptionId }}
#>

param(
  [Parameter(Mandatory = $true)]
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true)]
  [string]$StorageAccountName,
  [Parameter(Mandatory = $true)]
  [string]$ContainerName,
  [Parameter(Mandatory = $true)]
  [string]$AzureSubscriptionId,
  [Parameter(Mandatory = $false)]
  [string]$Location = "East US"
)

$ResourceGroup = $null
$StorageAccount = $null
$StorageContainer = $null
$LegalHoldTag = "Created"


#  Log in to Azure Resource Manager interactively
Connect-AzAccount

Set-AzContext -Subscription $AzureSubscriptionId

Register-AzResourceProvider -ProviderNamespace "Microsoft.Storage"

Write-Host -ForegroundColor Yellow "Verifying Resource Group $ResourceGroupName...`n`n"

# Verify existence of requested Resource Group 
try {
  $ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
  if (!$ResourceGroup) { throw }
}
catch {
  Write-Host -ForegroundColor Red "Could not verify existence of Resource Group $ResourceGroupName."
  return
}

Write-Host $ResourceGroup`n`n

Write-Host -ForegroundColor Yellow "Creating new Storage Account $StorageAccountName...`n`n"

# Create the Storage Account
New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
  -Name $StorageAccountName `
  -SkuName Standard_LRS `
  -Location $Location `
  -Kind StorageV2

# Verify creation of new Storage Account
try {
  $StorageAccount = Get-AzStorageAccount -StorageAccountName $StorageAccountName `
    -ResourceGroupName $ResourceGroupName
  if (!$StorageAccount) { throw }
}
catch {
  Write-Host -ForegroundColor Red "Could not verify creation of Storage Account $StorageAccountName."
  return
}

Write-Host -ForegroundColor Yellow "Creating new Storage Container $ContainerName...`n`n"

# Get the IStorageContext for the new Container
$AzStorageKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName `
    -Name $StorageAccountName).Value[0]

$AzStorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName `
  -StorageAccountKey $AzStorageKey

# Create the Storage Container
New-AzStorageContainer -Name $ContainerName `
  -Context $AzStorageContext `
  -Permission Blob

# Verify creation of Storage Container
try {
  $StorageContainer = Get-AzRmStorageContainer -Name $ContainerName `
    -StorageAccountName $StorageAccountName `
    -ResourceGroupName $ResourceGroupName
  if (!$StorageContainer) { throw }
}
catch {
  Write-Host -ForegroundColor Red "Could not verify creation of Storage Container $ContainerName."
  return;
}

Write-Host -ForegroundColor Yellow "Adding Legal Hold Policy $LegalHoldTag`nto Storage Container $ContainerName...`n`n"

# Lock the container with a legal hold
Add-AzRmStorageContainerLegalHold -Container $StorageContainer `
-Tag $LegalHoldTag

Write-Host '(¯`·._.·(¯`·._.· BOOMSHAKALAKA ·._.·´¯)·._.·´¯)'
Write-Host "`n`n"