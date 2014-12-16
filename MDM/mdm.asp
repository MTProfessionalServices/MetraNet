<!--   #INCLUDE FILE="mdmIncludes.asp"   -->
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' NAME                  : MetraTech Dialog Manager - Main VBScript Module
' VERSION               : 1.0
' CREATION_DATE     : 08/xx/2000
' AUTHOR                : F.Torres.
' DESCRIPTION       : To much to say about it. Read the MDM Design Document
'                     and the MDM programming guide document.
'
'                   The file include the MDM dialog manager entry point function
'                           mdm_Main()
'
'                   and the Product View Browser manager entry point function
'                           mdm_pvb_RenderProductViewHtml()
' ----------------------------------------------------------------------------------------------------------------------------------------

PUBLIC CONST MDM_DISPLAY_PERFORMANCE_INFO = FALSE ' MDM 3.6

Response.Expires = -1000  ' Force IEx to refresh every dialog...

Public Form        ' As Object MTMSIX.MDMForm
                   ' each time this page is called and the dialog already exist
                   ' The Form instance is set to Form from the session, BUT THE SESSION INSTANCE IS CLEARED
                   ' The method mdm_TestIfFormMustBeSavedAndSave() Save it again in the session

Public EventArg    ' As Object MTMSIX.MDMEvent

' This 3 instances reference the same object! I did that to have 3 name and so a better
' syntax when we deal with a service or a product view! Nobody can set these to variables.
' The object is saved into the session at the beginning and removed at the end by mdm_OnTerminate.
' The Way of storing the FOrm Object and the Service object is different I do not remember why.

Public Service     ' As Object MTMSIX.MSIXHandler
Public ProductView ' As Object MTMSIX.MSIXHandler
Public COMObject   ' As Object MTMSIX.MSIXHandler ' MDM V2
                  
Public mdm_DialogID ' Used to create unique objects for the dialog when the source is shared

' The cache object allow to cache the EnumType name space object and
' the service property localization string, and other stuff.
' The instance is create the first time the MDM run and it is store
' in a session variable. The mdm_GarbageCollector free this object
Private mdm_InternalCache ' As MTMSIX.Cache

Private mdm_DialogType    ' As Long ' MDM_STANDARD_DIALOG_TYPE,MDM_PVB_DIALOG_TYPE

Private mdm_RefreshFromClickFromObject ' As Boolean ' Set to false by default see mdm_Initialize

Private mdm_IsPicker:mdm_IsPicker=FALSE

' Localization UTF-8  - [YellowKnife]
Session.CodePage = 65001
Response.CharSet = "utf-8"

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_PVBrowserMain
' PARAMETERS            :
' DESCRIPTION   :  This function is the MDM VBScript entry point. Each dialog using the MDM
'                  must called this function. Note that the private function constructor mdm_Initialize
'                  is called automatically before the mdm_Main().
'                  The mdm_Main called at the end the function destructor mdm_Terminate.
'                  This function is the internal function/event dispatcher
'                  This function save and restore the Form object if it must be saved.
'
'                  A Product View Browser Form does not have any CANCEL or OK Event so there is no way to close
'                  the Form automatically. Calling the function mdm_pvb_Close
' RETURNS                         :
Function mdm_PVBrowserMain() ' As Boolean
  Dim strAction, strPageAction, strSubAction, strFilter
  
  mdm_DialogCollector()
  mdm_TestIfMustUnLoadDialog False


  mdm_DialogType = MDM_PVB_DIALOG_TYPE
  strAction = mdm_UIValue("mdmAction")
  strFilter = mdm_UIValue("mdmPVBFilter")

  Select Case UCase(mdm_UIValue("mdmProperty"))

      Case MDM_ACTION_PVB_FILTER_BUTTON_GO ' Ask to set a filter
          
        Form.Grid.Filter          = mdm_UIValue("mdmPVBFilter")
        Form.Grid.Filter2         = mdm_UIValue("mdmPVBFilter2")
        Form.Grid.FilterOperator  = mdm_UIValue("mdmPVBFilterOperator") ' We are setting a filter so let us store the operator
        Form.Grid.FilterPropertySaveValue  = mdm_UIValue("mdmPVBFilterColumns")
        
        strAction = MDM_ACTION_REFRESH
        If (Len(Form.Grid.Filter) = 0) Then ' No Filter is passer we going to remove the filter
            Form.Grid.Filter = MDM_ACTION_PVB_FILTER_RESET
        End If            
      
      Case MDM_ACTION_PVB_FILTER_BUTTON_RESET ' Ask to remove the filter
                        
        Form.Grid.Filter = MDM_ACTION_PVB_FILTER_RESET
        strAction = MDM_ACTION_REFRESH
 
  End Select
  
  ' MDM V 3.5
  ' In a PVB we already support button and button click but when we click we call for a MDM MDM_ACTION_REFRESH
  ' which close the turn down. When we click on a button we do not want this that is why I added the private 
  ' var mdm_RefreshFromClickFromObject
  ' F.TORRES - Sep 18 2002
  If(strAction = MDM_ACTION_REFRESH_FROM_CLICK_FROM_OBJECT)Then  

      strAction                       = MDM_ACTION_REFRESH
      mdm_RefreshFromClickFromObject  = True
  End If
    
  '
  ' BECARE FULL THIS CODE WAS BADLY RETURN BY ME F.TORRES, It is not very clear and confusinf
  ' how I use strAction and strPageAction. I did not clean it because I do not want to break anything...
  ' 9/17/01
  '
  strPageAction = UCase(mdm_UIValue("mdmPageAction"))
    
    If (mdm_UserClickedOn(strSubAction)) Then ' Allow to process customized button event, Only Image Button MDM 1.0
    
        strAction = MDM_INTERNAL_EVENT_ON_CLICK
    End If
    
    ' MDM V2 - Support OK and Cancel Cancel Button in a PVB.
    If (strAction = MDM_ACTION_ENTER_KEY) Then
    
        strAction = MDM_INTERNAL_EVENT_ON_CLICK       ' Simulate a click on a OK Button
        strSubAction = MDM_INTERNAL_EVENT_ON_OK
    End If
    If (strAction = MDM_ACTION_ESCAPE_KEY) Then
    
        strAction = MDM_INTERNAL_EVENT_ON_CLICK       ' Simulate a click on a OK Button
        strSubAction = MDM_INTERNAL_EVENT_ON_CANCEL
    End If
    
    Select Case UCase(strAction) ' Process the string command
            
        Case MDM_ACTION_DEFAULT, MDM_ACTION_OPEN_PV
        
            If (strPageAction = MDM_ACTION_EXPORT) Then
            
                mdm_OnExport
            Else
                mdm_pvb_OpenProductView True, False, strPageAction
            End If
            
        Case MDM_ACTION_REFRESH, MDM_INTERNAL_EVENT_ON_CLICK
        
            If (UCase(strAction) = MDM_INTERNAL_EVENT_ON_CLICK) Then
                
                Select Case strSubAction ' MDM V2 - We support OK and CANCEL Button in PVB
                
                  Case MDM_INTERNAL_EVENT_ON_OK: mdm_OnOk
                  Case MDM_INTERNAL_EVENT_ON_CANCEL: mdm_OnCancel
                  Case Else
                      mdm_OnClick strSubAction, False ' A Button asked for a refresh - we need to raise the event
                End Select
            End If
            If (Len(CStr(mdm_UIValue("mdmProperty")))) Then

                If (UCase(mdm_UIValue("mdmProperty")) <> MDM_ACTION_PVB_FILTER_BUTTON_GO) And _
                  (UCase(mdm_UIValue("mdmProperty")) <> MDM_ACTION_PVB_FILTER_BUTTON_RESET) Then ' Exclude the case of a click on the PVB Filter Button
                
                    ' ## I am guessing that we should just do a redraw rather than a refresh but the MDM 1
                    ' I leave this unchanged...Because we will close the cycle in 3 days...
                    mdm_OnRefresh False ' A comboxbox or a checkbox asked for a refresh - we need to raise the event
                End If
            End If
            
            If (Len(strPageAction) = 0) Then strPageAction = MDM_ACTION_REFRESH ' Standard refresh PV
            
            ' ## HERE I going to do a HACK Because I have not enough time.
            ' In the case of a button click we just need to do a redraw but we used to do a MDM_ACTION_REFRESH
            ' And I do not want to break the all workflow! So I keep the refresh but if the event is
            ' SELECTALL I do a REDRAW - Cycle 1.3
            '
            ' Same for cycle 2.0.
            '
            If (UCase(mdm_UIValue("mdmProperty")) = "SELECTALL") Then strPageAction = MDM_ACTION_REDRAW
            
            ' MDM V2 - The New thing here is that we do not refresh the PVB is OK or CANCEL were clicked...
            If (strSubAction <> MDM_INTERNAL_EVENT_ON_OK) And (strSubAction <> MDM_INTERNAL_EVENT_ON_CANCEL) Then
            
                mdm_pvb_OpenProductView True, False, strPageAction
            End If
            
        End Select
    
    mdm_Terminate
    mdm_PVBrowserMain = True
End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_Main
' PARAMETERS            :
' DESCRIPTION           :  This function is the MDM VBScript entry point. Each dialog using the MDM
'                      must called this function. Note that the private function constructor mdm_Initialize
'                      is called automatically before the mdm_Main().
'                      The mdm_Main called at the end the function destructor mdm_Terminate.
'                      This function is the internal function/event dispatcher!
'                      This function save and restore the Form object if it must be saved.
' RETURNS                       :
Function mdm_Main() ' As Boolean

    Dim strAction, strSubAction

    mdm_DialogCollector()
    mdm_TestIfMustUnLoadDialog False

    ' NOTE: Creating/Retreiving the form is in the mdm_Initialize event
    mdm_DialogType  = MDM_STANDARD_DIALOG_TYPE
    strAction       = MDM_INTERNAL_EVENT_OPEN_DIALOG       '  Default Mode when a dialog must be open
        
    ' Convert the asp input parameter into a string command
    If (mdm_UserClickedOnOk()) Then
      
        strAction = MDM_INTERNAL_EVENT_ON_OK
                  
    ElseIf (mdm_UserClickedOnCancel()) Then
      
        strAction = MDM_INTERNAL_EVENT_ON_CANCEL
          
    ElseIf (mdm_UserClickedOn(strSubAction)) Then
      
        strAction = MDM_INTERNAL_EVENT_ON_CLICK
      
    ElseIf mdm_DialogNeedARefreshFromClickOnObject()  Then
    
      ' MDM V 3.5
      ' In a PVB we already support button and button click but when we click we call for a MDM MDM_ACTION_REFRESH
      ' which close the turn down. When we click on a button we do not want this that is why I added the private 
      ' var mdm_RefreshFromClickFromObject
      ' F.TORRES - Sep 18 2002
      
      ' This was added for use custom button/event in PVB but does affect regular dialog
        strAction                       = MDM_INTERNAL_EVENT_ON_REFRESH
        mdm_RefreshFromClickFromObject  = True
          
    ElseIf (mdm_DialogNeedARefresh()) Then
      
        strAction = MDM_INTERNAL_EVENT_ON_REFRESH
        
    Else
        ' If we reach this point we are in the default case OPENDIALOG, in that case I want to
        ' force the dialog to be deleted if it was already in memory
        ' mdm_TestIfMustUnLoadDialog TRUE
        
        ' This code has been removed because I forgot the case where we re opening a dialog
        ' because the OK event returned false...
    End If

    Select Case UCase(strAction) ' Process the string command
  
          Case MDM_INTERNAL_EVENT_OPEN_DIALOG: mdm_OnOpenDlg True, False, Empty, True, Empty, GetDefaultRenderingFlag()
                  
          Case MDM_INTERNAL_EVENT_ON_OK: mdm_OnOk
                  
          Case MDM_INTERNAL_EVENT_ON_CANCEL: mdm_OnCancel
                  
          Case MDM_INTERNAL_EVENT_ON_CLICK: mdm_OnClick strSubAction, True
                  
          Case MDM_INTERNAL_EVENT_ON_REFRESH: mdm_OnRefresh True
    End Select

    mdm_Terminate
