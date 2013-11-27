<%
' //==========================================================================
' // @doc $Workfile: D:\Dev\UI\client\sites\csr\us\errorActions.asp$
' //
' // Copyright 1998 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //
' // Created by: Dave Wood
' // Modified by: Derek Yound and Frederic Torres.
' //
' // $Date: 05/04/2000 11:45:20 AM$
' // $Author: David Wood$
' // $Revision: 14$
' //==========================================================================

OPTION EXPLICIT
%>
<!-- #INCLUDE VIRTUAL="/mtinclude/prod_incs.asp" -->
<!-- #INCLUDE FILE="../FTemporaryLib.asp" -->
<%

CONST mkstrErrorMark 					= "errorID:"
CONST mkstrSessionMark 					= "sessionID:"
CONST FAILED_TRANSACTION_COM_OBJECT 	= "MTMeteredTrans.MeteredTransaction"
 
CONST TEXT_REMETER_FAILED_TRANSACTION 	= "Can't create COM object MTMeteredTrans.MeteredTransaction!"

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ReMeter()
' DESCRIPTION   : Remeter the current transaction. The different parameters are store in the form...
' PARAMETERS    :
' RETURNS       :
Function ReMeter() ' As Boolean

	Dim 	lngMaxProperties			' As long
	Dim 	strName 					' As String
	Dim 	strValue       				' As String
	Dim 	booFound					' As Boolean
	Dim		strPropertyServiceName		' As String
	Dim 	strPropertyErrorId			' As String
	Dim 	strPropertySessionId		' As String
	Dim 	strPropertyParentSessionId	' As String
	Dim 	objMeteredTransaction		' As Object
	Dim 	strPropertyName				' As String
	Dim 	strPropertyType				' As String
	Dim 	strPropertyValue			' As String

	writeSystemLog "[Asp=errorActions.asp][Function=ReMeter]" &  "ReMeter()",LOG_DEBUG ' #mark 4/14/00 10:56:34 AM
	
	ReMeter = FALSE
	
	strPropertyServiceName		=	GetPropertyParameter("PropertyServiceName")
	strPropertyErrorId			=	GetPropertyParameter("PropertyErrorID")
	strPropertySessionId		=	GetPropertyParameter("PropertySessionID")
	strPropertyParentSessionId	=	GetPropertyParameter("PropertyParentSessionID")
		
	' Create the VB COM object	
	On Error Resume Next
	Err.Clear
	Set objMeteredTransaction = CreateObject(FAILED_TRANSACTION_COM_OBJECT)
	If(err.Number)Then
		Exit Function
	End If
	On Error Goto 0
	    
	' Load the transaction that failed
    Set objMeteredTransaction = objMeteredTransaction.Initialize(strPropertySessionId,strPropertyParentSessionId,strPropertyErrorId)
	
	If(objMeteredTransaction Is Nothing)Then
		writeSystemLog "[Asp=errorActions.asp][Function=ReMeter]" &  "[ERROR] objMeteredTransaction.Initialize FAILED",LOG_DEBUG ' #mark 4/14/00 10:56:34 AM
		Exit Function	
	End If
			
	' Reset the properties of the transaction with the new values from the user
	lngMaxProperties	=	0
	Do
		lngMaxProperties = lngMaxProperties + 1
		strPropertyName	= GetPropertyParameter("PropertyName" & lngMaxProperties)
		If(strPropertyName<>"")Then
					
			strPropertyType		=	GetPropertyParameter("PropertyType"  & lngMaxProperties)
			strPropertyValue	=	GetPropertyParameter("PropertyValue" & lngMaxProperties)
			writeSystemLog "[Asp=errorActions.asp][Function=ReMeter]" &  "SET PROPERTIES " & strPropertyName & " " & strPropertyType & " " & strPropertyValue,LOG_DEBUG ' #mark 4/14/00 10:56:34 AM
			objMeteredTransaction.Properties.Remove strPropertyName
			Select Case UCASE(strPropertyType)
					Case "DATE/TIME"
						objMeteredTransaction.Properties.Add strPropertyName, CDate(strPropertyValue)
					Case "LONG"
						objMeteredTransaction.Properties.Add strPropertyName, CLng(strPropertyValue)
					Case "DOUBLE"
						objMeteredTransaction.Properties.Add strPropertyName, CDbl(strPropertyValue)
					Case "BOOLEAN"
						objMeteredTransaction.Properties.Add strPropertyName, CBool(strPropertyValue)
					Case else ' Case "STRING"
						objMeteredTransaction.Properties.Add strPropertyName, CStr(strPropertyValue)
			End Select								
		Else
			lngMaxProperties = lngMaxProperties - 1	
			Exit Do
		End If		
	Loop
	writeSystemLog "[Asp=errorActions.asp][Function=ReMeter]" &  "[REMETER] Transaction={" & objMeteredTransaction.ToString & "};",LOG_DEBUG ' #mark 4/14/00 10:56:34 AM
	ReMeter	= objMeteredTransaction.ReMeter()
	' Debug Code
	'For i=1 to Request.Form.Count
	' 	Response.write CStr(i) & " " & Request.Form.key(i) & " = " & Request.Form.Item(i) & "<BR>"
	'Next		
