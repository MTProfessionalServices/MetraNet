VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTSQLRowsetSimulator"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'****************************************************************************************************************************************************
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
' CLASS         : MTSQLRowsetSimulator
' AUTHOR        : F.Torres
' CREATION DATE : 09/21/2000
' VERSION       : 1.0
' DESCRIPTION   : This class allows to store rows/columns information in a MTSQLRowset compatible interface COM object. I developed this class,
'                 because the back end boys MAM FIND function return a result in a collection of collection. On the other side the MDM Product
'                 View Browser support only MTSQLRowset Compatible Interface...
'
'
' MODIFIED      : $Date: 11/11/2002 3:05:45 PM$
' LAST AUTHOR   : $Author: Frederic Torres$
' REVISION      : $Revision: 31$
' FILENAME      : $Workfile: MTSQLRowSetSimulator.cls$
'
'****************************************************************************************************************************************************
Option Explicit

Public TRACE_ID As Long

Private m_lngAbsolutePosition As Long
Private m_lngCount            As Long
Private m_lngRecordCount      As Long

Private m_strNames()          As String
Private m_varValues()         As Variant

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : EOF
' PARAMETERS    :
' DESCRIPTION   : MTSQLRowset Interface.
' RETURN        :
Public Property Get EOF() As Boolean

    On Error GoTo ErrMgr

    EOF = m_lngAbsolutePosition >= RecordCount

    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "EOF", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Count
' PARAMETERS    :
' DESCRIPTION   : MTSQLRowset Interface. Return the number of columns
' RETURN        :
Public Property Get Count() As Long

    On Error GoTo ErrMgr

    Count = m_lngCount

    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "Count", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Count
' PARAMETERS    :
' DESCRIPTION   : MTSQLRowset Interface. Return the number of records
' RETURN        :
Public Property Get RecordCount() As Long

    On Error GoTo ErrMgr

    RecordCount = m_lngRecordCount

    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "RecordCount", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   : MTSQLRowset Interface.
' RETURN        :
Public Function Init(ByVal strConfigPath As String) As Boolean

    On Error GoTo ErrMgr

    MoveFirst
    Init = True

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "Init", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   : MTSQLRowset Interface.
' RETURN        :
Public Function MoveFirst() As Boolean

    On Error GoTo ErrMgr

    m_lngAbsolutePosition = 0
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "MoveFirst", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   : MTSQLRowset Interface.
' RETURN        :
Public Function MoveLast() As Boolean

    On Error GoTo ErrMgr

    m_lngAbsolutePosition = RecordCount - 1
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "MoveLast", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   : MTSQLRowset Interface.
' RETURN        :
Public Function MoveNext() As Boolean

    On Error GoTo ErrMgr

    m_lngAbsolutePosition = m_lngAbsolutePosition + 1

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "MoveNext", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   : MTSQLRowset Interface. Free all data and reset all the internal counter.
' RETURN        :
Function Clear() As Boolean

#If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If

    m_lngCount = 0
    m_lngRecordCount = 0

    Erase m_strNames()
    Erase m_varValues()
    
    Clear = True

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "MoveNext", LOG_ERROR
End Function


' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Function Initialize(ByVal lngRecordCount As Long, ByVal lngColumnCount As Long) As Boolean

    m_lngCount = lngColumnCount
    m_lngRecordCount = lngRecordCount
    
    If (Count) Then
        ReDim m_strNames(Count - 1)
    End If
    
    If (RecordCount) Then
        ReDim m_varValues(RecordCount - 1, Count - 1)
    End If

    Initialize = True

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "MoveNext", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Name(varKey As Variant) As Variant

    On Error GoTo ErrMgr

    Name = m_strNames(GetColumnIndex(varKey))
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "Name", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let Name(varKey As Variant, ByVal vNewValue As Variant)

    On Error GoTo ErrMgr

    Dim Index As Long
    Index = GetColumnIndex(varKey)
    If (Index > (m_lngCount - 1) Or (Index < 0)) Then
      RaiseError PreProcess(MTMSIX_ERROR_01108, "INDEX", Index, "SIZE", m_lngCount - 1), TypeName(Me), 1108, LOG_APPLICATION_ERROR
    End If
    
    m_strNames(Index) = vNewValue
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "Name", LOG_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Get Value(varKey As Variant) As Variant

    On Error GoTo ErrMgr
    
    Dim objError As New CError
    Dim strError As String

    Value = m_varValues(m_lngAbsolutePosition, GetColumnIndex(varKey))

    Exit Property
