VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 4  'RequiresNewTransaction
END
Attribute VB_Name = "AddPiType"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Member Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mobjLogger As New Logger
Private mobjRowset As New MTSQLRowset
Private mobjPC As New MTProductCatalog
Private mobjRCD As New MTRcd

Implements IMTHook

Private Sub Class_Initialize()
  'Intialize the rowset object
  Call mobjRowset.Init("queries\ProductCatalog")
  Call mobjLogger.Init(mobjRCD.ConfigDir, "[PriceableItemHook]")
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Hook Function                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub IMTHook_Execute(ByVal var As Variant, pVal As Long)
  On Error GoTo ErrorHandler
  
  Dim objFileList As MTRcdFileList
  
  Dim objPIType As Object                       'Return from objPI.getpriceableitemtypes
  Dim bFound As Boolean
  
  Dim strFile As Variant
  Dim objSWPI As PriceableItem
    
  Dim objSWPITemp As New PriceableItem      'Used to remove PI types
    
  Dim collPITypes As New Collection
  
  Dim collExistingPITypes As IMTCollection
  Dim objPCPIType As MTPriceableItemType
  
  Call mobjLogger.LogThis(LOG_INFO, "Starting hook execution.")

  ' Must use the executant directly because we want to include child
  ' PITypes as well
  Dim objPITypeReader As New MTPriceableItemTypeReader
  Set collExistingPITypes = objPITypeReader.FindByFilter(mobjPC.GetSessionContext())
  
  'Load the priceable item types and create/modify types and templates
  Set objFileList = mobjRCD.RunQuery("config\PriceableItems\*.xml", True)
  
  Call mobjLogger.LogThis(LOG_INFO, "Found " & objFileList.Count & " priceable item types.")
  
  Call mobjLogger.LogThis(LOG_INFO, "Loading priceable item types from XML.")
  
  For Each strFile In objFileList
    Set objSWPI = New PriceableItem
    
    Call objSWPI.LoadFromXML(strFile)
  
    'Add the XML file as a property of the SWPI
    Call objSWPI.PropertyAttributes.Add(strFile, "XMLFILE")
    
    'Do checksum match.  Note that bFound will be False precisely when an update
    'of the pitype in the database needs to be performed.
    'These updates will use the new C# based pitype sync infrastructure that no
    'longer does a delete/insert.
    Call mobjLogger.LogThis(LOG_INFO, "Comparing checksum for type: " & objSWPI.Name)
    bFound = CompareChecksum(objSWPI, collExistingPITypes)
    
    If bFound Then
      Call mobjLogger.LogThis(LOG_INFO, "Checksum match or the PI type didn't exist.  An update will NOT be performed." & objSWPI.Name)
    End If
    
    
    'Create types/templates for those PI Types that are added
    If objSWPI.PropertyAttributes("MODIFY") And bFound Then
      Call mobjLogger.LogThis(LOG_INFO, "Creating type...")
      Call SaveToDB(objSWPI)
      Call mobjLogger.LogThis(LOG_INFO, "Done.")
      
      Call mobjLogger.LogThis(LOG_INFO, "Creating template for the priceable item type (if necessary)...")
      Call CreateTemplate(objSWPI)
      Call mobjLogger.LogThis(LOG_INFO, "Done.")
      
      Call mobjLogger.LogThis(LOG_INFO, "Configuring counters for the priceable item type...")
      Call CreateCounters(objSWPI)
      Call mobjLogger.LogThis(LOG_INFO, "Done")
    End If
    
    If Not bFound Then
      Call mobjLogger.LogThis(LOG_INFO, "No checksum match.  An in-place update WILL be performed. " & objSWPI.Name)
      Dim objWriter As New MetraTech_Product_Hooks.PriceableItemTypeWriter
      Call objWriter.UpdatePriceableItemTypeFromFile(strFile)
    End If
        
    'Add the type to the collection
    Call collPITypes.Add(objSWPI)
  Next
  
  ' If there are any PITypes in the collection of existing ones, then
  ' there is no corresponding XML representation and they should be deleted.
  For Each objPCPIType In collExistingPITypes
    If Not mobjPC.GetPriceableItemTypeByName(objPCPIType.Name) Is Nothing Then
      Call mobjLogger.LogThis(LOG_INFO, "Removing deleted priceable item type: " & objPCPIType.Name)
      Call RemovePCPIType(objPCPIType)
    End If
  Next
  
  Call mobjLogger.LogThis(LOG_INFO, "Configuring priceable item relationships...")
  'Configure the PI Type relationships
  For Each objSWPI In collPITypes
    If objSWPI.PropertyAttributes("MODIFY") Then
      Call ConfigurePIRelationships(objSWPI)
    End If
  Next
  Call mobjLogger.LogThis(LOG_INFO, "Done.")
  
  Call mobjLogger.LogThis(LOG_INFO, "Updating checksums...")
  'Update checksums
  For Each objSWPI In collPITypes
    If objSWPI.PropertyAttributes("MODIFY") Or objSWPI.PropertyAttributes("UPDATECHECKSUM") Then
      Call SetChecksum(objSWPI)
    End If
  Next
  Call mobjLogger.LogThis(LOG_INFO, "Done updating checksums.")
  
  If Not GetObjectContext() Is Nothing Then
    GetObjectContext().SetComplete
  End If
  
  ' create adjustment tables
  CreateAdjustmentTables
  
  Call mobjLogger.LogThis(LOG_INFO, "The priceable item type hook has executed successfully.")

