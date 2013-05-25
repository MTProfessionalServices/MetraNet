VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CPipeLineAccess"
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
'  CLASS        : CPipeLineAccess
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  : This class is wrapper for all MT componants and functions that allow
'                 to meter.
'                 The properties are first stored in a CVariable collection called Properties.
'                 This class support synchronous and asynchronous metering.
'                 This class allow to meter parent/child transaction too.
'                 If a function failed the error and more info are logged in the default log.
'                 This class know how to meter any Visual Basic instance, see function SetPropertiesFromInstance()
'
'  VERSION      : none.
'
' MODIFIED      : $Date: 7/9/2002 3:54:57 PM$
' LAST AUTHOR   : $Author: Alon Becker$
' REVISION      : $Revision: 33$
' FILENAME      : $Workfile: CPipeLineAccess.cls$
'
'****************************************************************************************************************************************************
Option Explicit

Public TRACE_ID As Long

Public Properties           As New CVariables

Public Server               As String
Public Session              As String
Public UserName             As String
Public PassWord             As String
Public ObjectName           As String
Public RequestResponse      As Boolean

Public InSessionSet        As COMMeterLib.SessionSet

' The object session to make the call must be alive until we have finished
' included the output session values
Private m_objINSession              As COMMeterLib.Session

Private m_objOUTSession             As COMMeterLib.Session
Private m_objMeter                  As COMMeterLib.Meter
Private m_booMeteringInitialized    As Boolean '

Public Enum PAYMENT_SERVER_ERRORS
    
    CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND = &HE18F0011
    CREDITCARDACCOUNT_SUCCESS = &H618F0013
    

End Enum

Public Enum PIPELINE_ERRORS
    MT_INTERNAL_CPIPELINE_ERROR = -1
    MT_SUCCESS = 0
End Enum

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : InitializeMetering()
' DESCRIPTION   : Initialize the mandatory parameters for a metering. In the case of a Atomic metering you do not need
'                 to call this function. In the case of a parent/child YES (See CreateChildSession()).
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Public Function InitializeMetering(Optional ByVal SessionContext As Object, Optional ByVal eMeterMode As eMSIX_METER_MODE = eMSIX_METER_MODE_METER_SESSION) As Boolean

    On Error GoTo ErrMgr

    Dim objServerAccessSet      As New MTServerAccessDataSet
    Dim objServerAccess         As MTServerAccessData
    
    If (Not m_booMeteringInitialized) Then ' Do it only once
    
        Set m_objMeter = New Meter
        
        ClearSession
            
        ' Initialize the object, then search for the ServerAccess inFormation With the inFormation, set all the metering parameters
        TRACE "CPipeLineAccess.InitializeMetering() ObjectName=" & ObjectName
        objServerAccessSet.Initialize
        Set objServerAccess = objServerAccessSet.FindAndReturnObject(ObjectName)
        Set objServerAccessSet = Nothing
        
        With objServerAccess
            m_objMeter.HTTPTimeout = .Timeout
            m_objMeter.HTTPRetries = .NumRetries
            Call m_objMeter.AddServer(.Priority, .ServerName, .PortNumber, .Secure, .UserName, .PassWord)
            TRACE PreProcess("InitializeMetering ServerName:[SERVERNAME] Priority:[PRIORITY] PortNumber:[PORTNUMBER] Secure:[SECURE] UserName:[USERNAME] TimeOut:[TIMEOUT]", "SERVERNAME", .ServerName, "PRIORITY", .Priority, "PORTNUMBER", .PortNumber, "SECURE", .Secure, "USERNAME", .UserName, "TIMEOUT", .Timeout), Me, "InitializeMetering", LOG_DEBUG
        End With
        
        Set objServerAccess = Nothing
        
        m_objMeter.Startup
    
        ' Create the session set and session object
    
        Set InSessionSet = m_objMeter.CreateSessionSet
        
        NewSession ' Create a new blank session
        
        ' Set the security
        If IsValidObject(SessionContext) Then
    
            If Len(SessionContext.SecurityContext.ToXML) Then
            
                TRACE PreProcess("Meter to [SERVICE] with security context [CONTEXT]", "SERVICE", ObjectName, "CONTEXT", "blur"), TypeName(Me), "InitializeMetering", LOG_DEBUG 'SessionContext.SecurityContext.ToXML
                InSessionSet.SessionContext = SessionContext.SecurityContext.ToXML
            End If
        Else
            TRACE PreProcess("No Session Contect for metering [SERVICE]", "SERVICE", ObjectName), TypeName(Me), "InitializeMetering", LOG_DEBUG
        End If
        m_booMeteringInitialized = True
    End If
    InitializeMetering = True
    Exit Function

ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CPipeLineAccess.cls", "InitializeMetering", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Meter
' DESCRIPTION   : Meter the service (see var session) with the properties in the object Properties
'                 (A collection of CVariable(Name,Value,Type instance)) .
'                 To meter parent/child session see InitializeMetering()
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Public Function Meter( _
 _
    Optional ByVal booSynchronous As Boolean = False, _
    Optional ByVal SessionContext As Object, _
    Optional ByVal eMeterMode As eMSIX_METER_MODE = eMSIX_METER_MODE_METER_SESSION, _
    Optional ByVal booMeterAsSafeTransaction As Boolean = False, _
    Optional ByVal strMeterAsSafeTransactionSessionID As String _
 _
    ) As Boolean
  
    On Error GoTo ErrMgr
    
    Dim lngPropertyIndex        As Long
    Dim objVar                  As CVariable
    
    TRACE "CPipeLineAccess.Meter booSynchronous=" & booSynchronous, "CPipelineAccess.cls", "Meter()"
    
    ' In the case of a parent child metering
    InitializeMetering SessionContext, eMeterMode
            
    m_objINSession.RequestResponse = Abs(RequestResponse) ' Session attribut
       
    Select Case eMeterMode
    
        Case eMSIX_METER_MODE_METER_SESSION ' Default mode we meter one session
        
            AddPropertiesToSession Properties, m_objINSession
            
            If booMeterAsSafeTransaction Then
            
                TRACE "CPipeLineAccess About to close as safe transaction", "CPipelineAccess.cls", "Meter()"
                
