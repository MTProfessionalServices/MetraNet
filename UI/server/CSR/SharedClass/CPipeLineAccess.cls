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
'**************************************************************************
'
'  Copyright 1998 by MetraTech Corporation
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
'  CLASS        : CPipeLineAccess
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  : This class is wrapper for all MT componants and functions that allow
'                 to meter. This class know how a to meter generically any Visual Basic instance in read or write mode.
'                 The properties are first stored in a CVariable collection called properties.
'                 This class support synchronous and asynchronous metering.
'                 This class allow to meter parent/child transaction too.
'                 If a function failed the error and more info are logged in the default log.
'                 This class know how to meter any Visual Basic instance, see function SetPropertiesFromInstance()
'                 for a metering the data to the BackEnd or SetInstanceFromSessionProperty() to get data from the pipeline.
'  VERSION      : none.
'
'**************************************************************************
Option Explicit

Public Properties           As New CVariables

Public Server               As String
Public Session              As String
Public UserName             As String
Public PassWord             As String
Public ObjectName           As String
Public RequestResponse      As Boolean

' The object session to make the call must be alive until we have finished
' included the output session values
Private m_objINSession              As COMMeterLib.Session
Private m_objOUTSession             As COMMeterLib.Session
Private m_objMeter                  As Meter
Private m_booMeteringInitialized    As Boolean

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
Public Function InitializeMetering() As Boolean

    Dim objServerAccessSet      As New MTServerAccessDataSet
    Dim objServerAccess         As MTServerAccessData
    
    If (Not m_booMeteringInitialized) Then ' Do it only once
    
        Set m_objMeter = New Meter
        
        ClearSession
            
        ' Initialize the object, then search for the ServerAccess information With the information, set all the metering parameters
        TRACE "CPipeLineAccess.InitializeMetering() ObjectName=" & ObjectName
        objServerAccessSet.Initialize
        Set objServerAccess = objServerAccessSet.FindAndReturnObject(ObjectName)
        Set objServerAccessSet = Nothing
        
        With objServerAccess
            m_objMeter.HTTPTimeout = .Timeout
            m_objMeter.HTTPRetries = .NumRetries
            Call m_objMeter.AddServer(.Priority, .ServerName, .PortNumber, .Secure, .UserName, .PassWord)
        End With
        
        Set objServerAccess = Nothing
        
        m_objMeter.Startup
    
        ' Create the session object
        Set m_objINSession = m_objMeter.CreateSession(Session)
        
        m_booMeteringInitialized = True
    End If
    InitializeMetering = True
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Meter
' DESCRIPTION   : Meter the service (see var session) with the properties in the object Properties
'                 (A collection of CVariable(Name,Value,Type instance)) .
'                 To meter parent/child session see InitializeMetering()
' PARAMETERS    :
' RETURNS       : TRUE is ok, raise en error if failed
Public Function Meter(Optional ByVal booSynchronous As Boolean = False) As Boolean
  
    On Error GoTo ErrMgr
    
    Dim lngPropertyIndex        As Long
    Dim objVar                  As CVariable
    
    TRACE "CPipeLineAccess.Meter booSynchronous=" & booSynchronous
    
    ' In the case of a parent child metering
    InitializeMetering
        
    m_objINSession.RequestResponse = Abs(RequestResponse) ' Session attribut
        
    AddPropertiesToSession Properties, m_objINSession
    
    TRACE "CPipeLineAccess About to close"
    m_objINSession.Close
    TRACE "CPipeLineAccess.Meter SUCCEED"

    ' If the user ask for a return session object
    If (booSynchronous) Then
        Set m_objOUTSession = m_objINSession.ResultSession
    End If
    
    Set m_objMeter = Nothing
    Meter = True
    m_booMeteringInitialized = False
    Exit Function
