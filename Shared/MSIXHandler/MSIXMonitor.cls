VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXMonitor"
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
'****************************************************************************************************************************************************
' CLASS         : MSIXMonitor
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : The purpose of this class is to track things in the MSIXxxxxxx classes. For now we
'                 just count the number of MSIXHandler instance created and deleted. See function description.
'
'                 To do so we store the information not in the class itself but in the module MTXServiceModule!
'                 The global variables : g_lngMSIXInstanceActive, g_lngMSIXInstanceCreated are shared by all the instance
'                 MSIXHandler.
'                 When the first class MTMSIX.MSIXHandler is created from an IIS ASP page Site, the COM Object DLL is loaded and all
'                 the global values are allocated and initialized to 0. So if another instance of is created from they share these values.
'
'                 This code is not thread safe! But the purpose of this class is to test the COM Object in a mono client environement.
'
'
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
'****************************************************************************************************************************************************
Option Explicit

Public TRACE_ID As Long

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Count
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get InstanceActiveCount() As Long

    On Error GoTo ErrMgr

    InstanceActiveCount = g_lngMSIXInstanceActive

    Exit Property
ErrMgr:
      TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXMonitor.cls", "InstanceActiveCount", LOG_ERROR
End Property


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Count
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get InstanceCreatedCount() As Long

    On Error GoTo ErrMgr

    InstanceCreatedCount = g_lngMSIXInstanceCreated
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXMonitor.cls", "InstanceCreatedCount", LOG_ERROR
End Property

Private Sub Class_Initialize()

    On Error GoTo ErrMgr

   #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXMonitor.cls", "Class_Initialize", LOG_ERROR
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr

#If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXMonitor.cls", "Class_Terminate", LOG_ERROR
End Sub