'                'Debug.Assert 0
                Dim strXML As String
                strXML = InSessionSet.ToXML

                ' create and begin the transaction
                Dim objMTTransaction As Object
                Set objMTTransaction = CreateObject("PipelineTransaction.MTTransaction.1")
                objMTTransaction.Begin "Pipeline", m_objMeter.HTTPTimeout * 1000

                Dim objFailures
                Set objFailures = CreateObject("MetraPipeline.MTSessionFailures.1")

                Dim objPipeline
                Set objPipeline = CreateObject("MetraPipeline.MTPipeline.1")

                ' Delete the error and submit the new session within the transaction
                objFailures.AbandonSession strMeterAsSafeTransactionSessionID, objMTTransaction
                objPipeline.SubmitMessage strXML, objMTTransaction
                
                objMTTransaction.Commit ' -- Commit both steps
        
            Else
            
                TRACE "CPipeLineAccess About to close", "CPipelineAccess.cls", "Meter()"
                InSessionSet.Close
                ' If the user ask for a return session object
                If (booSynchronous) Then Set m_objOUTSession = m_objINSession.ResultSession
            End If
            TRACE "CPipeLineAccess.Meter SUCCEED", "CPipelineAccess.cls", "Meter()"
            Set m_objMeter = Nothing
            m_booMeteringInitialized = False
            
        Case eMSIX_METER_MODE_PASS_FIRST_SESSION ' Session Set mode - Pass the data
            ' The InitializeMetering has created a new session
            AddPropertiesToSession Properties, m_objINSession
            
        Case eMSIX_METER_MODE_PASS_SESSION
            Me.NewSession
            AddPropertiesToSession Properties, m_objINSession
            
        Case eMSIX_METER_MODE_METER_SESSION_SET ' Session Set mode - Meter the session
            TRACE "CPipeLineAccess About to close session set", "CPipelineAccess.cls", "Meter()"
            InSessionSet.Close
            TRACE "CPipeLineAccess.Meter SessionSet SUCCEED", "CPipelineAccess.cls", "Meter()"
            ' If the user ask for a return session object
            'If (booSynchronous) Then Set m_objOUTSession = m_objINSession.ResultSession
            Set m_objMeter = Nothing
            m_booMeteringInitialized = False
    End Select
    Meter = True
    Exit Function
    
   
