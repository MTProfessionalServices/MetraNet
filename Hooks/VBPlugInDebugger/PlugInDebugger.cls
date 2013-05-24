VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PlugInDebugger"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Implements IMTHook


Dim logger As logger

Dim enumConfig As MTENUMCONFIGLib.enumConfig
Dim nameID As NAMEIDLib.MTNameID





Private Sub IMTHook_Execute(ByVal var As Variant, pVal As Long)
    
    If logger Is Nothing Then
        Set logger = New logger
        logger.Init "Logging\plugindebug", "[PlugInDebugger]"
    End If

  If nameID Is Nothing Then
    Set nameID = New NAMEIDLib.MTNameID
  End If
    'Mutex is used to protect one plugin logging on top of another in the
    'the case of a compound like audioconf
    Dim hMutex
    hMutex = CreateMutex(0, 0, "PlugInDebugger")
    
    If hMutex = 0 Then
        'What to do with this error
        logger.LogThis 4, "ERROR: Unable to create Mutex in PipeLineDebugger [" & GetLastError & "]"
    End If

    Dim exInfo As IMTExecutionInfo
    Set exInfo = var

    'Enter Critical Section
    Dim bRet As Long
    bRet = WaitForSingleObject(hMutex, INFINITE)
        'logger.LogThis 4, "WaitForSingleObject returned [" & bRet & "] ThreadId [" & GetCurrentThreadId & "]"
        
    'If lastState = 2 And pVal = 1 And lastStage = exInfo.StageName Then
    '    DumpAbbreviated exInfo, pVal
    'Else
    'Sleep (5000)
    
    DumpSessionsEx exInfo, pVal
        
    'Leave critical section
    bRet = ReleaseMutex(hMutex)
         'logger.LogThis 4, "ReleaseMutex returned [" & bRet & "] ThreadId [" & GetCurrentThreadId & "]"
   
    lastPlugIn = exInfo.PlugInName
    lastStage = exInfo.StageName
    lastState = pVal

    CloseHandle (hMutex)
End Sub

Private Function GetStateString(state As Long)
    If state = 1 Then
        GetStateString = "is about to execute"
    Else
        GetStateString = "finished executing"
    End If
End Function

Private Sub DumpAbbreviated(exInfo As IMTExecutionInfo, state As Long)
    logger.LogThis 4, "--- Stage " & exInfo.StageName & " " & GetStateString(state) _
        & " execute plug-in " & exInfo.PlugInName

    Dim sessions As IMTSessionSet
    Set sessions = exInfo.SessionSet

    Dim session As IMTSession

    For Each session In sessions
        ' log the session ID
        logger.LogThis 4, "Session " & _
            session.UIDAsString & " (properties unchanged)"
    Next

End Sub

Private Sub DumpSessions(exInfo As IMTExecutionInfo, state As Long)
    logger.LogThis 4, "Stage " & exInfo.StageName & " is about to execute plug-in " & exInfo.PlugInName

    Dim sessions As IMTSessionSet
    Set sessions = exInfo.SessionSet

    Dim session As IMTSession

    For Each session In sessions
        ' log the session ID
        logger.LogThis 4, "Session " & session.UIDAsString

        ' log all the session properties
        Dim prop As IMTSessionProp
        For Each prop In session
            Dim name As String
            name = LCase(prop.name)

            Dim strType As String
            Dim strValue As String
    
            Select Case prop.Type
            Case SESS_PROP_TYPE_DATE
                strType = "DATETIME"
                strValue = session.GetOLEDateProperty(prop.nameID)
                
            Case SESS_PROP_TYPE_TIME
                strType = "INT32"
                strValue = session.GetTimeProperty(prop.nameID)
                                
            Case SESS_PROP_TYPE_STRING
                strType = "STRING"
                strValue = session.GetBSTRProperty(prop.nameID)
                    
            Case SESS_PROP_TYPE_LONG
                strType = "INT32"
                strValue = CStr(session.GetLongProperty(prop.nameID))

            Case SESS_PROP_TYPE_LONGLONG
                strType = "INT64"
          strValue = CStr(session.GetLongLongPropertyAsString(prop.nameID))
    
            Case SESS_PROP_TYPE_DOUBLE
                strType = "DOUBLE"
                strValue = CStr(session.GetDoubleProperty(prop.nameID))
                    
            Case SESS_PROP_TYPE_BOOL
                strType = "BOOLEAN"
                If session.GetBoolProperty(prop.nameID) = True Then
                    strValue = "True"
                Else
                    strValue = "False"
                End If

            Case SESS_PROP_TYPE_DECIMAL
                strType = "DECIMAL"
                strValue = CStr(session.GetDecimalProperty(prop.nameID))

            Case SESS_PROP_TYPE_ENUM
                strType = "ENUM"
                ' TODO: convert to string
                'strValue = enumConfig.GetEnumeratorValueByID(
                'enumConfig->GetEnumeratorValueByID(aSession->GetEnumProperty(nameid));
                'inputsSet->InsertProp((const wchar_t *) name, PROP_TYPE_STRING, value);
 
                strValue = CStr(session.GetEnumProperty(prop.nameID))
            
            Case Else
                strType = "UNKNOWN"
                strValue = "UNKNOWN"
            End Select

            ' log it
            logger.LogThis 4, name & " (" & strType & ")" & " = " & strValue

        Next
    
    Next
