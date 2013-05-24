VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXAccountTemplate"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

' The MSIX is the main object of the MDM and is used here to store
' in memory the Properties definition and value.
' This object will be allocated and create by the UI ASP MDM Dialog page
' and pass to this object
Private mobjMSIXHandler                  As MTMSIX.MSIXHandler
Private m_objYAAC_AccountTemplate       As MTYAACLib.MTAccountTemplate

Public Property Set MSIXHandler(ByVal objMSIXHandler As MSIXHandler)
  Set mobjMSIXHandler = objMSIXHandler
End Property

Public Property Get MSIXHandler() As MSIXHandler
  Set MSIXHandler = mobjMSIXHandler
End Property


Public Function Initialize(ByVal objYAAC_AccountTemplate As MTAccountTemplate) As Boolean
    Set m_objYAAC_AccountTemplate = objYAAC_AccountTemplate
    Initialize = True
End Function

Public Function LoadMSIXHandler(Optional ByVal strMSIXDefFileName As String, Optional ByVal strLanguage As String = "US") As Boolean
    
    On Error GoTo ErrMgr
    
    Set mobjMSIXHandler = New MSIXHandler
    If mobjMSIXHandler.Initialize(strMSIXDefFileName, , strLanguage) Then
        LoadMSIXHandler = True
    End If
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error" & GetVBErrorString(), TypeName(Me), "LoadMSIXHandler", LOG_ERROR
End Function

Public Property Get Properties() As MTMSIX.MSIXProperties
    Set Properties = mobjMSIXHandler.Properties
End Property

Public Function Load() As Boolean

    On Error GoTo ErrMgr
    
    Dim objMSIXProperty As MSIXProperty
    Dim objATProperty   As MTAccountTemplateProperty
        
    'Obsolete, since YAAC object will return -1 for AccountTemplate, but the load
    'method will find the correct ancestor
    'If m_objYAAC_AccountTemplate.id = -1 Then ' the template does not exist yet
    '    Load = True
    '    Exit Function
    'End If
    'If Not m_objYAAC_AccountTemplate.Load() Then Exit Function
    
    If IsValidObject(mobjMSIXHandler) Then
    
        For Each objATProperty In m_objYAAC_AccountTemplate.Properties
        
            Set objMSIXProperty = mobjMSIXHandler.Properties(objATProperty.Name) ' Get the MSIXProperty
            
            If IsValidObject(objMSIXProperty) Then
            
                objMSIXProperty.value = objATProperty.value
            Else
               ' TRACE PreProcess(MTACCOUNTHIERARCHYHERLPER_ERROR_06000, "NAME", objATProperty.Name), TypeName(Me), "Load", LOG_ERROR
            End If
        Next
    End If
    Load = True
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error" & GetVBErrorString(), TypeName(Me), "Load", LOG_ERROR
End Function

Public Property Get Name() As String
    Name = m_objYAAC_AccountTemplate.Name
End Property

Public Property Let Name(ByVal vNewValue As String)
    m_objYAAC_AccountTemplate.Name = vNewValue
End Property

Public Property Get Description() As String
    Description = m_objYAAC_AccountTemplate.Description
End Property

Public Property Let Description(ByVal vNewValue As String)
    m_objYAAC_AccountTemplate.Description = vNewValue
End Property

Public Function GetSubscriptionsAsRowSet() As MTSQLRowset

    Set GetSubscriptionsAsRowSet = m_objYAAC_AccountTemplate.GetSubscriptionsAsRowSet()
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error" & GetVBErrorString(), TypeName(Me), "GetSubscriptionsAsRowSet", LOG_ERROR
End Function

Public Function AddProductOfferingToSubscriptions(ByVal lngIdPO As Long) As Boolean
'    m_objYAAC_AccountTemplate
 '   AddProductOfferingToSubscriptions = True
End Function

' Internal Account Template
Public Property Get AccountTemplate() As MTAccountTemplate
    Set AccountTemplate = m_objYAAC_AccountTemplate
End Property


' Internal Account Template
Public Property Get Subscriptions() As MTAccountTemplateSubscriptions
    Set Subscriptions = m_objYAAC_AccountTemplate.Subscriptions
End Property


