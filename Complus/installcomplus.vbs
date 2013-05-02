' ----------------------------------------------------------------
' * Copyright 1997-2001 by MetraTech
' * All rights reserved.
' *
' * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
' * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
' * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
' * OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
' * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
' * RIGHTS.
' *
' * Title to copyright in this software and any associated
' * documentation shall at all times remain with MetraTech, and USER
' * agrees to preserve the same.
' ----------------------------------------------------------------

' ----------------------------------------------------------------
' Name:
'       installcomplus.vbs
' Usage:
'       installcomplus.vbs <directory of dlls>
'
' Description:
'       Installs (or reinstalls) product catalog executants
'       and priceable item hook as COM+ components.
'
' ----------------------------------------------------------------

Option explicit

Const COMAdminAccessChecksApplicationLevel = 0 
Const COMAdminAccessChecksApplicationComponentLevel = 1 

PUBLIC CONST vbHide             = 0

Const COMAdminActivationInproc = 0 
Const COMAdminActivationLocal = 1 

const COMAdminTransactionIgnored = 0 
const COMAdminTransactionNone = 1 
const COMAdminTransactionSupported = 2 
const COMAdminTransactionRequired = 3 
const COMAdminTransactionRequiresNew = 4 

const COMAdminTxIsolationLevelAny = 0

' This class will set the dos return code if an error has been raise
CLASS CDOSErrorCatcher

  PRIVATE SUB Class_Terminate()
      If Err.Number Then
          WScript.Quit Err.Number
      End If
  END SUB
END CLASS

Main

Sub Main()

    Dim DOSErrorCatcher : Set DOSErrorCatcher = New CDOSErrorCatcher
    
    Dim dllpath ' As String
    Dim tlbpath ' As String

    if wscript.arguments.length < 2 then
        wscript.echo "to run, pass in directory where COM+ executants are located and a directory where Interop TLBs are created"
        exit sub
    end if

    dllPath = wscript.arguments(0)
    tlbpath =  wscript.arguments(1)

    ' remove obsolete MTProductCatalog app if it exists
    If (RemoveApplication("MTProductCatalog", false) = True) Then
        wscript.echo "Removed obsolete application: MTProductCatalog"
    End If

    ' remove obsolete MetraTech.xxx.dll
    If (RemoveApplication("MetraTech.", true) = True) Then
        wscript.echo "Removed exisiting COM+ application: MetraTech.*"
    End If

    If (RemoveApplication("MetraNet", false) = True) Then
        wscript.echo "Removed exisiting COM+ applications: MetraNet"
    End If

    wscript.echo "Creating COM+ application: MetraNet"
    
    Dim fso
    Dim folder
    Dim fc
    Dim f

    Set fso = CreateObject("Scripting.FileSystemObject")

    Set folder = fso.GetFolder(dllPath)
    Set fc = folder.files
    
    
    wscript.echo "Installing MetraNet"
    
    Call InstallApplication( dllPath, tlbpath, fc)

    
End Sub

