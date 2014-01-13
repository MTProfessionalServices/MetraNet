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

PUBLIC CONST REBILL_UNKNOWN_VALUE_FOR_IMPUT_PROPERTY = "Unknown Account"

' Dictionary collection for localization REBILL_ACTIONTYPE        
PUBLIC CONST REBILL_ACTIONTYPE_METER_TO_UNKNOWN_ACCOUNT         = 1 ' Must Start At 1 to match a dictionary collection
PUBLIC CONST REBILL_ACTIONTYPE_EXTERNAL_IDENTIFIER              = 2
PUBLIC CONST REBILL_ACTIONTYPE_ACCOUNT_ID                       = 3
PUBLIC CONST REBILL_ACTIONTYPE_INTERNAL_IDENTIFIER              = 4
PUBLIC CONST REBILL_ACTIONTYPE_MAX_VALUE                        = 5

CLASS CReBillHelper
  
	PUBLIC PROPERTY GET SessionIDs()
      Set SessionIDs = SESSION("ADJ_SESSION_IDS")
    END PROPERTY
    
    PUBLIC PROPERTY SET SessionIDs(v)
      Set SESSION("ADJ_SESSION_IDS") = v 
    END PROPERTY    
    
   
    PUBLIC FUNCTION GenerateUI()
    
        Dim strHTMLTemplate, Prop
        dim sd, accids
        set sd = TransactionSet.ServiceDefinition
        set accids = sd.AccountIdentifiers
        
        dim externalname_name
        dim externalnamespace_name
        dim internalid_name
        dim identifier
        
        externalname_name = ""
        externalnamespace_name = ""
        internalid_name = ""
                
        
        'public enum AccountIdentifierType
				'{
				'	ACCOUNT_ID, ACCOUNT_NAME, ACCOUNT_NAMESPACE
				'}
        
        for Each identifier in accids
					if identifier.IdentifierType = 1 Then
						externalname_name = identifier.MSIXProperty.Name
					else If identifier.IdentifierType = 2 Then
						externalnamespace_name = identifier.MSIXProperty.Name
					else If identifier.IdentifierType = 0  Then
						internalid_name = identifier.MSIXProperty.Name
					End If
					End If
					End If
				Next
        
        RemovePropertyTagged "INPUT"
        
        CONST INPUT_PROPERTIES_HTML_TEMPLATE  = "<MDMHTML><tr><td class='captionEW'><mdmlabel name='[NAME]' type='Caption'></mdmlabel>:</td><td class='field'><INPUT Type='Text' name='[NAME]'></td></tr>[CRLF]"
        CONST INPUT_ACCOUNT_ID_HTML_TEMPLATE  = "<MDMHTML><tr><td class='captionEW'><mdmlabel name='[NAME]' type='Caption'></mdmlabel>:</td><td class='field'><input id='[NAME]' name='[NAME]' type='text'><a href=""JavaScript:getFrameMetraNet().getSelection('setSelection','[NAME]');"" name='sel[NAME]' id='sel[NAME]'><img src='/Res/Images/icons/find.png' alt='Select Account' border='0' /></a></td></tr>[CRLF]"

        Select Case Service.Properties("ActionType").Value
        
            CASE REBILL_ACTIONTYPE_METER_TO_UNKNOWN_ACCOUNT         :
            
            CASE REBILL_ACTIONTYPE_EXTERNAL_IDENTIFIER              :            
            
                For Each Prop in TransactionSet.AccountIdentifiers  
										if Prop.Name = externalname_name Then
									    Service.Properties.Add Prop.Name, Prop.DataTypeAsString, prop.Length , prop.Required, Empty ' Prop.DataTypeAsString, Prop.Length 
										  Service.Properties(Prop.Name).Caption   = Prop.Name ' There is no localization for this properties. See Boris
											Service.Properties(Prop.Name).Tag       = "INPUT" ' To retreive the input properties
											strHTMLTemplate                         = strHTMLTemplate & PreProcess(INPUT_PROPERTIES_HTML_TEMPLATE,Array("NAME",Prop.Name,"CRLF",vbNewLine))
										End If
                Next
						CASE REBILL_ACTIONTYPE_INTERNAL_IDENTIFIER              :            
            
                For Each Prop in TransactionSet.AccountIdentifiers  
										if Prop.Name = internalid_name Then
									    Service.Properties.Add Prop.Name, MSIXDEF_TYPE_STRING, prop.Length , prop.Required, Empty ' Prop.DataTypeAsString, Prop.Length 
										  Service.Properties(Prop.Name).Caption   = Prop.Name ' There is no localization for this properties. See Boris
											Service.Properties(Prop.Name).Tag       = "INPUT" ' To retreive the input properties
											strHTMLTemplate                          = strHTMLTemplate & PreProcess(INPUT_ACCOUNT_ID_HTML_TEMPLATE,Array("NAME",Prop.Name,"CRLF",vbNewLine))
										End If
                Next            
            
            ' IF none of the proeprties are marked as either external or internal identifiers - we also
            ' support setting MetraNet account id directly. In this case id resolution to account name will happen
            ' before reassign operation.
            CASE REBILL_ACTIONTYPE_ACCOUNT_ID                       :            

                Service.Properties.Add "_ACCOUNTID", MSIXDEF_TYPE_STRING, 255 , TRUE, Empty ' Prop.DataTypeAsString, Prop.Length
                Service.Properties("_ACCOUNTID").Caption = FrameWork.Dictionary.Item("TEXT_ACCOUNT_ID").Value
                Service.Properties("_ACCOUNTID").Tag     = "INPUT" ' To retreive the input properties
                strHTMLTemplate                          = strHTMLTemplate & PreProcess(INPUT_ACCOUNT_ID_HTML_TEMPLATE,Array("NAME","_ACCOUNTID","CRLF",vbNewLine))

            CASE REBILL_ACTIONTYPE_MAX_VALUE                        :
        End Select

        Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation  
        InputPropertiesGenericHTMLTemplate  = strHTMLTemplate        
        
        GenerateUI = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION Save(EventArg)
        
        Dim MSIXProp, lngAccountID, sessionID

        Save = FALSE
		For Each sessionID In SessionIDs		
			
			CreateTransactionSet sessionID
        	Select Case Service.Properties("ActionType").Value
	        
				CASE REBILL_ACTIONTYPE_METER_TO_UNKNOWN_ACCOUNT         :
					' Code added on 06/02/2008 to implement reassign to an unknown account
						lngAccountID = 0			  
					TransactionSet.AccountID = lngAccountID
	            
				CASE REBILL_ACTIONTYPE_EXTERNAL_IDENTIFIER              :
				
					For Each MSIXProp In Service.Properties
	                
						If MSIXProp.Tag="INPUT" Then TransactionSet.AccountIdentifiers.Item(MSIXProp.Name).Value = MSIXProp.Value
						If Err.Number Then EventArg.Error.Save Err : Exit Function
					Next
				
				CASE REBILL_ACTIONTYPE_INTERNAL_IDENTIFIER              :
	            
					For Each MSIXProp In Service.Properties
	          FrameWork.DecodeFieldID Service.Properties(MSIXProp.Name).Value, lngAccountID
						If MSIXProp.Tag="INPUT" Then TransactionSet.AccountIdentifiers.Item(MSIXProp.Name).Value = lngAccountID
						If Err.Number Then EventArg.Error.Save Err : Exit Function
					Next
	      
	                
				CASE REBILL_ACTIONTYPE_ACCOUNT_ID                       :                
	            
					FrameWork.DecodeFieldID Service.Properties("_ACCOUNTID").Value, lngAccountID
					TransactionSet.AccountID = lngAccountID
	                  
				
			End Select
	        
			TransactionSet.Description      = Service.Properties("Description").Value
			Set TransactionSet.ReasonCode   = FrameWork.AdjustmentCatalog.GetReasonCode(Service.Properties("ReasonCode").Value)
	        
			On Error Resume Next
			If Service.Properties("ActionType").Value=REBILL_ACTIONTYPE_METER_TO_UNKNOWN_ACCOUNT Then      
			    'Code added to implement modified functionality for rebilling to unknown acocunt  
			  TransactionSet.SaveToMIUAsynchronously(nothing)		
			Else        
				TransactionSet.Save(nothing)
			End If
			If Err.Number Then
				EventArg.Error.Save Err   
			Else            
				Save = TRUE
			End If
        
        Next
        
        TransactionUIFinder.UpdateFoundRowSet
        
    END FUNCTION
		
		PRIVATE FUNCTION CreateTransactionSet(SessionID)
			Set TransactionSet = FrameWork.AdjustmentCatalog.CreateRebillTransaction(SessionID)
		END FUNCTION		
		
    PUBLIC PROPERTY GET TransactionSetSessionID()
        TransactionSetSessionID = SESSION("REBILL_TransactionSetSessionID")
    END PROPERTY
    PUBLIC PROPERTY LET TransactionSetSessionID(v)
        SESSION("REBILL_TransactionSetSessionID") = v
    END PROPERTY  		
    
    PUBLIC FUNCTION Initialize(strPriceAbleItemType,strSessionIDs)

        Dim pitype
        Set pitype                          = FrameWork.ProductCatalog.GetPriceableItemTypeByName(strPriceAbleItemType)
        InputPropertiesGenericHTMLTemplate  = ""
				
		SetTransactionIDs strSessionIDs				
		
		CreateTransactionSet SessionIDs.Item(1) 
                
        Dim Prop, MSIXProperty, booOK, strHTMLTemplate
        
        Service.Properties.Clear
        
        Service.Properties.Add "Description"              , MSIXDEF_TYPE_STRING, 255 , False, Empty
        Service.Properties.Add "RebilledTransactionInfo"  , MSIXDEF_TYPE_STRING, 0 , False, Empty
        Service.Properties.Add "ReasonCode"               , MSIXDEF_TYPE_INT32, 0 , True , Empty
        Service.Properties.Add "ActionType"               , MSIXDEF_TYPE_INT32, 0 , TRUE, Empty
        Service.Properties.Add "TotalTransactions"        , MSIXDEF_TYPE_STRING, 255 , False, Empty
        Service.Properties.Add "NumTransactions"          , MSIXDEF_TYPE_STRING, 255 , False, Empty
        
        Service.Properties("Description").Caption              = FrameWork.Dictionary().Item("TEXT_DESCRIPTION").Value
        Service.Properties("RebilledTransactionInfo").Caption  = FrameWork.Dictionary().Item("TEXT_TRANSACTION").Value
        Service.Properties("ReasonCode").Caption               = FrameWork.Dictionary().Item("TEXT_REASON_CODE").Value
        Service.Properties("ActionType").Caption               = FrameWork.Dictionary().Item("TEXT_REBILL_TYPE").Value
        Service.Properties("TotalTransactions").Caption        = FrameWork.Dictionary().Item("TEXT_REBILL_TOTAL_TRANSACTIONS").Value
        Service.Properties("NumTransactions").Caption		   = SessionIDs.Count
        
        If TransactionSet.IdentifiedByAccountExternalID = false and TransactionSet.IdentifiedbyAccount = false Then
           Response.Write(mam_GetDictionary("TEXT_CANNOT_REASSIGN_ADJUSTMENT"))
           Response.End
        End If
        
        InitializeActionTypeEnumType
        InitializeReasonCodeEnumType

        Initialize = TRUE
    END FUNCTION
    
    PRIVATE FUNCTION InitializeReasonCodeEnumType()
    
        Dim ReasonCode, objVars
        
        Set objVars = mdm_CreateObject(CVariables)
        
        For Each ReasonCode In TransactionSet.GetApplicableReasonCodes()
        
            objVars.Add ReasonCode.Name,ReasonCode.ID,,,ReasonCode.DisplayName
        Next        
        Service.Properties("ReasonCode").AddValidListOfValues objVars
        
        InitializeReasonCodeEnumType = TRUE
    END FUNCTION
    
    PRIVATE FUNCTION InitializeActionTypeEnumType
    
        Dim objVars, i, objReBillActionTypeLocalization
        Dim internallyidentifiable
        internallyidentifiable = false
        
        Set objVars                         = mdm_CreateObject(CVariables)
        Set objReBillActionTypeLocalization = FrameWork.Dictionary().GetCollection("REBILL_ACTIONTYPE")
        
        If TransactionSet.IdentifiedByAccountExternalID Then
					objVars.Add REBILL_ACTIONTYPE_EXTERNAL_IDENTIFIER,REBILL_ACTIONTYPE_EXTERNAL_IDENTIFIER,,,objReBillActionTypeLocalization.Item(REBILL_ACTIONTYPE_EXTERNAL_IDENTIFIER)
				End If
				If TransactionSet.IdentifiedByAccountInternalID Then 
					objVars.Add REBILL_ACTIONTYPE_INTERNAL_IDENTIFIER,REBILL_ACTIONTYPE_INTERNAL_IDENTIFIER,,,objReBillActionTypeLocalization.Item(REBILL_ACTIONTYPE_INTERNAL_IDENTIFIER)
					internallyidentifiable = true
				End If
				' If service definition supports internal account identifiers, then there is no need to give "Account ID" option.
				' It is redundant. In this case no resolution is done upfront and we trust the stage to resolve account.
        If TransactionSet.IdentifiedByAccount AND internallyidentifiable = false Then 
					objVars.Add REBILL_ACTIONTYPE_ACCOUNT_ID,REBILL_ACTIONTYPE_ACCOUNT_ID,,,objReBillActionTypeLocalization.Item(REBILL_ACTIONTYPE_ACCOUNT_ID)
				End If
				If TransactionSet.CanSaveToMIU Then 
					objVars.Add REBILL_ACTIONTYPE_METER_TO_UNKNOWN_ACCOUNT,REBILL_ACTIONTYPE_METER_TO_UNKNOWN_ACCOUNT,,,objReBillActionTypeLocalization.Item(REBILL_ACTIONTYPE_METER_TO_UNKNOWN_ACCOUNT)
				End If
        
        
        Service.Properties("ActionType").AddValidListOfValues objVars
        'REMOVED, the first one in the enum will be selected: Service.Properties("ActionType").Value = REBILL_ACTIONTYPE_EXTERNAL_IDENTIFIER
    END FUNCTION
    
    PUBLIC PROPERTY GET InputPropertiesGenericHTMLTemplate()
        InputPropertiesGenericHTMLTemplate = SESSION("REBILL_INPUT_HTML_TEMPLATE")
    END PROPERTY    
    PUBLIC PROPERTY LET InputPropertiesGenericHTMLTemplate(v)
        SESSION("REBILL_INPUT_HTML_TEMPLATE") = v
        FrameWork.Dictionary.Add "REBILL_INPUT_PROPERTIES"  , v
    END PROPERTY        
    
    PUBLIC PROPERTY GET TransactionSet()
      Set TransactionSet = SESSION("REBILL_TRANSACTION_SET")
    END PROPERTY    
    PUBLIC PROPERTY SET TransactionSet(v)
      Set SESSION("REBILL_TRANSACTION_SET") = v 
    END PROPERTY  
    
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
    
