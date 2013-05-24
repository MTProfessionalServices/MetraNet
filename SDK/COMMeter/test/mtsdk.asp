<% 
	Dim ses
	Dim c
On Error Resume Next
	Set mt = Server.CreateObject("MetraTechSDK.Meter")
	mt.HTTPTimeout = 30
    mt.HTTPRetries = 9
	' Must use "", "" at end
    mt.AddServer 0, "partner.metratech.com", 80, False, "", ""
    mt.Startup
    Set ses = mt.CreateSession("metratech.com/TestService")
    
    ses.InitProperty "AccountID", CInt(Request.Form("accountid"))
    ses.InitProperty "Description", CStr(Request.Form("description"))
    ses.InitProperty "Amount", CDbl(Request.Form("amount"))
    ses.InitProperty "UOM", CStr("USD")
    ses.InitProperty "Time", Now
    Session("SessionName") = ses.Name
    ses.Close  
	If (Err.Number <> 0) then
		Session("IsError") = 1
		Session("ErrString") = Err.Description
	Else
		Session("RefID") = ses.ReferenceID   
	End If
    mt.Shutdown
    Session("IsError") = 0

%>
<HTML>
<HEAD>
<TITLE>Add Session</TITLE>
</HEAD>
<BODY>
<FONT FACE="Arial, Helvetica" SIZE=2>
	Heelo<BR>
<% If Session("IsError") = 0 Then %>
	SessionID is <%= Session("SessionName") %><BR>
	RefID is <%= Session("RefID") %><BR>
	Type of AccountID is <%= TypeName(Request.Form("accountid")) %><BR>
	Type of Description is <%= TypeName(Request.Form("description")) %><BR>
	Type of Amount is <%= TypeName(Request.Form("amount")) %><BR>
<% Else %>
	An Error has Occurred <%= Session("ErrString") %>
<% End If %>
</BODY>
</HTML>
