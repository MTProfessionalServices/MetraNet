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
' CREATION_DATE     : 10/09/2002
' AUTHOR	        : F.Torres.
' DESCRIPTION	    : 
'                   
' ----------------------------------------------------------------------------------------------------------------------------------------

PUBLIC CONST ADJUSTMENT_ROWSET_SESSION_NAME         = "ADJUSTMENT_ROWSET_SESSION_NAME"
PUBLIC CONST SESSION_ADJ_PARENT_ROWSET              = "SESSION_ADJ_PARENT_ROWSET"
PUBLIC CONST SESSION_ADJ_CHILDREN_ROWSET            = "SESSION_ADJ_CHILDREN_ROWSET"

' This const are used as dictionary entry prefix
PUBLIC CONST ADJUSTMENT_TEMPLATE_DICTIONARY_PREFIX            = "Adjustments.Template:"
PUBLIC CONST TRANSACTION_FINDER_TEMPLATE_DICTIONARY_PREFIX    = "TransactionFinder.Template:"

' enum {
PUBLIC CONST AdjustmentKind_FLAT = 1
PUBLIC CONST AdjustmentKind_PERCENT = 2
PUBLIC CONST AdjustmentKind_MINUTES = 3
PUBLIC CONST AdjustmentKind_REBILL = 4
'    } AdjustmentKind;


