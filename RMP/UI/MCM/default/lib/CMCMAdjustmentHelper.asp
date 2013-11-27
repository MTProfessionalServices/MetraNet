<%



CLASS CAdjustmentTemplateHelper

    PUBLIC FUNCTION PriceAbleItemDisplayName()
        PriceAbleItemDisplayName = Template.DisplayName
    END FUNCTION
    
    PUBLIC FUNCTION Save()
        Dim Adjustment
        
        For Each Adjustment In TemplateAdjustments
            Adjustment.Save
        Next         
        Save = TRUE
    END FUNCTION

    PUBLIC FUNCTION Initialize(lngTemplateID)
    
        Set Instance = Nothing ' --- VERY IMPORTANT -- We must clear this variable to tell we are not dealing instance but template adjustment
                               ' --- See the implementation of the property Template.

        Set Template = FrameWork.ProductCatalog.GetPriceableItem(lngTemplateID)
        Initialize   = TRUE
    END FUNCTION

    PUBLIC FUNCTION AddAdjustment(lngAdjustmentTypeID)

        Set  AddAdjustment = Template.CreateAdjustment(lngAdjustmentTypeID)
    END FUNCTION
    
    PUBLIC FUNCTION AddReasonCode(lngReasonCodeID,lngAdjustmentTemplateID)
    
        Dim AdjustmentTemplate, ReasonCode
        
        Set AdjustmentTemplate  = GetAdjustmentFromID(lngAdjustmentTemplateID)
        Set ReasonCode          = FrameWork.AdjustmentCatalog.GetReasonCode(lngReasonCodeID)
        
        AdjustmentTemplate.AddExistingReasonCode(ReasonCode)
        
        AddReasonCode = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION RemoveReasonCode(lngReasonCodeID,lngAdjustmentTemplateID)
    
        Dim AdjustmentTemplate, ReasonCode
        
        Set AdjustmentTemplate  = GetAdjustmentFromID(lngAdjustmentTemplateID)
        
        AdjustmentTemplate.RemoveReasonCode lngReasonCodeID
        
        RemoveReasonCode = TRUE
    END FUNCTION    
    
    PUBLIC FUNCTION RemoveAdjustment(lngAdjustmentTypeID)    
        Dim Adjustment, lngIndex
        
        Template.RemoveAdjustment lngAdjustmentTypeID
        RemoveAdjustment = TRUE
    END FUNCTION
    
    PUBLIC PROPERTY GET PriceAbleItemType()
      Set PriceAbleItemType = Template.PriceableItemType
    END PROPERTY    
    
    PUBLIC PROPERTY GET AdjustmentTypes()
      Set AdjustmentTypes = PriceAbleItemType.AdjustmentTypes
    END PROPERTY            
    
    PUBLIC PROPERTY GET TemplateAdjustments()
        Set TemplateAdjustments = Template.GetAdjustments()
    END PROPERTY
    
    PUBLIC FUNCTION GetAdjustmentFromID(lngID)    
        Set GetAdjustmentFromID = TemplateAdjustments.Item(GetAdjustmentIndexFromID(lngID))
    END FUNCTION
    
    PUBLIC FUNCTION GetAdjustmentIndexFromID(lngID)
    
        Dim Adjustment, lngIndex
        
        lngIndex  = 1
        
        For Each Adjustment In TemplateAdjustments
        
           If CLng(Adjustment.ID)=CLng(lngID) Then
           
              GetAdjustmentIndexFromID = lngIndex
              Exit Function
           End If
           lngIndex = lngIndex  + 1
        Next
    END FUNCTION
    
    PUBLIC FUNCTION GetAdjustmentReasonCodes(lngID)

        Dim Adjustment
        Set Adjustment = GetAdjustmentFromID(lngID)
        Set GetAdjustmentReasonCodes = Adjustment.GetApplicableReasonCodes()
    END FUNCTION
    
    PUBLIC FUNCTION CreateAGlobalBlankNewReasonCode()
    
        Set CurrentReasonCodeInstance   = FrameWork.AdjustmentCatalog.CreateReasonCode()
        CreateAGlobalBlankNewReasonCode = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION LoadReasonCode(lngReasonCodeId)
    
        Set CurrentReasonCodeInstance = FrameWork.AdjustmentCatalog.GetReasonCode(lngReasonCodeId)
        CurrentReasonCodeInstance.SetSessionContext(FrameWork.SessionContext)
        LoadReasonCode = TRUE
    END FUNCTION

    PUBLIC PROPERTY GET CurrentReasonCodeInstance()
      Set CurrentReasonCodeInstance = Session("ADJUSTMENT_CurrentReasonCodeInstance")
    END PROPERTY    
    PUBLIC PROPERTY SET CurrentReasonCodeInstance(v)
        Set Session("ADJUSTMENT_CurrentReasonCodeInstance") = v
    END PROPERTY    
    
    PUBLIC PROPERTY GET Template()
      If IsValidObject(Instance) Then
          Set Template = Instance.GetTemplate()
      Else
          Set Template = Session("ADJUSTMENT_TEMPLATE")
      End If
    END PROPERTY
    PUBLIC PROPERTY SET Template(v)
        Set Session("ADJUSTMENT_TEMPLATE") = v
    END PROPERTY
    
    PUBLIC PROPERTY GET Instance()      
      If IsEmpty(Session("ADJUSTMENT_Instance")) Then Set Instance = Nothing ' We need to do this so the next line does not cras you cannot do a SET with an EMPTY value
      Set Instance = Session("ADJUSTMENT_Instance")
    END PROPERTY
    PUBLIC PROPERTY SET Instance(v)
        Set Session("ADJUSTMENT_Instance") = v
    END PROPERTY    
    
    PUBLIC PROPERTY GET InstanceAdjustments()
        Set InstanceAdjustments = Instance.GetAdjustments()
    END PROPERTY
        
    PUBLIC FUNCTION InitializeInstance(lngInstanceID,lngPOID)          
    
          Set Instance = FrameWork.ProductCatalog.GetProductOffering(lngPOID).GetPriceableItem(lngInstanceID)
          
          ' -- Create the Instance adjutsments based on what was defined in the --
          Dim AjTemplate, AjInstance

