<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
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
' NAME		        : MetraTech Dialog Manager - VBScript Library
' VERSION	        : 1.0
' CREATION_DATE     : 08/xx/2000
' AUTHOR	        : F.Torres.
' DESCRIPTION	    : 
' ----------------------------------------------------------------------------------------------------------------------------------------

Public const gDialogCollectorOn = FALSE
Public const gMaxPageLive = 5
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION: mdm_DialogCollectorAdd
' PARAMETERS: DialogID, KeepAlive
' DESCRIPTION: Called before the Form_Initialize event.  It
'              adds the current dialog to the list of dialogs to be 
'              collected in the mdm_DialogCollector
' RETURNS: True if the dialog is added to the list
PRIVATE FUNCTION mdm_DialogCollectorAdd(dialogID, keepAlive)

  If Not gDialogCollectorOn Then
    mdm_DialogCollectorAdd = True
    Exit Function
  End If
  
  mdm_DialogCollectorAdd = False
  
  If Not keepAlive Then
    Dim dc
    
    If IsEmpty(Session("MDM_DIALOG_COLLECTOR")) Then
       Set dc = Server.CreateObject(DICTIONARY_PROG_ID)
    Else
       Set dc = Session("MDM_DIALOG_COLLECTOR")
    End If
    
    If dc.Exist(dialogID) Then 
      dc(dialogID).Value = 1 
      Exit Function  
    End If
    
    Call dc.Add(dialogID, 1)

    Set Session("MDM_DIALOG_COLLECTOR") = dc
    mdm_DialogCollectorAdd = True 
  End If  

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION: mdm_DialogCollector (AKA: Garbage Collector)
' PARAMETERS: 
' DESCRIPTION: Go through the list of dialogs stored
'              in Session("MDM_DIALOG_COLLECTOR") and free them.
' RETURNS: True if the dialog is added to the list
PRIVATE FUNCTION mdm_DialogCollector()

  If Not gDialogCollectorOn Then
    mdm_DialogCollector = True
    Exit Function
  End If
    
  mdm_DialogCollector = False
  
    If Not IsEmpty(Session("MDM_DIALOG_COLLECTOR")) Then
     
      Dim dc, val
      Set dc = Session("MDM_DIALOG_COLLECTOR")
        
      If dc.Count > 0 Then

        If dc.Exist(GetDialogId()) Then 
          dc(GetDialogId()).Value = 0 
        End If

        For Each val in dc

            If CLng(val.Value) > gMaxPageLive Then
              If Not IsEmpty(Session(mdm_FORM_SESSION_NAME & val.Name)) Then
                Set Session(mdm_FORM_SESSION_NAME & val.Name) = Nothing
                Session(mdm_FORM_SESSION_NAME & val.Name) = Empty
              End If
                  
              If Not IsEmpty(Session(mdm_DIALOG_SESSION_NAME & val.Name)) Then
                Set Session(mdm_DIALOG_SESSION_NAME & val.Name) = Nothing
                Session(mdm_DIALOG_SESSION_NAME & val.Name) = Empty
              End If
              dc.Remove(val.Name)
            Else
              val.Value = CLng(val.Value) + 1 
            End If
            
        Next
        
      End If  

      mdm_DialogCollector = True
    End If  

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION: mdm_DumpDialogCollector
' PARAMETERS: 
' DESCRIPTION: Used by MDMMonitor to display the dialogs
'              that are in the list to be collected (freed).
' RETURNS: 
PRIVATE FUNCTION mdm_DumpDialogCollector()

  If Not gDialogCollectorOn Then
    mdm_DumpDialogCollector = True
    Exit Function
  End If

   If Not IsEmpty(Session("MDM_DIALOG_COLLECTOR")) Then
     
      Dim dc, val
      Set dc = Session("MDM_DIALOG_COLLECTOR")
        
      If dc.Count > 0 Then
        Response.Write "<TABLE BORDER=0 WIDTH='100%' BGCOLOR='white' CELLPADDING='0' CELLSPACING='0'>"  & vbNewLine
        Response.Write "<TR>"  & vbNewLine
        Response.Write "         <TD Class='mdmDebuggerCaption'>Dialog Collector</TD><td Class='mdmDebuggerCaption'>Age</td>" & vbNewLine
        Response.Write "</TR>"  & vbNewLine      
        For Each val in dc
            Response.Write "<TR>" & vbNewLine
            Response.Write "<TD Class='mdmDebuggerCell' Align='Right'>" & val.Name & "</TD>"
            Response.Write "<TD Class='mdmDebuggerCell' Align='Right'>" & val.Value & "</TD>"
            Response.Write "</TR>" & vbNewLine
        Next
        Response.Write "</TABLE>" & vbNewLine
      End If  
   End If   
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 	        : mdm_SetAtGlobalLevelTheServiceInstance
' PARAMETERS	    : 
' DESCRIPTION 	    : Called at the beginning of each MDM Internal Event
'                     to Create/Retreive the current instance of the MSIXHandler
'                     The global variables Service and ProductView are set.
' RETURNS	        :
PRIVATE FUNCTION mdm_SetAtGlobalLevelTheServiceInstance(strLogMessage) ' As Boolean
    
    mdm_SetAtGlobalLevelTheServiceInstance = FALSE ' Default Return Value
    
	' Get the COM Instance object    
    Set Service	= mdm_GetServiceInstance()
    If(Not IsValidObject(Service))Then
            
        mdm_DisplayinternalErrorMessage mdm_GetMDMLocalizedError("MDM_ERROR_1001")
        Exit Function        
    Else
        Set ProductView                        = Service        
        Set COMObject                          = Service
        mdm_SetAtGlobalLevelTheServiceInstance  = TRUE
    End If
    'mdm_LogWarning "[MDM] ASPFunction=" & strLogMessage & " Service=" & Service.name    
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 	        : mdm_GetErrorString
' PARAMETERS	    : 
' DESCRIPTION 	    : Return a string with the VB Run Time Error. Number, Description and source!
'                     And clear the error!
' RETURNS	        :
PRIVATE FUNCTION mdm_GetErrorString() ' As String

 
	mdm_GetErrorString = CStr(err.Number) & " " & err.Description & " " & err.Source
	Err.Clear
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : 	mdm_GetCurrentFullURL
' PARAMETERS    : 
' DESCRIPTION 	: 	Return the current URL with the ASP Parameters. But Erase/Rename the OK.x OK.y
'  					CANCEL.x and CANCEL.y
' RETURNS	    :   The URL string.
PRIVATE FUNCTION mdm_GetCurrentFullURL() ' As String

	Dim strS	' As String

	strS			=	mdm_GetCurrentAspCall()
	strS			=	Replace(strS,"OK.X","_K.X"          ,1,-1,vbTextCompare)
	strS			=	Replace(strS,"CANCEL.X","_ANCEL.X"  ,1,-1,vbTextCompare)

	mdm_GetCurrentFullURL   =   strS
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 	        : mdm_UserClickedOn()
' PARAMETERS	    : strAction 
' DESCRIPTION 	    : Return TRUE if an Button was clicked and return the name of
'	 	              of the button. Does not process OK and CANCEL button.
' RETURNS	        : TRUE if button was clicked else FALSE
PRIVATE FUNCTION mdm_UserClickedOn(strAction) ' As Boolean
	Dim itm	
	Dim strItm
  Dim objUIItems          ' AS CVariables
  

  mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
  
	For Each itm In objUIItems
  		strItm = UCase(itm.Name)
  		If(Right(strItm,2) = ".X")Then
  				
    			If( (UCase(strItm)<>"OK.X")And(UCase(strItm)<>"CANCEL.X")And(UCase(strItm)<>"_K.X")And(UCase(strItm)<>"_ANCEL.X") )Then
      
      				strAction 		    = Mid(Itm.Name,1,Len(Itm.Name)-2)
      				mdm_UserClickedOn	= TRUE
      				Exit Function
    			End If
  		End If
	Next
	mdm_UserClickedOn = FALSE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 	        : mdm_PopulateCOMInstanceWithQueryString