CLASS CAdjustmentHelper

    ' Code Shared by Adjustment.PVB.children.asp and Adjustment.PVB.children.Delete.asp
    ' This is ok to hard code the column here we are talking about Adjustment properties
    PUBLIC FUNCTION ChildrenPVBColumnSelection()
    
        Dim i
        i = 1
        
        ProductView.Properties.ClearSelection    
        ProductView.Properties("SessionID").Selected          = i : i=i+1 ' As PlaceHolder      
        ProductView.Properties("Amount").Selected             = i : i=i+1
        ProductView.Properties("Currency").Selected           = i : i=i+1
        ProductView.Properties("DisplayName").Selected        = i : i=i+1
        ProductView.Properties("TaxAmount").Selected          = i : i=i+1        
        ProductView.Properties.CancelLocalization
        ProductView.Properties("SessionID").Caption        = FrameWork.Dictionary.Item("TEXT_SESSION_ID").Value   
        ProductView.Properties("Amount").Caption           = FrameWork.Dictionary.Item("TEXT_AMOUNT").Value
        ProductView.Properties("Currency").Caption         = FrameWork.Dictionary.Item("TEXT_CURRENCY").Value
        ProductView.Properties("DisplayName").Caption      = FrameWork.Dictionary.Item("TEXT_PAYEE_DISPLAY_NAME").Value
        ProductView.Properties("TaxAmount").Caption        = FrameWork.Dictionary.Item("TEXT_TAX_AMOUNT").Value    
        
        ChildrenPVBColumnSelection = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION CheckIfTransactionHasAlreadyAdjustment(lngChildViewID,lngParentTransactionID,ByRef strMessage)
    
          Dim R, lngPrebillAdjusted, lngPostbillAdjusted, lngTotalAdjustment
          
          CheckIfTransactionHasAlreadyAdjustment  = FALSE
          lngPrebillAdjusted                      = 0
          lngPostbillAdjusted                     = 0
          
          Set R = GetTransactionChildrenRowSet(lngChildViewID,lngParentTransactionID)
          Do While Not R.EOF
              If R.Value("IsPrebillAdjusted")="Y" Then lngPrebillAdjusted=lngPrebillAdjusted+1                  
              If R.Value("IsPostbillAdjusted")="Y" Then lngPostbillAdjusted=lngPostbillAdjusted+1
              R.MoveNext
          Loop
          If(lngPrebillAdjusted<>0 Or lngPostbillAdjusted<>0)Then
          
              CheckIfTransactionHasAlreadyAdjustment  = TRUE
              lngTotalAdjustment                      = lngPrebillAdjusted  + lngPostbillAdjusted                            
              strMessage                              = PreProcess(FrameWork.Dictionary.Item("TEXT_TRANSACTION_ADJUSTMENT_STATUS").Value,Array("lngTotalAdjustment",lngTotalAdjustment,"lngPrebillAdjusted",lngPrebillAdjusted,"lngPostbillAdjusted",lngPostbillAdjusted))
          Else
              strMessage = ""
          End If
    END FUNCTION
  
    PUBLIC FUNCTION GetTransactionChildrenRowSet(lngChildViewID,lngParentTransactionID)
    
      Dim idParent, productSlice, sessSlice 
      
      Set GetTransactionChildrenRowSet = Nothing ' Default Value
      
      Set productSlice      = CreateObject("MTHierarchyReports.ProductViewAllUsageSlice")
      productSlice.ViewID   = lngChildViewID
      
      If(productSlice.ViewID=-1) Then Exit Function
      
      set sessSlice = CreateObject("MTHierarchyReports.SessionChildrenSlice")
      
      ' Just get the first record of the rowset
      sessSlice.ParentID = lngParentTransactionID
    
      ClearCachedData
      
      Set GetTransactionChildrenRowSet = TransactionUIFinder.RptHelper.GetTransactionDetail(productSlice, sessSlice, TransactionUIFinder.AccSlice, TransactionUIFinder.TimeSlice, "")
    END FUNCTION  
  
    PUBLIC PROPERTY GET DeletedAdjustmentRowset()
      Set DeletedAdjustmentRowset = SESSION("ADJ_DELETE_ADJUSTMENT_ROWSET")
    END PROPERTY    
    PUBLIC PROPERTY SET DeletedAdjustmentRowset(v)
      Set SESSION("ADJ_DELETE_ADJUSTMENT_ROWSET") = v
    END PROPERTY
    
    PUBLIC PROPERTY GET ApprovedAdjustmentRowset()
      Set ApprovedAdjustmentRowset = SESSION("ADJ_APPROVED_ADJUSTMENT_ROWSET")
    END PROPERTY    
    PUBLIC PROPERTY SET ApprovedAdjustmentRowset(v)
      Set SESSION("ADJ_APPROVED_ADJUSTMENT_ROWSET") = v
    END PROPERTY
    
    
    PUBLIC PROPERTY GET OrphanAdjustmentRowset()
      Set OrphanAdjustmentRowset = SESSION("ADJ_ORPHAN_ADJUSTMENT_ROWSET")
    END PROPERTY    
    PUBLIC PROPERTY SET OrphanAdjustmentRowset(v)
      Set SESSION("ADJ_ORPHAN_ADJUSTMENT_ROWSET") = v
    END PROPERTY    
    
    PUBLIC PROPERTY GET OrphanSelected()
      Set OrphanSelected = SESSION("ADJ_ORPHAN_ADJUSTMENT_SELECTED")
    END PROPERTY    
    PUBLIC PROPERTY SET OrphanSelected(v)
      Set SESSION("ADJ_ORPHAN_ADJUSTMENT_SELECTED") = v
    END PROPERTY      

    PUBLIC FUNCTION IsThereDeletedAdjustmentErrors()
    
      IsThereDeletedAdjustmentErrors = FALSE
      
      If IsValidObject(DeletedAdjustmentRowset) Then
      
          If CBool(DeletedAdjustmentRowset.RecordCount>0) Then
          
              IsThereDeletedAdjustmentErrors = TRUE
              PopulateWarningRowsetInSession DeletedAdjustmentRowset
          End If
      End If
    END FUNCTION

    PUBLIC FUNCTION IsThereApprovedAdjustmentErrors()
    
      IsThereApprovedAdjustmentErrors = FALSE
      
      If IsValidObject(ApprovedAdjustmentRowset) Then
      
          If CBool(ApprovedAdjustmentRowset.RecordCount>0) Then
          
              IsThereApprovedAdjustmentErrors = TRUE
              PopulateWarningRowsetInSession ApprovedAdjustmentRowset
          End If
      End If
    END FUNCTION    
    
    PUBLIC FUNCTION DeleteAdjustment(EventArg,objIDs)

        Dim TrxSet

        DeleteAdjustment            = FALSE
        Set DeletedAdjustmentRowset  = Nothing
        
        On Error Resume Next
        
        If Form("Orphan") Then
          Set TrxSet = AdjustmentCatalog.CreateOrphanAdjustments(objIDs)
        Else
          Set TrxSet = AdjustmentCatalog.CreateAdjustmentTransactions(objIDs)
        End If  
        If Err.Number Then EventArg.Error.Save Err : Err.Clear : Exit Function
        
        Set DeletedAdjustmentRowset = trxset.DeleteAndSave(nothing)
        If Err.Number Then EventArg.Error.Save Err : Err.Clear :Exit Function
        
        DeleteAdjustment = TRUE
    END FUNCTION
    
 
    PRIVATE FUNCTION ApproveOrphanAdjustments(EventArg,objIDs)
    
        Dim lngIDSession
        
        ApproveOrphanAdjustments    = FALSE
        Set OrphanAdjustmentRowset  = ProductView.Properties.RowSet ' Save the rowset into the session
        Set OrphanSelected          = objIDs
        
        mdm_TerminateDialogAndExecuteDialog FrameWork.Dictionary.Item("ADJUSTMENT_ORPHAN_ISSUE_DIALOG").Value
        
        ApproveOrphanAdjustments    = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION ApproveAdjustment(EventArg,objIDs)

        Dim TrxSet, Rs

        ApproveAdjustment = FALSE
        
        If Form("Orphan") Then
            ApproveAdjustment = ApproveOrphanAdjustments(EventArg,objIDs)
            Exit Function
        End If
        
        On Error Resume Next
        Set TrxSet  = AdjustmentCatalog.CreateAdjustmentTransactions(objIDs)
        If Err.Number Then EventArg.Error.Save Err : Exit Function
        
        Set ApprovedAdjustmentRowset = trxset.ApproveAndSave(nothing)
        If Err.Number Then EventArg.Error.Save Err : Exit Function

        ApproveAdjustment = TRUE
    END FUNCTION
    
    PRIVATE FUNCTION butApprove_Click(EventArg)
    
        butApprove_Click = PerformActionOnSelectedSession(EventArg,"APPROVE")
    END FUNCTION
    
    PUBLIC FUNCTION GetAdjustmentStatusDescription(strCode)
    
        Dim strStatusesAsCsv, i
        strStatusesAsCsv = Split(FrameWork.Dictionary.Item("TEXT_ADJUSTMENT_STATUSES").Value,",")
        
        For i=0 To UBound(strStatusesAsCsv)
        
            If strCode=Mid(Trim(strStatusesAsCsv(i)),1,1) Then
            
                GetAdjustmentStatusDescription = Mid(Trim(strStatusesAsCsv(i)),3)
                Exit Function
            End If
        Next
        GetAdjustmentStatusDescription = strStatusesAsCsv(UBound(strStatusesAsCsv))
    END FUNCTION
    
    PUBLIC FUNCTION GetManagableAdjustmentsAsRowset(lngSessionID, lngIdPiTemplate)
    
        Dim objMTFilter, strColumn
        
        If Len("" & lngSessionID) Then 
        
            If InStr(lngSessionID,"PARENT:") Then
            
                lngSessionID  = Replace(lngSessionID,"PARENT:","")
                strColumn     = "ID_PARENT_SESS"
            Else
                strColumn     = "id_sess"
            End If
            Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
            objMTFilter.Add strColumn, MT_OPERATOR_TYPE_EQUAL, CStr(lngSessionID)
            
            If Len("" & lngIdPiTemplate) Then
                objMTFilter.Add "id_pi_template", MT_OPERATOR_TYPE_EQUAL, CLNG(lngIdPiTemplate)            
            End If
            
            objMTFilter.Add "LanguageCode", MT_OPERATOR_TYPE_EQUAL, Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").LanguageId

            Set GetManagableAdjustmentsAsRowset = AdjustmentCatalog.GetAdjustedTransactionsAsRowset((objMTFilter))
        Else    
            Const ORPHAN_COLUMN_NAME =  "ID_SESS"
            If Form("Orphan") Then
                Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
                objMTFilter.AddIsNull ORPHAN_COLUMN_NAME
                Set GetManagableAdjustmentsAsRowset = AdjustmentCatalog.GetOrphanAdjustmentsAsRowset((objMTFilter))
            Else
				'Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
				'objMTFilter.Add "LanguageCode", MT_OPERATOR_TYPE_EQUAL, Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").LanguageId
				Set objMTFilter = nothing
                Set GetManagableAdjustmentsAsRowset = AdjustmentCatalog.GetAdjustedTransactionsAsRowset((objMTFilter))            
            End If
        End If    
    END FUNCTION
    
    PUBLIC FUNCTION ClearCachedData()  
    
        Dim TransactionUIFinder
        Set TransactionUIFinder = New CTransactionUIFinder
        TransactionUIFinder.CreateNewReportHelper()
        ClearCachedData = TRUE
    END FUNCTION
 
    PUBLIC FUNCTION Save(EventArg)
    
        Dim objWarningsRowset
        
        Save = FALSE
        EventArg.Error.Clear
        
        If Calculated Then
        
            On Error Resume Next
            
            Set TransactionSet.ReasonCode = GetReasonCodeByID(CLng(Service.Properties("AdjReasonCode").Value))
            If(Err.Number) Then EventArg.Error.Save Err : Exit Function

            Set TransactionSet.ReasonCode = GetReasonCodeByID(CLng(Service.Properties("AdjReasonCode").Value))
            TransactionSet.Description    = Service.Properties("AdjDescription").Value
            
            Set objWarningsRowset = TransactionSet.SaveAdjustments(null)
            If(Err.Number) Then EventArg.Error.Save Err : Exit Function
        
            If(objWarningsRowset.RecordCount)Then
                Set SaveWarningRowset = objWarningsRowset
            Else
                Set objWarningsRowset = Nothing
            End If
            Save = TRUE
        Else
            NotReadyToBeSave EventArg
            Save = FALSE
        End If
    END FUNCTION
    
    PUBLIC FUNCTION SaveAll(EventArg)
    
        Dim objWarningsRowset
        
        SaveAll = FALSE
        EventArg.Error.Clear
        
        If Calculated Then
			'Fix for CR#12586. Adjustment shouldn't be saved if warnings occured
			' IF( WarningsCounter>0 ) THEN
			' 	WarningsOccuredCanNotSave EventArg
			' 	SaveAll = FALSE
			' 	EXIT FUNCTION
			' END IF
            On Error Resume Next
            
            Set TransactionSet.ReasonCode = GetReasonCodeByID(CLng(Service.Properties("AdjReasonCode").Value))
            If(Err.Number) Then EventArg.Error.Save Err : Exit Function

            Set TransactionSet.ReasonCode = GetReasonCodeByID(CLng(Service.Properties("AdjReasonCode").Value))
            TransactionSet.Description    = Service.Properties("AdjDescription").Value
            
            dim objProgress, message
			set objProgress = nothing
			
            Set objWarningsRowset = TransactionSet.SaveAdjustments(objProgress)
            If(Err.Number) Then 
				message = Err.Description
				 
				Response.Redirect FrameWork.Dictionary.Item("ADJUSTMENT_SAVED_ADJUSTMENT_WARNING_DIALOG").Value & "?DialogType=" & "BulkAdjustment" & "&Message=" & Server.URLEncode(message)
				Exit function
			 End If
			
			If(objWarningsRowset.RecordCount)Then
				Set SaveWarningRowset = objWarningsRowset
			Else
				Set objWarningsRowset = Nothing
			End If
          
             
			TransactionUIFinder.UpdateFoundRowSet 
   			If IsValidObject(AdjustmentHelper.SaveWarningRowset) Then ' We have a message for the user
			    Response.Redirect FrameWork.Dictionary.Item("ADJUSTMENT_SAVED_ADJUSTMENT_WARNING_DIALOG").Value & "?DialogType=" & "BulkAdjustment"
			Else
	    Response.Redirect FrameWork.Dictionary.Item("ADJUSTMENT_SAVED_ADJUSTMENT_WARNING_DIALOG").Value & "?DialogType=" & "BulkAdjustment" & "&Message=" & Server.URLEncode(FrameWork.Dictionary.Item("TEXT_ADJUSTMENT(s)_HAS_BEEN_APPROVED").Value)
			End If
			
            SaveAll = TRUE
        Else
            NotReadyToBeSave EventArg
            SaveAll = FALSE
        End If
    END FUNCTION
    
    PUBLIC FUNCTION NotReadyToBeSave(EventArg)
        EventArg.Error.Number      = 1040+vbObjectError
        EventArg.Error.Description = FrameWork.Dictionary.Item("MAM_ERROR_1040")
        NotReadyToBeSave           = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION WarningsOccuredCanNotSave(EventArg)
        EventArg.Error.Number      = 2012+vbObjectError
        EventArg.Error.Description = FrameWork.Dictionary.Item("MAM_ERROR_2012")
        WarningsOccuredCanNotSave  = TRUE
    END FUNCTION
    
    ' Do not reset the AdjustmentTypes object
    PUBLIC FUNCTION Reset()
    
        Calculated                                  = FALSE ' Mark as not calculated yet
        OutputPropertiesGenericHTMLTemplate         = ""
        InputPropertiesGenericHTMLTemplate          = ""    
        Set OutPutPropertiesAsRowset                = Nothing
        Set TransactionSet                          = Nothing
        Set SaveWarningRowset                       = Nothing
        Reset                                       = TRUE
    END FUNCTION

    PUBLIC FUNCTION LoadAdjustmentTypes(lngPriceAbleItemID, strSessionIDs, MSIXService) ' As Boolean
    
        Dim strSessionID, Prop, PriceAbleItemTemplate, booError

		LoadAdjustmentTypes = FALSE
		Reset        
        Set AdjustmentTypes = AdjustmentCatalog.GetAdjustmentTypesForPITemplate(lngPriceAbleItemID,false)', Not ParentMode) ' 2 parameter get the children bulk mode...
        
        booError = Not IsValidObject(AdjustmentTypes)
        
        If Not booError Then If AdjustmentTypes.Count=0 Then booError = TRUE           
        
        If booError Then
        
            Set PriceAbleItemTemplate   = FrameWork.ProductCatalog.GetPriceAbleItem(lngPriceAbleItemID)
            EventArg.Error.Description  = PreProcess(FrameWork.Dictionary.Item("MAM_ERROR_1041").Value,Array("NAME",PriceAbleItemTemplate.Name))
            EventArg.Error.Number       = 1041
						Form.RouteTo = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_ADJUSTMENT_NOT_SUPPORTED"), EventArg.Error.Description,mam_GetDictionary("ADJUSTMENT_PVB_DIALOG"))
						Exit Function
        End If
                
        SetTransactionIDs strSessionIDs
        
        Service.Properties.Clear
        
        Service.Properties.Add "UserWarningMessage" , "string", 0 , False, Empty
        Service.Properties("UserWarningMessage").Value = Empty
            
        Service.Properties.Add "AdjType" , "string", 0 , True, Empty
        Service.Properties("AdjType").AddValidListOfValues GetAdjustmentTypesAsValidListOfValues()
        Service.Properties("AdjType").Caption = FrameWork.Dictionary.Item("TEXT_ADJUSTMENT_TYPE").Value
        
        Service.Properties.Add "AdjReasonCode" , "string", 0 , FALSE, Empty
        Service.Properties("AdjReasonCode").Caption = FrameWork.Dictionary.Item("TEXT_ADJUSTMENT_REASON_CODE").Value
        
        Service.Properties.Add "AdjDescription" , "string", 1900 , FALSE, Empty
        Service.Properties("AdjDescription").Caption = FrameWork.Dictionary.Item("TEXT_ADJUSTMENT_DESCRIPTION").Value
    
        Service.Properties.Add "AdjApplyBulk" , "Boolean", 0 , False, Empty
        Service.Properties("AdjApplyBulk").Value = FALSE
    
        Service.Properties.Add "PriceAbleItemType" , "String", 0 , False, Empty
        Service.Properties("PriceAbleItemType").Value = TransactionUIFinder.SelectedPriceAbleItemTypeName
        
 '       Service.Properties.Add "PriceAbleItemTypeTitle" , "String", 255 , False, Empty
