'*******************************************************************************
'* Copyright 2005 by MetraTech Corporation
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corporation MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corporation,
'* and USER agrees to preserve the same.
'*
'* Name:        Test.vbs
'* Created By:  Simon Morton
'* Description: Test program for the Common.vbs
'*******************************************************************************

Option Explicit

'*******************************************************************************
'*** Include file processing (do not change)
'*******************************************************************************
Function Include(sIncFileName)
  Dim sCustActData
  Dim sIncFilePath

  On Error Resume Next
  sCustActData = Session.Property("CustomActionData")
  If err.Number <> 0 Then
    On Error Goto 0
    Dim oWsh, oEnv
    Set oWsh = CreateObject("Wscript.Shell")
    Set oEnv = oWsh.Environment("PROCESS")
    sCustActData = oEnv("ROOTDIR") & "\"
    Set oWsh = Nothing
    Set oEnv = Nothing
  End If

  On Error Goto 0
  Dim nEnd
  nEnd = InStr(sCustActData,";")
  If nEnd = 0 Then nEnd = Len(sCustActData)+1
  sIncFilePath = Left(sCustActData,nEnd-1) & "install\scripts\" & sIncFileName

  Dim oFso, oFile
  Set oFso  = CreateObject("Scripting.FileSystemObject")
  Set oFile = oFso.OpenTextFile(sIncFilePath)
  ExecuteGlobal oFile.ReadAll()
  oFile.Close
  Set oFso  = Nothing
  Set oFile = Nothing
End Function

Include "Common.vbs"
'*******************************************************************************

Main()

Function Main()
  If InitialLogMsg()                    <> kRetVal_SUCCESS Then Exit Function
  If LoadProperties()                   <> kRetVal_SUCCESS Then Exit Function
  If Debug_DisplayProps()               <> kRetVal_SUCCESS Then Exit Function
  If Debug_GetAndLogProperties()        <> kRetVal_SUCCESS Then Exit Function
  If Validate_RMP_Crypto_Params()       <> kRetVal_SUCCESS Then Exit Function
  If Validate_PaySvr_Crypto_Params()    <> kRetVal_SUCCESS Then Exit Function
  If Validate_MPS_Crypto_Params()       <> kRetVal_SUCCESS Then Exit Function
  If Validate_Consistency()             <> kRetVal_SUCCESS Then Exit Function
  If Validate_DB_Params()               <> kRetVal_SUCCESS Then Exit Function
  If Validate_DB_LoginParams()          <> kRetVal_SUCCESS Then Exit Function
  If Validate_DB_UserLoginParams()      <> kRetVal_SUCCESS Then Exit Function
  If Validate_DB_CreateParams()         <> kRetVal_SUCCESS Then Exit Function
  If ValidatePortalParams()             <> kRetVal_SUCCESS Then Exit Function
  If Validate_PaymentSvrClient_Params() <> kRetVal_SUCCESS Then Exit Function
  If ValidateReportingParams()          <> kRetVal_SUCCESS Then Exit Function
  If Validate_GreatPlains_Params()      <> kRetVal_SUCCESS Then Exit Function
  If ResourceCheck()                    <> kRetVal_SUCCESS Then Exit Function
  If ValidateDBOUser()                  <> kRetVal_SUCCESS Then Exit Function
  If ValidateMDACVersion()              <> kRetVal_SUCCESS Then Exit Function
  If Reset_DBMS_Type()                  <> kRetVal_SUCCESS Then Exit Function
  If Error_DBMS_Type()                  <> kRetVal_SUCCESS Then Exit Function
  If ContinueOrAbort()                  <> kRetVal_SUCCESS Then Exit Function
  If VerifyRemoveAll()                  <> kRetVal_SUCCESS Then Exit Function
  If CryptoMPS()                        <> kRetVal_SUCCESS Then Exit Function
  If StopPipeline()                     <> kRetVal_SUCCESS Then Exit Function
  If FinalLogMsg()                      <> kRetVal_SUCCESS Then Exit Function
End Function
