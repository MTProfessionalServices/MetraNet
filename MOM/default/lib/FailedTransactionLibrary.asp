<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' NAME		        : mom - MetraTech Account Manager - VBScript Library
' VERSION	        : 1.0
' CREATION_DATE     : 09/xx/2000
' AUTHOR	        : F.Torres.
' DESCRIPTION	    : Contains different usefull functions for theM App.
'               
' ----------------------------------------------------------------------------------------------------------------------------------------

'PRIVATE m_objMTPipeLine 			' Object ' Stored in session in MOM 3.0 for speed reason
PRIVATE m_objMTSessionServer 	' Object

Const SESSION_PROPERTY_TYPE_DATE     = 1 ' In a metered session the type have an index, this index is not the VT_XXXX index...
Const SESSION_PROPERTY_TYPE_TIME     = 2
Const SESSION_PROPERTY_TYPE_STRING   = 3
Const SESSION_PROPERTY_TYPE_LONG     = 4
Const SESSION_PROPERTY_TYPE_DOUBLE   = 5
Const SESSION_PROPERTY_TYPE_BOOLEAN  = 6
Const SESSION_PROPERTY_TYPE_ENUM     = 7
Const SESSION_PROPERTY_TYPE_DECIMAL  = 8
  
CONST XML_TAG_END_SESSION     = "</SESSION>"
CONST XML_TAG_START_SESSION   = "<SESSION>"

CONST SESSION_PROPERTY_STRING_TYPE_DATETIME  = "TIMESTAMP"  ' MSIX Type
CONST SESSION_PROPERTY_STRING_TYPE_LONG      = "INT32"
CONST SESSION_PROPERTY_STRING_TYPE_DOUBLE    = "DOUBLE"
CONST SESSION_PROPERTY_STRING_TYPE_DECIMAL   = "DECIMAL"
CONST SESSION_PROPERTY_STRING_TYPE_BOOLEAN   = "BOOLEAN"          
CONST SESSION_PROPERTY_STRING_TYPE_STRING    = "STRING"
CONST SESSION_PROPERTY_STRING_TYPE_ENUM      = "ENUM"

CONST FAILED_TRANSACTIONS_ROWSET_SESSION_NAME = "FailedTransactionsRowset"

' VB COM Object Name



CONST FAILED_TRANSACTION_ERROR_5000 = "5000-FAILED TRANSACTION-ERROR-The session [SESSION_ID] cannot be found. Check the error queue."
CONST FAILED_TRANSACTION_ERROR_5001 = "5001-FAILED TRANSACTION-ERROR-Error while retreiving the transaction in the rowset"
CONST LOST_TRANSACTION_ERROR_5002 = "5002-LOST TRANSACTION-ERROR-Cannot find Lost Message for UID [UID] "

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: Failed_Transaction_Convert
' PARAMETERS		:
' DESCRIPTION 	: When a property is resubmit we must give a variant with the right type
'                 But the UI return string...So
' RETURNS			  :
FUNCTION Failed_Transaction_Convert(strValue,strType)

  Dim varRetVal
  Select Case  strType

      CASE  SESSION_PROPERTY_STRING_TYPE_DATETIME : varRetVal = CDate(strValue)
      CASE  SESSION_PROPERTY_STRING_TYPE_LONG     : varRetVal = CLng(strValue)
      CASE  SESSION_PROPERTY_STRING_TYPE_DOUBLE   : varRetVal = CDbl(strValue)
      CASE  SESSION_PROPERTY_STRING_TYPE_DECIMAL  : varRetVal = CDec(strValue)
      CASE  SESSION_PROPERTY_STRING_TYPE_BOOLEAN  : varRetVal = CBool(strValue)
      CASE  SESSION_PROPERTY_STRING_TYPE_STRING   : varRetVal = CStr(strValue)
      CASE  Else
          varRetVal = strValue ' Return as is...
  End Select
  Failed_Transaction_Convert  = varRetVal
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetMTPipeLineObject
' DESCRIPTION   : In 3.0 we store the object in the pipeline. Looks like in  IIS Proces Level Medium the creation of this
' PARAMETERS    : object is very slow! That's why we store it into the session;
' RETURNS       :
PRIVATE FUNCTION GetMTPipeLineObject() ' As Object

    If(Not IsValidObject(Session("MetraPipeline")))Then
    
        Set Session("MetraPipeline") = mdm_CreateObject("MetraPipeline.MTPipeline.1")
    End If
    Set GetMTPipeLineObject = Session("MetraPipeline")
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetMTSessionServerObject
' DESCRIPTION   : Only store in the current page
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION GetMTSessionServerObject() ' As Object

    If(Not IsValidObject(m_objMTSessionServer))Then Set m_objMTSessionServer = GetMTPipeLineObject().SessionServer
    Set GetMTSessionServerObject = m_objMTSessionServer
    
 '   If(Not IsValidObject(Session("MTSessionServer")))Then
  '      Set Session("MTSessionServer") = GetMTPipeLineObject().SessionServer
   ' End If
    'Set GetMTSessionServerObject = Session("MTSessionServer")
