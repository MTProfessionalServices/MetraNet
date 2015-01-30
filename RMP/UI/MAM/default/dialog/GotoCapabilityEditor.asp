<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<%
on error resume next

PRIVATE FUNCTION CheckAndWriteError()
    If(err.number)Then  
      EventArg.Error.Save Err
      EventArg.Error.LocalizedDescription = Hex(Err.number) & " " & EventArg.Error.Description
      Form_DisplayErrorMessage EventArg
      Response.End
    End If
END FUNCTION

'---------------------------------------------------------------------------------------------------------------
' The tx_editor field in the database is used to determine the page we go to for editing this capability.
' The value stored in the tx_editor field is a MAM dictionary entry defining the page to go to.
' If there is no value in the tx_editor field we go back to the roleSetup page assuming there is nothing
' to be configured (we also add it to the role).  However, if a different dictionary entry for a dialog is
' specified in the tx_editor field of the database we will use that page instead. 
' The generic editor is: DEFAULT_CAPABILITY_EDITOR_DIALOG
'---------------------------------------------------------------------------------------------------------------

'On Error Resume Next

Dim strDialog 
Dim objCompositeInstance
Dim objRole
Dim objCompositeCapabilityType
Dim objPolicy
Dim objAuthAccount
Dim objAccountPolicy
Dim nCapabilityType

nCapabilityType = request.QueryString("IDS")

If Len(request.QueryString("OPTIONALVALUES")) = 0 Then
	
	If UCase(Session("IsAccount")) = "TRUE" Then
			
      On error resume next
      Set	objAuthAccount = FrameWork.Policy.GetAccountByID(FrameWork.SessionContext,Session("SecurityAccountID"), mam_ConvertToSysDate(mam_GetHierarchyTime()))
      If err.number <> 0 then
        Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
      End If
      On error goto 0     
      
       ' Add capability with zero atomics to account here
			CheckAndWriteError
			
			' Determine which policy to use - active or default
			If UCase(Session("DefaultPolicy")) = "TRUE" Then
			  	Set objAccountPolicy = objAuthAccount.GetDefaultPolicy(FrameWork.SessionContext)
			Else
		    	Set objAccountPolicy = objAuthAccount.GetActivePolicy(FrameWork.SessionContext)
	    End If
			CheckAndWriteError
			
			Set objCompositeCapabilityType = FrameWork.Policy.GetCapabilityTypeByID(nCapabilityType)
			CheckAndWriteError
			
			Set objCompositeInstance = objCompositeCapabilityType.CreateInstance()
			CheckAndWriteError
			
	    objAccountPolicy.AddCapability(objCompositeInstance)
			CheckAndWriteError
			
			objAuthAccount.Save()
			CheckAndWriteError		
	Else	
			
		  ' Add capability with zero atomics to role here
			Set objRole = FrameWork.Policy.GetRoleByID(FrameWork.SessionContext, session("RoleID"))
			CheckAndWriteError
			
			Set objCompositeCapabilityType = FrameWork.Policy.GetCapabilityTypeByID(nCapabilityType)
			CheckAndWriteError
			
			Set objCompositeInstance = objCompositeCapabilityType.CreateInstance()
			CheckAndWriteError
		  
		  Set objPolicy =  objRole.GetActivePolicy(FrameWork.SessionContext)
			CheckAndWriteError
			
			objPolicy.AddCapability(objCompositeInstance)
			CheckAndWriteError
				
			objRole.Save
			CheckAndWriteError
		End If

		CheckAndWriteError
	  Response.redirect Session("LastRolePage")
Else
  strDialog = mam_GetDictionaryDefault(request.QueryString("OPTIONALVALUES"), mam_GetDictionary("DEFAULT_CAPABILITY_EDITOR_DIALOG"))						

	CheckAndWriteError
  response.redirect strDialog & "?MDMReload=TRUE&capabilityID=" & nCapabilityType & "&RoleID=" &  session("RoleID")
End IF
%>
