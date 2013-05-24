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

Public Sub subErrLog(ByVal strSource As String, Optional pError As String)

   If Err.Number = 0 Then Exit Sub

   Dim strErrLog As String
   Dim strErrNum As String, strErrDes As String
   Dim intF As Integer

   strErrNum = Err.Number          'This is necessary, otherwise
   strErrDes = Err.Description     'ErrorLogExit will be tripped
   
On Error GoTo ErrorLogExit
    
    strErrLog = App.Path + "\msix2sql.log"
    
'   Log entry ***************************************************
    intF = FreeFile
    Open strErrLog For Append Access Write As #intF
            
        Print #intF, Str$(Now)
        
        If LenB(servname) > 0 Then
            Print #intF, servname
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
        
        Print #intF, ""
               
    Close #intF
'   *************************************************************
    
ErrorLogExit:
        
End Sub


