<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE FILE="./MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="./default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="./default/lib/MTProductCatalog.Library.asp" -->
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

 strLogon             = Request.QueryString("Logon")
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
      session("isAuthenticated")= true
	  end if

    If Len(strNamespaceType) = 0 Then
     strNamespaceType = "system_mps"
    End If
       
    ' Attempt to login
    Call FrameWork.LogOn("MAM", Empty , Empty , strNamespace, strTicket, Empty) 
    
    Call mam_SetupCSR(strLogon, strNamespace, strNamespaceType)
      
    Session("LocalizedPath") = Application("APP_HTTP_PATH") & "/default/localized/" & Session("PAGE_LANGUAGE")

    Session("bTickectFromMetraView") = TRUE ' setting this to false will not close the page on logout
    
    ' Setup MAM dialogs for NEW app that uses ticketing
    If UCase(isNewMetraCare) = "TRUE" Then
      FrameWork.Dictionary.Add "WELCOME_DIALOG", "/MetraNet/Welcome.aspx"
      FrameWork.Dictionary.Add "GLOBAL_DEFAULT_LOGIN", "/MetraNet/Login.aspx"
      Session("isNewMetraCare") = "TRUE"
    End If  

    Call Go()
  End If
 
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' OK to login, go to passed in URL
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function Go()
    If Len(SubscriberUserName) <> 0 Then
      If Len(SubscriberNamespace) <> 0 Then
        strAccountID = mam_GetAccountIDFromUserNameNameSpace(SubscriberUserName, SubscriberNamespace)
      End IF  
    End If
    
    ' Load subscriber account
    If(Len(strAccountID) > 0) Then
     If Not CBool(mam_LoadSubscriberAccount(strAccountID)) Then
     '  Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"), mam_GetDictionary("SUBSCRIBER_FOUND"))
     End If 
    Else
     If Not CBool(mam_LoadSubscriberAccount(MAM().CSR("_AccountID"))) Then
     '  Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
     End If 
    End If
    
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