End Function

PRIVATE FUNCTION mdm_OnOpen()

        mdm_OnOpen = FALSE
        If (Not mdm_CallEvent("Form_Open(EventArg)", Form.ErrorHandler)) Then
                    mdm_LogWarning Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1015"), "[EVENT]", "Form_Open")
                    mdm_OnCancel '  I call the cancel event because this event route to the route to page
                                 '  If the programmer want to do something special he can do it in the
                                 '  cancel event by testing Form.Initialized.
                    Exit Function
                      
        End If
        mdm_OnOpen = TRUE
  
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_OnOpenDlg
' PARAMETERS            :
' DESCRIPTION           : Print the dialog. Use the Service instance and the QueryString.
'                     Call the event Form_Initialize or Form_Refresh
'                     Call the event Form_Paint.
'                     Call the event Form_DisplayErrorMessage if necessary.
' RETURNS                       :
Function mdm_OnOpenDlg(booInitialized, booRefresh, strOptionalHTMLTemplateSourceCode, booPrintHTML, strOutPutHTMLRendered, lngRenderFlags) ' As Boolean

    Dim varHTMLRendered             ' As String
    Dim booErrorMessage                     ' As String
    Dim strFullPathTemplateFileName ' As String
    Dim EventArgError               ' As Object
    Dim strTabTemplateContent
    Dim objGrid
    
    mdm_OnOpenDlg = False

    If (Not mdm_SetAtGlobalLevelTheServiceInstance("mdm_OnOpenDlg")) Then Exit Function ' Get from session Or Create the MSIXHandler Instance

    ' Try to retreive an error
    Set EventArgError = mdm_GetInstanceFromSession(mdm_EVENT_ARG_ERROR)
    
    booErrorMessage = FALSE
    If IsValidObject(EventArgError) Then booErrorMessage = EventArgError.Error.Number<>0 Or CBool(Len(EventArgError.Error.Description))
    
    If (booErrorMessage) Then ' If Yes then Free the instance in the session (actually the ref)
    
        Set Session(mdm_EVENT_ARG_ERROR) = Nothing
    End If
      
    mdm_OnOpen ' MDM 3.0 - Last Minute event
    
    ' If we have an error we have to populate the UI with the asp parameters else call the initialize function
    If (booErrorMessage) Then
    
    Else
    
        If (booInitialized) Then ' Run the init code
        
            ' MDM V2 - We load the template now and store it in Form.HTMLTemplateSourceCode
            If (Not LoadHTMLTemplateSourceInForm()) Then
              ' Error
            End If
            
            ' Call the OnInitialize Event - The event may not be implemented
            ' Init the Event Info Object
            EventArg.Clear
            
            ' REMOVED IN 3.5 To be able to support the enter key on picker dialog...
            ' mdm_GetDictionary.Add "MDM_CLIENT_SIDE_ENTER_KEY_CALL_JAVASCRIPT_OK_CLICK_EVENT", "false"  ' default value
            
            
            ' Add dialog to list of dialogs to be cleaned up by the DialogCollector
            Call mdm_DialogCollectorAdd(GetDialogId(), mdm_UIValueDefault("mdmKeepAlive", False)) 
            
            If (Not mdm_CallEvent("Form_Initialize(EventArg)", Form.ErrorHandler)) Then
       
            
                mdm_LogWarning Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1015"), "[EVENT]", "Form_Initialize")
                mdm_OnCancel '  I call the cancel event because this event route to the route to page
                             '  If the programmer want to do something special he can do it in the
                             '  cancel event by testing Form.Initialized.
                Exit Function
            Else
                Form.Initialized = True '  Tell the programmer that the dialog initilalize event succeed
            End If
        End If
        If (booRefresh) Then
        
            ' Call the OnInitialize Event - The event may not be implemented
            ' Init the Event Info Object
            EventArg.Clear
            If (Not mdm_CallEvent("Form_Refresh(EventArg)", Form.ErrorHandler)) Then
            
            End If
        End If
    End If

    mdm_PopulateDictionaryWithInternalStuff mdm_DialogType ' Add some new entries to support style sheet localization
    
    If (lngRenderFlags = 0) Then
    
        lngRenderFlags = GetDefaultRenderingFlag()
    End If
    
    ' Tabs are in stand by
    ' MDM V2 - Render the tab if defined
    'If(Form.TabsDefined())Then
    '
    '     mdm_RenderTabs EventArg, Form.Tabs ' The function mdm_RenderTabs is defined in mdmTabEvents.asp
    'End If
    
    ' MDM V2
    ' Render the content of all the grid defined in the dialog is the grid are visible.
    ' The HTML rendered is stored in the grid property HTMLRendered.
    ' The method Service.RenderHTML() following will insert the result in the main template...
    If (Form.GridsDefined()) Then

        For Each objGrid In Form.Grids
        
            mdm_RenderGrid EventArg, objGrid ' The function mdm_RenderGrid is defined in mdmGridEvents.asp
        Next
    End If

    ' MDM V2
    ' Support dialog based on COM Object like an MTPriceAbleItem
    If (IsValidObject(Service.Instance)) Then ' We Have an COM object associated with the dialog
    
        Service.Properties.PopulateFromCOMObject Service.Instance ' Populate the service object with the data of the COM Object
    End If
    
    ' MDM V2
    ' The Template HTML Source Code is now loaded in the MDM Initialize
    
    ' -- The FAMOUS RENDERING PROCESS --
    ' Server.variables("URL") is used to populate the attribute action for the tag <FORM>
    ' MDM V2 - We changed the first parameter it is not more the html template file name but the html source code.
    If (Service.RenderHTML( _
                                Form.HTMLTemplateSource, _
                                varHTMLRendered, _
                                request.serverVariables("URL"), _
                                lngRenderFlags, _
                                strTabTemplateContent & strOptionalHTMLTemplateSourceCode, _
                                Form _
                        )) Then

          ' Update the EventInfo Structure. The property cannot be passed as Byref parameter to the function RenderHTML because it is a property! Remember!
          EventArg.HTMLRendered = varHTMLRendered
          varHTMLRendered       = Empty         ' Free some space
          
          ' Call the OnOpen Event
          If (Not mdm_CallEvent("Form_Paint(EventArg)", Form.ErrorHandler)) Then
              
          End If
    
          If (booErrorMessage) Then                    
          
                Form_DisplayErrorMessage EventArgError ' Let Us Do not forget to set the event
                Response.Write mdm_GetHTMLHiddenTagError(EventArgError.Error)
          End If
  
          ' Print the HTML source, If we have to else we store it in the output parameter strOutPutHTMLRendered
          If (booPrintHTML) Then
          
              Response.Write CStr(EventArg.HTMLRendered) ' Write the template processed
          Else
              strOutPutHTMLRendered = CStr(EventArg.HTMLRendered)
          End If
          EventArg.HTMLRendered = Empty ' Free Some Space
          
          EventArg.Clear
          mdm_OnOpenDlg = True
          
          If (Len(Form.HelpFile)) Then
              Session("HelpContext") = Form.HelpFile
          Else
              Session("HelpContext") = mdm_BuildHelpFileName(request.serverVariables("URL"))
          End If
    Else
          Response.Write mdm_GetMDMLocalizedError("MDM_ERROR_1022")
    End If
        
        ' Debug mdmManager
    If (Service.Configuration.DebugMode) Then
    
          mdm_DisplayDebugInfo Array("DlgId", GetDialogId(), _
                                    "Tpl", strFullPathTemplateFileName, _
                                    "Service.Name", Service.Name, _
                                    "Values", Service.Properties.ToString(True) _
                                    )
    End If

End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_OnOk
' PARAMETERS            :
' DESCRIPTION           : When a User pressed the OK Button this function deals with the
'                     all process.
'                     1 - Populate the Instance Service with the Query String!
'                     2 - If there is an error then call the Form_Error Event and redirect the page to print the dialog with the error!
'                     3 - Test if all the required fiels are set, If there is an error then call the Form_Error Event and redirect the page to print the dialog with the error!
'                     4 - If there is no error call the event OK_Click!
'                     5 - If OK_Click return FALSE redirect the page to print the dialog with the USER error
'                     6 - If OK_Click returns TRUE, Close the dialog and redirect to the end page
'
'                     The function do the Response.ReDirect
'
' RETURNS                       : TRUE if no error occur
Function mdm_OnOk() ' As Boolean
    
    Dim strPropertyName               ' As String
    Dim booError                          ' As Boolean
    Dim booGoBackToDialog           ' As Boolean
    Dim lngErrorCode          ' As Long
    Dim booErrorCode          ' As Long
    Dim strRouteTo            ' As String
    Dim strDummy              ' As String
    Dim objUIItems            ' AS CVariables

    mdm_OnOk = False

    If (mdm_CheckForTimeOut()) Then Exit Function
    
    If (Not mdm_CheckDialogIsMemory("mdm_OnOk", True)) Then Exit Function
    
    If (Not mdm_SetAtGlobalLevelTheServiceInstance("mdm_OnOk")) Then Exit Function ' Get from session Or Create the MSIXHandler Instance
    
    mdm_OnOpen ' MDM 3.0 - Last Minute event
            
    booError = False
    booGoBackToDialog = False
        
        ' Put properties value from the query string to the COM instance. All the properties are set even if we
        ' have an error, in case of :
        '       - type mismatch : The property is not set and so keep its old value.
        '                                         The function mdm_PopulateCOMInstanceWithQueryString() return false.
        '       - string to long: First this case should not happen because the UI takes care of it! Well anyway
        '                                 in this case the value is truncated and the function
        '                                         mdm_PopulateCOMInstanceWithQueryString() return false.
        '                                         Detail about the error are logged in the mtlog.txt.
        '
      ' The function populate the object EventArg.Error.

     mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
     Set EventArg.UIParameters = objUIItems
      
     If (Not mdm_CallEvent("Form_Populate(EventArg)", Form.ErrorHandler)) Then
      
     End If
       
      booError = Not mdm_PopulateCOMInstanceWithQueryString(objUIItems, EventArg, Service, True)
      
      If (booError) Then ' We found an error we go back to the screen with an error message for the user.
  
          booGoBackToDialog = True ' Error because one field is not set with a correct value in the form
      Else  
          If (Service.RequiredFieldsOK(EventArg.Error)) Then ' Check to see if all the required field are set
                  
                EventArg.Clear ' Call the OnOk Event - The event may not be implemented
          
                If (mdm_CallEvent("OK_Click(EventArg)", Form.ErrorHandler)) Then
                  
                    If (Not Form.Modal) Then ' MDM V2 - this was the only mode in V1
                        ' The instance of the Service will be deleted by the mdm_OnTerminate
                        ' The Form.RouteTo will no longer exist We save it before and use the variable after
                        strRouteTo = Form.RouteTo
                        mdm_OnTerminate
                        If (Len(strRouteTo) > 0) Then Response.redirect strRouteTo ' Then route the next page
        
                    Else ' MDM V2 - This a new mode call modal where the form is opened in a pop up window
                         ' This OK event here does not terminate the dialog but render it one last time.
                         ' The OK_CLICK event of the dialog can set Form.JavaScriptInitialize = "mdm_CloseWindow();" & VBNEWLINE
                         ' This will close the dialog. Comment not finished.
                         mdm_TestIfFormMustBeSavedAndSave
                         
                         If Len(Form.JavaScriptInitialize)=0 Then ' If modal and we have no JavaScript Initialization Code, we generate one from Form.RouteTo property

                            Form.JavaScriptInitialize = "mdm_RefreshCallerAndCloseWindow('" & mdm_ProcessParameter() & "','" & mdm_GetFormRouteParameter() & "');" & vbNewLine
                         End If
                         
                         ' mdmRefreshForClose=TRUE Tell the dialog to refresh but just to execute the Form Init Java Script that will close the dialog.
                         ' See module mdmLibrary.asp fucntion mdm_PopulateCOMInstanceWithQueryString() at the end the comment
                         Response.redirect request.serverVariables("URL") & "?mdmRefreshForClose=TRUE&mdmAction=" & MDM_ACTION_REFRESH  ' We recall the same URL, so we go back to the dialog
                    End If
                Else        
                      mdm_LogWarning Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1015"), "[EVENT]", "OK_Click")
                      booGoBackToDialog = True ' Error because OK_Click event returned false
                End If
            Else
              booGoBackToDialog = True ' Error because one required field is not set
            End If
      End If
      
      If (booGoBackToDialog) Then
        
          mdm_LogWarning GetDialogId() & " OK_Click event failed. ErrorMessage=" & EventArg.Error.ToString() ' Log as a warning the fact that we have a problem
          
          Form_Error EventArg  ' Call the OnError Event - The event may not be implemented. Here we must not clear the error info!
          
          mdm_OnOk = False '  We have an error
          
          ' Store the EventInfo object in a session var so in the next call the function mdm_OnOpenDlg will read and free this object
          Set Session(mdm_EVENT_ARG_ERROR) = EventArg
          strDummy = EventArg.Error.PropertyCaption(Service) ' Force to read the property caption, so now it is in the COM object cache!
                                                 ' See VB implementation of MDMError object Method caption!

          mdm_Terminate ' Free all the objects and save the form object in the session.
                        ' This bug was discovered the 12/2/2000.
                        
          If mdm_IsPicker Then          
            Response.redirect mdm_GetCurrentFullURL() & "MDMAction="  & MDM_ACTION_REFRESH
          Else
            Response.redirect mdm_GetCurrentFullURL()
          End If
          
      Else
          mdm_OnOk = True
      End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_OnTerminate