'        Service.Properties("PriceAbleItemTypeTitle").Value = FrameWork.GetPricteAbleItemTypeFQN(Session(SESSION_ADJUTSMENT_PRICEABLEITEM_FQN))
        
        Service.Properties.Add "ChildType" , "String", 0 , False, Empty        
        Service.Properties("ChildType").Value = Form("ChildType") 
        
        If(BulkMode)Then
        '    PopulateServiceWithTransactionFields
        End If
        
        LoadAdjustmentTypes = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION LoadAllAdjustmentTypes(lngPriceAbleItemID, strSessionIDs, MSIXService) ' As Boolean
    
        Dim strSessionID, Prop, PriceAbleItemTemplate, booError

		LoadAllAdjustmentTypes = FALSE
		        
        Set AdjustmentTypes = AdjustmentCatalog.GetAdjustmentTypesForPITemplate(lngPriceAbleItemID,true)', Not ParentMode) ' 2 parameter get the children bulk mode...
        
        booError = Not IsValidObject(AdjustmentTypes)
        
        If Not booError Then If AdjustmentTypes.Count=0 Then booError = TRUE           
        
        If booError Then
        
            Set PriceAbleItemTemplate   = FrameWork.ProductCatalog.GetPriceAbleItem(lngPriceAbleItemID)
            EventArg.Error.Description  = PreProcess(FrameWork.Dictionary.Item("MAM_ERROR_1041").Value,Array("NAME",PriceAbleItemTemplate.Name))
            EventArg.Error.Number       = 1041
						Form.RouteTo = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_ADJUSTMENT_NOT_SUPPORTED"), EventArg.Error.Description,mam_GetDictionary("ADJUSTMENT_PVB_DIALOG"))
						Exit Function
        End If
                
        SetTransactionIDs strSessionIDs
        
        Service.Properties.Clear
        
        Service.Properties.Add "UserWarningMessage" , "string", 0 , False, Empty
        Service.Properties("UserWarningMessage").Value = Empty
            
        Service.Properties.Add "AdjType" , "string", 0 , True, Empty
        Service.Properties("AdjType").AddValidListOfValues GetAdjustmentTypesAsValidListOfValues()
        Service.Properties("AdjType").Caption = FrameWork.Dictionary.Item("TEXT_ADJUSTMENT_TYPE").Value
        
        Service.Properties.Add "AdjReasonCode" , "string", 0 , FALSE, Empty
        Service.Properties("AdjReasonCode").Caption = FrameWork.Dictionary.Item("TEXT_ADJUSTMENT_REASON_CODE").Value
        
        Service.Properties.Add "AdjDescription" , "string", 1900 , FALSE, Empty
        Service.Properties("AdjDescription").Caption = FrameWork.Dictionary.Item("TEXT_ADJUSTMENT_DESCRIPTION").Value
    
        Service.Properties.Add "AdjApplyBulk" , "Boolean", 0 , False, Empty
        Service.Properties("AdjApplyBulk").Value = FALSE
    
        Service.Properties.Add "PriceAbleItemType" , "String", 0 , False, Empty
        Service.Properties("PriceAbleItemType").Value = TransactionUIFinder.SelectedPriceAbleItemTypeName
        
 '       Service.Properties.Add "PriceAbleItemTypeTitle" , "String", 255 , False, Empty