End Function




' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
sub resubmit(istrErrorID, istrSessionID)

	call mobjFailures.resubmitSession(istrErrorID)
end sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Function Delete(istrErrorID, istrSessionID) ' As Boolean

	call mobjFailures.AbandonSession(istrErrorID)
	Delete = TRUE
End Function

' 

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Function ReMeterFailedTransaction(strServiceName, lngPropertyCount,strPropertyNameArr, strPropertyValueArr,strPropertyTypeArr) ' As Boolean

    Dim m_objAccountDataSession     'As Session
    Dim m_PipeLine                  'As New CPipeLineAccess
	Dim i
	
	'Response.write "ReMeterFailedTransaction<br>"
	
	Set m_PipeLine = CreateObject("MTCreditCardInfo.CPipeLineAccess")
	
	'Response.write "CreateObject OK<br>"
        
    m_PipeLine.ObjectName 		= "EditedFailedTransaction"
    m_PipeLine.Session 			= strServiceName
    m_PipeLine.RequestResponse 	= False
	
	'Response.write "Init OK<br>"
	
	For i=1 To lngPropertyCount
	
		If(MID(strPropertyNameArr(i),1,1)="_")Then
			' We do not re-meter the reserved property
		Else
			Select Case strPropertyTypeArr(i)
			
					Case "DATE/TIME"
						m_PipeLine.Properties.Add strPropertyNameArr(i), CDate(strPropertyValueArr(i))
					Case "LONG"
						m_PipeLine.Properties.Add strPropertyNameArr(i), CLng(strPropertyValueArr(i))
					Case "DOUBLE"
						m_PipeLine.Properties.Add strPropertyNameArr(i), CDbl(strPropertyValueArr(i))
					Case "BOOLEAN"
						m_PipeLine.Properties.Add strPropertyNameArr(i), CBool(strPropertyValueArr(i))				
					Case else ' Case "STRING"
						m_PipeLine.Properties.Add strPropertyNameArr(i), CStr(strPropertyValueArr(i))
			End Select
		End If
	Next
	
	'Response.write "Add Property<br>"
		
	m_PipeLine.Meter False ' Asynchronous Metering
	
	'Response.write "ReMeterFailedTransaction SUCCEED<br>"
	ReMeterFailedTransaction	=	TRUE
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Function GetPropertyParameter(strProperty) ' As String	
	Dim ii ' As long

	GetPropertyParameter = ""
	For ii=1 to Request.Form.Count
	
		If(Request.Form.key(ii) = strProperty)Then
		
			GetPropertyParameter	=	Request.Form.item(ii)
			Exit Function
		End If
	Next
End Function





' START THE PROCESSING
'	on error resume next
	
	dim mobjFailures ' as object
	set mobjFailures = server.createObject("MetraPipeline.MTSessionFailures.1")
	
	dim strIds
	dim strErrorId
	dim strSessionId
	dim arrstrIds
	dim i
	dim intErrorLocation
	dim intSessionLocation1
	dim intSessionLocation2
	
	If(len(request.form("btnReMeter"))>0)Then						
		
		ReMeter
	End If
	
	If(request.form("batch") = "Y")Then
		
		strIds = request.form("ckbItems")
		if len(strIds) > 0 then
		
			arrstrIds = split(strIds, ", ")
			
			for i = 0 to ubound(arrstrIds)
			
				intErrorLocation 	= instr(arrstrIds(i), mkstrErrorMark) + len(mkstrErrorMark)
				intSessionLocation1 = instr(arrstrIds(i), mkstrSessionMark)
				intSessionLocation2 = intSessionLocation1 + len(mkstrSessionMark)
				strErrorId 			= mid(arrstrIds(i), intErrorLocation, intSessionLocation1 - intErrorLocation)  
				strSessionId 		= mid(arrstrIds(i), intSessionLocation2, len(arrstrIds(i)) - intSessionLocation2 + 1) 
					
				if len(request.form("btnDelete")) > 0 then
				
					call delete(strErrorId, strSessionId)
					
				elseif len(request.form("btnResubmit")) > 0 then
				
					call resubmit(strErrorId, strSessionId)
				End If
			next
		end if
	else
		if request.queryString("action") = "restart" then
		
			call resubmit(request.querystring("errorID"), request.queryString("sessionId"))
			
		elseif request.queryString("action") = "delete" then
		
			call delete(request.querystring("errorID"), request.queryString("sessionId"))
		end if
	end if
	
	set mobjFailures = nothing
	'if err then
	'	response.write "ERR: " & err.description
	'	response.end
	'end if
	dim strReferer
	strReferer = request.serverVariables("HTTP_REFERER")
	if instr(strReferer, "Refresh=Y") > 0 then
		response.reDirect(strReferer)
	else
		response.redirect(strReferer & "&Refresh=Y")
	end if	
 %>


