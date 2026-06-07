clear-host
function listaUnica
{

}
#Config Variables
write-host "Script para el cambio de versionado de ficheros."
write-Host " Por favor, introduzca el nombre del sitio"



# $ListName ="PROYECTOS"

try{
    #Connect to PnP Online
    $SiteURL=Read-Host " Sitio "
    $credenciales = Get-Credential
    Connect-PnPOnline -Url $SiteURL -Credentials ($credenciales)
    
    $opcionLista=Read-Host("¿ quiere aplicar a todas las librerias (T) o solo a una (1)")
    switch ( $opcionLista )
    {

        1 {   listaUnica(1)  }
    }
    

    #Get List
    $List = Get-PnPList $ListName
    
    If($List)
    { 
        #sharepoint online enable versioning powershell
        Set-PnPList -Identity $ListName -EnableVersioning $True -MajorVersions 20
    }
}
catch{
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
} 