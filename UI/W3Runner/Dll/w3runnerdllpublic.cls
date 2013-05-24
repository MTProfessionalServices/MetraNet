VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "DllPublic"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'
' Get the registration key
'
Public Function GetInternalVersion(ByVal strDatabaseLogFileName As String, ByVal v As Variant, K As Variant, LID As Variant, LC As Variant) As Boolean
Attribute GetInternalVersion.VB_MemberFlags = "40"

    Dim objKey  As New CKey
    
    On Error GoTo ErrMgr
    
    objKey.CompanyName = v(0)
    objKey.Address = v(1)
    objKey.City = v(2)
    objKey.Zip = v(3)
    objKey.state = v(4)
    objKey.Country = v(5)
    objKey.email = v(6)
    objKey.KeyDate = v(7)
    objKey.LicenceCounter = v(8)
    
    ' Just to trick a deassembleur
    If v(8 + 1) <> "454FCBB5-BE9C-4957-87B2-17644EE7C732" Then Exit Function
    If v(7 + 2) <> "454FCBB5-BE9C-4957-87B2-17644EE7C732" Then Exit Function
        
    objKey.Create
    
    K = objKey.Key
    LID = objKey.LicenceID
    LC = objKey.LicenceCounter
    
    GetInternalVersion = objKey.Log(strDatabaseLogFileName)
    Exit Function
ErrMgr:
    
End Function



Public Function GetFilesList(ByVal strPath As String, ByVal strWildCard As String, objFiles As Variant) As Boolean

    Dim strDirFullPath As String
    Dim strFileName    As String
    Dim lngFileAttr    As Long
    
    On Error GoTo ErrMgr
    
    strDirFullPath = CheckPath(strPath & "\" & strWildCard)
    
    strFileName = Dir(strDirFullPath, vbArchive)
    Do While strFileName <> ""
    
        If (strFileName <> "." And strFileName <> "..") Then
        
            lngFileAttr = GetAttr(CheckPath(strPath & "\" & strFileName))
            
            If (lngFileAttr And vbDirectory) Or (lngFileAttr And vbVolume) Or (lngFileAttr And vbSystem) Or (lngFileAttr And vbHidden) Then
            
                ' I do not care about this type of file...
            Else
            
                objFiles.Add strFileName, CheckPath(strPath & "\" & strFileName)
            End If
        End If
        strFileName = Dir
    Loop
    GetFilesList = True
    Exit Function
ErrMgr:
    
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : CheckPath
' PARAMETER     :
' DESCRIPTION   :
' RETURN        :
Private Function CheckPath(ByVal strPath As String) As String
    CheckPath = Replace(strPath, "\\", "\")
End Function
