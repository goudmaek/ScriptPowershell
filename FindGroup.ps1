Function Main {
#invite pour introduire le nom d'utilisateur recherché. 
$UserName=Read-host "Introduire le nom d'utilisateur"
CheckAdAccount
}

Function checkAdAccount {
Try{
# test pour vérifier que l'utilisateur existe
$GetAdUser=Get-aduser -identity $UserName -properties *
#si l'utilisateur existe, appel de la fonction listgroup autrement affichage d'un message d'erreur et retour 
#à l'invite pour introduie le nom d'utilisateur. 

if ($GetAdUser -ne $null) {
ListGroup
}
}
catch {
write-host "l'utilisateur n'existe pas" 
main
}
}

Function ListGroup { 
#Récupère les groupes de l'utilisateur et fait une requête Get-ADGroup pour récupérer le nom "user friendly" du groupe. 
#autrement le résultat affiche le chemin de l'objet groupe "cn=blabla,OU=blabla,.."
$Groups = ($getaduser.memberof |Get-AdGroup |Select -ExpandProperty Name) -join " ,"

write-output "$UserName est membre des groupes $Groups"
}

main