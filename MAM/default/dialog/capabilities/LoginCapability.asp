<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
'  Copyright 1998,2000,2001,2002 by MetraTech Corporation
'  All rights reserved.
' 
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' 
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
' 
'  Created by: Kevin A. Boucher
' 
'  $Date$
'  $Author$
'  $Revision$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../../auth.asp" -->
<!-- #INCLUDE FILE="../../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../../custom/Lib/CustomCode.asp" --> 
<%
    
Form.Version        = MDM_VERSION     ' Set the dialog version
Form.RouteTo        = Session("LastRolePage")
 
Dim bMAM, bMPS, bMCM, bMOM
  
mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim bReturn 
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  ' Add Applications                   
  Service.Properties.Add "APP_MAM", "Boolean", 0, FALSE, FALSE                   
  Service.Properties.Add "APP_MCM", "Boolean", 0, FALSE, FALSE    
  Service.Properties.Add "APP_MOM", "Boolean", 0, FALSE, FALSE     
  Service.Properties.Add "APP_MPS", "Boolean", 0, FALSE, FALSE                        
                  
  Form("Update") = request.QueryString("Update")
 	Form("RoleID") =  request.QueryString("RoleID")
	Form("CapabilityID") = request.QueryString("capabilityID") 
  Form("CompositeCollection") = Empty
	
  If UCase(Session("IsAccount")) = "TRUE" Then
		
    On error resume next
    Form("AuthAccount") = FrameWork.Policy.GetAccountByID(FrameWork.SessionContext,Session("SecurityAccountID"), mam_ConvertToSysDate(mam_GetHierarchyTime()))
    If err.number <> 0 then
      Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
    End If
    On error goto 0     

  
		If UCase(Session("DefaultPolicy")) = "TRUE" Then
		  Form("AccountPolicy") = Form("AuthAccount").GetDefaultPolicy(FrameWork.SessionContext)
		Else
	    Form("AccountPolicy") = Form("AuthAccount").GetActivePolicy(FrameWork.SessionContext)
    End If
		Form("CompositeCapabilityType") = FrameWork.Policy.GetCapabilityTypeByID(CLng(Form("CapabilityID")))
  Else
  	Form("Role") = FrameWork.Policy.GetRoleByID(FrameWork.SessionContext, Form("RoleID"))
	  Form("CompositeCapabilityType") = FrameWork.Policy.GetCapabilityTypeByID(CLng(Form("CapabilityID")))
	End If	

  Set ProductView.Properties.RowSet = FrameWork.Policy.GetCapabilityTypeAsRowsetLocalized(FrameWork.SessionContext, CLng(Form("CapabilityID")))	
	
  bReturn = DynamicCapabilites(EventArg) ' Load the correct template for the dynmaic capabilities
		
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

  Form_Initialize = bReturn

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  DynamicCapabilites
' PARAMETERS:  EventArg
' DESCRIPTION:  This function determines what should be placed in the dialog template based on the atomic capabilities found
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION DynamicCapabilites(EventArg)
	Dim objCompositeInstance
	Dim atomic
  Dim composite
  Dim objDyn
	Dim strHTML
  Dim nCount

  on error resume next
	
  ' Set Title	
  mdm_GetDictionary().add "CAPABILITY_TITLE", ProductView.Properties.Rowset.Value("tx_desc")  

	If IsEmpty(Form("CompositeCollection")) Then
  	If UCase(Form("Update")) <> "TRUE" Then
      If UCase(Session("IsAccount")) = "TRUE" Then			
			  Form("AccountPolicy").AddCapability(Form("CompositeCapabilityType").CreateInstance())
			Else
			  Form("Role").GetActivePolicy(FrameWork.SessionContext).AddCapability(Form("CompositeCapabilityType").CreateInstance())
			End If	
	  End If
	End If
  
  CheckAndWriteError
  
  If UCase(Session("IsAccount")) = "TRUE" Then	
   	Form("CompositeCollection") = Form("AccountPolicy").GetCapabilitiesOfType(Form("CompositeCapabilityType").ID)
  Else
	  Form("CompositeCollection") = Form("Role").GetActivePolicy(FrameWork.SessionContext).GetCapabilitiesOfType(Form("CompositeCapabilityType").ID)
  End If
	 
	nCount = 1
	For Each composite in Form("CompositeCollection")
	
		For Each atomic in composite.AtomicCapabilities

	    Select Case UCase(atomic.capabilityType.name)
    		'----------------------------------------------------------------------------------------------------------					
		  	Case "MTENUMTYPECAPABILITY"
	
				  If IsValidObject(atomic.GetParameter()) Then
            Dim strPName
            strPName = "APP_" & CStr(Atomic.GetParameter().Value)
            Service.Properties(strPName).value = TRUE
					End If
														
	   	End Select

		Next
  
  	nCount = nCount + 1
	Next
  
  DynamicCapabilites = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Refresh
