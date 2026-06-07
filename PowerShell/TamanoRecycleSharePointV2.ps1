
$ArraySitios ="ARRAY DE TODAS LAS BIBLIOTECAS QUE DEBE MIRAR LA PAPELERA"






try{


#$credencial=Credenciales
$pathFolderSaveReport="<UBICACION DEL FICHERO>"
    
$hola= "Informe de papelera de Sharepoint"
Out-File $pathFolderSaveReport -InputObject $hola

foreach ($s in $ArraySitios)
{
    $SiteURL = "<TENANT>"+$s
    Write-Host $SiteURL
    $RecycleBinSize=0
    Connect-PnPOnline -Url $SiteURL #-Credentials ($credencial)
   
    
    # escribir en fichero el sitio
    Out-File $pathFolderSaveReport -InputObject  $s -Append

    # se indica la hora.

    $fecha=Get-Date -Format "dddd MM/dd/yyyy HH:mm" 
    Out-File $pathFolderSaveReport -InputObject  $fecha -Append


    #Sum Recycle bin Items Size
    $RecycleBinSize = Get-PnPRecycleBinItem -RowLimit 10000 | Measure-Object -Property Size -Sum

    $total=([Math]::Round($RecycleBinSize.Sum/1GB,2))
    $salida="Recycle Bin Size (GB): [Primera]"  +$total
    Out-File $pathFolderSaveReport -InputObject  $salida -Append



    $RecycleBinSize = Get-PnPRecycleBinItem -RowLimit 10000 -SecondStage  | Measure-Object -Property Size -Sum 
    #Get Recycle bin size
    $total=([Math]::Round($RecycleBinSize.Sum/1GB,2))
    $salida="Recycle Bin Size (GB): [Segundo]" +$total
    Out-File $pathFolderSaveReport -InputObject  $salida -Append
    

}
Send-PnPMail -From "CORREO_EMISOR" -To "CORREO_RECEPTOR1","CORREO_RECEPTOR2" -Subject "Informe de papelera" -Body "Informe de papelera" -Attachments $pathFolderSaveReport
}
catch{
 Write-Host "El siguiente error ha ocurrido:" -f Red
   Write-Host $_


}

finally {
    Disconnect-PnPOnline

}