ErrMgr:

    ' Store the error info
    objError.Save Err.Number, Err.Description, Err.Source, , "MTSQLRowSetSimulator.cls", "Value Get"
    
    ' Log the error
    strError = MTMSIX_ERROR_01033 & objError.ToString()
    TRACE strError, "MTSQLRowSetSimulator.cls", "Value", LOG_ERROR
    
    ' Raise the error
    RaiseError strError, , , LOG_APPLICATION_ERROR
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function RemoveRow(ByVal lngIndex As Long) As Boolean

    On Error GoTo ErrMgr
    
    Dim objError As New CError
    Dim strError As String

    Dim i As Long
    Dim j As Long
    
    If lngIndex = Me.RecordCount Then
    Else
      For i = lngIndex To Me.RecordCount - 2
        For j = 0 To Me.Count - 1
          m_varValues(i, j) = m_varValues(i + 1, j)
        Next
      Next
    End If
    m_lngRecordCount = m_lngRecordCount - 1
    
    Exit Function
ErrMgr:

    ' Store the error info
    objError.Save Err.Number, Err.Description, Err.Source, , "MTSQLRowSetSimulator.cls", "Value Get"
    
    ' Log the error
    strError = MTMSIX_ERROR_01033 & objError.ToString()
    TRACE strError, "MTSQLRowSetSimulator.cls", "Value", LOG_ERROR
    
    ' Raise the error
    RaiseError strError, , , LOG_APPLICATION_ERROR
End Function
' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Property Let Value(varKey As Variant, ByVal vNewValue As Variant)

    On Error GoTo ErrMgr
    
    Dim objError As New CError
    Dim strError As String

    Dim Index As Long
    Index = GetColumnIndex(varKey)
    If (Index > (m_lngCount - 1) Or (Index < 0)) Then
      RaiseError PreProcess(MTMSIX_ERROR_01107, "INDEX", Index, "SIZE", m_lngCount - 1), TypeName(Me), 1107, LOG_APPLICATION_ERROR
    End If
    
    m_varValues(m_lngAbsolutePosition, Index) = vNewValue

    Exit Property
ErrMgr:

    ' Store the error info
    objError.Save Err.Number, Err.Description, Err.Source, , "MTSQLRowSetSimulator.cls", "Value Let"
    
    ' Log the error
    strError = MTMSIX_ERROR_01033 & objError.ToString()
    TRACE strError, "MTSQLRowSetSimulator.cls", "Value", LOG_ERROR
    
    ' Raise the error
    RaiseError strError, , , LOG_APPLICATION_ERROR
    
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Function GetColumnIndex(varKey As Variant) As Long

    On Error GoTo ErrMgr

    Dim i As Long
    
    If (IsNumeric(varKey)) Then
    
        GetColumnIndex = CLng(varKey)
        Exit Function
    Else
    
        For i = 0 To Count - 1
        
            If (UCase$(Name(i)) = UCase$(varKey)) Then
            
                GetColumnIndex = i
                Exit Function
            End If
        Next
    End If
    
    RaiseError Replace(MTMSIX_ERROR_01049, "[NAME]", CStr(varKey)), , , LOG_APPLICATION_ERROR

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "GetColumnIndex", LOG_ERROR
End Function

Public Function LoadFolder(ByVal strPath As String, ByVal strWildCard As String) As Boolean

    On Error GoTo ErrMgr


    Dim objDir          As New cTextFile
    Dim objFiles        As New CVariables
    Dim objFile         As New CVariable
    
'    'Debug.Assert 0
    If (objDir.GetFilesList(strPath, strWildCard, objFiles)) Then
        
        Me.Initialize objFiles.Count, 2 ' X files , one column
        
        Me.Name(0) = "FileName" ' set the name of the first columns
        Me.Name(1) = "FullFileName" ' set the name of the first columns
        
        Me.MoveFirst
        
        For Each objFile In objFiles
        
            Me.Value(0) = objFile.Name
            Me.Value(1) = objFile.Value
            Me.MoveNext
        Next
    End If
    LoadFolder = True
    
    Dim objTool As New MSIXTools
    'Debug.Print objTool.MTSQLRowSetToString(Me)
    

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "LoadFolder", LOG_ERROR
End Function



Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If
    Exit Sub
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "Class_Initialize", LOG_ERROR
End Sub

