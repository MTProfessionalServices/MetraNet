<%    
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2005 by MetraTech Corporation
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
' NAME        : AccountLib.asp
' DESCRIPTION	: Account Creation Functions
' AUTHOR	    : F.Torres, Kevin A. Boucher
' VERSION	    : Updated in Kona
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
CONST MAM_ACCOUNT_HIERARCHY_ROOT_ID = 1 
 
PUBLIC CONST AccountCreationService_ERROR_MAPPING_ALREADY_EXIST=-501284862 

PUBLIC CONST BILLING_CYCLE_NAME_MONTHLY       = "MONTHLY"
PUBLIC CONST BILLING_CYCLE_NAME_ON_DEMAND     = "ON-DEMAND"   ' It does not exist in 3.0 last days
PUBLIC CONST BILLING_CYCLE_NAME_DAILY         = "DAILY"
PUBLIC CONST BILLING_CYCLE_NAME_WEEKLY        = "WEEKLY"
PUBLIC CONST BILLING_CYCLE_NAME_BI_WEEKLY     = "BI-WEEKLY"
PUBLIC CONST BILLING_CYCLE_NAME_SEMI_MONTHLY  = "SEMI-MONTHLY"
PUBLIC CONST BILLING_CYCLE_NAME_QUARTERLY     = "QUARTERLY"
PUBLIC CONST BILLING_CYCLE_NAME_ANNUALLY      = "ANNUALLY"
PUBLIC CONST BILLING_CYCLE_NAME_SEMIANNUALLY      = "SEMI-ANNUALLY"

PRIVATE CONST BILLING_CYCLE_BIWEEKLY_COMBOXBOX_INDEX_FORMAT = "month=[MONTH],Day=[DAY],Year=[YEAR]," ' This is an internal index format. Do not need to be localized at all.

CONST CREDITORACH      = "1"
CONST CASHORCHECK      = "2"

' Set current account type
PUBLIC FUNCTION mam_Account_SetSubscriberAccountType()
  If Len(mdm_UIValue("AccountType")) Then
    Service("AccountType").Value = mdm_UIValueDefault("AccountType", "IndependentAccount")
  End If
  mam_Account_SetSubscriberAccountType = TRUE
END FUNCTION

