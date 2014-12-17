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
' NAME          : MCM - Picker Library - VBScript Library
' VERSION         : 1.0
' CREATION_DATE   : 4/11/2001
' AUTHOR         : Some body called Fred!
' DESCRIPTION     : See file mdm\common\mdmPicker.List.Interface.txt
' ----------------------------------------------------------------------------------------------------------------------------------------

PUBLIC MDMPickerDialog ' Global Instance...
Set MDMPickerDialog = New CMDMPickerDialog

mdm_IsPicker = TRUE

CLASS CMDMPickerDialog

    PUBLIC FUNCTION Initialize(EventArg) ' As Boolean
   
        NextPage                      = Request.QueryString("NextPage")           ' Save the value in a form variables
        Form("Kind")                  = Request.QueryString("Kind")               ' Save the value in a form variables
        Set Form("SelectedIDs")       = mdm_CreateObject(CVariables)              ' Object sthat stores the selection
        Form("MonoSelect")            = Request.QueryString("MonoSelect")         ' Multi MonoSelect , Multi is the default mode
        Form("OptionalColumn")        = Request.QueryString("OptionalColumn")     ' Multi MonoSelect , Multi is the default mode
        Form("IDColumnName")          = Request.QueryString("IDColumnName")       ' Column name to use for ID  - default is id_prop
        ProductView.Properties.Flags  = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW         ' Tell the product view object to behave like real MT Product View based on the data in the rowset
        Form.Page.MaxRow              = mdm_GetDictionary().GetValue("MAX_ROW_PER_PICKER_PAGE",16)        
        Form.Grid.FilterMode          = TRUE        
        Parameters                    = Request.QueryString("Parameters")  
        
        If(Len(Request.QueryString("Title")))Then
            mdm_GetDictionary().Add "MCM_PICKER_TITLE", mdm_GetDictionary().Item(Request.QueryString("Title")).Value
        Else
            mdm_GetDictionary().Add "MCM_PICKER_TITLE", ""
        End If               
        
        ' We want the enter key to call the mdm client side javascript OK_Click()
        mdm_GetDictionary.Add "MDM_CLIENT_SIDE_ENTER_KEY_CALL_JAVASCRIPT_OK_CLICK_EVENT", "true"  ' true must be in lower case because it is for javascript
         
       ProductView.Clear ' Set all the property of the service to empty or to the default value
       Initialize = TRUE
    END FUNCTION
    
    PUBLIC PROPERTY GET NextPage()
        NextPage = Form("NextPage")
    END PROPERTY
    
    PUBLIC PROPERTY LET NextPage(v)
        'SECENG: CORE-4767 CLONE - MSOL BSS 26808 Metracare: Reflected cross-site scripting [/mam/default/dialog/RoleAddCapability.asp in NextPage parameter] (Post-PB)
        'Added validation if the URL specified by "v" argument is allowed
        if not SafeForUrlAC(v) then
            v = ""
            Response.Clear
            Response.Status = "403 Forbidden"
            Response.End
        end if
        Form("NextPage") = v
        'SECENG: Added encoding for JavaScript
        mdm_GetDictionary().Add "MDM_PICKER_NEXT_PAGE" , SafeForJs(v)
    END PROPERTY
    
    PUBLIC PROPERTY GET Parameters()
        Parameters = Form("Parameters")
    END PROPERTY
    
    PUBLIC PROPERTY LET Parameters(v)
        Form("Parameters") = v
        mdm_GetDictionary().Add "MDM_PICKER_PARAMETER_VALUE" , ProcessParameter() ' If we use the picker in a pop up window we need to call back the caller with the parameter values, so we first pass it to the JAVASCRIPT. See mdm/internal/mdm.JavaScript.tpl.js
    END PROPERTY

    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION       :
    ' PARAMETERS    :
    ' DESCRIPTION   :
    ' RETURNS        : Return TRUE if ok else FALSE
    PUBLIC FUNCTION OK_Click(EventArg) ' As Boolean

        Dim strS, strSNames

        If(Form("MonoSelect"))Then Item_Click(EventArg) ' As Boolean

        strS = GetIDsCsvString()
        If(Not IsEmpty(Form("OptionalColumn")))Then strSNames = GetOptionalValuesCsvString()

        If(Not IsEmpty(Form("NextPage")))Then

            Form.RouteTo = mdm_AddParameterToAspCall(Form("NextPage"),"IDS", strS)

            If(Len(strSNames))Then

                Form.RouteTo = mdm_AddParameterToAspCall(Form.RouteTo,"OPTIONALVALUES", strSNames)
            End If
            If(Not IsEmpty(Form("Parameters")))Then

                Form.RouteTo = Form.RouteTo  & "&" & ProcessParameter()
            End If
        End If
        OK_Click = TRUE
    END FUNCTION

    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION       :
    ' PARAMETERS    :
    ' DESCRIPTION   :
    ' RETURNS        : Return TRUE if ok else FALSE
		PUBLIC FUNCTION GetIDsCsvString() ' As Boolean

        Dim objVar, strS

        For Each objVar In Form("SelectedIDs") ' Build a CSV String with the Item id

            strS = strS & Mid(objVar.Name,2) & ","
        Next
        
        if len(strS) > 0 then        
          GetIDsCsvString = Mid(strS,1,Len(strS)-1) ' Remove the last ,
        else
          GetIDsCsvString = ""
        end if
    END FUNCTION

    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION       :
    ' PARAMETERS    :
    ' DESCRIPTION   :
    ' RETURNS        : Return TRUE if ok else FALSE
    PRIVATE FUNCTION GetOptionalValuesCsvString() ' As Boolean

        Dim objVar, strS, objRowset, objTool, arrOptionalIDs, strID, bFound

        Set objRowset = ProductView.Properties.Rowset
        Set objTool   = mdm_CreateObject(MSIXTools)
        
        arrOptionalIDs = split(Form("OptionalColumn"), ",")

        for Each objVar In Form("SelectedIDs") ' Loop around all the ids
          if objTool.RowsetQuickFind(objRowset, GetIDColumnName(), Mid(objVar.Name, 2)) then
            bFound = false
            for each strID in arrOptionalIDs
              if bFound then 
                strS = strS & ","
              end if
                
              strS = strS & Trim(objRowset.value(CStr(strID)))
              bFound = true
            next
  
            strS = strS & "|"
          end if
        next
        
        'Remove the last |
        if len(strS) > 0 then
          GetOptionalValuesCSVString = mid(strS, 1, len(strS) - 1)
        end if
        
    END FUNCTION

    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION       :
    ' PARAMETERS    :
    ' DESCRIPTION   :
    ' RETURNS        : Return Column Name
    PUBLIC FUNCTION GetIDColumnName()
      If Len(Form("IDColumnName")) Then
        GetIDColumnName = Form("IDColumnName")
      Else
        GetIDColumnName = "id_prop"
      End If

    END FUNCTION

    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION       : Item_Click
    ' PARAMETERS    :
    ' DESCRIPTION   :
    ' RETURNS        : Return TRUE if ok else FALSE
    PUBLIC FUNCTION Item_Click(EventArg) ' As Boolean

        Dim objUIItems, objVar

        mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
        Form("SelectedIDs").Clear

        For Each objVar In objUIItems

            If(objVar.Name="PickerItem")Then
                ' The objVar.Value contains all the id separated with a ,
                ' Parse the string and populate the collection the name is the id the value is 1
                Form("SelectedIDs").LoadSet objVar.Value,",",,TRUE,CLng(1)
            End If
        Next
        Item_Click = TRUE
    END FUNCTION

    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION       : ProcessParameter
    ' PARAMETERS    :
    ' DESCRIPTION   : Return the input Parameter Form("Parameters") in a QueryString Format.
    ' RETURNS        : Return TRUE if ok else FALSE
    PRIVATE FUNCTION ProcessParameter() ' As String

        Dim strParameter

        If(IsEmpty(Form("Parameters")))Then
              ProcessParameter = Empty
        Else
           strParameter     = Replace(Form("Parameters"),"|","=")
           strParameter     = Replace(strParameter,";","&")
		   ' SECENG: CORE-4796 CLONE - MSOL BSS 29803 MetraOffer: Reflected cross-site scripting [mcm/default/dialog/ProductOffering.Picker.asp - 'Parameters' GET paramater]
 		   ' JS Encoding added
           ProcessParameter = SafeForJS(strParameter)
        End If
    END FUNCTION

    PUBLIC FUNCTION GenerateHTMLEndOfPage(EventArg)
        '
        ' This line is commented for 2.1. The function and line was only there to set the focus on the first radio button and
        ' and check box of the picker dialog, so the enter key can work. 
        ' This gave me some bugs with javascript when we close the windows, when mdm close the pop up window the function is still
        ' called but the java include lib is probably discarded before!
        ' Plus I realize some dialog does not set a default value. So if there is no checked radio button the function is ignored.
        ' 
        ' Conclusion : When a user open a picker dialog and if the first item is selected and the user press ENTER the enter keyn is ignored...
        '
      
        'EventArg.HTMLRendered = EventArg.HTMLRendered & "<SCRIPT>SetFocusToFirstPickerItem();</SCRIPT>" & vbNewLine
    END FUNCTION

