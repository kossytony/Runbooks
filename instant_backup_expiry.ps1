<#
    .DESCRIPTION
        A runbook which backs up the server periodically using the Run As Account (Service Principal)

    .NOTES
        AUTHOR: Kossy
        LASTEDIT: Oct 13, 2020
#>

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
 
$ExpiryTime = (get-date).addDays(5)

Get-AzRecoveryServicesVault `
    -ResourceGroupName "www.uniprint.net" `
    -Name "vault647" | Set-AzRecoveryServicesVaultContext

$backupcontainer = Get-AzRecoveryServicesBackupContainer `
    -ContainerType "AzureVM" `
    -FriendlyName "up-prod-web"

$item = Get-AzRecoveryServicesBackupItem `
    -Container $backupcontainer `
    -WorkloadType "AzureVM"

Backup-AzRecoveryServicesBackupItem -Item $item -ExpiryDateTimeUTC $ExpiryTime
