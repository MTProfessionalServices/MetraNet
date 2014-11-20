<% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: FailedTransactionEditCompoundParent.asp$
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
'  Created by: F.Torres
' 
'  $Date: 9/27/2002 3:03:16 PM$
'  $Author: Rudi Perkins$
'  $Revision: 3$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"                                    -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE FILE="../../default/lib/FailedTransactionLibrary.asp"     -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

Private m_objRowSet ' As MTSQLRowset - Private Member - This is cool for vbscript - 
                    ' In Each event we have to reset this guy because the value go away in
                    ' between events...
                                        
Form.Initialized = FALSE ' Because of a bug of the MDM, I have to do that;

Form.RouteTo     = mom_GetDictionary("FAILED_TRANSACTION_BROWSER_DIALOG")

'FindRowSetAndSetCurrentRow        ' ' Here we set the service file name dynamically by retreiving some info from a rowset - Set the m_objRowSet

Form.MsixdefExtension = ""

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_Initialize
' PARAMETERS    :  EventArg
' DESCRIPTION   :
' RETURNS       :  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim i, lngCount, objServiceProperty, strXMLMessage 
  
  Service.Clear
  
  Server.ScriptTimeout = 1800 'Increase script timeout for this page to 30 minutes while parsing the xml  

  set Session("ChildSessionsToDeleteCollection") = CreateObject("MetraTech.MTCollectionEx")  

  on error resume next

  ' 6.4 - Take Compound Session id from request and not the rowset
  Dim idFailureCompoundSession
  idFailureCompoundSession = request("FailureCompoundSessionId") 'FailureCompoundSessionId being passed indicates being called from new MetraNet screens
  If Len(idFailureCompoundSession)>0 Then
    '6.4 New Screens
    'Create a new rowset for the single entry in t_failedtransactions and set it in the session and also set m_objRowSet
     Dim  idFailure
     idFailure = Request.QueryString("IdFailure")
    
    If(Len(idFailure))Then
      Form("IdFailure") = idFailure
    End If

    Form("IsPopup") = true

    InitializeRowsetForSingleFailedTransaction(idFailure)
  Else
    Form("IsPopup") = false

    FindRowSetAndSetCurrentRow        ' ' Here we set the service file name dynamically by retreiving some info from a rowset - Set the m_objRowSet
  End If

  If Not GetTransactionXML(m_objRowSet,EventArg,strXMLMessage) Then
    Form_DisplayErrorMessage(EventArg)
    response.end
  End If

 '//Initialize the service from the xml in a retry loop
  dim iRetryCount
  iRetryCount = 12
  for i=0 to iRetryCount-1

      Service.XML(Server.MapPath("/mdm"),Service.Language,,,,,mdm_InternalCache) = strXMLMessage
          If Err.Number Then
            '//If we are on our last retry then display a message
            If i=iRetryCount-1 then
              EventArg.Error.Save Err
              Dim strErrorExplanation

              if CBool(InStr(Err.Description,"-517996519")) then '    if Err.Number = &H80040451 then
                'strErrorExplanation = "Compound Session Id: " & m_objRowSet.Value("FailureCompoundSessionId") & "<BR>"
                'strErrorExplanation = strErrorExplanation & "The failed transaction contains a session id that is currently already in shared memory (duplicate session id). This situation is caused by the same failed transaction being parsed in another process at the same time it is was being parsed here or by an error that has caused the transaction to remain in shared memory (sessions.bin file).<BR>"
                strErrorExplanation = "The failed transaction is currently being opened by another user. Please retry.<BR>"
              else
                strErrorExplanation = "There was an error retrieving the failed transaction. Please retry.<BR>[" & Err.Number & " " & Err.Description & "]<BR>"
              end if
              strErrorExplanation = strErrorExplanation & "<br><div align='center'><a href='" & Form.Routeto & "' target='fmeMain'>Return to Failed Transaction List</a></div>"
  
              on error goto 0
              EventArg.Error.LocalizedDescription =  strErrorExplanation
              EventArg.Error.Description =  strErrorExplanation
              Form_DisplayErrorMessage(EventArg)
              Response.End
            end if

            '//We had an error but we are going to try again
            Err.Clear
            Service.Clear
            CreateObject("MTVBLIB.CWINDOWS").Sleep CLNG(5000)    'Sleep 5 seconds
          Else
            '//No error, exit our retry loop
            Exit For
          End If
   next

      
  Set session("FailedTransaction_Compound_Parent") = Service
  session("FailedTransaction_Compound_Parent_Session_Id") = m_objRowset.Value("FailureCompoundSessionId")
  
  
  '
  ' Extra property
  '
  Dim sServiceNameWithError
  sServiceNameWithError = ucase(m_objRowset.Value("FailureServiceName"))

  Service.Properties.Add "PayerDisplayName", "string", 255, False, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties("PayerDisplayName").Value                 = SafeForHtml(Service.Properties("Payer").Value)
  Service.Properties("PayerDisplayName").Caption     = Service.Properties("Payer").Caption
	
  Service.Properties.Add "ServiceName", "string", 255, False, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties("ServiceName").Value                 = UCASE(Service.Name)
  Service.Properties("ServiceName").Caption     = "" 'mom_GetDictionary("TEXT_SERVICE_NAME")

  Service.Properties.Add "ServiceNameWithError", "string", 255, False, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties("ServiceNameWithError").Value                 = sServiceNameWithError
  Service.Properties("ServiceNameWithError").Caption     = "" 'mom_GetDictionary("TEXT_SERVICE_NAME")
  session("FailedTransaction_ServiceNameWithError") = sServiceNameWithError
  
  Service.Properties.Add "ErrorMessage", "string", 255, False, Empty, eMSIX_PROPERTY_FLAG_NONE  
  Service.Properties("ErrorMessage")            = SafeForHtml(m_objRowSet.Value("ErrorMessage"))
  Service.Properties("ErrorMessage").Caption    = mom_GetDictionary("TEXT_ERROR_MESSAGE")

  Service.Properties.Add "CaseNumber", "integer",0, False, Empty, eMSIX_PROPERTY_FLAG_NONE  
  Service.Properties("CaseNumber")            = m_objRowSet.Value("CaseNumber")
  Service.Properties("CaseNumber").Caption    = mom_GetDictionary("TEXT_ERROR_MESSAGE")

  Service.Properties.Add "CaseStatus", "string", 30, False, Empty, eMSIX_PROPERTY_FLAG_NONE  
  Service.Properties("CaseStatus")            = m_objRowSet.Value("Status")
  Service.Properties("CaseStatus").Caption    = mom_GetDictionary("TEXT_ERROR_MESSAGE")

  Service.Properties.Add "CaseStatusDisplayName", "string", 30, False, Empty, eMSIX_PROPERTY_FLAG_NONE  
  Service.Properties("CaseStatusDisplayName")            = GetFailedTransactionStatusString(m_objRowSet.Value("Status"))
  Service.Properties("CaseStatusDisplayName").Caption    = mom_GetDictionary("TEXT_ERROR_MESSAGE")
  
  Service.Properties.Add "CaseStatusReasonCode", "string", 30, False, Empty, eMSIX_PROPERTY_FLAG_NONE  
  Service.Properties("CaseStatusReasonCode")            = m_objRowSet.Value("StateReasonCode")
  Service.Properties("CaseStatusReasonCode").Caption    = mom_GetDictionary("TEXT_ERROR_MESSAGE")
  
  'Fields for updating status
  Service.Properties.Add "NewStatus"     , "string", 1, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Comment"       , "string", 255, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "InvestigationReasonCode"    , "string", 255, FALSE, "", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "DismissedReasonCode"    , "string", 255, FALSE, "", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ResubmitNow"    , "boolean", 0, FALSE, false, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "CaseStatusUpdated"    , "string", 1, FALSE, "F", eMSIX_PROPERTY_FLAG_NONE
  
  Service.Properties("InvestigationReasonCode").SetPropertyType "ENUM", "metratech.com/failedtransaction", "InvestigationReasonCode"	
  Service.Properties("DismissedReasonCode").SetPropertyType "ENUM", "metratech.com/failedtransaction", "DismissedReasonCode"	
  
  Service.Properties("InvestigationReasonCode").Value=""
  Service.Properties("DismissedReasonCode").Value=""
  if Service.Properties("CaseStatus")="I" then
    Service.Properties("InvestigationReasonCode").Value=Service.Properties("CaseStatusReasonCode") 
  else
    if Service.Properties("CaseStatus")="P" then
      Service.Properties("DismissedReasonCode").Value=Service.Properties("CaseStatusReasonCode") 
    end if
  end if
  
  'Set the template to be used for customized display of parent values
  
  dim sTemplatePath
  sTemplatePath=Server.mappath("\mom\default\dialog\subtemplate\EditFailedTransaction") & "\" & Service.Name & ".htm"
  
  if Service.Tools.TextFile.ExistFile(sTemplatePath) then
    mdm_GetDictionary().Add "CUSTOMIZED_EDIT_FAILED_TRANSACTION_PARENT_SUB_TEMPLATE", sTemplatePath
  else
    mdm_GetDictionary().Add "CUSTOMIZED_EDIT_FAILED_TRANSACTION_PARENT_SUB_TEMPLATE", mom_GetDictionary("DEFAULT_EDIT_FAILED_TRANSACTION_PARENT_SUB_TEMPLATE")
  end if
  
  mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTION_FAILURE_ID"              ,  m_objRowSet.Value("FailureSessionId")  
  mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTION_COMPOUND_FAILURE_ID"     ,  m_objRowSet.Value("FailureCompoundSessionId")    
  mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTION_ERROR_MESSAGE"           ,  m_objRowSet.Value("ErrorMessage") 

  Form_Initialize = Form_Refresh(EventArg)
