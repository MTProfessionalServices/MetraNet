VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXEnumTypeEntry"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
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
' * *  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
' CLASS         : MSIXEnumTypeEntry
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   :
'                   This object implements a MetraTech Enum Type Item also called enumerator.
'                   Some of the properties and methods of this object are reserved by the MetraTech Dialog Manager VBScript layer.
'
'                   This object cannot be created directly, but can be created through an instance of the object MSIXHandler as a service
'                   or a product view object. Initializing an MSIXHandler object as a service or a product view automatically loads all the enum types and their localization.
'
'                   Refer to the "Metratech Dialog Manager Programming Guide" for more information.
'

'
'**********************************************************************************************************************************************************
Option Explicit

Public TRACE_ID As Long
Public Name             As String   ' The name of the enum type item
Public Value            As Variant  ' The value of the enum type item
Attribute Value.VB_VarUserMemId = 0
Private m_varCaption    As Variant ' Defined as a variant because I need to support the empty mode

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the content of the object in a string.
' RETURN        :
Public Function ToString() As String

    ToString = "name=" & Name & "; Value=" & Value & "; Caption=" & Caption & "; "

    Exit Function
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "", "MSIXEnumTypeEntry.cls", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Caption
' PARAMETERS    :
' DESCRIPTION   : Gets or sets the localisation of the enum type item.
' RETURN        :
Public Property Get Caption() As String

    On Error GoTo ErrMgr

    If (IsEmpty(m_varCaption) Or Len(m_varCaption) = 0) Then
        Caption = "{NL}" & Name
    Else
        Caption = m_varCaption
    End If

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Caption", "MSIXEnumTypeEntry.cls", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Caption
' PARAMETERS    :
' DESCRIPTION   : See property get.
' RETURN        :
Public Property Let Caption(ByVal vNewValue As String)

    On Error GoTo ErrMgr

    m_varCaption = vNewValue

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Caption", "MSIXEnumTypeEntry.cls", LOG_ERROR
End Property