FUNCTION mam_Account_LoadAccountStatusEnumTypeForUpdate()

		Dim objNewAccountStatusEnumType
		
		Set objNewAccountStatusEnumType = mdm_CreateObject(CVariables)
		
		'Select Case UCase(Service("ACCOUNTSTATUS").NonLocalizedValue)		
		'		Case "AC", "SU" , "ACTIVE", "SUSPENDED"  
				
   	objNewAccountStatusEnumType.Add "Active"   ,"AC",,,"Active" ' -- We need the current state
  	objNewAccountStatusEnumType.Add "Suspended","SU",,,"Suspended" ' -- We need the current state
    objNewAccountStatusEnumType.Add "Closed"   ,"CL",,,"Closed" ' -- We need the current state
    
		'End Select
		
	  Set Service("ACCOUNTSTATUS").EnumType.Entries = mdm_CreateObject(MSIXEnumTypeEntries) ' Create a blank enum type
    Service("ACCOUNTSTATUS").EnumType.Entries.Populate objNewAccountStatusEnumType
		
		mam_Account_LoadAccountStatusEnumTypeForUpdate = TRUE
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_Account_UpdateBiWeeklyProperties()
' DESCRIPTION	: The UI returns the biweekly information into the service property BiWeeklyLabelInfo; this property
'               value will contains the info in this format month=[MONTH];Day=[DAY];Year=[YEAR]; we need to decode that
'               and update the right property before we meter...
' PARAMETERS	:
' RETURNS		  : TRUE if ok
PUBLIC FUNCTION mam_Account_UpdateBiWeeklyProperties() ' As Boolean

    Dim objVariables
    Dim objParser
    
    Set objVariables = mdm_CreateObject(CVariables)
    
    If Service("usagecycletype").EnumType.Entries.Exist("Bi-weekly") Then
    
      If(Service("usagecycletype") = Service("usagecycletype").EnumType("Bi-weekly"))Then
      
          If(objVariables.LoadSet(CStr(Service("BiWeeklyLabelInfo"))))Then ' Decode the string month=[MONTH];Day=[DAY];Year=[YEAR]
          
              Service("StartMonth")  = objVariables("Month")
              Service("StartDay")    = objVariables("Day")
              Service("StartYear")   = objVariables("Year")
          End If
      End If
    End If
    mam_Account_UpdateBiWeeklyProperties = TRUE
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_Account_SetBiWeeklyLabelInfo
' DESCRIPTION	: The BiWeeklyLabelInfo property is a dynamic property of the service that we use to stored and present
'               the BiWeekLy Info in a string. In the dialog DefaultDialogUpdateAccount we need to store in this
'               property the internal value grouping the startmonth, startday and startyear in a specific format
'               BILLING_CYCLE_BIWEEKLY_COMBOXBOX_INDEX_FORMAT!
' PARAMETERS	:
' RETURNS		  : TRUE if ok
PUBLIC FUNCTION mam_Account_SetBiWeeklyLabelInfo() ' As Boolean
  
    Dim objPreProcessor
    
    Set objPreProcessor = mdm_CreateObject(CPreProcessor)
    
    objPreProcessor.Add "MONTH" , "" & Service("StartMonth") 
    objPreProcessor.Add "DAY"   , "" & Service("StartDay")
    objPreProcessor.Add "YEAR"  , "" & Service("StartYear") 
    
    ' Set in the for each item the value we need to metered    
    Service("BiWeeklyLabelInfo") = objPreProcessor.Process(BILLING_CYCLE_BIWEEKLY_COMBOXBOX_INDEX_FORMAT)                    
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_SetGoodEnumTypeValueToUsageCycleType()
'
' DESCRIPTION	: UsageCycleType Combo box should not be populate with the all content of the enum type BillingCycle but with
'               A sub set defined in Config\UsageServer\BillingCycle.xml. This function do it;
'			          We need to create a new instance rather that modify the current one because we modify the current we alter the instance in the cache
'			          then the instance is altered for every body...
' PARAMETERS	:
' RETURNS		  : TRUE if ok
PUBLIC FUNCTION mam_Account_SetGoodEnumTypeValueToUsageCycleType() ' As Boolean
  
    Dim objBillingCycleType
      
    mam_Account_GetBillingCycleValues "", "", objBillingCycleType, Empty, Empty
        
	  ' Create a new blank enum type
	  Set Service("UsageCycleType").EnumType.Entries	= mdm_CreateObject(MSIXEnumTypeEntries)
    
    Service("UsageCycleType").EnumType.Entries.Populate objBillingCycleType
	
    ' StartMonth is an enum type so it is loaded at the initialization of the dialog, but we do not want the  enum type value
    ' we want the value pull out from the billing cycle object...
    Service("StartMonth").EnumType.Entries.Clear

    Service.Properties("usagecycletype").Required = TRUE    
    mam_Account_SetGoodEnumTypeValueToUsageCycleType = TRUE
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_Account_SetBillingCycleEnumType
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PUBLIC FUNCTION mam_Account_SetBillingCycleEnumType() '  As Boolean

    Dim objItem ' As CVariables
    Dim strStartMonthEnumerator 

  	Select Case UCase(Service.Properties("usagecycletype").Value)
	   
  	  	Case BILLING_CYCLE_NAME_ON_DEMAND        
        Case BILLING_CYCLE_NAME_DAILY
                  
        Case BILLING_CYCLE_NAME_WEEKLY
         
            mam_Account_GetBillingCycleValues "Weekly","NamedDay" , objItem, Empty, Empty
            Service("DayOfWeek").AddValidListOfValues objItem
            
        Case BILLING_CYCLE_NAME_BI_WEEKLY
        
            ' Get the valid list of value for the combo box month
            mam_Account_GetBillingCycleValues "Bi-weekly" , "Month" , objItem, Empty, Empty
            Service("BiWeeklyLabelInfo").AddValidListOfValues objItem
                                
        Case BILLING_CYCLE_NAME_MONTHLY
          
            mam_Account_GetBillingCycleValues "Monthly" , "Day" , objItem, Empty, Empty
            
            if IsEmpty(Service("DayOfMonth").Value) then
              Service("DayOfMonth").Value = 31
            end if
            
            Service("DayOfMonth").AddValidListOfValues objItem                               
            
        Case BILLING_CYCLE_NAME_SEMI_MONTHLY
               
            mam_Account_GetBillingCycleValues "Semi-Monthly" , "Day" , objItem, Empty, Empty
            Service("FirstDayOfMonth").AddValidListOfValues objItem
            Service("SecondDayOfMonth").AddValidListOfValues objItem
            
        Case BILLING_CYCLE_NAME_QUARTERLY
        
          ' Get the valid list of value for the combo box month
            mam_Account_GetBillingCycleValues "Quarterly" , "Month" , objItem, Empty, Empty
            Service("StartMonth").AddValidListOfValues objItem
                
            ' Get the valid list of days for the current selected month
            
            ' First we need to retreive the month but not as the enum type value but enumerator because the fonction 
            ' mam_Account_GetBillingCycleValues use it to compare!            
            strStartMonthEnumerator = Service("StartMonth").EnumType.Entries(Service("StartMonth").Value).Name
            
            ' Add the function mam_Account_GetBillingCycleValues, for the billing cycle : Bi-weekly
            ' month=Service("StartMonth") to return the list of days available...
            mam_Account_GetBillingCycleValues "Quarterly","Day" ,  objItem, "Month", strStartMonthEnumerator 
            Service("StartDay").AddValidListOfValues objItem                                 
        
        Case BILLING_CYCLE_NAME_ANNUALLY
        
          ' Get the valid list of value for the combo box month
            mam_Account_GetBillingCycleValues "Annually" , "Month" , objItem, Empty, Empty
            Service("StartMonth").AddValidListOfValues objItem
                
            ' Get the valid list of days for the current selected month
            
            ' First we need to retreive the month but not as the enum type value but enumerator because the fonction 
            ' mam_Account_GetBillingCycleValues use it to compare!            
            strStartMonthEnumerator = Service("StartMonth").EnumType.Entries(Service("StartMonth").Value).Name
            
            ' Add the function mam_Account_GetBillingCycleValues, for the billing cycle : Bi-weekly
            ' month=Service("StartMonth") to return the list of days available...
            mam_Account_GetBillingCycleValues "Annually","Day" ,  objItem, "Month", strStartMonthEnumerator 
            Service("StartDay").AddValidListOfValues objItem  
         
         Case BILLING_CYCLE_NAME_SEMIANNUALLY
        
          ' Get the valid list of value for the combo box month
            mam_Account_GetBillingCycleValues "Semi-Annually" , "Month" , objItem, Empty, Empty
            Service("StartMonth").AddValidListOfValues objItem
                
            ' Get the valid list of days for the current selected month
            
            ' First we need to retreive the month but not as the enum type value but enumerator because the fonction 
            ' mam_Account_GetBillingCycleValues use it to compare!            
            strStartMonthEnumerator = Service("StartMonth").EnumType.Entries(Service("StartMonth").Value).Name
            
            ' Add the function mam_Account_GetBillingCycleValues, for the billing cycle : Bi-weekly
            ' month=Service("StartMonth") to return the list of days available...
            mam_Account_GetBillingCycleValues "Semi-Annually","Day" ,  objItem, "Month", strStartMonthEnumerator 
            Service("StartDay").AddValidListOfValues objItem                 
        
  	End Select
    mam_Account_SetBillingCycleEnumType = TRUE    
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_Account_SetDynamicEnumType
' DESCRIPTION	:
' PARAMETERS	:
' RETURNS		  :
PUBLIC FUNCTION mam_Account_SetDynamicEnumType() ' As Boolean

    ' -- Set on the on fly some valid list of value to populate the comboboxes --
    Service("Name_Space").AddValidListOfValues  "__GET_PRESENTATION_NAME_SPACE_LIST__",,,,mam_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH")    

    If(Not Service.Properties.IsProductView())Then
      Service("transactioncookie") = "" '  Must be set to string
    End If
    
    mam_Account_ChangeCurrencyTypeToEnumType()
        
    ' MAM 2.0 This enum type return empty when the value is empty rather that the first
    ' enum type value which is the MDM enum type default behavior
    If Service.Properties.Exist("Country") Then
      Service("Country").EnumTypeSupportEmpty = TRUE
      Service("Country").EnumType.Entries.Add "",""," " ' Add a blank value
    End If
    
    If Service.Properties.Exist("LoginApplication") Then
      Service("LoginApplication").EnumTypeSupportEmpty = TRUE
      Service("LoginApplication").EnumType.Entries.Add "",""," " ' Add a blank value
    End If    
    mam_Account_SetDynamicEnumType = TRUE