ErrorHandler:

  If Err Then
    If Not GetObjectContext() Is Nothing Then
      GetObjectContext().SetAbort
    End If
    
    Call mobjLogger.LogThis(LOG_INFO, "An error occurred in the Priceable Item Type synchronization hook [" & Err.Source & " -- " & Err.Description & "]")
    Err.Description = "An error occurred in the Priceable Item Type synchronization hook [" & Err.Source & " -- " & Err.Description & "]"
    Call Err.Raise(Err.Number) '(-1)
  End If
End Sub

'---------------------------------------------------------------------------'
' Function      : CreateAdjustmentTables                         '
' Description   : Create the adjustment tables from the metadata in the database

Private Function CreateAdjustmentTables()
 mobjLogger.LogThis LOG_INFO, "Creating Adjustment metadata..."
  ' TODO: create adjustment types from XML, populate object
  Dim ac As New AdjustmentCatalog
  ac.Initialize Nothing
  ac.SynchronizeTypes
End Function

'---------------------------------------------------------------------------'
' Function      : RemovePCPIType(objSWPI)                                     '
' Description   : Attempt to remove a priceable item type and its templates '
'               : from the product catalog.                                 '
' Inputs        : obSWPI -- Product catalog priceable item to remove .      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub RemovePCPIType(ByRef objPIType As MTPriceableItemType)
  Dim objPITemplate As Object
  On Error GoTo ErrorHandler
  
  If objPIType.GetProductOfferings.Count > 0 Then
      Call mobjLogger.LogThis(LOG_ERROR, "Unable to remove priceable item type!  It is part of one or more product offerings!")
      Err.Description = "Unable to remove priceable item type [" & objPIType.Name & "] because it is part of one or more product offerings."
      Err.Raise -1
  End If
    
    
    'Remove the templates
    For Each objPITemplate In objPIType.GetTemplates
      Call objPIType.RemoveTemplate(objPITemplate.ID)
    Next
    
    'Remove the type
    Call mobjPC.RemovePriceableItemType(objPIType.ID)

  
ErrorHandler:
  'if an error occurs, log an error then move on
  If Err Then
    Call mobjLogger.LogThis(LOG_WARNING, "Unable to remove priceable item type! " & Err.Description)
      Err.Description = "Error occurred while removing a priceable item type [" & objPIType.Name & "]   --  " & Err.Description
      Err.Raise (Err.Number)
  End If
End Sub
'---------------------------------------------------------------------------'
' Function      : RemovePIType(objSWPI)                                     '
' Description   : Attempt to remove a priceable item type and its templates '
'               : from the product catalog.                                 '
' Inputs        : obSWPI -- Service wizard priceable item type object.      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function RemovePIType(ByRef objSWPI As PriceableItem)
  
  Dim objPIType As MTPriceableItemType      'pi type
     
  Set objPIType = mobjPC.GetPriceableItemTypeByName(objSWPI.Name)
  
  'If part of a product offering, fail out with no modification
  If Not objPIType Is Nothing Then
    Call RemovePCPIType(objPIType)
  End If
  
End Function
'---------------------------------------------------------------------------'
' Function      : FindPIByName(objSWPI, collExistingPITypes)                '
' Description   : Compare the checksum for a priceable item type xml file.  '
'               : Return true if the checksums match, return false if they  '
'               : don't.  The new checksum is stored.                       '
' Inputs        : objSWPI    -- Service wizard priceable item helper object '
'               : collExistingPITypes -- collection of PItypes to search    '
' Outputs       : index in the collection containing the match.             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function FindPIByName(ByRef objSWPI As PriceableItem, ByRef collExistingPITypes As IMTCollection) As Long
  'Get the PI Type from the collection taken from the database
  Dim I As Long
  For I = 1 To collExistingPITypes.Count
    If collExistingPITypes.Item(I).Name = objSWPI.Name Then
        FindPIByName = I
        Exit Function
    End If
  Next
  FindPIByName = 0
