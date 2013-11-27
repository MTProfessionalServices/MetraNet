<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2000 by MetraTech Corporation
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
'
' MetraTech Dialog Manager Framework ASP Dialog Template
' 
' DIALOG	    :
' DESCRIPTION	:
' AUTHOR	    :
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit

%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<%

' http://Localhost/mam/default/dialog/Dictionary.asp?Action=Set&NameValue=PV_ROW_PER_PAGE,1000,MAX_ROW_PER_PICKER_PAGE,1000,MAX_ROW_PER_LIST_PAGE,1000

Dim strAction, arrNameValue, strData, i

strAction     = Request.QueryString("Action")
arrNameValue  = Split(Request.QueryString("NameValue"),",")

strData = strData & "<H1>Dictionary Entries Dynamically Set</H1><HR Size=1>"

Select Case UCase(strAction)

    CASE "ADD","SET"
        For i=0 To UBound(arrNameValue) Step 2
            FrameWork.Dictionary.Add arrNameValue(i),arrNameValue(i+1)
            strData = strData & "Set " & arrNameValue(i) & "=" & FrameWork.Dictionary.Item(arrNameValue(i)).Value & "<br>"
        Next
End Select
Response.write strData & "<br>"
Response.End

%>