'        Service.Properties("PriceAbleItemTypeTitle").Value = FrameWork.GetPricteAbleItemTypeFQN(Session(SESSION_ADJUTSMENT_PRICEABLEITEM_FQN))
        
        Service.Properties.Add "ChildType" , "String", 0 , False, Empty        
        Service.Properties("ChildType").Value = Form("ChildType") 
        
        If(BulkMode)Then
        '    PopulateServiceWithTransactionFields
        End If
        
        LoadAllAdjustmentTypes = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION SetTransactionIDs(strSessionIDs)
    
        Dim strSessionID
        'strSessionIDs = "16000,16006"
    
        Set SessionIDs = CreateObject("Metratech.MTCollection")        
        
        For Each strSessionID In Split(strSessionIDs,",")
        
            If(Len(strSessionID))Then
            
                SessionIDs.Add(strSessionID)
            End If
        Next
        SetTransactionIDs = TRUE
    END FUNCTION

    
    PUBLIC FUNCTION GetAdjustmentType(strAdjustmentTypeName)
    
        Dim AdjustmentType
        
        Set GetAdjustmentType = Nothing
        
        For Each AdjustmentType In AdjustmentTypes
        
            If AdjustmentType.Name = strAdjustmentTypeName Then
            
                Set GetAdjustmentType = AdjustmentType
                Exit Function
            End If
        Next        
    END FUNCTION
    
    PUBLIC FUNCTION GetSelectedAdjustmentType()
    
        Set GetSelectedAdjustmentType =  GetAdjustmentType(Service.Properties("AdjType").Value)   
    END FUNCTION
    
    PUBLIC FUNCTION SelectAdjustmentType(strAdjustmentTypeName)
    
        Dim AdjustmentType
        Set AdjustmentType   = GetAdjustmentType(strAdjustmentTypeName)
        Reset
        SelectAdjustmentType = SelectAdjustmentOneType(AdjustmentType) 
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
    
    PRIVATE FUNCTION SelectAdjustmentOneType(AdjustmentType)
            
        Dim Prop, MSIXProperty, booOK, strHTMLTemplate
        
        SelectAdjustmentOneType = FALSE
      
        RemovePropertyTagged "INPUT"
        
        CreateTransactionSet AdjustmentType
        
        CONST INPUT_PROPERTIES_HTML_TEMPLATE  = "<MDMHTML><tr><td class='captionEW'><mdmlabel name='[NAME]' type='Caption'></mdmlabel>:</td><td class='field'><INPUT Type='Text' Class='clsInputBox' name='[NAME]'></td></tr>[CRLF]"

        For Each Prop in AdjustmentType.RequiredInputs
        
            Service.Properties.Add Prop.Name, Prop.DataTypeAsString, prop.Length , TRUE , Prop.DefaultValue ' Prop.DataTypeAsString, Prop.Length 
            
            Service.Properties(Prop.Name).Caption   = Prop.DisplayName
            Service.Properties(Prop.Name).Tag       = "INPUT" ' To retreive the input properties
            Service.Properties("AdjDescription").Value = TransactionSet.Description
            strHTMLTemplate                         = strHTMLTemplate & PreProcess(INPUT_PROPERTIES_HTML_TEMPLATE,Array("NAME",Prop.Name,"CRLF",vbNewLine))
        Next
 
        PopulateReasonCodeEnumType
        
        Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation  
        InputPropertiesGenericHTMLTemplate  = strHTMLTemplate        
        SelectAdjustmentOneType             = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION PopulateReasonCodeEnumType()
    
        PopulateReasonCodeEnumType = FALSE
        
        Dim objVars, ReasonCode
        Set objVars = mdm_CreateObject(CVariables)
        
        If IsValidObject(ReasonCodes) Then
        
            For Each ReasonCode In ReasonCodes
            
                objVars.Add ReasonCode.Name,ReasonCode.ID,,,ReasonCode.DisplayName
            Next        
            Service.Properties("AdjReasonCode").AddValidListOfValues objVars
        Else
            ' Clear the entrie if there are some
            If IsValidObject(Service.Properties("AdjReasonCode").EnumType) Then
            
                If IsValidObject(Service.Properties("AdjReasonCode").EnumType.Entries) Then
                
                    Service.Properties("AdjReasonCode").EnumType.Entries.Clear
                End If
            End If
        End If
        
        Service.Properties("AdjReasonCode").Required = TRUE
        
        PopulateReasonCodeEnumType = TRUE
    END FUNCTION
    
    PRIVATE FUNCTION GetAdjustmentTypesAsValidListOfValues() ' As CVariable
        
        Dim AdjustmentType, objVars
        Set objVars = mdm_CreateObject(CVariables)

        For Each AdjustmentType In AdjustmentTypes
        
            If(Len(AdjustmentType.Name))Then
            
                ' Put back this line when boris has introduced the filter
                objVars.Add AdjustmentType.Name,AdjustmentType.Name,,,AdjustmentType.DisplayName
            End If
        Next
        Set GetAdjustmentTypesAsValidListOfValues = objVars
    END FUNCTION       
    
    PUBLIC FUNCTION GenerateOutputPropertiesGenericHTMLTemplate()
    
        Dim Prop, MSIXProperty, booOK, strHTMLTemplate, Sess,  strPIndexedName, objAdjustmentTransactions, i, strValue
        Dim propValue
        GenerateOutputPropertiesGenericHTMLTemplate = FALSE
        
        CONST OUTPUT_PROPERTIES_HTML_TEMPLATE_HEADER  = "<MDMHTML><tr><td valign='top' align='right' >Output Properties : </td><TD><TABLE>"
        CONST OUTPUT_PROPERTIES_HTML_TEMPLATE_FOOTER  = "</TABLE></TD></TR>"
        
        CONST OUTPUT_PROPERTIES_HTML_TEMPLATE         = "<tr><td>[PROPERTY_NAME]:</td><td>&nbsp;[PROPERTY_VALUE]</td></tr>[CRLF]"
        
        RemovePropertyTagged "OUTPUT"
        OutputPropertiesGenericHTMLTemplate = "" ' Clear for now
        Set OutPutPropertiesAsRowset        = Nothing
        dim totalajamount
        
        If Calculated Then
            '
            ' Generate the output properties summary
            '
            strHTMLTemplate = ""
          
            For Each Prop in TransactionSet.Outputs
							if	(InStr(1, UCASE(CStr(Prop.Name)), "AJ_TAX", 1) = 0) AND (InStr(1, UCASE(CStr(Prop.Name)), "TOTALTAXADJUSTMENTAMOUNT", 1) = 0) then
                strHTMLTemplate = strHTMLTemplate & PreProcess(OUTPUT_PROPERTIES_HTML_TEMPLATE,Array("PROPERTY_NAME",Prop.DisplayName,"PROPERTY_VALUE",ABS(CDBL(Prop.Value)),"CRLF",vbNewLine))
              end if
              if(InStr(1, UCASE(CStr(Prop.Name)), "TOTALADJUSTMENTAMOUNT", 1) <> 0) then
								totalajamount = CDBL(Prop.Value)
              end if
            Next
            OutputPropertiesGenericHTMLTemplate = OUTPUT_PROPERTIES_HTML_TEMPLATE_HEADER & strHTMLTemplate & "<TR><TD height='1' width='100%' bgcolor='silver'></TD></TR>"
            strHTMLTemplate = ""
            For Each Prop in TransactionSet.Outputs
							if (InStr(1, UCASE(CStr(Prop.Name)), "AJ_TAX", 1) <> 0  OR (InStr(1, UCASE(CStr(Prop.Name)), "TOTALTAXADJUSTMENTAMOUNT", 1) <> 0)) Then
								' only display adjustment amounts if they are greater than 0
								if (CDBL(Prop.Value) > 0) then
									strHTMLTemplate = strHTMLTemplate & PreProcess(OUTPUT_PROPERTIES_HTML_TEMPLATE,Array("PROPERTY_NAME",Prop.DisplayName,"PROPERTY_VALUE",ABS(CDBL(Prop.Value)),"CRLF",vbNewLine))
								end if
								if(InStr(1, UCASE(CStr(Prop.Name)), "TOTALTAXADJUSTMENTAMOUNT", 1) <> 0) then
									totalajamount = totalajamount + CDBL(Prop.Value)
								end if
              end if
            Next
            OutputPropertiesGenericHTMLTemplate = OutputPropertiesGenericHTMLTemplate & strHTMLTemplate &  "<TR><TD height='1' width='100%' bgcolor='silver'></TD></TR>"
            
            'display overall adjustment total
            OutputPropertiesGenericHTMLTemplate = OutputPropertiesGenericHTMLTemplate & PreProcess(OUTPUT_PROPERTIES_HTML_TEMPLATE,Array("PROPERTY_NAME","Total Adjustment Amount (With Taxes)","PROPERTY_VALUE",ABS(CDBL(totalajamount)),"CRLF",vbNewLine)) & OUTPUT_PROPERTIES_HTML_TEMPLATE_FOOTER

            '
            ' Stored the output properties details in a rowset
            '
            Set OutPutPropertiesAsRowset  = mdm_CreateObject(MT_SQL_ROWSET_SIMULATOR_PROG_ID)
            Set objAdjustmentTransactions = TransactionSet.GetAdjustmentTransactions()
            Set Sess                      = objAdjustmentTransactions(1)
            
            OutPutPropertiesAsRowset.Initialize objAdjustmentTransactions.Count, Sess.Outputs.Count
            OutPutPropertiesAsRowset.MoveFirst
            i=0
            For Each Prop in Sess.Outputs
                OutPutPropertiesAsRowset.Name(i) = Prop.DisplayName
                i=i+1
            Next
            For Each Sess in objAdjustmentTransactions          
                i=0
                For Each Prop in Sess.Outputs
                    
                    If Sess.IsAdjustable Then
                        strValue = "" & Prop.Value
                    Else
                        strValue = mam_GetDictionary("TEXT_CANNOT_BE_ADJUSTED_WITH_INPUT_PROPERTIES")
                    End If
                    OutPutPropertiesAsRowset.Value(i) = "" & strValue
                    i=i+1
                Next
                OutPutPropertiesAsRowset.MoveNext
            Next
        End If
        GenerateOutputPropertiesGenericHTMLTemplate = TRUE
    END FUNCTION
        
    PUBLIC FUNCTION UpdateInputProperties()
    
        UpdateInputProperties = FALSE
        
        Dim Prop
        
        For Each Prop in TransactionSet.Inputs ' Populate the MSIX Service object with the input property        
        
            Prop.Value = Service.Properties(Prop.Name).Value
        Next
        UpdateInputProperties = TRUE
    END FUNCTION
    
    ' PARENT-
    
    PUBLIC FUNCTION CreateTransactionSet(AdjustmentType)
          
        If(SessionIDs.Count)Then ' In the case on a child adjustment we do no have the selected children right from the beginning

            If BulkMode AND AdjustmentType.HasParent Then
                Set TransactionSet = AdjustmentType.CreateAdjustmentTransactionsForChildren(SessionIDs)
            Else            
                Set TransactionSet = AdjustmentType.CreateAdjustmentTransactions(SessionIDs)
            End If
        End If
        CreateTransactionSet = TRUE
    END FUNCTION
    
    PUBLIC PROPERTY GET TransactionSet()
      Set TransactionSet = SESSION("ADJ_TRANSACTION_SET")
    END PROPERTY
    
    PUBLIC PROPERTY SET TransactionSet(v)
      Set SESSION("ADJ_TRANSACTION_SET") = v 
    END PROPERTY
    
    PUBLIC PROPERTY GET AdjustmentTypes()
        Set AdjustmentTypes = SESSION("ADJ_ADJUSTMENT_TYPE")
    END PROPERTY    
    PUBLIC PROPERTY SET AdjustmentTypes(v)
        Set SESSION("ADJ_ADJUSTMENT_TYPE") = v
    END PROPERTY
  
    PUBLIC PROPERTY GET SessionIDs()
      Set SessionIDs = SESSION("ADJ_SESSION_IDS")
    END PROPERTY
    PUBLIC PROPERTY SET SessionIDs(v)
      Set SESSION("ADJ_SESSION_IDS") = v 
    END PROPERTY    
    
    PUBLIC PROPERTY GET SaveWarningRowset()
      Set SaveWarningRowset = SESSION("ADJ_SaveWarningRowset")
    END PROPERTY
    PUBLIC PROPERTY SET SaveWarningRowset(v)
      Set SESSION("ADJ_SaveWarningRowset") = v 
    END PROPERTY      
    
    PUBLIC PROPERTY GET OutPutPropertiesAsRowset()
      Set OutPutPropertiesAsRowset = SESSION("ADJ_OUTPUT_PROPERTIES_ROWSET")
    END PROPERTY
    PUBLIC PROPERTY SET OutPutPropertiesAsRowset(v)
      Set SESSION("ADJ_OUTPUT_PROPERTIES_ROWSET") = v       
    END PROPERTY        
    
    PUBLIC PROPERTY GET BulkMode()
        BulkMode = SESSION("ADJ_BULK_MODE")
    END PROPERTY    
    PUBLIC PROPERTY LET BulkMode(v)
        SESSION("ADJ_BULK_MODE") = v
    END PROPERTY

    PUBLIC PROPERTY GET ParentMode()
        ParentMode = SESSION("ADJ_PARENT_MODE")
    END PROPERTY    
    PUBLIC PROPERTY LET ParentMode(v)
        SESSION("ADJ_PARENT_MODE") = v
    END PROPERTY
    
        
    PUBLIC PROPERTY GET WarningsCounter()
        If IsEmpty(SESSION("WARNING_COUNTER")) Then WarningsCounter=0
        WarningsCounter = SESSION("WARNING_COUNTER")
    END PROPERTY
    PUBLIC PROPERTY LET WarningsCounter(v)
        SESSION("WARNING_COUNTER") = v
    END PROPERTY
    
    PUBLIC PROPERTY GET InputPropertiesGenericHTMLTemplate()
        InputPropertiesGenericHTMLTemplate = SESSION("ADJ_INPUT_HTML_TEMPLATE")
    END PROPERTY
    PUBLIC PROPERTY LET InputPropertiesGenericHTMLTemplate(v)
        SESSION("ADJ_INPUT_HTML_TEMPLATE") = v
        FrameWork.Dictionary.Add "ADJUSTMENT_INPUT_PROPERTIES"  , v
    END PROPERTY    
    
    PUBLIC PROPERTY GET OutputPropertiesGenericHTMLTemplate()
        OutputPropertiesGenericHTMLTemplate = SESSION("ADJ_OUTPUT_HTML_TEMPLATE")
    END PROPERTY
    PUBLIC PROPERTY LET OutputPropertiesGenericHTMLTemplate(v)
        SESSION("ADJ_OUTPUT_HTML_TEMPLATE") = v
        FrameWork.Dictionary.Add "ADJUSTMENT_OUTPUT_PROPERTIES" , v
    END PROPERTY
    
    PUBLIC PROPERTY GET SelectedIDs()
        SelectedIDs = SESSION("ADJ_SelectedIDs")
    END PROPERTY
    PUBLIC PROPERTY LET SelectedIDs(v)
        SESSION("ADJ_SelectedIDs") = v
    END PROPERTY
     
    PUBLIC PROPERTY GET Calculated()
        Calculated = SESSION("ADJ_CALCULATED")
    END PROPERTY
    PUBLIC PROPERTY LET Calculated(v)
        SESSION("ADJ_CALCULATED") = v
    END PROPERTY        
    
    PUBLIC FUNCTION Clear()
      Set AdjustmentTypes = Nothing
      Set TransactionSet  = Nothing
      Clear               = TRUE
    END FUNCTION

    PUBLIC PROPERTY GET AdjustmentCatalog()
        Set AdjustmentCatalog = FrameWork.AdjustmentCatalog()
    END PROPERTY

    PUBLIC FUNCTION CalculateAndUpdateServiceProperties()    
        
        UpdateInputProperties
        
        Dim objWarningsRowset
        Set objWarningsRowset = TransactionSet.CalculateAdjustments(Nothing) ' ProgressBar        
        WarningsCounter       = objWarningsRowset.RecordCount
        If(WarningsCounter)Then
			    Set SaveWarningRowset = objWarningsRowset
			    objWarningsRowset.MoveFirst
          PopulateWarningRowsetInSession objWarningsRowset
        End If
        Calculated                          = TRUE
        GenerateOutputPropertiesGenericHTMLTemplate
        CalculateAndUpdateServiceProperties = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION PopulateWarningRowsetInSession(objWarningsRowset)

        Dim accountID
        accountID = mam_GetSubscriberAccountID()
        Dim fieldID
        fieldID = mam_GetFieldIDFromAccountID(accountID)
                         
        Do While Not objWarningsRowset.EOF
          
          On Error Resume Next
            BatchError.Add accountID, fieldID, "<b>Session ID:</b>  " & objWarningsRowset.Value("id_sess") & "&nbsp;&nbsp;&nbsp;&nbsp;<b>Message:</b>  " & objWarningsRowset.Value("Description")
          If err.number <> 0 Then
            BatchError.Add accountID, fieldID, objWarningsRowset.Value("Description")
          End If  
          On Error Goto 0
          
          objWarningsRowset.MoveNext
        Loop
        
        Set Session("LAST_BATCH_ERRORS") = BatchError.GetBatchErrorRS()
        PopulateWarningRowsetInSession   = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION GetAdjHTMLTemplateFileBasedOnAdjType()
        Dim strDicEntry
        
        If Service.Properties.Exist("AdjType") Then
        
            strDicEntry                           = ADJUSTMENT_TEMPLATE_DICTIONARY_PREFIX & Service.Properties("PriceAbleItemType") & ":" & Service.Properties("AdjType").Value
            GetAdjHTMLTemplateFileBasedOnAdjType  = FrameWork.Dictionary.Item(strDicEntry).Value
        End If
    END FUNCTION
    
    PUBLIC FUNCTION ParentRowset()
    
        Set ParentRowset = Session(SESSION_ADJ_PARENT_ROWSET)
    END FUNCTION
  
    PUBLIC FUNCTION Rowset()
        If ParentMode Then
            Set Rowset = Session(SESSION_ADJ_PARENT_ROWSET)
        Else
            Set Rowset = Session(SESSION_ADJ_CHILDREN_ROWSET)
        End If
    END FUNCTION
    
