VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTParamTableDefinition"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'// ----------------------------------------------------------------
'// Object:      MTParamTableDefinition
'// Description: describes a MTRuleSet
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Property:    ID
'// Description: unique ID
Public ID As Long

'// ----------------------------------------------------------------
'// Property:    Name
'// Description: name as shown to the user
Public Name As String

'// ----------------------------------------------------------------
'// Property:    ConditionHeader
'// Description: name to show as header for the condition columns
Public ConditionHeader As String

'// ----------------------------------------------------------------
'// Property:    ActionHeader
'// Description: name as shown as header for the action columns
Public ActionHeader As String

'// ----------------------------------------------------------------
'// Property:    HelpURL
'// Description: URL that points to help
Public HelpURL As String

'// ----------------------------------------------------------------
'// Property:    ConditionMetaData
'// Description: meta data describing the condition columns
Public ConditionMetaData As Collection

'// ----------------------------------------------------------------
'// Property:    ActionMetaData
'// Description: meta data describing the action columns
Public ActionMetaData As Collection

'=== internal properties ====================================================

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Method:      Save
'// Description: Saves modification to this object to database.
Public Sub Save()

End Sub

'// ----------------------------------------------------------------
'// Method:      GetRateSchedulesAsRowset
'// Description: return rateschedules of this param table for a given pricelist
Public Function GetRateSchedulesAsRowset(ByVal plID As Long)
    
    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' add meta data for all fields
    rowset.AddColumnDefinition "id_prop", "int32", 255
    rowset.AddColumnDefinition "n_name", "string", 255
    rowset.AddColumnDefinition "nm_startdate", "string", 255
    rowset.AddColumnDefinition "nm_enddate", "string", 255

    ' fill rowset
    rowset.OpenDisconnected

    Dim rs As MTRateSchedule
    Dim tmp As Long
    
    For Each rs In RateSchedules_
        tmp = rs.PriceListID
        If tmp = plID Then
            rowset.AddRow
            rowset.AddColumnData "id_prop", rs.ID
            rowset.AddColumnData "n_name", rs.Name
            rowset.AddColumnData "nm_startdate", CStr(rs.EffectiveDate.StartDate)
            rowset.AddColumnData "nm_enddate", CStr(rs.EffectiveDate.EndDate)
        End If
    Next
    
    Set GetRateSchedulesAsRowset = rowset
End Function

'// ----------------------------------------------------------------
'// Method:      GetRateSchedule
'// Description: get a RateSchedule
'// Arguments:
'// Returns:
Public Function GetRateSchedule(ByVal rsid As Long) As Object
    Dim rs As MTRateSchedule
    For Each rs In RateSchedules_
        If rs.ID = rsid Then
            Set GetRateSchedule = rs
            Exit For
        End If
    Next
End Function


'=== internal methods =======================================================