Private Sub Class_Terminate()
    On Error GoTo ErrMgr

    Clear
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If
    Exit Sub
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "Class_Terminate", LOG_ERROR
End Sub

Public Function InitializeWithMSIXProperties(ByVal objMSIXProperties As MSIXProperties, ByVal lngRecordCount As Long) As Boolean

    On Error GoTo ErrMgr


    Dim objProperty As MSIXProperty
    Dim i           As Long
    
    Me.Initialize lngRecordCount, objMSIXProperties.Count
    
    For Each objProperty In objMSIXProperties
    
        Me.Name(i) = objProperty.Name
        i = i + 1
    Next
    InitializeWithMSIXProperties = True

    Exit Function
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "InitializeWithMSIXProperties", "MTSQLRowSetSimulator.cls", LOG_ERROR
End Function

Public Property Get AbsolutePosition() As Long

    On Error GoTo ErrMgr

    AbsolutePosition = m_lngAbsolutePosition

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "AbsolutePosition", "MTSQLRowSetSimulator.cls", LOG_ERROR
End Property

Public Property Let AbsolutePosition(ByVal vNewValue As Long)

    On Error GoTo ErrMgr

    m_lngAbsolutePosition = vNewValue

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "AbsolutePosition", "MTSQLRowSetSimulator.cls", LOG_ERROR
End Property

Public Function CloneFrom(ByVal SR As Variant, Optional ByVal strColumnName As String, Optional ByVal varValue As Variant) As Boolean

    Dim i               As Long
    Dim lngRecordCount  As Long
    Dim booOK           As Boolean
'    'Debug.Assert 0
    ' Compute the number of column
    
    
    lngRecordCount = 0
    
    If SR.RecordCount Then
    
        SR.MoveFirst
        Do While Not SR.EOF
            
            If Len(strColumnName) Then
                If SR.Value("" & strColumnName) = varValue Then lngRecordCount = lngRecordCount + 1
            Else
                lngRecordCount = lngRecordCount + 1
            End If
            SR.MoveNext
        Loop
    End If
    
    Me.Initialize lngRecordCount, SR.Count
    
    For i = 0 To SR.Count - 1
        Me.Name(i) = SR.Name(CLng(i))
    Next

    Me.MoveFirst
    
    If SR.RecordCount Then
    
        SR.MoveFirst
        Do While Not SR.EOF
        
            booOK = False
        
            If Len(strColumnName) Then
                If SR.Value("" & strColumnName) = varValue Then booOK = True
            Else
                booOK = True
            End If
            
            If booOK Then
            
                For i = 0 To SR.Count - 1
                    Me.Value(i) = SR.Value(CLng(i))
                Next
                Me.MoveNext
            End If
            SR.MoveNext
        Loop
    End If
    Me.MoveFirst
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "AbsolutePosition", "MTSQLRowSetSimulator.cls", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clone
' PARAMETERS    :
' DESCRIPTION   : Returns a copy of the MTSQLRowsetSimulator, if strFilterColumnName and strFilterColumnValue are defined it is possible to apply
'                 a one column filter. Return the instance of the MTSQLRowsetSimulator or Nothing
' RETURN        :
Public Function Clone(Optional ByVal strFilterColumnName As String, Optional ByVal strFilterColumnValue As String) As MTSQLRowsetSimulator

    Dim lngAbsPos           As Long
    Dim i                   As Long
    Dim objRowSetCloned     As New MTSQLRowsetSimulator
    Dim booOK               As Boolean
    Dim lngRows             As Long
    
    On Error GoTo ErrMgr
    
    Set Clone = Nothing
    lngAbsPos = Me.AbsolutePosition ' Save the current position
    
    
    ' Count the rows that will be copied
    Me.MoveFirst
    lngRows = 0
    Do While Not Me.EOF()
        
        If (Len(strFilterColumnName) = 0) Then
            booOK = True
        Else
            booOK = CBool(CStr(Me.Value(strFilterColumnName)) = strFilterColumnValue)
        End If
        If (booOK) Then lngRows = lngRows + 1
        Me.MoveNext
    Loop
    
    ' Allow the new MTSQLRowset with the right number of rows
    objRowSetCloned.Initialize lngRows, Me.Count
    
    
    Me.MoveFirst                    ' Copy the column name info
    objRowSetCloned.MoveFirst
    For i = 0 To Count - 1
        objRowSetCloned.Name(i) = Me.Name(i)
    Next
    
    Do While Not Me.EOF()           ' Copy the row by row, col by col
        
        If (Len(strFilterColumnName) = 0) Then
            booOK = True
        Else
            booOK = CBool(CStr(Me.Value(strFilterColumnName)) = strFilterColumnValue)
        End If
        
        If (booOK) Then
            For i = 0 To Count - 1
                objRowSetCloned.Value(i) = Me.Value(i)
            Next
            objRowSetCloned.MoveNext
        End If
        Me.MoveNext
    Loop
    
    Me.AbsolutePosition = lngAbsPos ' restore the current position
    Set Clone = objRowSetCloned
                            
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "Clone", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Find
' DESCRIPTION   : Select the first row that match the names/values contained in NameValues.
'                 Syntax:
'                   <code>UIf(objMyRowset.Find("AccountID",123,"ContactType",1))Then</code>
'                 This function apply a AND only operator between the variables.
' PARAMETERS    :
'                   objMTSQLRowset - MTSQLRowset or any compatible interface COM object.
'                   NamesValues    - A Visual Basic ParamArray listing names,values.
' RETURNS       : Returns true if on row match else false
Public Function Find(ParamArray NamesValues() As Variant) As Boolean

    On Error GoTo ErrMgr
    
    Dim i           As Long
    Dim booExp      As Boolean
    
    If (Me.RecordCount) Then Me.MoveFirst
    
    Do While Not Me.EOF()
    
        booExp = False
        For i = 0 To UBound(NamesValues) Step 2

            If (CStr(Me.Value(CStr(NamesValues(i)))) = CStr(NamesValues(i + 1))) Then
            
                booExp = True
            Else
                booExp = False
                Exit For ' Perform a AND only
            End If
        Next

        If (booExp) Then
    
            Find = True
            Exit Function
        End If
        Me.MoveNext
    Loop
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "Find", LOG_ERROR
End Function

