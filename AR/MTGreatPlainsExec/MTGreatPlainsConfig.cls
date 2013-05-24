VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTGreatPlainsConfig"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Implements IMTARConfig

Private Function IMTARConfig_Configure(Optional ByVal aInternalSystemInfo As Variant) As Variant
    Dim configState As New GPConfigState
    Dim oConfig
    Dim strPath
    Dim oXML As MSXML2.DOMDocument40
    Dim oServers As Object
    Dim oGPServer As Object
    
    On Error GoTo errorhandler
    
    Set oXML = CreateObject("Microsoft.XMLDom")
    
    Set oConfig = CreateObject("MetraTech.Rcd.1")
    oConfig.Init
    strPath = oConfig.ExtensionDir & "\AR\config\AR\MTGreatPlainsExec\GPConfig.xml"
    oXML.Load strPath
    If oXML.parseError.ErrorCode <> 0 Then
        Dim msg As String
        msg = "Error reading '" + strPath + "(" + Str(oXML.parseError.Line) + "): "
        msg = msg + oXML.parseError.reason
        Err.Raise oXML.parseError.ErrorCode, "IMTARConfig_Configure", msg
    End If
    
    Set oServers = CreateObject("MTServerAccess.MTServerAccessDataSet")
    oServers.Initialize
    
    configState.XSLPath = oConfig.ExtensionDir & "\AR\config\AR\MTGreatPlainsExec\XSLTransform\"
  
    'Get the connection string for each configured server (in the case of multiple operating companies)
    Dim sBaseConnectionString
    If oXML.selectSingleNode("//eConnectConnectionString") Is Nothing Then
      'if connection is not specified in config file, default to eConnect 7.5 for backwards compatibility
      sBaseConnectionString = "Provider=SQLOLEDB.1;Persist Security Info=False;User ID=%%USERNAME%%;Password=%%PASSWORD%%;Initial Catalog=%%DATABASENAME%%;Data Source=%%SERVERNAME%%"
    Else
      sBaseConnectionString = oXML.selectSingleNode("//eConnectConnectionString").Text
    End If

    Dim oSubNodes As Object
    Dim oNode As Object
    Set oSubNodes = oXML.selectNodes("//Company")
    For Each oNode In oSubNodes
        Dim tempConnectionString As String
        Dim sServerName As String
        sServerName = oNode.selectSingleNode("ServerEntry").Text
        Set oGPServer = oServers.FindAndReturnObject(sServerName)
    
        tempConnectionString = sBaseConnectionString
        With oGPServer
          tempConnectionString = SandR(tempConnectionString, "%%DATABASENAME%%", .DatabaseName)
          tempConnectionString = SandR(tempConnectionString, "%%SERVERNAME%%", .ServerName)
          
          'These additional fields are required for a eConnect 7.5 connection string that is not using integrated security
          tempConnectionString = SandR(tempConnectionString, "%%USERNAME%%", .UserName)
          tempConnectionString = SandR(tempConnectionString, "%%PASSWORD%%", .Password)
        
                                      'tempConnectionString = "Provider=SQLOLEDB.1;Persist Security Info=False;User ID=" & .UserName & ";Password=" & .Password & _
                                      '                                 ";Initial Catalog=" & .DatabaseName & ";Data Source=" & .ServerName
                                      'tempConnectionString = "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;User ID=sa;Initial Catalog=MTGP;Data Source=qablue"
        End With
      
        configState.SetConnectionString oNode.selectSingleNode("Namespace").Text, tempConnectionString
    Next
    
    
    Set oGPServer = oServers.FindAndReturnObject("GreatPlainsServer")
       
    configState.OutGoingIdentifier = oXML.selectSingleNode("//OutGoingIdentifier").Text
    configState.MoveBalancePrefix = oXML.selectSingleNode("//MoveBalancePrefix").Text
    configState.MoveBalanceSeperator = oXML.selectSingleNode("//MoveBalanceSeperator").Text
    If oXML.selectSingleNode("//eConnectObject") Is Nothing Then
      'if eConnectObject is not specified in config file, default to eConnect 7.5 for backwards compatibility
      configState.eConnectObjectName = "ExecProcsXML.ExecStoredProcedure75"
    Else
      configState.eConnectObjectName = oXML.selectSingleNode("//eConnectObject").Text
    End If
    
    Set IMTARConfig_Configure = configState
    
    Set oServers = Nothing
    Exit Function
errorhandler:
    Err.Raise Err.Number, Err.Source, "<ARDocuments><ARDocument><Errors><Error><Code>30012</Code><Message>" & Err.Description & "</Message></Error></Errors></ARDocument></ARDocuments>"

End Function
'This is a temporary code to make it run from VBScript
Public Function Configure(Optional ByVal aInternalSystemInfo As Variant) As Variant
    Set Configure = IMTARConfig_Configure(aInternalSystemInfo)
End Function
Public Function AsIMTARConfig() As IMTARConfig
    Set AsIMTARConfig = Me
End Function
