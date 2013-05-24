VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 2  'RequiresTransaction
END
Attribute VB_Name = "MTGreatPlainsReader"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Implements IMTARReader

Private Function IMTARReader_CanDeleteAdjustments(ByVal doc As String, ByVal configState As Variant) As String
   IMTARReader_CanDeleteAdjustments = CanDeleteDocuments(doc, configState)
End Function

Private Function IMTARReader_CanDeleteBatches(ByVal doc As String, ByVal configState As Variant) As String
    Dim oXML As DOMDocument40
    Dim oXSL As DOMDocument40
    Dim strXML As String
    Dim oCmdCanDeleteBatches As Object
    Dim oParam As ADODB.Parameter
    Dim oCnn As ADODB.Connection
    Dim oRsCanDeleteBatches As ADODB.Recordset
    Dim strXMLOut As String
    
    On Error GoTo errorhandler
    
    Set oXML = New MSXML2.DOMDocument40
    Set oXSL = New MSXML2.DOMDocument40
    
    oXML.loadXML doc
    oXSL.Load configState.XSLPath & "CanDeleteBatchPre.xsl"
    strXML = oXML.transformNode(oXSL)

    Set oCnn = New ADODB.Connection
    oCnn.CursorLocation = adUseClient
    oCnn.Mode = adModeRead
    oCnn.Open GetStoredProcedureConnectionStringFromDocument(oXML, configState)

    Set oCmdCanDeleteBatches = New ADODB.Command
    oCmdCanDeleteBatches.CommandType = adCmdStoredProc
    oCmdCanDeleteBatches.CommandText = "MT_Can_DeleteBatch"
    Set oCmdCanDeleteBatches.ActiveConnection = oCnn
  
    Set oParam = New ADODB.Parameter
    With oParam
         .Name = "BatchData"
         .Type = adLongVarChar
         .Size = Len(strXML)
         .Direction = adParamInput
         .Value = strXML
    End With
    oCmdCanDeleteBatches.Parameters.Append oParam
    
    TRACE "Executing eConnect stored procedure with connection string[" & oCnn.ConnectionString & "]", "MTGreatPlainsReader", "IMTARReader_CanDeleteBatches"
    TRACE "eConnect Document[" & vbNewLine & strXML & vbNewLine & "]", "MTGreatPlainsReader", "IMTARReader_CanDeleteBatches"
    Set oRsCanDeleteBatches = oCmdCanDeleteBatches.Execute
    oRsCanDeleteBatches.ActiveConnection = Nothing

    Set oCmdCanDeleteBatches = Nothing
    
    oRsCanDeleteBatches.Save oXML, adPersistXML
    oXSL.Load configState.XSLPath & "RsToXML.xsl"
    oXSL.selectSingleNode("//*[@name = 'ARDocumentType']").Attributes.Item(0).Text = "CanDeleteBatch"
    
    strXMLOut = oXML.transformNode(oXSL)
    IMTARReader_CanDeleteBatches = strXMLOut

    Set oXML = Nothing
    Set oXSL = Nothing
 
    oRsCanDeleteBatches.Close
    Set oRsCanDeleteBatches = Nothing

    oCnn.Close
    Set oCnn = Nothing
    Exit Function
errorhandler:
    Err.Raise Err.Number, Err.Source, FormatErrorToXML(Err.Description)
End Function

Private Function IMTARReader_CanDeleteInvoices(ByVal doc As String, ByVal configState As Variant) As String
   IMTARReader_CanDeleteInvoices = CanDeleteDocuments(doc, configState)
End Function

Private Function IMTARReader_CanDeletePayments(ByVal doc As String, ByVal configState As Variant) As String
   IMTARReader_CanDeletePayments = CanDeleteDocuments(doc, configState)