END FUNCTION

PUBLIC FUNCTION mam_Account_ChangeCurrencyTypeToEnumType()
    Service("Currency").SetPropertyType "ENUM","Global/SystemCurrencies","SystemCurrencies"
    mam_Account_ChangeCurrencyTypeToEnumType = TRUE
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: NotifySubscriberWithEMail()
' DESCRIPTION	: The function may raise an error too. If the strSubscriberEMailAddress returns true.
' PARAMETERS	:
' RETURNS		  : TRUE if ok
PUBLIC Function mam_AddAccountEMailNotification(strLanguage) ' As Boolean                                 

  Dim strTemplateFileName
  
  strTemplateFileName = mam_GetMAMFolder() & "\" & mam_GetDictionary("ADD_ACCOUNT_EMAIL_TEMPLATE") ' " Home site color bug
  
  Service.Properties.Add "Time" , "String" , 255, False, FrameWork.MetraTimeGMTNow() ' Add this for the email template
  Service.Properties("Time").Caption = "Dummy Time"
  
  On Error Resume Next
  Service.SendTemplatedEMail strTemplateFileName , Service("EMAIL"),,,strLanguage
  mam_AddAccountEMailNotification = CBool(Err.Number=0)
  On Error Goto 0
  
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Paint
' PARAMETERS		  :
' DESCRIPTION 		: This event is shared by DefaultDialogAddAccount.asp and DefaultDialogUpdateAccount.asp
' RETURNS		      : Return TRUE if ok else FALSE
PUBLIC FUNCTION AddUpdateAccount_FormPaint(EventArg) ' As Boolean

  	Dim varBillingCycleHTMLSubDialog
  	Dim strTemplateFileName
  	Dim strTemplateFolder
    Dim lngRenderFlag, objTextFile

    Service("dayofmonth").Required = FALSE
    Service("dayofweek").Required = FALSE
    Service("firstdayofmonth").Required = FALSE        
    Service("seconddayofmonth").Required = FALSE
    Service("startmonth").Required = FALSE
    Service("startday").Required = FALSE
    Service("startyear").Required = FALSE
    Service("BiWeeklyLabelInfo").Required = FALSE
    
    ' Do not render the <FORM>  for a sub template this will raise an rendering error
    lngRenderFlag = eMSIX_RENDER_FLAG_DEFAULT_VALUE-eMSIX_RENDER_FLAG_RENDER_FORM_TAG
    
    varBillingCycleHTMLSubDialog  = ""
    strTemplateFolder             = mdm_GetDialogPhysicalPath()    

	  ' Find the Usage Cycle Sub Dialog According the value of the property usagecycletype
  	Select Case UCase(Service.Properties("usagecycletype").Value)
	
  	  	Case BILLING_CYCLE_NAME_ON_DEMAND
            ' We do nothing there is not extra values
            
        Case BILLING_CYCLE_NAME_DAILY
            ' We do nothing there is not extra values

        Case BILLING_CYCLE_NAME_WEEKLY
            strTemplateFileName = strTemplateFolder & "\SubTemplate\Subscriber.AccountInformation.BillingCycle.Weekly" & GetBillingCycleSubTemplateMode() & ".htm"
            Service("dayofweek").Required = TRUE            
            
        Case BILLING_CYCLE_NAME_MONTHLY
            strTemplateFileName = strTemplateFolder & "\SubTemplate\Subscriber.AccountInformation.BillingCycle.Monthly" & GetBillingCycleSubTemplateMode() & ".htm"
            Service("dayofmonth").Required = TRUE
            
        Case BILLING_CYCLE_NAME_BI_WEEKLY
            strTemplateFileName = strTemplateFolder & "\SubTemplate\Subscriber.AccountInformation.BillingCycle.BiWeekly" & GetBillingCycleSubTemplateMode() & ".htm"
            Service("BiWeeklyLabelInfo").Required = TRUE

        Case BILLING_CYCLE_NAME_SEMI_MONTHLY
            strTemplateFileName = strTemplateFolder & "\SubTemplate\Subscriber.AccountInformation.BillingCycle.SemiMthly" & GetBillingCycleSubTemplateMode() & ".htm"
            Service("firstdayofmonth").Required  = TRUE
            Service("seconddayofmonth").Required = TRUE            
            
        Case BILLING_CYCLE_NAME_QUARTERLY
            strTemplateFileName = strTemplateFolder & "\SubTemplate\Subscriber.AccountInformation.BillingCycle.Quarterly" & GetBillingCycleSubTemplateMode() & ".htm"
            Service("startmonth").Required = TRUE
            Service("startday").Required   = TRUE
            
        Case BILLING_CYCLE_NAME_ANNUALLY
            strTemplateFileName = strTemplateFolder & "\SubTemplate\Subscriber.AccountInformation.BillingCycle.Annually" & GetBillingCycleSubTemplateMode() & ".htm"
            Service("startmonth").Required = TRUE
            Service("startday").Required   = TRUE            
  	End Select

	  If(Len(strTemplateFileName))Then
	      Set objTextFile = mdm_CreateObject(CTextFile)
        Service.RenderHTML objTextFile.LoadFile(strTemplateFileName), varBillingCycleHTMLSubDialog, request.serverVariables("URL"), CLng(lngRenderFlag)
  	End If
    EventArg.HTMLRendered = Replace(Cstr(EventArg.HTMLRendered ),"[USAGE_CYCLE_TYPE_SUB_DIALOG]",CStr(varBillingCycleHTMLSubDialog))
	  AddUpdateAccount_FormPaint = TRUE
