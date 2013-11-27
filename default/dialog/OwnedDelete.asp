<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<%
On Error Resume Next

Dim mgr, assoc, owned, startDate, endDate

owned = request.QueryString("ID")
startDate = request.QueryString("StartDate")
endDate = request.QueryString("EndDate")
  
Set mgr = mam_GetSystemUser().GetOwnershipMgr()
Set assoc = mgr.CreateAssociationAsOwner()
assoc.OwnedAccount = owned
If Len(startDate) > 0 Then  
  assoc.StartDate = CDate(startDate)    
Else
  assoc.StartDate = CDate(FrameWork.RCD().GetMinDate())
End If
If Len(endDate) > 0 Then  
  assoc.EndDate = CDate(endDate)    
Else
  assoc.EndDate = CDate(FrameWork.RCD().GetMaxDate())
End If

mgr.RemoveOwnership(assoc)
      
CheckAndWriteError

%>

<script>
 document.location.href =  '<%=mam_GetDictionary("SYSTEM_USER_OWNED_ACCOUNTS_DIALOG")%>';
</script>