Public Function Save(Optional ByVal vRefDate As Date) As Boolean

    Dim objMSIXProperty  As MSIXProperty
    Dim objATProperty    As MTAccountTemplateProperty
    Dim lngPropertyIndex As Long
    Dim booMustUpdateProperty As Boolean
    Dim enumconfig

    Set enumconfig = CreateObject("MetraTech.MTEnumConfig")
    
    On Error GoTo ErrMgr
    
    ' Copy the property value from the MSIXAccountTemplate object to the AccountTemplate object
    
    For Each objMSIXProperty In mobjMSIXHandler.Properties
    
        lngPropertyIndex = GetPropertiesIndex(objMSIXProperty.Name) ' Get the value before the update if exist
    
        If Len(objMSIXProperty.value) Then
        
            ' g. cieplik 6/3/2008 CR 15785 do not check the "IsValueEqualToDefaultValue() allow a template property to be changed back to its default value 
            If (objMSIXProperty.Flags And eMSIX_PROPERTY_FLAG_METERED)  Then
                
                If lngPropertyIndex <> -1 Then m_objYAAC_AccountTemplate.Properties.Remove lngPropertyIndex
                
                Dim value As String
                If objMSIXProperty.PropertyType = "ENUM" Then
                  value = CStr(enumconfig.GetID(objMSIXProperty.EnumType.Namespace, objMSIXProperty.EnumType.Name, objMSIXProperty.value))
                Else
                  value = objMSIXProperty.value
                End If
                m_objYAAC_AccountTemplate.Properties.Add objMSIXProperty.Name, value, objMSIXProperty.PropertyType
            End If
        Else
          ' Remove the property because it is now blank
          If lngPropertyIndex <> -1 Then
            m_objYAAC_AccountTemplate.Properties.Remove lngPropertyIndex
          End If
        End If
    Next
    Save = m_objYAAC_AccountTemplate.Save(vRefDate)
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error" & GetVBErrorString(), TypeName(Me), "Save", LOG_ERROR
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Clear()                                                     '
' Description : Clear the loaded template and the service properties.       '
' Inputs      : none                                                        '
' Outputs     : boolean                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function Clear()
  Dim objMSIXProperty As MSIXProperty
  Dim objATProperty As MTAccountTemplateProperty
  
  On Error GoTo ErrMgr
  
  'Clear values of MSIX collection
  'For Each objMSIXProperty In mobjMSIXHandler.Properties
  Call mobjMSIXHandler.Properties.ReSetDefaults
  'Next
    
  Call m_objYAAC_AccountTemplate.Clear
  m_objYAAC_AccountTemplate.ApplyDefaultSecurityPolicy = False
  
ErrMgr:
  
  If Err Then
    'TRACE App.EXEName & " Error" & GetVBErrorString(), TypeName(Me), "Clear", LOG_ERROR
    Clear = False
  Else
    Clear = True
  End If
  
  End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetPropertiesIndex(ByVal strName As String) As Long

  Dim objATProperty   As MTAccountTemplateProperty
  Dim i               As Long
  
  i = 0
  For Each objATProperty In m_objYAAC_AccountTemplate.Properties
  
    i = i + 1 ' Start at one
    If UCase$(objATProperty.Name) = UCase$(strName) Then
    
        GetPropertiesIndex = i
        Exit Function
    End If
  Next
  GetPropertiesIndex = -1
End Function

Public Property Get ApplyDefaultSecurityPolicy() As Boolean
    ApplyDefaultSecurityPolicy = m_objYAAC_AccountTemplate.ApplyDefaultSecurityPolicy
End Property

Public Property Let ApplyDefaultSecurityPolicy(ByVal vNewValue As Boolean)
    m_objYAAC_AccountTemplate.ApplyDefaultSecurityPolicy = vNewValue
End Property

Public Function ApplyPropertiesTo(ByVal objMSIXService As MSIXHandler) As Boolean

    Dim objMTAccountTemplateProperty As MTAccountTemplateProperty
    
    On Error GoTo ErrMgr
    
    TRACE "Execute", TypeName(Me), "ApplyPropertiesTo", LOG_DEBUG
    
    For Each objMTAccountTemplateProperty In m_objYAAC_AccountTemplate.Properties
    
        If objMSIXService.Properties.Exist(objMTAccountTemplateProperty.Name) Then
        
                If Len("" & objMTAccountTemplateProperty.value) Then
                
                    TRACE objMTAccountTemplateProperty.Name & "=" & objMTAccountTemplateProperty.value, TypeName(Me), "ApplyPropertiesTo", LOG_DEBUG
                    objMSIXService.Properties(objMTAccountTemplateProperty.Name).value = objMTAccountTemplateProperty.value
                End If
        Else
            TRACE "Property " & objMTAccountTemplateProperty.Name & " not found in service definition", TypeName(Me), "ApplyPropertiesTo", LOG_DEBUG
        End If
    Next
    objMSIXService.Properties("ApplyDefaultSecurityPolicy").value = m_objYAAC_AccountTemplate.ApplyDefaultSecurityPolicy
    ApplyPropertiesTo = True
Exit Function
ErrMgr:
    TRACE App.EXEName & " Error" & GetVBErrorString(), TypeName(Me), "ApplyPropertiesTo", LOG_ERROR
End Function
