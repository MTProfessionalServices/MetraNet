VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 2  'RequiresTransaction
END
Attribute VB_Name = "Test"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Public Function RunTest()
   TestCustomer
End Function
Public Sub TestCustomer()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\Customer.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//CreateOrUpdateAccount/ExtAccountID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.CreateOrUpdateAccounts(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Public Sub TestCustomerStatusUpdate()
Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\CustomerStatusUpdate.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//AccountStatusUpdate/ExtAccountID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.UpdateAccountStatus(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub


Public Sub TestSalesPerson()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\SalesPerson.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//SalesPerson/SalesPersonID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.CreateOrUpdateSalesPersons(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub TestTerritory()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object
On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\Territory.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//Territory/TerritoryID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.CreateOrUpdateTerritories(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub TestTerritoryManager()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\TerritoryManager.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//UpdateTerritoryManagers/TerritoryID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.UpdateTerritoryManagers(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub TestCreatePayments()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\Payment.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//Payment/PaymentID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.CreatePayments(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Public Sub TestApplyCredits()

Dim configState As Variant
Dim oConfig As IMTARConfig

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.ApplyCredits(configState)

GetObjectContext.SetComplete

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Public Sub TestRunAging()
Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\RunAging.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//RunAging")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.RunAging(doc, configState)

GetObjectContext.SetComplete

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Public Sub TestCreateInvoices()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\Invoice.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//CreateInvoice/InvoiceID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.CreateInvoices(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub TestGetBalances()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object
Dim obj As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\GetBalances.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//GetBalance/ExtAccountID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim reader As IMTARReader
Set reader = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsReader")
Set obj = reader.GetBalances(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set reader = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub TestGetBalanceDetails()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object
Dim obj As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\GetBalances.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//Balance/ExtAccountID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim reader As IMTARReader
Set reader = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsReader")
Set obj = reader.GetBalanceDetails(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set reader = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Public Sub TestMoveBalances()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\MoveBalances.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//MoveBalance/FromExtAccountID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.MoveBalances(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Public Sub TestDeleteBatches()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\DeleteBatches.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//DeleteBatch/BatchID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.DeleteBatches(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Public Sub TestCreateAdjustments()

Dim configState As Variant
Dim oConfig As IMTARConfig
Dim doc As Object

On Error GoTo errorhandler

Set oConfig = New MTGreatPlainsConfig

Set configState = oConfig.Configure

Set doc = CreateObject(configState.DOMDocumentProgID)

If Not doc.Load(App.Path + "\Adjustment.xml") Then
    Err.Raise 999, "", doc.parseError.reason
End If

Dim node As IXMLDOMNode
Set node = doc.selectSingleNode("//CreateAdjustment/AdjustmentID")
If node Is Nothing Then
  Err.Raise 999, "", "node not found"
End If

Dim writer As IMTARWriter
Set writer = GetObjectContext.CreateInstance("MTGreatPlainsExec.MTGreatPlainsWriter")
Call writer.CreateAdjustments(doc, configState)

GetObjectContext.SetComplete
Set doc = Nothing

Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set writer = Nothing
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub



