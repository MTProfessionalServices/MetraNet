Attribute VB_Name = "modErrLog"
'**************************************************
'© 2005 by MetraTech Corp.
'
'Author: Michael Ross
'MSIXDEF parsing by Simon Morton
'Last Update: 08-08-05
'
'Sorry, no time to comment this code yet...
'**************************************************

Option Explicit

Public Sub subErrLog(ByVal strSource As String, Optional pError As String, Optional strData As String)

   If Err.Number = 0 Then Exit Sub

   Dim strErrLog As String
   Dim strErrNum As String, strErrDes As String
   Dim intF As Integer

   strErrNum = Err.Number          'This is necessary, otherwise
   strErrDes = Err.Description     'ErrorLogExit will be tripped
   
'   MsgBox strSource + " " + Str(Err.Number) + vbNewLine + Err.Description
   
On Error GoTo ErrorLogExit
    
    strErrLog = App.Path + "\QuickConfig.log"
    
'   Log entry ***************************************************
    intF = FreeFile
    Open strErrLog For Append Access Write As #intF
            
        Print #intF, Str$(Now)
        
        If LenB(form2.txTemplate) > 0 Then
            Print #intF, "Template: " + form2.txTemplate
        End If
        
        If LenB(form2.txConfig) > 0 Then
            Print #intF, "Generated: " + form2.txConfig
        Else
            If Len(GetSetting("QuickConfig", "Settings", "LastTempDir")) > 0 Then
               form2.txConfig = GetSetting("QuickConfig", "Settings", "LastTempDir") + "MeterConfig.xml"
            Else
               form2.txConfig = App.Path + "\MeterConfig.xml"
            End If
        End If
       
        If LenB(form2.txParentService) > 0 Then
            Print #intF, "Parent: " + form2.txParentService
        End If
        
        If LenB(form2.txChildServices) > 0 Then
            Dim tc As Integer
            For tc = 0 To form2.txChildServices.ListCount - 1
               Print #intF, "Child: " + form2.txChildServices.List(tc)
            Next
        End If
        
        If LenB(strErrNum) > 0 Then
            Print #intF, "Error Number: " + strErrNum
        End If
                
        If LenB(strSource) > 0 Then
            Print #intF, "Source: " + strSource
        End If
        
        If LenB(strErrDes) > 0 Then
            Print #intF, "Description: " + strErrDes
        End If
        
        If LenB(pError) > 0 Then
            Print #intF, "Parsing Error Details: " + pError
        End If
        
        If LenB(strData) > 0 Then
            Print #intF, "Node Data: " + strData
        End If
        
        Print #intF, ""
               
    Close #intF
'   *************************************************************
    
ErrorLogExit:
        
End Sub


