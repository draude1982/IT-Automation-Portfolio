# Conéctate a Azure AD
Connect-AzureAD

# Obtén el listado de todos los usuarios
$users = Get-AzureADUser -All $true | Where-Object { $_.UserPrincipalName -like "*DOMINIO" }

 # Prepara una lista donde almacenaremos los resultados
$MFAStatus = @()

foreach ($user in $users) {
    #$authMethods = Get-MsolUser -UserPrincipalName $user.UserPrincipalName | Select-Object -ExpandProperty StrongAuthenticationMethods
    #$MFAEnabled = if ($authMethods.Count -gt 0) { "Habilitado" } else { "Deshabilitado" }
    $authMethods = Get-MgUserAuthenticationMethod -UserId $user.ObjectId
    $MFAEnabled = if ($authMethods.Count -gt 0) { "Habilitado" } else { "Deshabilitado" }

    $MFAStatus += [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        id_usuario=$user.Id
        DisplayName = $user.DisplayName
        MFAStatus = $MFAEnabled
    }
} 

# Exportar a CSV solo los usuarios con dominio "abc.com"
$MFAStatus | Export-Csv -Path "UBICACION FICHERO CSV" -NoTypeInformation
