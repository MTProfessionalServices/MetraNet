<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: s:\UI\MOM\default\dialog\FailedTransactionEditCompoundProperties.asp$
'
'  Copyright 1998-2002 by MetraTech Corporation
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
'  $Date: 9/4/2002 2:19:10 PM$
'  $Author: Rudi Perkins$
'  $Revision: 1$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"                                    -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE FILE="../../default/lib/FailedTransactionLibrary.asp"     -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%


Private Const HTML_ERROR_TEMPLATE = "</TABLE><BR><BR><TABLE Width='100%' CellPadding=0 CellSpacing=0 Border=0><TR><TD Class='ErrorMessageCaption'>Error</TD></TR><TR><TD Class='ErrorMessage'>[ERROR]</TD></TR></TABLE>"
Private Const METER_FLAG_PREFIX   = "meterFlag"

Private m_strServiceName ' As String ' For a Compound Child we store the Service name in there rater that in the tv_pv_error rowset
Private m_objRowSet ' As MTSQLRowset - Private Member - This is cool for vbscript -
                    ' In Each event we have to reset this guy because the value go away in
                    ' between events...

Form.Initialized = FALSE ' Because of a bug of the MDM, I have to do that;
Form.RouteTo     = mom_GetDictionary("FAILED_TRANSACTION_BROWSER_DIALOG") ' When we edit a compound children there is no route to because we are in a pop up

If Form("EditCompound") = "TRUE" Or Len(Request("ChildKey")) Then
    ' We are editing a children compound we do not need to look up the t_pv_error information
Else
    FindRowSetAndSetCurrentRow ' Here we set the service file name dynamically by retreiving some info from a rowset - Set the m_objRowSet
End If

Form.MsixdefExtension = ""

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_Initialize
' PARAMETERS    :  EventArg
' DESCRIPTION   :
' RETURNS       :  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Framework.AssertCourseCapability "Update Failed Transactions", EventArg
  Dim i, lngCount, objServiceProperty, strXMLMessage, idChildKey

  
  Dim lngObjPtr
  lngObjPtr = Service.Tools.GetObjPtr(Service)
  
  Form("ExecutePaintEvent") = TRUE

  Service.Clear
  


  'Test if we are editing atomic or compound and initialize service accordingly
  idChildKey = request("ChildKey")

  If Len(idChildKey)=0 Then

      ' Atomic
      Server.ScriptTimeout = 1800 'Increase script timeout for this page to 30 minutes while parsing the xml
      If Not GetTransactionXML(m_objRowSet,EventArg,strXMLMessage) Then Exit Function
      Set Service.Dictionary = mdm_GetDictionary()
      Service.XML(Server.MapPath("/mdm"),,,,,,mdm_InternalCache) = strXMLMessage
      AddExtraProperties
  Else
     ' Compound Child or Parent

      m_strServiceName = Request("ServiceName")

      If UCase(idChildKey)="PARENT" Then
          Form("EditParent")  = TRUE
          Set Service = Session("FailedTransaction_Compound_Parent")
      Else
          Set Service = Session("FailedTransaction_Compound_Parent").SessionChildrenTypes(m_strServiceName).Children(idChildKey)
          Form("EditParent")  = FALSE
          AddExtraProperties
      End If

      ' Since we give up the current service instance and plug in a one from our big parent/collection we must store a ref in the session
      mdm_SaveDialogCOMInstance Service ' Save the object in the session based on its id

      Form.Modal            = TRUE
      Form("EditCompound")  = "TRUE"
  End If


  If(Not Form.Initialized)Then

      ' For each property of the service I add extra property to store the Meter Status information
      ' We need to use a i loop else the collection keep growing and we never go out of the loop!
      lngCount = Service.Properties.Count

      For i=1 To lngCount

          Set objServiceProperty =  Service.Properties(i)
          Service.Properties.Add METER_FLAG_PREFIX & objServiceProperty.Name, "boolean", 0, False, Empty, eMSIX_PROPERTY_FLAG_NONE
          Service.Properties(METER_FLAG_PREFIX & objServiceProperty.Name).Caption = "dummy" ' avoid localization call
      Next
  End If
  mdm_GetDictionary().Add "TEXT_FAILED_TRANSACTION_FAILURE_ID",  GetFailureID()

  '//All edited services will have an extra metered internal property _Resubmit set to true to indicate it is a resubmitted session
  '//The pipeline uses this to update first pass productviews in the case of aggregate rating
  Service.Properties.Add "_Resubmit", "boolean", 0, False, Empty, eMSIX_PROPERTY_FLAG_LOADED_FROM_MSIXDEF + eMSIX_PROPERTY_FLAG_METERED
  Service.Properties("_Resubmit").value = true
  Service.Properties.Add METER_FLAG_PREFIX & "_Resubmit", "boolean", 0, False, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties(METER_FLAG_PREFIX & "_Resubmit").Caption = "dummy" ' avoid localization call

  ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
  ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
  ' else one.
  Service.LoadJavaScriptCode

