VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTPriceableItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Member0" ,"ParameterTable"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'// ----------------------------------------------------------------
'// Object: MTPriceableItem
'// Description: Base class for MTUsageCharge, MTRecurringCharge,
'//              MTNonRecurringCharge, MTDiscount.
'//              Can be a "template" (set up in MPM)
'//              or an "instance" (added to a product offering)
'// ----------------------------------------------------------------
Option Explicit

'=== public properties ======================================================

'// ----------------------------------------------------------------
'// Enum:        MTPriceableItemType
'// Description: the kind of priceable item
'//              The values have to be unique for all kinds of
'//              product catalog entities.
'//              The reserved value range for MTPriceableItemType is 1-99
Public Enum MTPriceableItemType
    PI_TYPE_USAGE = 10
    PI_TYPE_RECURRING = 20
    PI_TYPE_NON_RECURRING = 30
    PI_TYPE_DISCOUNT = 40
End Enum

'// ----------------------------------------------------------------
'// Method:      <<accessor>> Properties
'// Description: Interface to get all (core and extended) properties of this PI
'//              by name or collection.
'// Returns:     MTProperties
Public Properties As New MTProperties

'=== internal properties ====================================================

' single parent of this PI
Private mParent As MTPriceableItem

' all children of this PI
Private mChildren As New Collection

' collection of parameter tables that make up this priceable item
Private mParamTableDefinitions As New Collection

' for instances: original priceable item (template) this instance was based on
' for templates: Nothing
Private mBasedOn As MTPriceableItem

' for instances: list of all mappings between priceable item parameter tables and pricelists.
Public mPriceListMappings_ As New Collection

' list of counters
Public mCounters_ As New Collection


Public ProdCat_ As MTProductCatalog
Public ProdOff_ As MTProductOffering


'=== public methods =========================================================

'// ----------------------------------------------------------------
'// Property:    ID
'// Description: ID unique among all priceable items (templates, instances,
'//              kinds)
Public Property Get ID() As Long
    ID = Properties.Item("ID").Value
End Property
Public Property Let ID(ByVal val As Long)
    Properties.Item("ID").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    Kind
'// Description: UsageCharge, RecurringCharge, NonRecurringCharge, or Discount
Public Property Get Kind() As MTPriceableItemType
    Kind = Properties.Item("Kind").Value
End Property
Public Property Let Kind(ByVal val As MTPriceableItemType)
    Properties.Item("Kind").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    Name
'// Description: name as shown to the user
Public Property Get Name() As String
    Name = Properties.Item("Name").Value
End Property
Public Property Let Name(ByVal val As String)
    Properties.Item("Name").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    DisplayName
'// Description: name as shown to the user in other applications
Public Property Get DisplayName() As String
    DisplayName = Properties.Item("DisplayName").Value
End Property
Public Property Let DisplayName(ByVal val As String)
    Properties.Item("DisplayName").Value = val
End Property


'// ----------------------------------------------------------------
'// Property:    Description
Public Property Get Description() As String
    Description = Properties.Item("Description").Value
End Property
Public Property Let Description(ByVal val As String)
    Properties.Item("Description").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    ServiceDefinition
'// Description: fully qualified name of the service definition that corresponds
'//              to this priceable item
Public Property Get ServiceDefinition() As String
    ServiceDefinition = Properties.Item("ServiceDefinition").Value
End Property
Public Property Let ServiceDefinition(ByVal val As String)
    Properties.Item("ServiceDefinition").Value = val
End Property

'// ----------------------------------------------------------------
'// Property:    Parent
'// Description: for child PIs in a compound PI: the parent PI
'//              for other Pis: NULL

Public Function GetParent() As Object
    Set GetParent = mParent
End Function
Public Sub SetParent_(val As Object)
    Set mParent = val
End Sub

'// ----------------------------------------------------------------
'// Property:    BasedOn
'// Description: for PI instances: the PI template that this instance is based
'//              on
'//              for PI templates: NULL
Public Function GetBasedOn() As Object
    Set GetBasedOn = mBasedOn
End Function
Public Sub SetBasedOn(val As Object)
    Set mBasedOn = val
End Sub

'// ----------------------------------------------------------------
'// Method:      Save
'// Description: Saves modification to this PI to database.
Public Sub Save()
End Sub

'// ----------------------------------------------------------------
'// Method:      CreateUsageChargeChild
'// Description: Create a child of type usage charge.
'//              MTUsageCharge::Save() will insert it into the database.
'// Returns:     UsageCharge
Public Function CreateUsageChargeChild() As MTUsageCharge
    Dim pi As New MTUsageCharge
    pi.ProdCat_ = ProdCat_
    pi.Kind = PI_TYPE_USAGE
    pi.ID = NextID()
    pi.SetParent_ Me
    mChildren.Add pi
    Set CreateUsageChargeChild = pi