Public Function ToString(Optional booNameValue As Boolean = False, Optional booColumnIndex As Boolean = False) As String

    Dim objCat  As New cStringConcat
    Dim i       As Long
    Dim lngRow  As Long
    Dim lngMaxColSize() As Long
    
    ReDim lngMaxColSize(Me.Count)
    
       
    
    On Error GoTo ErrMgr
    
    
    If booNameValue Then
        ToString = Me.ToStringNameValue()
        Exit Function
    End If
        
    objCat.Init 16384
    
    ' Compute the max length of each column so we can render a nice output
    For i = 0 To Count - 1
    
        lngMaxColSize(i) = Len(Me.Name(i))
    Next
    Do While Not EOF()
        For i = 0 To Count - 1
            If Len(Me.Value(i)) > lngMaxColSize(i) Then lngMaxColSize(i) = Len(Me.Value(i))
        Next
        Me.MoveNext
    Loop
    For i = 0 To Count - 1 ' Separator size
        lngMaxColSize(i) = lngMaxColSize(i) + 1
    Next
    
    ' Generate the header
    For i = 0 To Count - 1
        objCat.Concat RightPad(Name(i), lngMaxColSize(i))
    Next
    objCat.Concat vbNewLine
    
    If (RecordCount) Then MoveFirst
    
    Do While Not EOF()
        
        For i = 0 To Count - 1
        
            objCat.Concat RightPad(Value(i), lngMaxColSize(i))
        Next
        MoveNext
        objCat.Concat vbNewLine
    Loop
    If (RecordCount) Then MoveFirst
    
    ToString = objCat.GetString()

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "String", LOG_ERROR
End Function

Private Function RightPad(ByVal s As Variant, ByVal lngMaxLen As Long) As String

    Dim lngSLen As Long
    
    If IsNull(s) Then s = "Null"
    
    lngSLen = Len(s)
    
    If lngSLen < lngMaxLen Then
        RightPad = s & Space(lngMaxLen - lngSLen)
    Else
        RightPad = Mid(s, 1, lngMaxLen)
    End If