' PARAMETERS            :
' DESCRIPTION   : When a dialog must be closed this function is called.
'                 This function call the event Form_Terminate. And do some
'                 Clean up. This function is called by mdm_OnOk and mdm_OnCancel
' RETURNS                       :
Function mdm_OnTerminate() ' As Boolean

    mdm_OnTerminate = False
          If (Not mdm_SetAtGlobalLevelTheServiceInstance("mdm_OnTerminate")) Then Exit Function ' Get from session Or Create the MSIXHandler Instance
    
    ' This function must not clear the ErrorInfo Object It will affect the OnOk Or OnCancel event
    mdm_OnTerminate = mdm_CallEvent("Form_Terminate(EventArg)", Form.ErrorHandler)
    
    mdm_DeleteDialogFromMemory
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : mdm_CheckForTimeOut
' PARAMETERS  : Only use by mdm_OnOK
' RETURNS     :
PUBLIC FUNCTION mdm_CheckForTimeOut() ' As Boolean

    If Form.LoginDialog Then

        If Not mdm_IsServiceInstanceInMemory() Then

              Dim s
              s = Form.LoginDialogRouteTo
              If Len(s)=0 Then s = request.ServerVariables("URL")
              Response.Redirect s & "?Message=" & Server.URLEncode(mdm_GetDictionary().Item("MDM_ERROR_1025").Value)
        End If
    Else
        mdm_CheckForTimeOut = False
    End If    
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_OnCancel
' PARAMETERS            :
' DESCRIPTION   : When a User pressed the CANCEL Button this function deal with the
'                 all process.
'                 1 - Call the event OK_Click
'                 2 - Close the dialog and redirect to the end page
'
'                 The function do the Response.ReDirect
' RETURNS                       : TRUE.
Function mdm_OnCancel() ' As Boolean

    Dim strRouteTo              ' As String
    
    mdm_OnCancel = False
    
    If (Not mdm_CheckDialogIsMemory("mdm_OnCancel", True)) Then Exit Function
    
    If (Not mdm_SetAtGlobalLevelTheServiceInstance("mdm_OnCancel")) Then Exit Function ' Get from session Or Create the MSIXHandler Instance
    
    mdm_OnOpen ' MDM 3.0 - Last Minute event
        
    ' Call the OnCancel Event
    EventArg.Clear
    
    If (Form.Modal) Then ' MDM V2 - this was the only mode in V1
        Form.JavaScriptInitialize = "mdm_CloseWindow();" & vbNewLine
    End If
    'mdm_OnCancel = Cancel_Click(EventArg) ' Call the OnCancel EventArg.
    mdm_OnCancel = mdm_CallEvent("Cancel_Click(EventArg)", Form.ErrorHandler)
    
    If (Not Form.Modal) Then ' MDM V2 - this was the only mode in V1
        strRouteTo = Form.RouteTo
          mdm_OnTerminate
    Else ' MDM V2 - This a new mode call modal where the form is opened in a pop up window
         ' This OK event here does not terminate the dialog but render it one last time.
         ' The OK_CLICK event of the dialog can set Form.JavaScriptInitialize = "mdm_CloseWindow();" & VBNEWLINE
         ' This will close the dialog. Comment not finished.
         mdm_TestIfFormMustBeSavedAndSave
         Response.redirect request.serverVariables("URL") & "?mdmAction=" & MDM_ACTION_REFRESH  ' We recall the same URL, so we go back to the dialog
    End If
    Response.redirect strRouteTo
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_OnClick
' PARAMETERS            :
' DESCRIPTION   : When a User pressed the a Button other than CANCEL and OK this function deals with the
'                 all process.
'                 1 - Clear the EventInfo.Error object
'                 2 - Call the event Gorm_Click(EventArg)
'                 3 - Response.ReDirect the page to itself to re open the dialog.
' RETURNS                       : TRUE.
Function mdm_OnClick(strEventName, booOpenDialog) ' As Boolean

    Dim strRouteBack    ' As String
    Dim strEventName2
    Dim booError
    Dim objUIItems
    
    mdm_OnClick = False
    If (Not mdm_SetAtGlobalLevelTheServiceInstance("mdm_OnClick")) Then Exit Function ' Get from session Or Create the MSIXHandler Instance
    
    mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
    Set EventArg.UIParameters = objUIItems

    If (Not mdm_CallEvent("Form_Populate(EventArg)", Form.ErrorHandler)) Then
    End If
    
    booError = Not mdm_PopulateCOMInstanceWithQueryString(objUIItems, EventArg, Service, False) ' Populate the COM object - Here we do not care about error. FALSE stand for RaiseError = FALSE
    
    ' Call the OnCancel Event
    EventArg.Clear
    EventArg.Name = strEventName     ' Set the event name
    
    mdm_OnClick = mdm_CallEvent("Form_Click(EventArg)", Form.ErrorHandler)
    'mdm_OnClick     =   Form_Click(EventArg)

    
    ' We need to redirect to the page itself but we need to remove the action Click
    ' on this button so for instance : If the user clicked on the clear button.
    ' The query clause contains CLEAR.x=67, we will rename the entry _LEAR.X. So we can
    ' ignore it.
    
    strRouteBack = mdm_GetCurrentAspCall()
    ' erase the clear.x from the query string and recall it!
          strRouteBack = Replace(strRouteBack, strEventName & ".x", strEventName & "._", 1, -1, vbTextCompare)
          
    If (booOpenDialog) Then
          mdm_OnOpenDlg False, True, Empty, True, Empty, GetDefaultRenderingFlag() ' Call mdm_OnRefresh in refresh mode and not in initialize mode
    End If
        mdm_OnClick = True
  
End Function



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_OnRefresh
' PARAMETERS            :
' DESCRIPTION   : This event is called when a dialog ask for it! By setting the QueryString
'                 parameter mdmAction="REFRESH"! The function populate
'                 - The Service object
'                 - For each property that has the EventFlag set call the event PropertyName_Click
'                 - call directly the mdm_OnOpenDlg function.
' RETURNS                       :
Function mdm_OnRefresh(booReOpenDialog) ' As Boolean

    Dim strErrorString
    Dim booError
    Dim strQueryStringValue
    Dim objProperty
    Dim strPropertyName
    Dim objUIItems
    Dim lngTabIndex
    Dim booEventReturnCode
        
    mdm_OnRefresh = False
    
    If (Not mdm_CheckDialogIsMemory("mdm_OnCancel", True)) Then Exit Function
    
    If (Not mdm_SetAtGlobalLevelTheServiceInstance("mdm_OnRefresh")) Then Exit Function ' Get from session Or Create the MSIXHandler Instance
    
    ' Populate the instance
    mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
    Set EventArg.UIParameters = objUIItems

    If (Not mdm_CallEvent("Form_Populate(EventArg)", Form.ErrorHandler)) Then
    
    End If
        
    booError = Not mdm_PopulateCOMInstanceWithQueryString(objUIItems, EventArg, Service, False) ' Populate the COM object - Here we do not care about error. FALSE stand for RaiseError = FALSE
        
    strPropertyName = mdm_UIValue("mdmProperty") ' If there is a an event to call in the query string call it!
    
    If (Len(strPropertyName)) Then

        Err.Clear
        EventArg.Error.Clear
        
    
        
        On Error Resume Next
        
        ' MDM Tab are in stand by
        ' -- MDM v2 -- Detect if it is a TAB Event
        'If(InStr(UCase(strPropertyName),MDM_INTERNAL_PREFIX_TAB_INDEX_EVENT)=1)Then
        '
        '    strPropertyName = LEFT(strPropertyName,Len(strPropertyName)-1)                    ' Remove the last char which is a ')'
        '    lngTabIndex     = Mid(strPropertyName,Len(MDM_INTERNAL_PREFIX_TAB_INDEX_EVENT)+1) ' Get the index
        '    Form.Tabs.Item(Clng(lngTabIndex)).Selected = TRUE                                 ' Select the new tab
        '    strPropertyName = "Tabs" ' Change the property so we call the event Tabs_Click
        'End If
                
        ' In MDM 3.5 We process the return code of Custom Button, but to avoid compatibility problem
        ' we 2 check the event must return false and must set an error in the EventArg.Error.                
        booEventReturnCode = mdm_EventDispatcher(strPropertyName, "Click", "EventArg")
        If (Err.Number) Then
            'strErrorString = mdm_GetErrorString()
            EventArg.Error.Number = Err.Number
            EventArg.Error.Source = Err.Source
            strErrorString = Err.Description            
            EventArg.Error.Description = Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1013"), "[NAME]", strPropertyName & "_Click()") & strErrorString
            Form_DisplayErrorMessage EventArg
        Else            
          If (booEventReturnCode=FALSE)And(EventArg.Error.Number) Then ' Dialog return an error
          
              Form_DisplayErrorMessage EventArg
          End If
        End If
        On Error GoTo 0
    End If
    If (booReOpenDialog) Then
          mdm_OnOpenDlg False, True, Empty, True, Empty, GetDefaultRenderingFlag() ' Call mdm_OnRefresh in refresh mode and not in initialize mode
    End If
    mdm_OnRefresh = True