End Function
'---------------------------------------------------------------------------'
' Function      : CompareChecksum(objSWPI, collExistingPITypes)             '
' Description   : Compare the checksum for a priceable item type xml file.  '
'               : Return true if the checksums match, return false if they  '
'               : don't.  The new checksum is stored.                       '
' Inputs        : objSWPI    -- Service wizard priceable item helper object '
'               : collExistingPITypes -- collection of existing PItypes     '
' Outputs       : boolean indicating checksum match.                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function CompareChecksum(ByRef objSWPI As PriceableItem, ByRef collExistingPITypes As IMTCollection) As Boolean
  
  Dim objMTConfig As New MTConfig     'config object
  Dim objPropSet As MTConfigPropSet   'propset object
  Dim strChecksum As String           'file checksum
  Dim bReturn As Boolean              'value to return
  
  Dim objPI As Object
  Dim I As Long
  I = FindPIByName(objSWPI, collExistingPITypes)
  If I > 0 Then
  Set objPI = collExistingPITypes.Item(I)
  ' Record the fact that the object in the database has a matching XML rep.
  collExistingPITypes.Remove (I)
  Else
  Set objPI = Nothing
  End If
  
  'If the pi type was in the database
  If Not objPI Is Nothing Then
    
    'Compute the checksum from the file
    Set objPropSet = objMTConfig.ReadConfiguration(objSWPI.PropertyAttributes("XMLFILE"), False)
  
    'Get the checksum
    strChecksum = objPropSet.Checksum
  
    Call mobjRowset.SetQueryTag("__GET_PARAMTABLE_CHECKSUM__")
    Call mobjRowset.AddParam("%%ID_PARAM%%", objPI.ID)
    Call mobjRowset.Execute
    
    If mobjRowset.EOF Then
      Err.Description = "Unable to get checksum for priceable item type: " & objSWPI.Name & "...Aborting!"
      Err.Raise -1
    End If
    
    ' Special case for when version is zero.  In this case, we only
    ' update the checksum in the database.  Return True in this case
    ' because it tells the caller not to delete the PIType
    If mobjRowset.Value("n_version") = 0 Then
      bReturn = True
      Call objSWPI.PropertyAttributes.Add(False, "MODIFY")
      Call objSWPI.PropertyAttributes.Add(True, "UPDATECHECKSUM")
    ElseIf mobjRowset.Value("tx_checksum") = strChecksum Then
      bReturn = True
      Call objSWPI.PropertyAttributes.Add(False, "MODIFY")
      Call objSWPI.PropertyAttributes.Add(False, "UPDATECHECKSUM")
    Else
      bReturn = False
      Call objSWPI.PropertyAttributes.Add(True, "MODIFY")
      Call objSWPI.PropertyAttributes.Add(False, "UPDATECHECKSUM")
    End If
  
  'In the case of new pi's say the checksum matched so that the hook will
  ' not try to remove templates, etc.
  Else
    bReturn = True
    Call objSWPI.PropertyAttributes.Add(True, "MODIFY")
      Call objSWPI.PropertyAttributes.Add(False, "UPDATECHECKSUM")
    'For new types, the checksum can only be added when the type is created
  End If
  
  CompareChecksum = bReturn
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : SetChecksum(byref objSWPI as priceableitem)               '
' Description   : After all priceable item modifications, set the database  '
'               : checksum to match.                                        '
' Inputs        : objSWPI -- Service wizard priceable item object.          '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function SetChecksum(ByRef objSWPI As PriceableItem) As Boolean
  
  Dim objMTConfig As New MTConfig     'config object
  Dim objPropSet As MTConfigPropSet   'propset object
  Dim strChecksum As String           'file checksum
  Dim bReturn As Boolean              'value to return
  
  Dim objPI As Object
  
  'Get the PI Type from the database
  Set objPI = mobjPC.GetPriceableItemTypeByName(objSWPI.Name)
  
  'If the pi type was in the database
  If Not objPI Is Nothing Then
    'Compute the checksum from the file
    Set objPropSet = objMTConfig.ReadConfiguration(objSWPI.PropertyAttributes("XMLFILE"), False)
    
    strChecksum = objPropSet.Checksum
    'Update the checksum
    Call mobjRowset.SetQueryTag("__UPDATE_PARAMTABLE_CHECKSUM__")
    Call mobjRowset.AddParam("%%ID_PARAM%%", objPI.ID)
    Call mobjRowset.AddParam("%%CHECKSUM%%", strChecksum)
    Call mobjRowset.Execute
  End If
  
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' The Functions Below
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'---------------------------------------------------------------------------'
' Function    : CreateType(objSWPI)                                         '
' Description : Save the priceable item to the database. If bCreateNew is   '
'             : true then a new priceable item will be created.             '
' Inputs      : objSWPI -- The service wizard priceable item helper object. '
' Outputs     : none                                                        '
'---------------------------------------------------------------------------'
Private Function SaveToDB(ByRef objSWPI As PriceableItem)
  Dim lngID As Long
  Dim objPC As New MTProductCatalog
  
  'Create the item, depending on the type and call the item's
  'save method
  lngID = GetPriceableItemType(objSWPI, True)
    
  'Add parameter tables
  Call AddParameterTablesToPIType(objSWPI, lngID)
    
  'Configure CPDs
  If objSWPI.PCEntityType = PCENTITY_TYPE_AGGREGATE_CHARGE Or _
     objSWPI.PCEntityType = PCENTITY_TYPE_DISCOUNT Then
    Call ConfigureCPDs(objSWPI, lngID)
  End If
  
  ' Configure charges
  Call ConfigureCharges(objSWPI, lngID)
  'Call ConfigureAdjustmentTypes(objSWPI, lngID)
