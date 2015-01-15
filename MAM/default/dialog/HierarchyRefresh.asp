<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<form action="hierarchyClient.asp?Action=date" method="post" name="DateForm" id="DateForm" target="hierarchy">
  <input value="<%=Month(session("HIERARCHY_HELPER").SnapShot)%>" type="hidden" name="Month" id="Month">
  <input value="<%=Day(session("HIERARCHY_HELPER").SnapShot)%>"   type="hidden" name="Day" id="Day">
  <input value="<%=Year(session("HIERARCHY_HELPER").SnapShot)%>"  type="hidden" name="Year" id="Year">
</form> 
<script>
 document.DateForm.submit();
 document.location.href = "welcome.asp"
</script>