End Function
Private Function CanDeleteDocuments(ByVal doc As String, ByVal configState As Variant) As String
    Dim oXML As DOMDocument40
    Dim oXSL As DOMDocument40
    Dim strXML As String
    Dim oCmdCanDeleteDocuments As ADODB.Command
    Dim oParam As ADODB.Parameter
    Dim oCnn As ADODB.Connection
    Dim oRsCanDeleteDocuments As ADODB.Recordset
    Dim strXMLOut As String
    
    
    On Error GoTo errorhandler
    
    Set oXML = New MSXML2.DOMDocument40
    Set oXSL = New MSXML2.DOMDocument40
    
    oXML.loadXML doc
    oXSL.Load configState.XSLPath & "CanDeleteDocumentPre.xsl"
    strXML = oXML.transformNode(oXSL)
    
    Set oCnn = New ADODB.Connection
    oCnn.CursorLocation = adUseClient
    oCnn.Mode = adModeRead
    oCnn.Open GetStoredProcedureConnectionStringFromDocument(oXML, configState)

    Set oCmdCanDeleteDocuments = New ADODB.Command
    oCmdCanDeleteDocuments.CommandType = adCmdStoredProc
    oCmdCanDeleteDocuments.CommandText = "MT_Can_DeleteDocument"
    Set oCmdCanDeleteDocuments.ActiveConnection = oCnn
        
    Set oParam = New ADODB.Parameter
    With oParam
         .Name = "DocumentData"
         .Type = adLongVarChar
         .Size = Len(strXML)
         .Direction = adParamInput
         .Value = strXML
    End With
    oCmdCanDeleteDocuments.Parameters.Append oParam
        
    TRACE "Executing eConnect stored procedure with connection string[" & oCnn.ConnectionString & "]", "MTGreatPlainsReader", "CanDeleteDocuments"
    TRACE "eConnect Document[" & vbNewLine & strXML & vbNewLine & "]", "MTGreatPlainsReader", "CanDeleteDocuments"
    Set oRsCanDeleteDocuments = oCmdCanDeleteDocuments.Execute
    oRsCanDeleteDocuments.ActiveConnection = Nothing

    Set oCmdCanDeleteDocuments = Nothing
    
    oRsCanDeleteDocuments.Save oXML, adPersistXML
    oXSL.Load configState.XSLPath & "CanDeleteDocumentPost.xsl"
    
    strXMLOut = oXML.transformNode(oXSL)
    
    CanDeleteDocuments = strXMLOut

    Set oXML = Nothing
    Set oXSL = Nothing
 
    oRsCanDeleteDocuments.Close
    Set oRsCanDeleteDocuments = Nothing

    oCnn.Close
    Set oCnn = Nothing
    Exit Function
errorhandler:
    Err.Raise Err.Number, Err.Source, FormatErrorToXML(Err.Description)
End Function

Private Function IMTARReader_GetAccountStatusChanges(ByVal configState As Variant) As String
    Dim oXML As MSXML2.DOMDocument40
    Dim oXSL As MSXML2.DOMDocument40
    Dim strXML As String
    Dim oCmdAccountStatus As ADODB.Command
    Dim oCnn As ADODB.Connection
    Dim oRsAccountStatus As ADODB.Recordset
    Dim strXMLOut As String
   
    On Error GoTo errorhandler
    
    Set oXML = New MSXML2.DOMDocument40
    Set oXSL = New MSXML2.DOMDocument40

    Set oCnn = New ADODB.Connection
    oCnn.CursorLocation = adUseClient
    oCnn.Mode = adModeRead
    oCnn.Open GetStoredProcedureConnectionString(configState.BOConnectionString)

    Set oCmdAccountStatus = New ADODB.Command
    oCmdAccountStatus.CommandType = adCmdStoredProc
    oCmdAccountStatus.CommandText = "MT_Get_AccountStatusChanges"
    Set oCmdAccountStatus.ActiveConnection = oCnn
        
    Set oRsAccountStatus = oCmdAccountStatus.Execute
    oRsAccountStatus.ActiveConnection = Nothing

    Set oCmdAccountStatus = Nothing

    oRsAccountStatus.Save oXML, adPersistXML
    oXSL.Load configState.XSLPath & "RsToXML.xsl"
    oXSL.selectSingleNode("//*[@name = 'ARDocumentType']").Attributes.Item(0).Text = "GetAccountStatusChange"
    
    strXMLOut = oXML.transformNode(oXSL)
    
    IMTARReader_GetAccountStatusChanges = strXMLOut

    Set oXML = Nothing
    Set oXSL = Nothing
 
    oRsAccountStatus.Close
    Set oRsAccountStatus = Nothing

    oCnn.Close
    Set oCnn = Nothing
    Exit Function
