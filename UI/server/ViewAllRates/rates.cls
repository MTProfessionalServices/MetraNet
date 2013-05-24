VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "rates"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' ****************************************************************************************************************************************************
'
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
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' CLASS         : MSIX.
' AUTHOR        : K.Boucher
' CREATION DATE : 05/14/2001
' DESCRIPTION   : Walks the product catalog objects and returns XML describing the rates in the system
'
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
' *********************************************************************************************************************************************************
Option Explicit
 
Const PCDATE_TYPE_ABSOLUTE = 1
Const PCDATE_TYPE_SUBSCRIPTION = 2
Const PCDATE_TYPE_BILLCYCLE = 3
Const PCDATE_TYPE_NULL = 4
 
Private m_objXMLString As cStringConcat
Private Const XML_STRING_BUFFER = 256000

Private m_objEnumConfig As Object ' Just to hold a reference in memory during the process
Private m_objCalendarRowset As IMTRowSet

'Dim m_strXML As String

'----------------------------------------------------------------------------
'  EVENTS
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
'   Name: onstartpage
'   Description:  Set up the ASP variable.  Call during CreateObject
'   Parameters: sc As ScriptingContext
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub onstartpage(sc As ASPTypeLibrary.ScriptingContext)
       Set response = sc.response
       Set session = sc.session
       Set server = sc.server
       Set request = sc.request
       Set application = sc.application
End Sub

' ----------------------------------------
' writes out a progress indicator
' ----------------------------------------
Sub WriteMessage(ByRef strMessage As String)
    Dim str As String
    Dim strLoading(4) As String
    Static nLoadingIndex As Long
    
    strLoading(0) = "\\"
    strLoading(1) = "|"
    strLoading(2) = "/"
    strLoading(3) = "-"
    
    nLoadingIndex = nLoadingIndex + 1
    
    str = Replace(strMessage, "'", "\'") ' escape quote characters
            
    response.Write "<SCRIPT LANGUAGE=""JavaScript"">" & vbCrLf
    response.Write "document.getElementById('loading').innerText = 'Loading... " & strLoading(nLoadingIndex Mod 4) & "'; /* " & str & " */"
    response.Write "</SCRIPT>"
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetRatesForAccount
' PARAMETERS    : Account ID, optional boolean if you want it localized
' DESCRIPTION   : Get XML describing rates for an account
' RETURN        : XML describing rates for an account including (ICB)
Public Function GetRatesForAccount(strPriceListName As String, nID As Long, Optional booLocalize As Boolean = False, Optional booProgress As Boolean = False, Optional booCalendar As Boolean = False, Optional booLocalTime As Boolean = False, Optional TimeZoneID As Long = 18) As String
    Dim pc As New MTProductCatalog
    Dim acct As MTPCAccount
    Dim rowset As IMTRowSet
    Dim subs As IMTCollection
    Dim s As MTSubscription
    Dim po As MTProductOffering
    Dim pis As IMTCollection
    Dim pt As MTParamTableDefinition
    Dim pl As MTPriceList
    Dim objTextFile As New cTextFile
    
    Dim gs As MTGroupSubscription
    Dim sb As IMTSubscriptionBase
    
    Dim strStartDate As String
    Dim strEndDate As String
    
    On Error GoTo ErrMgr
        
    Dim objTools As Object
    Set objTools = CreateObject("MTMSIX.MSIXTools")

    m_objXMLString.Init XML_STRING_BUFFER
    m_objXMLString.Concat "<?xml version=""1.0""?>" & vbNewLine & "<rates>" & vbNewLine & "<accountID>" & nID & "</accountID>" & vbNewLine
    
    Set acct = pc.GetAccount(nID) ' get account reference
    
    'Retrieve Subscription Rates
    'Set rowset = acct.GetActiveSubscriptionsAsRowset() ' get active subscriptions
    Set rowset = acct.GetSubscriptionsAsRowset() 'get subscriptions
    
    While Not rowset.EOF  ' go over each subscription
    
     WriteMessage "Loading:  " & rowset.Value("po_nm_name") & "..."
      
     m_objXMLString.Concat "<subscription>" & vbNewLine & "<name>" & server.HTMLEncode(rowset.Value("po_nm_name")) & "</name>" & vbNewLine
     Set s = acct.GetSubscription(rowset.Value("id_sub"))
     Set po = s.GetProductOffering()
     
     Set pis = po.GetPriceableItems()
     
     RecursePriceableItems pis, booLocalize, booProgress, booCalendar, booLocalTime, s, TimeZoneID ' get priceable items
     
     m_objXMLString.Concat "</subscription>" & vbNewLine
     
     rowset.MoveNext
    Wend

    'Retrieve Group Subscription Rates
    Set rowset = acct.GetGroupSubscriptionsAsRowset() 'get subscriptions
    While Not rowset.EOF  ' go over each subscription
    
     WriteMessage "Loading:  " & rowset.Value("po_nm_name") & "..."
      
     m_objXMLString.Concat "<groupsubscription>" & vbNewLine & "<name>" & server.HTMLEncode(rowset.Value("po_nm_name")) & "</name>" & vbNewLine
     m_objXMLString.Concat "<groupdesc>" & server.HTMLEncode(rowset.Value("TX_DESC")) & "</groupdesc>" & vbNewLine
     
     strStartDate = rowset.Value("DT_START")
     strEndDate = rowset.Value("DT_END")
     
     If strStartDate = "" Then
        strStartDate = "[TEXT_NULL_START_DATE_TYPE]"
     Else
        If booLocalTime Then
            strStartDate = objTools.ConvertFromGMT(strStartDate, TimeZoneID)
        End If
     End If

     If strEndDate = "" Then
        strEndDate = "[TEXT_NULL_END_DATE_TYPE]"
     Else
        If booLocalTime Then
            strEndDate = objTools.ConvertFromGMT(strEndDate, TimeZoneID)
        End If
     End If
     
     m_objXMLString.Concat "<start>" & server.HTMLEncode(strStartDate) & "</start>" & vbNewLine
     m_objXMLString.Concat "<end>" & server.HTMLEncode(strEndDate) & "</end>" & vbNewLine
     
     Set gs = acct.GetSubscription(CLng(rowset.Value("id_sub")))
     Set po = gs.GetProductOffering()
     
     Set pis = po.GetPriceableItems()
     
     RecursePriceableItems pis, booLocalize, booProgress, booCalendar, booLocalTime, s, TimeZoneID ' get priceable items
     
     m_objXMLString.Concat "</groupsubscription>" & vbNewLine
     
     rowset.MoveNext
    Wend

    'Retrieve Pricelist Rates
    m_objXMLString.Concat "<defaultpricelist>" & strPriceListName & "</defaultpricelist>" & vbNewLine

    GetPriceList strPriceListName, booLocalize, booProgress, booCalendar, booLocalTime, TimeZoneID
    
    m_objXMLString.Concat "</rates>" & vbNewLine
    
    If booProgress Then
       WriteMessage "Rendering display..."
    End If
    
    GetRatesForAccount = m_objXMLString.GetString()
    
    'objTextFile.LogFile Environ("temp") & "\tina" & nID & ".xml", m_objXMLString.GetString(), True
   
    Exit Function
