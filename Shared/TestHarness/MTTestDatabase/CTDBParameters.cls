VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CTDBParameters"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit




Private mCol As Collection

Public Parent As CTDBItem


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method and
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(vntKey As Variant) As CTDBParameter
Attribute Item.VB_UserMemId = 0

    On Error GoTo ErrMgr
    
    If IsNumeric(vntKey) Then
    
        Set Item = mCol(vntKey)
    Else
        Set Item = mCol(UCase$(vntKey))
    End If
   Exit Property
ErrMgr:
   Set Item = Nothing
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Remove the item from the collection. The method is not case sensitive.
' RETURN        : Returns TRUE if OK
Public Function Remove(vntKey As Variant, Optional ByVal booUseLongId As Boolean, Optional ByVal booRemoveRequiredAlso As Boolean = False) As Boolean

    On Error GoTo ErrMgr
    
    If Me.Item(vntKey).Required And Not booRemoveRequiredAlso Then
    
    Else
        mCol.Remove vntKey
    End If
    Remove = True
    Exit Function
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Count
' PARAMETERS    :
' DESCRIPTION   : Returns the number of items in the collection.
' RETURN        :
Public Property Get Count() As Long

    On Error GoTo ErrMgr
    Count = mCol.Count
    Exit Property
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : NewEnum
' PARAMETERS    :
' DESCRIPTION   : Implement the COM Enumerator. This function is used internally by visual basic in for each loop!
' RETURN        : IUnknown
Public Property Get NewEnum() As IUnknown ' Documented=no
Attribute NewEnum.VB_UserMemId = -4

    On Error GoTo ErrMgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property


Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    Set mCol = New Collection
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub


Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Clear
    Set mCol = Nothing
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   : Remove all the items in the collection. If the item is no more referenced it is deleted and its destructor
'                 Class_Terminate event is raised.
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr

'    Do While Count > 0
'        Remove 1
'    Loop

    Set mCol = New Collection
    Clear = True
    Exit Function
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr


    Dim clsNode As CTDBParameter
    Dim strS    As String
    
    For Each clsNode In Me
    
        strS = strS & clsNode.ToString() & vbCrLf
    Next
    ToString = strS

    Exit Function
ErrMgr:
  TRACE TESTHARNESS_ERROR_7000 & GetVBErrorString(), "CTDBParameters.cls", "ToString", LOG_ERROR
End Function


' -------------------------------------------------------------------------------
' FUNCTION      : Exist
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Returns TRUE if the item exist in the collection. The method is not case sensitive.
' RETURN        :
Public Function Exist(ByVal vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    
    Dim objItem As Object
    
    If IsNumeric(vntKey) Then
        Set objItem = mCol(vntKey)
    Else
        Set objItem = mCol(UCase$(vntKey))
    End If
    
    Exist = True
    Exit Function
ErrMgr:
    Exist = False
    Err.Clear
End Function


Public Function AddDescriptionParameter(DP As MetraTech_QA_TestHarness_CommentParser.IParameter) As CTDBParameter

    Set AddDescriptionParameter = Me.Add(DP.Name, DP.defaultValue, CBool(DP.Required), DP.Enums.ToCSV()) ' todo : tocsv
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
' DESCRIPTION   : This Add is used by the XMLLoader to add a test info to a test session. This add
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function Add(strName As String, strValue As String, booRequired As Boolean, strEnumValue As String) As CTDBParameter

    On Error GoTo ErrMgr
        
    Dim p As CTDBParameter
    
    Set p = New CTDBParameter
    
    p.Name = strName
    p.Value = strValue
    p.Required = booRequired
    p.EnumValue = strEnumValue
    
    Set Add = AddInstance(p)
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function


Public Function AddInstance(p As CTDBParameter) As CTDBParameter

    On Error GoTo ErrMgr
    
    If Me.Exist(p.Name) Then Me.Remove p.Name
        
    mCol.Add p, UCase$(p.Name)
    
    Set p.Parent = Me
    
    Set AddInstance = p
    Exit Function
ErrMgr:
    
End Function



Public Function UpdateParametersList(NewParametersList As CTDBParameters) As Boolean

    On Error GoTo ErrMgr
    
    Dim p As CTDBParameter
    
    For Each p In NewParametersList
    
        If Not Me.Exist(p.Name) Then
        
            Me.AddInstance p.Clone()
        End If
    Next
    UpdateParametersList = True
    Exit Function
ErrMgr:
  TRACE TESTHARNESS_ERROR_7000 & GetVBErrorString(), "CTDBParameters.cls", "UpdateParametersList", LOG_ERROR
End Function


Public Function ValidateIntegrity(ByRef ParameterInValid As CTDBParameter) As Boolean

    On Error GoTo ErrMgr
    
    For Each ParameterInValid In Me
    
        If Not ParameterInValid.ValidateIntegrity() Then Exit Function
    Next
    ValidateIntegrity = True
    Exit Function
ErrMgr:
  TRACE TESTHARNESS_ERROR_7000 & GetVBErrorString(), "CTDBParameters.cls", "ValidateIntegrity", LOG_ERROR
End Function





Public Function Clone() As CTDBParameters

    On Error GoTo ErrMgr
    
    Dim objCloned   As New CTDBParameters
    Dim p           As CTDBParameter
    
    For Each p In Me
    
        objCloned.AddInstance p.Clone()
    Next
    Set Clone = objCloned
    Exit Function
ErrMgr:
  TRACE TESTHARNESS_ERROR_7000 & GetVBErrorString(), "CTDBParameters.cls", "Clone", LOG_ERROR
End Function



Public Function Populate(ParametersBackUp As CTDBParameters, booClear As Boolean) As Boolean

    On Error GoTo ErrMgr

    Dim p           As CTDBParameter
    
    If booClear Then Me.Clear
    
    For Each p In ParametersBackUp
    
        Me.AddInstance p.Clone()
    Next
    Populate = True
    Exit Function
ErrMgr:
  TRACE TESTHARNESS_ERROR_7000 & GetVBErrorString(), "CTDBParameters.cls", "Populate", LOG_ERROR
End Function




