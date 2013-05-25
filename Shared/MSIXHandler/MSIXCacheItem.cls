VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXCacheItem"
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
' $Date$
' $Author$
' $Revision$
' $Workfile$
'

Option Explicit

Public TRACE_ID         As Long
Public Id           As String
Private m_varData   As Variant
Public Hit          As Long
Public CreationTime As Date

'Public CacheName As String
'Public CacheCreationTime As Date

Public Property Get Name() As String

    On Error GoTo errmgr

    Name = Id

    Exit Property
errmgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CacheItem.cls", "Name", LOG_ERROR
End Property

Public Property Let Name(ByVal vNewValue As String)

    On Error GoTo errmgr

    Id = vNewValue

    Exit Property
errmgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CacheItem.cls", "Name", LOG_ERROR
End Property

Public Function IsObject() As Boolean

    On Error GoTo errmgr

    IsObject = VBA.IsObject(Data)

    Exit Function
errmgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CacheItem.cls", "IsObject", LOG_ERROR
End Function
' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo errmgr

    ToString = "name=" & Name & "; datatype=" & TypeName(Data) & "; value=" & IIf(VBA.IsObject(Data), "object", Data)

    Exit Function
errmgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CacheItem.cls", "ToString", LOG_ERROR
End Function

Private Sub Class_Initialize()
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
End Sub

Private Sub Class_Terminate()

    On Error GoTo errmgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If

    Exit Sub
errmgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CacheItem.cls", "Class_Terminate", LOG_ERROR
End Sub

Public Property Get Data() As Variant
Attribute Data.VB_UserMemId = 0

    On Error GoTo errmgr

    
    Hit = Hit + 1

    
    ''Debug.Print "CACHE.GetData, type=" & TypeName(m_varData) & ", Name=" & Name & ", CreationTime=" & CreationTime & ", hit=" & Hit
    
    If (VBA.IsObject(m_varData)) Then
        Set Data = m_varData
    Else
        Data = m_varData
    End If

    Exit Property
errmgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Data", "MSIXCacheItem.cls", LOG_ERROR
End Property

Public Property Let Data(ByVal vNewValue As Variant)

    On Error GoTo errmgr


    CreationTime = MTNow()
    
    ''Debug.Print "CACHE.LetData, type=" & TypeName(vNewValue) & ", Name=" & Name & ", CreationTime=" & CreationTime
    
    If (VBA.IsObject(vNewValue)) Then
        Set m_varData = vNewValue
    Else
        m_varData = vNewValue
    End If

    Exit Property
errmgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Data", "MSIXCacheItem.cls", LOG_ERROR
End Property


Public Property Set Data(ByVal vNewValue As Variant)

    On Error GoTo errmgr




    CreationTime = MTNow
    ''Debug.Print "CACHE.SetDate, type=" & TypeName(vNewValue) & ", Name=" & Name & ", CreationTime=" & CreationTime
    Set m_varData = vNewValue

    Exit Property
errmgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Data", "MSIXCacheItem.cls", LOG_ERROR
End Property