ErrMgr:
  TRACE MTVIEWALLRATES_ERROR_05000 & GetVBErrorString(), "rates.cls", "GetRatesForAccount", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetPriceList
' PARAMETERS    : optional boolean if you want it localized
' DESCRIPTION   : Get XML describing system rates
' RETURN        : XML describing rates in pricelist
Public Function GetPriceList(strPriceListName As String, Optional booLocalize As Boolean = False, Optional booProgress As Boolean = False, Optional booCalendar As Boolean = False, Optional booLocalTime As Boolean = False, Optional TimeZoneID As Long = 18) As String
    Dim pc As New MTProductCatalog
    Dim pl As MTPriceList
    Dim pi As MTPriceableItem
    Dim rowset As IMTRowSet
    Dim plRowset As IMTRowSet
    Dim po As MTProductOffering
    Dim pits As IMTCollection
    
    Dim pit As MTPriceableItemType
    Dim pit2 As MTPriceableItemType
    Dim ptdcol As IMTCollection
    Dim ptd As MTParamTableDefinition
    Dim pitsChild As IMTCollection
    
    On Error GoTo ErrMgr
    
    If Len(strPriceListName) = 0 Then
        Exit Function
    End If
    
    Set pits = pc.GetPriceableItemTypes()
    
    For Each pit In pits
    
        m_objXMLString.Concat "<Default>" & vbNewLine
        m_objXMLString.Concat "<name>" & server.HTMLEncode(pit.Name) & "</name>" & vbNewLine
        WriteMessage "Loading:  " & pit.Name & "..."
        
        If pit.Name = "Song Session" Then
            'Debug.Assert 0
        End If
        
        Set ptdcol = pit.GetParamTableDefinitions()
        
        For Each ptd In ptdcol
            m_objXMLString.Concat "<parameterTable>" & vbNewLine & "<name>" & server.HTMLEncode(ptd.Name) & "</name>" & vbNewLine
            
            'get rate schedules
            Set rowset = ptd.GetRateSchedulesAsRowset()
            GetRateSchedules rowset, ptd, booLocalTime, booCalendar, booLocalize, False, strPriceListName, TimeZoneID
            
            m_objXMLString.Concat "</parameterTable>" & vbNewLine
        Next
        
        m_objXMLString.Concat "</Default>" & vbNewLine
        
        '
        ' Added by fred to add the children rate of a price list - Bug #xxxxx
        '
        Set pitsChild = pit.GetChildren()
        
        If pitsChild.Count Then
        
            For Each pit2 In pitsChild
            
                m_objXMLString.Concat "<Default>" & vbNewLine
                m_objXMLString.Concat "<name>" & server.HTMLEncode(pit2.Name) & "</name>" & vbNewLine
                WriteMessage "Loading:  " & pit2.Name & "..."
                
                Set ptdcol = pit2.GetParamTableDefinitions()
                
                For Each ptd In ptdcol
                
                      m_objXMLString.Concat "<parameterTable>" & vbNewLine & "<name>" & server.HTMLEncode(ptd.Name) & "</name>" & vbNewLine
                    
                      'get rate schedules
                      Set rowset = ptd.GetRateSchedulesAsRowset()
                      GetRateSchedules rowset, ptd, booLocalTime, booCalendar, booLocalize, False, strPriceListName, TimeZoneID
                      
                      m_objXMLString.Concat "</parameterTable>" & vbNewLine
                Next
               m_objXMLString.Concat "</Default>" & vbNewLine
            Next
        End If
    Next
     
     Exit Function