' PARAMETERS:  EventArg
' DESCRIPTION:  Loads the DynamicCapabilities using the initial saved template
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg) ' As Boolean
	Form_Refresh = DynamicCapabilites(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
  On Error Resume Next

  Dim composite, atomic
 
  bMAM = TRUE
  bMPS = TRUE
  bMCM = TRUE
  bMOM = TRUE   

  ' Remove all capabilities
  If UCase(Session("IsAccount")) = "TRUE" Then
	  Call Form("AccountPolicy").RemoveCapabilitiesOfType(CLng(Form("CapabilityID")))
	Else
	  Call Form("Role").GetActivePolicy(FrameWork.SessionContext).RemoveCapabilitiesOfType(CLng(Form("CapabilityID")))
	End If

  ' Add a new capability instance for each TRUE
  If UCase(Session("IsAccount")) = "TRUE" Then
    If Service.Properties("APP_MAM").Value Then
      Form("AccountPolicy").AddCapability(Form("CompositeCapabilityType").CreateInstance())
    End IF
    
    If Service.Properties("APP_MPS").Value Then
      Form("AccountPolicy").AddCapability(Form("CompositeCapabilityType").CreateInstance())
    End IF

    If Service.Properties("APP_MCM").Value Then
      Form("AccountPolicy").AddCapability(Form("CompositeCapabilityType").CreateInstance())
    End IF

    If Service.Properties("APP_MOM").Value Then
      Form("AccountPolicy").AddCapability(Form("CompositeCapabilityType").CreateInstance())
    End IF  
	Else
    If Service.Properties("APP_MAM").Value Then
    	Form("Role").GetActivePolicy(FrameWork.SessionContext).AddCapability(Form("CompositeCapabilityType").CreateInstance())
    End IF
    
    If Service.Properties("APP_MPS").Value Then
    	Form("Role").GetActivePolicy(FrameWork.SessionContext).AddCapability(Form("CompositeCapabilityType").CreateInstance())
    End IF

    If Service.Properties("APP_MCM").Value Then
    	Form("Role").GetActivePolicy(FrameWork.SessionContext).AddCapability(Form("CompositeCapabilityType").CreateInstance())
    End IF

    If Service.Properties("APP_MOM").Value Then
    	Form("Role").GetActivePolicy(FrameWork.SessionContext).AddCapability(Form("CompositeCapabilityType").CreateInstance())
    End IF  
	End If	

  
  If UCase(Session("IsAccount")) = "TRUE" Then	
   	Form("CompositeCollection") = Form("AccountPolicy").GetCapabilitiesOfType(Form("CompositeCapabilityType").ID)
  Else
	  Form("CompositeCollection") = Form("Role").GetActivePolicy(FrameWork.SessionContext).GetCapabilitiesOfType(Form("CompositeCapabilityType").ID)
  End If
  

  ' set atomic value for each instance
	For Each composite in Form("CompositeCollection")
		Call SetAtomic(composite.GetAtomicEnumCapability())
	Next      
  
	' SAVE
	If UCase(Session("IsAccount")) = "TRUE" Then
	  Form("AuthAccount").Save
	Else
   	Form("Role").Save			
	End If	
				
	If(CBool(Err.Number = 0)) then
      On Error Goto 0
      OK_Click = TRUE
  Else        
      EventArg.Error.Save Err  
      OK_Click = FALSE
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
FUNCTION SetAtomic(atomic)
	if Not IsValidObject(atomic) then
		Exit Function
	end if

    If Service.Properties("APP_MAM").Value and bMAM Then
      Call atomic.SetParameter(CStr("MAM"))
      bMAM = FALSE
      Exit Function
    End IF
    
    If Service.Properties("APP_MPS").Value and bMPS Then
      Call atomic.SetParameter(CStr("MPS"))
      bMPS = FALSE
      Exit Function      
    End IF

    If Service.Properties("APP_MCM").Value and bMCM Then
      Call atomic.SetParameter(CStr("MCM"))
      bMCM = FALSE
      Exit Function      
    End IF

    If Service.Properties("APP_MOM").Value and bMOM Then
      Call atomic.SetParameter(CStr("MOM"))
      bMOM = FALSE
      Exit Function      
    End IF
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Cancel_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean

  Cancel_Click = TRUE
END FUNCTION

%>