End Function


Private Function mdm_EventDispatcher(strObjName, strEventName, strArgName)

    Dim strVBScriptOnTheFly

    strObjName = Replace(strObjName, ".", "_") ' Support COM Compound Object Property Event
    
    strVBScriptOnTheFly = strVBScriptOnTheFly & strObjName & "_" & strEventName & IIf(Len(strArgName), "(" & strArgName & ")", "") & vbNewLine
    mdm_EventDispatcher = Eval(strVBScriptOnTheFly)
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : mdm_Initialize
' PARAMETERS  :
' DESCRIPTION : MDM Constructor! That's mean each time we include this asp file in another this function will
'               be executed! That's why you should include this file only it you use it.
' RETURNS     : TRUE / FALSE
Function mdm_Initialize()

    mdm_PerformanceManager TRUE ' see global setting MDM_DISPLAY_PERFORMANCE_INFO
    
    mdm_InitializeConstants
    
    mdm_CacheInit
    Set Service = Nothing
    Set EventArg = mdm_GetNewMDMEventInstance()
    
    mdm_TestIfFormMustRestoredAndRestore ' Get or create the Form object
    
    mdm_RefreshFromClickFromObject = false
    
    mdm_Initialize = True
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_Terminate
' PARAMETERS            :
' DESCRIPTION           : MDM Destructor! This function is called by the 2 main entry point function mdm_Main() and
'                     mdm_PVBrowserMain()!
' RETURNS                       :
Function mdm_Terminate()
    
    mdm_TestIfFormMustBeSavedAndSave
    
    Set Form = Nothing              ' Free this ref, the form may have been saved in a session var
    Set Service = Nothing
    Set ProductView = Nothing
    Set COMObject = Nothing
    Set EventArg = Nothing
    Set mdm_InternalCache = Nothing
    mdm_Terminate = True
    
    mdm_PerformanceManager FALSE
    
End Function

' If the unique id has not been set, then set it to blank
If Len(mdm_DialogID) = 0 Then
  Call mdm_SetDialogID("")
End If  

'  Here is one of my trick...
'  Before any thing is called we initialized the mdm.
' The mdm_Terminate is called by mdm_Main()/mdm_PVBrowserMain()
mdm_Initialize