END FUNCTION


PUBLIC FUNCTION Form_Refresh(EventArg)
  'Refresh the parent values on the page
  Service.Properties("PayerDisplayName").Value                 = SafeForHtml(Service.Properties("Payer").Value)

  'Build a html table that holds the list of children and links
  Dim sChildServiceToShowInitially
  
  Dim htmlChildList, strTempLink
  
  '// Generate child selection display    
  'htmlChildList = "<TABLE><TR class='TableSubHeader'><TD>&nbsp;</TD><TD>Child Type</TD><TD>Number</TD>" & vbNewLine

  Dim objChildrenType 'As MSIXHandlerType
  if not Service.SessionChildrenTypes is nothing then
    For Each objChildrenType In Service.SessionChildrenTypes
        if len(sChildServiceToShowInitially)=0 then
            sChildServiceToShowInitially=objChildrenType.Name
        else
            if ucase(objChildrenType.Name) = Service.Properties("ServiceNameWithError").Value then
                sChildServiceToShowInitially = Service.Properties("ServiceNameWithError").Value
            end if
        end if
    '    strTempLink   = "FailedTransactionEditCompoundChildList.asp?Service=" & server.urlencode(objChildrenType.Name)
    '    htmlChildList = htmlChildList & "<TR style='background-color:white;'><TD><A href='" & strTempLink & "' target='EditChildList'><IMG BORDER=0 alt='' SRC='/newsamplesite/us/images/icons/genericProduct.gif'></A></TD><TD>" & objChildrenType.Name & "</TD><TD> " & objChildrenType.Children.Count & "</TD></TR>"  & vbNewLine    
    Next  
    'htmlChildList = htmlChildList & "</TABLE>" & vbNewLine
    'htmlChildList = htmlChildList & "<script>if (window.parent.EditChildList){ window.parent.EditChildList.location='" & "FailedTransactionEditCompoundChildList.asp?Service=" & sChildServiceToShowInitially & "'};</script>"& vbNewLine
    htmlChildList = htmlChildList & "<script>if (window.parent.EditChildList){ window.parent.EditChildList.location='" & "FailedTransactionEditCompoundChildList.asp'};</script>" & vbNewLine
  end if
  
  mdm_GetDictionary().Add "TEXT_CHILD_TRANSACTION_LIST"                     , htmlChildList  
  
  Form_Refresh = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Populate()