' PARAMETERS	      : 
' DESCRIPTION 	    : Update the COM Instance with QueryString Parameters values. If an type mismatch/string too long error 
'		                  occur we contine the population so in but I added a mechanism that return only the first error!
'                     Support the case the check box set to false. In that case the query string contains nothing about.
'                     But the rendere add for each check box an hidden tag giving the name of the check box.
'                     Based on the name we can determine the checkbox value;
'
'                     This function does not read the query string or form collection but has the parameter objUIItems.
'
' RETURNS	          : TRUE if no error occur
PRIVATE FUNCTION mdm_PopulateCOMInstanceWithQueryString(objUIItems,EventArg,objServiceInstance, booRaiseError) ' As Boolean

	  Dim objVar		          ' As String
    Dim booErrorFound       ' As Boolean    
    Dim strName
    Dim objGrid
    
	  mdm_PopulateCOMInstanceWithQueryString	= TRUE ' Default return value
    booErrorFound                           = FALSE
    
    ' When mdmRefreshForClose=TRUE, the dialog has to refresh it self, but just to run the java script to close
    ' the windows so here just exiting...There is no update to perform...
    If (UCase(Request.QueryString("mdmRefreshForClose")) = "TRUE") Then Exit Function
    
    
    For Each objVar In objUIItems ' Loop only to process checkbox
    
        If(Left(UCase(objVar.Name),Len(MDM_CHECKBOX_PREFIX))=MDM_CHECKBOX_PREFIX)Then ' Test if we have a check box based on the hidden tag
                                                                                      ' Associate with every CheckBox by the renderer
                                                                                      
            strName = Mid(objVar.Name,Len(MDM_CHECKBOX_PREFIX)+1) ' Extract the name of the check box!
            
            ' Test if the checkbox entry is in the collection (QueryString/Form) if yes this means the check box is TRUE
            ' if no the check box is false...
            if not objServiceInstance.Properties.Item(CStr(strName)) Is Nothing Then
              if objServiceInstance.Properties.Item(CStr(strName)).Enabled Then 
                objServiceInstance.Properties.Item(CStr(strName)).Value(CBool(booRaiseError)) = objUIItems.Exist(strName)
              end if
            end if
        End If
    Next
    
    On Error Resume Next
    
	  For Each objVar In objUIItems
		
		  If(objServiceInstance.Properties.Exist(objVar.Name))Then
        
            ' Do not trace crypted or password property
            If (Mid(objVar.Name,1,Len(objVar.Name))="_")Or(InStr(UCASE(objVar.Name),"PASSWORD")) Then
                objServiceInstance.log "SetProperty " & CStr(objVar.Name) & "=blur" 
            Else            
                objServiceInstance.log "SetProperty " & CStr(objVar.Name) & "=" & objUIItems(objVar.Name)
            End If
            
            ' If a date msix property is set to empty string, we will set it to empty, to avoid type mismatch
            If(objServiceInstance.Properties.Item(CStr(objVar.Name)).PropertyType=MSIXDEF_TYPE_TIMESTAMP OR objServiceInstance.Properties.Item(CStr(objVar.Name)).PropertyType=MSIXDEF_TYPE_BOOLEAN )Then
            
                 If(objUIItems(objVar.Name).Value="")Then
                
                    objUIItems(objVar.Name).Value = Empty
                End If            
            End If   
			
            If(objServiceInstance.Properties.Item(CStr(objVar.Name)).PropertyType=MSIXDEF_TYPE_ENUM) Then
	
	                If(objUIItems(objVar.Name).Value="")Then
	
	                   objUIItems(objVar.Name).Value = Empty
 	               End If
 	           End If
 	           If objServiceInstance.Properties.Item(CStr(objVar.Name)).PropertyType = MSIXDEF_TYPE_DECIMAL OR objServiceInstance.Properties.Item(CStr(objVar.Name)).PropertyType = MSIXDEF_TYPE_DOUBLE OR objServiceInstance.Properties.Item(CStr(objVar.Name)).PropertyType = MSIXDEF_TYPE_FLOAT Then
 	              If(objUIItems(objVar.Name).Value="")Then
 	
 	                 objUIItems(objVar.Name).Value = Empty
 	               End If
 	           End If
            If objServiceInstance.Properties.Item(CStr(objVar.Name)).PropertyType = MSIXDEF_TYPE_DECIMAL OR objServiceInstance.Properties.Item(CStr(objVar.Name)).PropertyType = MSIXDEF_TYPE_DOUBLE OR objServiceInstance.Properties.Item(CStr(objVar.Name)).PropertyType = MSIXDEF_TYPE_FLOAT Then
              objServiceInstance.Properties.Item(CStr(objVar.Name)).Value(CBool(booRaiseError)) = Replace(objUIItems(objVar.Name),mdm_GetDictionary().GetValue("DECIMAL_SEPARATOR"),".")
            ElseIf objServiceInstance.Properties.Item(CStr(objVar.Name)).PropertyType = MSIXDEF_TYPE_TIMESTAMP Then
            
                objServiceInstance.Properties.Item(CStr(objVar.Name)).Value(CBool(booRaiseError)) = CDate(mdm_ApplicationValidDate(objUIItems(objVar.Name).value))
            Else
    			      objServiceInstance.Properties.Item(CStr(objVar.Name)).Value(CBool(booRaiseError)) = objUIItems(objVar.Name)
            End If
        
            ' Process only the first error            
			      If(Err.Number)And(Not booErrorFound)Then
            
                EventArg.Error.Number                           = objServiceInstance.Tools.MakeItUserVisibleMTCOMError(Err.Number)
                
                EventArg.Error.Description                      = PreProcess(Err.Description,Array("PROPERTY",objServiceInstance.Properties.Item(CStr(objVar.Name)).Caption))
                EventArg.Error.Source                           = TypeName(objServiceInstance) & " " & objServiceInstance.Name
                EventArg.Error.PropertyName                     = objVar.Name
				        mdm_PopulateCOMInstanceWithQueryString	        = FALSE
                booErrorFound                                   = TRUE
                Err.Clear
                objServiceInstance.log "[ERROR]mdm_PopulateCOMInstanceWithQueryString=" &  EventArg.Error.ToString()
			      End If
            Err.Clear
		    End If
	  Next
    
    On Error Goto 0
    
  ' MDM V2
  ' Support dialog based on COM Object like an MTPriceAbleItem
    If (IsValidObject(objServiceInstance.Instance))Then ' We have an COM object associated with the dialog
        
        ' When mdmRefreshFromPopUpDialog=TRUE this means the dialog was asked to refresh by one pop up
        ' dialog, it called him self. In that case the query string contains no name=value and plus
        ' The COMObject.Instance was correctly updated by the pop up dialog and the current COMObject.Properties
        ' are not. So we basically doing the opposite :
        ' Summary :
        ' Standard Case : mdmRefreshFromPopUpDialog=FALSE
        '                 we copy the COMObject.Properties(MSXIHandler Properties) values to COMObject.Instance.MTProperties
        ' Other Case    : mdmRefreshFromPopUpDialog=TRUE
        '                 we copy the COMObject.Instance.MTProperties values to COMObject.Properties(MSXIHandler Properties) 
        
        If (UCase(Request.QueryString("mdmRefreshFromPopUpDialog"))= "TRUE") Then
        
            COMObject.Properties.PopulateFromCOMObject COMObject.Instance
        Else
        
            objServiceInstance.Properties.PopulateCOMObject objServiceInstance.Instance ' Populate the service object with the data of the COM Object            
            ' Grid set with MTProperty
            ' 
            ' If we have a Extended Property Grid The code above has populated from the
            ' Query string to COMObject.Instance. Nevertheless we need to force the extended
            ' property grid to refresh.
            If(Form.GridsDefined())Then ' If we have grid
    
                For Each objGrid In Form.Grids 
                
                    If(objGrid.IsMTPropertiesMode())Then
                    
                        Set objGrid.MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties
                    End If
                Next
            End If
      End If
    End If
	  On Error Goto 0
END FUNCTION

PUBLIC FUNCTION mdm_ApplicationValidDate(varDate)

  mdm_ApplicationValidDate = varDate
END FUNCTION
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    : 
' DESCRIPTION   :
' RETURNS       :
PRIVATE FUNCTION mdm_UserClickedOnOk() ' As Boolean
    If(CBool(Len(mdm_UIValue("OK.x"))) OR mdm_UIValue("mdmAction")=MDM_ACTION_ENTER_KEY) Then
        	mdm_UserClickedOnOk = TRUE
    Else
          mdm_UserClickedOnOk = FALSE
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    : 
' DESCRIPTION   :
' RETURNS       :
PRIVATE FUNCTION mdm_DialogNeedARefresh() ' As Boolean
	  mdm_DialogNeedARefresh = (UCase(CStr(mdm_UIValue("mdmAction")))=MDM_ACTION_REFRESH)
END FUNCTION


PRIVATE FUNCTION mdm_DialogNeedARefreshFromClickOnObject() ' As Boolean
	  mdm_DialogNeedARefreshFromClickOnObject = (UCase(CStr(mdm_UIValue("mdmAction")))=MDM_ACTION_REFRESH_FROM_CLICK_FROM_OBJECT)
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    : 
' DESCRIPTION   :
' RETURNS       :
PRIVATE FUNCTION mdm_UserClickOnHelp() ' As Boolean

	mdm_UserClickOnHelp = UCase(CStr(mdm_UIValue("mdmAction")))="HELP"
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    : 
' DESCRIPTION   :
' RETURNS       :
PRIVATE FUNCTION mdm_DialogNeedPopAndGo() ' As Boolean

	mdm_DialogNeedPopAndGo = UCase(CStr(mdm_UIValue("mdmAction")))="POPANDGO"
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    : 
' DESCRIPTION   :
' RETURNS       :
PRIVATE FUNCTION mdm_UserClickedOnCancel() ' As Boolean

	mdm_UserClickedOnCancel = CBool(mdm_UIValue("CANCEL.x")<>"") OR mdm_UIValue("mdmAction")=MDM_ACTION_ESCAPE_KEY
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 	      : IIF
' PARAMETERS	: 
' DESCRIPTION 	: Implement the Visual Basic IIF
' RETURNS	      :
FUNCTION iif(booExp,varRetValueTrue,varRetValueFalse) ' As Variant
	If(booExp)Then
		iif = varRetValueTrue
	Else
		iif = varRetValueFalse
	End If	
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_GetDialogPhysicalPath
' PARAMETERS	: 
' DESCRIPTION : Return the hard drive path of the current Form. The template and the asp are in this Form.
' RETURNS		  : 
PRIVATE FUNCTION mdm_GetDialogPhysicalPath() ' As Boolean

    mdm_GetDialogPhysicalPath = Service.tools.TextFile.GetPathFromFileName(request.serverVariables("PATH_TRANSLATED"), ANTI_SLASH)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: IsValidObject
' PARAMETERS	: obj
' DESCRIPTION : Return if obj is an object and not nothing.
' RETURNS		  : TRUE / FALSE  
FUNCTION IsValidObject(obj) ' As Boolean
    
    If(IsObject(obj))Then
    
        IsValidObject = Not(Obj Is Nothing)
    Else
        IsValidObject = FALSE        
    End If        
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: GetDialogId
' PARAMETERS	: 
' DESCRIPTION : Gets the dialog id for the page
' RETURNS			: dialog id as string
FUNCTION GetDialogId() ' As String
  
  GetDialogId	=	request.serverVariables("PATH_TRANSLATED") & mdm_DialogID   
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_SetDialogID
' PARAMETERS	: uniqueID
' DESCRIPTION : Specifies a unique id that should be used to create a unique form for a shared dialog.
'               The unique key is then passed in a hidden form variable (MDM_FORM_UNIQUE_KEY) that is populated via the dictionary.   
' RETURNS			: TRUE / FALSE 
PUBLIC FUNCTION mdm_SetDialogID(uniqueID)

  mdm_DialogID = mdm_UIValueDefault("mdmFormUniqueKey", uniqueID)
  If NOT IsValidObject(mdm_GetDictionary()) Then
    FrameWork.Initialize TRUE
    FrameWork.Language = mdm_GetSessionVariable("mdm_APP_LANGUAGE")
    FrameWork.LoadDictionary
  End If
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Added output encoding for protect from URL injection
  'mdm_GetDictionary().Add "MDM_FORM_UNIQUE_KEY", mdm_DialogID
  mdm_GetDictionary().Add "MDM_FORM_UNIQUE_KEY", SafeForUrl(mdm_DialogID)
  
  mdm_SetDialogID = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION : 
' RETURNS			:
PRIVATE FUNCTION mdm_GetSessionVariable(strVarName) ' As String

    Dim strVbError
    Dim strValue

    strValue = Session(strVarName)
    If(IsEmpty(strValue))Then
        strVbError = Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1006"),"[NAME]",strVarName)
        Err.Raise 1006,"mdm.asp",strVbError
    Else
        mdm_GetSessionVariable = strValue
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		: 
' RETURNS			:
PRIVATE FUNCTION mdm_GetDictionaryInstance(objServiceInstance,objDictionary) ' As Boolean

    mdm_GetDictionaryInstance = FALSE ' Default return value
    
    On Error Resume Next
    Err.Clear 
    Set objDictionary = Session("mdm_LOCALIZATION_DICTIONARY")
    If(Err.Number)Then
        mdm_LogWarningWithService objServiceInstance, mdm_GetMDMLocalizedError("MDM_ERROR_1002") & "VB Error=" & mdm_GetErrorString()
        Err.Clear
    Else
        On Error Goto 0
        If(IsValidObject(objDictionary))Then
            mdm_GetDictionaryInstance = TRUE
            mdm_LogWarningWithService objServiceInstance, mdm_GetMDMLocalizedError("MDM_ERROR_1003")
        Else
            mdm_LogWarningWithService objServiceInstance, mdm_GetMDMLocalizedError("MDM_ERROR_1002")
        End If
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		: 
' RETURNS			:
PRIVATE FUNCTION mdm_LogWarning(strMessage) ' As Boolean

    mdm_LogWarning = mdm_LogWarningWithService(Service,strMessage)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		: 