End Function

Public Function InitWithMTProperties(ByVal objMTProperties As Variant, Optional ByVal varExtended As Variant) As Boolean

    Dim objMTProperty  As Object
    Dim lngRecordCount As Long
    
    On Error GoTo ErrMgr
    
    If (IsMissing(varExtended)) Then varExtended = Empty
        
    For Each objMTProperty In objMTProperties
    
        If (IsEmpty(varExtended)) Or ((Not IsEmpty(varExtended)) And (objMTProperty.Extended = varExtended)) Then
        
            lngRecordCount = lngRecordCount + 1
        End If
    Next
    Initialize lngRecordCount, 2
    Me.Name(0) = "Name"
    Me.Name(1) = "Value"
    Me.MoveFirst
    
    For Each objMTProperty In objMTProperties
    
        If (IsEmpty(varExtended)) Or ((Not IsEmpty(varExtended)) And (objMTProperty.Extended = varExtended)) Then
            
            Me.Value(0) = objMTProperty.Name
            Me.Value(1) = objMTProperty.Value
            Me.MoveNext
        End If
    Next
    InitWithMTProperties = True
    
Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "ConvertMTPropertiesIntoMTSQLRowset", LOG_ERROR
    
End Function


Public Function InitMTCollection(ByVal objMTCollection As Variant) As Boolean

    On Error GoTo ErrMgr


    Dim objInstance As Variant
    Dim objProperty As Variant
    
    Dim i           As Long
    
    InitMTCollection = False
    
    If (objMTCollection.Count = 0) Then
        Exit Function
    End If
    
    Me.Initialize objMTCollection.Count, objMTCollection.Item(1).Properties.Count
    Me.MoveFirst
    
    ' Populate the header
    i = 0
    For Each objProperty In objMTCollection.Item(1).Properties
        If Not IsObject(objProperty.Value) Then
          Me.Name(i) = objProperty.Name
          i = i + 1
        End If
    Next
    
    ' Populating the data
    For Each objInstance In objMTCollection
    
        i = 0
        For Each objProperty In objInstance.Properties
          If Not IsObject(objProperty.Value) Then
            Me.Value(i) = objProperty.Value
            i = i + 1
          End If
        Next
        Me.MoveNext
    Next
    InitMTCollection = True
    Exit Function
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "InitMTCollection", "MTSQLRowSetSimulator.cls", LOG_ERROR
End Function

' Just for compatibility with the MTSQLRowset Interface
Public Function Resetfilter() As Boolean
    Resetfilter = True
End Function



Public Function ToStringNameValue() As String

    Dim objCat  As New cStringConcat
    Dim i       As Long
    Dim lngRow  As Long
    Dim lngMaxColSize() As Long
    
    ReDim lngMaxColSize(Me.Count)
    
    On Error GoTo ErrMgr
        
    objCat.Init 16384
    
    ' Compute the max length of each column so we can render a nice output
    'For i = 0 To Count - 1
   '
   '     lngMaxColSize(i) = Len(Me.Name(i))
    'Next
    'Do While Not EOF()
     '   For i = 0 To Count - 1
    '        If Len(Me.Value(i)) > lngMaxColSize(i) Then lngMaxColSize(i) = Len(Me.Value(i))
     '   Next
     '   Me.MoveNext
    'Loop
    'For i = 0 To Count - 1 ' Separator size
    '    lngMaxColSize(i) = lngMaxColSize(i) + 1
    'Next
    
    ' Generate the header
    'For i = 0 To Count - 1
    '    objCat.Concat RightPad(Name(i), lngMaxColSize(i))
    'Next
    'objCat.Concat vbNewLine
    
    If (RecordCount) Then MoveFirst
    
    Do While Not EOF()
        
        objCat.Concat "Row " & Me.AbsolutePosition & vbNewLine
        For i = 0 To Count - 1

            objCat.Concat "  " & RightPad(Name(i), 32) & "'" & Value(i) & "'" & vbNewLine
        Next
        MoveNext
        objCat.Concat vbNewLine
    Loop
    If (RecordCount) Then MoveFirst
    
    ToStringNameValue = objCat.GetString()

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MTSQLRowSetSimulator.cls", "String", LOG_ERROR
End Function
