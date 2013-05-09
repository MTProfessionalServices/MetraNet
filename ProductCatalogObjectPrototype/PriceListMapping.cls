VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTPriceListMapping"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Member0" ,"ParameterTable"
Attribute VB_Ext_KEY = "Member1" ,"PriceableItem"
Attribute VB_Ext_KEY = "Member2" ,"PriceList"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object:      MTPriceListMapping
'// Description: Mapping between a PriceableItem, a ParameterTable and
'//              a PriceList. Used by product offerings and subscriptions.
'// ----------------------------------------------------------------

Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Property:    PriceableItemID
Public PriceableItemID As Long

'// ----------------------------------------------------------------
'// Property:    ParamTableDefinitionID
Public ParamTableDefinitionID As Long

'// ----------------------------------------------------------------
'// Property:    PriceListID
'// Description: price list for this priceable item parameter table
Public PriceListID As Long

'// ----------------------------------------------------------------
'// Property:    CanICB
'// Description: if true, an ICB PricelistMapping can be created for
'//              this productOffering PricelistMapping
Public CanICB As Boolean

'// Reference to Product Catalog
Public ProdCat_ As MTProductCatalog

'=== internal properties ====================================================
' owner (only one of them is set)
Public PriceableItem_ As MTPriceableItem
Public Subscription_ As MTSubscription

'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Method:      GetRateSchedules
'// Description: return all rate schedules for this PI, ParamTableDef
'// Returns:     Collection of RateSchedules
Public Function GetRateSchedules() As Collection
    Set GetRateSchedules = RateSchedules_
End Function

'// ----------------------------------------------------------------
'// Method:      GetRateSchedulesAsRowset
'// Description: return all rate schedules as rowset for this PI, ParamTableDef
'// Returns:     Collection of RateSchedules
Public Function GetRateSchedulesAsRowset() As IMTSQLRowset

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
    For Each rs In GetRateSchedules()
        rowset.AddRow
        rowset.AddColumnData "id_prop", rs.ID
        rowset.AddColumnData "n_name", rs.Name
        rowset.AddColumnData "nm_startdate", CStr(rs.EffectiveDate.StartDate)
        rowset.AddColumnData "nm_enddate", CStr(rs.EffectiveDate.EndDate)
    Next
    
    Set GetRateSchedulesAsRowset = rowset
End Function


'// ----------------------------------------------------------------
'// Method:      GetEffectiveRateSchedule
'// Description: get the effective rate schedule for this PI, ParamTableDef
'// Arguments:   time – timeStamp
'// Returns:     a RateSchedule or NULL if none matches
Public Function GetEffectiveRateSchedule(ByVal d As Date) As MTRateSchedule
    Dim rs As MTRateSchedule
    
    For Each rs In GetRateSchedules()
        If rs.IsEffective(d) Then
            Set GetEffectiveRateSchedule = rs
            Exit For
        End If
    Next
    
End Function

'// ----------------------------------------------------------------
'// Method: CreateRateSchedule
'// Description: Create a new RateSchedule
'// Arguments:
'// Returns:     a RateSchedule or NULL if none matches
Public Function CreateRateSchedule() As MTRateSchedule
    Set CreateRateSchedule = CreateRateSchedule_(PriceListID, ParamTableDefinitionID)
End Function

'=== internal methods =======================================================