errorhandler:
    Err.Raise Err.Number, Err.Source, FormatErrorToXML(Err.Description)
End Function

Private Function IMTARReader_GetAgingConfiguration(ByVal configState As Variant) As String
    Dim oXML As MSXML2.DOMDocument40
    Dim oXMLResponse As MSXML2.DOMDocument40
    Dim oXSL As MSXML2.DOMDocument40
    Dim strXML As String
    Dim oCmdBalances As ADODB.Command
    Dim oCnn As ADODB.Connection
    Dim oRsBalances As ADODB.Recordset
    Dim strXMLOut As String
    
    On Error GoTo errorhandler
    
    Dim countMinusOne As Integer
    Dim index         As Integer

    'Get configuration for each operating company
    countMinusOne = configState.ConnectionStringCount() - 1

    For index = 0 To countMinusOne
        configState.GetNamespaceString (index)
    
        Set oXML = New MSXML2.DOMDocument40
        Set oXMLResponse = New MSXML2.DOMDocument40
        Set oXSL = New MSXML2.DOMDocument40
    
        Set oCnn = New ADODB.Connection
        oCnn.CursorLocation = adUseClient
        oCnn.Mode = adModeRead
        oCnn.Open GetStoredProcedureConnectionString(configState.GetConnectionString(configState.GetNamespaceString(index)))
    
        Set oCmdBalances = New ADODB.Command
        oCmdBalances.CommandType = adCmdStoredProc
        oCmdBalances.CommandText = "MT_Get_AgingConfiguration"
        Set oCmdBalances.ActiveConnection = oCnn
            
        TRACE "Executing eConnect stored procedure MT_Get_AgingConfiguration with connection string[" & oCnn.ConnectionString & "]", "MTGreatPlainsReader", "IMTARReader_GetAgingConfiguration"
        Set oRsBalances = oCmdBalances.Execute
        oRsBalances.ActiveConnection = Nothing
    
        Set oCmdBalances = Nothing
    
        oRsBalances.Save oXML, adPersistXML
        oXSL.Load configState.XSLPath & "AgingConfiguration.xsl"
    
        oXML.transformNodeToObject oXSL, oXMLResponse
        
        ' We must now create an attribute for the externale namespace/operating company and set its value
        Dim oNodeExternalNamespace As MSXML2.IXMLDOMNode
        Set oNodeExternalNamespace = oXSL.createAttribute("ExtNamespace")
        oNodeExternalNamespace.nodeValue = configState.GetNamespaceString(index)
        oXMLResponse.selectSingleNode("//ARDocuments").Attributes.setNamedItem oNodeExternalNamespace

        strXMLOut = strXMLOut & oXMLResponse.xml
    Next
 
    
    IMTARReader_GetAgingConfiguration = strXMLOut
 
    Set oXML = Nothing
    Set oXSL = Nothing

    oRsBalances.Close
    Set oRsBalances = Nothing

    oCnn.Close
    Set oCnn = Nothing
    Exit Function
errorhandler:
    Err.Raise Err.Number, Err.Source, FormatErrorToXML(Err.Description)