END FUNCTION

PRIVATE FUNCTION GetBillingCycleSubTemplateMode()
    If(UCase(Form("AddUpdateMode")) = "UPDATE")Then
        GetBillingCycleSubTemplateMode = ".Update"
    End If      
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : mam_ClearContact
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PUBLIC FUNCTION mam_ClearContact(Service) ' As Boolean

  Service.Properties("lastname") 			            = ""
  Service.Properties("middleinitial") 			      = ""  
	Service.Properties("firstname") 	              = ""
  Service.Properties("address1") 	                = ""
  Service.Properties("address1") 	                = ""
  Service.Properties("address2") 	                = ""
  Service.Properties("address3") 	                = ""
  Service.Properties("City") 	                    = ""
  Service.Properties("state") 	                  = ""
  Service.Properties("zip") 	                    = ""
  Service.Properties("country") 	                = ""
  Service.Properties("email") 	                  = ""
  Service.Properties("company") 	                = ""
  Service.Properties("phonenumber") 	            = ""
  Service.Properties("facsimiletelephonenumber")  = ""
  Service.Properties("Country")                   = ""
END FUNCTION    

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : mam_Account_CheckBillingCycleRule
' PARAMETERS		  :
' DESCRIPTION 		: Apply some rule on the billing cycle data before we send to the pipe line.
'                   If one rule fails the function return FALSE and the error message in the EventArg object.
' RETURNS		      :
PUBLIC FUNCTION mam_Account_CheckBillingCycleRule(EventArg) ' As Boolean
    
    mam_Account_CheckBillingCycleRule = FALSE
             
  	Select Case UCase(Service.Properties("usagecycletype").Value)
	   
        ' No rules for these guys...
  	  	'Case UCase(Service("usagecycletype").EnumType("On-demand")) ' It does not exist in 3.0 last days
        'Case UCase(Service("usagecycletype").EnumType("Daily"))
        'Case UCase(Service("usagecycletype").EnumType("Weekly"))
        'Case UCase(Service("usagecycletype").EnumType("Bi-weekly"))
        'Case UCase(Service("usagecycletype").EnumType("Monthly"))
        
        Case BILLING_CYCLE_NAME_SEMI_MONTHLY
          
            ' Rule 1
            If(Service("FirstDayOfMonth")>=Service("SecondDayOfMonth"))Then
            
                EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1002")
                Exit Function
            End If
            
            ' Rule 2
            If(Not mtvblib_IsInRange(Service("FirstDayOfMonth"),1,27))Then
            
                EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1020")
                Exit Function
            End If
            
            ' Rule 3
            If(Not mtvblib_IsInRange(Service("SecondDayOfMonth"),2,31))Then
            
                EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1020")
                Exit Function
            End If          
          
        'Case UCase(Service("usagecycletype").EnumType("Quarterly"))
        'Case Service("usagecycletype").EnumType("Annually")
        
  	End Select
    
    mam_Account_CheckBillingCycleRule = TRUE
     
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : mam_Account_AddDynamicProperties
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PUBLIC FUNCTION mam_Account_AddDynamicProperties() ' As Boolean
        
    If(Not Service.Properties.Exist("EMailNotification"))Then
        mdm_GetDictionary().Add "LOGINVALIDATEDMESSAGE", ""
    
        ' Add internal property that use to build the UI logic. these property will not be metered                    
        Service.Properties.Add "EMailNotification"        , "Boolean" , 00 , False, mam_GetDictionary("DEFAULT_DEFAULT_ADD_ACCOUNT_EMAIL_NOTIFICATION")  ' Add the EMail Notification on the fly
        Service.Properties.Add "PrimaryAlias"             , "String"  , 32 , False, ""    ' Add the EMail Notification on the fly
        Service.Properties.Add "MappingAddedSucceed"      , "String"  , 255, False, ""    ' We used this property to store the result of the AddPrimaryAlias() to give it to the next dialog...
        Service.Properties.Add "EMailNotificationStatus"  , "String"  , 255, False, ""    ' We used this property to store the result of the AddPrimaryAlias() to give it to the next dialog...
        
        Service.Properties.Add "UIUpdateMode"             , "Boolean" , 00 , False, FALSE  ' Add or update UI mode.
        Service.Properties.Add "ConfirmedPassWord"        , "String"  , 255, False, Empty
        Service.Properties.Add "BiWeeklyLabelInfo"        , "String"  , 255, False, Empty    
        Service.Properties.Add "NameSpaceDescription"     , "String"  , 255, False, Empty    
 
        Service("EMailNotification").Caption        = "dummy" ' to avoid localization error logged in mtlog.txt
        Service("PrimaryAlias").Caption             = "dummy" ' to avoid localization error logged in mtlog.txt
        Service("MappingAddedSucceed").Caption      = "dummy" ' to avoid localization error logged in mtlog.txt
        Service("EMailNotificationStatus").Caption  = "dummy" ' to avoid localization error logged in mtlog.txt
        
        Service("UIUpdateMode").Caption             = "dummy" ' to avoid localization error logged in mtlog.txt
        Service("ConfirmedPassWord").Caption        = "dummy" ' to avoid localization error logged in mtlog.txt
        Service("BiWeeklyLabelInfo").Caption        = "dummy" ' to avoid localization error logged in mtlog.txt
        Service("NameSpaceDescription").Caption     = "dummy" ' to avoid localization error logged in mtlog.txt
    End If
        
    mam_Account_AddDynamicProperties = TRUE
    
