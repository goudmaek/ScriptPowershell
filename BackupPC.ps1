$PC=get-adgroupmember -identity ag-ordinateursasauvegarder
#write-host $PC
foreach ($computer in $pc) {
$NomOrdinateur=$computer.name
write-host $NomOrdinateur
$path = "\\$nomordinateur\c$\users"
#dir $path
write-host $path
test-path -path  $path
if((test-path -path $path) -eq "$true") {
write-host "accès OK"
}
else {
write-host "Accès NOK"
}

}