' MDM3.6 -- Just in case we need it...

'CLOSE_INSESSIONSET:
'
'    Dim lngCloseCounter As Long
'    Dim e As New CError
'
'    Do While True
'
'        If lngCloseCounter > 0 Then
'            TRACE App.EXEName & ".dll-About to close the Session for the " & lngCloseCounter + 1 & " time(s)", Me, "Meter", LOG_WARNING
'        End If
'
'        On Error Resume Next
'        Set e = New CError
'        InSessionSet.Close
'        e.Save Err.Number, Err.Description, Err.Source
'        On Error GoTo ErrMgr
'
'        lngCloseCounter = lngCloseCounter + 1
'
'        If e.Number = MT_ERR_SERVER_BUSY Then
'
'            TRACE App.EXEName & ".dll-" & TypeName(Me) & "Detect error MT_ERR_SERVER_BUSY wait for 5 Minutes." & e.ToString, Me, "Meter", LOG_WARNING
'            SleepMinutes 5
'
'        ElseIf e.Number = MT_ERR_SYN_TIMEOUT Then
'
'            TRACE App.EXEName & ".dll-" & TypeName(Me) & "Detect error MT_ERR_SYN_TIMEOUT wait for 4 Minutes." & e.ToString, Me, "Meter", LOG_WARNING
'            SleepMinutes 5
'
'        ElseIf e.Number = 0 Then
'
'            Exit Do
'        Else
'            e.Raise
'        End If
'    Loop
'Return
    
    
    
    
    
    
    
ErrMgr:

    Dim objError As New CError
        
    objError.Save Err.Number, Err.Description, Err.Source, "CPipeLineAccess.Meter FAILED", "CPipeLineAccess.cls", "Meter", , LOG_ERROR
    
    If CBool(objError.Number = MT_ERR_SERVER_BUSY) Or CBool(objError.Number = MT_ERR_SYN_TIMEOUT) Then
        TRACE objError.ToString, , , LOG_WARNING
    Else
        TRACE objError.ToString, , , LOG_ERROR
    End If
    
    m_booMeteringInitialized = False
    Err.Raise objError.Number, objError.Source, objError.Description
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SetPropertiesFromInstance
' DESCRIPTION   : This function allow to set the metering properties from ANY VB instance.
' PARAMETERS    :
'                   obj                 -   The VB Instance w ewant to meter.
'                   strPropertiesList   -   A String that describe the property of the VB instance. Format is : PropertyName=MaxLength;
'                                           For numeric the value is 0. The size of the string properties are is checked.
' RETURNS       :
Public Function SetPropertiesFromInstance(obj As Object, strPropertiesList As String, Optional booClear As Boolean = True, Optional booRaiseError As Boolean = True) As Boolean
    
    Dim objPropertiesList   As New CVariables
    Dim objPropertyList     As CVariable
    Dim objParser           As New CByteSyntaxAnalyser
    Dim strProperty         As String
    Dim strVBProperty       As String
    Dim strVal              As Variant
    Dim lngSize             As Long
    
    On Error GoTo ErrMgr
    
    If (booClear) Then Properties.Clear
        
    objParser.Init strPropertiesList
    
    objPropertiesList.caseSensitive = True
    
    If (objPropertiesList.LoadSet(objParser, ";")) Then
    
        For Each objPropertyList In objPropertiesList
        
            strProperty = objPropertyList.Name
            strVBProperty = strProperty
            lngSize = CLng(objPropertyList.Value)
            
            ' To avoid this property that start with an '_'
            If (Left(strVBProperty, 1) = "_") Then strVBProperty = Mid$(strVBProperty, 2)
            'Debug.Print strProperty
            
            'strVal = CallByName(obj, strVBProperty, VbGet)
            strVal = obj.Property(strVBProperty)
            'Debug.Print strVal
            
            ' If we have a size to check
            If (lngSize > 0) Then
            
                If (Len(CStr(strVal)) > lngSize) Then    ' Check the size
                
                    If (booRaiseError) Then
                    
                        On Error GoTo 0
                        Err.Raise vbObjectError + 1, App.EXEName, "Property " & strProperty & " value too big. Max size is " & lngSize & "."
                    End If
                End If
            End If
            Me.Property(strProperty) = strVal
        Next
    End If
    SetPropertiesFromInstance = True
    Exit Function