ErrMgr:
  TRACE MTVIEWALLRATES_ERROR_05000 & GetVBErrorString(), "rates.cls", "GetPriceList", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetAllRatesByProductOffering
' PARAMETERS    : optional boolean if you want it localized
' DESCRIPTION   : Get XML describing system rates
' RETURN        : XML describing rates in system (not ICB)
Public Function GetAllRatesByProductOffering(Optional booLocalize As Boolean = False, Optional booProgress As Boolean = False, Optional booCalendar As Boolean = False, Optional booLocalTime As Boolean = False, Optional TimeZoneID As Long = 18) As String
    Dim pc As New MTProductCatalog
    Dim pl As MTPriceList
    Dim pi As MTPriceableItem
    Dim rowset As IMTRowSet
    Dim poRowset As IMTRowSet
    Dim po As MTProductOffering
    
    On Error GoTo ErrMgr
    
    Set poRowset = pc.FindProductOfferingsAsRowset()
                 
    
    

                 
    m_objXMLString.Init XML_STRING_BUFFER
    m_objXMLString.Concat "<?xml version=""1.0""?>" & vbNewLine & "<rates>" & vbNewLine
    
    While Not poRowset.EOF
    
        Set po = pc.GetProductOffering(poRowset.Value("id_prop"))
        WriteMessage "Loading:  " & po.Name & "..."
        m_objXMLString.Concat "<ProductOffering>" & vbNewLine
        m_objXMLString.Concat "<name>" & server.HTMLEncode(po.Name) & "</name>" & vbNewLine
        
        RecursePriceableItems po.GetPriceableItems(), booLocalize, booProgress, booCalendar, booLocalTime, Nothing, TimeZoneID
        
        m_objXMLString.Concat "</ProductOffering>" & vbNewLine
          
        poRowset.MoveNext
    Wend
    
     
    m_objXMLString.Concat "</rates>" & vbNewLine
    
    If booProgress Then
       WriteMessage "Rendering display..."
    End If
            
    GetAllRatesByProductOffering = m_objXMLString.GetString()
    Exit Function

ErrMgr:
  TRACE MTVIEWALLRATES_ERROR_05000 & GetVBErrorString(), "rates.cls", "GetAllRatesByProductOffering", LOG_ERROR
  
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetAllRatesForProductOffering
' PARAMETERS    : optional boolean if you want it localized
' DESCRIPTION   : Get XML describing system rates
' RETURN        : XML describing rates in system (not ICB)
Public Function GetAllRatesForProductOffering(poid As Long, Optional booLocalize As Boolean = False, Optional booProgress As Boolean = False, Optional booCalendar As Boolean = False, Optional booLocalTime As Boolean = False, Optional TimeZoneID As Long = 18) As String
    Dim pc As New MTProductCatalog
    Dim pl As MTPriceList
    Dim pi As MTPriceableItem
    Dim rowset As IMTRowSet
    Dim po As MTProductOffering
    
    On Error GoTo ErrMgr
    
                 
    m_objXMLString.Init XML_STRING_BUFFER
    m_objXMLString.Concat "<?xml version=""1.0""?>" & vbNewLine & "<rates>" & vbNewLine
    
    Set po = pc.GetProductOffering(poid)
    WriteMessage "Loading:  " & po.Name & "..."
    m_objXMLString.Concat "<ProductOffering>" & vbNewLine
    m_objXMLString.Concat "<name>" & server.HTMLEncode(po.Name) & "</name>" & vbNewLine
    
    RecursePriceableItems po.GetPriceableItems(), booLocalize, booProgress, booCalendar, booLocalTime, Nothing, TimeZoneID
    
    m_objXMLString.Concat "</ProductOffering>" & vbNewLine
    
     
    m_objXMLString.Concat "</rates>" & vbNewLine
    
    If booProgress Then
       WriteMessage "Rendering display..."
    End If
            
    GetAllRatesForProductOffering = m_objXMLString.GetString()
    Exit Function