End Function
'---------------------------------------------------------------------------'
' Function    : GetPriceableItemType(objSWPI, bSave)                        '
' Description : Create a priceable item type, or return an existing one.    '
' Inputs      : objSWPI -- The service wizard priceable item helper object. '
'             : bSave   -- Boolean indicating whether or not to save the    '
'             :            generated product catalog object.                '
' Outputs     : ID of the priceable item type.                              '
'---------------------------------------------------------------------------'
Private Function GetPriceableItemType(ByRef objSWPI As PriceableItem, _
                                      ByVal bSave As Boolean) As Long
  Dim objPC As New MTProductCatalog
  Dim objPI As MTPriceableItemType
  Dim bNew As Boolean                 'indicates a new pi type was created
  
  Dim objMTConfig As New MTConfig     'config object
  Dim objPropSet As MTConfigPropSet   'propset object
  Dim strChecksum As String           'file checksum
    
  Dim objTemp As MTAggregateCharge
  Dim at As IAdjustmentType
  
  'Check if the item exists
  Set objPI = objPC.GetPriceableItemTypeByName(objSWPI.Name)
  
  If objPI Is Nothing Then
    bNew = True
    'Create the item
    Set objPI = objPC.CreatePriceableItemType
  
    objPI.Kind = objSWPI.PCEntityType
    objPI.Name = objSWPI.Name
    For Each at In objSWPI.AdjustmentTypes
       at.PriceableItemTypeID = objPI.ID
    Next
    
    objPI.AdjustmentTypes = objSWPI.AdjustmentTypes
  Else
    bNew = False
  End If
  
  'Set properties
  objPI.Description = objSWPI.Description
  
  objPI.ServiceDefinition = objSWPI.ServiceName
  objPI.ProductView = objSWPI.PVName
  
  If bSave Then
    
    If objPI.Kind <> PCENTITY_TYPE_DISCOUNT Then
      objPI.ConstrainSubscriberCycle = True
    Else
      objPI.ConstrainSubscriberCycle = False
    End If
    
    Call objPI.Save
    
    If bNew Then
      'If a new item is created, add a checksum
      'Compute the checksum from the file
      Set objPropSet = objMTConfig.ReadConfiguration(objSWPI.PropertyAttributes("XMLFILE"), False)
  
      'Get the checksum
      strChecksum = objPropSet.Checksum
    
      ' insert new checksum
      Call mobjRowset.SetQueryTag("__ADD_PARAMTABLE_CHECKSUM__")
      Call mobjRowset.AddParam("%%ID_PARAM%%", objPI.ID)
      Call mobjRowset.AddParam("%%CHECKSUM%%", strChecksum)
      Call mobjRowset.Execute
    End If
  End If
 
  GetPriceableItemType = objPI.ID
End Function
'---------------------------------------------------------------------------'
' Function      : ConfigureCPDs(objSWPI, lngPIID)                           '
' Description   : Add the counter definitions to the priceable item type.   '
' Inputs        : objSWPI -- ID of the priceable item to add to             '
'               : lngPIID -- ID of the priceable item to add to             '
' Outputs       : none                                                      '
'---------------------------------------------------------------------------'
Private Function ConfigureCPDs(ByRef objSWPI As PriceableItem, _
                               ByVal lngPIID As Long)
  Dim lngCPDID As Long                              'CPD id
  Dim lngCounterID As Long                          'Counter ID
    
  Dim objPC As New MTProductCatalog               'Product catalog object
  Dim objPI As MTPriceableItemType                'Priceable item type
  
  Dim objCPD As CPDef                             'Local CPDefs
  Dim objCounter As Counter                       'Local counters
   
  Set objPI = objPC.GetPriceableItemType(lngPIID)
  
  'Configure the CPD and associated counter
  For Each objCPD In objSWPI.CPDefs
    lngCPDID = ConfigureCPD(objCPD, lngPIID)
    
    'Check for error
    If Err Then
      Err.Description = "Unable to Add CPD: " & objCPD.Name
      Err.Raise (Err.Number)
    End If
    
  Next
End Function
'---------------------------------------------------------------------------'
' Function    : ConfigureCPD(objCPDID, lngPIID) as long                     '
' Description : Update or create the CPD, depending on whether it exists or '
'             : not.                                                        '
' Inputs      : objCPD  -- CPD object describing the CPD to get/create.     '
'             : lngPIID -- ID of the priceable item this CPD is associated  '
'             :            with.                                            '
' Outputs     : ID of the CPD                                               '
'---------------------------------------------------------------------------'
Private Function ConfigureCPD(ByRef objCPD As CPDef, _
                              ByRef lngPIID As Long) As Long
  Dim objPC As New MTProductCatalog                   'Product Catalog object
  Dim lngID As Long                                   'ID of the CPD to return
  Dim objRowset As IMTRowSet                          'Rowset object
  Dim objPCCPD As MTCounterPropertyDefinition         'Counter Property Definition object
  Dim objPCPIType As MTPriceableItemType              'Priceable Item Type object
  Dim bFound As Boolean                               'Indicates the CPD already exists
  
  'Get the PI
  Set objPCPIType = objPC.GetPriceableItemType(lngPIID)
  
  'Check for a match
  For Each objPCCPD In objPCPIType.GetCounterPropertyDefinitions
    If UCase(objPCCPD.Name) = UCase(objCPD.Name) Then
      lngID = objPCCPD.ID
      Call PopulateCPD(objCPD, objPCCPD)
      Call objPCCPD.Save
      Exit Function
    End If
  Next
  
  'If the CPD wasn't found, create it
  Set objPCPIType = objPC.GetPriceableItemType(lngPIID)
  Set objPCCPD = objPCPIType.CreateCounterPropertyDefinition()
  
  Call PopulateCPD(objCPD, objPCCPD)
  
  Call objPCCPD.Save
    
  ConfigureCPD = objPCCPD.ID

End Function
'---------------------------------------------------------------------------'
' Function      : PopulateCPD(objCPD, objPCCPD)                             '
' Description   : Populate a product catalog CPD object with information    '
'               : from a service wizard CPD helper object.                  '
' Inputs        : objCPD    --  CPD helper object.                          '
'               : objPCCPD  --  product catalog CPD object                  '
' Outputs       : none                                                      '
'---------------------------------------------------------------------------'
Private Function PopulateCPD(ByRef objCPD As CPDef, _
                             ByRef objPCCPD As MTCounterPropertyDefinition)
  objPCCPD.Name = objCPD.Name
  objPCCPD.DisplayName = objCPD.DisplayName
  objPCCPD.ServiceDefProperty = objCPD.ServiceProperty
  objPCCPD.PreferredCounterTypeName = objCPD.PreferredCounterTypeName
                             
