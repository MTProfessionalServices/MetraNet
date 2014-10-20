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
' NAME		        : MAM - MetraTech Account Manager - VBScript Library
' VERSION	        : 3.5
' CREATION_DATE   : 10/09/2002
' AUTHOR	        : F.Torres.
' DESCRIPTION	    : 
'                   
' ----------------------------------------------------------------------------------------------------------------------------------------

PUBLIC CONST ACCOUNT_FINDER_ACCOUNT_TYPE_FOR_SEARCH_PAYER=1
PUBLIC CONST ACCOUNT_FINDER_ACCOUNT_TYPE_FOR_SEARCH_PAYEE=2

CLASS CTransactionUIFinder

    PRIVATE m_objPriceAbleItemProperties
    
    PUBLIC PROPERTY GET PriceAbleItemTypeInfoEnumType()
        If IsEmpty(SESSION("ADJ_PriceAbleItemTypeInfoEnumType")) Then Set SESSION("ADJ_PriceAbleItemTypeInfoEnumType") = Nothing
        Set PriceAbleItemTypeInfoEnumType = SESSION("ADJ_PriceAbleItemTypeInfoEnumType")
    END PROPERTY
    PUBLIC PROPERTY SET PriceAbleItemTypeInfoEnumType(v)
        Set SESSION("ADJ_PriceAbleItemTypeInfoEnumType") = v 
    END PROPERTY
    PUBLIC PROPERTY GET TimeSlice()
      Set TimeSlice = SESSION("ADJ_TimeSlice")
    END PROPERTY
    PUBLIC PROPERTY SET TimeSlice(v)
      Set SESSION("ADJ_TimeSlice") = v 
    END PROPERTY
    PUBLIC PROPERTY GET AccSlice()
      Set AccSlice = SESSION("ADJ_AccSlice")
    END PROPERTY
    PUBLIC PROPERTY SET AccSlice(v)
      Set SESSION("ADJ_AccSlice") = v 
    END PROPERTY
    PUBLIC PROPERTY GET ProductSlice()
      Set ProductSlice = SESSION("ADJ_ProductSlice")
    END PROPERTY
    PUBLIC PROPERTY SET ProductSlice(v)
      Set SESSION("ADJ_ProductSlice") = v 
    END PROPERTY
    PUBLIC PROPERTY GET SessSlice()
      Set SessSlice = SESSION("ADJ_SessSlice")
    END PROPERTY
    PUBLIC PROPERTY SET SessSlice(v)
      Set SESSION("ADJ_SessSlice") = v 
    END PROPERTY
    PUBLIC PROPERTY GET RptHelper()
      Set RptHelper = SESSION("ADJ_RptHelper")
    END PROPERTY
    PUBLIC PROPERTY SET RptHelper(v)
      Set SESSION("ADJ_RptHelper") = v 
    END PROPERTY    
    PUBLIC PROPERTY GET SelectedPriceAbleItemTypeName()
      SelectedPriceAbleItemTypeName = SESSION("ADJ_SelectedPriceAbleItemTypeName")
    END PROPERTY
    PUBLIC PROPERTY LET SelectedPriceAbleItemTypeName(v)
      SESSION("ADJ_SelectedPriceAbleItemTypeName") = v 
    END PROPERTY        
    PUBLIC PROPERTY GET ProductViewFQN()
      ProductViewFQN = SESSION("ADJ_ProductViewFQN")
    END PROPERTY
    PUBLIC PROPERTY LET ProductViewFQN(v)
      SESSION("ADJ_ProductViewFQN") = v 
    END PROPERTY    
    PUBLIC PROPERTY GET SelectedPriceAbleItemTemplateID()
      SelectedPriceAbleItemTemplateID = SESSION("ADJ_SelectedPriceAbleItemTemplateID")
    END PROPERTY
    PUBLIC PROPERTY LET SelectedPriceAbleItemTemplateID(v)
      SESSION("ADJ_SelectedPriceAbleItemTemplateID") = v 
    END PROPERTY
    PUBLIC PROPERTY GET SelectedPriceAbleItemTypeID()
      SelectedPriceAbleItemTypeID = FrameWork.ProductCatalog.GetPriceableItem(SelectedPriceAbleItemTemplateID).PriceAbleItemType.ID
    END PROPERTY
    
    PUBLIC FUNCTION SelectedPriceAbleItemTypeSupportReBill()
    
        ' PriceAbleItemTypeInfoEnumType is a CVariables object, we store in the property TAG of the CVariable instance
        ' if the priceable item type support rebill
        SelectedPriceAbleItemTypeSupportReBill = CBool(PriceAbleItemTypeInfoEnumType.Item(SelectedPriceAbleItemTypeName).Tag)
    END FUNCTION
    
    PRIVATE FUNCTION Clean()
    
        Set SessSlice     = Nothing
        Set RptHelper     = Nothing
        Set TimeSlice     = Nothing
        Set AccSlice      = Nothing
        Set ProductSlice  = Nothing
        ProductViewFQN    = Empty        
        Clean             = TRUE
    END FUNCTION
    
        PUBLIC FUNCTION SetValidListOfValueAdjustablePriceAbleItem(MSIXProperty)
    
        Dim v, lngID, PriceableItemTypes, PriceableItemType, booSupportReBill, Template, AdjustmentType,  PriceableItemTypeChild, ChildTemplate
        dim children
        dim adjustable
        Dim AdjustmentTypes
        