' *********************************************************************************************************************************************************
' PRODUCT VIEW BROWSER MANAGER
' *********************************************************************************************************************************************************

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_pvb_OpenProductView
' PARAMETERS            :
' DESCRIPTION   :
' RETURNS                         :
Function mdm_pvb_OpenProductView(booInitialized, booRefresh, strPageAction)

    Dim strHTMLTemplateRendered     ' As String
    Dim strFullPathTemplateFileName ' As String
    Dim booDebugMode                ' As Boolean
    Dim strHTMLRendered             ' As String
    Dim objSortedProperty           ' As String
    Dim objSortProfiler             ' As Object
    Dim objRowsetfilter
    Dim strTmpFilter
    Dim booFilterWasThere
    Dim strTmpFilter2
    Dim strErrorMessage, enumFilterOperator, booApplyFilter

    mdm_pvb_OpenProductView = FALSE
    booApplyFilter          = TRUE

    If (Not mdm_SetAtGlobalLevelTheServiceInstance("mdm_pvb_OpenProductView")) Then Exit Function ' Get from session Or Create the MSIXHandler Instance
        
    booDebugMode = Service.Configuration.DebugMode                            ' Do not want the function mdm_OnOpenDlg to display the debugger if on
    ProductView.Configuration.DebugMode = False
    
    Select Case strPageAction ' What do we have to do

        Case MDM_ACTION_DEFAULT
        
              Form.Grid.TurnDowns.Clear
              
              ' Each time a PVB dialog is initialized we remove/clear the property mdmIntervalId
              ' so we show the current interval id rather than the last viewed. Because we have
              ' a synchronisation problem between the PVB data and the Interval ID combox box...
              If (Service.Properties.Exist("mdmIntervalId")) Then Service.Properties.Remove "mdmIntervalId"
  
              ' MDM V2 - We load the template now and store it in Form.HTMLTemplateSourceCode
              If (Not LoadHTMLTemplateSourceInForm()) Then
                ' Error
              End If
              
              ' I call the event here and not in the mdm_OnOpenDlg() Function because
              ' In between the event Form_Initialize and For_paint I want to execute
              ' some code. This is different from a dialog
              ' Call the OnInitialize Event...
              EventArg.Clear

              ' Clear the filter if we are not remembering it between page refreshes
              mdm_ClearFilter
        
              '
              ' Bug10722, 2003-8-18
              '
              ' When Kevin and Fred Investigated this bug, they discovered that we should actualy call
              ' the FORM_Initialize only if booInitialized is false.
              ' BUT WE DID NOT CHANGE IT, BECAUSE IT WILL AFFECT ALL THE PVB DIALOGS THAT RELY ON THE
              ' FACT FORM_INITIALIAZE IS CALLED FOR EVERY MDM ACTION/EVENT.
              ' TO FIX THE PROBLEM Look at the event FORM_INITIALIZE DIALOG GroupPOSelect.asp, MAM application. 
         
              ' Add dialog to list of dialogs to be cleaned up by the DialogCollector
              Call mdm_DialogCollectorAdd(GetDialogId(), mdm_UIValueDefault("mdmKeepAlive", False)) 
     
              If (Not mdm_CallEvent("Form_Initialize(EventArg)", Form.ErrorHandler)) Then
              
                  mdm_LogWarning Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1015"), "[EVENT]", "Form_Initialize")
                                  ' I call the cancel event because this event route to the route to page
                  mdm_OnCancel    ' If the programmer want to do something special he can do it in the cancel event by testing Form.Initialized.
                  Exit Function
              Else
                  Form.Initialized = True '  Tell the programmer that the dialog initilalize event succeed
              End If
  
              ' Call the special PV Event Form_LoadProductView
              EventArg.Clear
              
              If (Not mdm_CallEvent("Form_LoadProductView(EventArg)", Form.ErrorHandler)) Then
              
                  mdm_LogWarning Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1015"), "[EVENT]", "Form_LoadProductView")
                                  ' I call the cancel event because this event route to the route to page
                  mdm_OnCancel    ' If the programmer want to do something special he can do it in the cancel event by testing Form.Initialized.
                  Exit Function
              Else
                  Form.Initialized = True '  Tell the programmer that the dialog initilalize event succeed
              End If
                        
        Case MDM_ACTION_REFRESH
          
              ' Do not clear the turn down if the refresh comes from a button click
              If(Not mdm_RefreshFromClickFromObject) Then 
                  Form.Grid.TurnDowns.Clear
                  ProductView.Properties.Selector.Clear
              End If                
              
              ProductView.Properties.Interval.Id = mdm_UIValueDefault("mdmIntervalId", ProductView.Properties.Interval.Id)
              If (ProductView.Properties.Exist("mdmIntervalId")) Then ' Test because we support direct SQL ROWSET and Product View RoweSet
              
                  ProductView.Properties("mdmIntervalId").Value = ProductView.Properties.Interval.Id
                  'Response.write "INTERVAL ID=" & ProductView.Properties("mdmIntervalId").Value   & "<br>"
              End If
  
              ' Call the special PV Event Form_LoadProductView
              EventArg.Clear
              If (Not mdm_CallEvent("Form_LoadProductView(EventArg)", Form.ErrorHandler)) Then
                                  ' I call the cancel event because this event route to the route to page
                  mdm_OnCancel    ' If the programmer want to do something special he can do it in the cancel event by testing Form.Initialized.
                  Exit Function
              End If
              EventArg.Clear
              If (Not mdm_CallEvent("Form_Refresh(EventArg)", Form.ErrorHandler)) Then
              
              End If

        Case MDM_ACTION_REVERSESORT
        Case MDM_ACTION_REDRAW
                    
    End Select
    
    ' MDM V2 -- We need to do the filtering here because the property Form.Page.MaxPage is based on Rowset.RecordCount.
    ' We also need to filter before we sort...
    If (Len(Form.Grid.Filter)) Then

        strTmpFilter = Trim(Form.Grid.Filter)
        
        '
        ' ADO bug raise an error when filter like this : LIKE "%Fred"
        ' Derek, Simon and Fred Decided that if we find this case we will raise an error saying we do not support this case
        ' Rather that returning the error or an inexact result!
        '
        If Len(strTmpFilter)  Then
            If Mid(strTmpFilter,1,1)="*" Then
                mdm_SaveErrorInSession 1020 , mdm_GetMDMLocalizedError("MDM_ERROR_1028")                            
                strTmpFilter=empty
            End if         
        End If

        If (Len(strTmpFilter) And (strTmpFilter <> MDM_ACTION_PVB_FILTER_RESET)) Then

            If Form.Grid.FilterMode = MDM_FILTER_MULTI_COLUMN_MODE_ON Then ' MDM v2.2 - Support Filter based on a combobox list of property we are here setting the hard coded property based on the combobox selected value                                                                                   '
              mdm_SetFilterPropertyAndType
                'If Len(mdm_UIValue("mdmPVBFilterColumns")) Then 
                 '  Set Form.Grid.FilterProperty = ProductView.Properties(mdm_UIValue("mdmPVBFilterColumns")) ' There is case where we not going to set the property but we do not want to lose the previous values : case filter + goto to next page
                 '  ProductView.Properties("mdmPVBFilterColumns").Value = mdm_UIValue("mdmPVBFilterColumns")
                'End If
            End If

            if Form.Grid.ApplyFilter then 'Some pages will do their own filtering in the backend and we do not need to reapply the MDM filter through ADO
              If (strTmpFilter <> "*") Then ' Remove this case which make a crash
                                     
                   enumFilterOperator  = GetRowsetOperator(Form.Grid.FilterOperator,UCase(Form.Grid.FilterProperty.PropertyType))
                   Set objRowsetfilter = Service.Properties.Rowset.Filter
                   booFilterWasThere   = IsValidObject(objRowsetfilter)
                   
                   mdm_SetFilterObjectFromCurrentFilterSettings objRowsetfilter
                   
                  If booApplyFilter Then 
                  
                       On Error Resume Next
                       ProductView.Log "FilterString " & objRowsetfilter.FilterString ' Some time this can raise an error we want to ignore it. we will catch it when we apply the filter
                       On Error Goto 0
                       
                       On Error Resume Next
                       If (booFilterWasThere) Then
                           Service.Properties.Rowset.ApplyExistingFilter
                       Else
                           Set Service.Properties.Rowset.Filter = objRowsetfilter
                       End If
                       If Err.Number Then                 
                          strErrorMessage = mdm_GetErrorString()
                          mdm_SaveErrorInSession 1024 , mdm_GetMDMLocalizedError("MDM_ERROR_1024")
                          ProductView.Log "Filter Error:" & strErrorMessage                    
                       Else
                          'Form.Grid.Filter = "" ' Filter has been apply we clear it - This was added in mdm 3.5 - Looks like in before we  were doing the filtering each time we were changing page for example
                       End If
                   End If
                   On Error Goto 0
               End If
             End If 'if Form.Grid.ApplyFilter
          End If

    End If
    
    ' Give the rowset to the MDM
    Set Form.Page.Rowset = Service.Properties.Rowset               ' Set a ref of the rowset into the page object, so now
                                                                   ' the page object can execute some logic like, computing the numbe of page.
    ProductView.PreProcessor.Add "MAX_PAGE", Form.Page.MaxPage     ' Add the MaxPage to the Service Preprocessor, the toolbar max page info can
                                                                   ' be rendered
                                                                       
    ' This entry is stored as an hidden html field, so FredRunner can do some testing based on the number of rows
    mdm_GetDictionary().Add "MDM_PVB_ROWSET_RECORD_COUNT", Form.Page.Rowset.RecordCount
                                                                    
    ' If no page index is defined we start from one. This is good because when we change the interval combo box we issue a mdmAction=REFRESH, this imply
    ' mdmPageAction=Refresh, but there is no page index defined! In case of redraw we do nothing...
    If (strPageAction <> MDM_ACTION_REDRAW) And (strPageAction <> MDM_ACTION_TURN_DOWN) And (strPageAction <> MDM_ACTION_TURN_RIGHT) Then
    
        Form.Page.Index = mdm_UIValueDefault("mdmPageIndex", 1)
    End If
    
    If (strPageAction = MDM_ACTION_REFRESH) Then    
        Form.Page.Index = 1
    End If
    
    Dim lngPreviousPage:lngPreviousPage = Form.Page.Index
    
    Select Case strPageAction
    
        'CASE MDM_ACTION_REFRESH
        'CASE MDM_ACTION_REDRAW

        Case MDM_ACTION_FIRSTPAGE
           
            Form.Page.Index = 1
            Form.Grid.TurnDowns.Clear            
            Form_ChangePage EventArg,lngPreviousPage,Form.Page.Index ' Call event mdm 3.5
            
        Case MDM_ACTION_LASTPAGE
            Form.Page.Index = Form.Page.MaxPage
            Form.Grid.TurnDowns.Clear
            Form_ChangePage EventArg,lngPreviousPage,Form.Page.Index ' Call event mdm 3.5
            
        Case MDM_ACTION_NEXTPAGE            
            Form.Page.Index = Form.Page.Index + 1 '  Do need to check if we over flow the VB code do it for us
            Form.Grid.TurnDowns.Clear
            Form_ChangePage EventArg,lngPreviousPage,Form.Page.Index ' Call event mdm 3.5
            
        Case MDM_ACTION_PREVIOUSPAGE
            Form.Page.Index = Form.Page.Index - 1 '  Do need to check if we over flow the VB code do it for us
            Form.Grid.TurnDowns.Clear
            Form_ChangePage EventArg,lngPreviousPage,Form.Page.Index ' Call event mdm 3.5
            
        Case MDM_ACTION_GOTOPAGE
            dim iMDMGotoPage
            if len(mdm_UIValue("mdmPageIndex"))>0 then
                iMDMGotoPage = CLng(mdm_UIValue("mdmPageIndex"))
            else
                iMDMGotoPage = 1
            end if
            if Form.Page.MaxPage>Form.Page.MaxPage then
              Form.Page.MaxPage=Form.Page.MaxPage
            end if
            Form.Page.Index = iMDMGotoPage
            Form.Grid.TurnDowns.Clear
            Form_ChangePage EventArg,lngPreviousPage,Form.Page.Index ' Call event mdm 3.5
            
        Case MDM_ACTION_SORT
            Form.Grid.TurnDowns.Clear
            ' Set the property sorted of the product view column
            If (ProductView.Properties(CStr(mdm_UIValue("mdmSortColumn"))).Sorted > 0) Then ' If the property is already the sorted property reverse the sort
                ProductView.Properties.SortedProperty.ReverseSort
            Else
                ProductView.Properties(CStr(mdm_UIValue("mdmSortColumn"))).Sorted = MTSORT_ORDER_ASCENDING   ' Sort a new property
            End If
            
        Case MDM_ACTION_REVERSESORT
            Form.Grid.TurnDowns.Clear
            ProductView.Properties.SortedProperty.ReverseSort ' Set the property sorted of the product view column
    End Select
    
    If (ProductView.Properties.RowsetSupportSort()) Then
    
        Set objSortedProperty = ProductView.Properties.SortedProperty
        
        If (IsValidObject(objSortedProperty)) Then
        
            'Set objSortProfiler = CreateObject(CProfiler) : objSortProfiler.Start TRUE,"mdm.asp", "mdm_pvb_OpenProductView","SORT TIME"
            On Error Resume Next
            ProductView.Properties.Rowset.Sort objSortedProperty.Name, objSortedProperty.Sorted
            If (Err.Number) Then
                Response.Write Replace(MDM_ERROR_1020, "[PROPERTY]", objSortedProperty.Name)
                Response.END
            End If
            On Error GoTo 0
            'Set objSortProfiler = Nothing
        End If
    End If
    
    ProductView.PreProcessor.Add "MDM_TOOL_BAR_PAGE_WORD", mdm_GetDictionaryValue("MDM_TOOL_BAR_PAGE_WORD", MDM_TOOL_BAR_PAGE_WORD)
    ProductView.PreProcessor.Add "MDM_TOOL_BAR_OF_WORD", mdm_GetDictionaryValue("MDM_TOOL_BAR_OF_WORD", MDM_TOOL_BAR_OF_WORD)
    ProductView.PreProcessor.Add "PAGE_INDEX", Form.Page.Index              ' Add the Page Index to the Service Preprocessor, the toolbar max page info can be rendered!
    
    If (Form.Page.MaxPage = 0) Then ' If no data
    
        ProductView.PreProcessor.Add "MAX_PAGE", ""
        ProductView.PreProcessor.Add "PAGE_INDEX", ""
        ProductView.PreProcessor.Add "MDM_TOOL_BAR_PAGE_WORD", ""
        ProductView.PreProcessor.Add "MDM_TOOL_BAR_OF_WORD", ""
    End If
    
    ' Define the missing piece of the gif file name we we can have available or grayed
    ProductView.PreProcessor.Add "ENABLED_IMAGE", IIf(Form.Page.MaxPage <= 1, "disabled", "enabled")
    ProductView.PreProcessor.Add "ROLLED_IMAGE", IIf(Form.Page.MaxPage <= 1, "disabled", "rolled")
    
    ' If the Interval Id is loaded we add a enum type field to the product view so the rendering process
    ' will field the UI Template file with it is asked!
    If (ProductView.Properties.RowsetSupportInterval()) Then
    
        mdm_pvb_DoToProductViewTheIntervalIDFieldAsEnumType MDM_ACTION_ADD, ProductView
    End If
    
   'Set the filter
    If (Form.Grid.FilterMode) Then 
     If (Not Service.Properties.Exist("mdmPVBFilter")) Then
       Service.Properties.Add "mdmPVBFilter", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
     End If
     If (Not Service.Properties.Exist("mdmPVBFilter2")) Then
       Service.Properties.Add "mdmPVBFilter2", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
     End If
     If (Not Service.Properties.Exist("mdmPVBFilterOperator")) Then
       Service.Properties.Add "mdmPVBFilterOperator", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
     End If
     If (Not Service.Properties.Exist("mdmPVBFilterColumns")) Then
       Service.Properties.Add "mdmPVBFilterColumns", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
     End If
     
     If(Form.Grid.Filter = MDM_ACTION_PVB_FILTER_RESET) Then
       mdm_ClearFilter
     Else
       If Form.Grid.FilterPropertySave = True Then
         Service.Properties("mdmPVBFilter").Value = Form.Grid.Filter
         Service.Properties("mdmPVBFilter2").Value = Form.Grid.Filter2
         Service.Properties("mdmPVBFilterOperator").Value = Form.Grid.FilterOperator    
         Service.Properties("mdmPVBFilterColumns").Value = Form.Grid.FilterPropertySaveValue   
         mdm_GetDictionary().Add "MDM_FILTER_OPERATOR_SAVE", Form.Grid.FilterOperator
       Else
         mdm_ClearFilter
       End If  
     End IF 

    End IF
    
    ' MDM v2.1 - Support Export Icon
    mdm_GetDictionary().Add "MDM_PVB_EXPORT_MODE", CStr(Form.ShowExportIcon)
    
    ' Response.write "BEFORE RENDER - INTERVAL ID=" & ProductView.Properties("mdmIntervalId").Value   & "<br>"
    ' Now we call the RENDERER to render the HTML template file, but we do not print it because we want to response.write the all screen
    ' I removed the rendering of localized image...to speed the process of 0.5 s on my machine...
    mdm_OnOpenDlg False, booRefresh, mdm_pvb_HTMLToolBarSourceCode(Service), False, strHTMLTemplateRendered, GetDefaultRenderingFlag() - eMSIX_RENDER_FLAG_RENDER_IMG_TAG ' No Initialize because we just did it
    
    ProductView.Configuration.DebugMode = booDebugMode ' Restore the value
        
    If (mdm_pvb_RenderProductViewHtml(strPageAction, strHTMLTemplateRendered)) Then
    
    End If
            
          ' Debug mdmManager
    If (Service.Configuration.DebugMode) Then
    
        mdm_DisplayDebugInfo Array("DlgId", GetDialogId(), _
                                    "Tpl", strFullPathTemplateFileName, _
                                    "Service.Name", Service.Name, _
                                    "Values", Service.Properties.ToString(True) _
                                    )
    End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_pvb_RenderProductViewHtml