Sub InstallApplication(dllpath,  tlbpath, FileNames)

  Dim fulldllpath ' As String
 
  Const AppName = "MetraNet"
  Const AppDesc = "MetraNet COM+ app"
  Dim AppDll 
 
  'TODO: put auth related hooks

  ' setup up the transaction context
  dim txctx
  Set txctx = CreateObject("TxCtx.TransactionContext")

  ' get catalog 
  Dim cat ' As COMAdmin.COMAdminCatalog
  Set cat = txctx.CreateInstance("COMAdmin.COMAdminCatalog") ' New COMAdmin.COMAdminCatalog

  ' increase transaction timeout if needed
  Const minimumTimeout = 600
  
  Dim oLocalComputerCol
  Dim oLocalComputerItem
  Dim currentTimeout

  Set oLocalComputerCol = cat.GetCollection("LocalComputer")
  oLocalComputerCol.Populate
  Set oLocalComputerItem = oLocalComputerCol.Item(0)

  currentTimeout = oLocalComputerItem.Value("TransactionTimeout")
  if currentTimeout < minimumTimeout then
    wscript.echo "Increasing transaction timeout from " & currentTimeout & " to " & minimumTimeout & " seconds."
    oLocalComputerItem.Value("TransactionTimeout") = minimumTimeout
    oLocalComputerCol.SaveChanges
  else
    wscript.echo "No need to increase transaction timeout. Timeout is already " & currentTimeout & " seconds."
  end if
  
  
  

  ' Add new library application
  Dim apps ' As COMAdmin.COMAdminCatalogCollection
  Set apps = cat.GetCollection("Applications")
  Dim app ' As COMAdmin.COMAdminCatalogObject
  Set app = apps.Add
  
  app.Value("Name") = AppName
  app.Value("Description") = AppDesc
  app.Value("ApplicationAccessChecksEnabled") = False
  app.Value("AccessChecksLevel") = COMAdminAccessChecksApplicationComponentLevel
  app.Value("Activation") = COMAdminActivationInProc
  
  apps.SaveChanges
  
  Dim f
  For each f in FileNames
      If InStr(f.Name, "Exec.dll") Then
        WScript.Echo f.Name
        AppDll = f.Name
        WScript.Echo "Installing " & AppDll
        fulldllpath = dllpath & "\" & AppDll 
        If f.Name = "MTGreatPlainsExec.dll" Then
          ' make sure MTGreatPlainsExec.dll has been registered
          ExecuteProgram "regsvr32 /s " & fulldllpath, VBHide
          ' for MTGreatPlainsExec only register the reader and writer, not the config helper classes
          cat.ImportComponent AppName, "MTGreatPlainsExec.MTGreatPlainsReader"
          cat.ImportComponent AppName, "MTGreatPlainsExec.MTGreatPlainsWriter"
        Else
          cat.InstallComponent AppName, fulldllpath, "", ""
        End If
      End If
      
   Next
   
   wscript.echo "Installing MTAuditDBWriter.dll"
   
   fulldllpath = dllpath & "\" & "MTAuditDBWriter.dll"
   cat.InstallComponent AppName, fulldllpath, "", ""


  'wscript.echo "Installing MTAuditPlugin"
  'cat.ImportComponent AppName,"MetraPipeline.MTAuditPluginWriter"
  wscript.echo "Installing byot object"
  cat.ImportComponent AppName,"Byot.ByotServerEx"
    
  wscript.echo "installing ComPlusWrapper"
   fulldllpath = dllpath & "\" & "ComPlusWrapper.dll"
   cat.InstallComponent AppName, fulldllpath, "", ""

  SetTransactionProps apps, app


  ' Install PrcItemHookDll into the new application
  'WScript.Echo "Installing " & PrcItemHookDll 
  'fulldllpath = dllpath & "\" & PrcItemHookDll
  'cat.InstallComponent AppName, fulldllpath, "", ""

    



  WScript.Echo "Committing changes"
  txctx.Commit
  WScript.Echo "Installing C# Serviced Components"
  For each f in FileNames
    If InStr(f.Name, "MetraTech") then
      WScript.Echo f.Name
    End If
    If InStr(f.Name, "MetraTech") Then
      If InStr(f.Name, ".dll") Then
        WScript.Echo "Registering C# ServicedComponent " & f.Name
        fulldllpath = dllpath & "\" & f.Name 
        Call RegisterCSharpComponents(fulldllpath, AppName, tlbpath)
       End If
    End If
  Next
  

End Sub

Function ApplicationExists(AppName) 'As Boolean
  Dim cat ' As COMAdmin.COMAdminCatalog
  Set cat = CreateObject("COMAdmin.COMAdminCatalog") ' New COMAdmin.COMAdminCatalog
  Dim apps ' As COMAdmin.COMAdminCatalogCollection
  Set apps = cat.GetCollection("Applications")
  apps.Populate
  ' enumerate through applications looking for AppName
  Dim app ' As COMAdmin.COMAdminCatalogObject
  For Each app In apps
    If app.Name = AppName Then
      ApplicationExists = True
      Exit Function
    End If
  Next ' app
  ApplicationExists = False