ErrMgr:
    Debug.Assert 0
    
    Dim objError As New CError
    objError.Save "CPipeLineAccess.Meter FAILED", "CPipeLineAccess.cls", "Meter", , CERROR_ERROR
    TRACE objError.ToString
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
    
    objPropertiesList.CaseSensitive = True
    
    If (objPropertiesList.LoadSet(objParser, ";")) Then
    
        For Each objPropertyList In objPropertiesList
        
            strProperty = objPropertyList.Name
            strVBProperty = strProperty
            lngSize = CLng(objPropertyList.Value)
            
            ' To avoid this property that start with an '_'
            If (Left(strVBProperty, 1) = "_") Then strVBProperty = Mid(strVBProperty, 2)
            Debug.Print strProperty
            
            'strVal = CallByName(obj, strVBProperty, VbGet)
            strVal = obj.Property(strVBProperty)
            Debug.Print strVal
            
            ' If we have a size to check
            If (lngSize > 0) Then
            
                If (Len(CStr(strVal)) > lngSize) Then    ' Check the size
                
                    If (booRaiseError) Then
                    
                        On Error GoTo 0
                        Err.Raise vbObjectError + 1, App.EXEName, "Property " & strProperty & " value too big. Max size is " & lngSize & "."
                    End If
                End If
            End If
            ' v2.2 we do not meter empty property - this will solve the case of the enum type metered as ""
            'If Len("" & strVal) > 0 Then
                Me.Property(strProperty) = strVal
            'End If
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

    Set m_objINSession = Nothing
    Set m_objOUTSession = Nothing
    ClearSession = True
End Function
 
' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Terminate
' DESCRIPTION   : Desctructor
' PARAMETERS    :
' RETURNS       :
Private Sub Class_Terminate()
    ClearSession
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ReturnedProperty
' DESCRIPTION   : Return the OUTPUT property strPropertyName from the OUTPUT Session. This can be used only with
'                 Synchronous metering and the service must return properties.
' PARAMETERS    :
' RETURNS       :
Public Property Get ReturnedProperty(ByVal strPropertyName As String) As Variant

    On Error GoTo ErrMgr
    
    If (Not m_objOUTSession Is Nothing) Then
        ReturnedProperty = m_objOUTSession.GetProperty(strPropertyName)
    End If
    Exit Property
ErrMgr:
    'Debug.Assert 0
    Err.Raise Err.Number, Err.Source, Err.Description & GetErrorInfoEx("CPipeLineAccess.cls", "ReturnedProperty", "Property " & strPropertyName)
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Property LET
' DESCRIPTION   : Set the metering property strPropertyName
' PARAMETERS    :
' RETURNS       :
Public Property Let Property(ByVal strPropertyName As String, ByVal vNewValue As Variant)
   
    Properties.Add strPropertyName, vNewValue
End Property

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : OutSession
' DESCRIPTION   : Return the Output Session
' PARAMETERS    :
' RETURNS       :
Public Property Get OutSession() As Session

    Set OutSession = m_objOUTSession
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
    
    objPropertiesList.CaseSensitive = True
    
    If (objPropertiesList.LoadSet(objParser, ";")) Then
    
        For Each objPropertyList In objPropertiesList
        
            strProperty = objPropertyList.Name
            strVBProperty = strProperty
            strVal = Me.ReturnedProperty(strProperty)
            
            ' To avoid this property that start with an '_'
            If (Left(strVBProperty, 1) = "_") Then
                strVBProperty = Mid(strVBProperty, 2)
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
' DESCRIPTION   : Return ANY VB Instance value into a string. See comment of SetPropertiesFromInstance().
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
    
    objPropertiesList.CaseSensitive = True
    
    If (objPropertiesList.LoadSet(objParser, ";")) Then
    
        For Each objPropertyList In objPropertiesList
        
            strProperty = objPropertyList.Name
            strVBProperty = strProperty
            strVal = Me.ReturnedProperty(strProperty)
            
            ' To avoid this property that start with an '_'
            If (Left(strVBProperty, 1) = "_") Then strVBProperty = Mid(strVBProperty, 2)
            
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
    objError.Save , "CPipeLineAccess.cls", "CreateChildSession", , CERROR_ERROR
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
    
    For Each objVar In objProperties
    
        lngPropertyIndex = lngPropertyIndex + 1
        
        If (Right(objVar.Name, 1) = "_") Then
            ' Do not trace sensitiv property like a credit card number
            TRACE "CPipeLineAccess.Meter Service=" & Session & " " & CStr(lngPropertyIndex) & " Property " & objVar.Name & " = " & "Blur"
        Else
            TRACE "CPipeLineAccess.Meter Service=" & Session & " " & CStr(lngPropertyIndex) & " Property " & objVar.Name & " = " & objVar.Value
        End If
        
        objSession.InitProperty objVar.Name, objVar.Value
    Next
    AddPropertiesToSession = True
    Exit Function
ErrMgr:
    objError.Save , "CPipeLineAccess.cls", "AddPropertiesToSession", , CERROR_ERROR
    TRACE objError.ToString
    objError.Raise
End Function