End Sub

Private Sub DumpSessionsEx(exInfo As IMTExecutionInfo, state As Long)
    'logger.LogThis 4, "Stage " & exInfo.StageName & " is about to execute plug-in " & exInfo.PlugInName
    Dim strSessionInfo
    Dim strState
    If state = 1 Then
        strState = "start"
    Else
        strState = "end"
    End If
    
    Dim sessions As IMTSessionSet
    Set sessions = exInfo.SessionSet

  Dim session As IMTSession
    
    For Each session In sessions
        ' log the session ID
        'logger.LogThis 4, "Session " & session.UIDAsString
    strSessionInfo = strSessionInfo & vbCrLf & "<session uid=""" & session.UIDAsString & """ parentuid=""" & session.ParentUIDAsString & """ servicename=""" & nameID.GetName(session.ServiceID) & """ stage=""" & exInfo.StageName & """ plugin=""" & exInfo.PlugInName & """ state=""" & strState & """>" & vbCrLf
        
        ' log all the session properties
        Dim prop As IMTSessionProp
        For Each prop In session
            Dim name As String
            name = LCase(prop.name)

            Dim strType As String
            Dim strValue As String
    
            Select Case prop.Type
            Case SESS_PROP_TYPE_DATE
            
                strType = "DATETIME"
                strValue = session.GetOLEDateProperty(prop.nameID)
                
            Case SESS_PROP_TYPE_TIME
            
                strType = "INT32"
                strValue = session.GetTimeProperty(prop.nameID)
                    
            Case SESS_PROP_TYPE_STRING
                strType = "STRING"
                strValue = session.GetBSTRProperty(prop.nameID)
                    
        Case SESS_PROP_TYPE_LONG
          strType = "INT32"
          strValue = CStr(session.GetLongProperty(prop.nameID))

        Case SESS_PROP_TYPE_LONGLONG
          strType = "INT64"
          strValue = CStr(session.GetLongLongPropertyAsString(prop.nameID))
    
            Case SESS_PROP_TYPE_DOUBLE
                strType = "DOUBLE"
                strValue = CStr(session.GetDoubleProperty(prop.nameID))
                    
            Case SESS_PROP_TYPE_BOOL
                strType = "BOOLEAN"
                If session.GetBoolProperty(prop.nameID) = True Then
                    strValue = "True"
                Else
                    strValue = "False"
                End If

            Case SESS_PROP_TYPE_DECIMAL
                strType = "DECIMAL"
                strValue = CStr(session.GetDecimalProperty(prop.nameID))

            Case SESS_PROP_TYPE_ENUM
                strType = "ENUM"
                ' TODO: convert to string
                strValue = CStr(session.GetEnumProperty(prop.nameID))
            
            Case Else
                strType = "UNKNOWN"
                strValue = "UNKNOWN"
            End Select

            ' log it
            'logger.LogThis 4, name & " (" & strType & ")" & " = " & strValue
            strSessionInfo = strSessionInfo & vbTab & "<" & name & " ptype=""" & strType & """>" & strValue & "</" & name & ">" & vbCrLf
        Next
        strSessionInfo = strSessionInfo & "</session>" & vbCrLf
    Next
    logger.LogThis 4, strSessionInfo
End Sub