End Function
Private Function IMTARReader_GetBalances(ByVal doc As String, ByVal configState As Variant) As String
    Dim oXML As DOMDocument40
    Dim oXSL As DOMDocument40
    Dim oInputXML As DOMDocument40
    Dim strXML As String
    Dim oCmdBalances As ADODB.Command
    Dim oParam As ADODB.Parameter
    Dim oCnn As ADODB.Connection
    Dim oRsBalances As ADODB.Recordset
    Dim strXMLOut As String
        
    On Error GoTo errorhandler
    
    Set oXSL = New MSXML2.DOMDocument40
    Set oInputXML = New MSXML2.DOMDocument40
    
    oInputXML.loadXML (doc)
    If oInputXML.parseError.ErrorCode <> 0 Then
        Dim msg As String
        msg = "Error parsing input document (" + Str(oInputXML.parseError.Line) + "): "
        msg = msg + oInputXML.parseError.reason
        Err.Raise oInputXML.parseError.ErrorCode, "IMTARReader_GetBalances", msg
    End If
    
    oXSL.Load configState.XSLPath & "ChangeBalanceFormat.xsl"
    strXML = oInputXML.transformNode(oXSL)
    
    Set oCnn = New ADODB.Connection
    oCnn.CursorLocation = adUseClient
    oCnn.Mode = adModeRead
    oCnn.Open GetStoredProcedureConnectionStringFromDocument(oInputXML, configState)

    Set oCmdBalances = New ADODB.Command
    oCmdBalances.CommandType = adCmdStoredProc
    oCmdBalances.CommandText = "MT_Get_Balances"
    Set oCmdBalances.ActiveConnection = oCnn
        
    Set oParam = New ADODB.Parameter
    With oParam
         .Name = "CustomerData"
         .Type = adLongVarChar
         .Size = Len(strXML)
         .Direction = adParamInput
         .Value = strXML
    End With
    oCmdBalances.Parameters.Append oParam
        
    TRACE "Executing eConnect stored procedure with connection string[" & oCnn.ConnectionString & "]", "MTGreatPlainsReader", "GetBalances"
    TRACE "eConnect Document[" & vbNewLine & strXML & vbNewLine & "]", "MTGreatPlainsReader", "GetBalances"
    Set oRsBalances = oCmdBalances.Execute
    oRsBalances.ActiveConnection = Nothing

    Set oCmdBalances = Nothing

    Set oXML = New MSXML2.DOMDocument40

    oRsBalances.Save oXML, adPersistXML
    oXSL.Load configState.XSLPath & "RsToXML.xsl"
    oXSL.selectSingleNode("//*[@name = 'ARDocumentType']").Attributes.Item(0).Text = "Balance"
    
    strXMLOut = oXML.transformNode(oXSL)
    
    IMTARReader_GetBalances = strXMLOut
 
    Set oXML = Nothing
    Set oXSL = Nothing

    oRsBalances.Close
    Set oRsBalances = Nothing

    oCnn.Close
    Set oCnn = Nothing
    Exit Function
errorhandler:
    Err.Raise Err.Number, Err.Source, FormatErrorToXML(Err.Description)
