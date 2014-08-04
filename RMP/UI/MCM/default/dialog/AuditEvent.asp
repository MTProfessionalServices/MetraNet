<!-- #INCLUDE FILE="../../auth.asp" --> 
<HTML>
<HEAD>
  <LINK rel="STYLESHEET" type="text/css" href="/mcm/default/localized/en-us/styles/styles.css">
  <title></title>                 
</HEAD>
<body>
<TABLE border="0" cellpadding="1" cellspacing="0" width="100%">
<tr><td Class='CaptionBar' nowrap>Create Audit Event</td></tr>
</TABLE>
<br>
<%
if request("EventId") <> "" then
  '// Create and submit new event
  iEventId = Clng(request("EventId"))
  iUserId = CLng(request("UserId"))
  iEntityTypeId = CLng(request("EntityTypeId"))
  iEntityId = CLng(request("EntityId"))  
  sDetails = request("Details")
  
  response.write("<HR>")
  'SECENG: CORE-4792 CLONE - BSS 34776 MetraCare: Stored Cross-Site Scripting in [MAM/default/dialog/DefaultPVBApplicationAuditLog.asp]
  'HTML encoding was added.
  response.write("About to create new event with [" & iEventId & "][" & iUserId & "][" & iEntityTypeId & "][" & iEntityId & "][" & SafeForHtml(sDetails) & "]... ")

  
  Set objAuditEvent = CreateObject("Metratech.AuditEvent")

  objAuditEvent.UserId=iUserId
  objAuditEvent.EventId=iEventId
  objAuditEvent.EntityTypeId = iEntityTypeId
  objAuditEvent.EntityId = iEntityId
  objAuditEvent.Details=sDetails

  Set objAuditWriter = CreateObject("Metratech.AuditDBWriter")
  objAuditWriter.write(objAuditEvent)
  response.write("DONE<BR>")
  response.write("<HR>")

  response.write("<script language=""Javascript"">window.opener.location = window.opener.location;</script>")

end if
  
%>

<form action="AuditEvent.asp" name="AuditEvent">

 <table border="0" cellpadding="0" cellspacing="0" width="100%">
     <tr>
       <td class="captionEWRequired">Event:&nbsp;&nbsp;</td>
        <td> <select name="EventId">
          <option value="0   ">Unknown</option>
          <option value="1100">Product Offering Creation</option>
          <option value="1101">Product Offering Update</option>
          <option value="1102">Product Offering Add Priceable Item Instance</option>
          <option value="1103">Product Offering Delete Priceable Item Instance</option>
          <option value="1104">Product Offering Update Priceable Item Instance</option>
          <option value="1105">Product Offering Update Price List Mapping</option>
          <option value="1200">Template Creation</option>
          <option value="1201">Template Update</option>
          <option value="1202">Template Deletion</option>
          <option value="1300">Price List Creation</option>
          <option value="1400">Rate Schedule Creation</option>
          <option value="1401">Rate Schedule Property Update</option>
          <option value="1402">Create Personal Rate</option>
          <option value="1403">Update Personal Rate</option>
          <option value="1404">Remove Personal Rate</option>
          <option value="1500">Bulk Subscription Change</option>
          <option value="1501">Subscription Creation</option>
          <option value="1502">Subscription Update</option>
          <option value="1503">Unsubscription</option>
          <option value="1504">Account Creation</option>
          <option value="1505">Account Update</option>
          <option value="1600">Other</option>

     </tr>
     <tr>
       <td class="captionEWRequired">User:&nbsp;&nbsp;</td>
        <td><input type="text" class="field" name="userid" value="126"><BR></td>
      </tr>
      <tr><td>&nbsp;</td><td>&nbsp;</td></tr>
      <tr>
        <td class="captionEWRequired" style='vertical-align: top;'>Entity Type:&nbsp;&nbsp;</td>
        <td><select class="field" name="EntityTypeId"><option value="1">Account</option><option value="2" selected>Product Catalog Object</option></select></td>
      </tr>
      <tr>
        <td class="captionEWRequired" style='vertical-align: top;'>Entity:&nbsp;&nbsp;</td>
        <td><input type="text" class="field" name="entityid" value="126"></td>
      </tr>
      <tr><td>&nbsp;</td><td>&nbsp;</td></tr>
      <tr>
        <td class="captionEW" style='vertical-align: top;'>Details:&nbsp;&nbsp;</td>
        <td><textarea class="field" cols="100" rows="10" name="Details"></textarea></td>
      </tr>
      
        
		    <tr><td colspan=2></td></tr> 
 </table>

<br>

<br><br><hr size="1">
<div align="center">
  <button name="Submit" class="clsButtonMedium" onClick="window.document.AuditEvent.submit();">Create Event</button>
</div>
 
</form>