'        Set PriceAbleItemTypeInfoEnumType = Nothing

        If Not IsValidObject(PriceAbleItemTypeInfoEnumType) Then
            '
            ' We need to get only the price able item that support adjustment
            '
            'Set PriceableItemTypes              = FrameWork.ProductCatalog.GetPriceableItemTypes()
            Set PriceAbleItemTypeInfoEnumType   = mdm_CreateObject(CVariables)
     
            Dim rs
            Set rs = server.CreateObject("MTSQLRowset.MTSQLRowset.1")

            rs.Init "Queries\Adjustments"
            rs.SetQueryTag "__LOAD_ADJUSTABLE_TEMPLATES__"

            rs.AddParam "%%LANG_ID%%", Framework.SessionContext.LanguageID

            rs.ExecuteDisconnected

            While Not CBool(rs.EOF)
                PriceAbleItemTypeInfoEnumType.Add CStr(rs.Value("nm_name")),Int(rs.Value("id_template")),,,CStr(rs.Value("nm_display_name")), CBool(rs.Value("supportsRebill"))

                rs.MoveNext
            Wend

            Set rs = nothing
                    
            PriceAbleItemTypeInfoEnumType.Add 0,0,,,FrameWork.Dictionary().Item("TEXT_ACCOUNT_FINDER_PLEASE_SELECT_A_PI").Value, FALSE
        End If
        Service.Properties("PriceAbleItem").AddValidListOfValues PriceAbleItemTypeInfoEnumType
        SetValidListOfValueAdjustablePriceAbleItem = TRUE
    END FUNCTION

    
    PUBLIC FUNCTION GetViewID(s)
    
        GetViewID = Service.Tools.PVNameIdLookUpObject.GetNameID(CStr(s))
    END FUNCTION
    
    PUBLIC FUNCTION SetHTMLSubTemplate(strPriceAbleItemName,lngPriceAbleItemTypeID)
    
