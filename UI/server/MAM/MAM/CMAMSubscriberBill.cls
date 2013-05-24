VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CMAMSubscriberBill"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Const PROP_VIEW_ID = "viewID"
Const PROP_VIEW_TYPE = "viewType"
Const PROP_AMOUNT = "Amount"
Const PROP_TAXAMOUNT = "TaxAmount"
Const PROP_UOM = "Currency"
Const PROP_TIMESTAMP = "TimeStamp"
Const PROP_ACCOUNTID = "AccountID"
Const PROP_PAYEEDISPLAY = "PayeeDisplayName"
Const PROP_SESSIONID = "SessionID"
Const PROP_SESSIONTYPE = "sessionType"
Const PROP_COUNT = "count"
Const PROP_INSTANCE_ID = "PriceableItemInstanceId"
Const PROP_TEMPLATE_ID = "PriceableItemTemplateId"

Public BillLists            As New Collection

Private mobjYAAC            As MTYAAC
Private mobjReportManager   As ReportManager
Private m_objRCD            As New MTRcd
Private mobjReportHelper    As ReportHelper
Private mobjSliceFactory    As New SliceFactory
Private mcollReports        As MTCollection
Private XMLSummary          As String
Private XMLSummaryDom       As DOMDocument40


Private m_objProductSlice
Private m_objAccountSlice
Private m_objProductTimeSlice
Private m_objUsageDetail
Private m_objSessionSlice


Public Function Initialize(ByVal objSubscriberYAAC As Object, Optional ByVal lngLanguageCode As Long = 840, Optional ByVal strReportConfigXMLFile As String = "\samplesite\mps\siteconfig\reports.xml") As Boolean

  
  Dim objSC             As MTSessionContext
  Dim objLC             As New MTLoginContext
  Dim objRenderInfo     As New MPSRenderInfo
  Dim strDisplay        As Variant
  Dim objItem           As MPSReportInfo
  
  Set mobjReportManager = New ReportManager
  mobjReportManager.Initialize m_objRCD.ExtensionDir & strReportConfigXMLFile
  
  'Set objSC = objLC.Login(strUserName, strNameSpace, strPassWord)
  'objYAACFactory.Init objSC
  'Set mobjYAAC = objSubscriberYAAC.GetActorAccount()
  
  Set mobjYAAC = objSubscriberYAAC
  
  Set mobjReportHelper = mobjReportManager.GetReportHelper(mobjYAAC, lngLanguageCode)
  
  Set mcollReports = mobjReportHelper.GetAvailableReports(REPORT_TYPE_BILL)
    
  For Each objItem In mcollReports
  
        BillLists.Add CStr(objItem.Name)
  Next
  Initialize = True
End Function

Public Function LoadSummary(Optional ByVal lngReportIndex As Long = 1) As Boolean

  Dim strXML            As String
  Dim objRenderInfo     As New MPSRenderInfo
  Dim objHierarchyTop   As HierarchyReportLevel
  Dim eViewType         As MPS_VIEW_TYPE
  Dim intIndex          As Long
  Dim objTimeSlice      As New UsageIntervalSlice
  Dim i                 As Long
  
  intIndex = lngReportIndex
    
  eViewType = VIEW_TYPE_BY_FOLDER 'eViewType = VIEW_TYPE_BY_PRODUCT
  
  Set objTimeSlice = mobjReportHelper.GetIntervalTimeSlice(mobjReportHelper.DefaultIntervalID)
  
  mobjReportHelper.ReportIndex = intIndex
  
  mobjReportHelper.InitializeReport objTimeSlice, eViewType, False, False
  
  XMLSummary = mobjReportHelper.GetReportAsXML()
  Debug.Print XMLSummary
  
  Set XMLSummaryDom = New DOMDocument40
  XMLSummaryDom.loadXML XMLSummary
  
  LoadSummary = Len(XMLSummary)
End Function


Public Function LoadProductViewData(ByVal strPriceAbleItemID As String) As Object

  Dim objViewSlice          As Object
  
  Dim i                     As Long
  
  If Len(XMLSummary) = 0 Then Exit Function
  
  Set m_objProductSlice = mobjSliceFactory.FromString(XMLSummaryDom.selectSingleNode("/level/charges/po/pi/internal_id").Text)
  Set m_objAccountSlice = mobjSliceFactory.FromString(XMLSummaryDom.selectSingleNode("/level/internal_id").Text)
  Set m_objProductTimeSlice = mobjReportHelper.GetIntervalTimeSlice(mobjReportHelper.DefaultIntervalID) 'Set objProductTimeSlice = mobjSliceFactory.FromString("And/" & XMLSummaryDom.selectSingleNode("/level/internal_id").Text)
  Set objViewSlice = mobjSliceFactory.FromString("ROOT")
  
  ' -- Keep a ref to the rowset --
  Set m_objUsageDetail = mobjReportHelper.GetUsageDetail(m_objProductSlice, objViewSlice, m_objAccountSlice, m_objProductTimeSlice, "")
  
  Set LoadProductViewData = m_objUsageDetail
