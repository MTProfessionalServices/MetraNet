VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PerformanceMonitor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
' Copyright 1998, 2001 by MetraTech Corporation
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
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' NAME          :   PerformanceMonitor.cls
' DESCRIPTION   :   Class that return Performance Monitor Counter
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' History :
'           -   Written by THE BOUCHER, who took the code from where, nobody knows.
'           -   ReArrange by Fred.
'
' Remarks : This code trahs IIS when called from an asp page...Noa Said.
'
' ****************************************************************************************************************************************************
Option Explicit

Private Enum PERF_DETAIL
  PERF_DETAIL_NOVICE = 100      ' The uninformed can understand it
  PERF_DETAIL_ADVANCED = 200    ' For the advanced user
  PERF_DETAIL_EXPERT = 300      ' For the expert user
  PERF_DETAIL_WIZARD = 400      ' For the system designer
End Enum

Private Enum PDH_STATUS
  PDH_CSTATUS_VALID_DATA = &H0
  PDH_CSTATUS_NEW_DATA = &H1
  PDH_CSTATUS_NO_MACHINE = &H800007D0
  PDH_CSTATUS_NO_INSTANCE = &H800007D1
  PDH_MORE_DATA = &H800007D2
  PDH_CSTATUS_ITEM_NOT_VALIDATED = &H800007D3
  PDH_RETRY = &H800007D4
  PDH_NO_DATA = &H800007D5
  PDH_CALC_NEGATIVE_DENOMINATOR = &H800007D6
  PDH_CALC_NEGATIVE_TIMEBASE = &H800007D7
  PDH_CALC_NEGATIVE_VALUE = &H800007D8
  PDH_DIALOG_CANCELLED = &H800007D9
  PDH_CSTATUS_NO_OBJECT = &HC0000BB8
  PDH_CSTATUS_NO_COUNTER = &HC0000BB9
  PDH_CSTATUS_INVALID_DATA = &HC0000BBA
  PDH_MEMORY_ALLOCATION_FAILURE = &HC0000BBB
  PDH_INVALID_HANDLE = &HC0000BBC
  PDH_INVALID_ARGUMENT = &HC0000BBD
  PDH_FUNCTION_NOT_FOUND = &HC0000BBE
  PDH_CSTATUS_NO_COUNTERNAME = &HC0000BBF
  PDH_CSTATUS_BAD_COUNTERNAME = &HC0000BC0
  PDH_INVALID_BUFFER = &HC0000BC1
  PDH_INSUFFICIENT_BUFFER = &HC0000BC2
  PDH_CANNOT_CONNECT_MACHINE = &HC0000BC3
  PDH_INVALID_PATH = &HC0000BC4
  PDH_INVALID_INSTANCE = &HC0000BC5
  PDH_INVALID_DATA = &HC0000BC6
  PDH_NO_DIALOG_DATA = &HC0000BC7
  PDH_CANNOT_READ_NAME_STRINGS = &HC0000BC8
End Enum

Private Const ERROR_SUCCESS = 0

Private Declare Function PdhVbGetOneCounterPath Lib "PDH.DLL" (ByVal PathString As String, ByVal PathLength As Long, ByVal DetailLevel As Long, ByVal CaptionString As String) As Long
Private Declare Function PdhVbCreateCounterPathList Lib "PDH.DLL" (ByVal PERF_DETAIL As Long, ByVal CaptionString As String) As Long
Private Declare Function PdhVbGetCounterPathFromList Lib "PDH.DLL" (ByVal Index As Long, ByVal Buffer As String, ByVal BufferLength As Long) As Long
Private Declare Function PdhOpenQuery Lib "PDH.DLL" (ByVal Reserved As Long, ByVal dwUserData As Long, ByRef hQuery As Long) As PDH_STATUS
Private Declare Function PdhCloseQuery Lib "PDH.DLL" (ByVal hQuery As Long) As PDH_STATUS
Private Declare Function PdhVbAddCounter Lib "PDH.DLL" (ByVal QueryHandle As Long, ByVal CounterPath As String, ByRef CounterHandle As Long) As PDH_STATUS
Private Declare Function PdhCollectQueryData Lib "PDH.DLL" (ByVal QueryHandle As Long) As PDH_STATUS
Private Declare Function PdhVbIsGoodStatus Lib "PDH.DLL" (ByVal StatusValue As Long) As Long
Private Declare Function PdhVbGetDoubleCounterValue Lib "PDH.DLL" (ByVal CounterHandle As Long, ByRef CounterStatus As Long) As Double
    

Private m_lngQueryHandle        As Long             'handle to the pdh query
Private m_lngCounter            As Long             'handle to the counter

Public Query                    As String

Public Function Initialize(ByVal strQuery) As Boolean

  On Error GoTo Errmgr
    
  Dim pdhStatus As PDH_STATUS   'status returned from calls
  
  Query = strQuery
    
  m_lngQueryHandle = 0
  m_lngCounter = 0
  
  'Open the pdh Query (remember to close!)
  If m_lngQueryHandle = 0 Then
        pdhStatus = PdhOpenQuery(CLng(0), CLng(0), m_lngQueryHandle)
  End If
    
  If pdhStatus <> ERROR_SUCCESS Then
        Err.Description = "Unable to Open the PDH Query <pdh error code:" & pdhStatus & ">"
        Exit Function
  End If
  
  'Add the counter
  pdhStatus = PdhVbAddCounter(m_lngQueryHandle, Query, m_lngCounter)
  
  If pdhStatus <> ERROR_SUCCESS Then
        Err.Description = "Unable to Add PDH Counter <pdh error code:" & pdhStatus & "  pdh counter: " & strQuery & ">"
        Exit Function
  End If
  Initialize = True
  Exit Function

Errmgr:
    CloseQuery
End Function


Public Function GetValue(ByRef Value As Variant) As Boolean

  On Error GoTo Errmgr
  
  Dim pdhStatus As PDH_STATUS
  Dim dblValue  As Double
  
  If m_lngQueryHandle <> 0 Then
  
        pdhStatus = PdhCollectQueryData(m_lngQueryHandle)
      
        If pdhStatus <> ERROR_SUCCESS Then
            Err.Description = "Unable to Get Query Data <pdh error code:" & pdhStatus & ">"
            Exit Function
        End If
    
        Value = PdhVbGetDoubleCounterValue(m_lngCounter, pdhStatus)
                    
      ' Verify that when we queried, the returned value was valid
        'If pdhStatus <> PDH_CSTATUS_VALID_DATA And pdhStatus <> PDH_CSTATUS_NEW_DATA Then
         ' Err.Description = "Unable to Get Valid Data <pdh error code:" & pdhStatus & ">"
         ' Err.Raise vbObjectError + 1
        'End If

    
  Else
        Err.Description = "No valid Query Handle"
        Exit Function
  End If
  GetValue = True
  Exit Function
Errmgr:
  
End Function

Public Function CloseQuery() As Boolean

    On Error GoTo Errmgr
    
    PdhCloseQuery m_lngQueryHandle
    m_lngQueryHandle = 0
    CloseQuery = True
    Exit Function
Errmgr:

End Function

