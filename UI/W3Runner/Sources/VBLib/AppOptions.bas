Attribute VB_Name = "AppOptionsModule"
Option Explicit

Public g_objAppOptionIniFile As cIniFile

Public Property Get AppOptions(strName As String, Optional ByVal defaultValue As Variant, Optional ByVal strSection = "frmOptions") As String

    Dim s As String
    
    s = g_objAppOptionIniFile.getVar(strSection, strName)
    
    If (Len(s)) Then
    
        AppOptions = s
    Else
        If (IsMissing(defaultValue)) Then
            AppOptions = ""
        Else
            AppOptions = defaultValue
        End If
    End If
End Property

Public Property Let AppOptions(strName As String, Optional ByVal defaultValue As Variant, Optional ByVal strSection = "frmOptions", ByVal v As String)
    
    If UCase$(v) = "TRUE" Or v = "-1" Then v = 1
    If UCase$(v) = "FALSE" Then
    
        'Debug.Assert 0
        v = 0
    End If
    
    g_objAppOptionIniFile.SetVar strSection, strName, v
End Property

Public Function AppOptionsLong(ByVal strName As String, ByVal defaultValue As Long, Optional ByVal strSection = "frmOptions") As Long

    Dim s As String
    
    s = AppOptions(strName, defaultValue, strSection)
    
    AppOptionsLong = IIf(IsNumeric(s), CLng(s), defaultValue)
End Function