ErrMgr:
    If (booRaiseError) Then
        Err.Raise Err.Number, Err.Source, Err.Description
    Else
        Resume Next
    End If
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ClearSession
' DESCRIPTION   : Delete the Input and OutPut Metering Session.
' PARAMETERS    :
' RETURNS       :
Private Function ClearSession() As Boolean

    On Error GoTo ErrMgr


    
    Set m_objINSession = Nothing
    Set m_objOUTSession = Nothing
    Set InSessionSet = Nothing
    ClearSession = True

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CPipeLineAccess.cls", "ClearSession", LOG_ERROR
End Function
 
Private Sub Class_Initialize()
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Terminate
' DESCRIPTION   : Desctructor
' PARAMETERS    :
' RETURNS       :
Private Sub Class_Terminate()
    
    On Error GoTo ErrMgr

    ClearSession
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CPipeLineAccess.cls", "Class_Terminate", LOG_ERROR
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ReturnedProperty
' DESCRIPTION   : Returns the OUTPUT property strPropertyName from the OUTPUT Session. This can be used only with
'                 Synchronous metering and the service must return properties.
' PARAMETERS    :
' RETURNS       :
Public Property Get ReturnedProperty(ByVal strPropertyName As String) As Variant

    On Error GoTo ErrMgr
    
    
    Dim objError As New CError
    
    If (Not m_objOUTSession Is Nothing) Then
        ReturnedProperty = m_objOUTSession.GetProperty(strPropertyName)
    End If
    Exit Property
ErrMgr:
    ''Debug.Assert 0
    objError.Save "Property " & strPropertyName & " not found in returned session", "CPipeLineAccess.cls", "ReturnedProperty"
    

End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Property LET
' DESCRIPTION   : Set the metering property strPropertyName
' PARAMETERS    :
' RETURNS       :
Public Property Let Property(ByVal strPropertyName As String, ByVal vNewValue As Variant)

    On Error GoTo ErrMgr

    Properties.Add strPropertyName, vNewValue

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CPipeLineAccess.cls", "Property", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : OutSession
' DESCRIPTION   : Returns the Output Session
' PARAMETERS    :
' RETURNS       :
Public Property Get OutSession() As Session

    On Error GoTo ErrMgr


    Set OutSession = m_objOUTSession

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "CPipeLineAccess.cls", "OutSession", LOG_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SetInstanceFromSessionProperty
' DESCRIPTION   : Set a ANY VB Instance with the properties of the class (object Properties).
'                 This function do the opposite of the function SetPropertiesFromInstance().
' PARAMETERS    :
' RETURNS       :
Public Function SetInstanceFromSessionProperty(obj As Object, strPropertiesList As String, Optional booRaiseError As Boolean = True) As Boolean

    Dim objPropertiesList   As New CVariables
    Dim objPropertyList     As CVariable
    Dim objParser           As New CByteSyntaxAnalyser
    Dim strProperty         As String
    Dim strVBProperty       As String
    Dim strVal              As Variant
    Dim lngSize             As Long
    
    On Error GoTo ErrMgr
        
    objParser.Init strPropertiesList
    
    objPropertiesList.caseSensitive = True
    
    If (objPropertiesList.LoadSet(objParser, ";")) Then
    
        For Each objPropertyList In objPropertiesList
        
            strProperty = objPropertyList.Name
            strVBProperty = strProperty
            strVal = Me.ReturnedProperty(strProperty)
            
            ' To avoid this property that start with an '_'
            If (Left(strVBProperty, 1) = "_") Then
                strVBProperty = Mid$(strVBProperty, 2)
            End If
            CallByName obj, strVBProperty, VbLet, strVal
        Next
    End If
    SetInstanceFromSessionProperty = True
    Exit Function
