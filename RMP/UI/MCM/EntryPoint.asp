<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdmIncludes.asp" -->
<!-- #INCLUDE FILE="default/lib/mcmLibrary.asp" -->

<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' EntryPoint.asp takes in the following parameters:
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' AccountID     - account to lookup, default is logon account (not required) 
' Logon         - account to logon as
' Password      - logon account password (not required) 
' Namespace     - logon account namespace
' NamespaceType - CSR namespace type
' Ticket        - logon account ticket
' URL           - page to go to recommend: default/dialog/frameset.asp 
' loadFrame     - TRUE if you want to load the frame (not required) 
On Error resume next

 Dim objKioskAuth, credObj, boolIsAuthentic
 Dim strLogon, strPassword, strNamespace, strTicket
 Dim strNamespaceType, strAccountID, strLoadFrame, strURL
 Dim SubscriberUserName, SubscriberNamespace, isNewMetraCare

 strLogon             = Request.QueryString("UserName")
 strPassword          = Request.QueryString("Password")
 strNamespace         = Request.QueryString("Namespace")
 strTicket            = Request.QueryString("Ticket")
 strNamespaceType     = request.QueryString("namespaceType")
 strAccountID         = Request.QueryString("AccountID")
 strLoadFrame         = Request.QueryString("loadFrame")
 strURL               = Request.QueryString("URL")
 SubscriberUserName   = Request.QueryString("SubscriberUserName")
 SubscriberNamespace  = Request.QueryString("SubscriberNamespace")
 isNewMetraCare       = Request.QueryString("isNewMetraCare")

 ' Check for existing session
 If Session("isAuthenticated") = true Then
   Call Go()
 Else
    ' Authenticate user
	  set objKioskAuth = createObject ("COMKioskAuth.COMKioskAuth.1")
	  objKioskAuth.Initialize
	  set application("objKioskAuth") = objKioskAuth

	  ' Create a credentials object object to authenticate the user
	  set credObj = createObject ("ComCredentials.ComCredentials.1")
   
	  credObj.loginID 	 = strLogon
	  credObj.pwd 			 = strPassword
	  credObj.name_space = strNamespace 
    credObj.ticket 		 = strTicket    
    
	  boolIsAuthentic = application("objKioskAuth").IsAuthentic(credObj)
  	
    if boolIsAuthentic then
      session("IsAuthenticated") = true
      session("ValidSession") = "TRUE"
	  end if

    If Len(strNamespaceType) = 0 Then
     strNamespaceType = "system_user"
    End If

    ' Attempt to login
    Call FrameWork.LogOn("mcm", strLogon , Empty , strNamespace, strTicket, Empty) 
    
    Session("LocalizedPath") = Application("APP_HTTP_PATH") & "/default/localized/en-us/"

    Session("bTickected") = TRUE ' setting this to false will not close the page on logout
    
    Call Go()
  End If
 
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' OK to login, go to passed in URL
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function Go()
      ' Retrieve Top Level Account Information (Partition)
    Call GetTopLevelAccountInformation()

	'SECENG
	'Fixing issue ESR-4041 MSOL BSS 27485 Metracare: Open redirection [/mam/EntryPoint.asp] (ESR for 18272) (Post-PB)
	'Added verification of the URL supplied
	'If SafeForUrlAC(strURL) Then
		If UCase(strLoadFrame) = "TRUE" Then
		  response.Redirect "frameset.asp?RouteTo=" & strURL 
		Else  
		  response.Redirect strURL  
		End If
	'End If
  End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : GetTopLevelAccountInformation()                                 '
' Description : Obtain topLevelAccount information for the given UI User        '
' Inputs      :                                                                 '
' Outputs     :                                                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetTopLevelAccountInformation()
  If Session("isPartitionUser") = Empty Then
      Dim accountId, refDate, topLevelAccountId, userName, displayName, hierarchyDisplayName
      Set objSqlRowset = Server.CreateObject("MTSQLRowset.MTSQLRowset.1")

      Call objSqlRowset.Init("..\Extensions\Partitions\config\SqlCustom\Queries\Account")
      Call objSqlRowset.SetQueryTag("__GET_TOP_LEVEL_ACCOUNT_INFORMATION_OLD__")

      accountId = FrameWork.AccountID()
      refDate = FrameWork.MetraTimeGMTNow()
  
      Call objSqlRowset.AddParam("%%accountId%%", accountId)
      Call objSqlRowset.AddParam("%%refDate%%", refDate)
      Call objSqlRowset.Execute()

      If objSqlRowset.EOF Then
        Set objSqlRowset = nothing
        GetTopLevelAccountInformation = False
        Exit Function
      End If

      'GOTO first row
      objSqlRowset.MoveFirst
      topLevelAccountId = objSqlRowset.value("topLevelAccountId")

      If topLevelAccountId = accountId Then
        Session("isPartitionUser") = False
      Else
        Session("isPartitionUser") = True
      End If

      userName             = objSqlRowset.value("userName")
      displayName          = objSqlRowset.value("displayName")
      hierarchyDisplayName = objSqlRowset.value("hierarchyDisplayName")

      Session("topLevelAccountId") = topLevelAccountId
      Session("topLevelAccountUserName") = userName
      Session("topLevelAccountDisplayName") = displayName
      Session("topLevelAccountHierarchyDisplayName") = hierarchyDisplayName

      Set objSqlRowset = nothing
  End If

  GetTopLevelAccountInformation = True
End Function

%>