' PARAMETERS            :
' DESCRIPTION           :
' RETURNS                       :
Function mdm_pvb_RenderProductViewHtml(strPageAction, strHTMLTemplateRendered) ' As Boolean
    Dim objProperty                    ' AS ServiceProperty
    Dim strTable                   ' As String
    Dim strPreProcessed          ' As String
    Dim objProfiler          ' MTVBLib.CProfiler
    Dim objRowProfiler       ' MTVBLib.CProfiler
    Dim objDetailRowProfiler ' MTVBLib.CProfiler
    Dim strSelectorHTMLCode  ' As String
    Dim strAlign             ' As String
    Dim strValue             ' As String
    Dim i                    ' As Long
    Dim lngTableNumberOfCols ' As Long
    Dim lngRowCounter        ' As Long
    Dim objCat               ' As MTVBLib.CStringConcat
    ' Dim varCurrentRowsetPosition #MDM V2 -5/30/2001
    Dim objTool              ' Object
    Dim booIncludeRow        ' As Boolean
    Dim EventArgError, booErrorMessage
    
    Set objTool = mdm_CreateObject(MSIXTools)
    Set objCat = mdm_CreateObject(CStringConcat)
    
    objCat.Init MDM_STRING_CONCAT_BUFFER_SIZE ' Use a 16Kb buffer
    objCat.AutomaticCRLF = True    
    objCat.Concat strHTMLTemplateRendered
    
    Set objProfiler = CreateObject(CProfiler)
    objProfiler.Start True, "mdm.asp", "mdm_pvb_RenderProductViewHtml"
        
    ' Call Event
    EventArg.HTMLRendered = Empty
    Form_DisplayBeginOfPage EventArg
          objCat.Concat EventArg.HTMLRendered

    ' Call Event
    EventArg.HTMLRendered = Empty
    Form_DisplayBeginHeader EventArg
          objCat.Concat EventArg.HTMLRendered

    ' Call Event Header Cell 1
    EventArg.HTMLRendered = Empty
    Form.Grid.Col = 1
    Form_DisplayHeaderCell EventArg
          objCat.Concat EventArg.HTMLRendered
    
    ' Call Event Header Cell 2
    EventArg.HTMLRendered = Empty
    Form.Grid.Col = 2
    Form_DisplayHeaderCell EventArg
          objCat.Concat EventArg.HTMLRendered

    lngTableNumberOfCols = 2
    
          For i = 1 To ProductView.Properties.Count
    
        Set Form.Grid.SelectedProperty = ProductView.Properties.ItemSelected(i)
        If (Form.Grid.SelectedProperty Is Nothing) Then
            Exit For
        Else
            EventArg.HTMLRendered = Empty   ' Call Event Header Cell i
            Form.Grid.Col = i + 2
            Form_DisplayHeaderCell EventArg
            objCat.Concat EventArg.HTMLRendered & vbNewLine
            lngTableNumberOfCols = lngTableNumberOfCols + 1
        End If
        Next
        
    Form_DisplayEndHeader EventArg ' Call Event
          objCat.Concat EventArg.HTMLRendered & vbNewLine
    
    If (ProductView.Properties.Rowset.RecordCount) Then
    
        ' Set the right position in the rowset
          mdm_MoveRowsetToPage ProductView.Properties.Rowset, Form.Page
        
        Form.Grid.Row = 0
        lngRowCounter = 0
        'varCurrentRowsetPosition  = mdm_GetRowsetAbsolutePosition(ProductView.Properties.Rowset) #MDM V2 -5/30/2001 -

          Do While Not ProductView.Properties.Rowset.EOF
        
            'Set objRowProfiler = CreateObject(CProfiler)
            'objRowProfiler.Start TRUE, "mdm.asp", "mdm_pvb_RenderProductViewHtml:Row","row=" & lngRowCounter
            
            lngRowCounter = lngRowCounter + 1
            Form.Grid.Row = lngRowCounter
            If (lngRowCounter > Form.Page.MaxRow) Then ' End Of Page
                Exit Do
            End If
            
            If (lngRowCounter Mod 2) Then
                Form.Grid.CellClass = "TableCell"
            Else
                Form.Grid.CellClass = "TableCellAlt"
            End If
            
            ' Check the row Turn Right Or Down
            Select Case strPageAction
            
                Case MDM_ACTION_TURN_DOWN:
                    If (CLng(mdm_UIValue("mdmRowIndex")) = lngRowCounter) Then
                                            
                        Form.Grid.TurnDowns.Add "R" & mdm_UIValue("mdmRowIndex"), True  ' Add the row to the turn down collection
                    End If
                    
                Case MDM_ACTION_TURN_RIGHT:
                    Form.Grid.TurnDowns.Remove "R" & mdm_UIValue("mdmRowIndex")  ' Remove the row from the turn down collection
            End Select
            
            EventArg.HTMLRendered = Empty       ' CALL EVENT Form_DisplayBeginRow for the row 1
            Form_DisplayBeginRow EventArg
            objCat.Concat EventArg.HTMLRendered
                        
            Form.Grid.Col = 1                   ' CALL EVENT Form_DisplayCell for the cell  1, which is the Action Cell
            Set Form.Grid.SelectedProperty = Nothing
            Form_DisplayCell EventArg
                  objCat.Concat EventArg.HTMLRendered
                        
            Form.Grid.Col = 2                   ' CALL EVENT Form_DisplayCell for the cell  2, which is the turn down
            Set Form.Grid.SelectedProperty = Nothing
            Form_DisplayCell EventArg
                  objCat.Concat EventArg.HTMLRendered
            
                  For i = 1 To ProductView.Properties.Count
            
                'Set objDetailRowProfiler = CreateObject(CProfiler)
                'objDetailRowProfiler.Start TRUE,"mdm.asp", "mdm_pvb_RenderProductViewHtml:DETAIL ROW " & i
            
                Set Form.Grid.SelectedProperty = ProductView.Properties.ItemSelected(i)
                If (Form.Grid.SelectedProperty Is Nothing) Then
                    Exit For
                Else
                    Form.Grid.Col = i + 2             ' CALL EVENT Form_DisplayCell for the cell  of the product view
                    EventArg.HTMLRendered = Empty
                    Form_DisplayCell EventArg
                    objCat.Concat EventArg.HTMLRendered
                End If
                    Next
            
            ' CALL EVENT Form_DisplayBeginRow for the row 1
            EventArg.HTMLRendered = Empty
            Form_DisplayEndRow EventArg
            objCat.Concat EventArg.HTMLRendered
            
            If (Form.Grid.TurnDowns.Exist("R" & Form.Grid.Row)) Then
            
                ' Call the 3 event to display the detail row
                EventArg.HTMLRendered = Empty
                Form_DisplayBeginDetailRow EventArg
                  objCat.Concat EventArg.HTMLRendered
    
                EventArg.HTMLRendered = Empty
                Form_DisplayDetailRow EventArg
                objCat.Concat EventArg.HTMLRendered
            
                EventArg.HTMLRendered = Empty
                Form_DisplayEndDetailRow EventArg
                objCat.Concat EventArg.HTMLRendered
            End If
            
            ProductView.Properties.Rowset.MoveNext
            'Set objRowProfiler = Nothing
          Loop
    Else
        objCat.Concat "<TR><TD Class='TableCell' ColSpan=" & lngTableNumberOfCols & "><b>" & Form.Page.NoRecordUserMessage & "</TD></TR>"
    End If
    
    ' CALL EVENT Form_DisplayEndOfPage
    EventArg.HTMLRendered = Empty
    Form_DisplayEndOfPage EventArg
    objCat.Concat EventArg.HTMLRendered & vbNewLine
    
        
    ' MDM 3.0
    Set EventArgError = mdm_GetInstanceFromSession(mdm_EVENT_ARG_ERROR)
    booErrorMessage = IsValidObject(EventArgError)
    If (booErrorMessage) Then ' If Yes then Free the instance in the session (actually the ref)
    
        Set Session(mdm_EVENT_ARG_ERROR) = Nothing
        Form_DisplayErrorMessage EventArgError ' Let Us Do not forget to set the event
        Response.Write mdm_GetHTMLHiddenTagError(EventArgError.Error)
    End If
    Dim HtmlParser 
    Set HtmlParser = mdm_CreateObject("MTMSIX.CHtmlParser")    
    Response.Write mdm_GetDictionary().PreProcess(HtmlParser.HTMLWidgetsProcessorPVB(objCat.GetString(),Form.Widgets))
    
    ' Restore the current position of the rowset
    '#MDM V2 -5/30/2001 - mdm_SetRowsetAbsolutePosition ProductView.Properties.Rowset, varCurrentRowsetPosition
    
    mdm_pvb_RenderProductViewHtml = True
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_pvb_RenderProductViewHtml
' PARAMETERS            :
' DESCRIPTION   :
' RETURNS                         :
Function mdm_pvb_HTMLToolBarSourceCode(Service) ' As String
    
    Dim strHTMLToolBarFileName
    
    strHTMLToolBarFileName = mdm_GetMDMFolder() & IIf(Form.Page.MaxPage > 1, MDM_PRODUCT_VIEW_HTML_TOOL_BAR_HTML_FILE_NAME, MDM_PRODUCT_VIEW_HTML_TOOL_BAR_HTML_FILE_NAME_NO_DATA)
    mdm_pvb_HTMLToolBarSourceCode = Service.Tools.TextFile.LoadFile(strHTMLToolBarFileName)
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_pvb_DoToProductViewTheIntervalIDFieldAsEnumType
' PARAMETERS            :
' DESCRIPTION   :
' RETURNS                         :
Function mdm_pvb_DoToProductViewTheIntervalIDFieldAsEnumType(eAction, ProductView) ' As Boolean

    Dim lngRecCount
    Dim strUsageIntervalText
    Dim varArrID
    Dim varArrLabel
    Dim varID
    Dim varLabel
    Dim objPP
    Dim strTemplate
    
    Select Case eAction
    
        Case MDM_ACTION_DELETE ' Remove the property mdmIntervalID
            On Error Resume Next
            Service.Properties.Remove "mdmIntervalId"
            Service.Properties.Remove "mdmPVBFilter" 
            Service.Properties.Remove "mdmPVBFilter2" 
            Service.Properties.Remove "mdmPVBFilterOperator"                         

            On Error GoTo 0
            Err.Clear
            
        Case MDM_ACTION_ADD ' Set the enum type value for mdmIntervalID
        
            'Service.Properties.Remove "mdmIntervalId"
            
            If (Not Service.Properties.Exist("mdmIntervalId")) Then
        
                lngRecCount = 0
                
                ' Build 2 arrays : interval id and interval label based in the IntervalId Rowset
                ReDim varArrID(ProductView.Properties.Interval.Rowset.RecordCount - 1)
                ReDim varArrLabel(ProductView.Properties.Interval.Rowset.RecordCount - 1)
                
                ProductView.Properties.Interval.Rowset.MoveFirst
                
                Set objPP = mdm_CreateObject(CPreProcessor)
                
                Do While Not ProductView.Properties.Interval.Rowset.EOF
                
                    varArrID(lngRecCount) = ProductView.Properties.Interval.Rowset.Value("IntervalId")
                    
                    objPP.Add "INVOICE_NUMBER", ""
                    
                          If (lngRecCount = 0) Then ' Current Interval
                    
                        strTemplate = mdm_GetDictionaryValue("MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_CURRENT_MONTH", MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_CURRENT_MONTH)
                          Else
                        If (Len(ProductView.Properties.Interval.Rowset.Value("InvoiceNumber"))) Then ' Interval close we have an invoice number

                            objPP.Add "INVOICE_NUMBER", ProductView.Properties.Interval.Rowset.Value("InvoiceNumber")
                            
                            If (ProductView.Properties.Interval.DisplayInvoiceNumber) Then
                                strTemplate = mdm_GetDictionaryValue("MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_PREVIOUS_CLOSED_MONTH", MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_PREVIOUS_CLOSED_MONTH)
                            Else
                                strTemplate = mdm_GetDictionaryValue("MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_PREVIOUS_CLOSED_MONTH_WITH_NO_INVOICE_NUMBER", MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_PREVIOUS_CLOSED_MONTH_WITH_NO_INVOICE_NUMBER)
                            End If
                        Else
                            strTemplate = mdm_GetDictionaryValue("MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_PREVIOUS_NON_CLOSED_MONTH", MDM_PVB_INTERVAL_ID_COMBOX_BOX_FORMAT_PREVIOUS_NON_CLOSED_MONTH)
                        End If
                    End If
                    
                    objPP.Add "START_DATE", Service.Tools.Format(ProductView.Properties.Interval.Rowset.Value("StartDate"), ProductView.Properties.Interval.DateFormat)
                    objPP.Add "END_DATE", Service.Tools.Format(ProductView.Properties.Interval.Rowset.Value("EndDate"), ProductView.Properties.Interval.DateFormat)
                    

                    
                      If (Len(ProductView.Properties.Interval.Rowset.Value("InvoiceNumber"))) Then
                    
                        objPP.Add "INVOICE_NUMBER", ProductView.Properties.Interval.Rowset.Value("InvoiceNumber")
                                    'varArrLabel(lngRecCount) = varArrLabel(lngRecCount) & " "  & TEXT_INVOICE_NUMBER & " " & ProductView.Properties.Interval.Rowset.Value("InvoiceNumber")
                            End If
                    
                    varArrLabel(lngRecCount) = objPP.Process(strTemplate)
                    lngRecCount = lngRecCount + 1
                    ProductView.Properties.Interval.Rowset.MoveNext
                Loop
            
                ' Add the mdmIntervalId on the fly - Note the flag
                Service.Properties.Add "mdmIntervalId", "int32", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
                
                ' Set to the new property the list of interval id and label
                varID = varArrID
                varLabel = varArrLabel
                Service.Properties("mdmIntervalId").AddValidListOfValues varID, varLabel
            End If
            
    End Select
    mdm_pvb_DoToProductViewTheIntervalIDFieldAsEnumType = True
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_GetRowsetAbsolutePosition
' PARAMETERS            :
' DESCRIPTION   : Return the AbsolutePosition of the rowset. If the rowset or compatible does not support the property
'                 AbsolutePosition the function return Empty
' RETURNS                         :
Function mdm_GetRowsetAbsolutePosition(objRowSet) ' As Variant

  Dim lngPos
  
  On Error Resume Next
  Err.Clear
  lngPos = objRowSet.AbsolutePosition
  If (Err.Number) Then
      lngPos = Empty
      Err.Clear
  End If
  On Error GoTo 0
  mdm_GetRowsetAbsolutePosition = lngPos
  
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_GetRowsetAbsolutePosition
' PARAMETERS            :
' DESCRIPTION   : Return the AbsolutePosition of the rowset. Return TRUE if the rowset support the property AbsolutePosition
' RETURNS                         :
Function mdm_SetRowsetAbsolutePosition(objRowSet, lngPosition) ' As Boolean

  Dim lngPos
  
  On Error Resume Next
  Err.Clear
  objRowSet.AbsolutePosition = lngPosition
  mdm_SetRowsetAbsolutePosition = CBool(Err.Number = 0)
  Err.Clear
  
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    mdm_PopulateDictionaryWithInternalStuff
' PARAMETERS:  Dialog Type
' DESCRIPTION: Add new entries to the dictionay based on other dictionary entries.
'              These new entries are used by the MTMSIX.MSIXHandler renderer.
'              New entries are :
'                   DEFAULT_PATH_REPLACE_FOLDER
'                   CUSTOM_PATH_REPLACE_FOLDER
'              These two paths are used to localize the style sheet.
' RETURNS:  True / False
Function mdm_PopulateDictionaryWithInternalStuff(lngDialogType) ' As Boolean

  Dim strS
  Dim objDic
  
  Set objDic = mdm_GetDictionary()

  mdm_PopulateDictionaryWithInternalStuff = False
  
  mdm_GetDictionary.Add "MDM_CALL_PARENT_POPUP_WITH_NO_URL_PARAMETERS", LCase("" & Form.CallParentPopUpWithNoURLParameters) ' LCase because it will generate some javascript code
  
  'CORE-2947, ESR-3364: Removing MDM_REQUEST_QUERYSTRING and MDM_REQUEST_FORM to avoid XSS vulnerabilities; see bug/issue for more details
  'mdm_GetDictionary.Add "MDM_REQUEST_QUERYSTRING", Replace(request.QueryString(), """", "\""") '"
  'mdm_GetDictionary.Add "MDM_REQUEST_FORM", Replace(request.Form(), """", "\""")               '"

  If (IsValidObject(objDic)) Then
      
      If (objDic.Exist("DEFAULT_PATH_REPLACE")) Then
      
          strS = objDic("DEFAULT_PATH_REPLACE")  ' Get the DEFAULT_PATH_REPLACE which is a HTTP path
          strS = Server.MapPath(strS)            ' Convert the HTTP path into a folder path
          objDic.Add "DEFAULT_PATH_REPLACE_FOLDER", strS
      End If
      If (objDic.Exist("CUSTOM_PATH_REPLACE")) Then
      
          strS = objDic("CUSTOM_PATH_REPLACE")  ' Get the DEFAULT_PATH_REPLACE which is a HTTP path
          strS = Server.MapPath(strS)           ' Convert the HTTP path into a folder path
          objDic.Add "CUSTOM_PATH_REPLACE_FOLDER", strS
      End If
      
      ' - Canceld - objDic.Add "MDM_SESSION_ID", Session("mdm_SESSION_ID") ' See CheckForTimeOut()
      
      ' Decide if the dialog type will support special enter key handling
      Select Case lngDialogType
          Case MDM_STANDARD_DIALOG_TYPE
              mdm_GetDictionary.Add "MDM_CLIENT_SIDE_SUPPORT_ENTER_KEY", "true"   ' true must be is lower case it will generate so client side java-script
          Case MDM_PVB_DIALOG_TYPE
              mdm_GetDictionary.Add "MDM_CLIENT_SIDE_SUPPORT_ENTER_KEY", "true"   ' Allow enter key on pvb filter 4.01 patch
      End Select
      
      mdm_PopulateDictionaryWithInternalStuff = True
  End If
  
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : GetDefaultRenderingFlag
' PARAMETERS            :
' DESCRIPTION   : Return the rendering flag. in MDM V2 we remove by default the rendering of the service properties...
' VERSION       : MDM V2
' RETURNS                         :
Function GetDefaultRenderingFlag()

    If (Form.Version = "1.3") Then
        GetDefaultRenderingFlag = eMSIX_RENDER_FLAG_DEFAULT_VALUE
    Else
        GetDefaultRenderingFlag = eMSIX_RENDER_FLAG_DEFAULT_VALUE_VERSION_2_0
    End If