'    PUBLIC FUNCTION PopulateServiceWithTransactionFields()
'        Dim i
'        
'        Dim objRowset
'        Set objRowset = Rowset()
'        
'        For i=0 To objRowset.Count-1 ' Populate the MSIX Service object with the transaction value - Read Only
'        
'            Service.Properties.Add "transaction_" & objRowset.Name(i),"string",255, False, Empty
'            Service.Properties("transaction_" & objRowset.Name(i)).Value = objRowset.Value(i)
'        Next
'        PopulateServiceWithTransactionFields = TRUE
'    END FUNCTION    
      
    PUBLIC FUNCTION FindTransactionInRowset(lngSessionID)
        Dim r
        Set r = ParentRowset()
        FindTransactionInRowset = FALSE
        r.MoveFirst
        Do While Not r.Eof
          If(CStr(r.Value("SessionID"))=lngSessionID)Then
              FindTransactionInRowset = TRUE
              Exit Function
          End If
          r.MoveNext
        Loop
    END FUNCTION
    
    PUBLIC FUNCTION GetReasonCodeByID(ByVal lngRSID)
    
      Dim ReasonCode
      
      For Each ReasonCode In ReasonCodes
      
          If ReasonCode.ID = lngRSID Then
          
              Set GetReasonCodeByID = ReasonCode
              Exit Function
          End If
      Next
    END FUNCTION
    
    PUBLIC PROPERTY GET ReasonCodes()
        If IsValidObject(TransactionSet) Then
            Set ReasonCodes = TransactionSet.GetApplicableReasonCodes()
        End If
    END PROPERTY
    
    PUBLIC FUNCTION SetJavaScriptInitialize(strAdjustmentDialogType)
    
        Select Case UCase(strAdjustmentDialogType)
            Case "PARENT":