End Function
'---------------------------------------------------------------------------'
' Function      : ConfigureCharges(objSWPI, lngPIID)                        '
' Description   : Add the charges to the priceable item type.               '
' Inputs        : objSWPI -- ID of the priceable item to add to             '
'               : lngPIID -- ID of the priceable item to add to             '
' Outputs       : none                                                      '
'---------------------------------------------------------------------------'
Private Function ConfigureCharges(ByRef objSWPI As PriceableItem, _
                                   ByVal lngPIID As Long)
  Dim lngChargeID As Long                         'Charge id
    
  Dim objPC As New MTProductCatalog               'Product catalog object
  Dim objPI As MTPriceableItemType                'Priceable item type
  
  Dim objCharge As Charge                         'Local Charges
   
  Set objPI = objPC.GetPriceableItemType(lngPIID)
  
  'Configure the CPD and associated counter
  For Each objCharge In objSWPI.Charges
    lngChargeID = ConfigureCharge(objCharge, lngPIID)
    
    'Check for error
    If Err Then
      Err.Description = "Unable to Add Charge: " & objCharge.Name
      Err.Raise (Err.Number)
    End If
    
  Next
End Function
'---------------------------------------------------------------------------------'
' Function    : ConfigureCharge(objCharge, lngPIID) as long                       '
' Description : Update or create the Charge, depending on whether it exists or    '
'             : not.                                                              '
' Inputs      : objCharge  -- Charge object describing the Charge to get/create.  '
'             : lngPIID -- ID of the priceable item this charge is associated     '
'             :            with.                                                  '
' Outputs     : ID of the Charge                                                  '
'---------------------------------------------------------------------------------'
Private Function ConfigureCharge(ByRef objCharge As Charge, _
                                 ByRef lngPIID As Long) As Long
  Dim objPC As New MTProductCatalog                   'Product Catalog object
  Dim lngID As Long                                   'ID of the Charge to return
  Dim objRowset As IMTRowSet                          'Rowset object
  Dim objPCCharge As MTCharge                         'Charge object
  Dim objPCPIType As MTPriceableItemType              'Priceable Item Type object
  Dim bFound As Boolean                               'Indicates the Charge already exists
  Dim objPV As IProductView                           'Product View object of the PI Type
  
  
  'Get the PI
  Set objPCPIType = objPC.GetPriceableItemType(lngPIID)
  Set objPV = objPCPIType.GetProductViewObject
  
  'Check for a match
  For Each objPCCharge In objPCPIType.GetCharges
    If UCase(objCharge.Name) = UCase(objPCCharge.Name) Then
      lngID = objPCCharge.ID
      Call PopulateCharge(objCharge, objPCCharge, objPV)
      Call objPCCharge.Save
      Exit Function
    End If
  Next
  
  'If the Charge wasn't found, create it
  Set objPCCharge = objPCPIType.CreateCharge()
  
  Call PopulateCharge(objCharge, objPCCharge, objPV)
  
  Call objPCCharge.Save
    
  ConfigureCharge = objPCCharge.ID
  
  'Now configure all of the charge properties
  Call ConfigureChargeProperties(objCharge, objPCCharge, objPV)

End Function
'---------------------------------------------------------------------------'
' Function      : PopulateCharge(objCharge, objPCCharge)                    '
' Description   : Populate a product catalog Charge object with information '
'               : from a service wizard Charge helper object.               '
' Inputs        : objCharge   --  Charge helper object.                     '
'               : objPCCharge  --  product catalog Charge object            '
'               : objPV  --  product view object of the pi type             '
' Outputs       : none                                                      '
'---------------------------------------------------------------------------'
Private Function PopulateCharge(ByRef objCharge As Charge, _
                             ByRef objPCCharge As MTCharge, _
                             ByRef objPV As IProductView)
  objPCCharge.Name = objCharge.Name
  objPCCharge.DisplayName = objCharge.DisplayName
  ' Get the database id of the product view property with the same
  ' name as the charge
  Dim objProductViewProperty As IProductViewProperty
  Set objProductViewProperty = objPV.GetPropertyByName(objPCCharge.Name)
  objPCCharge.AmountPropertyID = objProductViewProperty.ID
End Function
'---------------------------------------------------------------------------'
' Function      : ConfigureChargeProperties(objCharge, lngChargeID)                        '
' Description   : Add the charge properties to the charge.               '
' Inputs        : objCharge -- The charge charge to add to             '
'               : lngChargeID -- ID of the charge to add to             '
' Outputs       : none                                                      '
'---------------------------------------------------------------------------'
Private Function ConfigureChargeProperties(ByRef objCharge As Charge, _
                                           ByRef objPCCharge As MTCharge, _
                                           ByRef objPV As IProductView)
  Dim lngChargePropertyID As Long                 'Charge Property id
    
  
  Dim objChargeProperty As ChargeProperty         'Local Charge Property
   
  'Configure the charge property
  For Each objChargeProperty In objCharge.ChargeProperties
    lngChargePropertyID = ConfigureChargeProperty(objChargeProperty, objPCCharge, objPV)
    
    'Check for error
    If Err Then
      Err.Description = "Unable to Add Charge Property: " & objChargeProperty.Name
      Err.Raise (Err.Number)
    End If
    
  Next