End Function

'	---------------------------------------------------------------------------------------------------------------------------------------
'	FUNCTION		:	GetDefaultRenderingFlag
'	PARAMETERS	:
'	DESCRIPTION	:	Return the rendering flag. in	MDM	V2 we	remove by	default	the	rendering	of the service properties...
'	VERSION			:	MDM	V2
'	RETURNS			:
Function LoadHTMLTemplateSourceInForm()	'	As Boolean

    Dim	strFullPathTemplateFileName, objTextFile

		'	-- Process the template	file name	--
		strFullPathTemplateFileName	=	Form.HTMLTemplateFileName
		If (Len(strFullPathTemplateFileName))	Then ' If	the	template is	defined	check	if it	exist	if no	concat the asp path	the	template name
 
				If (Not	Service.Tools.TextFile.ExistFile(strFullPathTemplateFileName)) Then

						strFullPathTemplateFileName	=	mdm_GetHTMLTemplateFullName()				'	Get	the	full path	+	file name	of the asp file
						strFullPathTemplateFileName	=	Service.Tools.TextFile.GetPathFromFileName(strFullPathTemplateFileName,	ANTI_SLASH)	'	Get	only the path
						strFullPathTemplateFileName	=	strFullPathTemplateFileName	&	ANTI_SLASH & Form.HTMLTemplateFileName ' Build the full	template file	name
				End	If
		Else
				'	Compute	the	HTML Template	file name	if not defined
				strFullPathTemplateFileName	=	request.serverVariables("PATH_TRANSLATED")
				strFullPathTemplateFileName	=	Mid(strFullPathTemplateFileName, 1,	Len(strFullPathTemplateFileName) - 3)
				strFullPathTemplateFileName	=	strFullPathTemplateFileName	&	"htm"
        
        'Set it on the form object so that if we have an issue, we know what template was used CR#13565
        Form.HTMLTemplateFileName = strFullPathTemplateFileName
		End	If
		
		Set	objTextFile	=	mdm_CreateObject(CTextFile)
		Form.HTMLTemplateSource	=	objTextFile.LoadFile(strFullPathTemplateFileName)
		LoadHTMLTemplateSourceInForm = True
		
End	Function


    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION              : ProcessParameter
    ' PARAMETERS                  :
    ' DESCRIPTION               : Return the input Parameter Form("Parameters") in a QueryString Format.
    ' RETURNS                 : Return TRUE if ok else FALSE
    Private Function mdm_ProcessParameter() ' As String
    
        Dim strParameter
        
        If (IsEmpty(Form("Parameters"))) Then
              mdm_ProcessParameter = Empty
        Else
           strParameter = Replace(Form("Parameters"), "|", "=")
           strParameter = Replace(strParameter, ";", "&")
           mdm_ProcessParameter = strParameter
        End If
    End Function



    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION              : ProcessParameter
    ' PARAMETERS                  :
    ' DESCRIPTION               : Return the input Parameter Form("Parameters") in a QueryString Format.
    ' RETURNS                 : Return TRUE if ok else FALSE
    Private Function mdm_GetFormRouteParameter() ' As String
      Dim lngPos
      If (Len(Form.RouteTo)) Then
          lngPos = InStr(Form.RouteTo, "?")
          mdm_GetFormRouteParameter = Mid(Form.RouteTo, lngPos + 1)
      End If
    End Function
        
Public Function mdm_CallEvent(strEvent, booErrorHandler)

    Dim booRetVal
    
    If (booErrorHandler) Then
        On Error Resume Next
        booRetVal = Eval(strEvent)
        If (Err.Number) Then
            EventArg.Error.Save Err
            Form_DisplayErrorMessage EventArg
            mdm_DeleteDialogFromMemory
            Service.Log Service.Tools.PreProcess(mdm_GetMDMLocalizedError("MDM_ERROR_1021"), "EVENT_NAME", strEvent, "ERR_NUMBER", EventArg.Error.Number, "ERR_DESCRIPTION", EventArg.Error.Description, "ERR_LOCALIZATION", EventArg.Error.LocalizedDescription), eLOG_ERROR
            Response.END
        End If
    Else
      booRetVal = Eval(strEvent)
    End If
    mdm_CallEvent = booRetVal
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION                      : mdm_OnExport
' PARAMETERS            :
' DESCRIPTION   :
' RETURNS                       : TRUE.
Function mdm_OnExport() ' As Boolean

    Dim strRouteTo ' As String
    
    mdm_OnExport = False
   
    If (Not mdm_CheckDialogIsMemory("mdm_OnExport", True)) Then Exit Function
    
          If (Not mdm_SetAtGlobalLevelTheServiceInstance("mdm_OnExport")) Then Exit Function ' Get from session Or Create the MSIXHandler Instance
        
    ' Call the OnCancel Event
    EventArg.Clear
    
    mdm_OnExport = mdm_CallEvent("Form_Export(EventArg)", Form.ErrorHandler)
    
    '
    ' The dialogm life continue we do not delete it...
    '
End Function


PUBLIC FUNCTION mdm_TerminateDialogAndExecuteDialog(strURL)

    mdm_OnTerminate
    mdm_Terminate
    Response.ReDirect strURL
    mdm_TerminateDialogAndExecuteDialog = TRUE
END FUNCTION

PUBLIC FUNCTION mdm_CloseDialogAndExecuteDialog(strURL)

    mdm_Terminate
    Response.ReDirect strURL
    mdm_TerminateDialogAndExecuteDialog = TRUE
END FUNCTION

PUBLIC FUNCTION mdm_TerminateDialog()

    mdm_OnTerminate
    mdm_Terminate
    mdm_TerminateDialog = TRUE
END FUNCTION