End Function

'ProductOfferingName,PriceableItemName,PriceableItemInstanceName,ProductOfferingId,PriceableItemInstanceId,PriceableItemTemplateId,PriceableItemParentId,ViewID,ViewType,DescriptionID,Currency,Amount,TaxAmount,AmountWithTax,Count,
Public Function GetChildrenTYPESDetailAsRowSet()
  
  Set m_objSessionSlice = getChildSummarySlice(getSessionSlice(m_objUsageDetail))
  Set GetChildrenTYPESDetailAsRowSet = getSessionSummary(m_objSessionSlice, m_objAccountSlice, m_objProductTimeSlice, "")
End Function

Private Function getChildSummarySlice(objDetailSlice) As Object

  Dim objProductSlice
  Set objProductSlice = CreateObject("MTHierarchyReports.SessionChildrenSlice")
  objProductSlice.ParentID = objDetailSlice.SessionID
  Set getChildSummarySlice = objProductSlice

End Function


Function getSessionSummary(objProductSlice, objAccountSlice, objTimeSlice, aSqlExtension)

  Set getSessionSummary = mobjReportHelper.GetUsageSummary(objProductSlice, objAccountSlice, objTimeSlice)
End Function




Private Function getSessionSlice(objUsageDetail) As Object

  Dim objSessionSlice   'As UsageIntervalSlice
  Dim intSessionID      As Long
  
  Set objSessionSlice = CreateObject("MTHierarchyReports.SessionSlice")
  intSessionID = objUsageDetail.Value("SessionID")
  objSessionSlice.SessionID = intSessionID
  Set getSessionSlice = objSessionSlice
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : getProductSlice(objSummaryRowset)                                       '
' Description : Get a product slice from the current row of the rowset                  '
' Inputs      : objSummaryRowset - A summary rowset that is positioned on a valid row   '
' Outputs     : The product slice object that selecting the current row                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function getProductSlice(objSummaryRowset)

  Dim objProductSlice

  ' Look at the rowset and figure out whether it is within a product offering or not
  If Len(objSummaryRowset.Value(PROP_TEMPLATE_ID)) = 0 Then
  
    Set objProductSlice = CreateObject("MTHierarchyReports.ProductViewSlice")
    objProductSlice.ViewID = CLng(objSummaryRowset.Value(PROP_VIEW_ID))
    
  ElseIf Len(objSummaryRowset.Value(PROP_INSTANCE_ID)) = 0 Then
  
    Set objProductSlice = CreateObject("MTHierarchyReports.PriceableItemTemplateSlice")
    objProductSlice.TemplateID = CLng(objSummaryRowset.Value(PROP_TEMPLATE_ID))
    objProductSlice.ViewID = CLng(objSummaryRowset.Value(PROP_VIEW_ID))
    
  Else
  
    Set objProductSlice = CreateObject("MTHierarchyReports.PriceableItemInstanceSlice")
    objProductSlice.InstanceID = CLng(objSummaryRowset.Value(PROP_INSTANCE_ID))
    
    objProductSlice.ViewID = CLng(objSummaryRowset.Value(PROP_VIEW_ID))
  End If
  Set getProductSlice = objProductSlice

End Function

Public Function GetChildrenDetailAsRowSet(ByVal objRowSet As Object, ByVal strChilType As String)
  
    Set GetChildrenDetailAsRowSet = mobjReportHelper.GetUsageDetail(getProductSlice(objRowSet), m_objSessionSlice, m_objAccountSlice, m_objProductTimeSlice, "")
End Function


Public Function DumpRowSet(r) As Boolean
    Dim i As Long
    r.MoveFirst
    
    For i = 0 To r.Count - 1
        Debug.Print r.Name(CLng(i)) & ",";
    Next
    Debug.Print ""
    
    Do While Not r.EOF
    
        For i = 0 To r.Count - 1
            Debug.Print r.Value(CLng(i)) & ",";
        Next
        Debug.Print ""
        r.MoveNext
    Loop
    r.MoveFirst
End Function