' PARAMETERS		  : 
' DESCRIPTION 		: This event is called by the MDM before it will populate the service MSIXHandler instance...
'                   Here we remove all the value that have a blank string associated because it may cause a type
'                   mistmatch...If the property is required then the error will occur later...
' RETURNS		      : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Populate(EventArg) ' As Boolean
    
      ' If the Check box mdmCheckRequiredField is defined in the query/form string this mean it is set to TRUE,
      ' else this mean we do not want to perform the required field operation
      Service.Configuration.CheckRequiredField = EventArg.UIParameters.Exist("mdmCheckRequiredField")
      Service.LOG "Service.Configuration.CheckRequiredField=" & Service.Configuration.CheckRequiredField
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  OK_Click
' PARAMETERS    :  EventArg
' DESCRIPTION   :
' RETURNS       :  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    dim booRetVal
    
    'Save the edits to the transaction


    OK_Click = FALSE
    
    If SaveFailedSessionXML(EventArg,session("FailedTransaction_Compound_Parent_Session_Id"), session("FailedTransaction_Compound_Parent").xml, Service.Properties("Comment").value) Then
       booRetVal = TRUE
    Else
        Exit Function
    End If

    'If status has changed, update the status as well
    if Service.Properties("CaseStatusUpdated").value="T" then
    
        Dim strNewStatus, strReasonCode
        
        strNewStatus = Service.Properties("NewStatus").value
        
        if strNewStatus="P" then
        
            strReasonCode=Service.Properties("DismissedReasonCode").value
        else
            if strNewStatus="I" then
            
                strReasonCode=Service.Properties("InvestigationReasonCode").value
            end if
        end if        
        booRetVal = UpdateFailedTransactionStatus(session("FailedTransaction_Compound_Parent_Session_Id"),strNewStatus,strReasonCode,Service.Properties("Comment").value)
     end if
      
    if strNewStatus = "C" then
    
        if Service.Properties("ResubmitNow").value then   
            booRetVal = ReSubmitSession(session("FailedTransaction_Compound_Parent_Session_Id"))   
        end if
    end if  
        
    Form.Modal                = TRUE
    Form.JavaScriptInitialize = "window.parent.location='" & Form.RouteTo & "';"
    If (Form("IsPopup")) then
      'Form.JavaScriptInitialize = "window.opener.location='" & Form.RouteTo & "&ID=" & Service.Properties("IntervalID") & "';window.close();"
       Form.JavaScriptInitialize = "window.parent.parent.close();"
    End If
    OK_Click = booRetVal ' Here the event must succeed event if ReMeter failed...
END FUNCTION

FUNCTION Cancel_Click(EventArg) ' As Boolean

    Form.Modal = true
    Form.JavaScriptInitialize = "window.parent.parent.close();"

	  Cancel_Click = TRUE
END FUNCTION

PUBLIC FUNCTION ChildWasDeleted_Click(EventArg)
    
    ChildWasDeleted_Click = TRUE
END FUNCTION

%>