PUBLIC FUNCTION mdm_CallFunctionIfExist(ByVal strFunction, ByRef varRetVal)

    On Error Resume Next
    varRetVal               = Eval(strFunction)
    mdm_CallFunctionIfExist = CBool(Err.Number = 0)
    Err.Clear
END FUNCTION

PUBLIC FUNCTION mdm_ClearFilter()
   If (Service.Properties.Exist("mdmPVBFilter")) Then Service.Properties("mdmPVBFilter").Value = ""
   If (Service.Properties.Exist("mdmPVBFilter2")) Then Service.Properties("mdmPVBFilter2").Value = ""
   If (Service.Properties.Exist("mdmPVBFilterOperator")) Then Service.Properties("mdmPVBFilterOperator").Value = ""
   If (Service.Properties.Exist("mdmPVBFilterColumns")) Then Service.Properties("mdmPVBFilterColumns").Value = ""         
   mdm_GetDictionary().Add "MDM_FILTER_OPERATOR_SAVE", ""  

   ' Reset the filter only if we are not saving it for this dialog or we have an error
   If Form.Grid.FilterPropertySave <> True Then   
     Form.Grid.Filter = MDM_ACTION_PVB_FILTER_RESET         
   End If  
END FUNCTION

PUBLIC FUNCTION mdm_SetFilterObjectFromCurrentFilterSettings(objRowsetfilter)
  
  mdm_SetFilterObjectFromCurrentFilterSettings = FALSE
  
  Dim strTmpFilter
  Dim booFilterWasThere
  Dim strTmpFilter2
  Dim strErrorMessage, enumFilterOperator, booApplyFilter

  strTmpFilter = Trim(Form.Grid.Filter)

        If (Len(strTmpFilter) And (strTmpFilter <> MDM_ACTION_PVB_FILTER_RESET)) Then

            If Form.Grid.FilterMode = MDM_FILTER_MULTI_COLUMN_MODE_ON Then ' MDM v2.2 - Support Filter based on a combobox list of property we are here setting the hard coded property based on the combobox selected value                                                                                   '
            
                If Len(mdm_UIValue("mdmPVBFilterColumns")) Then 
                  mdm_SetFilterPropertyAndType
            '       Set Form.Grid.FilterProperty = ProductView.Properties(mdm_UIValue("mdmPVBFilterColumns")) ' There is case where we not going to set the property but we do not want to lose the previous values : case filter + goto to next page
            '       ProductView.Properties("mdmPVBFilterColumns").Value = mdm_UIValue("mdmPVBFilterColumns")
                End If
            End If

            If (strTmpFilter <> "*") Then ' Remove this case which make a crash
                                   
                 enumFilterOperator  = GetRowsetOperator(Form.Grid.FilterOperator,UCase(Form.Grid.FilterProperty.PropertyType))
                 
                 'Set objRowsetfilter = Service.Properties.Rowset.Filter
                 booFilterWasThere   = IsValidObject(objRowsetfilter)

                 If (Not booFilterWasThere) Then
								 			Set objRowsetfilter = mdm_CreateObject(MTSQLRowsetFilter)
											objRowsetfilter.Clear
								 End If

								 Select Case UCase(Form.Grid.FilterProperty.PropertyType)
								 
										Case MSIXDEF_TYPE_STRING
                    
                       If(Form.Grid.FilterOperator="LIKE")Or(Form.Grid.FilterOperator="")Then 
                       
      									   strTmpFilter = Replace(strTmpFilter, "*", "%")
    	                     If (InStr(strTmpFilter, "%") = 0) Then strTmpFilter = "%" & strTmpFilter & "%"
                       End IF

    	                'fix for CORE-4955 MetraControl - can not search all intervals by setting 'status <> Hard Closed
      					'for IntervalManagement.List.asp page and filter on column "Status"
	                    'In t_usage_interval.tx_interval_status saved as a single character ("O" and "B" for open, "H" for hard closed)

                        If Form.Grid.FilterPropertySaveValue = "Status~STRING" Then
	                       Select Case Form.Grid.Filter
	                        Case "Open"
	                          Dim objRowsetfilter1
	                          Dim objRowsetfilter2
	
	                          Set objRowsetfilter1 = mdm_CreateObject(MTSQLRowsetFilter)
	                          Set objRowsetfilter2 = mdm_CreateObject(MTSQLRowsetFilter)
	
	                          objRowsetfilter1.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, Form.Grid.FilterProperty.Name) & Form.Grid.FilterProperty.Name, CLNG(enumFilterOperator) , "O"
	                          objRowsetfilter2.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, Form.Grid.FilterProperty.Name) & Form.Grid.FilterProperty.Name, CLNG(enumFilterOperator) , "B"
	
	                          If (Form.Grid.FilterOperator="NOT_EQUAL") Then
	                            Set objRowsetfilter = objRowsetfilter2.CreateMergedFilter(objRowsetfilter1, 0)
	                          Else
	                            Set objRowsetfilter = objRowsetfilter2.CreateMergedFilter(objRowsetfilter1, 1)
	                          End If
	
	                        Case "Hard Closed"
	                          objRowsetfilter.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, Form.Grid.FilterProperty.Name) & Form.Grid.FilterProperty.Name, CLNG(enumFilterOperator) , "H"
	                        Case Else
	                          objRowsetfilter.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, Form.Grid.FilterProperty.Name) & Form.Grid.FilterProperty.Name, CLNG(enumFilterOperator) , strTmpFilter
	                       End Select
                         'ESR-5409 Cannot filter on Role names 
                       ElseIf Form.Grid.FilterProperty.Caption = "Role Name and Description" Then
                          Dim objRowsetfilterName, objRowsetfilterDesc
                          Set objRowsetfilterName = mdm_CreateObject(MTSQLRowsetFilter)
                          Set objRowsetfilterDesc = mdm_CreateObject(MTSQLRowsetFilter)
                         
                          objRowsetfilterName.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, "tx_name") & "tx_name" , CLNG(enumFilterOperator) , strTmpFilter
                          objRowsetfilterDesc.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, "tx_desc") & "tx_desc" ,  CLNG(enumFilterOperator) , strTmpFilter
                          Set objRowsetfilter = objRowsetfilterDesc.CreateMergedFilter( objRowsetfilterName, 1)
                         
	                     Else
							objRowsetfilter.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, Form.Grid.FilterProperty.Name) & Form.Grid.FilterProperty.Name, CLNG(enumFilterOperator) , strTmpFilter
	                     End IF
										 
 										Case MSIXDEF_TYPE_TIMESTAMP

                        If IsDate(strTmpFilter) Then
                        
                            If enumFilterOperator = MT_OPERATOR_TYPE_BETWEEN Then
                                ' Derek and Fred have conclude that there is a ADO Filter bug on >= operator
                                ' which alway execute a >. There for to simulate the right behavior we remove one second.
                                'strTmpFilter = DATEADD("s",-1,CDATE(strTmpFilter))
                                objRowsetfilter.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, Form.Grid.FilterProperty.Name) & Form.Grid.FilterProperty.Name, MT_OPERATOR_TYPE_GREATER_EQUAL, CDate(strTmpFilter)
                                
                                strTmpFilter2 = Trim(Form.Grid.Filter2)
                                If CBool(Len(strTmpFilter2)) Then
                                
                                    If IsDate(strTmpFilter2) Then                                
                                    
                                        objRowsetfilter.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, Form.Grid.FilterProperty.Name) & Form.Grid.FilterProperty.Name, MT_OPERATOR_TYPE_LESS_EQUAL, CDate(strTmpFilter2)
                                    Else                                        
                                        mdm_SaveErrorInSession 1024 , mdm_GetMDMLocalizedError("MDM_ERROR_1024")
                                    End If                                      
                                End If
                            Else
                                ' Derek and Fred have conclude that there is a ADO Filter bug on >= operator
                                ' which alway execute a >. There for to simulate the right behavior we remove one second.
                                If enumFilterOperator=MT_OPERATOR_TYPE_GREATER_EQUAL Then strTmpFilter = DATEADD("s",-1,CDATE(strTmpFilter))
                                
                                objRowsetfilter.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, Form.Grid.FilterProperty.Name) & Form.Grid.FilterProperty.Name, CLNG(enumFilterOperator), CDate(strTmpFilter)
                            End If
                        Else
                            mdm_SaveErrorInSession 1024 , mdm_GetMDMLocalizedError("MDM_ERROR_1024")
                        End If
                        
                 		Case Else                    

                        If IsNumeric(strTmpFilter) Then 
                            'Type of the value is relevant to the Rowset filter object
                             Select Case UCase(Form.Grid.FilterProperty.PropertyType)
								               Case MSIXDEF_TYPE_INT32
                                   strTmpFilter = Clng(strTmpFilter)
								               Case MSIXDEF_TYPE_DOUBLE
                                   strTmpFilter = CDbl(strTmpFilter)
								               Case MSIXDEF_TYPE_DECIMAL
                                   strTmpFilter = CDec(strTmpFilter)
                             End Select
                                                        
                            objRowsetfilter.Add MTSQLRowset_GetColumnPreFix(Service.Properties.Rowset, Form.Grid.FilterProperty.Name) & Form.Grid.FilterProperty.Name, CLNG(enumFilterOperator) , strTmpFilter
                        Else
                            mdm_SaveErrorInSession 1024 , mdm_GetMDMLocalizedError("MDM_ERROR_1024")
                            booApplyFilter = FALSE
                        End If                        
                 End Select
               End If
             End If
             
  mdm_SetFilterObjectFromCurrentFilterSettings = TRUE

END FUNCTION

PRIVATE FUNCTION mdm_SetFilterPropertyAndType
  If Len(mdm_UIValue("mdmPVBFilterColumns")) Then
    'See if we can get the type from the value of mdmPVBFilterColumns
    dim iPos
    iPos = InStr(mdm_UIValue("mdmPVBFilterColumns"),"~")
    if iPos>0 then
      dim sName,sTypeInfo,sEnumType,sEnumSpace
      sName = Left(mdm_UIValue("mdmPVBFilterColumns"),iPos-1)
      sTypeInfo = Mid(mdm_UIValue("mdmPVBFilterColumns"),iPos+1)

      dim oProperty
      set oProperty = CreateObject("MTMSIX.MSIXProperty")
      oProperty.Name = sName
      'Is this an enum, then we need more information
      iPos = InStr(sTypeInfo,"~")
      if iPos>0 then
        dim arrEnumInfo
        arrEnumInfo = Split(sTypeInfo, "~")
        sTypeInfo = arrEnumInfo(0)
        sEnumType = arrEnumInfo(1)
        sEnumSpace = arrEnumInfo(2)
        oProperty.SetPropertyType sTypeInfo, sEnumType, sEnumSpace
      else
        oProperty.SetPropertyType sTypeInfo
      end if
      
      Set Form.Grid.FilterProperty = oProperty
    else
      Set Form.Grid.FilterProperty = ProductView.Properties(mdm_UIValue("mdmPVBFilterColumns")) ' There is case where we not going to set the property but we do not want to lose the previous values : case filter + goto to next page
    end if
    
    'If we have the productview.properties for the page already, then we call this to save/preserve the users selection for the field the next time we display the page
    if IsValidObject(ProductView.Properties) then
      ProductView.Properties("mdmPVBFilterColumns").Value = mdm_UIValue("mdmPVBFilterColumns")
    end if
    
  End If
END FUNCTION
%>
