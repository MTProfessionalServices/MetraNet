<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
    
' Mandatory
Form.Version = MDM_VERSION 
Form.RouteTo = mam_GetDictionary("SYSTEM_USER_OWNED_ACCOUNTS_DIALOG")

Session("BATCH_ERROR_RETURN_PAGE") = Form.RouteTo

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : OK_Click
' PARAMETERS : EventArg
' DESCRIPTION:
' RETURNS    : Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
	Dim PaymentMgr

  On Error Resume Next
  
  Dim mgr, assoc, rs, col, acc, c
    
  ' Get owned accounts  
  Set mgr = mam_GetSystemUser().GetOwnershipMgr()
  Set rs = mgr.GetOwnedAccountsAsRowset(mam_GetSystemUserHierarchyTime())
  
  ' Batch delete with collection of associations 
  Set col = Server.CreateObject(MT_COLLECTION_PROG_ID)
  
  Do While not rs.EOF
    
    Set assoc = mgr.CreateAssociationAsOwner()
  
    assoc.RelationType = rs.value("RelationType")
    assoc.PercentOwnership = rs.value("n_percent")

    If Len(rs.value("VT_Start")) > 0 Then  
      assoc.StartDate = CDate(rs.value("VT_Start"))    
    Else
      assoc.StartDate = CDate(FrameWork.RCD().GetMinDate())
    End If
    If Len(rs.value("VT_End")) > 0 Then  
      assoc.EndDate = CDate(rs.value("VT_End"))    
    Else
      assoc.EndDate = CDate(FrameWork.RCD().GetMaxDate())
    End If
    
    assoc.OwnedAccount = rs.value("id_owned")
  
    Call col.add(assoc)

    rs.MoveNext
  Loop
  
  If rs.RecordCount > 0 Then
    Set Session("LAST_BATCH_ERRORS") = mgr.RemoveOwnershipBatch((col), nothing)
     
    If Err.Number <> 0 Then
        EventArg.Error.Save Err
        OK_Click = FALSE       
        Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
        Response.Redirect mdm_GetCurrentFullURL()            
        Exit Function
    End If
              
    ' Get Batch Errors  
    If Session("LAST_BATCH_ERRORS").RecordCount > 0 Then
        EventArg.Error.number = 2015
        EventArg.Error.description = mam_GetDictionary("MAM_ERROR_2015")
        OK_Click = FALSE       
        Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
        Response.Redirect mdm_GetCurrentFullURL()             
        Exit Function
    End If
  End If

  OK_Click = TRUE
  Response.Redirect mam_GetDictionary("SYSTEM_USER_OWNED_ACCOUNTS_DIALOG")   
  
END FUNCTION
%>