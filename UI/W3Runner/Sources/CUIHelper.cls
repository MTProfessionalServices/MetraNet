VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CUIHelper"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 02/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Private m_objProcesses As CProcesses

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Processes() As CProcesses

    If Not IsValidObject(m_objProcesses) Then
    
        Set m_objProcesses = New CProcesses
    End If
    Set Processes = m_objProcesses
End Property

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function GetHTMLObjectName(ByVal o As Object) As String

    Dim strOName            As String
    Dim objTextFile         As New cTextFile
    Dim strUCaseTypeName    As String
    
    strUCaseTypeName = UCase$(TypeName(o))
    
    'Debug.Print TypeName(o)

    If (IsW3RunnerHTMLObjectSupported(o)) Then
    
        strOName = GetHTMLObjectProperty(o, "name")
        If Len(strOName) = 0 Then
        
            strOName = GetHTMLObjectProperty(o, "id") ' Get the alternate if the name is not defined
        End If
        If Len(strOName) = 0 Then strOName = GetHTMLObjectProperty(o, "alt") ' Get the alternate if the name is not defined
        
        If Len(strOName) = 0 Then
        
            If (strUCaseTypeName = "HTMLOBJECTELEMENT") Then
            
                strOName = GetHTMLObjectProperty(o, "Code")    ' For applet
                If Len(strOName) = 0 Then strOName = GetHTMLObjectProperty(o, "ClassId") ' For applet
            End If
        
            If (strUCaseTypeName = "HTMLIMG") Then
            
                strOName = GetHTMLObjectProperty(o, "SRC") ' Get the alternate if the name is not defined
                strOName = objTextFile.GetFileName(strOName, "/")
            End If
            
            If (strUCaseTypeName = "HTMLBUTTONELEMENT") Then
            
                strOName = GetHTMLObjectProperty(o, "InnerText") ' Get the alternate if the name is not defined
            End If
        
            If (strUCaseTypeName = "HTMLINPUTELEMENT") Then
            
                strOName = GetHTMLObjectProperty(o, "Value") ' Get the alternate if the name is not defined
            End If
            
            If (strUCaseTypeName = "HTMLANCHORELEMENT") Then
            
                strOName = GetHTMLObjectProperty(o, "InnerText") ' Get the alternate if the name is not defined
            End If

            '
            ' Becare full because this function is call at record time and run time.
            ' Recording TD or DIV with no name is some time a problem so we make this case optional
            '
            If (strUCaseTypeName = "HTMLTABLECELL") Then
            
                If (frmMain.RecordMode) And (Not CBool(AppOptions("RecordHTMLTagTDWithNoName", False))) Then
                    'Debug.Assert 0
                    Exit Function
                End If
                strOName = GetHTMLObjectProperty(o, "InnerText") ' Get the alternate if the name is not defined
            End If
            
            If (strUCaseTypeName = "HTMLDIVELEMENT") Then
            
                If (frmMain.RecordMode) And (Not CBool(AppOptions("RecordHTMLTagDIVWithNoName", False))) Then
                    'Debug.Assert 0
                    Exit Function
                End If
                strOName = GetHTMLObjectProperty(o, "InnerText") ' Get the alternate if the name is not defined
            End If
            
        End If
        GetHTMLObjectName = strOName
    End If
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function GetHTMLObjectProperty(ByVal o As Object, ByVal strPropertyName As String) As Variant

    Dim varValue As Variant
    On Error Resume Next
    
    varValue = CallByName(o, strPropertyName, VbGet)
    If IsNull(varValue) Then
        varValue = Empty
    End If
    GetHTMLObjectProperty = varValue
    
    If (Err.Number) Then
        GetHTMLObjectProperty = Empty 'PreProcess(W3RUNNER_ERROR_07009, "PROPERTY", strPropertyName, "OBJECT_TYPE", TypeName(o))
    End If
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   : NOT DOCUMENTED - ' -- For compatibility reason
' RETURN        :
Public Function Execute(ByVal strPrg As String, ByVal strParam As String, Optional booSynchronousMode As Boolean = True, Optional ByVal eShowMode As VbAppWinStyle = vbNormalFocus) As Boolean

    Dim objTool As New cTool
    
    On Error GoTo errmgr
    
    frmMain.TRACE PreProcess("Page.Helper.Execute([DC][PRG][DC],[DC][PARAM][DC],[EXECMODE],[SHOWMODE])", "DC", """", "PRG", strPrg, "PARAM", strParam, "EXECMODE", booSynchronousMode, "SHOWMODE", eShowMode), w3rMETHOD
    
    If booSynchronousMode Then
        Execute = objTool.execPrgSyncrone(strPrg, strParam, eShowMode)
    Else
        Shell strPrg & " " & strParam, eShowMode
        Execute = True
    End If
    Exit Function
errmgr:

End Function

' -- For compatibility reason --
Public Function GMTNow(Optional ByVal strDateSeparator As String = "/", Optional ByVal strTimeSeparator As String = ":") As Variant

    GMTNow = g_objW3RunnerObject.GMTNow(strDateSeparator, strTimeSeparator)
End Function

' -- For compatibility reason
Public Function PreProcess(ByVal strMessage As String, ParamArray defines() As Variant) As String

    Dim i As Long
    For i = 0 To UBound(defines()) Step 2
        strMessage = Replace(strMessage, "[" & defines(i) & "]", CStr(defines(i + 1)))
    Next
    PreProcess = strMessage
End Function