' RETURNS			:
PRIVATE FUNCTION mdm_LogWarningWithService(objService,strMessage) ' As Boolean

    If(objService.Configuration.LogWarning)Then
        objService.Log strMessage,eLOG_WARNING
        mdm_LogWarningWithService = TRUE
    Else
        mdm_LogWarningWithService = FALSE
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_LogError
' PARAMETERS		:
' DESCRIPTION 	: I need to allocate my own object because I am not sure the service object is allocated
' RETURNS			  :
PRIVATE FUNCTION mdm_LogError(strMessage) ' As Boolean

    Dim objTmpService
    
    Set objTmpService = mdm_CreateObject(MSIXHandler)
    objTmpService.Log strMessage,eLOG_ERROR
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		: 
' RETURNS			:
PRIVATE FUNCTION mdm_GetPropertyCaptionFromError() ' As Boolean

    If(Len(EventArg.Error.PropertyName))Then
    
        mdm_GetPropertyCaptionFromError = EventArg.Error.PropertyCaption()
    End If
END FUNCTION    

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_GetDaysOfTheMonthArray
' PARAMETERS		:
' DESCRIPTION 		: Return a variant array contains the value 1 to 31 so this array can be
'                     passed as a parameter to the method MTService.ServiceProperties.AddValidListOfValues().
' RETURNS			: A Variant contains array of variant initialized with long values
PRIVATE FUNCTION mdm_GetDaysOfTheMonthArray() ' As Variant

    Dim varArrayDayOfMonth(30) ' 0..30 = 31 values
    Dim i
    Dim v
    For i=1 to 31
        varArrayDayOfMonth(i-1) = CLng(i)
    Next
    v = varArrayDayOfMonth
    mdm_GetDaysOfTheMonthArray = v
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_GetMDMFolder
' PARAMETERS		:
' DESCRIPTION 		: 
' RETURNS			:
PRIVATE FUNCTION mdm_GetMDMFolder() ' As String

    mdm_GetMDMFolder = Server.MapPath("/mdm")
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		: 
' RETURNS			:
PRIVATE FUNCTION mdm_SaveDialogCOMInstance(objServiceInstance) ' As Boolean

  If(objServiceInstance Is Nothing)Then
      
      ' Free the session variable here
      mdm_LogWarningWithService Session(mdm_DIALOG_SESSION_NAME & GetDialogId()), Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1004"),"[NAME]",GetDialogId())
      Set Session(mdm_DIALOG_SESSION_NAME & GetDialogId())	=	Nothing ' Free the Service instance
  Else
      ' Set the session variable here
      mdm_LogWarningWithService objServiceInstance, Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1005"),"[NAME]",GetDialogId())
      Set Session(mdm_DIALOG_SESSION_NAME & GetDialogId())	=	objServiceInstance
  End If	
	mdm_SaveDialogCOMInstance = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	: 
' RETURNS			  :
PRIVATE FUNCTION mdm_GetServiceInstance() ' As Object
	Dim obj
    
	On Error Resume Next
	Set obj = Session(mdm_DIALOG_SESSION_NAME & GetDialogId())
	If(Err.Number)or(Not IsValidObject(obj))Then
            
    On Error Goto 0
		Set obj = mdm_CreateStandardServiceInstance()
	Else
    On Error Goto 0
    obj.log "MDM Get Service From Cache DialogId="  & GetDialogId()
	End If
    
  ' Link the event to the service
  EventArg.Initialize
   
  Set mdm_GetServiceInstance  = obj
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_GetDictionaryValue
' PARAMETERS		:
' DESCRIPTION 	: Find if a service is in memory and if not print an error and stop the script! This function allow
'                 to support the back button...
' RETURNS			  :
PUBLIC FUNCTION mdm_GetDictionaryValue(strEntryName,varDefaultValue) ' As Object
    Dim objDic
    Set objDic  = mdm_GetDictionary()

    If(IsValidObject(objDic))Then
        mdm_GetDictionaryValue  = objDic.GetValue(strEntryName,varDefaultValue)
    Else
        mdm_GetDictionaryValue  = varDefaultValue
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_CheckDialogIsMemory
' PARAMETERS		:
' DESCRIPTION 	: Find if a service is in memory and if not print an error and stop the script! This function allow
'                 to support the back button...
' RETURNS			  :
PRIVATE FUNCTION mdm_CheckDialogIsMemory(strEvent, booTraceAndStop) ' As Object

    Dim strErrorMessage
    
    If( mdm_IsServiceInstanceInMemory())Then
        
        mdm_CheckDialogIsMemory = TRUE
    Else
        If(booTraceAndStop)Then
            strErrorMessage = mdm_GetMDMLocalizedError("MDM_ERROR_1016")
            strErrorMessage = Replace(mdm_GetDictionaryValue("MDM_BACK_BUTTON_ERROR",strErrorMessage),"[EVENT]",strEvent)        
            EventArg.Error.LocalizedDescription =  strErrorMessage               
            EventArg.Error.Description =  "The browser back button is not supported."
            Form_DisplayErrorMessage(EventArg) ' As Boolean                
            Response.End
        End If            
        mdm_CheckDialogIsMemory = FALSE
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		: 
' RETURNS			:
PRIVATE FUNCTION mdm_CreateStandardServiceInstance()
	Dim obj
    
	Set obj = mdm_CreateServiceInstance(                                    _
                                            Form.ServiceMsixdefFileName,    _
                                            Form.ProductViewMsixdefFileName _
                                        )
	If(IsValidObject(obj))Then
	
		Set mdm_CreateStandardServiceInstance	=	obj
		mdm_SaveDialogCOMInstance obj ' Save the object in the session based on its id
	Else
		Set mdm_CreateStandardServiceInstance	=	Nothing ' The function failed
	End If
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		: 
' RETURNS			:
PRIVATE FUNCTION mdm_CreateServiceInstance(strServiceMsixDefFile,strProductViewMsixDefFile) ' As Object
	Dim obj
  Dim objDictionary
  Dim strMdmPath
    
	Set obj = mdm_CreateObject(MSIXHandler)

  obj.MsixdefExtension = Form.MsixdefExtension ' MDM v2.2
     
	If (obj.Initialize(strServiceMsixDefFile,strProductViewMsixDefFile,mdm_GetSessionVariable("mdm_APP_LANGUAGE"),mdm_GetSessionVariable("mdm_APP_FOLDER"),mdm_GetMDMFolder(),mdm_InternalCache,Form.Localize,Form.Version))Then
    
        ' Test if a dictionary is set in the session variables and if yes
        ' associate the dictionary the the new service instance
        If(mdm_GetDictionaryInstance(obj,objDictionary))Then
            
            Set obj.Dictionary = objDictionary ' Set the dictionary
        End If
        
        ' Add a property to force the form to be save in a session in between events
        Form("CreationDate")            = Now()        
		    Set mdm_CreateServiceInstance   = obj        
				
				If IsObject(Session(MDM_FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME)) Then ' Check if security is available
				
							Set obj.SessionContext = Session(MDM_FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME)
							Set obj.Policy         = Session(MDM_FRAMEWORK_SECURITY_SECURITY_POLICY_SESSION_NAME)
				End If
	Else
        
        obj.Log mdm_GetMDMLocalizedError("MDM_ERROR_1007"),eLOG_ERROR
		    Set mdm_CreateServiceInstance = Nothing
	End If
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: 
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION mdm_SetEventInfoError(objServiceInstance,strMDMErrorMessage) ' As Boolean

    EventArg.Error.Number      = Mid(strMDMErrorMessage,1,4)
    EventArg.Error.Description = strMDMErrorMessage
    EventArg.Error.Source      = "mdm.asp"
END FUNCTION    

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION          : mdm_DisplayinternalErrorMessage
' PARAMETERS        :
' DESCRIPTION       : Format and display the error message strErrorMessage 
' RETURNS           :
PRIVATE FUNCTION mdm_DisplayinternalErrorMessage(strErrorMessage) ' As Boolean
    
	Response.write "<FONT Face='Arial' Size=2 Color=Red><b>"
    Response.write strErrorMessage
    Response.write "</B></FONT>"

    mdm_DisplayinternalErrorMessage = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_DisplayQueryString
' PARAMETERS	:
' DESCRIPTION : Format and display the error message strErrorMessage 
' RETURNS		  :
PRIVATE FUNCTION mdm_DisplayQueryString() ' As Boolean

    Dim itm
    Dim strValue
    Dim objUIItems
    
    ' MDM Own style to display the debug info	
    Response.write mdm_GetDebugStyleString()
        
    Response.Write "<TABLE BORDER=0 WIDTH='100%' BGCOLOR='white' CELLPADDING='0' CELLSPACING='0'>"
    
    Response.Write "<TR><TD Class='mdmDebuggerCaption' ColSpan='11'>Request.QueryString</TD></TR>"

	'SECENG: CORE-4773 CLONE - MSOL BSS 27420 XSS vulnerability in \RMP\UI\MDM\mdmLibrary.asp (ESR for 27259) (Post-PB)
	'Added HTML encoding
    Response.Write "<TR><TD Class='mdmDebuggerCell' ColSpan='11'>" & SafeForHtml(Request.QueryString) & "</TD></TR>"
    
    Response.Write "<TR><TD Class='mdmDebuggerCaption'>QueryString/Form Variables</TD><TD Class='mdmDebuggerCaption'>Source</TD><TD Class='mdmDebuggerCaption'>Value</TD></TR>"
    
    mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
    
    For Each itm in objUIItems
    
        Response.Write "<TR>" & vbNewLine
        
        'SECENG: CORE-4773 CLONE - MSOL BSS 27420 XSS vulnerability in \RMP\UI\MDM\mdmLibrary.asp (ESR for 27259) (Post-PB)
		'Added HTML encoding
        strValue = SafeForHtml(CStr(itm.Value))
        If(Len(strValue)=0)Then strValue = "&nbsp;"
        
        'Added HTML encoding
        Response.Write "<TD Class='mdmDebuggerCell'>" & SafeForHtml(itm.Name)  & "eee</TD>"
        Response.Write "<TD Class='mdmDebuggerCell'>" & IIF(itm.VbType,"QueryString","Form")  & "</TD>"
        Response.Write "<TD Class='mdmDebuggerCell'>" & strValue & "<TD>" & vbNewLine
        Response.Write "</TR>" & vbNewLine
    Next
    Response.Write "</TABLE>"  & vbNewLine
    
    mdm_DisplayQueryString = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_DisplayQueryString