END CLASS

' ************ EVENT CANNOT BE PART OF THE CLASS, SO THEY CAN BE OVER RIDDENT ************

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_DisplayCell
' PARAMETERS :
' DESCRIPTION : Over ride the MDM Default event Form_DisplayCell()
'               If the client over ride this event it is not possible to call it as the Inherited event.
'               Because the inherited event is the one defined in the file mdm\mdmPVBEvents.asp, this
'               is a limitation of a picker.
' RETURNS    :
PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim m_objPP, strCheckStatus, strID,HTML_LINK_EDIT

    Select Case Form.Grid.Col

        Case 1
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<INPUT Type='[CONTROL_TYPE]' Name='PickerItem' value='I[ID]' [CHECK_STATUS] [ON_CLICK] >"

            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"

            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass

            m_objPP.Add "CONTROL_TYPE"  , IIF(Form("MonoSelect"),"Radio","CheckBox")
            m_objPP.Add "ON_CLICK"      , IIF(Form("MonoSelect"),"","OnClick='mdm_RefreshDialog(this);'")

            m_objPP.Add "ID"          , ProductView.Properties.Rowset.Value(MDMPickerDialog.GetIDColumnName())

            strID = "I" & CStr(ProductView.Properties.Rowset.Value(MDMPickerDialog.GetIDColumnName()))
            If(Form("SelectedIDs").Exist(strID))Then
                strCheckStatus   =  IIF(Form("SelectedIDs").Item(strID).Value=1,"CHECKED",Empty)
            Else
                strCheckStatus  = Empty ' Not Selected
            End If

            If(Form("MonoSelect"))THen
              If(Form("SelectedIDs").Count=0)and(Form.Grid.Row = 1)Then
                  strCheckStatus   =  "CHECKED"
              End If
            End If

            m_objPP.Add "CHECK_STATUS" , strCheckStatus

            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
        Case Else
           Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  PickerItem_Click, inheritedPickerItem_Click
