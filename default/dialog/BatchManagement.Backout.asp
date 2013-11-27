<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BatchManagement.Backout.asp$
' 
'  Copyright 1998-2003 by MetraTech Corporation
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
'  Created by: Rudi
' 
'  $Date: 11/15/2002 4:44:38 PM$
'  $Author: Rudi Perkins$
'  $Revision: 2$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

PRIVATE CONST enum_FT_BULK_CHANGE_ALL                   = 1
PRIVATE CONST enum_FT_BULK_CHANGE_IF_PREVIOUS_VALUE_IS  = 2

Form.Version = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo			              = "BatchManagement.ViewEdit.asp?BatchEncodedId=" & server.urlencode(Request.querystring("BatchId")) & "&BatchTableId=" & Request.querystring("BatchTableId")
Form.Modal                      = FALSE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean


	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  Form("BatchId") = Request.QueryString("BatchId")                  
  Form("BatchTableId") = Request.QueryString("BatchTableId")
  Form("BatchAction") = Request.QueryString("BatchAction")
  
  
  ' 1-Change all - 2-If Previous value is
  Service.Properties.Add "PageTitle"     , "string", 255, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Comment"     , "string", 255, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  
  
  'Set the title for the page
  select case Form("BatchAction")
    case "F"
      Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_BATCH_MANANAGEMENT_MARK_AS_FAILED_TITLE")
    case "C"
      Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_BATCH_MANANAGEMENT_MARK_AS_COMPLETED_TITLE")
    case "D"
      Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_BATCH_MANANAGEMENT_MARK_AS_DISMISSED_TITLE")
    case "B"
      Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_BATCH_MANANAGEMENT_BACKOUT_TITLE")
    case else
      Service.Properties("PageTitle").Value = "Doing some stuff"
   end select
   

  'PopulateThePropertyComboBox
  
  Service.LoadJavaScriptCode  
  
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  PopulateThePropertyComboBox
' PARAMETERS    :  Retreive the first child and loop through its msix property, build a temporary CVariables collection with
'                  name,value,caption and then pass it to the property property of the dialog.
' DESCRIPTION   :
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION PopulateThePropertyComboBox()

  Dim strChildrenType, objMSIXFirstChild, objMSIXProperty, objDyn
  
  PopulateThePropertyComboBox   = FALSE
  
  Set objDyn                    = mdm_CreateObject(CVariables)  
  Set objMSIXFirstChild         = Session("FailedTransaction_Compound_Parent").SessionChildrenTypes(Form("ChildrenType")).Children(1)
  
  For Each objMSIXProperty In objMSIXFirstChild.Properties  
  
      objDyn.Add objMSIXProperty.Name,objMSIXProperty.Name, , , objMSIXProperty.Caption
  Next  
  Service.Properties("Property").AddValidListOfValues objDyn
  
  PopulateThePropertyComboBox = TRUE
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    'On Error Resume Next

  'Update the status of the batch    
  dim mtbatch
  Set mtbatch = CreateObject(MT_BATCH_PROG_ID)
  'mtbatch.LoadByUID BATCH_UID

	'mtbatch.Operator = "Cyndi Lauper (Head Office), Hoboken New Jersey"
	'mtbatch.Action = "Backing out -- Bad Data Encountered"
	'mtbatch.Comment = Service.Properties("Comment").Value

  'mtbatch.LoadByID Form("BatchTableId")
  'mtbatch.LoadByUID Form("BatchId")
  'mtbatch.Status = Form("BatchAction")
  
  select case Form("BatchAction")
  case "F"
    mtbatch.MarkAsFailed Form("BatchId"), Service.Properties("Comment").Value
  case "D"
    mtbatch.MarkAsDismissed Form("BatchId"), Service.Properties("Comment").Value
  case "C"
    mtbatch.MarkAsCompleted Form("BatchId"), Service.Properties("Comment").Value
  'case "B"
    'mtbatch.MarkAsBackout Form("BatchId"), Service.Properties("Comment").Value
  end select
  
  

  if false then
  dim iEventId, iUserId, iEntityTypeId, iEntityId, sDetails
  'iEventId = 1751
  select case Form("BatchAction")
  case "F"
    iEventId = 1751
  case "C"
    iEventId = 1755
  case "D"
    iEventId = 1754
  case "B"
    iEventId = 1752    
  case else
    iEventId = 0
  end select
    
  iUserId = Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").AccountId
  iEntityTypeId = 6
  iEntityId = Form("BatchTableId")
  sDetails = Service.Properties("Comment").Value

  dim objAuditor
  Set objAuditor = CreateObject("MetraTech.Auditor")
    
  call objAuditor.FireEvent(iEventId, iUserId, iEntityTypeId, iEntityId, sDetails)  
  end if
  
  OK_Click = TRUE

  if Form("BatchAction")="B" then
    Form.RouteTo			              = "BackOutRerun.BackoutStep1.asp" & "?ReturnUrl=" & server.urlencode(Form.RouteTo) & "&BatchTableId=" & Form("BatchTableId") & "&BatchId=" & server.urlencode(Form("BatchId")) & "&BatchComment=" & server.urlencode(Service.Properties("Comment").Value)
  end if    

END FUNCTION

Function BackoutBatch(sBatchId, sComment)

    on error resume next
    
    dim objReRun
    Set objReRun = CreateObject(MT_BILLING_RERUN_PROG_ID)
    
    objReRun.Login FrameWork.SessionContext
    
    objReRun.Setup "Batch Backout:" & sComment    
    If Not CheckError("MTBillingReRun.Setup") Then Exit Function
    
    dim objFilter
    Set objFilter = CreateObject(MT_BILLING_IDENTIFICATION_FILTER_ID)
    
    objFilter.BatchID        = sBatchId
    
    'm_strStep = "MTBillingReRun.Identify"
    objReRun.Identify objFilter , sComment
    If Not CheckError("MTBillingReRun.Identify") Then Exit Function
    
    ' In advanced mode we let the use finish the rest of the operation manually
    ''If Service.Properties("AdvancedBackOut").Value Then
    
    '  OK_Click = TRUE        
    '  Exit Function
    'End If
    
    'm_strStep = "MTBillingReRun.Analyze"
    objReRun.Analyze sComment
    If Not CheckError("MTBillingReRun.Analyze") Then Exit Function
    
    'm_strStep = "MTBillingReRun.Backout"
    objReRun.Backout sComment
    If Not CheckError("MTBillingReRun.Backout") Then Exit Function
    
    'm_strStep = "MTBillingReRun.Prepare"
    objReRun.Prepare sComment
    If Not CheckError("MTBillingReRun.Prepare") Then Exit Function
    
    'm_strStep = "MTBillingReRun.Extract"
    objReRun.Extract sComment
    If Not CheckError("MTBillingReRun.Extract") Then Exit Function
    
    BackoutBatch = TRUE

End Function

PRIVATE FUNCTION CheckError(sBackoutStep) ' As Boolean

    CheckError = FALSE
    If(Err.Number)Then 
        EventArg.Error.Save Err 
        EventArg.Error.Description = EventArg.Error.Description & "; Step=" & sBackoutStep
        Err.Clear 
        Exit Function
    End If        
    CheckError = TRUE
END FUNCTION

%>