ErrMgr:
    If (booRaiseError) Then
        Err.Raise Err.Number, Err.Source, Err.Description
    Else
        Resume Next
    End If
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : InstanceToString
' DESCRIPTION   : Returns ANY VB Instance value into a string. See comment of SetPropertiesFromInstance().
' PARAMETERS    :
' RETURNS       :
Public Function InstanceToString(obj As Object, strPropertiesList As String, Optional booRaiseError As Boolean = True) As String

    Dim objPropertiesList   As New CVariables
    Dim objPropertyList     As CVariable
    Dim objParser           As New CByteSyntaxAnalyser
    Dim strProperty         As String
    Dim strVBProperty       As String
    Dim strVal              As Variant
    Dim strS                As String
       
    On Error GoTo ErrMgr
        
    objParser.Init strPropertiesList
    
    objPropertiesList.caseSensitive = True
    
    If (objPropertiesList.LoadSet(objParser, ";")) Then
    
        For Each objPropertyList In objPropertiesList
        
            strProperty = objPropertyList.Name
            strVBProperty = strProperty
            strVal = Me.ReturnedProperty(strProperty)
            
            ' To avoid this property that start with an '_'
            If (Left(strVBProperty, 1) = "_") Then strVBProperty = Mid$(strVBProperty, 2)
            
            strVal = CallByName(obj, strVBProperty, VbGet)
            
            strS = strS & strProperty & "=" & IIf(IsNull(strVal) Or IsEmpty(strVal), "NULL", strVal) & vbCrLf
        Next
    End If
    InstanceToString = strS
    Exit Function
ErrMgr:
    If (booRaiseError) Then
        Err.Raise Err.Number, Err.Source, Err.Description
    Else
        Resume Next
    End If
    
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Function CreateChildSession(strServiceName As String, objProperties As CVariables) As Boolean

    On Error GoTo ErrMgr
    
    Dim objSession  As Session
    Dim objError    As New CError
    
    ' Alloc a child session
    Set objSession = m_objINSession.CreateChildSession(strServiceName)
    
    ' Fill the child session with the properties
    If (AddPropertiesToSession(objProperties, objSession)) Then
    
        CreateChildSession = True
    End If
    Exit Function
ErrMgr:
    objError.Save Err.Number, Err.Description, Err.Source, , "CPipeLineAccess.cls", "CreateChildSession"
    TRACE objError.ToString
    objError.Raise
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : AddPropertiesToSession
' DESCRIPTION   : Add all the properties (Name,Value) from the object objProperties to the session
'                 objSession.
' PARAMETERS    :
' RETURNS       :
Private Function AddPropertiesToSession(objProperties As CVariables, objSession As Session) As Boolean

    On Error GoTo ErrMgr
    
    Dim objVar              As CVariable
    Dim lngPropertyIndex    As Long
    Dim objError            As New CError
    Dim varValue            As Variant
    
    For Each objVar In objProperties
    
        lngPropertyIndex = lngPropertyIndex + 1
        
        If (Right(objVar.Name, 1) = "_") Then
        
            #If DOT_NOT_BLUR Then
                varValue = objVar.Value
            #Else
                varValue = "blur"
            #End If
        Else
            varValue = objVar.Value
        End If
        TRACE "CPipeLineAccess.Meter Service=" & Session & " " & CStr(lngPropertyIndex) & " Property " & objVar.Name & " Type=" & TypeName(objVar.Value) & "; Value=" & varValue & ";"
        objSession.InitProperty objVar.Name, objVar.Value
    Next
    AddPropertiesToSession = True
    Exit Function
ErrMgr:
    objError.Save Err.Number, Err.Description, Err.Source, "Property " & objVar.Name & "=" & PrintableNULL(objVar.Value), "CPipeLineAccess.cls", "AddPropertiesToSession"
    TRACE objError.ToString, , , LOG_ERROR
    objError.Raise
End Function

Public Function NewSession() As Boolean
    Set m_objINSession = InSessionSet.CreateSession(Session)
    NewSession = True
End Function

Friend Function CleanMeteredSessionSet() As Boolean

    On Error GoTo ErrMgr
    
    ClearSession
    Set m_objMeter = Nothing
    CleanMeteredSessionSet = False
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "CleanMeteredSessionSet", LOG_ERROR
End Function