'            alert(""coucou"");
                Form.JavaScriptInitialize = "mdm_ExecuteJavaScript('parent.frameTransactionsPVB.location.href=parent.frameTransactionsPVB.location.href;document.location.href=""[BLANK_DIALOG]""');"
                Form.JavaScriptInitialize = PreProcess(Form.JavaScriptInitialize,Array("BLANK_DIALOG",mam_GetDictionary("BLANK_DIALOG")))          
                
            Case "BULK":
                Form.JavaScriptInitialize = "mdm_ExecuteJavaScript('parent.frameTransactionsPVB.location.href=parent.frameTransactionsPVB.location.href;document.location.href=""[BLANK_DIALOG]""');"
                Form.JavaScriptInitialize = PreProcess(Form.JavaScriptInitialize,Array("BLANK_DIALOG",mam_GetDictionary("BLANK_DIALOG")))
                
            Case "CHILDREN":
                Form.JavaScriptInitialize = "mdm_ExecuteJavaScript('parent.frameTransactionsPVB.location.href=""[URL]"";document.location.href=""[BLANK_DIALOG]""');"
                Form.JavaScriptInitialize = PreProcess(Form.JavaScriptInitialize,Array("URL",mam_GetDictionary("ADJUSTMENT_PVB_DIALOG"),"BLANK_DIALOG",mam_GetDictionary("BLANK_DIALOG")))
        End Select
    END FUNCTION
      
    PUBLIC FUNCTION SetRouteToForConfirmDialog(strDialogType, strMessage)

        If IsValidObject(AdjustmentHelper.SaveWarningRowset) Then ' We have a message for the user
        
            Form.RouteTo = FrameWork.Dictionary.Item("ADJUSTMENT_SAVED_ADJUSTMENT_WARNING_DIALOG").Value & "?DialogType=" & strDialogType
        Else
        Form.RouteTo = FrameWork.Dictionary.Item("ADJUSTMENT_SAVED_ADJUSTMENT_WARNING_DIALOG").Value & "?DialogType=" & strDialogType & "&Message=" & Server.URLEncode(strMessage)
        End If
        TransactionUIFinder.UpdateFoundRowSet ' -- Force to reload the transaction info now that we have adjusted at least one
        SetRouteToForConfirmDialog = TRUE
    END FUNCTION

END CLASS

%>