ErrMgr:
  TRACE MTVIEWALLRATES_ERROR_05000 & GetVBErrorString(), "rates.cls", "GetAllRatesForProductOffering", LOG_ERROR
  
End Function
' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetAllRatesByPriceableItemType
' PARAMETERS    : optional boolean if you want it localized
' DESCRIPTION   : Get XML describing system rates
' RETURN        : XML describing rates in system (not ICB)
Public Function GetAllRatesByPriceableItemType(Optional booLocalize As Boolean = False, Optional booProgress As Boolean = False, Optional booCalendar As Boolean = False, Optional booLocalTime As Boolean = False, Optional TimeZoneID As Long = 18) As String

    Dim pc As New MTProductCatalog
    Dim pl As MTPriceList
    Dim pi As MTPriceableItem
    Dim rowset As IMTRowSet
    Dim plRowset As IMTRowSet
    Dim po As MTProductOffering
    Dim pits As IMTCollection
    Dim pit As MTPriceableItemType
    Dim ptdcol As IMTCollection
    Dim ptd As MTParamTableDefinition
    
    On Error GoTo ErrMgr
    
    Set pits = pc.GetPriceableItemTypes()
                 
    m_objXMLString.Init XML_STRING_BUFFER
    m_objXMLString.Concat "<?xml version=""1.0""?>" & vbNewLine & "<rates>" & vbNewLine
    
    For Each pit In pits
    
        If pit.Kind = PCENTITY_TYPE_AGGREGATE_CHARGE Or pit.Kind = PCENTITY_TYPE_USAGE Then
        
              m_objXMLString.Concat "<PriceableItemType>" & vbNewLine
              m_objXMLString.Concat "<name>" & server.HTMLEncode(pit.Name) & "</name>" & vbNewLine
              
              Set ptdcol = pit.GetParamTableDefinitions()
              
              For Each ptd In ptdcol
              
                  m_objXMLString.Concat "<parameterTable>" & vbNewLine & "<name>" & server.HTMLEncode(ptd.Name) & "</name>" & vbNewLine
                
                  WriteMessage "Loading:  " & pit.Name & ":  " & ptd.Name & "..."
                  
                  'get rate schedules
                  Set rowset = ptd.GetNonICBRateSchedulesByPriceableItemTypeAsRowset(pit.ID)
                  'Set rowset = ptd.GetRateSchedulesAsRowset()
                  GetRateSchedules rowset, ptd, booLocalTime, booCalendar, booLocalize, False, "", TimeZoneID
                  
                  m_objXMLString.Concat "</parameterTable>" & vbNewLine
        
              Next
              
              ' Display the children priceable items too
              RecursePriceableItemTypes pit.GetChildren(), booLocalize, booProgress, booCalendar, booLocalTime, Nothing, TimeZoneID
              
             m_objXMLString.Concat "</PriceableItemType>" & vbNewLine
           
       End If
    Next
     
    m_objXMLString.Concat "</rates>" & vbNewLine
    
    If booProgress Then
       WriteMessage "Rendering display..."
    End If
            
    GetAllRatesByPriceableItemType = m_objXMLString.GetString()
    Exit Function

