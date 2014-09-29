<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
'  Copyright 1998-2003 by MetraTech Corporation
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
'  Created by: F.Torres
' 
'  $Date$
'  $Author$
'  $Revision$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->

<%

PRIVATE CONST enum_FT_BULK_CHANGE_ALL                   = 1
PRIVATE CONST enum_FT_BULK_CHANGE_IF_PREVIOUS_VALUE_IS  = 2

Form.Version = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo			              = mom_GetDictionary("NAME_SPACE_BROWSER_DIALOG")
Form.Modal                      = TRUE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Framework.AssertCourseCapability "Update Failed Transactions", EventArg
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  ' Store the children type for the all dialog duration, because we need it in the ok event                  
  Form("ChildrenType") = Request.QueryString("ChildrenType")
  
  ' 1-Change all - 2-If Previous value is
  Service.Properties.Add "Mode"         , "int32",    0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "NewValue"     , "string", 255, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "PreviousValue", "string", 255, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Property"     , "string", 255, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  
  Service.Properties("Mode").Value         = enum_FT_BULK_CHANGE_ALL
  
  Service.Properties("Mode").Caption       = mom_GetDictionary("TEXT_FAILED_TRANSACTION_BULK_CHANGE_MODE")
  Service.Properties("NewValue").Caption   = mom_GetDictionary("TEXT_FAILED_TRANSACTION_BULK_NEW_VALUE")
  Service.Properties("Property").Caption   = mom_GetDictionary("TEXT_FAILED_TRANSACTION_BULK_PROPERTY")
  Service.Properties("PreviousValue").Caption = mom_GetDictionary("TEXT_FAILED_TRANSACTION_BULK_PREVIOUS_VALUE")

  PopulateThePropertyComboBox
  
  Service.LoadJavaScriptCode  
  
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  PopulateThePropertyComboBox
' PARAMETERS    :  Retreive the first child and loop through its msix property, build a temporary CVariables collection with
'                  name,value,caption and then pass it to the property property of the dialog.
' DESCRIPTION   :
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION PopulateThePropertyComboBox()

  Dim strChildrenType, objMSIXFirstChild, objMSIXProperty, objDyn, objMSIXHandlerParent, p
  
  PopulateThePropertyComboBox   = FALSE
  Set objDyn                    = mdm_CreateObject(CVariables)  
  
  If(Form("ChildrenType") = "ParentAndChildren")Then
  
      ' -- Populate with all the common properties of the parent and the children --
    
      Set objMSIXHandlerParent    = Session("FailedTransaction_Compound_Parent")
      
      For Each p In objMSIXHandlerParent.CommonProperties 
      
          Set objMSIXProperty = objMSIXHandlerParent.Properties(p)
          objDyn.Add objMSIXProperty.Name,objMSIXProperty.Name, , , objMSIXProperty.Caption
      Next
  Else
  
      ' -- Populate with all the properties of the children type selected
      
      Set objMSIXFirstChild = Session("FailedTransaction_Compound_Parent").SessionChildrenTypes(Form("ChildrenType")).Children(1)
      
      For Each objMSIXProperty In objMSIXFirstChild.Properties  
      
          objDyn.Add objMSIXProperty.Name,objMSIXProperty.Name, , , objMSIXProperty.Caption
      Next  
  End If
  Service.Properties("Property").AddValidListOfValues objDyn
  
  PopulateThePropertyComboBox = TRUE
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    On Error Resume Next
    
    Dim booUpdateParentAndChildren
    Dim objChildren, objParent
    
    booUpdateParentAndChildren = CBool(Form("ChildrenType") = "ParentAndChildren")
    
    If(booUpdateParentAndChildren) Then
    
        Set objParent = Session("FailedTransaction_Compound_Parent")
        
        Select Case Service.Properties("Mode").Value      
        
            Case enum_FT_BULK_CHANGE_ALL                         
              objParent.UpdateParentAndChildrenProperty Service.Properties("Property").Value, Service.Properties("NewValue").Value
              
            Case enum_FT_BULK_CHANGE_IF_PREVIOUS_VALUE_IS
              objParent.UpdateParentAndChildrenProperty Service.Properties("Property").Value, Service.Properties("NewValue").Value, "like", Service.Properties("PreviousValue").Value
        End Select
        
    Else
    
        Set objChildren = Session("FailedTransaction_Compound_Parent").SessionChildrenTypes(Form("ChildrenType")).Children
        
        Select Case Service.Properties("Mode").Value      
        
            Case enum_FT_BULK_CHANGE_ALL                         
                objChildren.UpdateProperty Service.Properties("Property").Value, Service.Properties("NewValue").Value
              
            Case enum_FT_BULK_CHANGE_IF_PREVIOUS_VALUE_IS
                objChildren.UpdateProperty Service.Properties("Property").Value, Service.Properties("NewValue").Value, "like", Service.Properties("PreviousValue").Value
        End Select
    End If

    if Err then
      EventArg.Error.Description = Err.description
      OK_Click = FALSE
    else
      OK_Click = TRUE
    End if

END FUNCTION

%>




