VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXInterval"
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
' * *  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
' CLASS         : MSIXInterval
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   :
'                   This object implements the MetraTech notion of Interval ID related to a Product View.
'                   Some of the properties and methods of this object are reserved by the MetraTech Dialog Manager VBScript layer.
'
'                   This object cannot be created directly, but can be created through an instance of the object MSIXHandler as a service
'                   or a product view object. Initializing an MSIXHandler object as a service or a product view automatically loads all the enum types and their localization.
'
'                   Refer to the "Metratech Dialog Manager Programming Guide" for more information.
'

'
'**********************************************************************************************************************************************************Option Explicit

Public TRACE_ID As Long

Private m_Rowset       As ROWSETLib.MTSQLRowset
Private m_lngID        As Long
Private m_Parent       As MSIXProperties

Public AccountID                As Long             ' Gets or sets the Account ID associated with the product view.
Public DisplayInvoiceNumber     As Boolean          ' Related to the MDM Product View browser. Define if the PVB Interval ID combo box contains the invoice numbers if they are available. Default value is TRUE.

Private m_strDateFormat As String

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Rowset
' PARAMETERS    :
' DESCRIPTION   : Gets or Sets the Interval ID rowset.
' RETURN        :
Public Property Get Rowset() As Object

    On Error GoTo ErrMgr

    Set Rowset = m_Rowset

    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXIntervalId.cls", "Rowset", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Rowset
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Set Rowset(ByVal vNewValue As Object)

    On Error GoTo ErrMgr

    Set m_Rowset = vNewValue

    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXIntervalId.cls", "Rowset", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Load
' PARAMETERS    :
'                   lngAccountID - The account ID.
' DESCRIPTION   : Load the interval id rowset for the account lngAccountID. Once the the rowset is loaded the current interval id is
'                 set to the current one.
' RETURN        :
Public Function Load(ByVal lngAccountID As Long) As Boolean

    On Error GoTo ErrMgr
    
    Dim objProfiler As New CProfiler
    objProfiler.Start MTMSIX_PROFILER_ON, "MSIXInterval.cls", "Load"

    AccountID = lngAccountID
    Parent.Tools.DataAccessorObject.AccountID = lngAccountID
    Set Rowset = Parent.Tools.DataAccessorObject.GetUsageInterval()
    Rowset.MoveFirst
    
    ' Set the default id, the first record is the current interval id
    m_lngID = Rowset.Value("IntervalId")
    
    Load = True

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXIntervalId.cls", "Load", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Id
' PARAMETERS    :
' DESCRIPTION   : Gets or sets the current interval id. The value is used by the function MSIXProperties.Load() to load
'                 the product view.
' RETURN        :
Public Property Get Id() As Long
Attribute Id.VB_UserMemId = 0

    On Error GoTo ErrMgr

    Id = m_lngID

    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXIntervalId.cls", "ID", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Id
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Let Id(ByVal vNewValue As Long)

    On Error GoTo ErrMgr

    m_lngID = vNewValue

    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXIntervalId.cls", "ID", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Delete
' PARAMETERS    :
' DESCRIPTION   : Internal Delete function called by the parent object when the parent is about to be deleted.
'                 The purpose of this function is to free the parent ref from the child so the parent can be deleted.
'                 This deals with the COM problem of circular reference.
'                 This function cannot be called from the out side (Friend)!
' RETURN        :
Friend Function Delete() As Boolean

    On Error GoTo ErrMgr
    
    Set Parent = Nothing ' Free the parent
    Delete = True

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXIntervalId.cls", "ID", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : DateFormat
' PARAMETERS    :
' DESCRIPTION   : Gets or sets the date format in the MDM Product View Browser Interval Id Combox box.
' RETURN        :
Public Property Get DateFormat() As String

    On Error GoTo ErrMgr

    DateFormat = m_strDateFormat

    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXIntervalId.cls", "DateFormat", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : DateFormat
' PARAMETERS    :
' DESCRIPTION   : See property Get.
' RETURN        :
Public Property Let DateFormat(ByVal vNewValue As String)

    On Error GoTo ErrMgr

    m_strDateFormat = vNewValue

    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXIntervalId.cls", "DateFormat", LOG_ERROR
End Property


' -------------------------------------------------------------------------------
' FUNCTION      : Parent
' PARAMETERS    :
' DESCRIPTION   : Reference the MSIXProperty parent instance
' RETURN        :
Public Property Get Parent() As MSIXProperties

    On Error GoTo ErrMgr

    If (Not IsValidObject(m_Parent)) Then
        RaiseError Replace(MTMSIX_ERROR_01055, "[NAME]", "Interval"), , , LOG_APPLICATION_ERROR
        
    End If
    Set Parent = m_Parent

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Parent", "MSIXIntervalId.cls", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Parent
' PARAMETERS    :
' DESCRIPTION   : Gets the parent MSIXProperties of the object.
' RETURN        :
Public Property Set Parent(ByVal vNewValue As MSIXProperties)

    On Error GoTo ErrMgr

    Set m_Parent = vNewValue

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Parent", "MSIXIntervalId.cls", LOG_ERROR
End Property

Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    
    DisplayInvoiceNumber = True
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXInterval.cls", "Class_Initialize", LOG_ERROR
End Sub

Private Sub Class_Terminate()
    
    On Error GoTo ErrMgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXInterval.cls", "Class_Terminate", LOG_ERROR
End Sub