END FUNCTION

' -------------------------------------------------------------------------------- --------------------------------------------------------------------------------
' FUNCTION      : mam_Account_GetBillingCycleValues
' PARAMETERS    :
'                   strBillingCycleType - Values : montly, weekly, bi-weekly,... See the enum type CycleType.
'                   strPointProperty    - The property we want to use : NamedDay, Dat, Month. See file Config\UsageServer\billingcycles.xml.
'                   objValues           - A variant which intialized as a CVariables and which will be filled with the result. (Collection of name/value).
'                   strSyncPropertyName - The synchronized property name. See description.
'                   strSyncPropertyValue- The synchronized property value. See description.
'
' DESCRIPTION   : Pull out information from the Billing Cycle object.
'                 Syncrhonized Property : See file Config\UsageServer\billingcycles.xml first, you can even talk to TRAVIS.
'                 In the case Bi-Weekly, we must first fill the month combo box with the all the closing point month.
'                 Then according to the month we have selected in the combox box we must pull out from the billing cycle Bi-Weekly
'                 and say for the month of january, the list of valid days. In that case strSyncPropertyName="Month" and strSyncPropertyValue="january".
'
'                 See TRAVIS if you have problem to understand his design.
'
' RETURNS       : TRUE if ok.
PUBLIC Function mam_Account_GetBillingCycleValues( strBillingCycleType, strPointProperty , objValues, strSyncPropertyName, strSyncPropertyValue ) ' As Boolean

    'On Error GoTo ErrMgr

    Dim objBillingCycle            ' As Variant
    Dim objTimePoint               ' As Variant
    Dim strHTMLOptionTag           ' As String
    Dim objMTBillingCycleConfig    ' As Variant 'New MTBillingCycleConfig
    Dim strValue                   ' As String
    Dim i                          ' As Long
    Dim booOK                      ' As Boolean
    Dim varToday                   ' As Variant
    Dim varStartDate               ' As Variant
    Dim varEndDate                 ' As Variant   
    DIm objPreProcessor            ' As CPreProcessor
    Dim strName                    ' As String
    Dim strCaption
    Dim strLabel
    Dim lngMaxMonth    
    Dim lngMaxMonthQuarterly
    
    lngMaxMonth           = 31
    lngMaxMonthQuarterly  = 27 ' ask Travis
    
    Set objValues = mdm_CreateObject(CVariables) ' Alloc the collection to return the value
               
    Set objMTBillingCycleConfig = CreateObject("BillingCycleConfig.MTBillingCycleConfig.1")
    objMTBillingCycleConfig.Init

    ' I do a loop because in the very first release of the object, the item property support only index and not the string name!
    For Each objBillingCycle In objMTBillingCycleConfig

        If (Len(strBillingCycleType)) Then ' Get information for the billing cycly strBillingCycleType
        
            If (UCase(objBillingCycle.CycleType) = UCase(strBillingCycleType)) Then
            
                For Each objTimePoint In objBillingCycle
                
                    If (Len(strSyncPropertyName)) Then
                    
                        booOK = UCase(Service.Tools.CallByName(objTimePoint, strSyncPropertyName )) = UCase(strSyncPropertyValue)
                    Else
                        booOK = True ' no synchronisation property
                    End If
                    
                    If (booOK) Then
                        
                        Select Case UCase(strBillingCycleType)
                        
                            Case BILLING_CYCLE_NAME_BI_WEEKLY

                                varToday = CDate(FrameWork.MetraTimeGMTNow())
                                objBillingCycle.CalculateClosestInterval objTimePoint, varToday, varStartDate, varEndDate
                                
                                Set objPreProcessor = mdm_CreateObject(CPreProcessor)
                                
                                objPreProcessor.Add "END_DATE"    ,Service.Tools.Format(varEndDate, mam_GetDictionary("DATE_FORMAT")) 
                                objPreProcessor.Add "START_DATE"  ,Service.Tools.Format(varStartDate, mam_GetDictionary("DATE_FORMAT")) 

                                objPreProcessor.Add "LABEL"       ,mam_Account_BillingCycle_LocalizeEnumType("BI-WEEKLY_LABEL",objTimePoint.Label) 
                                objPreProcessor.Add "MONTH"       ,objTimePoint.month
                                objPreProcessor.Add "DAY"         ,objTimePoint.day
                                objPreProcessor.Add "NAMEDDAY"    ,objTimePoint.NamedDay
                                objPreProcessor.Add "SECONDDAY"   ,objTimePoint.SecondDay
                                objPreProcessor.Add "YEAR"        ,objTimePoint.Year
                                
                                strCaption  = objPreProcessor.Process(mam_GetDictionary("BILLING_CYCLE_BI_WEEKLY_COMBOX_BOX_FORMAT"))
                                strValue    = objPreProcessor.Process(BILLING_CYCLE_BIWEEKLY_COMBOXBOX_INDEX_FORMAT) ' Set in the for each item the value we need to metered
                                
                                objValues.Add objTimePoint.Label,strValue,,,strCaption
                            Case Else
                                'If( UCase(strBillingCycleType)="WEEKLY")Then
                                'end if

                                strValue    = Service.Tools.CallByName(objTimePoint, strPointProperty)
                                
                                If(UCase(strBillingCycleType)=BILLING_CYCLE_NAME_QUARTERLY)Then
                                    lngMaxMonth = lngMaxMonthQuarterly
                                End If                  
                                                               
                                If(UCase(strBillingCycleType)="QUARTERLY")And(UCase(strPointProperty)="DAY")Then                                
                                    ' In the case of Quaterly property Month of the day there is no localization
                                    ' If strSyncPropertyName is defined this mean we are trying to retreive the list of day
                                    ' for the current month...List ofday 1,2,3..31 There is no localization.
                                    ' I did that to avoid a localization error in the log...
                                Else
                                    strCaption  = mam_Account_BillingCycle_LocalizeEnumType(strBillingCycleType,strValue)
                                End If                                                                    
                                objValues.Add strValue, strValue,,, strCaption
                        End Select
                        
                    End If
                Next
                Exit For
            End If
        Else
             ' strBillingCycleType is empty string this mean just return the billing cycle name/id
             strCaption = mam_Account_BillingCycle_LocalizeEnumType("BILLINGCYCLE",objBillingCycle.CycleType)
             objValues.Add objBillingCycle.CycleType, objBillingCycle.CycleType ,,, strCaption
        End If
    Next
    
    Select Case UCase(strBillingCycleType)

        ' Case if we must use all the days of the month
	      Case BILLING_CYCLE_NAME_MONTHLY, BILLING_CYCLE_NAME_BI_WEEKLY, BILLING_CYCLE_NAME_SEMI_MONTHLY, BILLING_CYCLE_NAME_QUARTERLY, BILLING_CYCLE_NAME_ANNUALLY, BILLING_CYCLE_NAME_SEMIANNUALLY
        
            If (objValues.Count = 1) Then
            
                If (CStr(objValues(1).Value) = CStr(0)) Then
                
                    objValues.Remove 1
                    For i = 1 To lngMaxMonth
                    
                        objValues.Add CStr(i), i
                    Next
                End If
            End If
    End Select
    mam_Account_GetBillingCycleValues = True
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : UpdateAccountCreation
' PARAMETERS		  :
'                     objAccountMXISProperties    - Any instance of MSIXProperties that contains AccountCreation structure and value 
'                     strActionTypeEnumTypeValue  - contact, account, both
' DESCRIPTION 		: Update the account
' RETURNS		      :
PUBLIC FUNCTION UpdateAccountCreation(EventArg,objAccountMXISProperties, strActionTypeEnumTypeValue) ' As Boolean
    
  Dim AccountService
  Dim strServiceMsixDefFile
  
  UpdateAccountCreation = FALSE
  strServiceMsixDefFile = mam_GetAccountCreationMsixdefFileName()
  Set AccountService    = mdm_CreateObject(MSIXHandler_PROG_ID)
  
  Set AccountService.SessionContext = Session(MDM_FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME)
  Set AccountService.Policy         = Session(MDM_FRAMEWORK_SECURITY_SECURITY_POLICY_SESSION_NAME)
  
  If(AccountService.Initialize(strServiceMsixDefFile,,mdm_GetSessionVariable("mdm_APP_LANGUAGE"),mdm_GetSessionVariable("mdm_APP_FOLDER"),mdm_GetMDMFolder(),mdm_InternalCache))Then

      ' Make sure unset enumtypes do not get a default value
      Call mam_AccountEnumTypeSupportEmpty(AccountService.Properties)

      If(objAccountMXISProperties.CopyTo(AccountService.Properties))Then
               
          AccountService.Properties("Operation").Value = AccountService.Properties("Operation").EnumType.Entries("Update").Value
          AccountService.Properties("ActionType").value = AccountService.Properties("ActionType").EnumType.Entries(strActionTypeEnumTypeValue).Value
                              
          'CR 13510
          AccountService.Properties("AncestorAccountID") = empty
          AccountService.Properties("AccountStartDate") = empty
          AccountService.Properties("Hierarchy_StartDate") = empty
          AccountService.Properties("Hierarchy_EndDate") = empty
          
                    
          mam_Account_DoNotMeterAccountStateInfo AccountService
                    
          On Error Resume Next
          AccountService.Meter TRUE
          If(Err.Number)Then
          
              EventArg.Error.Save Err
              AccountService.Log EventArg.Error.ToString,eLOG_ERROR
          Else
              UpdateAccountCreation = TRUE
          End If
          On Error Goto 0
      End If          
  End If
  
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_Account_CheckIfEMailIsValid
' DESCRIPTION	: Valid the accout email empty. email is regarded as valid.
' PARAMETERS	:
' RETURNS		  :
PUBLIC FUNCTION mam_Account_CheckIfEMailIsValid(EventArg) ' As Boolean

      mam_Account_CheckIfEMailIsValid = TRUE ' Default value is TRUE
      If(Len(Trim(Service("EMail"))))Then
      
          If (Not Service.Tools.EMailAddressValid(Service("EMail"))) Then
          
              EventArg.Error.Description = FrameWork.GetHTMLDictionaryError("MAM_ERROR_1000")
              mam_Account_CheckIfEMailIsValid = FALSE
          End If
      End If
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: mam_Account_BillingCycle_LocalizeEnumType
' DESCRIPTION	: Localize some of the combo box entry of billing cycle but not all some are integer like day of the month
' PARAMETERS	:
' RETURNS		  :
PRIVATE FUNCTION mam_Account_BillingCycle_LocalizeEnumType(strBillingCycleType,strValue) ' As string
    Dim strFQN
    Dim varLocalization
    Dim booDoIt
    
    booDoIt = FALSE
    
    Select Case UCase(strBillingCycleType)
        Case "BILLINGCYCLE" :
              strFQN  = "metratech.com/billingcycle/UsageCycleType/"    & strValue
              booDoIt = TRUE
        Case "WEEKLY" :
              strFQN  = "Global/DayOfTheWeek/"                          & strValue
              booDoIt = TRUE
        Case "QUARTERLY" :
              strFQN  = "Global/MonthOfTheYear/"                        & strValue
              booDoIt = TRUE              
        Case "BI-WEEKLY_LABEL"
              strFQN  = "metratech.com/billingcycle/Bi-weekly/label/"    & strValue
              booDoIt = TRUE
    End Select
    
    If(booDoIt)Then
        Service.Tools.GetLocalizedString MAM().CSR("Language"), strFQN, varLocalization
        If(Len(Cstr(varLocalization))=0)Then
            varLocalization = "{VBS-NL}" & strValue
        End If
        mam_Account_BillingCycle_LocalizeEnumType = varLocalization
    Else
        mam_Account_BillingCycle_LocalizeEnumType = strValue        
    End If
    