ErrMgr:
  TRACE MTVIEWALLRATES_ERROR_05000 & GetVBErrorString(), "rates.cls", "GetAllRatesByPriceableItemType", LOG_ERROR
  
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : RecursePriceableItems
' PARAMETERS    : Priceable Item Collection, optional boolean if you want it localized
' DESCRIPTION   : Adds to global XML string
' RETURN        :
Sub RecursePriceableItems(pis, Optional booLocalize As Boolean = False, Optional booProgress As Boolean = False, Optional booCalendar As Boolean = False, Optional booLocalTime As Boolean = False, Optional subscr As MTSubscription = Nothing, Optional TimeZoneID As Long = 18)
     Dim p As MTPriceableItem
     Dim pis2 As IMTCollection
     Dim plm As MTPriceListMapping
     Dim pl As MTPriceList
     Dim ptd As MTParamTableDefinition
     Dim ptdcol As IMTCollection
     Dim rowset As IMTRowSet

     On Error GoTo ErrMgr
    
     For Each p In pis
     
         m_objXMLString.Concat "<priceableItem>" & vbNewLine & "<name>" & server.HTMLEncode(p.Name) & "</name>" & vbNewLine
         
         Set ptdcol = p.PriceableItemType.GetParamTableDefinitions()
         
         For Each ptd In ptdcol
         
            m_objXMLString.Concat "<parameterTable>" & vbNewLine & "<name>" & server.HTMLEncode(ptd.Name) & "</name>" & vbNewLine
            WriteMessage "Loading:  " & p.Name & ":  " & ptd.Name & "..."
            
            'get the icb rate schedules if subs exists
            If Not subscr Is Nothing Then
            
                Set plm = subscr.GetICBPriceListMapping(p.ID, ptd.ID)
                
                If Not plm Is Nothing Then
                
                  Set rowset = plm.FindRateSchedulesAsRowset()
                  GetRateSchedules rowset, ptd, booLocalTime, booCalendar, booLocalize, True, "", TimeZoneID
                End If
            End If
            
            'get the non-icb rate schedules
            Set plm = p.GetPriceListMapping(ptd.ID)
            If Not plm Is Nothing Then
              Set rowset = plm.FindRateSchedulesAsRowset()
              GetRateSchedules rowset, ptd, booLocalTime, booCalendar, booLocalize, False, "", TimeZoneID
            End If
            m_objXMLString.Concat "</parameterTable>" & vbNewLine
         Next
        
         
         Set pis2 = p.GetChildren()
         
         If pis2.Count > 0 Then
         
               RecursePriceableItems pis2, booLocalize, booProgress, booCalendar, booLocalTime, subscr, TimeZoneID
         End If
         
         m_objXMLString.Concat "</priceableItem>" & vbNewLine
     Next
     
     Exit Sub

ErrMgr:
  TRACE MTVIEWALLRATES_ERROR_05000 & GetVBErrorString(), "rates.cls", "RecursePriceableItems", LOG_ERROR
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : RecursePriceableItemTypes
' PARAMETERS    : Priceable Item Collection, optional boolean if you want it localized
' DESCRIPTION   : Adds to global XML string
' RETURN        :
Sub RecursePriceableItemTypes(pis, Optional booLocalize As Boolean = False, Optional booProgress As Boolean = False, Optional booCalendar As Boolean = False, Optional booLocalTime As Boolean = False, Optional subscr As MTSubscription = Nothing, Optional TimeZoneID As Long = 18)
     Dim p As MTPriceableItemType
     Dim pis2 As IMTCollection
     Dim plm As MTPriceListMapping
     Dim pl As MTPriceList
     Dim ptd As MTParamTableDefinition
     Dim ptdcol As IMTCollection
     Dim rowset As IMTRowSet

     On Error GoTo ErrMgr
    
     For Each p In pis
     
      m_objXMLString.Concat "<PriceableItemType>" & vbNewLine & "<name>" & server.HTMLEncode(p.Name) & "</name>" & vbNewLine
      Set ptdcol = p.GetParamTableDefinitions()
      
      For Each ptd In ptdcol
        m_objXMLString.Concat "<parameterTable>" & vbNewLine & "<name>" & server.HTMLEncode(ptd.Name) & "</name>" & vbNewLine
        WriteMessage "Loading:  " & p.Name & ":  " & ptd.Name & "..."
                
        'get the rate schedules
        'Set rowset = ptd.GetRateSchedulesAsRowset()
        Set rowset = ptd.GetNonICBRateSchedulesByPriceableItemTypeAsRowset(p.ID)
        GetRateSchedules rowset, ptd, booLocalTime, booCalendar, booLocalize, False, "", TimeZoneID
           
        m_objXMLString.Concat "</parameterTable>" & vbNewLine
      Next
     
      
      Set pis2 = p.GetChildren()
      If pis2.Count > 0 Then
        RecursePriceableItemTypes pis2, booLocalize, booProgress, booCalendar, booLocalTime, subscr
      End If
      
      m_objXMLString.Concat "</PriceableItemType>" & vbNewLine
     Next
     
     Exit Sub

ErrMgr:
  TRACE MTVIEWALLRATES_ERROR_05000 & GetVBErrorString(), "rates.cls", "RecursePriceableItemTypes", LOG_ERROR
