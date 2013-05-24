VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CIECacheEntry"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public URL As String

Public Function Delete(Optional ByVal strWildCard As String, Optional ByVal booTrace As Boolean = True) As Boolean

    If Len(strWildCard) Then
    
        If URL Like strWildCard Then
        
            GoSub DeleteURL
        End If
    Else
        GoSub DeleteURL
    End If
    Delete = True
    Exit Function
    
DeleteURL:
    #If W3RUNNER_DEFINE Then
        If booTrace Then
            frmMain.TRACE PreProcess("W3Runner.IECache.DeleteFile ""[URL]""", "URL", URL), w3rMETHOD
        End If
    #End If
    DeleteUrlCacheEntry URL
Return
    
End Function

Public Function ToString() As String
    ToString = URL
End Function

Public Function IsCookie() As Boolean
    IsCookie = InStr(URL, "cookie")
End Function