End Function '----------------------------------------------------------------------------------------'
' Function    : ConfigureChargeProperty(objChargeProperty, lngChargeID, lngPIID) as long '
' Description : Update or create the Charge Property, depending on whether it exists or  '
'             : not.                                                                     '
' Inputs      : objChargeProperty  -- Charge Property object describing the Charge       '
'             :            Property to get/create.                                       '
'             : lngPIID -- ID of the priceable item this charge property is              '
'             :            associated with.                                              '
'             : lngChargeID -- ID of the charge this charge property is associated       '
'             :             with.                                                        '
' Outputs     : ID of the Charge Property                                                '
'----------------------------------------------------------------------------------------'
Private Function ConfigureChargeProperty(ByRef objChargeProperty As ChargeProperty, _
                                         ByRef objPCCharge As MTCharge, _
                                         ByRef objPV As IProductView) As Long
  Dim lngID As Long                                   'ID of the Charge to return
  Dim objPCChargeProperty As MTChargeProperty         'Charge Property object
    
  'Check for a match
  For Each objPCChargeProperty In objPCCharge.GetChargeProperties
    If UCase(objChargeProperty.Name) = UCase(objPCChargeProperty.GetProductViewProperty().DN) Then
      lngID = objPCChargeProperty.ID
      Call PopulateChargeProperty(objChargeProperty, objPCChargeProperty, objPV)
      Call objPCChargeProperty.Save
      Exit Function
    End If
  Next
  
  'If the Charge wasn't found, create it
  Set objPCChargeProperty = objPCCharge.CreateChargeProperty()
  
  Call PopulateChargeProperty(objChargeProperty, objPCChargeProperty, objPV)
  
  Call objPCChargeProperty.Save
    
  ConfigureChargeProperty = objPCChargeProperty.ID

End Function
'---------------------------------------------------------------------------------------------------'
' Function      : PopulateChargeProperty(objChargeProperty, objPCChargeProperty)                    '
' Description   : Populate a product catalog Charge object with information                         '
'               : from a service wizard Charge helper object.                                       '
' Inputs        : objChargeProperty   --  Charge Property helper object.                            '
'               : objPCChargeProperty  --  product catalog Charge Property object                   '
'               : objPV  --  product view object of the pi type                                     '
' Outputs       : none                                                                              '
'---------------------------------------------------------------------------------------------------'
Private Function PopulateChargeProperty(ByRef objChargeProperty As ChargeProperty, _
                                        ByRef objPCChargeProperty As MTChargeProperty, _
                                        ByRef objPV As IProductView)
  ' Get the database id of the product view property with the same
  ' name as the charge
  Dim objProductViewProperty As IProductViewProperty
  Set objProductViewProperty = objPV.GetPropertyByName(objChargeProperty.Name)
  objPCChargeProperty.ProductViewPropertyID = objProductViewProperty.ID
