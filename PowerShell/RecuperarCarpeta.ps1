
Clear-Host
write-host ("ATENCION: Debe ser Administrador")
Pause
# Input Parameters

$siteURL=Read-Host " [Obligatorio] Introduce la ruta del SITIO completa (NO-Biblioteca)"
#usuario que borró el contenido.
$userDelete=Read-Host " [Obligatorio] Introduce el correo del usuario que lo borró "
#fecha que se borró el contenido. Formato americano.
$restoreDate=Read-Host " [Obligatorio] Introduce fecha formato (YYYY-MM-DD)"
#Hora que se borró el contenido..
#$restoreHour=Read-Host " [Opcional] Introduce fecha formato (HH:mm)"
#Usuario creador el fichero.
#$UserCreate=Read-Host "[Opcional] Introduce el correo del usuario que creo el fichero."
#Carpeta del usuario.
$NombreCarpeta=Read-Host "[Opcional] Introduce la carpeta ha recuperar: "
if ($NombreCarpeta -eq ""){ $NombreCarpeta="*"}


###########################################################################################################

# Función API de restauración de los elementos.
function Restore-RecycleBinItem {

    param(

        [Parameter(Mandatory)]

        [String]

        $Id

    )

    $siteUrl = (Get-PnPSite).Url
    # Esta es la URL de la papelera filtrada por Ids
    $apiCall = $siteUrl + "/_api/site/RecycleBin/RestoreByIds"

    $body = "{""ids"":[""$Id""]}"

    Write-Verbose "Performing API Call to Restore item from RecycleBin..."

    try {

        Invoke-PnPSPRestMethod -Method Post -Url $apiCall -Content $body |

        Out-Null

    }

    catch {

        Write-Error "Unable to Restore ID {$Id}" >>logRecuperar.txt

    }

}

# Este Script debe ser ejecutado con permisos de Administrador.
# Script que recupera los elementos borrados por OneDrive.
# Indicando Sitio, Usuario y fecha de borrado.

get-date >>logRecuperar.txt

Write-Output Init >>logRecuperar.txt

$conn = Connect-PnPOnline  -Url $siteURL -Credentials (Get-Credential)



$rbinItems = Get-PnPRecycleBinItem -Connection $conn -RowLimit 15000 | Where-Object {($_.DeletedDate -gt $restoreDate) -and ($_.DeletedByEmail -eq $userDelete) -and ($_.DirName -like $NombreCarpeta)} |Sort-Object DirName, LeafName

# Verificar que haya elementos que restaurar.
if ($rbinItems.Count -gt 0)
{

    $n=0
     # Recorrer los elementos que vamos a restaurar.
    foreach($ritem in $rbinItems)

    {

        $n++

        try {
           # Llamada a la funcion Restore-RecycleBinItem
           Restore-RecycleBinItem -Id $ritem.id  -ErrorVariable $CapturaError
           if ($CapturaError){ Write-Host "Error en restauración nombre: "+$ritem.Title}
           $info ="Se restauró el elmento "+$ritem.Title+" de la carpeta  "+$ritem.DirName 
           Write-Host $info
           $info>>logRecuperar.txt

        } catch {

            write-host "$($n.ToString("0000")) - ERROR AL RESTAURAR '$($ritem.Title)'|ERROR:'$($_.Exception.Message)': $($_.ScriptStackTrace)" -ForegroundColor Red >>logRecuperar.txt

        }

    }

} else

{

    write-host "NO se han encontrado elementos eliminados por el usuario '$($userDelete)' posteriores a la fecha $($restoreDate)" -ForegroundColor Blue >>logRecuperar.txt

}

Write-Output Fin >>logRecuperar.txt

