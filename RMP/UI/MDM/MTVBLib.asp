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
' NAME                  : MetraTech Visual Basic Library
' VERSION               : 1.0
' CREATION_DATE         : 9/14/2000
' AUTHOR                : F.Torres.
' DESCRIPTION           : All purposes generic class. This file declare consts exported from the VB MTVBLIB COM Object.
'
'
'
' ----------------------------------------------------------------------------------------------------------------------------------------

' Batch Components 3.5
PUBLIC CONST MT_BATCH_PROG_ID             = "MetraTech.Pipeline.Batch.BatchObject"

' Billing re run 3.5
'PUBLIC CONST MT_BILLING_RERUN_PROG_ID             = "MetraTech.MTBillingReRun"
PUBLIC CONST MT_BILLING_RERUN_PROG_ID             = "MetraTech.Pipeline.ReRun.Client"
PUBLIC CONST MT_BILLING_IDENTIFICATION_FILTER_ID  = "MetraTech.MTIdentificationFilter"

' Hierarchies - 3.0
PUBLIC CONST MT_YAAC_PROG_ID 											= "MetraTech.MTYAAC.1"
PUBLIC CONST MT_MSIX_ACCOUNT_TEMPLATE_PROG_ID 		= "MTHierarchyHelper.MSIXAccountTemplate"
PUBLIC CONST MT_HIERARCHY_HELPER_PROG_ID          = "MTHierarchyHelper.HierarchyHelper"
PUBLIC CONST MT_COLLECTION_PROG_ID                = "Metratech.MTCollection.1"
PUBLIC CONST MT_COLLECTIONEX_PROG_ID                = "Metratech.MTCollectionEx.1"
PUBLIC CONST MT_PROGRESS_READER_PROG_ID           = "MetraTech.MTProgressReader.1"
PUBLIC CONST MT_SQL_ROWSET_SIMULATOR_PROG_ID      = "MTMSIX.MTSQLRowsetSimulator"
PUBLIC CONST MT_RCD_PROG_ID                       = "MetraTech.Rcd.1"
PUBLIC CONST MT_ACCOUNT_CATALOG_PROG_ID           = "MetraTech.MTAccountCatalog"
PUBLIC CONST MT_SE_WRITER_PROG_ID                 = "MetraTech.MTServiceEndpointWriter"
PUBLIC CONST MT_SE_READER_PROG_ID                 = "MetraTech.MTServiceEndpointReader"
PUBLIC CONST MT_SE_ID_MAPPING_PROG_ID             = "MetraTech.MTServiceEndpointIDMapping"
PUBLIC CONST MT_SE_CONN_INFO_PROG_ID              = "MetraTech.MTServiceEndpointConnectionIn"

PUBLIC CONST MT_ACCOUNT_STATE_MANAGER_PROG_ID     = "MTAccountStates.MTAccountStateManager.1"

PUBLIC CONST MT_PRODUCT_CATALOG_PROG_ID           = "Metratech.MTProductCatalog.1"

' MTVBlib Prog Id Consts
Const CVariables = "MTVBLib.CVariables"
Const CTextFile = "MTVBLib.CTextFile"
Const CPreProcessor = "MTVBLib.CPreProcessor"
Const CProfiler = "MTVBLib.CProfiler"
Const CStringConcat = "MTVBLib.CStringConcat"
Const CTool = "MTVBLib.CTool"
Const CByteSyntaxAnalyser = "MTVBLib.CByteSyntaxAnalyser"
Const CDecimal = "MTVBLib.CDecimal"
Const MTSQLRowset = "MTSQLRowset.MTSQLRowset.1"
Const MTSQLRowsetFilter = "MTSQLRowset.MTDataFilter.1"
Const CWindows = "MTVBLib.CWindows"

Const MTPROGID_SESSIONFAILURES = "MetraPipeline.MTSessionFailures.1"
Const MTPROGID_PIPELINE        = "MetraPipeline.MTPipeline.1"

' Put the guys at the end of the file because of a home site bug...
Const ANTI_SLASH = "\"
Const SLASH = "/"

Public Function MTSQLRowset_GetColumnPreFix(objMTSQLRowSet, ByVal strColumnName)

    If UCase(TypeName(objMTSQLRowSet))="ICOMPRODUCTVIEW" Then
    
      If Not MTSQLRowset_IsColumnBelongToT_ACC_USAGE(objMTSQLRowSet, strColumnName) Then
  
        MTSQLRowset_GetColumnPreFix = "c_"
      End If
    ENd If
End Function

Public Function MTSQLRowset_IsColumnBelongToT_ACC_USAGE(objMTSQLRowSet, ByVal strColumnName)

   Dim objPropertiesDef
   Const COLUNM_NAME_INDEX = 5

   MTSQLRowset_IsColumnBelongToT_ACC_USAGE = False

   On Error Resume Next
   Set objPropertiesDef = Service.Properties.Rowset.GetProperties
   If Err.Number Then Err.Clear: Exit Function
   On Error GoTo 0

   strColumnName = UCase(strColumnName)

   objPropertiesDef.MoveFirst
   Do While Not objPropertiesDef.EOF

     If strColumnName = UCase(objPropertiesDef.Value(COLUNM_NAME_INDEX)) Then

        MTSQLRowset_IsColumnBelongToT_ACC_USAGE = True
        Exit Function
     End If
     objPropertiesDef.MoveNext
   Loop
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION              : mtvblib_IsInRange
' PARAMETERS    :
' DESCRIPTION :
' RETURNS                 :
Private Function mtvblib_IsInRange(varValue, varMinValue, varMaxValue) ' As Boolean

    mtvblib_IsInRange = CBool((varValue >= varMinValue) And (varValue <= varMaxValue))
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION              :
' PARAMETERS    :
' DESCRIPTION :
' RETURNS                 :
Private Function mtvblib_CreateObject(strProgId) ' As Object

    Set mtvblib_CreateObject = CreateObject(strProgId)
    Exit Function
    
    Dim obj
    On Error Resume Next
    Err.Clear

    Set obj = CreateObject(strProgId)
    If (Err.Number) Then
        On Error GoTo 0
        Err.Raise vbObjectError + CLng(Err.Number), Err.Description & ". ProgId=" & strProgId
    Else
        Set mdm_CreateObject = obj
    End If
    Err.Clear
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION              :
' PARAMETERS    :
' DESCRIPTION   :
' RETURNS               :
Private Function mtvblib_Version() ' As String
    Dim objTool
    Set objTool = mtvblib_CreateObject(CTool)
    
    mtvblib_Version = objTool.Version()
End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION  : PreProcess
' PARAMETERS  :
' DESCRIPTION  : Simple and smart string replacement.
'    PreProcess("Hello [SOMETHING]",Array("SOMETHING","World")) will return
'    Hello World
' RETURNS  : Return the string preprocess
PRIVATE FUNCTION PreProcess(ByVal strMessage, Defines) ' As String

  Dim i ' As Long

  For i = 0 To UBound(Defines) Step 2

       strMessage = Replace(strMessage, "[" & Defines(i) & "]", CStr(Defines(i + 1)))
  Next
  PreProcess = strMessage
END FUNCTION



function DumpRowset(rowset)
	dim i,str,j,tempvar
  
  str=""
  for j = 0 to rowset.count -1
      str = str & CStr(rowset.name(j)) & " , "
  next
  str = str & "<br>" & vbnewline
  
	for i = 0 to rowset.recordcount -1
		str = str & "row(" & i+1 & ")"
		for j = 0 to rowset.count -1
			tempvar = rowset.value(j)
				tempvar = rowset.value(j)
				if not IsObject(tempvar) then
					if not IsNull(tempvar) then
						str = str & CStr(rowset.value(j)) & " "
					end if
				end if
		next
    str = str & "<br>" & vbnewline
		rowset.MoveNext
	next
  DumpRowset = str
end function    

function DumpRowsetHTML(rowset)
	dim i,str,j,tempvar
  
  str="<table border='0' cellpadding='3' cellspacing='0' width='100%'><tr>"
  for j = 0 to rowset.count -1
      str = str & "<td Class='TableHeader'>" & CStr(rowset.name(j)) & "</td>"
  next
  str = str & "</tr>" & vbnewline
  
	for i = 0 to rowset.recordcount -1
		str = str & "<tr>"
		for j = 0 to rowset.count -1
			tempvar = rowset.value(j)
				tempvar = rowset.value(j)
				if not IsObject(tempvar) then
					if not IsNull(tempvar) then
						str = str & "<td Class='TableCell'>" & CStr(rowset.value(j)) & "&nbsp;</td>"
          else
            str = str & "<td Class='TableCell'>" & "[NULL]" & "&nbsp;</td>"
					end if
        else
          str = str & "<td Class='TableCell'>" & "[OBJECT]" & "&nbsp;</td>"          
				end if
		next
    str = str & "</tr>" & vbnewline
		rowset.MoveNext
	next
  str = str & "</table>"
  DumpRowsetHTML = str
end function   

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetArrayIndex
' PARAMETERS    :
' DESCRIPTION   : 
' RETURNS       :
PUBLIC FUNCTION GetStringArrayIndex(arr,byval value)
    Dim v, lngIndex
    
    value     = UCase(value)
    lngIndex  = 0
    
    For Each v In arr
      If(UCase(v)=value)Then
          GetStringArrayIndex = lngIndex
          Exit Function
      End If
      lngIndex = lngIndex + 1
    Next
    GetStringArrayIndex = -1
END FUNCTION

%>