'          If InstanceAdjustments.Count=0 Then ' TODO:Change this after the mile stone 3
 '         
  '              For Each AjTemplate In TemplateAdjustments
'
 '                   Set AjInstance          = Instance.CreateAdjustment(AjTemplate.AdjustmentType.ID)
  '                  AjInstance.DisplayName  = "*" & AjTemplate.DisplayName
   '             Next
    '      End If
     '     Instance.Save
          InitializeInstance = TRUE
    END FUNCTION
    
    PUBLIC FUNCTION GetAdjustmentInstanceFromID(lngID)

        Dim InstanceAdjustment

        Set GetAdjustmentInstanceFromID = Nothing

        For Each  InstanceAdjustment In InstanceAdjustments

            If InstanceAdjustment.ID = CLNG(lngID) Then

                Set GetAdjustmentInstanceFromID = InstanceAdjustment
                Exit Function
            End If
        Next
    END FUNCTION
    
    PUBLIC FUNCTION CheckIfAllAdjustmentHaveReasonCode()

        CheckIfAllAdjustmentHaveReasonCode = FALSE
        Dim TemplateAdjustment, ReasonCodes

        For Each TemplateAdjustment In TemplateAdjustments
        
              Set ReasonCodes = TemplateAdjustment.GetApplicableReasonCodes()              
              If ReasonCodes.Count=0 Then
                  Exit Function
              End If
        Next
        CheckIfAllAdjustmentHaveReasonCode = TRUE
    END FUNCTION

END CLASS

PUBLIC AdjustmentTemplateHelper
Set AdjustmentTemplateHelper = New CAdjustmentTemplateHelper
%>



