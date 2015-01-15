<%
option explicit
%>
<!-- #INCLUDE FILE="auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"         -->
<!-- #INCLUDE FILE="default/lib/mamLibrary.asp"         -->
<%
On Error resume next

Session("HelpContext") = "Viewing_Your_Interactive_Bill.htm"
  
PRIVATE FUNCTION CheckAndWriteError()

    If(err.number)Then  

      EventArg.Error.Save Err
      EventArg.Error.LocalizedDescription = Hex(Err.number) & " " & EventArg.Error.Description
      Form_DisplayErrorMessage EventArg
      Response.End
    end if
END FUNCTION

  Dim objTicketAgent
  Dim providerID
  Dim logonID
  Dim iExpirationTime
  Dim ticket
  Dim strMPS
  Dim objSecureStore
  Dim strProtectedProperyList
    
  ' Get account information
  providerID      = SubscriberYAAC().Namespace  'MAM().Subscriber("Name_Space").Value
  logonID         = SubscriberYAAC().LoginName  'MAM().Subscriber("UserName").Value
  iExpirationTime = 1200   ' 20 Minutes
 
  ' If we have an error loading the account,
  ' then grab the currently selected account
  ' id from the hierarchy and try to load it in main frame.  (This will give the user a good error message.) 
  If err.number > 0 Then
    Response.Write "<script>getFrameMetraNet().main.location.href = '" & mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountId=' + getFrameMetraNet().hierarchy.dragID + '&ForceLoad=TRUE';</script>" 
    Response.End
  End If

  On Error Resume Next
  
  Set objTicketAgent = server.createObject("MetraTech.TicketAgent.1")
  CheckAndWriteError
  
  Set objSecureStore = CreateObject("COMSecureStore.GetProtectedProperty.1")
  CheckAndWriteError
    
  strProtectedProperyList = MAM().Tools.GetMTConfigDir() & "\serveraccess\protectedpropertylist.xml"
  
  If(Not MAM().Tools.TextFile.ExistFile(strProtectedProperyList))Then
  
      EventArg.Error.LocalizedDescription = Replace(mam_GetDictionary("MAM_ERROR_1021"),"[FILENAME]",strProtectedProperyList)
      Form_DisplayErrorMessage EventArg
      Response.End
  End If
  
  objSecureStore.Initialize "pipeline", strProtectedProperyList, "ticketagent"
  CheckAndWriteError

  objTicketAgent.Key = objSecureStore.GetValue
  CheckAndWriteError
    
  ' Create ticket
  ticket = objTicketAgent.CreateTicket(providerID, logonID, iExpirationTime)
  CheckAndWriteError

  ' Create URL
  '  strMPS = mam_GetDictionary("GLOBAL_ONLINE_BILL_" & UCase(providerID)) & "?MAM=TRUE&Logon=" & Server.URLEncode(logonID) & "&namespace=" & providerID & "&ticket=" & server.URLEncode(ticket) & "&refURL=" & Server.URLEncode(mam_ConfirmDialogEncodeAllURL( mam_GetDictionary("TEXT_MPS_FAIL_TITLE"), mam_GetDictionary("TEXT_MPS_FAIL"), mam_GetDictionary("WELCOME_DIALOG")))
  strMPS = "gateway.asp?MAM=TRUE&ProviderID=" & server.URLEncode(providerID) & "&Logon=" & Server.URLEncode(logonID) & "&namespace=" & providerID & "&ticket=" & server.URLEncode(ticket) & "&refURL=" & server.URLEncode(mam_GetDictionary("TICKET_STATUS_DIALOG"))

  'response.write strMPS
  'response.end
  
  ' Away we go!
  response.redirect strMPS
%>