End Sub

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetRateSchedules
' PARAMETERS    :
' DESCRIPTION   : Adds to global XML string
' RETURN        :
Private Sub GetRateSchedules(rowset As IMTRowSet, ptd As MTParamTableDefinition, booLocalTime As Boolean, booCalendar As Boolean, booLocalize As Boolean, Optional booShowICB As Boolean = False, Optional strPriceListName As String = "", Optional TimeZoneID As Long = 18)
  Dim rs As MTRateSchedule
  Dim effective As MTPCTimeSpan
  Dim strStartDate As String
  Dim strEndDate As String
  Dim objTools As Object
  Dim booOKToShow As Boolean
  Dim rule As IMTRuleSet
  
  Dim objXMLDoc As New DOMDocument30       'XML document, used to handle massaging of data
                                        'to display optional properties correctly
  Dim objCondition As MTConditionMetaData  'Conditions meta-data
  Dim objAction As MTActionMetaData        'Action meta-data
  
  Dim objConfigDataNode As IXMLDOMNode      'Configdata section
  Dim objNewConstraintSetNode As IXMLDOMNode  'The new constraint set node
  Dim objConstraintSetNode As IXMLDOMNode  'each constraint set
  Dim objConstraintNode As IXMLDOMNode     'New condition node
  Dim objPropNameNode As IXMLDOMNode       'prop_name node
  Dim objPropValueNode As IXMLDOMNode      'prop_value node
  Dim objActionsNode As IXMLDOMNode        'Actions node for new constraint set
                                             
  Dim objConstraintSetList As IXMLDOMNodeList  'List of constraint sets
  
  Dim propset As IMTConfigPropSet
  Dim ruleBuffer As String
      
  Dim intLen As Integer         'used for formatting constraint_sets to include optional items
  Dim i As Integer              'counter
                                             
  On Error GoTo ErrMgr
  
  'Initialize the object
  objXMLDoc.async = False
  objXMLDoc.validateOnParse = False
  objXMLDoc.resolveExternals = False
  
  booOKToShow = True
  
  Set objTools = CreateObject("MTMSIX.MSIXTools")
  
  While Not rowset.EOF
    Set rs = ptd.GetRateSchedule(rowset.Value("id_sched"))
    
    If booShowICB Then
      If Not rs.GetPriceList.Shareable Then
        booOKToShow = True
      Else
        booOKToShow = False
      End If
    Else
      If Not rs.GetPriceList.Shareable Then
        booOKToShow = False
      Else
        booOKToShow = True
      End If
    End If
    
    If strPriceListName <> "" Then
      If strPriceListName = rs.GetPriceList.Name Then
        booOKToShow = True
      Else
        booOKToShow = False
      End If
    End If
    
    If booOKToShow Then
  
    'Active Progress!!!
    WriteMessage "Loading:  " & rs.GetPriceList.Name & "..."
    
    
    ' Effective Date logic
    Set effective = rs.EffectiveDate
      
    strStartDate = effective.StartDate
    strEndDate = effective.EndDate
      
    If False Then ' Ideally we would like to check effective.IsEndDateNull, but looks like when the date is subscription relative,
                  ' then effective.IsEndDateNull is TRUE too! In any case, Case 4 takes care of it
        strEndDate = "[TEXT_NULL_END_DATE_TYPE]"
    Else
      If booLocalTime Then
        strEndDate = objTools.ConvertFromGMT(strEndDate, TimeZoneID)
      End If
      
      Select Case effective.EndDateType
        Case PCDATE_TYPE_ABSOLUTE
          strEndDate = "[TEXT_ABSOLUTE_DATE_TYPE]" & " " & strEndDate
        Case PCDATE_TYPE_SUBSCRIPTION
          strEndDate = effective.EndOffset & " " & "[TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE]"
        Case PCDATE_TYPE_BILLCYCLE
          strEndDate = "[TEXT_BILLINGCYCLE_DATE_TYPE]" & " " & strEndDate
        Case PCDATE_TYPE_NULL
          effective.SetEndDateNull
          strEndDate = "[TEXT_NULL_END_DATE_TYPE]"
      End Select
    End If
      
    If False Then ' Ideally we would like to check effective.IsStartDateNull, but looks like when the date is subscription relative,
                  ' then effective.IsEndDateNull is TRUE too! In any case, Case 4 takes care of it
        strStartDate = "[TEXT_NULL_START_DATE_TYPE]"
    Else
      If booLocalTime Then
        strStartDate = objTools.ConvertFromGMT(strStartDate, TimeZoneID)
      End If
  
      Select Case effective.StartDateType
        Case PCDATE_TYPE_ABSOLUTE
          strStartDate = "[TEXT_ABSOLUTE_DATE_TYPE]" & " " & strStartDate
        Case PCDATE_TYPE_SUBSCRIPTION
          strStartDate = effective.StartOffset & " " & "[TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE]"
        Case PCDATE_TYPE_BILLCYCLE
          strStartDate = "[TEXT_BILLINGCYCLE_DATE_TYPE]" & " " & strStartDate
        Case PCDATE_TYPE_NULL
          effective.SetStartDateNull
          strStartDate = "[TEXT_NULL_START_DATE_TYPE]"
      End Select
    End If
    
    'End of Effective Date logic
      
      m_objXMLString.Concat "<rateSchedule>" & vbNewLine
      m_objXMLString.Concat "<PriceListName>" & vbNewLine
      If Len(rs.GetPriceList.Name) Then
        m_objXMLString.Concat server.HTMLEncode(rs.GetPriceList.Name)
      Else
        If Not rs.GetPriceList.Shareable Then
          m_objXMLString.Concat "[TEXT_PERSONAL_RATE]"
        End If
      End If
      m_objXMLString.Concat "</PriceListName>" & vbNewLine
      m_objXMLString.Concat "<name>" & server.HTMLEncode(rs.Description) & " - " & "[TEXT_RATES_COLUMN_START_DATE]" & ": " & strStartDate & " - " & "[TEXT_RATES_COLUMN_END_DATE]" & ": " & strEndDate & "</name>" & vbNewLine
                                          
      WriteMessage "Loading:  " & rs.GetPriceList.Name & ":  " & strStartDate & " - " & strEndDate & "..."
      
      Set rule = rs.RuleSet
                  
      Set propset = rule.WriteToSet
      
      If LCase(ptd.Name) = "metratech.com/calendar" Then
        If booCalendar Then
          Dim CalendarID As IXMLDOMElement
          Dim XML As New DOMDocument
          XML.loadXML propset.WriteToBuffer
          Set CalendarID = XML.selectSingleNode("configdata/default_actions/action/prop_value")
          
          'Test to see if this calendar is configured
          If CalendarID Is Nothing Then
            ruleBuffer = ""
            ruleBuffer = ruleBuffer & "<Calendar><name>[TEXT_RATES_CALENDAR_NOT_CONFIGURED]</name><description></description></Calendar>"
          Else
            ' If this is the first time we try to display calendar properties, get the rowset
            If m_objCalendarRowset Is Nothing Then
              Dim pc As New MTProductCatalog
              Set m_objCalendarRowset = pc.GetCalendarsAsRowset
            End If
          
            'Iterate thru the rowset until we find the calendar we want
            m_objCalendarRowset.MoveFirst
            While Not CLng(m_objCalendarRowset.Value("id_prop")) = CLng(CalendarID.Text) And Not m_objCalendarRowset.EOF
            '  Looking for calendar
              m_objCalendarRowset.MoveNext
            Wend
          
            ruleBuffer = ""
            ruleBuffer = ruleBuffer & "<Calendar>" & vbNewLine
            ruleBuffer = ruleBuffer & "<name>" & m_objCalendarRowset.Value("nm_name") & "</name>" & vbNewLine
            ruleBuffer = ruleBuffer & "<description>" & m_objCalendarRowset.Value("nm_desc") & "</description>" & vbNewLine
            ruleBuffer = ruleBuffer & "</Calendar>" & vbNewLine
          End If
        Else
          ruleBuffer = "" ' don't display calendar in this case
        End If
      Else
        ruleBuffer = propset.WriteToBuffer
        ruleBuffer = Replace(ruleBuffer, "<?xml version=""1.0"" encoding=""UTF-8""?>", "")
        ruleBuffer = Replace(ruleBuffer, vbLf, vbNewLine)
      End If
            
      'Massage the buffer
      TRACE "LoadXML", "rates.cls", "GetRateSchedules", LOG_DEBUG
      Call objXMLDoc.loadXML(ruleBuffer)
      
      Set objConfigDataNode = objXMLDoc.selectSingleNode("/configdata")
      Set objConstraintSetList = objXMLDoc.selectNodes("/configdata/constraint_set")
      
      'Get the length of the list
      intLen = objConstraintSetList.Length
      
      'For each objConstraintSet, make sure all optional properties exist
      'For Each objConstraintSetNode In objConstraintSetList
      For i = 0 To intLen - 1
      
        Set objConstraintSetNode = objConstraintSetList.item(i)
        Set objNewConstraintSetNode = objXMLDoc.createElement("constraint_set")
        Set objActionsNode = objXMLDoc.createElement("actions")
        
        ''''''''''''''''''''''''''''''''''
        'Handle the actions
        For Each objAction In ptd.ActionMetaData
          Set objConstraintNode = objConstraintSetNode.selectSingleNode("actions/action[prop_name = '" & objAction.PropertyName & "']")
          
          'If the node doesn't exist, add it
          If objConstraintNode Is Nothing Then
            Set objConstraintNode = objXMLDoc.createElement("action")
            Set objPropNameNode = objXMLDoc.createElement("prop_name")
            Set objPropValueNode = objXMLDoc.createElement("prop_value")
            
            objPropNameNode.Text = objAction.PropertyName
            objPropValueNode.Text = ""
            
            Call objConstraintNode.appendChild(objPropNameNode)
            Call objConstraintNode.appendChild(objPropValueNode)
            
            Call objActionsNode.appendChild(objConstraintNode)
          'Otherwise, add a clone
          Else
            Call objActionsNode.appendChild(objConstraintNode.cloneNode(True))
          End If
        Next
        
        ''''''''''''''''''''''''''''''''''
        
        Call objNewConstraintSetNode.appendChild(objActionsNode)
          
        ''''''''''''''''''''''''''''''''''
        'Handle the conditions
        For Each objCondition In ptd.ConditionMetaData
          Set objConstraintNode = objConstraintSetNode.selectSingleNode("constraint[prop_name = '" & objCondition.PropertyName & "']")
          
          'If the node doesn't exist, add it
          If objConstraintNode Is Nothing Then
            Set objConstraintNode = objXMLDoc.createElement("constraint")
            Set objPropNameNode = objXMLDoc.createElement("prop_name")
            Set objPropValueNode = objXMLDoc.createElement("prop_value")
            
            objPropNameNode.Text = objCondition.PropertyName
            objPropValueNode.Text = ""
            
            Call objConstraintNode.appendChild(objPropNameNode)
            Call objConstraintNode.appendChild(objPropValueNode)
            
            Call objNewConstraintSetNode.appendChild(objConstraintNode)
          'Otherwise, add a clone
          Else
            Call objNewConstraintSetNode.appendChild(objConstraintNode.cloneNode(True))
          End If
        Next
        
        'Remove the original, and append the new
        Call objConfigDataNode.RemoveChild(objConstraintSetNode)
        Call objConfigDataNode.appendChild(objNewConstraintSetNode)
      Next
      
      ruleBuffer = objXMLDoc.XML
      
      ''''
      ' This code will localize unique property names with the display name if booLocalize = TRUE
      ''''
      If booLocalize Then
        
        ' Localize Property names
        Dim table As MTParamTableDefinition
        Set table = rs.GetParameterTable()
        Dim item As Object
        For Each item In table.ConditionMetaData()
            ruleBuffer = Replace(ruleBuffer, item.PropertyName, item.DisplayName)
        Next
      
        ' Localize Action names
        For Each item In table.ActionMetaData
          ruleBuffer = Replace(ruleBuffer, item.PropertyName, item.DisplayName)
        Next
  
        ' Localize Operators
        ruleBuffer = Replace(ruleBuffer, "less_than", "&lt;")       '<
        ruleBuffer = Replace(ruleBuffer, "greater_than", "&gt;")    '>
        ruleBuffer = Replace(ruleBuffer, "less_equal", "&lt;=")     '<=
        ruleBuffer = Replace(ruleBuffer, "greater_equal", "&gt;=")  '>=
        ruleBuffer = Replace(ruleBuffer, "not_equals", "&lt;&gt;")   '<>
        ruleBuffer = Replace(ruleBuffer, "not_equal", "&lt;&gt;")   '<>
        ruleBuffer = Replace(ruleBuffer, "equals", "=")             '=
        ruleBuffer = Replace(ruleBuffer, "equal", "=")             '=
        
      End If
      ''''
      
      
      m_objXMLString.Concat ruleBuffer & vbNewLine
      
      m_objXMLString.Concat "</rateSchedule>" & vbNewLine
    
    End If
    
    rowset.MoveNext
  Wend
  Exit Sub
ErrMgr:
  
  TRACE MTVIEWALLRATES_ERROR_05000 & GetVBErrorString(), "rates.cls", "GetRateSchedules", LOG_ERROR
End Sub

Private Sub Class_Initialize()
    Set m_objXMLString = New cStringConcat
    
    ' Open a reference of Metratech.MTEnumConfig, so the Product Catalog method  RateSchedule.RuleSet() does not create one from scrath each time.
    ' Metratech.MTEnumConfig is a singleton. This is 100% usefull is not Metratech.MTEnumConfig has been created
    Set m_objEnumConfig = CreateObject("Metratech.MTEnumConfig")
    
End Sub