' PARAMETERS    :
' DESCRIPTION   :  This event is called internally by the MDM, it must not be exposed that's why it is private
'                  I also implement the inheritedPickerItem_Click event so this event can be overridden and
'                  the inherited event can be called following the regular MD Syntax : function Inherited()
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION inheritedPickerItem_Click(EventArg) ' As Boolean
    inheritedPickerItem_Click = MDMPickerDialog.Item_Click(EventArg)
END FUNCTION

PRIVATE FUNCTION PickerItem_Click(EventArg) ' As Boolean
    PickerItem_Click = inheritedPickerItem_Click(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayEndOfPage
' PARAMETERS    :
' DESCRIPTION   :  Over ride the MDM Default event Form_DisplayEndOfPage()
'                  If the client over ride this event it is not possible to call it as the Inherited event.
'                  Because the inherited event is the one defined in the file mdm\mdmPVBEvents.asp, this
'                  is a limitation of a picker.

' RETURNS       :  Return TRUE if ok else FALSE
'
' NOT USED SEE BELOW
'
PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode

    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting EventArg.HTMLRendered. The <TABLE> and <FORM> are closed...
    'Inherited("Form_DisplayEndOfPage()") 
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</TABLE>"
        
    MDMPickerDialog.GenerateHTMLEndOfPage EventArg
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BR><CENTER>"
    
    If ProductView.Properties.Rowset.RecordCount > 0 Then
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BUTTON Name='OK'  Class='clsOKButton' OnClick='mdm_RefreshDialog(this);return false;'>" & FrameWork.GetDictionary("TEXT_OK") & "</BUTTON>&nbsp;&nbsp;&nbsp;"
    End If
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BUTTON Name='CANCEL' Class='clsOKButton' OnClick='mdm_RefreshDialog(this);return false;'>" & FrameWork.GetDictionary("TEXT_CANCEL") & "</BUTTON>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</center>"
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM></HTML>"
        
    EventArg.HTMLRendered= EventArg.HTMLRendered & strEndOfPageHTMLCode 
    
    If(COMObject.Configuration.DebugMode)Then ' If in debug mode display the selection
       EventArg.HTMLRendered = EventArg.HTMLRendered  & "<hr size=1>" & Replace(Form("SelectedIDs").ToString(),vbNewline,"<br>") & "<br>"
    End If
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION




' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayEndOfPage
' PARAMETERS    :  
' DESCRIPTION   :  Over ride the MDM Default event Form_DisplayEndOfPage()
'                  If the client over ride this event it is not possible to call it as the Inherited event.
'                  Because the inherited event is the one defined in the file mdm\mdmPVBEvents.asp, this
'                  is a limitation of a picker.
' RETURNS       :  Return TRUE if ok else FALSE
'PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean
'
'    dim strEndOfPageHTMLCode
'    
'    ' We do not call the inherited event because we have to add the hidden field PickerIDs    
'    EventArg.HTMLRendered = "<INPUT Type='Hidden' Name='PickerIDs' Value=''></TABLE><BR><CENTER>" & vbNewLine
'    EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='OK'     Class='clsOKButton' OnClick='OK_Click();'>OK</BUTTON>&nbsp;&nbsp;&nbsp;" & vbNewLine
'    EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='CANCEL' Class='clsOKButton' OnClick='CANCEL_Click();'>Cancel</BUTTON></center>" & vbNewLine
'    EventArg.HTMLRendered = EventArg.HTMLRendered & "</center>" & vbNewLine
'    EventArg.HTMLRendered = EventArg.HTMLRendered & "</FORM>" & vbNewLine
'    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
'    
'    If(COMObject.Configuration.DebugMode)Then ' If in debug mode display the selection
'    
'       EventArg.HTMLRendered = EventArg.HTMLRendered & "<hr size=1>" & Replace(Form("SelectedIDs").ToString(),vbNewline,"<br>") & "<br>"
'    End If    
'    Form_DisplayEndOfPage = TRUE
'END FUNCTION

%>