' PARAMETERS	:
' DESCRIPTION : Format and display the error message strErrorMessage 
' RETURNS		  :
PRIVATE FUNCTION mdm_DisplayMDMFormCollection() ' As Boolean

    Dim itm
    Dim strValue
    Dim objUIItems
     
    Response.write mdm_GetDebugStyleString() ' MDM Own style to display the debug info	
        
    Response.Write "<TABLE BORDER=0 WIDTH='100%' BGCOLOR='white' CELLPADDING='0' CELLSPACING='0'>"
    Response.Write "<TR><TD Class='mdmDebuggerCaption'>MDM Form Collection</TD><TD Class='mdmDebuggerCaption'>Value</TD></TR>"
    
    For Each itm in Form
    
        Response.Write "<TR>" & vbNewLine       
        If(IsObject(itm.value))Then
           strValue                          = "Object:" & TypeName(itm)
        Else
        'SECENG: CORE-4773 CLONE - MSOL BSS 27420 XSS vulnerability in \RMP\UI\MDM\mdmLibrary.asp (ESR for 27259) (Post-PB)
		'Added HTML encoding
          strValue                          = SafeForHtml(itm.value)
        End If
        If(Len(strValue)=0)Then strValue  = "&nbsp;"
        
        Response.Write "<TD Class='mdmDebuggerCell'>" & itm.Name  & "</TD>"
        Response.Write "<TD Class='mdmDebuggerCell'>" & strValue & "<TD>" & vbNewLine
        Response.Write "</TR>" & vbNewLine
    Next
    Response.Write "</TABLE>"  & vbNewLine    
    mdm_DisplayMDMFormCollection = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_DisplayMonitorInfo
' PARAMETERS	:
' DESCRIPTION 	: Format and display the error message strErrorMessage 
' RETURNS		:
PRIVATE FUNCTION mdm_DisplayMonitorInfo() ' As Boolean

    On Error Resume Next
    ' MDM Own style to display the debug info	
    Response.write mdm_GetDebugStyleString()

  	Response.write "<TABLE Width='100%' CellPadding=0 CellSpacing=0 Border=0>" & vbNewLine 	
	  Response.write "<TR><TD ColSpan=2 Class='mdmDebuggerCaption' >MDM Monitor</TD></TR>" & vbNewLine
    Response.write "<TR><TD Class='mdmDebuggerCell'>MSIXHandler Instance Active</TD><TD Class='mdmDebuggerCell'>" & (Service.Monitor.InstanceActiveCount-1) & "</TD></TR>" & vbNewLine
    Response.write "<TR><TD Class='mdmDebuggerCell'>MSIXHandler Instance Created</TD><TD Class='mdmDebuggerCell'>" & (Service.Monitor.InstanceCreatedCount) & "</TD></TR>" & vbNewLine
    Response.write "</TABLE>" & vbNewLine
    
    On Error Goto 0
    Err.Clear
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_DisplayDebugInfo
' PARAMETERS	:
' DESCRIPTION 	: Format and display the error message strErrorMessage 
' RETURNS		:
PRIVATE FUNCTION mdm_DisplayDebugInfo(arrayDebugInfo) ' As Boolean

	  Dim 	strStyle 
	  Dim 	i		
    
    Response.write "<br>"
    mdm_DisplayMonitorInfo

    Response.write "<br>"
    mdm_DisplayQueryString
    
    Response.write "<br>"
    mdm_DisplayMDMFormCollection

    Response.write "<br>"

    ' MDM Own style to display the debug info	
    Response.write mdm_GetDebugStyleString() & vbNewLine

	  Response.write "<TABLE Width='100%' CellPadding=0 CellSpacing=0 Border=0>" & vbNewLine 	
  	Response.write "<TR><TD ColSpan=2 Class='mdmDebuggerCaption' >MDM Debugger</TD></TR>" & vbNewLine
	
	  For i = 0 To UBound(arrayDebugInfo) Step 2
    
		  Response.write "<TR><TD Class='mdmDebuggerCell'>" & arrayDebugInfo(i) & "</TD><TD Class='mdmDebuggerCell'>" & arrayDebugInfo(i+1) & "</TD></TR>" & vbNewLine
	  Next
    Response.write "</TABLE>" & vbNewLine

    Response.write "<br>"
    mdm_DisplaySessionInfo

    Response.write "<br>"
    mdm_DisplayApplicationInfo
        
	  mdm_DisplayDebugInfo = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: 
' PARAMETERS	:
' DESCRIPTION 	: 
' RETURNS		:
PRIVATE FUNCTION mdm_GetCurrentAspCall() ' As String
    If(request.serverVariables("QUERY_STRING").Item = "") Then     
      mdm_GetCurrentAspCall = request.serverVariables("URL") &  "?ErrorMsg=" & server.URLEncode(Session(mdm_EVENT_ARG_ERROR).Error.Description)
    Else
      mdm_GetCurrentAspCall = request.serverVariables("URL") & "?" & request.serverVariables("QUERY_STRING")
    End If   
END FUNCTION    

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: 
' PARAMETERS	:
' DESCRIPTION 	: 
' RETURNS		:
PRIVATE FUNCTION mdm_FindInRowSet(objMTSQLRowSet, strProperty, varValue) ' As Boolean
    
    mdm_FindInRowSet    =   FALSE
    
    objMTSQLRowSet.MoveFirst
    Do While Not objMTSQLRowSet.EOF
    
        If(CStr(objMTSQLRowSet.Value(strProperty))=CStr(varValue))Then
        
                mdm_FindInRowSet    =   TRUE
                Exit Function
        End If 
        objMTSQLRowSet.MoveNext
    LOOP    
END FUNCTION    

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_GetInstanceFromSession
' PARAMETERS		:
' DESCRIPTION 		: Return Nothing is the object is not in the session
' RETURNS			: Object or Nothing
PRIVATE FUNCTION mdm_GetInstanceFromSession(strSessionVariableName) ' As Object

    On Error Resume Next
    Set mdm_GetInstanceFromSession = Session(strSessionVariableName)
    
    If(Err.Number)Then
    
        Set mdm_GetInstanceFromSession = Nothing
    End If
    Err.Clear
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  :
PRIVATE FUNCTION mdm_CreateObject(strProgId) ' As Object

    Set mdm_CreateObject    =   mtvblib_CreateObject(strProgId)
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_DisplayDebugInfo
' PARAMETERS	:
' DESCRIPTION : Format and display the error message strErrorMessage 
' RETURNS		  :
PRIVATE FUNCTION mdm_DisplayDictionaryInfo() ' As Boolean

    Dim itm
    Dim objDic
    Dim lngDicIndex
    
    Set objDic = Session("mdm_LOCALIZATION_DICTIONARY")
    
    ' MDM Own style to display the debug info	
    Response.write mdm_GetDebugStyleString()
    
    Response.Write "<TABLE BORDER=0 WIDTH='100%' BGCOLOR='white' CELLPADDING='0' CELLSPACING='0'>"  & vbNewLine
    Response.Write "<TR>"  & vbNewLine
    Response.Write "         <TD Class='mdmDebuggerCaption'>Index</TD><TD Class='mdmDebuggerCaption'>Dictionary Entries</TD><TD Class='mdmDebuggerCaption'>Value</TD>"  & vbNewLine
    Response.Write "</TR>"  & vbNewLine
    
    lngDicIndex=0
    For Each itm in objDic
    
        lngDicIndex=lngDicIndex+1
        Response.Write "<TR>" & vbNewLine
            Response.Write "     <TD Class='mdmDebuggerCell' Align='Right'>" & lngDicIndex & "</TD><TD id='Dic" & lngDicIndex & "' Class='mdmDebuggerCell'>" & Itm.Name  & "</TD>"
            Response.Write "<TD Class='mdmDebuggerCell'>"
            Response.Write mdm_DisplayHTML( Itm.Value  )
            Response.Write "     </TD>" & vbNewLine
        Response.Write "</TR>" & vbNewLine
    Next
    Response.Write "</TABLE>" & vbNewLine
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION mdm_GetDebugStyleString()

    Dim strStyle

    ' MDM Own style to display the debug info	
  	strStyle = strStyle  & "<STYLE TYPE='text/css'>" & vbNewLine
	  strStyle = strStyle  & ".mdmDebuggerCaption{BACKGROUND-COLOR: #A8A8A8;BORDER-BOTTOM: 1px solid #8F8F8F;BORDER-LEFT: 1px solid #D0D0D0;BORDER-RIGHT: 1px solid #8F8F8F;BORDER-TOP: 1px solid #D0D0D0;clipBottom: 0px;clipLeft: 0px;clipRight: 0px;clipTop: 0px;COLOR: #484848;FONT-FAMILY: verdana;FONT-SIZE: 8pt;FONT-WEIGHT: bold;PADDING-BOTTOM: 2px;PADDING-LEFT: 2px;PADDING-RIGHT: 2px;PADDING-TOP: 2px;TEXT-ALIGN: Center;}" & vbNewLine
  	strStyle = strStyle  & ".mdmDebuggerCell{CURSOR:hand;BACKGROUND-COLOR: #B8B8B8;BORDER-BOTTOM: 1px solid #8F8F8F;BORDER-LEFT: 1px solid #D0D0D0;BORDER-RIGHT: 1px solid #8F8F8F;BORDER-TOP: 1px solid #D0D0D0;clipBottom: 0px;clipLeft: 0px;clipRight: 0px;clipTop: 0px;COLOR: #484848;FONT-FAMILY: verdana;FONT-SIZE: 8pt;FONT-WEIGHT: normal;PADDING-BOTTOM:1px;PADDING-LEFT: 1px;PADDING-RIGHT: 1px;PADDING-TOP: 1px;TEXT-ALIGN: left;}" & vbNewLine
    strStyle = strStyle  & ".mdmDebuggerCell:hover{BACKGROUND-COLOR: yellow;BORDER-BOTTOM: 1px solid #8F8F8F;BORDER-LEFT: 1px solid #D0D0D0;BORDER-RIGHT: 1px solid #8F8F8F;BORDER-TOP: 1px solid #D0D0D0;clipBottom: 0px;clipLeft: 0px;clipRight: 0px;clipTop: 0px;COLOR: red;FONT-FAMILY: verdana;FONT-SIZE: 8pt;FONT-WEIGHT: bold;PADDING-BOTTOM:1px;PADDING-LEFT: 1px;PADDING-RIGHT: 1px;PADDING-TOP: 1px;TEXT-ALIGN: left;}" & vbNewLine
    strStyle = strStyle  & ".mdmDebuggerCellProperty{BACKGROUND-COLOR: #B8B8B8;BORDER-BOTTOM: 1px solid #8F8F8F;BORDER-LEFT: 1px solid #D0D0D0;BORDER-RIGHT: 1px solid #8F8F8F;BORDER-TOP: 1px solid #D0D0D0;clipBottom: 0px;clipLeft: 0px;clipRight: 0px;clipTop: 0px;COLOR: #484848;FONT-FAMILY: verdana;FONT-SIZE: 8pt;FONT-WEIGHT: normal;PADDING-BOTTOM: 1px;PADDING-LEFT: 1px;PADDING-RIGHT: 1px;PADDING-TOP: 1px;TEXT-ALIGN: left;}" & vbNewLine   
    strStyle = strStyle  & ".mdmDebuggerBox{BACKGROUND-COLOR: white;BORDER-BOTTOM: black solid 1px;BORDER-LEFT: black solid 1px;BORDER-RIGHT: black solid 1px;BORDER-TOP: black solid 1px;COLOR: black;FONT-FAMILY: verdana;FONT-SIZE: 8pt;}"
	  strStyle = strStyle  & "</STYLE>" & vbNewLine 
        
    mdm_GetDebugStyleString = strStyle
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_TestIfFormMustBeSavedAndSave
' PARAMETERS		:
' DESCRIPTION 	: Note that the mdm put the property CreationDate in the Form properties object so
'                 the form is in fact always saved. So the Programmer can relie on the information
'                 stored in the form like the property RouteTo.
' RETURNS			:
PRIVATE FUNCTION mdm_TestIfFormMustBeSavedAndSave() ' As Boolean

    Dim obj
    
    If(Form.Count)Or((Form.Grid.TurnDowns.Count))Then

        Set Session(mdm_FORM_SESSION_NAME & GetDialogId())	=	Form
    Else
        ' We must not save the form, but an instance is maybe store in the session so we check and free it        
        Set obj = mdm_GetInstanceFromSession(mdm_FORM_SESSION_NAME & GetDialogId())
        If(IsValidObject(obj))Then ' The Instance exist
        
            mdm_FreeFormObjectFromSession
        End If
    End If
    mdm_TestIfFormMustBeSavedAndSave = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_FreeFormObjectFromSession