PUBLIC FUNCTION SetTransactionIDs(strSessionIDs)
    
        Dim strSessionID
            
        Set SessionIDs = CreateObject("Metratech.MTCollection")        
        
        For Each strSessionID In Split(strSessionIDs,",")
        
            If(Len(strSessionID))Then
            
                SessionIDs.Add(strSessionID)
            End If
        Next
        SetTransactionIDs = TRUE
END FUNCTION

PUBLIC FUNCTION SaveAll(EventArg)
        
    Dim MSIXProp, lngAccountID, sessionID
    dim RebillTransactionSet
		Dim sessioncounter
		Dim strWarnings
		
    SaveAll = FALSE
    sessioncounter = 0
    set RebillTransactionSet = FrameWork.AdjustmentCatalog.CreateRebillTransactions(SessionIDs)
    sessioncounter = sessioncounter + 1
    Select Case Service.Properties("ActionType").Value
	  	CASE REBILL_ACTIONTYPE_METER_TO_UNKNOWN_ACCOUNT         :
					' Code added on 05/12/2008 to implement assigning to an unknown account
					lngAccountID = 0			  
					RebillTransactionSet.AccountID = lngAccountID
          
			CASE REBILL_ACTIONTYPE_EXTERNAL_IDENTIFIER              :
	            
			For Each MSIXProp In Service.Properties
	                
				If MSIXProp.Tag="INPUT" Then RebillTransactionSet.AccountIdentifiers.Item(MSIXProp.Name).Value = MSIXProp.Value
						If Err.Number Then
						 EventArg.Error.Save Err
						   
             Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
             Response.Redirect mdm_GetCurrentFullURL()   
						 Exit Function
						End If 
				Next
			CASE REBILL_ACTIONTYPE_INTERNAL_IDENTIFIER              :
	            
				For Each MSIXProp In Service.Properties
		  			FrameWork.DecodeFieldID Service.Properties(MSIXProp.Name).Value, lngAccountID
						If MSIXProp.Tag="INPUT" Then RebillTransactionSet.AccountIdentifiers.Item(MSIXProp.Name).Value = lngAccountID
						'If Err.Number Then EventArg.Error.Save Err : Exit Function

						If Err.Number Then
						 EventArg.Error.Save Err
						   
             Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
             Response.Redirect mdm_GetCurrentFullURL()   
						 Exit Function
						End If 
				Next
	                
			CASE REBILL_ACTIONTYPE_ACCOUNT_ID                       :                
	            
					FrameWork.DecodeFieldID Service.Properties("_ACCOUNTID").Value, lngAccountID
					RebillTransactionSet.AccountID = lngAccountID
	                  
			    
			End Select
	        
			RebillTransactionSet.Description      = Service.Properties("Description").Value
			Set RebillTransactionSet.ReasonCode   = FrameWork.AdjustmentCatalog.GetReasonCode(Service.Properties("ReasonCode").Value)
	        
			Dim objWarningsRowset
			Dim AdjustmentHelper
			Set AdjustmentHelper = New CAdjustmentHelper
			
			'Code added on 06/02/2008 to implement rebilling to an unknown account

      If Service.Properties("ActionType").Value = REBILL_ACTIONTYPE_METER_TO_UNKNOWN_ACCOUNT Then
        set objWarningsRowset = RebillTransactionSet.SaveToMIUAsynchronously(nothing)			 	   
      Else
		    set objWarningsRowset = RebillTransactionSet.Save(nothing)
      End If    
	    
	    TransactionUIFinder.UpdateFoundRowSet 

			' Check if there are warnings
			If(objWarningsRowset.RecordCount)Then			 
			  Set AdjustmentHelper.SaveWarningRowset = objWarningsRowset
			  mam_ShowGuide FrameWork.Dictionary.Item("TEXT_ADJUSTMENT_WARNING_NOTE").Value 
        AdjustmentHelper.PopulateWarningRowsetInSession AdjustmentHelper.SaveWarningRowset			  
        Response.Redirect FrameWork.Dictionary.Item("BATCH_ERROR_LIST_DIALOG").Value & "&WarningMode=TRUE&FilterOff=TRUE&PopUpWindowMode=TRUE"                        
			Else			   
				Set objWarningsRowset = Nothing			
				Response.Redirect FrameWork.Dictionary.Item("ADJUSTMENT_SAVED_ADJUSTMENT_WARNING_DIALOG").Value & "?DialogType=" & "BulkAdjustment" & "&Message=" & Server.URLEncode(FrameWork.Dictionary.Item("TEXT_ADJUSTMENT(s)_HAS_BEEN_APPROVED").Value)
			End If

    END FUNCTION
    
    PUBLIC FUNCTION SetRouteToForConfirmDialog(strDialogType, strMessage)

        If Len(strMessage) Then ' We have a message for the user
		     	Form.RouteTo = FrameWork.Dictionary.Item("ADJUSTMENT_SAVED_ADJUSTMENT_WARNING_DIALOG").Value & "?DialogType=" & strDialogType & "&Message=" & Server.URLEncode(strMessage)
		    Else        
          Form.RouteTo = FrameWork.Dictionary.Item("ADJUSTMENT_SAVED_ADJUSTMENT_WARNING_DIALOG").Value & "?DialogType=" & strDialogType & "&Message=" & Server.URLEncode(FrameWork.Dictionary.Item("TEXT_ADJUSTMENT(s)_HAS_BEEN_APPROVED").Value)
        End If
        TransactionUIFinder.UpdateFoundRowSet ' -- Force to reload the transaction info now that we have adjusted at least one
        SetRouteToForConfirmDialog = TRUE
    END FUNCTION
 
     PUBLIC FUNCTION SetRouteToForConfirmDialogForProgress(strDialogType, strMessage, objProgress)

        If Len(strMessage) Then ' We have a message for the user
			   Response.Redirect FrameWork.Dictionary.Item("ADJUSTMENT_SAVED_ADJUSTMENT_WARNING_DIALOG").Value & "?DialogType=" & strDialogType & "&Message=" & Server.URLEncode(strMessage)
		Else        
            Response.Redirect FrameWork.Dictionary.Item("ADJUSTMENT_SAVED_ADJUSTMENT_WARNING_DIALOG").Value & "?DialogType=" & strDialogType & "&Message=" & Server.URLEncode(FrameWork.Dictionary.Item("TEXT_ADJUSTMENT(s)_HAS_BEEN_APPROVED").Value)
        End If
        TransactionUIFinder.UpdateFoundRowSet ' -- Force to reload the transaction info now that we have adjusted at least one
        SetRouteToForConfirmDialogForProgress = TRUE
    END FUNCTION

END CLASS

PUBLIC ReBillHelper: Set ReBillHelper = New CReBillHelper

%>


