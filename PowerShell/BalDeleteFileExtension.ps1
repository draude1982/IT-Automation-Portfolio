# Search and delete file by extension by Zone

function Datos {
    
    # Add site to revise, this script is for MTBTDM/Balears
    $Sitio="MTBTDM"
    $SiteURL="https://iplangestion.sharepoint.com/sites/"+$Sitio
    return $SiteURL
}


function AlgunasLibrerias(){
    
    $tempo=@()
    
    #Indicate Libraries specific
    $ArrayLibrerias ="BAL ET","BAL OA","BAL EXP","BAL OTROS"
    #Indicate file extension to delete
    $extensionFichero="*.dwl"
    
    
    foreach ($Libreria in $ArrayLibrerias)
    {
        #Collect Files Object with pararmenters
        $Files = Find-PnPFile -List $Libreria -Match $extensionFichero
        #Collect data from each files
        $tempo=BusquedaFiles($Files)
        $FileData=$FileData+$tempo
    }
    
    return $FileData
}

function BusquedaFiles([Object] $Files)
    {
        $FileData = @()
        ForEach ($File in $Files) 
                    {
            Write-Host($File.ServerRelativeURL)
            $FileData += [PSCustomObject][ordered]@{
            FileName        = $File.Name
            URL              = $File.ServerRelativeURL
            }
        
        #Write-Host ("Deleting File: '{0}' at '{1}'" -f $File.Name, $File.ServerRelativeURL)
        Remove-PnPFile -ServerRelativeUrl $File.ServerRelativeURL -Force -Recycle |Out-Null
        
    }
    return $FileData
}
    




try {
    
    clear-host
    $FileData = @()
    Write-Host ("¡ Atención! Este scritp borra todos los ficheros con la extensión especificada.`n") -f Red
    
     #Get SiteURL Sharepoint.
     $SiteURL=Datos
     
     #Connect to PnP Online
    Connect-PnPOnline -Url $SiteUrl 

    $FileData=AlgunasLibrerias

  
    
     #Create a informe
     $date=get-date -Format "ddMMyyyy_HHmm_"
     $CSVFilePath = $PSScriptRoot +"\"+$date+"informe.csv"
    
    $FileData| Sort-object Size -Descending
    $FileData | Export-Csv -Path $CSVFilePath  -Delimiter ';' -NoTypeInformation
    write-host "`nSe esta creando CSV informe.csv`n" -f Green
    

}
catch {
    Write-Host "El siguiente error ha ocurrido:" -f Red
   Write-Host $_
}