' PARAMETERS		:
' DESCRIPTION 	: Free the entry in the session that hold the form object
' RETURNS			  :
PRIVATE FUNCTION mdm_FreeFormObjectFromSession() ' As Boolean

    Set Session(mdm_FORM_SESSION_NAME & GetDialogId())  = Nothing ' Free
    mdm_FreeFormObjectFromSession                       = TRUE
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_TestIfFormMustRestoredAndRestore
' PARAMETERS	:
' DESCRIPTION : Test if the Form object was stored in a session if yes set the Form variable else create new one...
' RETURNS			: TRUE / FALSE
PRIVATE FUNCTION mdm_TestIfFormMustRestoredAndRestore() ' As Boolean

    Dim objForm
    Set objForm = mdm_GetInstanceFromSession(mdm_FORM_SESSION_NAME & GetDialogId())
    
    If(IsValidObject(objForm))Then
       'Set Session(mdm_FORM_SESSION_NAME & GetDialogId()) = Nothing ' Free the session ref --{ remove 9/8/2005 KAB }
       Set Form    =   objForm
    Else
       Set Form    =   mdm_CreateObject(MDMForm)
    End If
    mdm_TestIfFormMustRestoredAndRestore = TRUE                
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION mdm_MoveRowsetToPage(objRowSet, objPage) ' As Boolean

    Dim lngMaxRow,i
    
    objRowset.MoveFirst
    
    lngMaxRow   =   (objPage.Index-1) * objPage.MaxRow
    For i=1 to lngMaxRow
    
        objRowset.MoveNext
        If  objRowset.EOF Then Exit For
    Next
    mdm_MoveRowsetToPage = TRUE
END FUNCTION    



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_CacheInit
' PARAMETERS		:
' DESCRIPTION 		: Create and stored a Cache object in a session or retreive it
'                     if already created. The cache instance is deleted by the mdm_GarbageCollection
' RETURNS			:
PRIVATE FUNCTION mdm_CacheInit() ' As Boolean
    
    Set mdm_InternalCache = mdm_GetInstanceFromSession(mdm_CACHE_SESSION_NAME)
    If(Not IsValidObject(mdm_InternalCache))Then
    
        'Err.raise 1018,MDM_ERROR_1018,MDM_ERROR_1018
        'Set mdm_InternalCache                         =   Nothing
        Set mdm_InternalCache                         =   CreateObject(MSIXCache)
        mdm_InternalCache.Name                        =   "MTDialogManager Cache"
        Set Session(mdm_CACHE_SESSION_NAME)           =   mdm_InternalCache
    End If
    mdm_CacheInit = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_DisplayCacheInfo
' PARAMETERS	:
' DESCRIPTION 	:
' RETURNS		:
PRIVATE FUNCTION mdm_DisplayCacheInfo() ' As Boolean

    Dim itm
    Dim lngDicIndex
    
    mdm_CacheInit
    
    If(mdm_InternalCache Is Nothing)Then    
        Response.Write "The Cache object is not allocated"
        Exit Function
    End If
    
    ' MDM Own style to display the debug info	
    Response.write mdm_GetDebugStyleString()
    
    Response.Write "<TABLE BORDER=0 WIDTH='100%' BGCOLOR='white' CELLPADDING='0' CELLSPACING='0'>"  & vbNewLine
    Response.Write "<TR>"  & vbNewLine
    Response.Write "         <TD Class='mdmDebuggerCaption'>Index</TD><TD Class='mdmDebuggerCaption'>Cache Entries</TD><TD Class='mdmDebuggerCaption'>Hit</TD><TD Class='mdmDebuggerCaption'>Type</TD><TD Class='mdmDebuggerCaption'>Value</TD>"  & vbNewLine
    Response.Write "</TR>"  & vbNewLine
    
    lngDicIndex = 0

    For Each itm in mdm_InternalCache
    
        lngDicIndex = lngDicIndex + 1
        Response.Write "<TR>" & vbNewLine
        Response.Write "     <TD Class='mdmDebuggerCell' Align='Right'>" & lngDicIndex & "</TD>" & vbNewLine
        Response.Write "     <TD Class='mdmDebuggerCell'>" & Itm.Name  & "</TD>" & vbNewLine
        Response.Write "     <TD Class='mdmDebuggerCell'>" & Itm.Hit  & "</TD>" & vbNewLine
        Response.Write "     <TD Class='mdmDebuggerCell'>" & TypeName(Itm.data)  & "</TD>" & vbNewLine
        If(IsObject(Itm.data))Then
           
            If(UCase(TypeName(Itm.data))="CVARIABLES")Or(UCase(TypeName(Itm.data))="MSIXENUMTYPEENTRIES")Then
                Response.Write "     <TD Class='mdmDebuggerCell'>" & Replace(Itm.data.ToString(),vbNewLine,"<br>")  & "</TD>" & vbNewLine
            Else
                Response.Write "     <TD Class='mdmDebuggerCell'>&nbsp;</TD>" & vbNewLine
            End if
        Else
            Response.Write "     <TD Class='mdmDebuggerCell'>" & Itm.data  & "</TD>" & vbNewLine
        End if
        Response.Write "</TR>" & vbNewLine
    Next
    Response.Write "</TABLE>" & vbNewLine
    mdm_DisplayCacheInfo = TRUE
END FUNCTION

PRIVATE FUNCTION mdm_ClearCache() ' As Boolean

   ' mdm_CacheInit
    mdm_InternalCache.Clear
    'Service.Log MDM_ERROR_1012, eLOG_WARNING
    mdm_ClearCache = TRUE
END FUNCTION    

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 	        : mdm_DisplayHTML
' PARAMETERS	    : 
' DESCRIPTION 	    : Convert the chars '<' and '>' into a printable HTML source code
'                     and return the string
' RETURNS	        :
PRIVATE FUNCTION mdm_DisplayHTML(strHTML) ' As String
    Dim strHTML2        
    
    strHTML2        =   Replace(strHTML,"<","&lt;")
    strHTML2        =   Replace(strHTML2,">","&gt;")
    mdm_DisplayHTML =   strHTML2    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_GarbageCollector
' PARAMETERS	:
' DESCRIPTION : Free any session objects taking care to delete circular COM references
' RETURNS		  :
PRIVATE FUNCTION mdm_GarbageCollector() ' As Boolean

    Dim itm         ' As Variant
    Dim subitm
     
    mdm_ClearCache
    
    ' Try to free circular references in objects and sub objects 
    For Each itm in Session.Contents
        
        If(IsObject(Session(itm)))Then
          
          On Error Resume Next
            For Each subitm in Session(itm)
              subitm.Delete
              subitm.Clean  
              subitm.Clear
              Set subitm = Nothing
              subitm = Empty
            Next

            Session(itm).Delete
            Session(itm).Clean  
            Session(itm).Clear
          On Error Goto 0     
        End If
    Next

    ' Take a second pass at freeing circular references in case of dependency in order... 
    ' Next free the objects in session
    For Each itm in Session.Contents
    
        If(IsObject(Session(itm)))Then
          On Error Resume Next
            For Each subitm in Session(itm)
              subitm.Delete
              subitm.Clean  
              subitm.Clear
              Set subitm = Nothing
              subitm = Empty
            Next
          On Error Goto 0
          
          Set Session(itm) = Nothing
        End If

        Session(itm) = Empty
    Next
    
    mdm_GarbageCollector = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_DisplayDebugInfo