End Function '---------------------------------------------------------------------------'
' Function      : AddParameterTablesToPIType(objSWPI, lngID)                '
' Description   : Add the parameter tables to the type.                     '
' Inputs        : objSWPI -- Service Wizard priceable item helper object    '
'               : lngID   -- ID of the type to add parameter tables to.     '
' Outputs       : none                                                      '
'---------------------------------------------------------------------------'
Private Function AddParameterTablesToPIType(ByRef objSWPI As PriceableItem, _
                                            ByVal lngID As Long)
  Dim objPC As New MTProductCatalog
  Dim objPI As MTPriceableItemType
  Dim objPTD As MTParamTableDefinition
  Dim objPIPTD As MTParamTableDefinition
  Dim objParameterTableData As ParameterTableData  'Parameter table data object
  Dim strName As Variant
  
  Set objPI = objPC.GetPriceableItemType(lngID)
  
  For Each objParameterTableData In objSWPI.ParameterTables
    strName = objParameterTableData.Name
  
    Set objPTD = objPC.GetParamTableDefinitionByName(strName)
    
    If objPTD Is Nothing Then
        Err.Raise -1, "AddParameterTablesToPIType", "invalid parameter table: " & strName
    End If
    
    'If the PTD is already mapped to the priceable item, remove the mapping, then re-add it
    For Each objPIPTD In objPI.GetParamTableDefinitions
      If objPIPTD.ID = objPTD.ID Then
        Call objPI.RemoveParamTableDefinition(objPTD.ID)
      End If
    Next
    
    Call objPI.AddParamTableDefinition(objPTD.ID)
  Next

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' RELATIONSHIPS CONFIGURATION                                               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'---------------------------------------------------------------------------'
' Function      : ConfigurePIRelationships(objSWPI)                         '
' Description   : Add the parameter tables to the type.                     '
' Inputs        : objSWPI -- Service Wizard Priceable Type helper.          '
' Outputs       : none                                                      '
'---------------------------------------------------------------------------'
Private Function ConfigurePIRelationships(ByRef objSWPI As PriceableItem)
  Dim objPC As New MTProductCatalog
  
  Dim objPI As MTPriceableItemType
  Dim objPIRelative As MTPriceableItemType
  
  Dim objPITemplate As MTPriceableItem
  Dim objPIRelativeTemplate As MTPriceableItem

  Dim strName As Variant
  
  Set objPI = objPC.GetPriceableItemType(GetPriceableItemType(objSWPI, False))
  
  '''''''''''''''''''''
  ' Update the types
  
  'Set the parent for the type
  Set objPIRelative = objPC.GetPriceableItemTypeByName(objSWPI.Parent)
  
  If Not objPIRelative Is Nothing Then
    objPI.ParentID = objPIRelative.ID
    objPI.Save
    
    'Set the parent in the template
    Dim objColl As IMTCollection
    Set objColl = objPI.GetTemplates
    If objColl.Count > 0 Then
        Set objPITemplate = objPI.GetTemplates(1)
        Set objColl = objPIRelative.GetTemplates
        If objColl.Count > 0 Then
            Set objPIRelativeTemplate = objPIRelative.GetTemplates(1)
            objPITemplate.ParentID = objPIRelativeTemplate.ID
            objPITemplate.Save
        End If
    End If
  ElseIf objPI.ParentID <> -1 Then
    ' Somebody has set the parent to NULL
    objPI.ParentID = -1
    objPI.Save
    
    For Each objPITemplate In objPI.GetTemplates
      objPITemplate.ParentID = -1
      objPITemplate.Save
    Next
  End If
  
    
  'Set the children -- this may be redundant
  'For Each strName In objSWPI.Children
  '  Set objPIRelative = objPC.GetPriceableItemTypeByName(strName)
    
  '  If Not objPIRelative Is Nothing Then
  '    objPIRelative.ParentID = objPI.ID
  '    objPIRelative.Save
  '  End If
  'Next
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' CREATE TEMPLATES                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'---------------------------------------------------------------------------'
' Function      : CreateTemplates(objSWPI)                                  '
' Description   : Create Templates if necessary                             '
' Inputs        : objSWPI -- Service wizard priceable item type helper.     '
' Outputs       : none                                                      '
'---------------------------------------------------------------------------'
Private Function CreateTemplate(ByRef objSWPI As PriceableItem)

  Dim objPC As New MTProductCatalog
  Dim objPI As MTPriceableItemType
  Dim objTemplate As MTPriceableItem
  Dim objCPD As MTCounterPropertyDefinition
  Dim objCounter As Counter
  Dim lngCounterID As Long
  
  
  'Only create templates for Aggregate or Usage Charges
  Set objPI = objPC.GetPriceableItemType(GetPriceableItemType(objSWPI, False))
  
  If objPI.Kind = PCENTITY_TYPE_AGGREGATE_CHARGE Or objPI.Kind = PCENTITY_TYPE_USAGE Then
    
    'Remove existing templates
    For Each objTemplate In objPI.GetTemplates
      Call objPI.RemoveTemplate(objTemplate.ID)
    Next
    
    'If objPI.GetTemplates.Count > 0 Then
    '  Exit Function
    'End If
  
    'Change supports new algorithm, 7/10/01
    'Only create template if this is not a child
    'If Len(objSWPI.Parent) = 0 Then
    Set objTemplate = objPI.CreateTemplate()
    
    
    'for each adjustment type associated with this PI
    'create adjustment template

    Dim at As AdjustmentType
    Dim ajtemplate As Adjustment
    Dim rc As IReasonCode
    For Each at In objPI.AdjustmentTypes
        Set ajtemplate = objTemplate.CreateAdjustment(at.ID)
        For Each rc In objSWPI.ReasonCodes(at.Name)
            ajtemplate.AddExistingReasonCode rc
        Next
    Next
                
    
    'Else
    '  Exit Function
    'End If
  
    'For aggregate charges, the cycle type must be set to some value
    If objPI.Kind = PCENTITY_TYPE_AGGREGATE_CHARGE Then
      objTemplate.Cycle.CycleTypeID = 4  ' Weekly
      objTemplate.Cycle.EndDayOfWeek = 1 ' Sunday
    End If
        
    'Save the template
    Call objTemplate.Save
  End If
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' COUNTER CONFIGURATION                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'---------------------------------------------------------------------------'
' Function    : CreateCounters(objSWPI)                                     '
' Description : Add counters and CPDs to priceable items                    '
' Inputs      : objSWPI -- Service wizard priceable item type helper.       '
' Outputs     : none                                                        '
'---------------------------------------------------------------------------'
Private Function CreateCounters(ByRef objSWPI As PriceableItem)
  Dim objPC As New MTProductCatalog             'Product catalog object
  Dim objPI As MTPriceableItemType              'Priceable item type to operate on
  Dim objPCCPD As MTCounterPropertyDefinition   'Product catalog CPD object
  Dim objCounter As Counter                     'Service Wizard Counter object
  Dim lngCounterID As Long                      'ID of the counter to create
  Dim objTemplate As Object                     'Template object
  
  'Get the priceable item
  Set objPI = objPC.GetPriceableItemTypeByName(objSWPI.Name)
  
  If objPI.Kind = PCENTITY_TYPE_AGGREGATE_CHARGE Then
    
    'Find the matching CPD
    If Not objPI Is Nothing Then
      For Each objPCCPD In objPI.GetCounterPropertyDefinitions
      
        'Find the counter in this object that corresponds to the CPD
        For Each objCounter In objSWPI.Counters
          If objCounter.Name = objPCCPD.Name Then
            'Create a counter
            lngCounterID = ConfigureCounter(objCounter, objPI.ID, objPCCPD.ID)
          
            'Add the counter to the template
            Set objTemplate = objPI.GetTemplates(1)
            
            If Not objTemplate Is Nothing Then
              Call objTemplate.SetCounter(objPCCPD.ID, objPC.GetCounter(lngCounterID))
            
            Else
              'Error handling here
      
            End If
            
            'Save the template
            Call objTemplate.Save
            
          End If
        Next
      Next
    Else
      'Error handling here
    
    End If
  End If
End Function
'---------------------------------------------------------------------------'
' Function    : ConfigureCounter()                                          '
' Description : Configure a counter associated with a CPD.                  '
' Inputs      : objCounter    --  Object with counter information.          '
'             : lngPIID       --  ID of the product offering the CPD is     '
'             :                   associated with                           '
'             : lngCPDID      --  ID of the CPD associated with this counter'
' Outputs     : ID of the counter                                           '
'---------------------------------------------------------------------------'
Private Function ConfigureCounter(ByRef objCounter As Counter, _
                                  ByRef lngPIID As Long, _
                                  ByRef lngCPDID As Long) As Long
  Dim objPC As New MTProductCatalog                     'Product Catalog Object
  Dim objPCCPD As MTCounterPropertyDefinition           'CPD object
  Dim objPCCounter As MTCounter                         'Counter object
  Dim objPCCounterType As MTCounterType                 'Counter type
  
  Dim objMTPriceableItemType As MTPriceableItemType
  Dim objMTAggregateChargeTemplate As Object
  
  Dim lngID As Long                                     'ID to return
  Dim bFound As Boolean                                 'Indicates the counter was found
  
  bFound = False
  
  'Get the CPD, to compare names
  Set objPCCPD = objPC.GetCounterPropertyDefinition(lngCPDID)
  
  'Get the PIType
  Set objMTPriceableItemType = objPC.GetPriceableItemType(lngPIID)
  
  'Get the templates
  'For Each objMTAggregateChargeTemplate In objMTPriceableItemType.GetTemplates
  Set objMTAggregateChargeTemplate = objMTPriceableItemType.GetTemplates(1)
  
  If Not objMTAggregateChargeTemplate Is Nothing Then
    'Get the counter, by CPD ID
    Set objPCCounter = objMTAggregateChargeTemplate.GetCounter(lngCPDID)
  
    'IF the counter exists, update it
    If Not objPCCounter Is Nothing Then
      Call PopulateCounter(objCounter, objPCCounter)
      Call objPCCounter.Save
    
      ConfigureCounter = objPCCounter.ID
  
    'else create a new one
    Else
      For Each objPCCounterType In objPC.GetCounterTypes
        If UCase(objPCCounterType.Name) = UCase(objCounter.CounterType) Then
        
          Set objPCCounter = objPC.CreateCounter(objPCCounterType.ID)
      
          Call PopulateCounter(objCounter, objPCCounter)
          Call objPCCounter.Save
        
          ConfigureCounter = objPCCounter.ID
        End If
      Next
    End If
  End If
  
End Function
'---------------------------------------------------------------------------'
' Function      : PopulateCounter(objCounter, objPCCounter)                 '
' Description   : Populate a product catalog counter object with information'
'               : from a service wizard counter helper object.              '
' Inputs        : objCounter    -- service wizard helper counter            '
'               : objPCCounter  -- product catalog counter helper.          '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function PopulateCounter(ByRef objCounter As Counter, _
                                 ByRef objPCCounter As MTCounter)
  Dim objPCParameter As MTCounterParameter
  Dim objParameter As CounterParameter
  
  objPCCounter.Name = objCounter.Name
  objPCCounter.Description = objCounter.Description
  
  'Add parameters
  For Each objParameter In objCounter.Parameters
    objPCCounter.GetParameter(objParameter.Name).Value = objParameter.Value
  Next
End Function

'---------------------------------------------------------------------------'
' Function      :
' Description   :
'               :
' Inputs        :
'               :
' Outputs       : none                                                      '
'---------------------------------------------------------------------------'

Private Function ConfigureAdjustmentTypes(ByRef objSWPI As PriceableItem, _
                                   ByVal lngPIID As Long)

Dim AdjustmentType As AdjustmentType
Dim ExistingType As AdjustmentType
Dim objPCPIType As MTPriceableItemType
Dim existingCol As IMTCollection
'
Set objPCPIType = mobjPC.GetPriceableItemType(lngPIID)
Set existingCol = objPCPIType.AdjustmentTypes
'
Dim busage As Boolean
Dim templateID As Long
templateID = 0
'
Dim piTemplate As MTPriceableItem
For Each piTemplate In objPCPIType.GetTemplates
  If piTemplate.Kind = PCENTITY_TYPE_USAGE Then
    templateID = piTemplate.ID
  End If
Next
'
'
For Each AdjustmentType In objSWPI.AdjustmentTypes
  For Each ExistingType In existingCol
    If ExistingType.Name = AdjustmentType.Name Then
      ' populate the ID from existing database record so we do an update
      AdjustmentType.ID = ExistingType.ID
    End If
  Next
'
  AdjustmentType.SetSessionContext (mobjPC.GetSessionContext())
'
'  ' bind in the type of PI
  AdjustmentType.PriceableItemTypeID = objPCPIType.ID
  AdjustmentType.Save
Next
End Function