End Function
Private Function IMTARReader_GetBalanceDetails(ByVal doc As String, ByVal configState As Variant) As String
    Dim oXML As MSXML2.DOMDocument40
    Dim oXMLDoc As MSXML2.DOMDocument40
    Dim oXSL As Object
    Dim strXML As String
    Dim oCmdBalances As ADODB.Command
    Dim oParam As ADODB.Parameter
    Dim oCnn As ADODB.Connection
    Dim oRsBalances As ADODB.Recordset
    Dim strXMLOut As String
    
    On Error GoTo errorhandler
 
    Set oXML = New MSXML2.DOMDocument40
    Set oXMLDoc = New MSXML2.DOMDocument40
    Set oXSL = New MSXML2.DOMDocument40
    
    oXMLDoc.loadXML doc
    oXSL.Load configState.XSLPath & "ChangeBalanceFormat1.xsl"
    strXML = oXMLDoc.transformNode(oXSL)
    
    Set oCnn = New ADODB.Connection
    oCnn.CursorLocation = adUseClient
    oCnn.Mode = adModeRead
    oCnn.Open GetStoredProcedureConnectionStringFromDocument(oXMLDoc, configState)

    Set oCmdBalances = New ADODB.Command
    oCmdBalances.CommandType = adCmdStoredProc
    oCmdBalances.CommandText = "MT_Get_BalanceDetails"
    Set oCmdBalances.ActiveConnection = oCnn

    Set oParam = New ADODB.Parameter
    With oParam
         .Name = "CustomerData"
         .Type = adLongVarChar
         .Size = Len(strXML)
         .Direction = adParamInput
         .Value = strXML
    End With
    oCmdBalances.Parameters.Append oParam
        
    TRACE "Executing eConnect stored procedure with connection string[" & oCnn.ConnectionString & "]", "MTGreatPlainsReader", "GetBalanceDetails"
    TRACE "eConnect Document[" & vbNewLine & strXML & vbNewLine & "]", "MTGreatPlainsReader", "GetBalanceDetails"
    Set oRsBalances = oCmdBalances.Execute
    Set oRsBalances.ActiveConnection = Nothing

    Set oCmdBalances = Nothing
    
    oRsBalances.Save oXML, adPersistXML
    oXSL.Load configState.XSLPath & "RsToXML.xsl"
    oXSL.selectSingleNode("//*[@name = 'ARDocumentType']").Attributes.Item(0).Text = "BalanceDetails"
    
    oXMLDoc.loadXML oXML.transformNode(oXSL)
    oXSL.Load configState.XSLPath & "ChangeBalanceDetailFormat.xsl"
       
    strXMLOut = oXMLDoc.transformNode(oXSL)
    
    IMTARReader_GetBalanceDetails = strXMLOut
 
    Set oXSL = Nothing
    Set oXML = Nothing
    Set oXMLDoc = Nothing

    oRsBalances.Close
    Set oRsBalances = Nothing

    oCnn.Close
    Set oCnn = Nothing
    Exit Function
errorhandler:
    Err.Raise Err.Number, Err.Source, FormatErrorToXML(Err.Description)
End Function
'This is a temporary code to make it run from VBScript
Public Function GetAgingConfiguration(ByVal configState As Variant) As String
    GetAgingConfiguration = IMTARReader_GetAgingConfiguration(configState)
End Function
Public Function GetBalanceDetails(ByVal doc As String, ByVal configState As Variant) As String
    GetBalanceDetails = IMTARReader_GetBalanceDetails(doc, configState)
End Function
Public Function GetBalances(ByVal doc As String, ByVal configState As Variant) As String
    GetBalances = IMTARReader_GetBalances(doc, configState)
End Function
Public Function CanDeleteAdjustments(ByVal doc As String, ByVal configState As Variant) As String
    CanDeleteAdjustments = IMTARReader_CanDeleteAdjustments(doc, configState)
End Function
Public Function CanDeleteInvoices(ByVal doc As String, ByVal configState As Variant) As String
    CanDeleteInvoices = IMTARReader_CanDeleteInvoices(doc, configState)
End Function
Public Function CanDeletePayments(ByVal doc As String, ByVal configState As Variant) As String
    CanDeletePayments = IMTARReader_CanDeletePayments(doc, configState)
End Function
Public Function CanDeleteBatches(ByVal doc As String, ByVal configState As Variant) As String
    CanDeleteBatches = IMTARReader_CanDeleteBatches(doc, configState)
End Function
Public Function GetAccountStatusChanges(ByVal configState As Variant) As String
    GetAccountStatusChanges = IMTARReader_GetAccountStatusChanges(configState)
End Function
Public Function AsIMTARReader() As IMTARReader
    Set AsIMTARReader = Me
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