End Function


Function RemoveApplication(AppName, AllowPartialMatch) 'As Boolean
  Dim cat ' As COMAdmin.COMAdminCatalog
  Set cat = CreateObject("COMAdmin.COMAdminCatalog") ' New COMAdmin.COMAdminCatalog
  Dim apps ' As COMAdmin.COMAdminCatalogCollection
  Set apps = cat.GetCollection("Applications")
  apps.Populate

  RemoveApplication = False
  ' enumerate through applications looking for AppName
  Dim idx
  Dim app ' As COMAdmin.COMAdminCatalogObject
  idx = 0
  While idx < apps.Count
    Set app = apps.Item(idx)
    If app.Name = AppName OR (AllowPartialMatch AND InStr(app.Name, AppName) ) Then
      apps.Remove idx
      apps.SaveChanges
      RemoveApplication = True
      'look for more matches starting from beginning
      idx = -1
    End If
    idx = idx + 1
  wend
End Function



sub SetTransactionProps(apps, app)

  Dim components ' As COMAdmin.COMAdminCatalogCollection
  Set components = apps.GetCollection("Components", app.Key)
  components.Populate
  dim component
  wscript.echo "Setting writers as Required, readers as Supported:"
  for each component in components
      ' except For DDL writer
      if inStr(component.Name, "DDLWriter") then
          wscript.echo "  " & component.Name & " [transaction ignored]"
          component.Value("Transaction") = COMAdminTransactionIgnored
      Elseif inStr(component.Name, "FailureAuditDBWriter") then
          wscript.echo "  " & component.Name & " [requires new]"
          component.Value("Transaction") = COMAdminTransactionRequiresNew
      Elseif inStr(component.Name, "AuditDBWriter") then
          wscript.echo "  " & component.Name
          component.Value("Transaction") = COMAdminTransactionRequired
      Elseif inStr(component.Name, "Writer") then
          wscript.echo "  " & component.Name
          component.Value("Transaction") = COMAdminTransactionRequired
      Elseif component.Name = "ComplusWrapper.ExecVBScript" then
          wscript.echo " " & component.Name 
          component.Value("Transaction") = COMAdminTransactionRequired
      elseif inStr(component.Name, "Reader") then
          wscript.echo "  " & component.Name
          component.Value("Transaction") = COMAdminTransactionSupported
      end if

      component.Value("TxIsolationLevel") = COMAdminTxIsolationLevelAny 
     
  Next
  components.SaveChanges
end Sub

Function RegisterCSharpComponents(aDll, AppName, aTlbDir) 'As Boolean
  Dim cmdline
  cmdline = "RegisterServicedComponents /file:"& aDll & " /app:" & AppName & " /tlbdir:" & aTlbDir
  Call ExecuteProgram(cmdline, VBHide)
  
End Function

PRIVATE FUNCTION ExecuteProgram(ByVal strCommandLine,ByVal eMode)

      Dim lngErrorCode
      Dim Shell 
Set Shell = CreateObject("Wscript.Shell")

      ExecuteProgram = FALSE
      
      
      wscript.echo "TRACE: Executing Command: " & strCommandLine
      lngErrorCode = Shell.Run(strCommandLine,eMode,TRUE)

      If lngErrorCode=0 Then

                ExecuteProgram = TRUE
      Else
                RaiseInternalError 1001,PreProcess(CMetraTechDBInstall_ERROR_1001,Array("ERRORCODE",lngErrorCode))
      End If
  END FUNCTION

'      dim comPlusProperties

'      Set comPlusProperties = components.GetCollection("PropertyInfo", component.Key)
'      comPlusProperties.Populate

'      dim prop
'      for each prop in comPlusProperties
'          wscript.echo prop.Name & " = " & component.Value(prop.Name)
'      next
