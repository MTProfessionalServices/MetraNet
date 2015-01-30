'*******************************************************************************
'* Copyright 2005 by MetraTech Corp.
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corp. MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corp. MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corp.,
'* and USER agrees to preserve the same.
'*
'* Name:        RunHook.vbs
'* Created By:  Simon Morton
'* Description: Sample script to run a single hook or all hooks (synchronize)
'*******************************************************************************

Function Main()
  Dim sProgID
  Dim bSecure

  If wscript.arguments.length < 1 Then
    PrintUsage()
    Exit Function
  Else
    sProgID = wscript.arguments(0)
    If wscript.arguments.length > 1 Then
      If LCase(wscript.arguments(1)) = "secure" Then
        bSecure = True
      Else
        PrintUsage()
        Exit Function
      End If
    Else
      bSecure = False
    End If
  End If

  If sProgID = "all" Then
    RunAllHooks

  Else
    RunHook sProgID, bSecure
  End If

End Function

Function RunAllHooks ()
  Dim oXMLDOM
  Dim oHookList, oHookLists
  Dim oRCD
  Dim oFso  

  Set oXMLDOM              = CreateObject("Microsoft.XMLDOM")
  Set oFso                 = CreateObject("Scripting.FileSystemObject")
  oXMLDOM.Async            = FALSE
  oXMLDOM.ValidateOnParse  = FALSE
  oXMLDOM.ResolveExternals = FALSE

  Set oRCD = CreateObject("MetraTech.RCD")

  oXMLDOM.Load oRCD.InstallDir & "\config\deployment\hooks.xml"

  Set oHookLists = oXMLDOM.SelectNodes("/synchronization/hooklist")

  For Each oHookList In oHookLists
    Dim oHook, oHooks

    Set oHooks = oHookList.SelectNodes("hook")

    For Each oHook In oHooks
      Dim oHookAttrs
      Dim oHookSecuredAttr
      Dim oHookExtensiondAttr            
      Dim sExtensionFilePath
      Dim bSecure      

      bSecure = False
      Set oExtensiondName = Nothing
      Set oHookAttrs = oHook.attributes
      Set oHookSecuredAttr = oHookAttrs.GetNamedItem("secured")
      Set oHookExtensiondAttr = oHookAttrs.GetNamedItem("extension_name")                  
      
      If Not oHookSecuredAttr Is Nothing Then
        If oHookSecuredAttr.nodeValue = "true" Then
          bSecure = True
        End If
      End If
      
      If oHookExtensiondAttr Is Nothing Then
        RunHook oHook.NodeTypedValue, bSecure
      Else
        sExtensionFilePath = oRCD.InstallDir & "\extensions\" & oHookExtensiondAttr.nodeValue & "\config\extension.xml"
        If oFso.FileExists(sExtensionFilePath) Then
          RunHook oHook.NodeTypedValue, bSecure
        End If
      End If
     
    Next
  Next

End Function

Function RunHook (sProgID, bSecure)
  Dim oHookHandler
  Dim strConHold, objConHold 
  
  ' Hold open OLEDB connection to keep connection pool from going to 0 and destructing the pool
   Set objConHold = CreateObject("ADODB.Connection")
   strConHold =  GetConnStr2
   objConHold.Open strConHold

  Set oHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")

  If bSecure Then
        ' ESR-5176 remove hardcoded username and password
	' Obtain login information from servers.xml
	Dim ServersInfo
	Dim ServerInfo
	Dim strUser
	Dim strPassword
	Dim strNamespace
	Set ServersInfo = CreateObject("MTServerAccess.MTServerAccessDataSet")
	ServersInfo.Initialize
	Set ServerInfo = ServersInfo.FindAndReturnObject("SuperUser")
	strUser         = ServerInfo.UserName
	strPassword     = ServerInfo.Password
	strNamespace    = "system_user"
	Set ServerInfo  = Nothing
	Set ServersInfo = Nothing

    Dim oLoginContext
    Dim oSessionContext
   
    Set oLoginContext = CreateObject("Metratech.MTLoginContext")
    ' ESR-5176 remove hardcoded username and password
    Set oSessionContext = oLoginContext.Login(strUser, strNamespace, strPassword)
    oHookHandler.SessionContext = oSessionContext
    
    wscript.echo "Running Hook: " & sProgID  & " (secured)"

  Else
    wscript.echo "Running Hook: " & sProgID 
  End If
 
  oHookHandler.RunHookWithProgid sProgID,""
  
  ' Close Held Open OLEDB Connection
  objConHold.Close
  Set objConHold = Nothing
  
End Function

Function PrintUsage()
  wscript.echo "Usage:"
  wscript.echo "  cscript RunHook.vbs <progid> [secure]"
  wscript.echo "  cscript RunHook.vbs all"
End Function

Function GetConnStr2 ()
  Dim sConnStr
  Dim objServerAccess
  Dim objServerAccessData
  
  Set objServerAccess = CreateObject("MTServerAccess.MTServerAccessDataSet.1")
  
  objServerAccess.Initialize
  
  Set objServerAccessData = objServerAccess.FindAndReturnObject("NetMeter")
  
  if UCASE(objServerAccessData.Databasetype) = "{ORACLE}" THEN
  
		sConnStr = "Provider=OraOLEDB.Oracle"     & _
					";Data Source=" & objServerAccessData.servername & _
					";User ID="     & objServerAccessData.UserName   & _
					";Password="    & objServerAccessData.Password   & _
					";"
  else
		sConnStr = "Provider=SQLOLEDB.1;Data Source=" & objServerAccessData.servername & _
					";UID=" & objServerAccessData.UserName & _
					";PWD=" & objServerAccessData.Password & _
					";Initial Catalog=" & objServerAccessData.DatabaseName
  end if
			 
			 

  GetConnStr2 = sConnStr
End Function

Main