'    Service.JavaScriptCode
    
  Form_Initialize = TRUE
END FUNCTION

  
PRIVATE FUNCTION AddExtraProperties()  
  '
  ' Extra property
  '
  Service.Properties.Add "ServiceName", "string", 255, False, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties("ServiceName").Value       = GetServiceFileName()
  Service.Properties("ServiceName").Caption     = mom_GetDictionary("TEXT_SERVICE_NAME")

  Service.Properties.Add "ErrorMessage", "string", 255, False, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties("ErrorMessage").Value      = GetErrorMessage()
  Service.Properties("ErrorMessage").Caption    = mom_GetDictionary("TEXT_ERROR_MESSAGE")
  
  AddExtraProperties = TRUE
END FUNCTION  

PRIVATE FUNCTION GetFailureID()
   If IsEmpty(m_objRowSet) Then
      GetFailureID = Service.uID
   Else
      GetFailureID = m_objRowSet.Value("FailureSessionId")
   End If
END FUNCTION


PRIVATE FUNCTION GetErrorMessage()

   If IsEmpty(m_objRowSet) Then
      GetErrorMessage = "err msg not yet there"
   Else
      GetErrorMessage = m_objRowSet.Value("ErrorMessage")
   End If
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
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  OK_Click
' PARAMETERS    :  EventArg
' DESCRIPTION   :
' RETURNS       :  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    On Error Resume Next
    Dim objServiceProperty

    For Each objServiceProperty in Service.Properties

      ' Ignore the special property with start with a prefix
      If(objServiceProperty.Flags<>eMSIX_PROPERTY_FLAG_NONE) and (InStr(objServiceProperty.Name,METER_FLAG_PREFIX)<>1)And(objServiceProperty.Name<>"ServiceName")And(objServiceProperty.Name<>"ErrorMessage")And(objServiceProperty.Name<>"_Resubmit") Then

        ' If we have any numeric or timestamp then we force the property to not
        ' be blank if it is being metered.
        If Not Service.Properties(METER_FLAG_PREFIX & objServiceProperty.Name) Is Nothing Then 
        
          If( ((objServiceProperty.PropertyType = MSIXDEF_TYPE_FLOAT)     or  _
              (objServiceProperty.PropertyType = MSIXDEF_TYPE_DOUBLE)     or  _
              (objServiceProperty.PropertyType = MSIXDEF_TYPE_DECIMAL)    or  _
              (objServiceProperty.PropertyType = MSIXDEF_TYPE_INT32)      or  _
              (objServiceProperty.PropertyType = MSIXDEF_TYPE_TIMESTAMP)) and _
              (Len(Trim(objServiceProperty.Value)) = 0) and _
              (Service.Properties(METER_FLAG_PREFIX & objServiceProperty.Name) = TRUE ) ) Then 
          
            err.Description = "Property " & objServiceProperty.Name & " must not be blank if you want to meter it."  
            EventArg.Error.Save Err  
            OK_Click = FALSE
            On Error Goto 0
            Exit Function
          End If
          End If
        
       ' Set the metered flag on the "real" property
       If(Service.Properties.Exist(METER_FLAG_PREFIX & objServiceProperty.Name))Then ' If the user ask to remeter this property

          If(Service.Properties(METER_FLAG_PREFIX & objServiceProperty.Name))Then ' If the user ask to remeter this property

            ' We must set the flag eMSIX_PROPERTY_FLAG_METERED
            If(objServiceProperty.Flags And eMSIX_PROPERTY_FLAG_METERED)=0 Then  objServiceProperty.Flags = objServiceProperty.Flags + eMSIX_PROPERTY_FLAG_METERED
          else
          ' We must reset the flag eMSIX_PROPERTY_FLAG_METERED
            If(objServiceProperty.Flags And eMSIX_PROPERTY_FLAG_METERED) Then  objServiceProperty.Flags = objServiceProperty.Flags - eMSIX_PROPERTY_FLAG_METERED
          End If
          
       End If

     End If
          
    Next
     
    Form("ExecutePaintEvent") = FALSE

    If Not Form("EditParent") Then
        RemoveTempProperties ' Need to clean
    End if
    
    If(CBool(Err.Number = 0)) then
        On Error Goto 0
        OK_Click = TRUE
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
    End If

END FUNCTION

FUNCTION CANCEL_Click(EventArg) ' As Boolean

    Form("ExecutePaintEvent") = FALSE
    If Not Form("EditParent") Then
        RemoveTempProperties ' Need to clean
    End if

    Form.Modal = true
    Form.JavaScriptInitialize = "window.parent.parent.close();"

    CANCEL_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Paint
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION Form_Paint (EventArg) ' As Boolean

    Dim strHTML
    Dim objPreProcessor
    Dim objVar
    Dim strTemplate
    Dim objServiceProperty
    Dim lngRowCount
    Dim strValue
    
    If Not Form("ExecutePaintEvent") Then
        Form_Paint = TRUE
        Exit Function
    End If
    
    lngRowCount = 0

    CONST strTemplateLabel  = "<TD NoWrap>[PROPERTY_NAME]</TD><TD NoWrap>[PROPERTY_TYPE]</TD><TD NoWrap>[PROPERTY_LENGTH]</TD><TD NoWrap>[PROPERTY_REQUIRED]</TD><TD NoWrap>[METER_STATUS]</TD><TD NoWrap><INPUT Type='CheckBox' Name='[METER_FLAG_PREFIX][PROPERTY_NAME]' [METER_STATUS_CHECKED] [METER_STATUS_DISABLED]> <INPUT Type='Hidden' Value='1' Name='mdm_CheckBox_[METER_FLAG_PREFIX][PROPERTY_NAME]' > [PROPERTY_NEW_STATUS]</TD>"
    CONST strTemplateInput  = "<TD Align='left'><INPUT type='[TEXTBOXTYPE]' class='clsInputBox' size='50' Name='[PROPERTY_NAME]' Value=""[PROPERTY_VALUE]"" MaxLength='[PROPERTY_LENGTH]'></TD>"
    CONST strTemplateSelect = "<TD Align='letf'><SELECT class='clsInputBox' Name='[PROPERTY_NAME]'>[PROPERTY_ENUM_TYPE_VALUE]</SELECT></TD>"

    Set objPreProcessor = mdm_CreateObject(CPreProcessor)

    For Each objServiceProperty in Service.Properties

       If  (objServiceProperty.Flags<>eMSIX_PROPERTY_FLAG_NONE) and (InStr(objServiceProperty.Name,METER_FLAG_PREFIX)<>1)And(objServiceProperty.Name<>"ServiceName")And(objServiceProperty.Name<>"ErrorMessage")And(objServiceProperty.Name<>"_Resubmit") Then ' Ignore the special property with start with a prefix

           If(objServiceProperty.Flags And eMSIX_PROPERTY_FLAG_METERED)Then 

                If(objServiceProperty.PropertyType=MSIXDEF_TYPE_STRING)Then 

                    ' Trunc the string value in case it was metered to big...
                    objServiceProperty.Value  = MID(objServiceProperty.Value ,1,objServiceProperty.Length)
                End If

                objPreProcessor.Add "METER_STATUS"          , mom_GetDictionary("TEXT_FAILED_TRANSACTIONS_METERED_STATUS")
                objPreProcessor.Add "METER_STATUS_CHECKED"  , "CHECKED"
                Service.Properties(METER_FLAG_PREFIX & objServiceProperty.Name) = TRUE
            Else
                objPreProcessor.Add "METER_STATUS"          ,   mom_GetDictionary("TEXT_FAILED_TRANSACTIONS_NOT_METERED_STATUS")
                objPreProcessor.Add "METER_STATUS_CHECKED"  ,   ""
                Service.Properties(METER_FLAG_PREFIX & objServiceProperty.Name) = FALSE
            End If

            objPreProcessor.Add "PROPERTY_NAME"      , objServiceProperty.Name
            objPreProcessor.Add "PROPERTY_TYPE"      , LCase(objServiceProperty.PropertyType)

				    strValue = objServiceProperty.Value
				    strValue = Replace("" & strValue,"""","&quot;")

            objPreProcessor.Add "PROPERTY_VALUE"     , strValue
            objPreProcessor.Add "PROPERTY_LENGTH"    , IIF(objServiceProperty.PropertyType=MSIXDEF_TYPE_STRING, objServiceProperty.Length,"255") ' Just print the length for string
            objPreProcessor.Add "PROPERTY_REQUIRED"  , objServiceProperty.Required
            if objServiceProperty.Required Then
              '// If this property is required, you do not have the option of 'unchecking' the metered flag
              objPreProcessor.Add "METER_STATUS_DISABLED","disabled"
              Service.Properties(METER_FLAG_PREFIX & objServiceProperty.Name).Enabled=false              
            else
              objPreProcessor.Add "METER_STATUS_DISABLED",""
            end if
            
            objPreProcessor.Add "METER_FLAG_PREFIX"  , METER_FLAG_PREFIX
            objPreProcessor.Add "PROPERTY_NEW_STATUS", mom_GetDictionary("TEXT_FAILED_TRANSACTIONS_METER")

            objPreProcessor.Add "TEXTBOXTYPE", IIF(MSIXPropertyCrypted(objServiceProperty.Name),"password","text")

            Select Case UCase(objServiceProperty.PropertyType)

                Case MSIXDEF_TYPE_BOOLEAN, MSIXDEF_TYPE_ENUM

                    objPreProcessor.Add "PROPERTY_ENUM_TYPE_VALUE",objServiceProperty.EnumType.GetHTMLOptionTags()
                    strTemplate = strTemplateLabel & strTemplateSelect
                Case Else
                    strTemplate = strTemplateLabel & strTemplateInput
            End Select

            If (lngRowCount mod 2) Then
              Form.Grid.CellClass = "TableCellAlt"
            Else
              Form.Grid.CellClass = "TableCell"
            End If
            strHTML = strHTML & "<TR class='" & Form.Grid.CellClass & "'>" & objPreProcessor.Process(strTemplate,"[","]") & "</TR>" & vbNewLine
            lngRowCount = lngRowCount + 1
        End If
    Next
    EventArg.HTMLRendered = Replace(Cstr(EventArg.HTMLRendered),"[PROPERTIES]",CStr(strHTML))
    Form_Paint = TRUE
END FUNCTION

PRIVATE FUNCTION LogPropInfo(strName,strValue,strType)

    Service.Log "ErrorQueueProperties>name=" & strName & " value=" & strValue & " type=" & strType
    LogPropInfo = TRUE
END FUNCTION

PRIVATE FUNCTION RemoveTempProperties()

    Dim MSIXProperty, booOK
    
    RemoveTempProperties  = FALSE  
    booOK                 = FALSE
    
    Do While Not booOK ' Remove the input and output properties from the service object
    
        booOK = TRUE
        For Each MSIXProperty In Service.Properties
        
            If MSIXProperty.Flags = eMSIX_PROPERTY_FLAG_NONE Then Service.Properties.Remove MSIXProperty.Name : booOK = FALSE : Exit For
        Next
    Loop
    RemoveTempProperties = TRUE
END FUNCTION

%>