END FUNCTION


PRIVATE FUNCTION GetSessionFailureObject() ' As Object

    If(Not IsValidObject(Session("SessionFailureObject")))Then
    
        Set Session("SessionFailureObject") = mdm_CreateObject(MTPROGID_SESSIONFAILURES)
    End If
    Set GetSessionFailureObject = Session("SessionFailureObject")
END FUNCTION

PUBLIC FUNCTION GetFailedSession(EventArg,strUID, ByRef strXML) ' As IMTSession

  on error resume next
	Dim objSessionServer ,  strError, objSessionError, objSessionFailure
	
  ' -- These 1 instance need to be created to deal with session --  
  Set objSessionServer 	= GetMTSessionServerObject()
  Set GetFailedSession  = Nothing ' Default return value
  Set objSessionFailure	= GetSessionFailureObject()
  
  Set objSessionError  = objSessionFailure.Item(strUID)
   If(Err.Number)Then
	
      EventArg.Error.Number       = Err.Number
      strError                    = "Cannot retreive the failed session("""  & strUID & """) failed. error=" & mdm_GetErrorString()
      EventArg.Error.Description  = strError
      Exit Function
  End If
  Set GetFailedSession = objSessionError.Session
  strXML               = objSessionError.XMLMessage

  If(Err.Number)Then
	
      EventArg.Error.Number       = Err.Number
      strError                    = "Cannot retreive the failed session("""  & strUID & """) failed. error=" & mdm_GetErrorString()
      strError                    = Replace(FAILED_TRANSACTION_ERROR_5000,"[SESSION_ID]",strUID) & "<BR>" & strError
      EventArg.Error.Description  = strError

      Exit Function
  End If
	
 
  On Error Goto 0
END FUNCTION

PUBLIC FUNCTION SaveFailedSessionXML(EventArg,strUID, ByRef strXML, strComment) 'As BOOL
  on error resume next
	Dim objSessionServer ,  strError, objSessionError, objSessionFailure
	
  ' -- These 1 instance need to be created to deal with session --  
  Set objSessionServer 	= GetMTSessionServerObject()
  Set objSessionFailure	= GetSessionFailureObject()  
  Set objSessionError   = objSessionFailure.Item(strUID)
  
  'dim strChildUID
  'for each strChildUID in Session("ChildSessionsToDeleteCollection")
	'response.Write "Deleting child UID [" & strChildUID & "]<BR>"
  'next
  'response.End
  objSessionError.SaveXMLMessage strXML, Session("ChildSessionsToDeleteCollection")
	
  If(Err.Number)Then
      EventArg.Error.Description  = mdm_GetErrorString()
      EventArg.Error.Number       = Err.Number
      SaveFailedSessionXML        = FALSE
      Exit Function
  Else
      SaveFailedSessionXML  = TRUE ' Default return value
  End If
  On Error Goto 0
  
  'Record Audit Event
    '// Eventually put this inside of the object
    dim objAuditor
    Set objAuditor = CreateObject("MetraTech.Auditor")
    dim iEventId, iUserId, iEntityTypeId, iEntityId, sDetails
    iEventId = 1700 '// Update Transaction Details
    iUserId = Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").AccountId
    iEntityTypeId = 5

    iEntityId = GetFailureIdFromFailedTransactionCompoundUID(strUID)
    sDetails = strComment
    
    call objAuditor.FireEvent(iEventId, iUserId, iEntityTypeId, iEntityId, sDetails)
  
  
END FUNCTION


PRIVATE FUNCTION GetLostMessage(strUID)
		Dim strError
		On Error Resume Next
		GetLostMessage = GetMTPipeLineObject().GetLostMessage(strUID)
		If err.Number Then
				strError      = Replace(LOST_TRANSACTION_ERROR_5002,"[UID]",strUID)
				mdm_LogError  = strError
				GetLostMessage= strError
		End If
END FUNCTION

PRIVATE FUNCTION GetTransactionXML(objRowset,EventArg,strXMLMessage) ' As Boolean
  
  Dim strFailureCompoundID, strSessionID, objSession
  
  GetTransactionXML         = FALSE
  strFailureCompoundID      = objRowset.Value("FailureCompoundSessionId")
  strSessionID              = objRowset.Value("FailureSessionId")
	Set objSession            = GetFailedSession(EventArg,strFailureCompoundID,strXMLMessage) ' Get the parent
  
  if len(strXMLMessage)=0 then
    GetTransactionXML=FALSE
  else
    GetTransactionXML = TRUE
  end if
  
END FUNCTION

'6.4 FUNCTION For intializing the session rowset when we no long store the complete rowset in session
'Should be functionally equivalent to FindRowSetAndSetCurrentRow
PRIVATE FUNCTION InitializeRowsetForSingleFailedTransaction(idFailedTransaction)
  dim sQuery, sQueryWhereClause, rowset

  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\mom"
  rowset.SetQueryTag("__GET_FAILED_TRANSACTION_LIST_SINGLE__")
  rowset.AddParam "%%ID_FAILED_TRANSACTION%%", Cstr(idFailedTransaction)
  rowset.Execute

  Set Session("FAILED_TRANSACTIONS_ROWSET_SESSION_NAME")  = rowset

  Set m_objRowSet = rowset

  InitializeRowsetForSingleFailedTransaction = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_Initialize
' PARAMETERS    :  EventArg
' DESCRIPTION   :
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION FindRowSetAndSetCurrentRow()



    Dim objTools
    Dim lngIdSession
    Dim strIdSession
    
   
    Set objTools  = mdm_CreateObject(MSIXTOOLS_PROG_ID)
    
    ' Search the value in the query string if it not there
    ' that's mean the Form is already initialized we pull the value from the Form Object.

    strIdSession = Request.QueryString("IdFailure")
    
    'response.write " strIdSession=" &  strIdSession & "<br>"
    
    If(Len(strIdSession))Then
    
        Form("IdFailure") = strIdSession
    End If
    
    
    Set m_objRowSet = Session("FAILED_TRANSACTIONS_ROWSET_SESSION_NAME")
  ' Find in the rowset the transaction the user just selected
  
    'response.write "Form('IdSession')=" & Form("IdSession") & "<br>"
    If(objTools.RowSetQuickFind(m_objRowSet,"CaseNumber",CStr(Form("IdFailure"))))Then
    
      	FindRowSetAndSetCurrentRow = TRUE
    Else
        FindRowSetAndSetCurrentRow = FALSE
        response.write "Form('IdFailure')=" & Form("IdFailure") & "<BR>"
        mdm_LogError FAILED_TRANSACTION_ERROR_5001
        response.write FAILED_TRANSACTION_ERROR_5001 & "<br>"        
        mdm_DisplayDebugInfo ARRAY("","")
        response.end
    End If
END FUNCTION


PRIVATE FUNCTION MSIXPropertyCrypted(strPropertyName) ' As Boolean
    MSIXPropertyCrypted = CBool(Mid(strPropertyName,Len(strPropertyName),1)="_")
END FUNCTION

PRIVATE FUNCTION GetServiceFileName()

  Dim strS
  
  If IsEmpty(m_objRowset) Then
    GetServiceFileName = m_strServiceName 
  Else  
    strS                = m_objRowset.Value("FailureServiceName") & ".msixdef"
    strS                = Replace(strS,SLASH,ANTI_SLASH)
    GetServiceFileName  = strS
  End if
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : BulkUpdateFailedTransactionStatus
' DESCRIPTION : Update status on failed transaction selection in bulk
' PARAMETERS  : FailureIdCollection, sNewStatus, sNewReasonCode, sComment
' RETURNS     : 
PUBLIC FUNCTION BulkUpdateFailedTransactionStatus(FailureIdCollection, sNewStatus, sNewReasonCode, sComment) 
  on error resume next
  BulkUpdateFailedTransactionStatus = FALSE

  Dim objBulkFailed
  Set objBulkFailed = mdm_CreateObject("MetraTech.Pipeline.ReRun.BulkFailedTransactions")

  Set objBulkFailed.SessionContext = FrameWork.SessionContext
  objBulkFailed.UpdateStatusCollection (FailureIdCollection), sNewStatus, sNewReasonCode, sComment 
  If Not mom_CheckError("BulkUpdateFailedTransactionStatus") Then Exit Function
  
  BulkUpdateFailedTransactionStatus = TRUE
  on error goto 0
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : BulkResubmitFailedTransactions
' DESCRIPTION : Asynchrounously resubmit failed transactions
' PARAMETERS  : FailureIdCollection
' RETURNS     : TRUE / FALSE
PUBLIC FUNCTION BulkResubmitFailedTransactions(FailureIdCollection)
    on error resume next
    BulkResubmitFailedTransactions = FALSE
    
  	Dim objPipeline, objReRun, rerunID
      
  	Set objPipeline = mdm_CreateObject("MetraTech.Pipeline.ReRun.BulkFailedTransactions")
    Set objReRun = mdm_CreateObject(MT_BILLING_RERUN_PROG_ID)  
      
    Set objPipeline.SessionContext = FrameWork.SessionContext  
    rerunID = objPipeline.ResubmitCollectionAsync((FailureIdCollection))
    If Not mom_CheckError("ResubmitCollectionAsync") Then Exit Function
    
    objReRun.Login FrameWork.SessionContext
    objReRun.ID = rerunID
  	objReRun.Synchronous = FALSE
    If Not mom_CheckError("ReRun Login") Then Exit Function
  
    If not objReRun.IsComplete Then
      Session("FAILEDTRANSACTION_CURRENT_RERUNID") = rerunID
      Session("FAILEDTRANSACTION_CURRENT_STATUS_MESSAGE") = "Submission of failed transactions is in progress..."
      Session("FAILEDTRANSACTION_CURRENT_COMMENT") = ""
      mdm_TerminateDialogAndExecuteDialog "FailedTransactionWait.asp?ReturnUrl=" & mom_GetDictionary("FAILED_TRANSACTION_BROWSER_DIALOG") & "&Title=" & Server.UrlEncode("Submitting Failed Transactions") & "&MessageTitle=" & Server.UrlEncode("Resubmit Status:")
    Else
      Session("FAILEDTRANSACTION_CURRENT_RERUNID") = Empty
      Session("FAILEDTRANSACTION_CURRENT_STATUS_MESSAGE") = "Done."
      Session("FAILEDTRANSACTION_CURRENT_COMMENT") = "Done"
    End If
    
    Form.RouteTo = mom_GetDictionary("FAILED_TRANSACTION_BROWSER_DIALOG") & "?MDMAction=" & MDM_ACTION_REFRESH          

    BulkResubmitFailedTransactions = TRUE  
    on error goto 0
END FUNCTION

PRIVATE FUNCTION UpdateFailedTransactionStatus(strFailedCompoundTransactionId,strNewStatus,strReasonCode,strComment)

  'Use the bulk method for updating the status of this transaction
  Dim objCol
  Set objCol = Server.CreateObject("Metratech.MTCollection.1")
  objCol.Add strFailedCompoundTransactionId
  
  UpdateFailedTransactionStatus = BulkUpdateFailedTransactionStatus(objCol, strNewStatus, strReasonCode, strComment) 
  
END FUNCTION

PRIVATE FUNCTION GetFailureIdFromFailedTransactionCompoundUID(strFailedCompoundTransactionId)

  dim sQuery, sQueryWhereClause   
  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\audit"
  sQuery = "select max(id_failed_transaction) as id_failed_transaction from t_failed_transaction where tx_FailureCompoundId_Encoded='" & strFailedCompoundTransactionId & "'"

  rowset.SetQueryString(sQuery & sQueryWhereClause)
  rowset.Execute

  GetFailureIdFromFailedTransactionCompoundUID = rowset.value("id_failed_transaction")

END FUNCTION

PRIVATE FUNCTION GetFailedTransactionStatusString(strStatusCode)

  select case strStatusCode
  case "N"
    GetFailedTransactionStatusString = mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_STATUS_OPEN")
  case "I"
    GetFailedTransactionStatusString = mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_STATUS_UNDER_INVESTIGATION")
  case "C"
    GetFailedTransactionStatusString = mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_STATUS_CORRECTED")
  case "P"
    GetFailedTransactionStatusString = mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_STATUS_DISMISSED")
  case "R"
    GetFailedTransactionStatusString = mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_STATUS_RESUBMITTED")
  case "D"
    GetFailedTransactionStatusString = mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_STATUS_DELETED")
  case else
    GetFailedTransactionStatusString = "UNKNOWN STATUS"
  end select
  
END FUNCTION

' -------------------------------------------------------------------------------------------------
' FUNCTION    :  ReSubMitSession
' DESCRIPTION :  Resubmit a failed transaction.  This method creates a collection of one and uses
'                the bulk interface.
' PARAMETERS  :  Failure ID
' RETURNS     :  TRUE / FALSE
PRIVATE FUNCTION ReSubMitSession(istrErrorID) ' As Boolean
  On Error Resume Next
  Dim FailureIdCollection
  Set FailureIdCollection = CreateObject("MetraTech.MTCollectionEx")
  FailureIdCollection.Add istrErrorID
  ReSubMitSession = BulkResubmitFailedTransactions(FailureIdCollection)
END FUNCTION

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
PRIVATE FUNCTION ResubmitLostSession(istrErrorID) ' As Boolean

	Dim mobjFailures ' as object
	Set mobjFailures = mdm_CreateObject("MetraPipeline.MTSessionFailures.1")

  On Error Resume Next
  mobjFailures.ResubmitLostSession CStr(istrErrorID)
  ResubmitLostSession   = CBool(Err.Number=0)

  '// Eventually put this inside of the state change object
  dim objAuditor
  Set objAuditor = CreateObject("MetraTech.Auditor")
  dim iEventId, iUserId, iEntityTypeId, iEntityId, sDetails
  iEventId = 1702 '// Resubmit
  iUserId = Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").AccountId
  iEntityTypeId = 5 'Service.Properties("ENTITY_TYPE_ID")

  iEntityId = GetFailureIdFromFailedTransactionCompoundUID(istrErrorID)
  'sDetails = "Status Changed To '" & GetFailedTransactionStatusString(strNewStatus) & "'"
  'if len(strReasonCode)>0 then
  '  sDetails = sDetails & " : " & strReasonCode
  'end if
  'sDetails = sDetails & " : " & strComment
  
  call objAuditor.FireEvent(iEventId, iUserId, iEntityTypeId, iEntityId, sDetails)
  
  Set mobjFailures  = Nothing
	
End Function

%>