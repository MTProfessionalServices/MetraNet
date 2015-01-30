<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<%
  On Error Resume Next

  ' If QueryString has AccountID then we are 
	' either removing a role or a capability
	' Otherwise we are removing a capability from a role

	' JavaScript has already confirmed delete operation.
	Dim objRole
	Dim objCompositeCapabilityType
  Dim objAuthAccount  	 	
  Dim objAccountPolicy
	Dim nRoleID
	Dim nAccountID
	Dim nCapabilityID
	
	nAccountID    = request.QueryString("AccountID")
	nRoleID       = request.QueryString("RoleID")
	nCapabilityID = request.QueryString("CapabilityID")
	
  If Len(nAccountID) > 0 Then

    On error resume next
  	Set	objAuthAccount = FrameWork.Policy.GetAccountByID(FrameWork.SessionContext,CLng(nAccountID), mam_ConvertToSysDate(mam_GetHierarchyTime()))
    If err.number <> 0 then
      Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
    End If
    On error goto 0     
    
 	  CheckAndWriteError
		
		If UCase(Session("DefaultPolicy")) = "TRUE" Then  ' Decide which policy to use - default or active
		  Set objAccountPolicy = objAuthAccount.GetDefaultPolicy(FrameWork.SessionContext)
		Else
	    Set objAccountPolicy = objAuthAccount.GetActivePolicy(FrameWork.SessionContext)
    End If
		CheckAndWriteError
		
		If Len(nRoleID) > 0 Then
	    'Delete role from account - AccountID and RoleID
			objAccountPolicy.RemoveRole(nRoleID)
		Else
  	  'Delete capability from account - AccountID and CapabilityID  
		  objAccountPolicy.RemoveCapabilitiesOfType(nCapabilityID) 
		End If
	  CheckAndWriteError
		
		objAuthAccount.Save()		
  Else
	  'Delete Capability from role - RoleID and CapabilityID
		Set objRole = FrameWork.Policy.GetRoleByID(FrameWork.SessionContext, nRoleID)
		CheckAndWriteError
		
		Set objCompositeCapabilityType = FrameWork.Policy.GetCapabilityTypeByID(nCapabilityID)
	  CheckAndWriteError
		
	  objRole.GetActivePolicy(FrameWork.SessionContext).RemoveCapabilitiesOfType(objCompositeCapabilityType.ID)
		CheckAndWriteError
		
		objRole.Save()
  End If	
	CheckAndWriteError
	
	'Where are we going back to?
  response.redirect Session("LastRolePage")	
%>
