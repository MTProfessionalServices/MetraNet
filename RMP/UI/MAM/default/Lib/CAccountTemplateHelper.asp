<%
' //==========================================================================
' //
' // Copyright 1998,2001 by MetraTech Corporation
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
' //==========================================================================

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' CAccountTemplateHelper.asp                                                '
' Contains definition for CAccountTemplateHelper class.  Also creates an    '
' instance of the class on page load.                                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public AccountTemplateHelper

'Create an instance of the template helper
Set AccountTemplateHelper = new CAccountTemplateHelper

const SESSIONS_PER_SET = 1

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Begin Class Definition                                                    '
Class CAccountTemplateHelper

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  'Begin Properties
   Private  m_sdk
   Private  m_whereabouts
   Private  m_AccountType

  
  ' TemplateExists -- Returns boolean indicating if a template exists for   '
  '                   the selected account                                  '
  Public Property Get TemplateExists()
    if session("ACCOUNT_TEMPLATE").AccountTemplate.ID = -1 then
      TemplateExists = false
    else
      TemplateExists = true
    end if
  End Property

  ' FolderID  --  ID of the folder being operated on
  Public Property Get FolderID()
    FolderID = Form("CAccountTemplate_FOLDERID")
  End Property
  
  Public Property Let FolderID(v)
    Form("CAccountTemplate_FOLDERID") = v
  End Property
  
  ' NoAncestorWithTemplate -- Returns true if no ancestors of this folder have templates
  ' HACK -- Get Carl to get parent name
  Public Property Get NoAncestorWithTemplate()
    NoAncestorWithTemplate = false
    on error resume next
    if CDate(session("ACCOUNT_TEMPLATE").AccountTemplate.DateCrt) = CDate("12:00:00am") then
      NoAncestorWithTemplate = true
    else
      NoAncestorWithTemplate = false
    end if
    on error goto 0
  End Property
  
  'AccountTemplate - Get the IMTYAAC::AccountTemplate from the MSIXAccountTemplate
  Public Property Get AccountTemplate()
    Set AccountTemplate = session("ACCOUNT_TEMPLATE").AccountTemplate
  End Property
  
  'MSIXAccountTemplate -- Get the MSIX account template object
  Public Property Get MSIXAccountTemplate()
    Set MSIXAccountTemplate = session("ACCOUNT_TEMPLATE")
  End Property
    
  'MSIXHandler - Set the MSIXHandler for the MSIXAccountTemplate
  Public Property Set MSIXHandler(v)
    Set session("ACCOUNT_TEMPLATE").MSIXHandler = v
  End Property
  
  Public Property Get MSIXHandler()
    Set MSIXHandler = session("ACCOUNT_TEMPLATE").MSIXHandler
  End Property
  
  'Name -- Name of the template
  Public Property Get Name()
    Name = session("ACCOUNT_TEMPLATE").Name
  End Property
  
  Public Property Let Name(v)
    session("ACCOUNT_TEMPLATE").Name = v
  End Property
    
  'Description -- Description for the template
  Public Property Get Description()
    Description = session("ACCOUNT_TEMPLATE").Description
  End Property
  
  Public Property Let Description(v)
    session("ACCOUNT_TEMPLATE").Description = v
  End Property
  
  'ApplyDefaultSecurityPolicy
  Public Property Get ApplyDefaultSecurityPolicy()
    ApplyDefaultSecurityPolicy = session("ACCOUNT_TEMPLATE").ApplyDefaultSecurityPolicy
  End Property
  
  Public Property Let ApplyDefaultSecurityPolicy(v)
    session("ACCOUNT_TEMPLATE").ApplyDefaultSecurityPolicy = v
  End Property
  
  'End Properties
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Begin Public Methods

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Sub         : Initialize(lngFolderID)                                   '
  ' Description : Set some basic properties for the dialog.  This should    '
  '             : only be called once per dialog.                           '
  ' Inputs      : lngFolderID -- ID of the folder                           '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Sub Initialize(lngFolderID, strAccountType)
    'Clear the session
    Set session("ACCOUNT_TEMPLATE") = nothing
    
    'Set Account Type
    m_AccountType = strAccountType
    
    'Store the folder id
    Form("CAccountTemplate_FOLDERID") = lngFolderID

    'Store the object in the session
    Set session("ACCOUNT_TEMPLATE") = GetMSIXAccountTemplate()

  End Sub
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : LoadTemplate()                                            '
  ' Description : Load the template for the account.                        '
  ' Inputs      : none                                                      '
  ' Outputs     : boolean                                                   '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function LoadTemplate()
    LoadTemplate = session("ACCOUNT_TEMPLATE").Load()  
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : ClearTemplate()                                           '
  ' Description : Clear the account template.                               '
  ' Inputs      : none                                                      '
  ' Outputs     : boolean                                                   '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function ClearTemplate()
    ClearTemplate = session("ACCOUNT_TEMPLATE").Clear()
  End Function 
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : SaveTemplate()                                            '
  ' Description : Save the changes to the account template.                 '
  ' Inputs      : none                                                      '
  ' Outputs     : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function SaveTemplate()
    SaveTemplate = session("ACCOUNT_TEMPLATE").Save(mam_GetHierarchyDate())
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetSubscriptions()                                        '
  ' Description : Get the subscriptions as objects.                         '
  ' Inputs      : none                                                      '
  ' Outputs     : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetSubscriptions()
    Set GetSubscriptions = session("ACCOUNT_TEMPLATE").Subscriptions
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetAncestorName()                                         '
  ' Description : Get the name of the ancestor that the account template    '
  '             : being created from.                                       '
  ' Inputs      : none                                                      '
  ' Outputs     : Name of the ancestor                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetAncestorName()
    dim rs
    If(Not IsEmpty(session("ACCOUNT_TEMPLATE"))) Then
         set rs= session("ACCOUNT_TEMPLATE").AccountTemplate.NearestParentInfo(mam_GetHierarchyDate())
    End If
    GetAncestorName = rs.Value("displayname")
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetSubscriptionsAsRowset()                                '
  ' Description : Get a rowset containing the subscriptions for the         '
  '             : template.                                                 '
  ' Inputs      : none                                                      '
  ' Outputs     : Rowset                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetSubscriptionsAsRowset()
    Dim objRS
    Dim objSub
    Dim objPO
    
    Set objRS = mdm_CreateObject(MT_SQL_ROWSET_SIMULATOR_PROG_ID)
    
    'Create the rowsset
    Call objRS.Initialize(session("ACCOUNT_TEMPLATE").Subscriptions.Count, 5)
    
    'Set the columns
    objRS.Name(0) = "NM_DISPLAY_NAME"
    objRS.Name(1) = "B_GROUP"
    objRS.Name(2) = "NM_GROUPSUBNAME"
    objRS.Name(3) = "ID_PO"
    objRS.Name(4) = "SUBSCRIPTION_PO"
   
    Call objRS.MoveFirst()
    
    'Loop through the subscriptions
    for each objSub in session("ACCOUNT_TEMPLATE").Subscriptions
      if objSub.GroupSubscription Then
        objRS.Value(0) = GetGSubPOName(objSub.GroupID)
      else
        objRS.Value(0) = GetPOName(objSub.ProductOfferingID)
      End If
      objRS.Value(1) = objSub.GroupSubscription
      objRS.Value(2) = objSub.GroupSubName

      if objSub.GroupSubscription Then
        objRS.Value(3) = objSub.GroupID
      else
        objRS.Value(3) = objSub.ProductOfferingID
      End If
      
      objRS.Value(4) = objSub.SubscriptionProductOfferingID 'AR: Bug fix to allow removing group subscriptions from a template.
      Call objRS.MoveNext()
    next

    'Return the simulated rowset
    Set GetSubscriptionsAsRowset = objRS
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetAvailableProductOfferingsAsRowset(strDate)             '
  ' Description : Get a rowset of product offerings available as of the     '
  '             : specified date.                                           '
  ' Inputs      : strDate -- Current Date                                   '
  ' Outputs     : Rowset                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetAvailableProductOfferingsAsRowset(strDate)
    Set GetAvailableProductOfferingsAsRowset = session("ACCOUNT_TEMPLATE").AccountTemplate.GetAvailableProductOfferingsAsRowset(strDate)
  End Function

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetAvailableGroupSubscriptionsAsRowset(strDate)           '
  ' Description : Return a rowset of group subscriptions available as of    '
  '             : the specified date.                                       '
  ' Inputs      : strDate -- Current Date                                   '
  ' Outputs     : Rowset                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetAvailableGroupSubscriptionsAsRowset(strDate)
    Set GetAvailableGroupSubscriptionsAsRowset = session("ACCOUNT_TEMPLATE").AccountTemplate.GetAvailableGroupSubscriptionsAsRowset(strDate)
  End Function

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : AddSubscription(lngPOID, bGroup)                          '
  ' Description : Add a subscription to the template.                       '
  ' Inputs      : lngPOID -- ID of the product offering for the             '
  '             :            subscription.                                  '
  '             : bGroup  -- Boolean indicating if this is a group          '
  '             :            subscription.                                  '
  ' Outputs     : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddSubscription(lngPOID, bGroup)
    Dim objNewSubscription
    Dim objGroupSubscription
    
    'Get a subscription object
    Set objNewSubscription = session("ACCOUNT_TEMPLATE").Subscriptions.AddSubscription()
 
    
    'Handle case of group subscription
    if bGroup then
      Set objGroupSubscription = GetProductCatalogObject().GetGroupSubscriptionByID(lngPOID)
      objNewSubscription.GroupID = objGroupSubscription.GroupID
       objNewSubscription.GroupSubName = objGroupSubscription.Name
    else
      objNewSubscription.ProductOfferingID = lngPOID
       objNewSubscription.GroupSubName = ""

    end if

    'Set dummy subscription dates, use MTNow
    objNewSubscription.StartDate = FrameWork.MetraTimeGMTNow()
    objNewSubscription.EndDate = Framework.MetraTimeGMTNow()

  End Function

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : RemoveSubscription(lngPOID)                               '
  ' Description : Remove a subscription from a product offering.            '
  ' Inputs      : lngPOID -- ID of the product offering to remove.          '
  ' Outputs     : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function RemoveSubscription(lngPOID)
    Call session("ACCOUNT_TEMPLATE").Subscriptions.RemoveSubscription(lngPOID)
  End Function

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : NormalizeProperty(objMSIXProperty)                        '
  ' Description : Convert underlying property value from DB representation  '
  '             : to an MDM compliant representation.                       '
  ' Inputs      : objMSIX -- MSIX object to get to tools                    '
  '             : objMSIXProperty -- Account property from DB               '
  ' Outputs     : Normalized Value                                          '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function NormalizeProperty(objMSIX, objMSIXProperty)
    if UCase(objMSIXProperty.PropertyType) = "BOOLEAN" then
      NormalizeProperty = objMSIX.Tools.BooleanValue(objMSIXProperty.Value)
    else
      NormalizeProperty = objMSIXProperty.Value
    end if
   ' if UCase(objMSIXProperty.PropertyType) = "BOOLEAN" then
   '   if UCase(objMSIXProperty.Value) = "Y" or objMSIXProperty.Value = 1 or UCase(objMSIXProperty.Value) = "T" or UCase(objMSIXProperty.Value) = "TRUE" then
   '     NormalizeProperty = True
   '   elseif UCase(objMSIXProperty.Value) = "N" or objMSIXProperty.Value = 0 or UCase(objMSIXProperty.Value) = "F" or UCase(objMSIXProperty.Value) = "FALSE" then
   '     NormalizeProperty = False
   '   else
   '     NormalizeProperty = objMSIXProperty.Value
   '   end if
   ' else
   '    NormalizeProperty = objMSIXProperty.Value
   ' end if
  End Function

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetPropertiesDiffAsRowset(objAccountMSIXProperties)       '
  ' Description : Return a rowset containing properties for the account     '
  '             : differ from properties in the template.                   '
  ' Inputs      : objAccountMSIXProperties -- Account properties for the    '
  '                                        -- account being moved.          '
  ' Outputs     : Rowset                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetPropertiesDiffAsRowset(objAccountMSIXProperties)
    Dim objTemplateProperty
    Dim objMSIXProperty
    Dim bDiff
    Dim objTempCol
    Dim objVar
    Dim objRS
    
    Set GetPropertiesDiffAsRowset = nothing

    'Create a simulated rowset
    Set objRS = mdm_CreateObject(MTSQLROWSETSIMULATOR_PROG_ID)
    
    'Create a place for variables
    Set objTempCol = mdm_CreateObject(CVariables)
    
    'Loop through properties
    for each objTemplateProperty in AccountTemplate().Properties
      'Check if the property exists for the account
      if objAccountMSIXProperties.Exist(objTemplateProperty.Name) then
        Set objMSIXProperty  = objAccountMSIXProperties(objTemplateProperty.Name)

        'Check if the properties match
        if UCase(objMSIXProperty.PropertyType) = "BOOLEAN" then
          if objMSIXProperty.Parent.Tools.BooleanValue(objMSIXProperty.Value) <> objMSIXProperty.Parent.Tools.BooleanValue(objTemplateProperty.Value) then
            bDiff = true
          else
            bDiff = false
          end if
        else
          if UCase("" & objMSIXProperty.Value) <> UCase("" & objTemplateProperty.Value) then
            bDiff = true
          else
            bDiff = false
          end if
        end if
        
        'Handle case where different
        if bDiff then
          'Add(ByVal strName As String, Optional ByVal varValue As Variant, Optional ByVal varType As Variant, Optional ByVal strProgId As String, Optional varCaption As Variant, Optional varTag As Variant) As CVariable
          'BEWARE sneakiness by using CVariables to hold properties
          '  .Name    = Property Name
          '  .Value   = Template Property Value
          '  .Caption = Account Property Value
          '  .Tag     = MSIXProperty.Caption
          Call objTempCol.Add(objTemplateProperty.Name, CStr("" & objTemplateProperty.Value),,, CStr("" & NormalizeProperty(Service, objMSIXProperty)), objMSIXProperty.Caption)
        end if
      end if
    next
    
    'Setup the rowset
    Call objRS.Initialize(objTempCol.Count, 4)
    
    'Set the names
    objRS.Name(0) = "Reserved"
		objRS.Name(1) = "Name"
		objRS.Name(2) = "TemplateValue"
		objRS.Name(3) = "MSIXValue"
    
    Call objRS.MoveFirst()

    'Add the rows
    'BEWARE sneakiness by using CVariables to hold properties
    '  .Name    = Property Name
    '  .Value   = Template Property Value
    '  .Caption = Account Property Value
    '  .Tag     = MSIXProperty.Caption
    
    for each objVar in objTempCol
      
      objRS.Value(0) = PreProcess("&nbsp;<input name=""_ATHP_|[NAME]|[TEMPLATE_VALUE]|[MSIX_VALUE]" & """ type=""CheckBox"" Checked>&nbsp;&nbsp;", _
                                   Array("NAME",objVar.Name,"TEMPLATE_VALUE",objVar.Value,"MSIX_VALUE",objVar.Caption))

 			objRS.Value(1) = objVar.Tag

      if UCase(objVar.Name) = "PAYERID" then
        'Handle PayerID specially
	  		objRS.Value(2) = mam_GetFieldIDFromAccountID(objVar.Value)
		  	objRS.Value(3) = mam_GetFieldIDFromAccountID(objVar.Caption)
      else
        Set objMSIXProperty = objAccountMSIXProperties(objVar.Name)
        If objMSIXProperty.IsEnumType() Then
            If objMSIXProperty.EnumType.Entries.Exist(objVar.Value) then            
                objRS.Value(2) = objMSIXProperty.EnumType.Entries.Item(objVar.Value).Caption
            Else            
                objRS.Value(2) = objMSIXProperty.EnumType.Entries.ItemByValue(objVar.Value).Caption
            End if   
            
            If objMSIXProperty.EnumType.Entries.Exist(objVar.Caption) then            
                objRS.Value(3) = objMSIXProperty.EnumType.Entries.Item(objVar.Caption).Caption 
            Else
                If Len(objVar.Caption) > 0 Then
                  objRS.Value(3) = objMSIXProperty.EnumType.Entries.ItemByValue(objVar.Value).Caption 
                End If  
            End if   
        Else
        		objRS.Value(2) = objVar.Value  	  	  	
            objRS.Value(3) = objVar.Caption
        End If
        
      end if      
						
			Call objRS.MoveNext()
    next

    Set GetPropertiesDiffAsRowset = objRS
  End Function
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetTemplatePropertiesAsRowset()                           '
  ' Description : Return a rowset containing properties in the template.    '
  ' Outputs     : Rowset                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetTemplatePropertiesAsRowset(objAccountMSIXProperties)
    Dim objTemplateProperty
    Dim objMSIXProperty
    Dim bDiff
    Dim objTempCol
    Dim objVar
    Dim objRS

    Set GetTemplatePropertiesAsRowset = nothing

    'Create a simulated rowset
    Set objRS = mdm_CreateObject(MTSQLROWSETSIMULATOR_PROG_ID)

    'Setup the rowset
    Call objRS.Initialize(AccountTemplate().Properties.count, 3)
    
    'Set the names
    objRS.Name(0) = "Reserved"
		objRS.Name(1) = "Caption"
		objRS.Name(2) = "Value"
    
    Call objRS.MoveFirst()
    
    'Loop through properties
    for each objTemplateProperty in AccountTemplate().Properties

      If UCase(objTemplateProperty.Name) = "ACCOUNTTYPE" or _
         UCase(objTemplateProperty.Name) = "APPLYACCOUNTTEMPLATE" or _
         UCase(objTemplateProperty.Name) = "TRUNCATEOLDSUBSCRIPTIONS" Then
         ' Skip properties that can not be updated
      Else
        Service.Log "-T- Setting Template Property: " & objTemplateProperty.Name
        objRS.Value(0) = PreProcess("&nbsp;<input name=""_ATHP_|[NAME]|[TEMPLATE_VALUE]" & """ type=""CheckBox"" Checked>&nbsp;&nbsp;", _
                                      Array("NAME",objTemplateProperty.Name,"TEMPLATE_VALUE",objTemplateProperty.Value))
      End IF
      
        If UCase(objTemplateProperty.Name) = "PAYERID" Then
            'Handle PayerID specially
            objRS.Value(1) = "Payer ID"
      	    objRS.Value(2) = mam_GetFieldIDFromAccountID(objTemplateProperty.Value)
        Else
            ' Get caption
    	      objRS.Value(1) = Replace(MAM().TempAccount(objTemplateProperty.Name).Caption, "{NL}", "")
            
            If MAM().TempAccount(objTemplateProperty.Name).IsEnumType() Then
              If MAM().TempAccount(objTemplateProperty.Name).EnumType.Entries.Exist(objTemplateProperty.Value) then
                objRS.Value(2) =  MAM().TempAccount(objTemplateProperty.Name).EnumType.Entries.Item(objTemplateProperty.Value).Caption
              Else            
                objRS.Value(2) =  MAM().TempAccount(objTemplateProperty.Name).EnumType.Entries.ItemByValue(objTemplateProperty.Value).Caption
              End if
            Else
    	        objRS.Value(2) = objTemplateProperty.Value
    	      End If
        End If
     ' End If
       
 			Call objRS.MoveNext()
    next

    Set GetTemplatePropertiesAsRowset = objRS
    
  End Function
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : ApplyTemplatesToAccounts()                                '
  ' Description : Apply template properties to an array of accounts.        '
  ' Inputs      : array of account ids                                      '
  ' Outputs     :                                                           '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function ApplyTemplatesToAccounts(colAccountIDs)
      Dim runID
    
      ApplyTemplatesToAccounts = false
    
      set m_sdk = InitSDK()
      runID = GenerateRunID()     
      
      ' meters a couple of sets 
  	  If CBool(AtLeastOnePropertyChecked()) Then
          If Not MeterSessionSet(runID, colAccountIDs) Then
            Err.Clear
          End If
      Else
      End If
      
      If err.number = 0 Then
        ApplyTemplatesToAccounts = true
      End If  
  End Function

  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AtLeastOnePropertyChecked()
	  AtLeastOnePropertyChecked = FALSE
   
	  Dim prop
  
	  If Instr(Request.Form, "_ATHP_") <> 0 Then
	  	AtLeastOnePropertyChecked = TRUE
	  End If 

  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
  ' End Public Methods
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Begin Private Methods

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetMSIXAccountTemplate()                                  '
  ' Description : Get the account template for the folder.                  '
  ' Inputs      :                                                           '
  ' Outputs     : MSIXAccountTemplate for the folder                        '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function GetMSIXAccountTemplate()
    Dim objYAAC
    Dim objTemplate
    on error resume next
    Set objYAAC = mdm_CreateObject(MT_YAAC_PROG_ID)
    Set objTemplate = mdm_CreateObject(MT_MSIX_ACCOUNT_TEMPLATE_PROG_ID)
    
    If Form("CAccountTemplate_FOLDERID") <> 1 Then
      Call objYAAC.InitAsSecuredResource(Form("CAccountTemplate_FOLDERID"), Framework.SessionContext, mam_GetHierarchyDate())
      CheckAndWriteError
      Call objTemplate.Initialize(objYAAC.GetAccountTemplate(mam_GetHierarchyDate(), mam_GetAccountType(m_AccountType).ID))
      CheckAndWriteError
    End If
    Set GetMSIXAccountTemplate = objTemplate
  End Function  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetPOName(lngPOID, bGroup)                                '
  ' Description : Get the name of a product offering.                       '
  ' Inputs      : lngPOID -- ID of the product offering to get the name of. '
  '             : bGroup  -- Indicates get name for group                   '
  ' Outputs     : string containing name of the po.                         '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function GetPOName(lngPOID)
    GetPOName = GetProductCatalogObject().GetProductOffering(lngPOID).DisplayName
  End Function
  
  Private Function GetGSubPOName(GSubID)
    Dim objPO
    Set objPO = GetProductCatalogObject().GetGroupSubscriptionByID(GSubID)
    GetGSubPOName = GetProductCatalogObject().GetProductOffering(objPO.ProductOfferingID).DisplayName
  End Function



  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function MeterSessionSet(runID, colAccountIDs)
      on error resume next
      dim setn, sessionSet, prop, i, sess
            
      for setn = 1 to colAccountIDs.count

          set sessionSet = m_sdk.CreateSessionSet
          sessionSet.SessionContext = FrameWork.SessionContext.toXML
  
          Call LoadTempAccountProperties(colAccountIDs.item(setn))

          For i = 1 to SESSIONS_PER_SET
              
              Set sess = sessionSet.CreateSession(mam_GetServiceFQNForOperationAndType("UPDATE", Session("MAM_CURRENT_ACCOUNT_TYPE")))
              Service.log "METERING TO: " & mam_GetServiceFQNForOperationAndType("UPDATE", Session("MAM_CURRENT_ACCOUNT_TYPE")) & "  Account Type = " & Session("MAM_CURRENT_ACCOUNT_TYPE")
              
              For Each prop in Service.Properties
                
                If Not IgnoreProperty(prop.name) Then
                  
                  ' Set property value in session if it's not empty or null
                  If Not IsEmpty(TypeName(prop.value)) Then
                    If Not IsEmpty(prop.value) Then
                      If Not IsNull(prop.value) Then

                        Service.log ">>> " &  prop.name & "[" & TypeName(prop.value) & "]=" & prop.value

                        If UCase(prop.PropertyType) = "BOOLEAN" Then
                          Call sess.InitProperty(prop.name, CBool(prop.value))
                        Else
                          Call sess.InitProperty(prop.name, prop.value)
                        End If

                        ' if payerid exists also add the payment start date, based on the passed in move date
                        If UCase(prop.name) = "PAYERID" Then
                          Service.log ">>> Setting payment startdate from move start date " & Form("MoveStartDate")
                          sess.InitProperty "payment_startdate", CDate(Form("MoveStartDate"))
                        End If
                        
                      End If                                                
                    end if  
                  End If
                  
                End If                        
              Next

              sess.RequestResponse = True
          Next
          
          sessionSet.Close
          
          if err.number <> 0 then
            dim errDescription
            errDescription = err.Description 
            
            Call BatchError.Add(Service.Properties("_accountid").Value, mam_GetFieldIDFromAccountID(Service.Properties("_accountid").Value), errDescription)
          end if
      next
  
      MeterSessionSet = true
      on error goto 0
  End Function

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : IgnoreProperty(name)                                      '
  ' Description : This is a list of properties we never want to meter as    '
  '               part of the template operation.                           '
  ' Inputs      : name -- Name of the property in Service.Properties        '
  ' Outputs     : TRUE if the property should be ignored, FALSE otherwise   '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function IgnoreProperty(name)

    Select Case LCase(name)  ' I find this syntax a little easier to read than a bunch of 'if' statements like we used to have
      Case "updatesubscriptions", "forcesubscriptions", "updateproperties"
        IgnoreProperty = TRUE    
      Case "subscribe_effectivestartdate", "subscribe_effectiveenddate"
        IgnoreProperty = TRUE
      Case "startnextbillingperiod", "endnextbillingperiod"
        IgnoreProperty = TRUE    
      Case "accountstatus" 
        IgnoreProperty = TRUE    
      Case Else
        IgnoreProperty = FALSE
    End Select    
                                
  End Function

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  
  Private Function InitSDK()
      Dim objMeter
      Dim objServerAccessSet 
      Dim objAccountPipelineServerAccess            
      
      Set objMeter = server.CreateObject("MetraTechSDK.Meter")
      Set objServerAccessSet = server.CreateObject("MTServerAccess.MTServerAccessDataSet.1")

      objServerAccessSet.Initialize
      Set objAccountPipelineServerAccess = objServerAccessSet.FindAndReturnObject("AccountPipeline")

      With objAccountPipelineServerAccess
           objMeter.HTTPTimeout = .Timeout
           objMeter.HTTPRetries = .NumRetries
           Call objMeter.AddServer(.Priority, .ServerName, .PortNumber, .Secure, .UserName, .PassWord)
      End With

      Call objMeter.Startup
      Set InitSDK = objMeter
  End Function

  
  ' generates a unique id used to uniquely identify records
  ' in a product view
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function GenerateRunID()
      GenerateRunID = Now() & " " & Int((1024 * Rnd) + 1) 
  End Function

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  
  Private Function LoadTempAccountProperties(accountID)
    Dim v, arrVar, objUIItems

    mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
    
    ' Reload all the data of the current subscriber
    mam_LoadTempAccount accountID
    MAM().TempAccount.CopyTo Service.Properties

    ' Make sure all properties can be set to empty 
    Call mam_AccountEnumTypeSupportEmpty(Service.Properties)

    ' Set all properties to empty except _AccountID and AccountType    
    Dim prop
    For Each prop in Service.Properties
      If UCase(prop.Name) <> "_ACCOUNTID" Then
        If UCase(prop.Name) <> "ACCOUNTTYPE" Then
          If Not IgnoreProperty(prop.Name) Then
            prop.Value = Empty
          End If  
        End If
      End If   
    Next  

    ' Apply Properties from the screen     
  	For Each v In objUIItems
  		arrVar = Split(v.name,"|")			
  		Select Case arrVar(0)
  		
  				Case "_ATHP_"
  						Service.Properties(arrVar(1)).Value = arrVar(2)
  		End Select
  	Next

    ' Get ready for an update
  	Service.Properties("ActionType").value = Service.Properties("ActionType").EnumType.Entries("Both").Value
  	Service.Properties("Operation").Value = Service.Properties("Operation").EnumType.Entries("Update").Value
  	If MAM().TempAccount.Exist("ContactType") Then
  	  Service.Properties("ContactType").Value = Service.Properties("ContactType").EnumType.Entries("Bill-To").Value
  	End If
  	
  	For Each prop in Service.Properties
  	    Service.log "INTO <<< " &  prop.name & "[" & TypeName(prop.value) & "]=" & prop.value
  	Next    

  End Function
  
  ' End Private Methods
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
End Class
' End Class Definition
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : SubscribeToProductOffering(EventArg, lngAccountID, lngPOID, '
'             :                            strStartDate, strEndDate,        '
'                                          bEffectiveNextPeriod, bGroup)    '
' Description : Subscribe the account to a product offering or group        '
'             : subscription.                                               '
' Inputs      : EventArg                                                    '
'             : lngAccountID -- ID of the account to add the po to.         '
'             : lngPOID      -- ID of the po or group subscription.         '
'             : strStartDate -- Start date of the subscription.             '
'             : strEndDate   -- End date of the subscription.               '
'             : bStartNextBillingPeriod                                     '
'             : bEndNextBillingPeriod                                       '
'             : bGroup       -- Indicates this is a group subscription.     '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function SubscribeToProductOffering(EventArg, lngAccountID, lngPOID, strStartDate, strEndDate, bStartNextBillingPeriod, bEndNextBillingPeriod, bGroup)
  Dim objProductCatalog
  Dim objAccount
  Dim objEffectiveDate
  Dim objGroupSubscription
  Dim objGSubMember
  
  SubscribeToProductOffering = false
  
  'Create objects
  Set objProductCatalog = GetProductCatalogObject()
  
  'Handle group subscriptions and non-group subscriptions differently
  if bGroup then
    'Find the group subscription
    Set objGroupSubscription = objProductCatalog.GetGroupSubscriptionByID(lngPOID)
    
    'Create a group subscription member
    Set objGSubMember = mdm_CreateObject(MTGSubMember)
    
    'Populate
    objGSubMember.AccountID = lngAccountID
    objGSubMember.StartDate = strStartDate
    
    if len(strEndDate) > 0 then
      objGSubMember.EndDate = strEndDate
    else
      objGSubMember.EndDate = FrameWork.RCD().GetMaxDate()  
    end if
    
    'Add account to group subscription
    Call objGroupSubscription.AddAccount(objGSubMember)
  else
    'Get a product catalog account reference
    Set objAccount = objProductCatalog.GetAccount(lngAccountID)
    
    Set objEffectiveDate = mdm_CreateObject(MTTimeSpan)

    'Get the effective dates
    objEffectiveDate.StartDate = CDate(Service.Tools.ConvertToGMT(strStartDate, MAM().CSR("TimeZoneId")))
  
    objEffectiveDate.StartDateType = IIF(bStartNextBillingPeriod , PCDATE_TYPE_BILLCYCLE , PCDATE_TYPE_ABSOLUTE)
    objEffectiveDate.EndDateType = IIF(bEndNextBillingPeriod , PCDATE_TYPE_BILLCYCLE , PCDATE_TYPE_ABSOLUTE)
    
    'Check for null end date
    if len(strEndDate) > 0 then
      objEffectiveDate.EndDate =  CDate(Service.Tools.ConvertToGMT(strEndDate, MAM().CSR("TimeZoneId")))
    else
      Call objEffectiveDate.SetEndDateNull()
    end if
    
    'Subscribe
    dim bModified
    Call objAccount.Subscribe(lngPOID, objEffectiveDate,CBool(bModified))
  end if
  
  SubscribeToProductOffering = true
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
PUBLIC FUNCTION UpdateAccountWithSubscriptions(EventArg)
	
	Dim booOK, v, arrVar, lngPOID, objUIItems, bGroup
	
  UpdateAccountWithSubscriptions = FALSE
  mdm_BuildQueryStringCollectionPlusFormCollection objUIItems
	
	For Each v In objUIItems
	
			arrVar = Split(v.name,"|")
			
			Select Case arrVar(0)
			
					Case "_ATHS_"
							lngPOID = arrVar(1)
              
              if UCase(arrVar(2)) = "TRUE" then
                bGroup = true
              else
                bGroup = false
              end if
              
              Call SubscribeToProductOffering(EventArg,Form("AccountID"), lngPOID, Service("Subscribe_EffectiveStartDate"), Service("Subscribe_EffectiveEndDate"), Service("StartNextBillingPeriod"), Service("EndNextBillingPeriod"), bGroup)
			End Select
	Next			
	UpdateAccountWithSubscriptions = TRUE
END FUNCTION
%>
