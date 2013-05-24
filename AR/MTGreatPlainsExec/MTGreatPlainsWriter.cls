VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 2  'RequiresTransaction
END
Attribute VB_Name = "MTGreatPlainsWriter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Implements IMTARWriter

Private Sub IMTARWriter_ApplyCredits(ByVal configState As Variant)
    On Error GoTo errorhandler

    Dim countMinusOne As Integer
    Dim index         As Integer

    countMinusOne = configState.ConnectionStringCount() - 1

    For index = 0 To countMinusOne
      ApplyCreditsPerCustomer configState, configState.GetNamespaceString(index)
    Next

    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Private Sub IMTARWriter_CreateAdjustments(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "CreateAdjustments.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_CreateInvoices(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "CreateInvoices.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_CreateInvoicesWithTaxDetails(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "CreateInvoicesWithTaxDetails.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_CreateOrUpdateAccounts(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "Customer.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_CreateOrUpdateSalesPersons(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "SalesPerson.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_CreateOrUpdateTerritories(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "Territory.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_CreatePayments(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "CreatePayments.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_DeleteAccountStatusChanges(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "DeleteAccountStatusChanges.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_DeleteAdjustments(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "DeleteAdjustments.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_DeleteBatches(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "DeleteBatches.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_DeleteInvoices(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "DeleteInvoices.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_DeletePayments(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "DeletePayments.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Function IMTARWriter_MoveBalances(ByVal doc As String, ByVal configState As Variant) As String
    Dim oInputDoc As MSXML2.DOMDocument40
    Dim oCmdMoveBalances As ADODB.Command
    Dim oParam1, oParam2, oParam3, oParam4, oParam5, oParam6 As ADODB.Parameter
    Dim oCnn As ADODB.Connection
    Dim oRsMoveBalances As ADODB.Recordset
    Dim oXMLReturnDoc As MSXML2.DOMDocument40
    Dim oXMLDoc As MSXML2.DOMDocument40
    Dim oXML As MSXML2.DOMDocument40
    Dim oXSL As MSXML2.DOMDocument40
    Dim oNodes As MSXML2.IXMLDOMNodeList
    Dim oNode As MSXML2.IXMLDOMNode
    Dim oDocuments, oDocument, oAdjNode As MSXML2.IXMLDOMNode
    Dim oResponseNode, oChildNode As MSXML2.IXMLDOMNode
    Dim strExtNamespace As String
    
    On Error GoTo errorhandler
    
    Set oInputDoc = New MSXML2.DOMDocument40
    oInputDoc.loadXML (doc)
    If oInputDoc.parseError.ErrorCode <> 0 Then
        Dim msg As String
        msg = "Error parsing input document (" + Str(oInputDoc.parseError.Line) + "): "
        msg = msg + oInputDoc.parseError.reason
        Err.Raise oInputDoc.parseError.ErrorCode, "IMTARWriter_MoveBalances", msg
    End If
    
    strExtNamespace = GetExternalNamespaceFromDocument(oInputDoc)
    
    Set oXML = New MSXML2.DOMDocument40
    Set oXSL = New MSXML2.DOMDocument40
    Set oXMLDoc = New MSXML2.DOMDocument40
    Set oXMLReturnDoc = New MSXML2.DOMDocument40
   
    Set oNodes = oInputDoc.selectNodes("//MoveBalance")
    
    ' Need to get the namespace out of the input document (doc) and use it here???
    oXMLReturnDoc.loadXML "<ARDocuments ExtNamespace='" & strExtNamespace & "'></ARDocuments>"
    Set oDocuments = oXMLReturnDoc.selectSingleNode("//ARDocuments")

    If oNodes.length = 0 Then
       Err.Raise 8, "MoveBalances", FormatErrorToXML("No Records to Move", "30013")
    Else
      Set oCnn = New ADODB.Connection
      oCnn.CursorLocation = adUseClient
      oCnn.Mode = adModeRead
      oCnn.Open GetStoredProcedureConnectionStringFromDocument(oInputDoc, configState)

       ' loop over all MoveBalance nodes
       For Each oNode In oNodes

           ' before moving documents, apply credits for "from account" to minimize number of documents to move
           ' Need to get the namespace out of the input document (doc) and use it here???
           ApplyCreditsPerCustomer configState, GetExternalNamespaceFromDocument(oInputDoc), oNode.selectSingleNode("FromExtAccountID").Text

           Set oCmdMoveBalances = New ADODB.Command
           oCmdMoveBalances.CommandType = adCmdStoredProc
           oCmdMoveBalances.CommandText = "MT_Get_MoveBalanceDetails"
           Set oCmdMoveBalances.ActiveConnection = oCnn

           Set oParam1 = New ADODB.Parameter
           With oParam1
                    .Name = "FromCustNo"
                    .Type = adVarChar
                    .Direction = adParamInput
                    .Size = 15
                    .Value = oNode.selectSingleNode("FromExtAccountID").Text
           End With
           oCmdMoveBalances.Parameters.Append oParam1
           
           Set oParam2 = New ADODB.Parameter
           With oParam2
                    .Name = "ToCustNo"
                    .Type = adVarChar
                    .Direction = adParamInput
                    .Size = 15
                    .Value = oNode.selectSingleNode("ToExtAccountID").Text
           End With
           oCmdMoveBalances.Parameters.Append oParam2

           Set oParam3 = New ADODB.Parameter
           With oParam3
                    .Name = "BatchID"
                    .Type = adVarChar
                    .Direction = adParamInput
                    .Size = 15
                    .Value = oNode.selectSingleNode("BatchID").Text
           End With
           oCmdMoveBalances.Parameters.Append oParam3

           Set oParam4 = New ADODB.Parameter
           With oParam4
                    .Name = "Prefix"
                    .Type = adVarChar
                    .Direction = adParamInput
                    .Size = 5
                    .Value = configState.MoveBalancePrefix
           End With
           oCmdMoveBalances.Parameters.Append oParam4

           Set oParam5 = New ADODB.Parameter
           With oParam5
                    .Name = "Seperator"
                    .Type = adVarChar
                    .Direction = adParamInput
                    .Size = 1
                    .Value = configState.MoveBalanceSeperator
           End With
           oCmdMoveBalances.Parameters.Append oParam5

           Set oParam6 = New ADODB.Parameter
           With oParam6
                    .Name = "MoveDate"
                    .Type = adDBTimeStamp
                    .Direction = adParamInput
                    .Size = 8
                    .Value = Left(Trim(oNode.selectSingleNode("MoveDate").Text), 10)
           End With
           oCmdMoveBalances.Parameters.Append oParam6
           
           ' call sproc MT_Get_MoveBalanceDetails to generate the necessary transactions
           Set oRsMoveBalances = oCmdMoveBalances.Execute
           oRsMoveBalances.ActiveConnection = Nothing

           Set oCmdMoveBalances = Nothing

           ' store necessary transactions in oXML
           oRsMoveBalances.Save oXML, adPersistXML
           oXSL.Load configState.XSLPath & "RsToXML.xsl"
           oXSL.selectSingleNode("//*[@name = 'ARDocumentType']").Attributes.Item(0).Text = "MoveBalance"
                               
           oXMLDoc.loadXML oXML.transformNode(oXSL)
           
           ' We must now create an attribute for the externale namespace/operating company and set its value
           Dim oNodeExternalNamespace As MSXML2.IXMLDOMNode
           Set oNodeExternalNamespace = oXSL.createAttribute("ExtNamespace")
           oNodeExternalNamespace.nodeValue = strExtNamespace
           oXMLDoc.selectSingleNode("//ARDocuments").Attributes.setNamedItem oNodeExternalNamespace
           
           ' if there is a balance to move
           If oXMLDoc.selectSingleNode("//ARDocuments").childNodes.length > 0 Then
                ' call eConnect to create the transactions
                TransformAndExecute "MoveBalances.xsl", oXMLDoc.xml, configState
                
                ' append MoveBalanceResponse node to oXMLReturnDoc with moved balance
                Set oDocument = oXMLReturnDoc.createNode(1, "ARDocument", "")
                oDocuments.appendChild oDocument
                Set oResponseNode = oXMLReturnDoc.createNode(1, "MoveBalanceResponse", "")
                oDocument.appendChild oResponseNode
                Set oChildNode = oXMLReturnDoc.createNode(1, "FromExtAccountID", "")
                oChildNode.nodeTypedValue = oNode.selectSingleNode("FromExtAccountID").Text
                oResponseNode.appendChild oChildNode
                Set oChildNode = oXMLReturnDoc.createNode(1, "ToExtAccountID", "")
                oChildNode.nodeTypedValue = oNode.selectSingleNode("ToExtAccountID").Text
                oResponseNode.appendChild oChildNode
                Set oChildNode = oXMLReturnDoc.createNode(1, "MovedBalance", "")
                Set oAdjNode = oXMLDoc.selectSingleNode("//MoveBalance[CUSTNMBR = '" & oNode.selectSingleNode("FromExtAccountID").Text & "']")
                If oAdjNode.selectSingleNode("RMDTYPAL").Text = 3 Then
                   oChildNode.nodeTypedValue = "-" & oAdjNode.selectSingleNode("CURTRXAM").Text
                ElseIf oAdjNode.selectSingleNode("RMDTYPAL").Text = 7 Then
                   oChildNode.nodeTypedValue = oAdjNode.selectSingleNode("CURTRXAM").Text
                End If
                oResponseNode.appendChild oChildNode
           Else
                ' there is no balance to move
                ' append MoveBalanceResponse node to oXMLReturnDoc with 0 balance moved
                Set oDocument = oXMLReturnDoc.createNode(1, "ARDocument", "")
                oDocuments.appendChild oDocument
                Set oResponseNode = oXMLReturnDoc.createNode(1, "MoveBalanceResponse", "")
                oDocument.appendChild oResponseNode
                Set oChildNode = oXMLReturnDoc.createNode(1, "FromExtAccountID", "")
                oChildNode.nodeTypedValue = oNode.selectSingleNode("FromExtAccountID").Text
                oResponseNode.appendChild oChildNode
                Set oChildNode = oXMLReturnDoc.createNode(1, "ToExtAccountID", "")
                oChildNode.nodeTypedValue = oNode.selectSingleNode("ToExtAccountID").Text
                oResponseNode.appendChild oChildNode
                Set oChildNode = oXMLReturnDoc.createNode(1, "MovedBalance", "")
                oChildNode.nodeTypedValue = "0"
                oResponseNode.appendChild oChildNode
           End If

           oRsMoveBalances.Close
           Set oRsMoveBalances = Nothing
       Next
    End If
           
    IMTARWriter_MoveBalances = oXMLReturnDoc.xml

    oCnn.Close
    Set oCnn = Nothing
    Exit Function
errorhandler:
    Err.Raise Err.Number, Err.Source, FormatErrorToXML(Err.Description)
End Function

Private Sub IMTARWriter_RunAging(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "RunAging.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_UpdateAccountStatus(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "UpdateCustomerStatus.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub IMTARWriter_UpdateTerritoryManagers(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    TransformAndExecute "UpdateTerritoryManagers.xsl", doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub

Private Sub ApplyCreditsPerCustomer(ByVal configState As Variant, nameSpace As String, Optional strCustCode As Variant)
    Dim oCmdCredits, oCmdDebits As ADODB.Command
    Dim oParam As ADODB.Parameter
    Dim oCnn As ADODB.Connection
    Dim oRsCredits, oRsDebits As ADODB.Recordset
    Dim TotalDebits As Double
    Dim oXMLDoc As MSXML2.DOMDocument40
    Dim oNode As Object
    Dim oChildNode As Object
       
    On Error GoTo errorhandler
    
    ' get all open credits (payments and credit memos)

    Set oCnn = New ADODB.Connection
    oCnn.CursorLocation = adUseClient
    oCnn.Mode = adModeRead
    oCnn.Open GetStoredProcedureConnectionString(configState.GetConnectionString(nameSpace))

    Set oCmdCredits = New ADODB.Command
    oCmdCredits.CommandType = adCmdStoredProc
    oCmdCredits.CommandText = "MT_GetAll_OpenCredits"
    Set oCmdCredits.ActiveConnection = oCnn

    Set oRsCredits = oCmdCredits.Execute
    oRsCredits.ActiveConnection = Nothing
    
    Set oCmdCredits = Nothing

    If Not (IsMissing(strCustCode)) Then
          oRsCredits.Filter = "CUSTNMBR = '" & strCustCode & "'"
    End If
    
    ' loop over all credits and try to apply each to open debits
    Do While Not (oRsCredits.EOF)
       TotalDebits = 0
          
       ' get open debits for customer

       Set oCmdDebits = New ADODB.Command
       Set oCmdDebits.ActiveConnection = oCnn
       oCmdDebits.CommandType = adCmdStoredProc
       oCmdDebits.CommandText = "MT_GetAll_OpenDebits"
       
       Set oParam = New ADODB.Parameter
       With oParam
            .Name = "CUSTNMBR"
            .Type = adVarChar
            .Direction = adParamInput
            .Size = 17
            .Value = oRsCredits!CUSTNMBR
       End With
       
       oCmdDebits.Parameters.Append oParam
       
       Set oRsDebits = oCmdDebits.Execute
       oRsDebits.ActiveConnection = Nothing
    
       Set oCmdDebits = Nothing

       ' loop over debits (in date order)
       Do While Not (oRsDebits.EOF)
            
            'create a xml doc
            Set oXMLDoc = New MSXML2.DOMDocument40
            oXMLDoc.loadXML "<ARDocuments ExtNamespace='" + nameSpace + "'><ARDocument><ApplyCredit></ApplyCredit></ARDocument></ARDocuments>"  ' ???
            Set oNode = oXMLDoc.selectSingleNode("//ApplyCredit")
            Set oChildNode = oXMLDoc.createNode(1, "APTODCNM", "")
            oNode.appendChild oChildNode
            oChildNode.nodeTypedValue = CStr(oRsDebits!DOCNUMBR)
            Set oChildNode = oXMLDoc.createNode(1, "CUSTNMBR", "")
            oNode.appendChild oChildNode
            oChildNode.nodeTypedValue = CStr(oRsCredits!CUSTNMBR)
            
            ' amount to apply to debit
            Set oChildNode = oXMLDoc.createNode(1, "APPTOAMT", "")
            oNode.appendChild oChildNode
            
            ' if credit exceeds processed debits
            If TotalDebits + oRsDebits!CURTRXAM < oRsCredits!CURTRXAM Then
               ' apply full debit amount
               oChildNode.nodeTypedValue = CStr(CDbl(oRsDebits!CURTRXAM))
            Else
               ' apply remainder of credit
               oChildNode.nodeTypedValue = CStr(CDbl(oRsCredits!CURTRXAM - TotalDebits))
            End If
            
            Set oChildNode = oXMLDoc.createNode(1, "APFRDCNM", "")
            oNode.appendChild oChildNode
            oChildNode.nodeTypedValue = CStr(oRsCredits!DOCNUMBR)
            Set oChildNode = oXMLDoc.createNode(1, "APFRDCTY", "")
            oNode.appendChild oChildNode
            oChildNode.nodeTypedValue = CStr(oRsCredits!RMDTYPAL)
            Set oChildNode = oXMLDoc.createNode(1, "APTODCTY", "")
            oNode.appendChild oChildNode
            oChildNode.nodeTypedValue = CStr(oRsDebits!RMDTYPAL)
           
            
            ' call eConnect to apply this credit against this debit
            TransformAndExecute "ApplyCredits.xsl", oXMLDoc.xml, configState
            Set oXMLDoc = Nothing
            
            ' update debit total
            TotalDebits = TotalDebits + oRsDebits!CURTRXAM
            
            ' quit debit loop if credits are exhausted
            If TotalDebits >= oRsCredits!CURTRXAM Then
               Exit Do
            End If
            oRsDebits.MoveNext
       Loop
       oRsDebits.Close
       Set oRsDebits = Nothing
       oRsCredits.MoveNext
    Loop
        
    oRsCredits.Close
    Set oRsCredits = Nothing

    oCnn.Close
    Set oCnn = Nothing

    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, FormatErrorToXML(Err.Description)
End Sub

' transform ARDocument to eConnect document
' then calls eConnect to process
Private Sub TransformAndExecute(ByVal strFileName As String, ByVal strXMLDoc As String, ByVal configState As Variant)
    
    MTDEFAULTtLOGFileName = "logging\AR"
    TRACE "Processing Document using " & strFileName & " template.", "MTGreatPlainsWriter", "TransformAndExecute"
    
    Dim oXSLDoc As MSXML2.DOMDocument40
    Dim strXML As String
  
    Dim oInputDoc As MSXML2.DOMDocument40
    Set oInputDoc = New MSXML2.DOMDocument40
    oInputDoc.loadXML (strXMLDoc)
    If oInputDoc.parseError.ErrorCode <> 0 Then
        Dim msg As String
        msg = "Error parsing input document (" + Str(oInputDoc.parseError.Line) + "): "
        msg = msg + oInputDoc.parseError.reason
        Err.Raise oInputDoc.parseError.ErrorCode, "TransformAndExecute", msg
    End If
  
    On Error GoTo errorhandler
       
    Set oXSLDoc = New MSXML2.DOMDocument40
    oXSLDoc.Load configState.XSLPath & strFileName
    strXML = oInputDoc.transformNode(oXSLDoc)
             
    Execute_Query strXML, configState, GetConnectionStringFromDocument(oInputDoc, configState)
                
    Set oXSLDoc = Nothing
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, FormatErrorToXML(Err.Description)
End Sub

' call eConnect with an incoming document
Private Sub Execute_Query(strXMLDoc As String, configState As Variant, strConnectionString As String)
   Dim status As Boolean
   Dim ErrorState As Long
   Dim ErrorString As String
   Dim ErrorCode As Variant
   Dim OutGoingMessage As String
   Dim context As String
   Dim eConnectProcessInfoOutgoing As MSXML2.IXMLDOMNode
   Dim eConnectProcessNode As MSXML2.IXMLDOMNode
   Dim oXMLDoc As MSXML2.DOMDocument40
   
   On Error GoTo errorhandler
   
   MTDEFAULTtLOGFileName = "logging\AR"
   TRACE strXMLDoc, "MTGreatPlainsWriter", "Execute_Query"
   
   ' load up an xml doc to do some validation
   ' (Note: for performance we could avoid this one parse, if we did not validate)
   Set oXMLDoc = New MSXML2.DOMDocument40
   oXMLDoc.loadXML strXMLDoc
   
   ' check if document is an incoming doc
   Set eConnectProcessInfoOutgoing = oXMLDoc.selectSingleNode(configState.OutGoingIdentifier)
   If Not (eConnectProcessInfoOutgoing Is Nothing) Then
      If eConnectProcessInfoOutgoing.nodeTypedValue = "TRUE" Then
         Err.Raise 8, "Save", ERR_NOT_A_INCOMING_DOCUMENT
         Exit Sub
      End If
   End If
   
   Set eConnectProcessNode = oXMLDoc.selectSingleNode("//eConnect")
   
   ' check for documents to process (otherwise eConnect would return succeeded)
   If eConnectProcessNode.childNodes.length = 0 Then
      Err.Raise 8, "eConnectExecute", "Not a Valid XML Document or No Records to process"
   End If

   ' call eConnect
   Dim oExecProcs As Object
   Set oExecProcs = CreateObject(configState.eConnectObjectName)
  
   TRACE "Executing eConnect stored procedure with connection string[" & strConnectionString & "]", "MTGreatPlainsWriter", "Execute_Query"
   TRACE "eConnect Document[" & vbNewLine & strXMLDoc & vbNewLine & "]", "MTGreatPlainsWriter", "Execute_Query"
   status = oExecProcs.ExecStoredProc(strXMLDoc, strConnectionString, ErrorState, ErrorString, OutGoingMessage)
   
   If status = True Then
      TRACE "eConnect execution successful", "MTGreatPlainsWriter", "Execute_Query"
   Else
      TRACE "eConnect execution returned error", "MTGreatPlainsWriter", "Execute_Query"
      ErrorString = TranslateEconnectErrorToXML(oExecProcs.ErrorCodes, configState)
 
      Err.Raise 8, "eConnectExecute", ErrorString
   End If
   
   Set oExecProcs = Nothing
   Exit Sub

errorhandler:
   GetObjectContext.SetAbort
   Set oExecProcs = Nothing
   
   Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Private Function TranslateEconnectErrorToXML(ByVal ErrCollection As Variant, ByVal configState As Variant) As String
   Dim strFmtErr As String
   Dim strErr As Variant
   Dim iposCode, iposDesc As Integer
   Dim ictr As Integer
   Dim strCode, strDesc As String
   
   strFmtErr = "<ARDocuments><ARDocument><Errors>"
   
   If ErrCollection Is Nothing Then
    strFmtErr = strFmtErr + "<Error>" + "Internal Error: Operation did not complete but ErrorCode collection from eConnect was empty" + "</Error>"
   Else
    For Each strErr In ErrCollection
         TRACE "    eConnect error [" & strErr & "]", "MTGreatPlainsWriter", "Execute_Query"
         iposCode = InStr(1, strErr, "Error Number = ")
         iposDesc = InStr(1, strErr, "Error Description = ")
         strCode = ""
         For ictr = iposCode + 15 To Len(strErr)
             If (Not IsNumeric(Mid(strErr, ictr, 1))) Then
                Exit For
             Else
                strCode = strCode + Mid(strErr, ictr, 1)
             End If
         Next ictr
         
         If iposDesc <> 0 Then
           strErr = Mid(strErr, iposDesc + 20, Len(strErr) - iposDesc - 19)
         End If
         
         strFmtErr = strFmtErr + "<Error><Code>" + strCode + "</Code>"
         strFmtErr = strFmtErr + "<Message>" + strErr + "</Message>"
         strFmtErr = strFmtErr + "<Dump>" + strErr + "</Dump></Error>"
    Next
   End If
   
   strFmtErr = strFmtErr + "</Errors></ARDocument></ARDocuments>"
   
   TranslateEconnectErrorToXML = strFmtErr
End Function
Private Function FormatErrorToXML(ByVal ErrDesc As String, Optional ErrCode As Variant) As String
   Dim oXMLDoc As MSXML2.DOMDocument40
   Dim oNode As MSXML2.IXMLDOMNode
   On Error GoTo errorhandler
   Set oXMLDoc = New MSXML2.DOMDocument40
   oXMLDoc.loadXML ErrDesc
   Set oNode = oXMLDoc.selectSingleNode("/ARDocuments/ARDocument/Errors")
   If oNode Is Nothing Then
      If (IsMissing(ErrCode)) Then
          FormatErrorToXML = "<ARDocuments><ARDocument><Errors><Error><Code>30012</Code><Message>" & ErrDesc & "</Message></Error></Errors></ARDocument></ARDocuments>"
      Else
          FormatErrorToXML = "<ARDocuments><ARDocument><Errors><Error><Code>" & ErrCode & "</Code><Message>" & ErrDesc & "</Message></Error></Errors></ARDocument></ARDocuments>"
      End If
   Else
      FormatErrorToXML = ErrDesc
   End If
   Set oXMLDoc = Nothing
   Exit Function
errorhandler:
   Err.Raise Err.Number, Err.Source, "<ARDocuments><ARDocument><Errors><Error><Code>30012</Code><Message>" & ErrDesc & "</Message></Error></Errors></ARDocument></ARDocuments>"
End Function
'This is a temporary code to make it run from VBScript
Public Sub ApplyCredits(ByVal configState As Variant)
On Error GoTo errorhandler
    IMTARWriter_ApplyCredits configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub CreateAdjustments(ByVal doc As String, ByVal configState As Variant)
On Error GoTo errorhandler
    IMTARWriter_CreateAdjustments doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub CreateInvoices(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_CreateInvoices doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub CreateOrUpdateAccounts(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_CreateOrUpdateAccounts doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub CreateOrUpdateSalesPersons(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_CreateOrUpdateSalesPersons doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub CreateOrUpdateTerritories(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_CreateOrUpdateTerritories doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub CreatePayments(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_CreatePayments doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub DeleteBatches(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_DeleteBatches doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub DeletePayments(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_DeletePayments doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub DeleteInvoices(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_DeleteInvoices doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub DeleteAdjustments(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_DeleteAdjustments doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub DeleteAccountStatusChanges(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_DeleteAccountStatusChanges doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Function MoveBalances(ByVal doc As String, ByVal configState As Variant) As String
    On Error GoTo errorhandler
    MoveBalances = IMTARWriter_MoveBalances(doc, configState)
    Exit Function
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Function
Public Sub RunAging(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_RunAging doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub UpdateAccountStatus(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_UpdateAccountStatus doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Sub UpdateTerritoryManagers(ByVal doc As String, ByVal configState As Variant)
    On Error GoTo errorhandler
    IMTARWriter_UpdateTerritoryManagers doc, configState
    Exit Sub
errorhandler:
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Function AsIMTARWriter() As Variant
    Set AsIMTARWriter = Me
End Function
Private Function TranslateEConnectError(ByVal strErr As String)
   Dim spos As Integer
   Dim strFmtErr
   If (InStr(1, strErr, "Error Number = 3421")) Then
      strFmtErr = "Field is longer than the allowed length - "
      strErr = Replace(strErr, "ADODB.Parameter", "")
      spos = InStr(1, strErr, "Parameter = @") + 13
      strFmtErr = strFmtErr & Mid(strErr, spos, Len(strErr) + spos)
   ElseIf (InStr(1, strErr, "Error Number = 167")) Then
      strFmtErr = ""
   Else
      spos = InStr(1, strErr, "Error Description = ") + 20
      If (spos + 20 < Len(strErr)) Then
          strFmtErr = Mid(strErr, spos, Len(strErr) - spos)
      Else
          strFmtErr = strErr
      End If
   End If
   TranslateEConnectError = strFmtErr
End Function


