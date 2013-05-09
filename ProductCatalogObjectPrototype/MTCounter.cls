VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTCounter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'// ----------------------------------------------------------------
'// Object: MTCounter
'// Description: Subscribable grouping of Priceable items.
'// ----------------------------------------------------------------

Option Explicit



'=== public properties ======================================================

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Property:    ID
'// Description: unique ID of this product offering
Public ID As Long

'// ----------------------------------------------------------------
'// Property:    Name
'// Description: name as shown to the user
Public Name As String

'// ----------------------------------------------------------------
'// Property:    Description
Public Description As String
    
    
'// ----------------------------------------------------------------
'// Property:    Formula
Public Formula As String

Private mParameters As New Collection



'// ----------------------------------------------------------------
'// Method:      GetParameters
'// Description: Get all parameters
'//              associated with this instance
'// Returns:     Collection of MTCounterParameter

Public Function GetParameters() As Collection
    Set GetParameters = mParameters
End Function


'// ----------------------------------------------------------------
'// Method:      SetParameter
'// Description: Replace a formal parameter with actual value
'// Returns:

Public Function SetParameter(ByVal aParamName As String, ByVal aParamValue, ByVal aDontValidateString As Boolean)
    Dim p As MTCounterParameter
    For Each p In mParameters
        If p.Name = aParamName Then
            p.Value = aParamValue
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      Execute
'// Description: constructs a counter query and executes it
'//               only tiered strategy is supported
'// Returns:    IMTSQLRowset with two columns: AccountID, Counter Value; ONly used by Discount object

Public Function Execute(aStrategy As Long, aStartDate As Date, aEndDate As Date, aAccountList As Collection) As IMTSQLRowset

End Function

'// ----------------------------------------------------------------
'// Method:      Save
'// Description: Saves this instance into database. All formal parameters
'//              have to be replaced with actual ones at this point, Name and Decription
'//              properties have to be set
'// Returns:    DB ID (primary key on t_counter table)
Public Function Save() As Long

End Function

'// ----------------------------------------------------------------
'// Method:      GetType
'// Description: Get MTCounterType object this instance was created from
'// Returns:      MTCounterType object

Public Function GetType() As MTCounterType

End Function

'// ----------------------------------------------------------------
'// Method:      Load
'// Description: Initializes internal state based on passed in DB id
'//              NOOP if already has a state (ID is set)
'// Returns:

Public Function Load(ByVal aDBID As Long)

End Function