END FUNCTION

' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION		: PopulateDefaultAccountPricelist
' DESCRIPTION	: change DEFAULTACCOUNTPRICELIST property to an ENUM and populate from prodcat objects
' PARAMETERS	:
' RETURNS		  :
PUBLIC FUNCTION PopulateDefaultAccountPricelist()
    Dim objDyn
    Dim objMTProductCatalog  
    Dim rowset
    Dim strValues
    Dim CurrencyFilter
    
    If Service.Properties.Exist("Currency") and Service.Properties.Exist("PRICELIST") Then
      Set objDyn              = mdm_CreateObject(CVariables)
      Set objMTProductCatalog = GetProductCatalogObject()

      Set CurrencyFilter = Server.CreateObject(MTFilter)
      CurrencyFilter.Add "CurrencyCode", MT_OPERATOR_TYPE_EQUAL, Service.Properties("Currency").Value
      CurrencyFilter.Add "Type", MT_OPERATOR_TYPE_EQUAL, PRICELIST_TYPE_REGULAR
      Set Rowset = objMTProductCatalog.FindPriceListsAsRowset(currencyFilter) ' Get all
      
      objDyn.Add mam_GetDictionary("TEXT_NO_DEFAULT_ACCOUNT_PRICELIST"), "", , , mam_GetDictionary("TEXT_NO_DEFAULT_ACCOUNT_PRICELIST")
      Do While not Rowset.EOF
      
        If Len(Rowset.value("nm_name")) Then objDyn.Add rowset.value("nm_name"), rowset.value("nm_name"), , , rowset.value("nm_name")
        Rowset.MoveNext
      Loop

      Service.Properties("PRICELIST").AddValidListOfValues objDyn
      Service.Properties("PRICELIST").Caption = mam_Getdictionary("TEXT_DEFAULT_ACCOUNT_PRICELIST")
      Service.properties("PRICELIST").EnumType.Entries(mam_GetDictionary("TEXT_NO_DEFAULT_ACCOUNT_PRICELIST")).value = mam_GetDictionary("TEXT_NO_DEFAULT_ACCOUNT_PRICELIST")
    End If
        
    PopulateDefaultAccountPricelist = TRUE