' PARAMETERS	:
' DESCRIPTION 	: Format and display the error message strErrorMessage 
' RETURNS		:
PRIVATE FUNCTION mdm_DisplaySessionInfo() ' As Boolean

    Dim itm
    
    ' MDM Own style to display the debug info	
    Response.write mdm_GetDebugStyleString()
    
    Response.Write "<TABLE BORDER=0 WIDTH='100%' BGCOLOR='white' CELLPADDING='0' CELLSPACING='0'>"  & vbNewLine
    Response.Write "<TR>"  & vbNewLine
    Response.Write "         <TD Class='mdmDebuggerCaption'>Session Variables</TD><TD Class='mdmDebuggerCaption'>Type</TD><TD Class='mdmDebuggerCaption'>Value</TD>"  & vbNewLine
    Response.Write "</TR>"  & vbNewLine
    
    For Each itm in Session.Contents
    
        Response.Write "<TR>" & vbNewLine
        
        Response.Write "    <TD Class='mdmDebuggerCell'>" & Itm  & "</TD>" & vbNewLine
        Response.Write "    <TD Class='mdmDebuggerCell'>" & TypeName(Session(Itm))  & "</TD>" & vbNewLine
        
        If(IsObject(Session(itm)))Then
        
            Response.Write "     <TD nowrap Class='mdmDebuggerCell'>&nbsp;</TD>" & vbNewLine
            
        ElseIf(IsArray(Session(itm)))Then
        
            Response.Write "     <TD nowrap  Class='mdmDebuggerCell'>ARRAY:<BR>"
            Dim i
            For i = 1 to UBound(Session(itm))
              If(LEN(Session(itm)(i)))Then
				'SECENG: CORE-4773 CLONE - MSOL BSS 27420 XSS vulnerability in \RMP\UI\MDM\mdmLibrary.asp (ESR for 27259) (Post-PB)
				'Added HTML encoding
                response.write "<input type='text' class='clsInputBox' size='80' value='" & SafeForHtmlAttr(Session(itm)(i)) & "'><br>"
              End If
            Next
            Response.Write "<TD>" & vbNewLine
        Else
			'SECENG: CORE-4773 CLONE - MSOL BSS 27420 XSS vulnerability in \RMP\UI\MDM\mdmLibrary.asp (ESR for 27259) (Post-PB)
			'Added HTML encoding
            Response.Write "     <TD nowrap  Class='mdmDebuggerCell'>" & SafeForHtml(Session(itm)) & "<TD>" & vbNewLine
        End If
        Response.Write "</TR>" & vbNewLine   
    Next
    Response.Write "</TABLE>" & vbNewLine
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mdm_DisplayApplicationInfo
' PARAMETERS	:
' DESCRIPTION 	: 
' RETURNS		:
PRIVATE FUNCTION mdm_DisplayApplicationInfo() ' As Boolean

    Dim itm
    
    ' MDM Own style to display the debug info	
    Response.write mdm_GetDebugStyleString()
    
    Response.Write "<TABLE BORDER=0 WIDTH='100%' BGCOLOR='white' CELLPADDING='0' CELLSPACING='0'>"  & vbNewLine
    Response.Write "<TR>"  & vbNewLine
    Response.Write "         <TD Class='mdmDebuggerCaption'>Application Variables</TD><TD Class='mdmDebuggerCaption'>Type</TD><TD Class='mdmDebuggerCaption'>Value</TD>"  & vbNewLine
    Response.Write "</TR>"  & vbNewLine
    
    For Each itm in Application.Contents
    
        Response.Write "<TR>" & vbNewLine
        
        Response.Write "    <TD Class='mdmDebuggerCell'>" & Itm  & "</TD>" & vbNewLine
        Response.Write "    <TD Class='mdmDebuggerCell'>" & TypeName(Application(Itm))  & "</TD>" & vbNewLine
        
        If(IsObject(Application(itm)))Then
            Response.Write "     <TD nowrap Class='mdmDebuggerCell'>&nbsp;</TD>" & vbNewLine
        Else
			'SECENG: CORE-4773 CLONE - MSOL BSS 27420 XSS vulnerability in \RMP\UI\MDM\mdmLibrary.asp (ESR for 27259) (Post-PB)
			'Added HTML encoding
            Response.Write "     <TD nowrap  Class='mdmDebuggerCell'>" & SafeForHtml(Application(itm)) & "<TD>" & vbNewLine
        End If
        Response.Write "</TR>" & vbNewLine   
    Next
    Response.Write "</TABLE>" & vbNewLine
END FUNCTION

FUNCTION mdm_BuildHelpFileName(strAspFile) ' As String

    Dim objTextFile ' as MTVBLib.CTextFile
    Set objTextFile  = mdm_CreateObject(CTextFile)
    Dim strFileName
    
    strFileName     = objTextFile.GetFileName(strAspFile,"/") 
    strFileName     = Replace(UCase(strFileName),".ASP",".hlp.htm")
    mdm_BuildHelpFileName = strFileName
END FUNCTION

FUNCTION Inherited(strEventName) ' As Variant

    strEventName = Replace(strEventName,"()","")
    If(Instr(strEventName,"("))Then
        Inherited = Eval("inherited" & strEventName)
    Else
        Inherited = Eval("inherited" & strEventName & "(EventArg)")
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_GetInstanceFromSession
' PARAMETERS		:
' DESCRIPTION 	: Return Nothing is the object is not in the session
' RETURNS			  : Object or Nothing
PRIVATE FUNCTION mdm_GetInstanceFromApplication(strSessionVariableName) ' As Object

    On Error Resume Next
    Set mdm_GetInstanceFromApplication = Application(strSessionVariableName)
    
    If(Err.Number)Then
    
        Set mdm_GetInstanceFromApplication = Nothing
    End If
    Err.Clear
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_UIValue
' PARAMETERS		:
'                 strName - The variable name 
' DESCRIPTION   : Return the value of the variable from the QueryString or the Form object. The MDM use only this function to read information
'                 sent from the UI. So the MDM support both QueryString and Form. The Default method for a MDM dialog is a post.
'       
' RETURNS			  : Return the string value
PRIVATE FUNCTION mdm_UIValue(strName) ' As String

  Dim strValue
  
  strValue  = Request.QueryString(strName)  ' If the name is defined in the query string even, as an empty string
  If(Not IsEmpty(strValue))Then 
      mdm_UIValue = strValue
      Exit Function
  End if  
  
  strValue  = Request.Form(strName) ' If the name is defined in the Form, even as an empty string
  If(Not IsEmpty(strValue))Then 
      mdm_UIValue = strValue
      Exit Function
  End If      
  
  mdm_UIValue = Empty ' Simulate not found in a query string
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_UIValueDefault
' PARAMETERS		:
' DESCRIPTION   : Same as mdm_UIValue but can specify a default value if no entry is  found in the Query/Form!
' RETURNS			  : Return the string value
PRIVATE FUNCTION mdm_UIValueDefault(strName,varDefaultValue) ' As String

  Dim strValue
  
  strValue  = mdm_UIValue(strName)
  If(IsEmpty(strValue)Or(Len("" & strValue)=0))Then
      strValue  = varDefaultValue
  End If
  mdm_UIValueDefault = strValue
  
  ' Here base on the default value I conclude that we are asking for a boolean value
  ' so i checked the type of the query string value. if the query string value
  ' is not a boolean, I will return the varDefaultValue
  If(UCase(varDefaultValue)="FALSE")Or(UCase(varDefaultValue)="TRUE")Then
  
        If NOT( (UCase(strValue)="FALSE")Or(UCase(strValue)="TRUE") )Then
        
            mdm_UIValueDefault = varDefaultValue
        End If
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_BuildQueryStringCollectionPlusFormCollection
' PARAMETERS		:
'                 objAllCollection - The output result.
' DESCRIPTION   : Return in objAllCollection a CVariables object that contains the QueryString collection items and the Form collection items.
'
' RETURNS			  : TRUE if ok.
PRIVATE FUNCTION mdm_BuildQueryStringCollectionPlusFormCollection(objAllCollection) ' As Boolean

  Dim objItem
  
  'Set objAllCollection =  ProductView.Tools.Cache.GetObject(CVariables,"QueryStringColPlusFormCol")  
  Set objAllCollection =  mdm_CreateObject(CVariables)
  objAllCollection.Clear
   
  For Each objItem In Request.QueryString   ' Add all the item of the QueryString Collection
  
      objAllCollection.Add CStr(objItem), CStr(Request.QueryString(objItem)),1
  Next
  
  For Each objItem In Request.Form ' Add all the item of the QueryString Collection
    
      objAllCollection.Add CStr(objItem), CStr(Request.Form(objItem)),0
  Next  
  
  mdm_BuildQueryStringCollectionPlusFormCollection  = TRUE
  
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_GetDictionary
' PARAMETERS		:
' DESCRIPTION   : Return the instance of the dictionary stored in the session else nothing.
' RETURNS			  : TRUE if ok.
PUBLIC FUNCTION mdm_GetDictionary() ' As Dictionary

    On Error Resume Next
    Set mdm_GetDictionary = Session("mdm_LOCALIZATION_DICTIONARY")
    If(Err.Number)Then
    
        Err.Clear
        Set mdm_GetDictionary = Nothing
    End If
    On Error Goto 0   
END FUNCTION  



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_IsServiceInstanceInMemory
' PARAMETERS		:
' DESCRIPTION 	: Find if a service is in memory
' RETURNS			  :
PRIVATE FUNCTION mdm_IsServiceInstanceInMemory() ' As Object

	Dim obj
	    
	On Error Resume Next
	Set obj = Session(mdm_DIALOG_SESSION_NAME & GetDialogId())
	If(Err.Number)Or(Not IsValidObject(obj))Then
  
      mdm_IsServiceInstanceInMemory = FALSE
  Else
      mdm_IsServiceInstanceInMemory = TRUE
	End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_IsServiceInstanceInMemory
' PARAMETERS		:
' DESCRIPTION 	: Find if a service is in memory
' RETURNS			  :
PRIVATE FUNCTION mdm_DeleteServiceInstanceInMemory() ' As Object

    mdm_SaveDialogCOMInstance Nothing ' Clear the Session variable
    mdm_FreeFormObjectFromSession
    mdm_DeleteServiceInstanceInMemory = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_PopulateDictionaryWithInternalStuff