End Function

'// ----------------------------------------------------------------
'// Method:      GetChildren
'// Description: returns the immediate children of this PI (if any)
'// Returns:     Collection of PriceableItems
Public Function GetChildren() As Collection
    Set GetChildren = mChildren
End Function

'// ----------------------------------------------------------------
'// Method:      GetChild
'// Description: returns an immediate child of this PriceableItem by its ID
'// Arguments:   ID – ID of the PriceableItem
'// Returns:     the PriceableItem or NULL if not found
Public Function GetChild(ByVal ID As Long) As Object
    Dim pi As Object
    For Each pi In mChildren
        If pi.ID = ID Then
            Set GetChild = pi
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      GetChildByName
'// Description: returns an immediate child of this PriceableItem by its ID
'// Arguments:   Name – Name of the PriceableItem
'// Returns:     the PriceableItem or NULL if not found
Public Function GetChildByName(ByVal Name As String) As Object
    Dim pi As Object
    For Each pi In mChildren
        If pi.Name = Name Then
            Set GetChildByName = pi
            Exit For
        End If
    Next
End Function


'// ----------------------------------------------------------------
'// Method:      AddParamTableDefinition
'// Description: adds a paramtable definitions to this PI
'// Arguments:   paramTblID – ID of ParamTableDefinition
Public Function AddParamTableDefinition(ByVal ptdID As Long)
    Dim ptd As MTParamTableDefinition
    Set ptd = ProdCat_.GetParamTableDefinition(ptdID)
    mParamTableDefinitions.Add ptd
End Function

'// ----------------------------------------------------------------
'// Method:      RemoveParamTableDefinition
'// Description: removes a paramtable definitions from this PI
'// Arguments:   paramTblID – ID of ParamTableDefinition
Public Function RemoveParamTableDefinition(ByVal ptdID As Long)
End Function

'// ----------------------------------------------------------------
'// Method:      GetParamTableDefinitions
'// Description: returns the parameter tables that make up this priceable item
'// Returns:     Collection of ParamTableDefinitions
Public Function GetParamTableDefinitions() As Collection
    Set GetParamTableDefinitions = mParamTableDefinitions
End Function

'// ----------------------------------------------------------------
'// Method:      GetParamTableDefinition
'// Description: returns the included parameter table with this pt_id
'// Returns:     Collection of ParamTableDefinitions
Public Function GetParamTableDefinition(ByVal pt_id As Long) As MTParamTableDefinition
    Dim ptd As MTParamTableDefinition
    For Each ptd In mParamTableDefinitions
        If ptd.ID = pt_id Then
            Set GetParamTableDefinition = ptd
        End If
    Next
    ' If you got here, then the parameter table does not belong to this priceable item
End Function


'// ----------------------------------------------------------------
'// Method:      GetParameterTablesAsRowset
'// Description: return a rowset of priceable items
'// Returns:     an IMTSQLRowset
Public Function GetParameterTablesAsRowset() As IMTSQLRowset
    
    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' add meta data for all fields
    rowset.AddColumnDefinition "id_prop", "int32", 255
    rowset.AddColumnDefinition "n_name", "string", 255

    ' fill rowset
    rowset.OpenDisconnected

    Dim ptd As MTParamTableDefinition
    For Each ptd In GetParamTableDefinitions()
        rowset.AddRow
        rowset.AddColumnData "id_prop", ptd.ID
        rowset.AddColumnData "n_name", ptd.Name
    Next
    Set GetParameterTablesAsRowset = rowset
End Function

'// ----------------------------------------------------------------
'// Method:      GetPriceListMappingsAsRowset
'// Description: return a rowset of parameter tables and pricelist mappings
'// Returns:     an IMTSQLRowset
Public Function GetPriceListMappingsAsRowset() As IMTSQLRowset
    
    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' add meta data for all fields
    rowset.AddColumnDefinition "id_prop", "int32", 255
    rowset.AddColumnDefinition "n_name", "string", 255
    rowset.AddColumnDefinition "id_pricelist", "int32", 255
    rowset.AddColumnDefinition "n_pricelistname", "string", 255
    rowset.AddColumnDefinition "n_icbable", "int32", 255

    ' fill rowset
    rowset.OpenDisconnected

    Dim ptd As MTParamTableDefinition
    For Each ptd In GetParamTableDefinitions()
        rowset.AddRow
        rowset.AddColumnData "id_prop", ptd.ID
        rowset.AddColumnData "n_name", ptd.Name
        
        Dim strPriceListName
        Dim intPriceListID
        Dim bICBable
        
        strPriceListName = ""
        intPriceListID = 0
        bICBable = False
    
        Dim plm As MTPriceListMapping
        Set plm = GetPriceListMapping(ptd.ID)
        
        If plm.PriceListID <> 0 Then
            intPriceListID = plm.PriceListID
            bICBable = plm.CanICB
            
            Dim pl As MTPriceList
            Set pl = ProdCat_.GetPriceList(intPriceListID)
            strPriceListName = pl.Name
        End If
        
        rowset.AddColumnData "id_pricelist", intPriceListID
        rowset.AddColumnData "n_pricelistname", strPriceListName
        rowset.AddColumnData "n_icbable", 0
        
    Next
    Set GetPriceListMappingsAsRowset = rowset