END FUNCTION

PRIVATE FUNCTION ClearPriceListIfValueIsNone(objPriceListEnumTypeBackUp)

   Service("PriceList").EnumTypeSupportEmpty = TRUE ' MAM v2.1
    
   If Service("PriceList").Value="" Or Service("PriceList").Value = mam_GetDictionary("TEXT_NO_DEFAULT_ACCOUNT_PRICELIST") Then
        
      Service("PriceList").Value = Empty                        ' Set to empty so the property is not metered.
   End If
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  IsAllContactInfoBlank
' PARAMETERS :  
' DESCRIPTION:
' RETURNS    :  
FUNCTION mam_Account_IsAllContactInfoBlank() ' As Boolean

  mam_Account_IsAllContactInfoBlank = FALSE

  If(Len(Service.Properties("city").Value))Then Exit Function
  If(Len(Service.Properties("state").Value))Then Exit Function
  If(Len(Service.Properties("zip").Value))Then Exit Function
  If(Len(Service.Properties("firstname").Value))Then Exit Function
  If(Len(Service.Properties("lastname").Value))Then Exit Function
  If(Len(Service.Properties("email").Value))Then Exit Function
  If(Len(Service.Properties("phonenumber").Value))Then Exit Function
  If(Len(Service.Properties("company").Value))Then Exit Function
  If(Len(Service.Properties("address1").Value))Then Exit Function
  If(Len(Service.Properties("address2").Value))Then Exit Function
  If(Len(Service.Properties("address3").Value))Then Exit Function
  If(Len(Service.Properties("country").Value))Then Exit Function 
  If(Len(Service.Properties("facsimiletelephonenumber").Value))Then Exit Function
  If(Len(Service.Properties("middleinitial").Value))Then Exit Function
    
  mam_Account_IsAllContactInfoBlank = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetAllContactInfoToEmpty
' PARAMETERS :
' DESCRIPTION:
' RETURNS    :  
FUNCTION mam_Account_EnableAllContactFields(booEnabled) ' As Boolean

  Service.Properties("city").Enabled      = booEnabled
  Service.Properties("state").Enabled     = booEnabled
  Service.Properties("zip").Enabled       = booEnabled
  Service.Properties("firstname").Enabled = booEnabled
  Service.Properties("lastname").Enabled  = booEnabled
  Service.Properties("email").Enabled     = booEnabled
  Service.Properties("phonenumber").Enabled = booEnabled
  Service.Properties("company").Enabled   = booEnabled
  Service.Properties("address1").Enabled  = booEnabled
  Service.Properties("address2").Enabled  = booEnabled
  Service.Properties("address3").Enabled  = booEnabled
  Service.Properties("country").Enabled   = booEnabled
  Service.Properties("facsimiletelephonenumber").Enabled = booEnabled
  Service.Properties("middleinitial").Enabled  = booEnabled
  
  mam_Account_EnableAllContactFields = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  SetAllContactInfoToEmpty
' PARAMETERS :
' DESCRIPTION:
' RETURNS    :  
FUNCTION mam_Account_SetAllContactInfoToEmpty() ' As Boolean

  Service.Properties("city").Value        = Empty
  Service.Properties("state").Value       = Empty
  Service.Properties("zip").Value         = Empty
  Service.Properties("firstname").Value   = Empty
  Service.Properties("lastname").Value    = Empty
  Service.Properties("email").Value       = Empty
  Service.Properties("phonenumber").Value = Empty
  Service.Properties("company").Value     = Empty
  Service.Properties("address1").Value    = Empty
  Service.Properties("address2").Value    = Empty
  Service.Properties("address3").Value    = Empty
  Service.Properties("country").Value     = Empty 
  Service.Properties("facsimiletelephonenumber").Value        = Empty
  Service.Properties("middleinitial").Value                   = Empty
  
  mam_Account_SetAllContactInfoToEmpty = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  mam_Account_SetToEmptyAllTheEmptyStringValue
