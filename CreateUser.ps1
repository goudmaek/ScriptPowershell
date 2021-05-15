
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
$Email="SMTP:"+$i.email
$Alias1=$i.alias1
$Alias2=$i.alias2
$Alias3=$i.alias3
$Alias4=$i.alias4
$ProxyAddresses= $Email
if ($ALias1 -ne "") { $ProxyAddresses+= ' '+','+"smtp:"+"$Alias1" }
if ($ALias2 -ne "") { $ProxyAddresses+= ' '+','+"smtp:"+"$Alias2" }
if ($ALias3 -ne "") { $ProxyAddresses+= ' '+','+"smtp:"+"$Alias3" }
if ($ALias4 -ne "") { $ProxyAddresses+= ' '+','+"smtp:"+"$Alias4" }
$global:proxyaddresses=@($ProxyAddresses)
}

Function UPN {
#crée le paramètre UserPrincipalName sur base de l'émail de l'employé
$Domain = $null
if ($i.email -ne "" ) 
    { $domain = "acme.fr"}
    else {$:domain = "acme.local"}
       
$Global:UserPrincipalName=$SamaccountName+"@"+$DOMAIN 
}

Function AddGroup {
#Ajoute l'utilisateur au groupe principal de son département. 
$Service=$i.Département
switch  ($service)
    {
    "Direction Générale" { $Group ="AG-DirectionGenerale"}
    "Direction Marketing" {$Group = "AG-DirectionMarketing"}
    "Direction Technique" { $Group = "AG-DirectionTechnique" }
    "Direction Financière" { $Group = "AG-DirectionFinanciere"}
    "Ressources Humaines" { $Group = "AG-RessourcesHumaines"}
    }
    Add-ADGroupmember -identity $Group -Members $SamaccountName
    write-output "Ajout du compte $SamAccountName de $DisplayName dans le groupe $Group"
}
    

Function CreateAdAccount {
#creation du compte utilisateur
$password= ConvertTo-SecureString -String Pwd2021+ -AsPlainText -Force
try {
New-aduser -SamAccountName $samaccountName -UserPrincipalName $global:userprincipalName -path $path -GivenName $GivenName -SurName $LastName -Name $DisplayName -DisplayName $DisplayName `
-title $title -EmailAddress $i.email -ChangePasswordAtLogon $true -Enabled $true -AccountPassword $password `
 -city $i.site -Company $i.domaine -Country FR  -Department $department -MobilePhone $i.Mobile -OfficePhone $i.Téléphone -office $i.site `
  -OtherAttributes @{'proxyaddresses'=$global:proxyaddresses} -ErrorAction stop 
  write-Output "Compte -$DisplayName avec le login $SamAccountName  et le mot de passe $password créé"

}
catch {
    #en cas d'erreur, on vérifie si le compte existe déjà. 
    $CheckAccount=get-aduser -identity $samaccountname 
    if ($CheckAccount -ne $null){
    write-output "Le compte $samaccountname existe dans l'AD"
    break
    }
    }
}

function CreateFolder {
    $server="lab-dc01.labo.local"
    $SharedFolder="Homes"
    $Global:SharesPath="\\$server" + "\$SharedFolder" + "\$SamAccountName"
    write-host $SamAccountName and $SharesPath
    $TestFolder=test-path $SharesPath
    if($TestFolder -eq $false) {
    New-item -path $sharesPath -ItemType directory
    write-Output "Création du dossier personnel $SamAccountName de $DisplayName"
    
    }
    else { 
        write-host "le dossier existe"
        }
}

function SetAcl {
    $ACL = Get-ACL -Path $Global:SharesPath
    $identity = $SamAccountName
    $filesystemRights = "Modify","delete","DeleteSubdirectoriesAndFiles"
    $type = "allow"
    $filesystemAccessRuleArgumentList = $identity, $filesystemRights, $type
    $filesystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $filesystemAccessRuleArgumentList 
    $Acl.SetAccessRule($filesystemAccessRule)
    set-acl -path "$sharespath" -AclObject $ACL
    }


start-transcript -path "c:\temp\$(get-date -f yy-mm-dd)-CreateUser.txt"
$Source=SelectFichierSource

#Import du fichier sources et boucle sur le contenu du tableau et on assigne les colonnes aux variables qui seront utilisées. 
$table=import-csv $Source -Encoding "utf8" -delimiter ";"

foreach ($i in $table) {
$GivenName= $i.prénom
$LastName = $i.Nom
$DisplayName =$GivenName +' '+ $LastName 
#Le nom d'utilisateur est généré sur base du Prénom et du nom. Seule la 1ère lettre du prénom est utilisée
#pour créer le nom d'utilisateur
$SamAccountName = ("$GivenName").Substring(0,1)+$LastName
$title=$i.Fonction
$Department= $i.Département
$site= $i.Site
$path= "OU=$Department,OU=$site,DC=LABO,DC=LOCAL"



UPN
AliasMail
CreateAdAccount
AddGroup
CreateFolder
setacl
 }
Stop-Transcript