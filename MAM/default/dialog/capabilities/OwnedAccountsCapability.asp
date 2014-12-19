<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: CapabilityEditor.asp$
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
'  $Date: 09/18/2002 5:02:15 PM$
'  $Author: Noah Cushing$
'  $Revision: 14$
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

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim bReturn 
	Service.Properties.Clear()
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
  Form("Update") = request.QueryString("Update")
 	Form("RoleID") =  request.QueryString("RoleID")
	Form("CapabilityID") = request.QueryString("capabilityID") 
  Form("InitialTemplate") = Form.HTMLTemplateSource  ' Save the initial template so we can use it to render a new dynamic template later
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

  ' Setup initial template
  Form.HTMLTemplateSource = Form("InitialTemplate") 
	
  Set ProductView.Properties.RowSet = FrameWork.Policy.GetCapabilityTypeAsRowsetLocalized(FrameWork.SessionContext, CLng(Form("CapabilityID")))	
	 
  ' Set Title
	'mdm_GetDictionary().add "CAPABILITY_TITLE", Form("CompositeCapabilityType").description  
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
	
  strHTML = strHTML & "<tr>"				 
  strHTML = strHTML & "<td><img src='/mam/default/localized/en-us/images/info.gif'>&nbsp;" & mam_GetDictionary("TEXT_MetraNet_Users_Hierarchy_members") & "</td>"
  strHTML = strHTML & "</tr>"
	
	For Each composite in Form("CompositeCollection")
	
		For Each atomic in composite.AtomicCapabilities

	    Select Case UCase(atomic.capabilityType.name)

		 		'----------------------------------------------------------------------------------------------------------
				Case "MTPATHCAPABILITY"
				  
					mdm_GetDictionary().add "MTPATHCAPABILITY_DESCRIPTION", atomic.capabilityType.CompositionDescription
			
	        Set objDyn = mdm_CreateObject(CVariables)
	        objDyn.Add "0", "0", , , "[TEXT_CURRENT_NODE]"
					objDyn.Add "1", "1", , , "[TEXT_DIRECT_DESCENDANTS]"
					objDyn.Add "2", "2", , , "[TEXT_ALL_DESCENDANTS]"
					
 				  Service.Properties.Add "MTPATHCAPABILITY" & nCount, "String", 255, TRUE, ""		
				  Service.Properties.Add "MTWILDCARD" & nCount, "String", 0, TRUE, ""
			    Service.Properties("MTWILDCARD" & nCount).AddValidListOfValues objDyn						
					
					strHTML = strHTML & "<tr>"
					strHTML = strHTML & "	 <td class='clsStandardText'><span class='sectionCaptionBar'>" & mam_GetDictionary("TEXT_Select_Access_Level") & "&nbsp;&nbsp;</span><hr>"
					strHTML = strHTML & "	   <input type='radio' name='MTWILDCARD" & nCount & "' value='0'>" & mam_GetDictionary("TEXT_Owned_directly") & "<br>"
					strHTML = strHTML & "		 <input type='radio' name='MTWILDCARD" & nCount & "' value='1'>" & mam_GetDictionary("TEXT_Owned_by_immediate_subordinates") & "<br>"
					strHTML = strHTML & "		 <input type='radio' name='MTWILDCARD" & nCount & "' value='2'>" & mam_GetDictionary("TEXT_Owned_by_all_subordinates") & "&nbsp;<br>"
					strHTML = strHTML & "	 </td>"
					strHTML = strHTML & "</tr>"				 
				
					Service.Properties("MTPATHCAPABILITY" & nCount).Caption = "Path" 'TODO
			    Service.Properties("MTWILDCARD" & nCount).Caption = "Wildcard"		
					
					If nCount <= Form("CompositeCollection").count Then
					  If IsValidObject(atomic.GetParameter()) Then
              ' Translate from path back to John Smith (123) format 
              Dim strID
              Dim strPath
              strPath = atomic.GetParameter().Path
              If strPath = "/" or strPath = "" Then
                Service.Properties("MTPATHCAPABILITY" & nCount) = mam_GetDictionary("TEXT_ALL_CORPORATE_ACCOUNTS") & " (1)"
                Service.Properties("MTWILDCARD" & nCount) = atomic.GetParameter().Wildcard                
              Else
        				if (InStrRev(strPath, "/") = Len(strPath)) Then
        					strPath = Mid(strPath, 1, Len(strPath)-1)
        				End if
                strID = Mid(strPath, InStrRev("" & strPath, "/", Len(strPath)) + 1, Len(strPath))
                  
                Service.Properties("MTPATHCAPABILITY" & nCount) = mam_GetFieldIDFromAccountID(strID)
                Service.Properties("MTWILDCARD" & nCount) = atomic.GetParameter().Wildcard              
              End If
              
						Else
						  Service.Properties("MTPATHCAPABILITY" & nCount) = ""
				      Service.Properties("MTWILDCARD" & nCount) = ""
						End If
					Else
  					Service.Properties("MTPATHCAPABILITY" & nCount) = ""
					End If
				 
  		'----------------------------------------------------------------------------------------------------------					
			Case "MTACCESSTYPECAPABILITY"
					mdm_GetDictionary().add "MTACCESSTYPECAPABILITY_DESCRIPTION", atomic.capabilityType.CompositionDescription

					Service.Properties.Add "MTACCESSTYPECAPABILITY" & nCount, "ENUM", 0, TRUE, ""
					Service.Properties("MTACCESSTYPECAPABILITY" & nCount).Caption = "Access Type"
	
	        Set objDyn = mdm_CreateObject(CVariables)
	        objDyn.Add "Read", "0", , , "Read"
					objDyn.Add "Write", "1", , , "Write"
	        Service.Properties("MTACCESSTYPECAPABILITY" & nCount).AddValidListOfValues objDyn	
				  Service.Properties("MTACCESSTYPECAPABILITY" & nCount) = CStr(atomic.GetParameter())
					
					strHTML = strHTML & "   <tr>"
 			    strHTML = strHTML & "     <td width='50%' class='captionEWRequired'>[MTACCESSTYPECAPABILITY_DESCRIPTION]:</td>"
          strHTML = strHTML & "     <td width='50%' class='clsStandardText'><SELECT class='fieldRequired' name='MTACCESSTYPECAPABILITY" & nCount & "'></SELECT></td>"
				  strHTML = strHTML & "   </tr>"
			
      '----------------------------------------------------------------------------------------------------------					
			Case "MTDECIMALCAPABILITY"			
					mdm_GetDictionary().add "MTDECIMALCAPABILITY_DESCRIPTION", atomic.capabilityType.CompositionDescription

					Service.Properties.Add "MTDECIMALCAPABILITY" & nCount, "DECIMAL", 0, TRUE, 0
          
          Service.Properties.Add "MTDECIMALCAPABILITYOPERATOR" & nCount, "String", 0, TRUE, ""
  				'Service.Properties.Add "MTDECIMALCAPABILITYOPERATOR" & nCount, "ENUM", 0, TRUE, "" 'old

					Service.Properties("MTDECIMALCAPABILITY" & nCount).Caption = "Decimal"
          Service.Properties("MTDECIMALCAPABILITYOPERATOR" & nCount).Caption = "Operator"
					
					Set objDyn = mdm_CreateObject(CVariables)					
				  objDyn.Add "equal", MTDECIMALCAPABILITY_OPERATOR_TYPE_EQUAL, , , "="
				  objDyn.Add "notequal", MTDECIMALCAPABILITY_OPERATOR_TYPE_NOT_EQUAL, , , "<>"
				  objDyn.Add "greater", MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER, , , ">"
				  objDyn.Add "greaterequal", MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER_EQUAL, , , ">="
				  objDyn.Add "less", MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS, , , "<"																														
				  objDyn.Add "lessequal", MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS_EQUAL, , , "<="																														
	        Service.Properties("MTDECIMALCAPABILITYOPERATOR" & nCount).AddValidListOfValues objDyn	
					
				  If IsValidObject(atomic.GetParameter()) Then
					  Service.Properties("MTDECIMALCAPABILITY" & nCount) = atomic.GetParameter().Value
						' Thank Boris for this Select :)
						Select Case  CStr(atomic.GetParameter().Test)
            	Case "="
							  Service.Properties("MTDECIMALCAPABILITYOPERATOR" & nCount) = MTDECIMALCAPABILITY_OPERATOR_TYPE_EQUAL
            	Case "!="
							  Service.Properties("MTDECIMALCAPABILITYOPERATOR" & nCount) = MTDECIMALCAPABILITY_OPERATOR_TYPE_NOT_EQUAL
            	Case">"
							  Service.Properties("MTDECIMALCAPABILITYOPERATOR" & nCount) = MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER
            	Case ">="
							  Service.Properties("MTDECIMALCAPABILITYOPERATOR" & nCount) = MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER_EQUAL
            	Case "<"
							  Service.Properties("MTDECIMALCAPABILITYOPERATOR" & nCount) = MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS
            	Case "<="
							  Service.Properties("MTDECIMALCAPABILITYOPERATOR" & nCount) = MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS_EQUAL
            End Select
					Else
  					Service.Properties("MTDECIMALCAPABILITY" & nCount) = "0.00"
						Service.Properties("MTDECIMALCAPABILITYOPERATOR" & nCount) = MTDECIMALCAPABILITY_OPERATOR_TYPE_NONE
					End If
					
					strHTML = strHTML & "   <tr>"
 			    strHTML = strHTML & "     <td width='50%' class='captionEWRequired'>[MTDECIMALCAPABILITY_DESCRIPTION]:</td>"
          strHTML = strHTML & "     <td width='50%' class='clsStandardText'><input class='fieldRequired' size='10' type='text' value='" & Service.Properties("MTDECIMALCAPABILITY" & nCount) & "' name='MTDECIMALCAPABILITY" & nCount & "'></td>"
					strHTML = strHTML & "   </tr><tr>"
 			    strHTML = strHTML & "     <td width='50%' class='captionEWRequired'>Operator:</td>"
					strHTML = strHTML & "     <td width='50%' class='clsStandardText'><SELECT  class='fieldRequired' name='MTDECIMALCAPABILITYOPERATOR" & nCount & "'></SELECT></td>"
				  strHTML = strHTML & "   </tr>"

  		'----------------------------------------------------------------------------------------------------------					
			Case "MTENUMTYPECAPABILITY"
					mdm_GetDictionary().add "MTENUMTYPECAPABILITY_DESCRIPTION", atomic.capabilityType.CompositionDescription

					Service.Properties.Add "MTENUMTYPECAPABILITY" & nCount, "String", 0, TRUE, ""
					Service.Properties("MTENUMTYPECAPABILITY" & nCount).Caption = "Enum Type"

					Dim strName
 				  Dim strNameSpace

					strNameSpace = atomic.GetParameter().EnumSpace
					strName = atomic.GetParameter().EnumType
                    
					Service.Properties("MTENUMTYPECAPABILITY" & nCount).SetPropertyType "ENUM", strNameSpace, strName

				  If IsValidObject(atomic.GetParameter()) Then
					  Service.Properties("MTENUMTYPECAPABILITY" & nCount).Value = atomic.GetParameter().Value
					Else
					  Service.Properties("MTENUMTYPECAPABILITY" & nCount).Value = ""
					End If	
					
					strHTML = strHTML & "   <tr>"
 			  '  strHTML = strHTML & "     <td width='50%' class='captionEWRequired'></td>"
				  strHTML = strHTML & "     <td width='50%' class='clsStandardText'><SELECT class='fieldRequired' name='MTENUMTYPECAPABILITY" & nCount & "'></SELECT></td>"
				  strHTML = strHTML & "   </tr>"
														
	 		'----------------------------------------------------------------------------------------------------------					
			Case Else
			  mdm_GetDictionary().add "NOT_FOUND", TRUE			
				mdm_GetDictionary().add "NOT_FOUND_DESCRIPTION", atomic.capabilityType.CompositionDescription
				Service.Properties.Add "NOTHING_TO_CONFIGURE", "String", 255, FALSE, ""
        Service.Properties("NOTHING_TO_CONFIGURE").Value = "No configuration has been setup for this atomic capability type."
	   	End Select

		Next
		
		' If we have multiple instances, then add the remove button - as long as it is not the last instance
		If Form("CompositeCollection").count > 1 Then
  		strHTML = strHTML & "<tr><td align='right' colspan='2'>"
    	'strHTML = strHTML & "	 <button onclick='mdm_RefreshDialogUserCustom(this,""" & composite.ID & """);' name='Remove' Class='clsButtonBlueSmall'>Remove</button>"
		strHTML = strHTML & "	 <button onclick='mdm_RefreshDialogUserCustom(this,""" & nCount & """);' name='Remove' Class='clsButtonBlueSmall'>Remove</button>"
			strHTML = strHTML & "</td></tr>"
    End If
  
  	nCount = nCount + 1
	Next
		
	' Display Add button if more than one instance is allowed
	If CBool(Form("CompositeCapabilityType").AllowMultipleInstances) Then
  	strHTML = strHTML & "</tr><tr><td>&nbsp;</td></tr>"
	  strHTML = strHTML & "<tr>"
	  strHTML = strHTML & "	 <td colspan='2' class='captionEWRequired'><button onclick='mdm_RefreshDialog(this)' name='AddPath' Class='clsButtonBlueSmall'><MDMLABEL Name='TEXT_ADD'>Add</MDMLABEL></button></td>"
	  strHTML = strHTML & "</tr>"  
	End IF

	Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_CAPABILITY_TEMPLATE />", strHTML)
  
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
' FUNCTION:  Remove_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Remove_Click(EventArg) ' As Boolean
	
	Form("RemoveID") = mdm_UIValue("mdmUserCustom")
	
	Call SyncToScreen()
		
  ' Make sure to clear the service properties
	Do while Service.Properties.count
	  Service.Properties.Remove(1)
	Loop
		
	' Remove a capability instance from the collection
  If UCase(Session("IsAccount")) = "TRUE" Then
	  Form("AccountPolicy").RemoveCapabilityAt(Form("RemoveID"))
	Else
	  Form("Role").GetActivePolicy(FrameWork.SessionContext).RemoveCapabilityAt(Form("RemoveID"))
	End If
		
	Remove_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  AddPath_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION AddPath_Click(EventArg) ' As Boolean
 	
	Call SyncToScreen()
		
	' Add a new capability instance to the collection	  
  If UCase(Session("IsAccount")) = "TRUE" Then
	  Form("AccountPolicy").AddCapability(Form("CompositeCapabilityType").CreateInstance())
	Else
  	Form("Role").GetActivePolicy(FrameWork.SessionContext).AddCapability(Form("CompositeCapabilityType").CreateInstance())
	End If	
 	
	AddPath_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  SyncToScreen
' PARAMETERS:  EventArg
' DESCRIPTION:  Ensures that our in memory objects look like the screen
' RETURNS:  Return TRUE if ok else FALSE
Function SyncToScreen()
 	Dim objCompositeInstance
	Dim atomic
	Dim composite
	Dim nCount
	
  ' Make sure all our instances are up to date with what is on the screen
	nCount = 1
	For Each composite in Form("CompositeCollection")

		For Each atomic in composite.AtomicCapabilities
	    Select Case UCase(atomic.capabilityType.name)
			  Case "MTACCESSTYPECAPABILITY"
	   				Call atomic.SetParameter(Service.Properties("MTACCESSTYPECAPABILITY" & nCount))
						
		 		Case "MTPATHCAPABILITY"
            Dim strPath, nID
            
            ' Here we do the translation from John Smith (123) or account ID to Path /132/522/6343
            If FrameWork.DecodeFieldID(CStr(Service.Properties("MTPATHCAPABILITY" & nCount)), nID) Then
              If CStr(nID) = "1" Then
                strPath = "/"
              Else
                strPath = mam_GetPathFromAccountID(nID)
              End If  
              Call atomic.SetParameter(CStr(strPath), CLng(Service.Properties("MTWILDCARD" & nCount)))
              
            End If

			  Case "MTDECIMALCAPABILITY"		
				     dim objD, decValue
             set objD  = CreateObject("MTVBLIB.CDecimal")
             objD.value = Service.Properties("MTDECIMALCAPABILITY" & nCount)
             decValue = objD.value				
						 Call atomic.SetParameter(decValue, CLng(Service.Properties("MTDECIMALCAPABILITYOPERATOR" & nCount)))
						
				Case "MTENUMTYPECAPABILITY"
						Call atomic.SetParameter(Service.Properties("MTENUMTYPECAPABILITY" & nCount))
		
			End Select
			
	  Next
		nCount = nCount + 1
	Next
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
  On Error Resume Next

	Call SyncToScreen()
  
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
' FUNCTION:  Cancel_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean

  Cancel_Click = TRUE
END FUNCTION

%>