' PARAMETERS :
' DESCRIPTION:
' RETURNS    :  
FUNCTION mam_Account_SetToEmptyAllTheEmptyStringValue() ' As Boolean

  Dim objProperty
  For Each objProperty In Service.Properties
  
    If (Not objProperty.Required) And (Len("" & objProperty.Value)=0) Then
    
      objProperty.Value = Empty
    End If
  Next
  mam_Account_SetToEmptyAllTheEmptyStringValue = TRUE  
END FUNCTION

FUNCTION mam_Account_UpDateMeteringAccordingIfThereIsOrNotContact()
    
    If(mam_Account_IsAllContactInfoBlank())Then ' Meter only Account Info
    
        Service.Properties("ActionType").value = Service("ActionType").EnumType.Entries("Account")
        mam_Account_SetAllContactInfoToEmpty ' so they will not be metered
    Else
        ' Meter Account And Contact Info
        Service.Properties("ActionType").value = Service("ActionType").EnumType.Entries("Both")
        mam_Account_CheckIfCountryIsEmptyStringBeforeMetering
    End If
    mam_Account_UpDateMeteringAccordingIfThereIsOrNotContact = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : mam_Account_CheckIfCountryIsEmptyStringBeforeMetering
' PARAMETERS :
' DESCRIPTION: Used by add account, update account and add contact dialog...
' RETURNS    : 
FUNCTION mam_Account_CheckIfCountryIsEmptyStringBeforeMetering()

  ' Here we have contact, if country is empty string we set it to Empty so it will not
  ' be metered, because blank is not a valid country enum type...
  If Len(Service.Properties("Country").Value)=0 Then Service.Properties("Country").Value = Empty
  mam_Account_CheckIfCountryIsEmptyStringBeforeMetering = TRUE

END FUNCTION

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : mam_Account_GetDefaultsFromTemlpate(lngFolderID)            '
' Description : Load the properties from the account template.  If no       '
'             : template exists for the folder, the template for the        '
'             : nearest ancestor will be used.                              '
'             : REQUIRES:  CAccountTemplateHelper.asp be included by        '
'             :            the calling page.                                '
' Inputs      : lngFolderID -- ID of the folder to get the template from    '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function mam_Account_GetDefaultsFromTemplate(lngFolderID)
  mam_Account_GetDefaultsFromTemplate = false
  
  'Check valid values, note sneaky use of "" to avoid using CStr on an empy var
  if isNumeric(lngFolderID) and len("" & lngFolderID) > 0 then
  
    'Don't apply when adding corporate accounts
    if CLng(lngFolderID) <> MAM_ACCOUNT_HIERARCHY_ROOT_ID then
      'Clear any template that might be in the session
      Call AccountTemplateHelper.Initialize(lngFolderID, Service.Properties("AccountType"))
      Set AccountTemplateHelper.MSIXHandler = Service
      Call AccountTemplateHelper.LoadTemplate()

      'Set the value for apply security policy
    'XXX  Service.Properties("ApplyDefaultSecurityPolicy").Value = AccountTemplateHelper.ApplyDefaultSecurityPolicy
    'XXX  Service.Properties("PayerAccount").Value               = mam_GetFieldIDFromAccountID(Service.Properties("PayerID").value)
    end if
  end if

  'Return success
  mam_Account_GetDefaultsFromTemplate = true
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PUBLIC FUNCTION mam_Account_ProcessFieldsID() ' As Boolean

    mam_Account_ProcessFieldsID = FALSE
    
    If Not FrameWork.DecodeFieldIDInMSIXProperty(Service("ANCESTORACCOUNT"),Service("ANCESTORACCOUNTID")) Then
    
        EventArg.Error.Number      = 1027
        EventArg.Error.Description = mam_GetDictionary("MAM_ERROR_1027")
        Exit Function
    End If
    
    If Not FrameWork.DecodeFieldIDInMSIXProperty(Service("PAYERACCOUNT"),Service("PAYERID")) Then
    
        EventArg.Error.Number      = 1028
        EventArg.Error.Description = mam_GetDictionary("MAM_ERROR_1028")
        Exit Function
    End If
        
    mam_Account_ProcessFieldsID = TRUE

END FUNCTION

PUBLIC FUNCTION mam_Account_DoNotMeterAccountStateInfo(oService)
    oService.Properties("AccountStartDate").Value = Empty         
    oService.Properties("AccountEndDate").Value  = Empty
    oService.Properties("AccountStatus").Flags   = oService.Properties("AccountStatus").Flags + eMSIX_PROPERTY_FLAG_SKIP_NEXT_METERING ' Because this is an enum type we cannot set it to Empty to not meter it.
    mam_Account_DoNotMeterAccountStateInfo       = TRUE
END FUNCTION    

PUBLIC FUNCTION mam_Account_CleanStatusReasonEnumTypeForAddingAccount()
    Service.Properties("StatusReason").EnumType.Entries.Remove "AccountTerminated" 
    Service.Properties("StatusReason").EnumType.Entries.Remove "AccountDeactivated" 
END FUNCTION    

PUBLIC FUNCTION mam_AccountEnumTypeSupportEmpty(properties)

  Dim prop
  For Each prop in properties
    If UCase(prop.PropertyType) = "ENUM"  or UCase(prop.PropertyType) = "BOOLEAN"  Then
      prop.EnumTypeSupportEmpty = TRUE
    End If
  Next

  mam_AccountEnumTypeSupportEmpty = TRUE
  
END FUNCTION  


%>
