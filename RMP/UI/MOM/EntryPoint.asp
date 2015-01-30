<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE VIRTUAL="/mom/default/lib/MomLibrary.asp" -->

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
 Dim strPartitionId

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
 strPartitionId       = Request.QueryString("PartitionID")

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
      session("IsAuthenticated")= true
	  end if

    If Len(strNamespaceType) = 0 Then
     strNamespaceType = "system_user"
    End If

    ' Attempt to login
    Call FrameWork.LogOn("MOM", strLogon , Empty , strNamespace, strTicket, Empty) 
 
    If Len(strPartitionId) > 0 Then
      Session("MOM_SESSION_CSR_PARTITION_ID") = strPartitionId
    End If 
     
    Session("LocalizedPath") = Application("APP_HTTP_PATH") &  "/default/localized/" &Session("mdm_APP_LANGUAGE")

    Session("bTickected") = TRUE ' setting this to false will not close the page on logout
    
    Call Go()
  End If
 
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' OK to login, go to passed in URL
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function Go()
	'SECENG
	'Fixing issue ESR-4041 MSOL BSS 27485 Metracare: Open redirection [/mam/EntryPoint.asp] (ESR for 18272) (Post-PB)
	'Added verification of the URL supplied
	If SafeForUrlAC(strURL) Then
		If UCase(strLoadFrame) = "TRUE" Then
		  response.Redirect mam_GetDictionary("FRAMESET_ASP") & "?RouteTo=" & strURL 
		Else  
		  response.Redirect strURL  
		End If
	End If
  End Function

%>
