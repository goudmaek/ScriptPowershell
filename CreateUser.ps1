Add-Type -AssemblyName System.WIndows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
#$FileBrowser.Filter = "Txt (*.txt) | *.txt"
[void]$FileBrowser.ShowDialog()
$FileBrowser.FileName