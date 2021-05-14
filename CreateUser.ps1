$errorLogs = "c:\temp\%date% +CreateUser.log"


function SelectFichierSource {
#fonction qui Ouvre l'explorateur windows pour permettre à l'utilisateur de sélectionner le fichier source.
Write-host "Sélectionnez le fichier qui contient les paramètres utilisateur."
Add-Type -AssemblyName System.WIndows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.Filter = "CSV (*.csv) | *.csv"
[void]$FileBrowser.ShowDialog()
$FileBrowser.FileName}

function AliasMail {
#Vérifie si l'utilisateur à des alias mail et construit la variable $Global:Proxyaddresses qui sera utilisée pendant la création du compte
$Alias1=$i.alias1
$Alias2=$i.alias2
$Alias3=$i.alias3
$Alias4=$i.alias4
$hash=@( $Alias1 , $Alias2 , $Alias3 , $Alias4)
$AliasMail = $hash |where{$_ -ne ""} 
$global:proxyaddresses=$AliasMail -join ','
}
Function UPN {
#crée le paramètre UserPrincipalName sur base de l'émail de l'employé
$Domain = $null
if ($i.email -ne "" ) 
    { $domain = $i.email}
    else {$:domain = "acme.local"}
    
$Global:UserPrincipalName=$SamaccountName+"@"+$DOMAIN
}


$Source=open-file

#Import du fichier sources et boucle sur le contenu du tableau et on assigne les colonnes aux variables qui seront utilisées. 
$table=import-csv $Source -Encoding "utf8" -delimiter ";"

foreach ($i in $table) {
$GivenName= $i.prénom
$LastName = $i.Nom
$DisplayName = $GivenName +' '+ $LastName
#Le nom d'utilisateur est généré sur base du Prénom et du nom. Seule la 1ère lettre du prénom est utilisée
#pour créer le nom d'utilisateur
$SamAccountName = ("$GivenName").Substring(0,1)+$LastName


UPN
AliasMail
write-host $LastName $global:UserPrincipalName $global:proxyaddresses


}