' PARAMETERS		:
' DESCRIPTION 	: By setting in the query string mdmReload=True, we can force a dialog to be deleted from
'                 Memory before we start it! To force a full reload...
'
'                 At this point the form object is already allocated or retreive from the session by the funtion
'                 mdm_TestIfFormMustRestoredAndRestore called from mdm_Initialize
'
' RETURNS			  :
FUNCTION mdm_TestIfMustUnLoadDialog(booForce) ' As Boolean
  
	Dim strFormSerialization
	
  mdm_TestIfMustUnLoadDialog = TRUE
  
  ' -- I changed this so will always remove the dialog from memory
  If(mdm_UIValueDefault("mdmReload",False))Or(booForce)Then
  
      If(mdm_IsServiceInstanceInMemory())Then ' Let us delete the service/product view object and the form object
             
	        ' We need to save and restore the form version. some feature depend on that and the form version is set
					' in the dialog before this code is executed.
          strFormSerialization = Form.Serialize
	 				
          mdm_TestIfMustUnLoadDialog  = mdm_DeleteServiceInstanceInMemory()
          mdm_TestIfFormMustRestoredAndRestore

          Form.Serialize = strFormSerialization
      End If
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_MakeID
' PARAMETERS		:
' DESCRIPTION   : 
' RETURNS			  : 
PUBLIC FUNCTION mdm_MakeID(str) ' As String

  str = Replace(str,"\","_") ' "
  str = Replace(str,"/","_")
  str = Replace(str," ","_")
  str = Replace(str,".","_")
  
  mdm_MakeID  = str
END FUNCTION  


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_TypeName(var) 
' PARAMETERS		:
' DESCRIPTION   : 
' RETURNS			  : 
PUBLIC FUNCTION mdm_TypeName(var) ' As String

  If(VarType(var)=vbDecimal)Then
      mdm_TypeName="Decimal"      
  Else
      mdm_TypeName=TypeName(var)
  End If
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_MsgBoxOk()
' PARAMETERS		:
' DESCRIPTION   : Diplay a msgbox with a title a message and a ok button then route to a specific page....
'                 Return the URL but does not call it...
' RETURNS			  : 
PUBLIC FUNCTION mdm_MsgBoxOk(strTitle, strMessage, strRouteTo, strAppPath) ' As String

  Dim strURLPath
  
  strURLPath  = strAppPath
  If(Len(strURLPath))Then
      strURLPath = strURLPath & "/"
  End If
  
  mdm_MsgBoxOk = strAppPath & "MDMMsgBoxOk.asp?Title=" & server.URLEncode(strTitle) & "&Message=" & server.URLEncode(strMessage) & "&RouteTo=" & server.URLEncode(strRouteTo)  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_GetHTMLTemplateFullName
' PARAMETERS		:
' DESCRIPTION   :
' RETURNS			  : 
FUNCTION mdm_GetHTMLTemplateFullName()

    mdm_GetHTMLTemplateFullName = request.serverVariables("PATH_TRANSLATED") 
END FUNCTION  

    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_GetHTMLTemplateFullName
' PARAMETERS		:
' DESCRIPTION   :
' RETURNS			  : 
FUNCTION mdm_AddParameterToAspCall(strAsp,strParameterName, strParameterValue)

  If(InStr(strAsp,"?"))Then ' The URL has already parameter
      mdm_AddParameterToAspCall = strAsp & "&" & server.URLEncode(strParameterName) & "=" & server.URLEncode(strParameterValue)
  Else
      mdm_AddParameterToAspCall =strAsp & "?" & server.URLEncode(strParameterName) & "=" & server.URLEncode(strParameterValue)
  End If
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: 
' PARAMETERS		:
' DESCRIPTION   :
' RETURNS			  : 
PUBLIC FUNCTION mdm_GetCurrentAspFileName()
  Dim objTextFile
  Set objTextFile           = mdm_CreateObject(CTextFile)
  mdm_GetCurrentAspFileName = objTextFile.GetFileName(request.serverVariables("URL"),"/")
END FUNCTION

PUBLIC FUNCTION mdm_NoTurnDownHTML(EventArg)
      EventArg.HTMLRendered     = "<td class='" & Form.Grid.CellClass & "' width='1'></td>" ' No Turn Down
END FUNCTION


PUBLIC FUNCTION mdm_DeleteDialogFromMemory()

    Form.Clear ' By Clearing every thing in the form, the form will not be saved in
               ' a session! Which is good because at this point the dialog is terminate!

    ' Clear the Session variable
    mdm_SaveDialogCOMInstance Nothing
    
    mdm_DeleteDialogFromMemory = TRUE
END FUNCTION    

' Not used for now 6/15/2001 - fred!
PUBLIC FUNCTION mdm_GetMaxCurrentMonth()
  Dim lngMonth
  Dim datGMTCurrentDate
  Dim lngMaxMonth
  
  lngMaxMonth       = Array(31, 27, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  datGMTCurrentDate = Service.Tools.GetCurrentGMTTime()
  lngMonth = Month(CDate(datGMTCurrentDate))
  
  mdm_GetMaxCurrentMonth = lngMaxMonth(lngMonth)
  
END FUNCTION

FUNCTION mdm_MakeErrorUserVisible(lngNumber)
    mdm_MakeErrorUserVisible = lngNumber+USER_ERROR_MASK
END FUNCTION    

'Call this function from Load_ProductView or Init when you wish for your rowset display to allow filtering on multiple
'columns in the rowset.
'booSelectedColumnOnly determines if all columns in the rowset can be used for filtering or if just the selected properties will be filter properties
FUNCTION mdm_SetMultiColumnFilteringMode(booSelectedColumnOnly)

    Form.Grid.FilterMode = MDM_FILTER_MULTI_COLUMN_MODE_ON ' Filter
    Service.Properties.Add "mdmPVBFilterColumns","String",255,TRUE,0,eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
    Dim p, objValidListOfProperties
    Set objValidListOfProperties = mdm_CreateObject(CVariables)
    
    For Each p In Service.Properties
      'We are saving the properytype as part of the value for the cases in which we need to retrieve the filter information to pass to the backend
      'but do not yet have a productview (CR #13284 2/10/2006)
      If booSelectedColumnOnly Then
          If p.Selected Then objValidListOfProperties.Add p.Name,p.Name&"~"&p.propertytype,,,p.Caption ' Selected Column Only
      Else
          objValidListOfProperties.Add p.Name,p.Name&"~"&p.propertytype,,,p.Caption ' All Column
      End If
    Next
    
    Service.Properties("mdmPVBFilterColumns").AddValidListOfValues objValidListOfProperties
    '//We are setting the operator to be a list of something just to avoid an MDM warning in the HTMLProcessor when the select list is empty. The actual operators are set in javascript.
    '//CR#13547
    Service.Properties.Add "mdmPVBFilterOperator","String",255,TRUE,0,eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
    Service.Properties("mdmPVBFilterOperator").AddValidListOfValues objValidListOfProperties '//Not the real list
    
END FUNCTION

'Call this function from Load_ProductView or Init when you wish for your rowset display to allow filtering on multiple
'columns in the rowset and you wish to specify exactly which columns can be used in the filter.
'sColumnList is a string with the format "~Time~User~Details~Id~" where ~ is the separator separating the column names to be used in the filter.
'Any separator can be used but the first character of the string must be the separator used to separate the rest of the string
'All the columns specified must exist by name within the productview but they do not have to be selected or displayed
FUNCTION mdm_SetMultiColumnFilteringModeWithCustomProperties(sColumnList)

    Form.Grid.FilterMode = MDM_FILTER_MULTI_COLUMN_MODE_ON ' Filter
    Service.Properties.Add "mdmPVBFilterColumns","String",255,TRUE,0,eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
    
    Dim p, objValidListOfProperties
    Set objValidListOfProperties = mdm_CreateObject(CVariables)
    
    dim arrPropertyNames,sPropName
    arrPropertyNames = Split(sColumnList,Left(sColumnList,1))
    
    For Each sPropName In arrPropertyNames
      if len(sPropName)>0 then
        set p=Service.Properties(sPropName)
        objValidListOfProperties.Add p.Name, p.Name&"~"& p.propertytype,,,p.Caption
      end if
    Next

    Service.Properties("mdmPVBFilterColumns").AddValidListOfValues objValidListOfProperties
    '//We are setting the operator to be a list of something just to avoid an MDM warning in the HTMLProcessor when the select list is empty. The actual operators are set in javascript.
    '//CR#13547
    Service.Properties.Add "mdmPVBFilterOperator","String",255,TRUE,0,eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
    Service.Properties("mdmPVBFilterOperator").AddValidListOfValues objValidListOfProperties '//Not the real list
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_IncludeCalendar
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mdm_IncludeCalendar() ' As Boolean

    ' Load the Calendar widget
    Form.Widgets.Add "Calendar", server.MapPath("/mdm/common/Widgets/Calendar/Calendar.Header.htm"), server.MapPath("/mdm/common/Widgets/Calendar/Calendar.Footer.htm")
    mdm_IncludeCalendar = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_IncludeProgress
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mdm_IncludeProgress() ' As Boolean
    ' Load the Progress widget
    Form.Widgets.Add "Progress", server.MapPath("/mdm/common/Widgets/Progress/Progress.Header.htm"), server.MapPath("/mdm/common/Widgets/Progress/Progress.Footer.htm")
    mdm_IncludeProgress = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mdm_GetGMTTimeFormatted(strFormat)

  Dim objTools
  Set objTools           = CreateObject(MSIXTOOLS_PROG_ID)
  mdm_GetGMTTimeFormatted = objTools.Format(objTools.GetCurrentGMTTime(), strFormat) 'metratime
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mdm_NormalDateFormat(vardate,strFormat)
  strFormat = LCase(strFormat)
  if(IsNull(vardate)) Then
    mdm_NormalDateFormat = ""
    exit function
  end if
    
  if(Len(vardate)=0) Then
    mdm_NormalDateFormat = ""
    exit function
  end if

  Dim Day, Month, Year
  Dim formatparts
  Dim parts
  if(InStr(strFormat, ".") = 0) then
    formatparts = Split(strFormat, "/")                   '[dd, MM, yyyy hh:mm:ss AMPM]
  else
    formatparts = Split(strFormat, ".")                   '[dd, MM, yyyy hh:mm:ss AMPM]
end if
  if(InStr(vardate, ".") = 0 and InStr(vardate, "/") = 0) then
    mdm_NormalDateFormat = ""
    exit function
  elseif(InStr(vardate, ".") = 0) then
    parts = Split(vardate, "/")                                '[9/1/2013 12:00:01 AM]
  elseif(InStr(vardate, "/") = 0) then
    parts = Split(vardate, ".")
end if

  Dim Rest 
  Rest = parts(2)

  if ((StrComp(formatparts(0),"dd")= 0) or (StrComp(formatparts(0),"d")= 0) or (StrComp(formatparts(0), "j")= 0))  Then 
    Month = parts(1)                               '9
    Day = parts(0)                                          '1
  elseIf (StrComp(formatparts(0),"yyyy")= 0) Then
    Month = parts(1)                               '9
    Dim dayplustime
    dayplustime = Split(parts(2), " ")
    Day = dayplustime(0)
    Year = parts(0)
    Rest = Year
    if UBound(dayplustime) > 0 then
      Rest = Rest & " " +dayplustime(1)
    elseif UBound(dayplustime) > 1  then
     Rest = Rest & " " +dayplustime(2)
    end if
  else
    Day = parts(1)                               '9
    Month = parts(0)     
  end if 
  mdm_NormalDateFormat = Month & "/" & Day & "/" & Rest
END FUNCTION 
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mdm_Format(varValue,strFormat)

  Dim objTools
  Set objTools  = CreateObject(MSIXTOOLS_PROG_ID)
  mdm_Format    = objTools.Format(varValue,strFormat)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mdm_GetHTMLHiddenTagError(ErrorCode)
    Dim strHTML
    If IsObject(ErrorCode) Then
        strHTML = strHTML &  vbNewLine & "<INPUT Name='MDM_ERROR_NUMBER' Type='Hidden' Value='" & ErrorCode.Number & "'>"  
        strHTML = strHTML &  vbNewLine & "<INPUT Name='MDM_ERROR_DESCRIPTION' Type='Hidden' Value='" & Replace(ErrorCode.Description,"'","") & "'>" & vbNewLine
    Else
        strHTML = vbNewLine & "<INPUT Name='MDM_ERROR_NUMBER' Type='Hidden' Value='" & strErrorCode & "'>" & vbNewLine
    End If
    mdm_GetHTMLHiddenTagError = strHTML
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mdm_SaveErrorInSession(lngNumber, strDescription)

  EventArg.Error.Number               = lngNumber
  EventArg.Error.Description          = strDescription
  EventArg.Error.LocalizedDescription = strDescription
  EventArg.Error.Source               = "MDM/ASP"
  Set Session(mdm_EVENT_ARG_ERROR)    = EventArg
  mdm_SaveErrorInSession              = TRUE
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mdm_GetMDMLocalizedError(strName)
    mdm_GetMDMLocalizedError = mdm_GetDictionaryValue(strName,Eval(strName))
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mdm_MakeTemplateFileName(byval s)

  s = Replace(s,"/","_")    
  s = Replace(s," ","_")    
  mdm_MakeTemplateFileName = s
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mdm_GetServiceInstanceFromID(strDialogID,booLogErrorIfNotFound)
    Dim s
    
    Set mdm_GetServiceInstanceFromID = Nothing
    
    For Each s In Session.contents    
    
        If CBool(InStr(UCASE(s),UCASE(strDialogID))) and CBool(InStr(UCASE(s),UCASE(mdm_DIALOG_SESSION_NAME))) Then
        
            Set mdm_GetServiceInstanceFromID = Session(s)
            Exit Function
        End If
    Next
    If(booLogErrorIfNotFound)Then
        mdm_LogError PreProcess(mdm_GetMDMLocalizedError("MDM_ERROR_1025"),Array("FILENAME",CHILDREN_DIALOG_ASP_FILE_NAME))
    End If
END FUNCTION    

PUBLIC FUNCTION mdm_MakeName(Byval strName)
    strName = Replace(strName,"/","_")
    strName = Replace(strName,"\","_")
    strName = Replace(strName,".","_")
    strName = Replace(strName,"@","_")
    mdm_MakeName = strName
END FUNCTION

PUBLIC FUNCTION mdm_GetNewMDMEventInstance()
  Set mdm_GetNewMDMEventInstance = CreateObject("MTMSIX.MDMEvent")
END FUNCTION

'//CR14423
'//Rudi: I believe this was added to fix bug CR9356, however removing it since SQL Server/Oracle code should be in Filter/Data access components and not MDM
'PUBLIC FUNCTION mdm_ADOProperty(strP) ' as String
'  mdm_ADOProperty = "[" & strP & "]"
'END FUNCTION


PUBLIC FUNCTION mdm_MeteringTimeOutManager(MSIXHanlderService, strMeteringTimeOutManagerURL, strActionMessage, strOKMessage, strCancelMessage,strRouteTo)

    If Err.Number=MT_ERR_SYN_TIMEOUT Or Err.Number=MT_ERR_SERVER_BUSY Then
    
        If Len(strMeteringTimeOutManagerURL) Then
            
             ' Save the Service.
             Set Session(MDM_METERING_SERVICE_TIME_OUT) = MSIXHanlderService
             mdm_TerminateDialogAndExecuteDialog strMeteringTimeOutManagerURL & "?ActionMessage=" & Server.URLEncode(strActionMessage) & "&RouteTo=" & Server.URLEncode(strRouteTo) & "&OKMessage=" & Server.URLEncode(strOKMessage) & "&CancelMessage=" & Server.URLEncode(strCancelMessage)
        End If
    End If
    mdm_MeteringTimeOutManager = TRUE
END FUNCTION

PUBLIC FUNCTION mdm_MeteringTimeOutManagerReTry(EventArg, byRef booNeedToRetry)

    mdm_MeteringTimeOutManagerReTry = FALSE
    booNeedToRetry                  = FALSE
    Err.Clear
    On Error Resume Next
    Session(MDM_METERING_SERVICE_TIME_OUT).MeteredSessionSet.Close
    If Err.Number=0 Then
    
        mdm_MeteringTimeOutManagerReTry = TRUE
        mdm_MeteringTimeOutManagerClear
        
    ElseIf Err.Number=MT_ERR_SYN_TIMEOUT Or Err.Number=MT_ERR_SERVER_BUSY Then
    
        booNeedToRetry = TRUE
    Else
        EventArg.Error.Save Err
    End If
    Err.Clear
END FUNCTION

PUBLIC FUNCTION mdm_MeteringTimeOutManagerClear()

    If IsValidObject(Session(MDM_METERING_SERVICE_TIME_OUT)) Then 
    
        Session(MDM_METERING_SERVICE_TIME_OUT).CleanMeteredSessionSet        
        Set Session(MDM_METERING_SERVICE_TIME_OUT) = Nothing
    End If
    mdm_MeteringTimeOutManagerClear = TRUE
END FUNCTION

' MDM 3.6 Fred
PUBLIC FUNCTION mdm_PerformanceManager(booStartDialog)
    
    If MDM_DISPLAY_PERFORMANCE_INFO Then

        If booStartDialog Then    
            If IsEmpty(Session("MDM_DISPLAY_PERFORMANCE_INFO_OBJECT")) Then Set Session("MDM_DISPLAY_PERFORMANCE_INFO_OBJECT") = mdm_CreateObject(CWindows) 
            Session("MDM_DISPLAY_PERFORMANCE_INFO_START_TICK") = Session("MDM_DISPLAY_PERFORMANCE_INFO_OBJECT").GetTickCount()
        Else
            Dim lngSecondDuration, strInfo, strJavaScriptEndOfRenderedTime, strComment
            
            strComment						= "<i> <-- This information is only valid if the Browser is running on the WebServer Machine with or without Terminal Server</i>"
            lngSecondDuration				= (Session("MDM_DISPLAY_PERFORMANCE_INFO_OBJECT").GetTickCount() - Session("MDM_DISPLAY_PERFORMANCE_INFO_START_TICK"))/1000
            strInfo							= "PERFORMANCE INFO[CRLF]FILE:[FILE][CRLF][CRLF]SERVER-TIME:[DURATION][CRLF]SERVER-ENDED-AT:[NOW][CRLF]CLIENT-ENDED-AT:[RNOW][COMMENT]"
            strJavaScriptEndOfRenderedTime	= "<SCRIPT>now = new Date;document.write(now.getFullYear()+""/""+(now.getMonth()+1)+""/""+now.getDate()+""/""+"" ""+now.getHours()+"":""+now.getMinutes()+"":""+now.getSeconds());</SCRIPT>"
            
            strInfo = PreProcess(strInfo,Array("COMMENT",strComment,"RNOW",strJavaScriptEndOfRenderedTime,"NOW",mdm_Format(now,"yyyy/mm/dd h:n:s"),"CRLF","<BR>","DURATION",lngSecondDuration,"FILE",request.serverVariables("URL")))
            Response.Write "<PRE>" & strInfo & "<PRE>"
            
        End If
    End If    
    mdm_PerformanceManager = TRUE
END FUNCTION    

' This function should be called when you keep a rowset around that has filtering applied to it.
PUBLIC FUNCTION mdm_ClearPVBFilter(rs)

    Set ProductView.Properties.RowSet = rs
    If IsValidObject(ProductView.Properties.RowSet.Filter) Then
		ProductView.Properties.RowSet.Filter.Clear
		ProductView.Properties.Rowset.ApplyExistingFilter
    End if
    
    mdm_ClearPVBFilter = TRUE
END FUNCTION

Public Function SetPropertiesFromRowset(s, objRowset) '  As Boolean

    Dim strName 'As String
    Dim i       'As Long
        
    For i = 0 To objRowset.Count - 1
    
        strName = objRowset.Name(CLng(i))
        
        If s.Properties.Exist(strName) Then
        
            s.Properties.Item(strName).Value = objRowset.Value(CLng(i))
        End If
     
    Next
    
    SetPropertiesFromRowset = True

End Function

FUNCTION mdm_EscapeForImageHandler(s)
' CORE-921  a pound sign # is not a valid URI identifer
		s = Replace(s,".","_")
		s = Replace(s,":","_")
		s = Replace(s,"'","_")
		s = Replace(s,"&","_")
		s = Replace(s,"""","_")
		s = Replace(s,"#","_")
		s = Replace(s,"*","_")		
        mdm_EscapeForImageHandler = Server.HTMLEncode(trim(s))
END FUNCTION

FUNCTION mdm_GetIconUrlForParameterTable(sParamTableName)
		mdm_GetIconUrlForParameterTable = "/ImageHandler/images/productcatalog/paramtable/" & mdm_EscapeForImageHandler(sParamTableName) & "/paramtable.gif"
END FUNCTION

FUNCTION mdm_GetIconUrlForPriceableItem(sPriceableItemName, nKind)
		mdm_GetIconUrlForPriceableItem = "/ImageHandler/images/productcatalog/priceableitem/" & nKind & "/" & mdm_EscapeForImageHandler(sPriceableItemName) & "/priceableitem.gif"
END FUNCTION

FUNCTION mdm_GetIconUrlForAccountType(sAccountTypeName)
		mdm_GetIconUrlForAccountType = "/imagehandler/images/Account/" & mdm_EscapeForImageHandler(sAccountTypeName) & "/account.gif"
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mdm_LocalizeXSL
' PARAMETERS		:
' DESCRIPTION   : Return the instance of the dictionary stored in the session else nothing.
' RETURNS			  : TRUE if ok.
PUBLIC FUNCTION mdm_LocalizeString(stringToLocalize) ' As Dictionary    

  Dim strTest 
  Dim strToReplace
  Dim strTag
  Set objRegExp = New RegExp
  objRegExp.Global = True
  objRegExp.IgnoreCase = True
  objRegExp.Pattern = "\[[A-Z0-9_]*\]"
  
  Set colMatches = objRegExp.Execute(stringToLocalize)
  For Each objMatch In colMatches
    strTag = Mid(objMatch.Value, 2, len(objMatch.Value) - 2)
    strToReplace = mdm_GetDictionaryValue(strTag, objMatch.Value)
    stringToLocalize = Replace(stringToLocalize, objMatch.Value, strToReplace)
  Next

  mdm_LocalizeString = stringToLocalize
END FUNCTION  



%>