'        Dim strTemplateFileName
'        
'        
'        
'        If FrameWork.Dictionary.Exist(TRANSACTION_FINDER_TEMPLATE_DICTIONARY_PREFIX & strPriceAbleItemName) Then 
'          
'            strTemplateFileName = FrameWork.Dictionary.Item(TRANSACTION_FINDER_TEMPLATE_DICTIONARY_PREFIX & strPriceAbleItemName).Value
'            
'            If CreateObject(CTextFile).ExistFile(strTemplateFileName) Then
'            
'                FrameWork.Dictionary.Add "ADJUSTMENT_FINDER_PRICE_ABLE_ITEM_SUB_TEMPLATE",  strTemplateFileName
'                Exit Function
'            End If
'        End If        
'        '
'        ' Generic Finder Template
'        '
'        Dim objPriceAbleItemType, strProductViewName, strHTML, MSIXProperty
'        Set objPriceAbleItemType = FrameWork.ProductCatalog.GetPriceableItemType(lngPriceAbleItemTypeID)
'        strProductViewName       = Replace(objPriceAbleItemType.ProductView & ".msixdef","/","\")
'        
'        Dim objMSIXHandlerProductView
'        Set objMSIXHandlerProductView = mdm_CreateObject(MSIXHandler)
'        
'        objMSIXHandlerProductView.Initialize ,strProductViewName,"" & MAM().CSR("Language").Value,mdm_GetSessionVariable("mdm_APP_FOLDER"),mdm_GetMDMFolder(),mdm_InternalCache,,MDM_VERSION
'        
'        For Each MSIXProperty In objMSIXHandlerProductView.Properties
'            strHTML = strHTML & PreProcess("<TR><TD class='captionEW'><MDMLABEL Name='[PROPERTYNAME]' Type='Caption'></MDMLABEL>:</td><TD class=''><INPUT Type='Text' Class='clsInputBox' Name='[PROPERTYNAME]'></TD></TR>",Array("PROPERTYNAME",MSIXProperty.Name)) & vbNewLine
'        Next        
'        
'        FrameWork.Dictionary.Add "ADJUSTMENT_FINDER_PRICE_ABLE_ITEM_SUB_TEMPLATE", "<MDMHTML>" & strHTML
    END FUNCTION
    
    PUBLIC FUNCTION CreateNewReportHelper()

        if not isobject(Application("REPORT_MANAGER")) then
          Dim objReportManager
          Set objReportManager = Server.CreateObject("MTHierarchyReports.ReportManager.1")
          
          if objReportManager is nothing then
            response.write "Error: Unable to create report manager!"
          else
            Dim strPath
            strPath = Server.MapPath("/MAM") & "\reports.xml"
            Call objReportManager.Initialize(strPath)
            
            Application.Lock
            Set Application("REPORT_MANAGER") = objReportManager
            Application.UnLock
          end if
        end if

        Set RptHelper = Application("REPORT_MANAGER").GetReportHelper(Session("SubscriberYAAC"), Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").LanguageId)

        RptHelper.ReportIndex = 1
        RptHelper.InlineAdjustments = false
        RptHelper.ReportInfo.InlineVATTaxes = false
        
        CreateNewReportHelper = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION InitializePriceAbleItem(strPriceAbleItemName,lngPriceAbleItemTypeID,strStartDate, strEndDate,booInsertPriceAbleItemProperties) ' As Boolean

        Clean
        
        CreateNewReportHelper
        
        Set SessSlice = mdm_CreateObject("MTHierarchyReports.RootSessionSlice")
        
        If len(Service.Properties("mdmIntervalID").Value)>0 Then        
            Set TimeSlice = CreateObject("MTHierarchyReports.UsageIntervalSlice")
            TimeSlice.IntervalID = Service.Properties("mdmIntervalID").Value
        Else
            Set TimeSlice = CreateObject("MTHierarchyReports.DateRangeSlice")
            TimeSlice.Begin = CDate(mam_NormalDateFormat(Service.Properties("StartDate")))
            TimeSlice.End = CDate(mam_NormalDateFormat(Service.Properties("EndDate")))
        End If
        
        If Service.Properties("CurrentAccountIsThePayer").Value = ACCOUNT_FINDER_ACCOUNT_TYPE_FOR_SEARCH_PAYER Then
        
            Set AccSlice                                  = CreateObject("MTHierarchyReports.PayerSlice")
            accSlice.PayerID                              = MAM().Subscriber("_AccountID").Value
        Else
            Set AccSlice                                  = CreateObject("MTHierarchyReports.PayeeSlice")
            accSlice.PayeeID                              = MAM().Subscriber("_AccountID").Value
        End If

        Set ProductSlice                              = CreateObject("MTHierarchyReports.PriceableItemTemplateWithInstanceSlice")
        ProductSlice.TemplateID                       = lngPriceAbleItemTypeID
        ProductViewFQN                                = FrameWork.ProductCatalog.GetPriceableItem(lngPriceAbleItemTypeID).PriceAbleItemType.GetProductViewObject().Name
        ProductSlice.ViewID                           = Service.Tools.PVNameIdLookUpObject.GetNameID(ProductViewFQN)
        
        SelectedPriceAbleItemTypeName                 = strPriceAbleItemName
        
        If(booInsertPriceAbleItemProperties) Then
            InsertPriceAbleItemProperties
        End If

        InitializePriceAbleItem = TRUE
    END FUNCTION
    
    PUBLIC PROPERTY GET PriceAbleItemProperties()
    
        If(IsEmpty(m_objPriceAbleItemProperties ))Then Set m_objPriceAbleItemProperties = ProductSlice.ProductView.GetProperties()
        Set PriceAbleItemProperties = m_objPriceAbleItemProperties
    END PROPERTY
    
    PUBLIC FUNCTION InsertPriceAbleItemProperties()
    
        Dim Prop, strHTML, strPropertiesList, strProperty, strDisplayName, strHTMLTEMPLATE, strMSIXType, propName
        
        RemovePropertyTagged "INPUT"

        ' Read As A Collection Of Entry        
        strPropertiesList = FrameWork.Dictionary.GetCollectionAsCSVString(TRANSACTION_FINDER_TEMPLATE_DICTIONARY_PREFIX & ProductViewFQN)
        If  Len(strPropertiesList) = 0 Then         
            For Each Prop in PriceAbleItemProperties            
                strPropertiesList =  strPropertiesList & LCase(Prop.Dn) & ","
            Next
        End If

        For Each strProperty In Split(strPropertiesList,",")
            Set Prop = GetSearchOnProperty(strProperty)

            If IsValidObject(Prop) Then
             
                If Prop.Core = FALSE Then ' Exclude properties coming from t_acc_usage
                      
                      strDisplayName = Empty
                      ProductView.Tools.GetLocalizedString MAM().CSR("Language").Value,ProductViewFQN & "/" & Prop.dn,strDisplayName
                      If Len(strDisplayName) = 0 Then strDisplayName = Prop.dn
    
                      strMSIXType = mdm_ComputeMSIXHandlerPropertyTypeAsString(Prop.DataType)
                      
                      ' Create the property as string because I prefer to reset the type later, This will avoid to log an error...
                      If strMSIXType = MSIXDEF_TYPE_ENUM Then strMSIXType = MSIXDEF_TYPE_STRING 
                      
                      propName = "_" & prop.dn
                      If strMSIXType = MSIXDEF_TYPE_TIMESTAMP Then 
                        Service.Properties.Add propName, MSIXDEF_TYPE_STRING, 255, False, Empty
                      Else
                        Service.Properties.Add propName, strMSIXType, IIF(strMSIXType=MSIXDEF_TYPE_STRING, 255, 0), False, Empty
                      End If

                      Service.Properties(propName).Caption = strDisplayName
                      Service.Properties(propName).Tag = "INPUT"
    
                      If strMSIXType = MSIXDEF_TYPE_TIMESTAMP Then
                     
                          strHTMLTEMPLATE = ""
                          strHTMLTEMPLATE = strHTMLTEMPLATE & vbNewLine & "<TR><TD class='captionEW'><MDMLABEL Name='[PROPERTYNAME]' Type='Caption'></MDMLABEL>:</td><TD class=''>" & vbNewLine
                          strHTMLTEMPLATE = strHTMLTEMPLATE & "<INPUT  Size=30 Type='Text' Class='clsInputBox' Name='[PROPERTYNAME]'>" & vbNewLine
                          strHTMLTEMPLATE = strHTMLTEMPLATE & "<a href='#' onClick='getCalendarForStartDate(document.mdm.[PROPERTYNAME]);return false;'><img src='/mam/default/localized/en-us/images/popupcalendar.gif' width=16 height=16 border=0 alt=''></a>" & vbNewLine
                          strHTMLTEMPLATE = strHTMLTEMPLATE & "</TD></TR>" & vbNewLine                  
                          strHTML         = strHTML & strHTMLTEMPLATE
                          
                      ElseIf strMSIXType = MSIXDEF_TYPE_BOOLEAN Then
                          
                          strHTML = strHTML & "<TR><TD class='captionEW'><MDMLABEL Name='[PROPERTYNAME]' Type='Caption'></MDMLABEL>:</td><TD class=''><SELECT Class='clsInputBox' Name='[PROPERTYNAME]'></SELECT></TD></TR>" & vbNewLine
                          Service.Properties(propName).EnumTypeSupportEmpty = TRUE
                          Service.Properties(propName).Value = Empty
                                                
                      ElseIf Len(Prop.EnumNamespace) Then
                      
                          Service.Properties(propName).SetPropertyType "ENUM", Prop.EnumNamespace, prop.EnumEnumeration
                          Service.Properties(propName).Value = ""
                          Service.Properties(propName).EnumTypeSupportEmpty = true 'CORE-6952 Fix so that when not populating enum filters, MSIXProperty.cls does not try to fill in a default value when no value is selected before performing the search

                          strHTML = strHTML & "<TR><TD class='captionEW'><MDMLABEL Name='[PROPERTYNAME]' Type='Caption'></MDMLABEL>:</td><TD class=''><SELECT Class='clsInputBox' Name='[PROPERTYNAME]'></SELECT></TD></TR>" & vbNewLine
                      Else
                          strHTML = strHTML & "<TR><TD class='captionEW'><MDMLABEL Name='[PROPERTYNAME]' Type='Caption'></MDMLABEL>:</td><TD class=''><INPUT Size=30 Type='Text' Class='clsInputBox' Name='[PROPERTYNAME]'></TD></TR>" & vbNewLine
                      End If
                      strHTML = PreProcess(strHTML,Array("PROPERTYNAME",propName)) & vbNewLine
                  End If                      
              End If
        Next
        Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
        FrameWork.Dictionary.Add "ADJUSTMENT_FINDER_PRICE_ABLE_ITEM_SUB_TEMPLATE", "<MDMHTML>" & strHTML
        InsertPriceAbleItemProperties = TRUE
    END FUNCTION
    
    PRIVATE FUNCTION GetSearchOnProperty(ByVal strPName)
    
        Dim Prop
        
        Set GetSearchOnProperty = Nothing
        strPName                = LCase(strPName)

        For Each Prop in PriceAbleItemProperties
        
            If LCase(Prop.Dn) = strPName Then
            
                Set GetSearchOnProperty = Prop
                Exit Function
            End If        
        Next
    END FUNCTION
    
    PUBLIC FUNCTION Find(EventArg)
      
        Dim Prop, Rs,lnginternalDBId
        Dim CriteriaCounter
        
        CriteriaCounter = 0
        Find            = -1 ' Error
        
        For Each Prop in PriceAbleItemProperties
                
            If(Service.Properties.Exist("_" & Prop.dn))Then
            
                If(Len(Service.Properties("_" & Prop.dn).Value))Then

                    If (Service.Properties("_" & Prop.dn).IsEnumType)And(Service.Properties("_" & Prop.dn).PropertyType<>MSIXDEF_TYPE_BOOLEAN) Then
                        lnginternalDBId = Service.Tools.GetEnumIDFromValue(Service.Properties("_" & Prop.dn).EnumType.NameSpace,Service.Properties("_" & Prop.dn).EnumType.Name,Service.Properties("_" & Prop.dn).Value)
                        ProductSlice.AddProductViewPropertyPredicate Prop, Clng(lnginternalDBId)
                    Else
                        ProductSlice.AddProductViewPropertyPredicate Prop, Service.Properties("_" & Prop.dn).Value
                    End If
                    CriteriaCounter = CriteriaCounter + 1
                End If
            End If
        Next
        On Error Resume Next
        Find = GetReportHelperUsageDetail()
        If Err.Number Then
            EventArg.Error.Save Err
            Find = -1
        End If
    END FUNCTION
    
    PUBLIC FUNCTION GetReportHelperUsageDetail()
    
        GetReportHelperUsageDetail = -1

        Session(SESSION_ADJ_PARENT_ROWSET)      = Empty
        ' Call GetTransactionDetail2 so we only get top 100 rows
        Set Session(SESSION_ADJ_PARENT_ROWSET)  = rpthelper.GetTransactionDetail2(ProductSlice, SessSlice, AccSlice, TimeSlice, "")
        
        If(IsObject(Session(SESSION_ADJ_PARENT_ROWSET)))Then
        
            GetReportHelperUsageDetail = Session(SESSION_ADJ_PARENT_ROWSET).RecordCount
        End If    
    END FUNCTION
    
    PUBLIC FUNCTION UpdateFoundRowSet()
        CreateNewReportHelper
        UpdateFoundRowSet = GetReportHelperUsageDetail()
    END FUNCTION
    
    PRIVATE FUNCTION RemovePropertyTagged(strTagType)
    
        Dim MSIXProperty, booOK
        
        RemovePropertyTagged = FALSE
      
        booOK = FALSE
        
        Do While Not booOK ' Remove the input and output properties from the service object
        
            booOK = TRUE
            For Each MSIXProperty In Service.Properties
            
                If MSIXProperty.Tag = strTagType Then Service.Properties.Remove MSIXProperty.Name : booOK = FALSE : Exit For
            Next
        Loop
        RemovePropertyTagged = TRUE
    END FUNCTION    
    
    PUBLIC FUNCTION Initialize()
        Initialize = FALSE
        
       ' If Service.Properties("PriceAbleItem").Value = 0 Then
          Service.Properties.Clear
          FrameWork.Dictionary.Add "ADJUSTMENT_FINDER_PRICE_ABLE_ITEM_SUB_TEMPLATE", "<MDMHTML>"
      
          Service.Properties.Add "CurrentAccountIsThePayer", "Int32",0,TRUE, Empty
          Service.Properties("CurrentAccountIsThePayer").Caption  = PreProcess(FrameWork.Dictionary.Item("ACCOUNT_FINDER_ACCOUNT_TYPE_FOR_SEARCH_CAPTION").Value  ,Array("SUBSCRIBER","<B>" & MAM().Subscriber("UserName").Value & "</B>") )
          Service.Properties("CurrentAccountIsThePayer").AddValidListOfValueFromDictionaryCollection FrameWork.Dictionary(),"ACCOUNT_FINDER_ACCOUNT_TYPE_FOR_SEARCH"
          Service.Properties("CurrentAccountIsThePayer").Value    = CLng(FrameWork.Dictionary.Item("ADJUSTMENT_FINDER_CURRENT_ACCOUNT_TYPE_FOR_QUERY_IS_THE_PAYER").Value)
          
          Service.Properties.Add "StartDate", "String",  0, False, Empty
          Service.Properties("StartDate").Caption = FrameWork.Dictionary.Item("TEXT_START_DATE").Value
        
          Service.Properties.Add "EndDate", "String", 0, False, Empty
          Service.Properties("EndDate").Caption = FrameWork.Dictionary.Item("TEXT_END_DATE").Value 

          Service.Properties.Add "BillingInterval", "String", 0, False, Empty
          Service.Properties("BillingInterval").Caption = FrameWork.Dictionary.Item("TEXT_BILLING_INTERVAL").Value 

          Service.Properties.Add "FixedDate", "String", 0, False, Empty
          Service.Properties("FixedDate").Caption = FrameWork.Dictionary.Item("TEXT_FIXED_DATE").Value 
               
          Service.Properties.Add "PeriodOfTime", "String", 0, False, Empty
          Service.Properties("PeriodOfTime").Caption = FrameWork.Dictionary.Item("TEXT_PERIOD_OF_TIME").Value 
        
          Service.Properties.Add "PriceAbleItem", "Int32" , 0 , TRUE , Empty  
          Service.Properties("PriceAbleItem").Caption = FrameWork.Dictionary.Item("TEXT_ACCOUNT_FINDER_PRICEABLEITEM_COMBOBOX_LABEL").Value
        'End If 

        TransactionUIFinder.SetValidListOfValueAdjustablePriceAbleItem Service.Properties("PriceAbleItem")       
        
        If Service.Properties("PriceAbleItem").EnumType.Entries.Count=0 Then
      
              EventArg.Error.Description =  FrameWork.Dictionary.Item("MAM_ERROR_1042").Value
              EventArg.Error.Number      =  1042
              Form_DisplayErrorMessage EventArg
              mdm_TerminateDialog
              Response.End
        End If        
        
        ' Load the interval id
        Service.Properties.Interval.Load mam_GetSubscriberAccountID()  
        mdm_pvb_DoToProductViewTheIntervalIDFieldAsEnumType MDM_ACTION_ADD, Service ' Populate the field Interval ID
          
        Initialize = TRUE
    END FUNCTION

    PUBLIC FUNCTION ReInitialize()
        ReInitialize = FALSE
        
        TransactionUIFinder.SetValidListOfValueAdjustablePriceAbleItem Service.Properties("PriceAbleItem")       
        
        If Service.Properties("PriceAbleItem").EnumType.Entries.Count=0 Then
      
              EventArg.Error.Description =  FrameWork.Dictionary.Item("MAM_ERROR_1042").Value
              EventArg.Error.Number      =  1042
              Form_DisplayErrorMessage EventArg
              mdm_TerminateDialog
              Response.End
        End If        
        
        ' Load the interval id
        Service.Properties.Interval.Load mam_GetSubscriberAccountID()  
        mdm_pvb_DoToProductViewTheIntervalIDFieldAsEnumType MDM_ACTION_ADD, Service ' Populate the field Interval ID
          
        ReInitialize = TRUE
    END FUNCTION
    
END CLASS

Private TransactionUIFinder
Set TransactionUIFinder = New CTransactionUIFinder

%>