End Function

'// ----------------------------------------------------------------
'// Method:      GetChildrenAsRowset
'// Description: return a rowset of child priceable items of the current one
'// Returns:     an IMTSQLRowset

Public Function GetChildrenAsRowset() As IMTSQLRowset
    
    Dim rowset As IMTSQLRowset
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.InitDisconnected

    ' add meta data for all fields
    Dim meta As MTPropertyMetaData
    For Each meta In ProdCat_.GetUsageChargeMetaData
        rowset.AddColumnDefinition meta.DBColumnName, meta.DataType, meta.Length
    Next

    ' fill rowset
    rowset.OpenDisconnected

    Dim pi As Object
    For Each pi In GetChildren()
        rowset.AddRow
        For Each meta In ProdCat_.GetUsageChargeMetaData
            On Error Resume Next
            rowset.AddColumnData meta.DBColumnName, pi.Properties.Item(meta.Name).Value
            On Error GoTo 0
        Next
    Next
    Set GetChildrenAsRowset = rowset
End Function

'// ----------------------------------------------------------------
'// Method:      GetPriceListMapping
'// Description: Get the pricelist mapping for a ParamTableDefinitions.
'//              There are as many PriceListMappings as there are
'//              ParamTableDefinitions
'// Arguments:   paramTblID – ID of ParamTableDefinition
Public Function GetPriceListMapping(ByVal paramTblID As Long) As MTPriceListMapping
    Dim plm As MTPriceListMapping
    Dim i As Integer
    For i = 1 To mPriceListMappings_.Count()
        Set plm = mPriceListMappings_.Item(i)
        If plm.ParamTableDefinitionID = paramTblID Then
            Set GetPriceListMapping = plm
            Exit For
        End If
    Next
End Function

'// ----------------------------------------------------------------
'// Method:      SetPriceListMapping
'// Description: override the price list for a parameter table.
'//              BUSINESS RULE: this function must verify the currency of the
'//              pricelist added.
'// Arguments:   paramTblID – ID of ParamTableDefinition
'//              prcLstID – ID of PriceList
Public Sub SetPriceListMapping(ByVal ptdID As Long, ByVal plID As Long)
    GetPriceListMapping(ptdID).PriceListID = plID
End Sub

'//------ Counter realated --------


'// ----------------------------------------------------------------
'// Method:      GetCounters
'// Description: returns counters mapped to this this priceable item
'// Arguments:
Public Function GetCounters()
    Set GetCounters = mCounters_
End Function


'=== internal methods =======================================================
Public Function Clone_() As Object

    ' make a deep copy of this priceable item

    Dim clonedPI As Object
    
    ' switch on kind
    Select Case Kind
        Case PI_TYPE_USAGE
            Set clonedPI = New MTUsageCharge
        Case PI_TYPE_RECURRING
            Set clonedPI = New MTRecurringCharge
        Case PI_TYPE_NON_RECURRING
            Set clonedPI = New MTNonRecurringCharge
        Case PI_TYPE_DISCOUNT
            Set clonedPI = New MTDiscount
    End Select
    
    clonedPI.Kind = Kind
    clonedPI.ID = NextID()
    clonedPI.Name = Name
    clonedPI.Description = Description
    
    clonedPI.ProdCat_ = ProdCat_
    
    'copy all paramtables
    Dim ptd As MTParamTableDefinition
    For Each ptd In GetParamTableDefinitions
        clonedPI.AddParamTableDefinition ptd.ID
    
        ' add a PLMapping for that paramtable
        Dim plm As MTPriceListMapping
        Set plm = New MTPriceListMapping
        plm.PriceableItemID = clonedPI.ID
        plm.ParamTableDefinitionID = ptd.ID
        ' plm.PriceListID = ' NULL?!
        plm.PriceableItemID = ID
        clonedPI.mPriceListMappings_.Add plm
    Next
            
    ' TODO copy all properties + attributes
            
        
    'clone each child
    Dim child As Object
    Dim clonedChild As Object
    For Each child In GetChildren()
        Set clonedChild = child.Clone_
        clonedPI.GetChildren().Add clonedChild
    Next
    Set Clone_ = clonedPI

End Function

