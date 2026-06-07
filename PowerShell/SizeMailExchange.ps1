function Inicializar{

    #Config Variables
    $CSVFilePath = $PSScriptRoot +"\informe_correo.csv"
    return $CSVFilePath
}


try {
  Write-Host(" SCRIPT: devuelve el tamaño de los buzones de Exchange") -f yellow
  $correoAdmin=Read-Host("Se requiere el correo con previlegios de Administrador")
  Connect-ExchangeOnline -UserPrincipalName $correoAdmin
  $FileEmail = @()
  $emaillist=Get-EXOMailbox -ResultSize unlimited

  foreach ($e in $emaillist)
      {
      
      $emailData=Get-EXOMailboxStatistics -Identity $e.UserPrincipalname -Properties TotalItemSize,SystemMessageSizeWarningQuota,DisplayName
    
      if($emailData.TotalItemSize -like "*GB*"){

        $FileEmail+=[PSCustomObject][ordered]@{ 
          name=$e.UserPrincipalname 
          TotalItemSize =$emailData.TotalItemSize
          DisplayName =$emailData.DisplayName 
          SystemMessageSizeWarningQuota=$emailData.SystemMessageSizeWarningQuota
                }
      }
      }
  #Export Files data to CSV File
  $CSVFilePath = Inicializar
  $FileEmail | Sort-object Size -Descending
  $FileEmail | Export-Csv -Path $CSVFilePath -Delimiter ';' -NoTypeInformation
  write-host "`nSe esta creando CSV informe.csv`n" -f Green
  write-host "`nEl informe esta en la misma que el script`n" -f Green

     


}
catch {
  Write-Host "Error!"
  Write-Host "El siguiente error ha ocurrido:" -f Red
  Write-Host $_
  <#Do this if a terminating exception happens#>
}
finally {
  disconnect-Exchangeonline
  <#Do this after the try block regardless of whether an exception occurred or not#>
}
