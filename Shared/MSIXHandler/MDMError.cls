VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMError"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'****************************************************************************************************************************************************
'
' Copyright 1998-2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' MODIFIED      : $Date$
' LAST AUTHOR   : $Author$
' REVISION      : $Revision$
' FILENAME      : $Workfile$
'
Option Explicit
Public TRACE_ID As Long
Public Number               As Long
Public Description          As String
Public LocalizedDescription As String
Public Source               As String
Public PropertyName         As String



Private m_PropertyCaption As String

' We need to associate a disctionary with the error object so the method save
' base on the error number can look up in the dictionary the localized error message...
Private m_objDictionary As Dictionary


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   : Remove all the items in the collection. If the item is no more referenced it is deleted and its destructor
'                 Class_Terminate event is raise.
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr

    Number = 0
    Description = ""
    Source = Description
    m_PropertyCaption = ""
    Clear = True
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If
    

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMError.cls", "Clear", LOG_ERROR
End Function

Public Sub Raise()

    On Error GoTo ErrMgr

    Err.Raise Number, Source, Description

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMError.cls", "Raise", LOG_ERROR
End Sub
' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr


    Dim strS As String
    
    strS = "error=" & CStr(Number) & "; description=" & Me.Description & "; source=" & Me.Source & "; LocalizedDescription=" & Me.LocalizedDescription & ";"
    
    If (Len(PropertyName)) Then
        strS = strS & " PropertyName=" & PropertyName & ";"
    End If
    
    ToString = strS
    
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMError.cls", "ToString", LOG_ERROR
End Function

Public Function Initialize(objParent As MDMEvent) As Boolean

    On Error GoTo ErrMgr

    
    Initialize = True

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMError.cls", "Initialize", LOG_ERROR
End Function



Public Property Get PropertyCaption(Optional ByVal objMSIXInstance As MSIXHandler) As Variant

    On Error GoTo ErrMgr


    If (Len(m_PropertyCaption)) Then
        PropertyCaption = m_PropertyCaption
    Else
        If (IsValidObject(objMSIXInstance)) Then
            If (Len(PropertyName)) Then
                m_PropertyCaption = objMSIXInstance.Properties.Item(Me.PropertyName).Caption
                PropertyCaption = m_PropertyCaption
            End If
        Else
            PropertyCaption = Replace(MTMSIX_ERROR_01031, "[NAME]", PropertyName)
            TRACE Replace(MTMSIX_ERROR_01031, "[NAME]", PropertyName), "MDMError.cls", "PropertyCaption", LOG_DEBUG
        End If
    End If

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMError.cls", "PropertyCaption", LOG_ERROR
End Property

Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMError.cls", "Class_Initialize", LOG_ERROR
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMError.cls", "Class_Terminate", LOG_ERROR
End Sub

Public Function CopyTo(ByVal objError As MDMError) As Boolean

    On Error GoTo ErrMgr


     objError.Number = Me.Number
     objError.Description = Me.Description
     objError.Source = Me.Source
     objError.PropertyName = Me.PropertyName
     CopyTo = True

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMError.cls", "CopyTo", LOG_ERROR
End Function



Public Function IsPropertyDefined() As Boolean

    On Error GoTo ErrMgr

    IsPropertyDefined = CBool(Len(PropertyName))

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMError.cls", "IsPropertyDefined", LOG_ERROR
End Function

Public Function Save(objError As Variant) As Boolean
    
    On Error GoTo ErrMgr

    Me.Number = objError.Number
    Me.Description = objError.Description
    Me.Source = objError.Source
    
    
   ' LookUpLocalizedDescription Number
    
    Save = True
    Exit Function
ErrMgr:
      TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMError.cls", "Save", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Dictionary
' PARAMETERS    :
' DESCRIPTION   : Gets or sets the instance of the dictionary. The value is defined in the Initialize() function.
'                 If the dictionary object is not defined, the property return <code>Nothing</code>.
' RETURN        :
Public Property Get Dictionary() As Dictionary

    On Error GoTo ErrMgr

    Set Dictionary = m_objDictionary

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Dictionary", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Dictionary
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Set Dictionary(ByVal vNewValue As Dictionary)

    On Error GoTo ErrMgr

    Set m_objDictionary = vNewValue
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXHandler.cls", "Dictionary", LOG_ERROR
End Property

Public Function LookUpLocalizedDescription(lngNumber As Long) As Boolean

    Dim objTool As New MSIXTools
    
    If objTool.GetMTErrorMessage(lngNumber, LocalizedDescription) Then
    
        LookUpLocalizedDescription = True
    Else
        Me.LocalizedDescription = Me.Description
    End If
End Function

Public Function IsUserError() As Boolean
    IsUserError = IsUserVisibleMTCOMError(Me.Number)
End Function
