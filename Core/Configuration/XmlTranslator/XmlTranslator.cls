VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsXmlTranslator"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
'----------------------------------------------------------------------------
' Private class variables
'----------------------------------------------------------------------------
Private mConfig As MTConfig
Private mLogger As Logger

'----------------------------------------------------------------------------
' consts
'----------------------------------------------------------------------------
Const gNameAttr = "name"
Const gVersionSetTag = "version"
Const gMajorAttr = "major"
Const gMinorAttr = "minor"
Const gTranslationTag = "translation_mechanism"
Const gActionTag = "action"
Const gSchemaLocation As String = "xsi:schemaLocation"
Const gSchemaRef As String = "xmlns:xsi"
Const gSchemaRefValue As String = "http://www.w3.org/1999/XMLSchema/instance"


'----------------------------------------------------------------------------
' Type declarations
'----------------------------------------------------------------------------

Public Type VersionInfo
  Name As String
  RelativePath As String
  TranslationFile As String
  Extension As String
  Major As Integer
  Minor As Integer
  InputFile As String
  OutputFile As String
End Type
'----------------------------------------------------------------------------
'   Name: Translate
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------


Private Function CrackVersionString(VersionStr As String, ByRef VersionStruct As VersionInfo)
  Dim aStringList, aExtensionList, aUnderscoreList As Variant
  Dim aCount As Long
  Dim ConfigDirectory As String
  Dim aBaseFile As String

  aStringList = Split(VersionStr, "/")
  ' get the complete file name.  this includes the extension and the
  aBaseFile = aStringList(UBound(aStringList))
  
  aExtensionList = Split(aBaseFile, ".")
  VersionStruct.Extension = aExtensionList(UBound(aExtensionList))
  
  ' the first part of the string is the name without the extension.  We don't handle
  ' cases where there are more than one "." in the file name. sorry.
  
  aUnderscoreList = Split(aExtensionList(0), "_")
  ' the minor is the upper bound
  VersionStruct.Minor = aUnderscoreList(UBound(aUnderscoreList))
  ' the major is upper bound -1
  VersionStruct.Major = aUnderscoreList(UBound(aUnderscoreList) - 1)
  ' the file name is the rest
  VersionStruct.Name = ""
  For aCount = 0 To UBound(aUnderscoreList) - 2
    If (VersionStruct.Name <> "") Then
     VersionStruct.Name = VersionStruct.Name & "_"
    End If
    VersionStruct.Name = VersionStruct.Name & aUnderscoreList(aCount)
  Next

  aStringList = Split(VersionStr, "/")
  VersionStruct.RelativePath = aStringList(3)

  For aCount = 4 To UBound(aStringList) - 1
    VersionStruct.RelativePath = VersionStruct.RelativePath + "\" + aStringList(aCount)
  Next

  ConfigDirectory = CStr(GetRegValue(HKEY_LOCAL_MACHINE, _
            "Software\Metratech\Netmeter", "ConfigDir", _
            ""))

  
  VersionStruct.TranslationFile = ConfigDirectory + "\" + VersionStruct.RelativePath + "\upgrade\" + VersionStruct.Name + "_trans" + ".xml"
  

End Function
'----------------------------------------------------------------------------
'   Name: Translate
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------


Private Function FindNewerVersion(ByRef aAttrSet As MTConfigAttribSet, ByRef Ver As VersionInfo) As Boolean


  Dim aMajor As Integer
  Dim aMinor As Integer
  
  aMajor = CInt(aAttrSet.AttrValue(gMajorAttr))
  aMinor = CInt(aAttrSet.AttrValue(gMinorAttr))
  
  FindNewerVersion = False
  
  If aMajor > Ver.Major Then FindNewerVersion = True
  If aMajor >= Ver.Major And aMinor > Ver.Minor Then FindNewerVersion = True
  
  If FindNewerVersion = True Then
    Call mLogger.LogThis(LOG_INFO, "Upgrading to version " & CStr(aMajor) & "." & CStr(aMinor))
  End If
  
  

End Function

Private Function TranformExecutionBuffer(ByRef aTranslationBuffer As String, _
                                         ByRef Output As String)
Dim aArray As Variant
aArray = Split(aTranslationBuffer, "\n")
'MsgBox (aTranslationBuffer)
                                         
End Function

'----------------------------------------------------------------------------
'   Name: Translate
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------
Private Function UpgradeWithVBS(ByRef aTranslationBuffer As String, _
                                    ByRef Ver As VersionInfo, _
                                   ByVal majorNum As String, ByVal MinorNum As String)
                                    
Dim aScriptObject As New ScriptControl
Dim aOutputStr As String
Dim aPropSet As MTConfigPropSet

aScriptObject.AllowUI = False
aScriptObject.Language = "VBScript"
'MsgBox (aTranslationBuffer)
'Call TranformExecutionBuffer(aTranslationBuffer, aOutputStr)
On Error GoTo ErrHandle
Call aScriptObject.AddCode(aTranslationBuffer)
Call aScriptObject.Run("TranslateFile", Ver.InputFile, Ver.OutputFile)
On Error GoTo 0
                                    

Set aPropSet = mConfig.ReadConfiguration(Ver.OutputFile, False)
Call AddDtdAndSchemaInfo(aPropSet, Ver, majorNum, MinorNum)
                                    
                                    
Exit Function
ErrHandle:
  Dim aError As Error
  Set aError = aScriptObject.Error
  Call mLogger.LogThis(LOG_FATAL, "UpgradeWithVBS: Failed to upgrade " & Ver.OutputFile & ": " & aError.Description & " " & Hex(Err.Number))
  Call Err.Raise(Err.Number)
                                      
End Function

'----------------------------------------------------------------------------
'   Name: UpgradeWithXSLT
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------
Private Function UpgradeWithXSLT(ByRef aTranslationBuffer As String, _
                                    ByRef Ver As VersionInfo, _
                                    ByVal majorNum As String, ByVal MinorNum As String)
                                    
  Call mLogger.LogThis(LOG_WARNING, "XSLT upgrade not implemented yet")
  Call Err.Raise(False, "UpgradeWithXSLT", "Feature not implemented yet")
                                    
End Function

Private Function AddDtdAndSchemaInfo(ByRef aPropSet As MTConfigPropSet, _
                                     ByRef Ver As VersionInfo, _
                                     majorNum As String, _
                                     MinorNum As String)


aPropSet.DTD = "http://localhost/validation/" & Ver.Name & "_" & majorNum & "_" & MinorNum & ".dtd"
If Not aPropSet.AttribSet Is Nothing Then
  Call aPropSet.AttribSet.RemoveAttr(gSchemaLocation)
  Call aPropSet.AttribSet.RemoveAttr(gSchemaRef)
Else
  Dim aAttribSet As New MTConfigAttribSet
  aAttribSet.Initialize
  aPropSet.AttribSet = aAttribSet
End If
Call aPropSet.AttribSet.AddPair(gSchemaRef, gSchemaRefValue)
Call aPropSet.AttribSet.AddPair(gSchemaLocation, "http://localhost/validation/" & Ver.Name & "_" & majorNum & "_" & MinorNum & ".xsd")
Call aPropSet.Write(Ver.OutputFile)

End Function

'----------------------------------------------------------------------------
'   Name: UpgradeWithXSL
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------
Private Function UpgradeWithXSL(ByRef aTranslationBuffer As String, _
                                    ByRef Ver As VersionInfo, _
                                    ByVal majorNum As String, ByVal MinorNum As String)
                                    
' step 1: create XMLDom documents for the source document and the XSL translation file
Dim aXmlSourceDoc As New DOMDocument
Dim aXslDoc As New DOMDocument
Dim aOutputXml As New DOMDocument

Dim aErrorObj As IXMLDOMParseError
Dim aResult As String
Dim aDTD As String
Dim aTempPropSet As MTConfigPropSet

Set aTempPropSet = mConfig.ReadConfiguration(Ver.InputFile, False)
aDTD = aTempPropSet.DTD



' step 2: load the source XML
aXmlSourceDoc.async = False
aXmlSourceDoc.validateOnParse = False
Call aXmlSourceDoc.Load(Ver.InputFile)
Set aErrorObj = aXmlSourceDoc.parseError
If aErrorObj.errorCode <> 0 Then
  Call mLogger.LogThis(LOG_FATAL, "UpgradeWithXSL: Failed to load source XML " & Ver.InputFile & ": " & aErrorObj.reason & aErrorObj.srcText)
  Call Err.Raise(aErrorObj.errorCode, "UpgradeWithXSL", aErrorObj.reason)
End If

' step 3: load the XSL file
aXslDoc.async = False
Call aXslDoc.loadXML(aTranslationBuffer)
Set aErrorObj = aXmlSourceDoc.parseError
If aErrorObj.errorCode <> 0 Then
  Call mLogger.LogThis(LOG_FATAL, "UpgradeWithXSL: Failed to load XSL " & Ver.InputFile & ": " & aErrorObj.reason)
  Call Err.Raise(aErrorObj.errorCode, "UpgradeWithXSL", aErrorObj.reason)
End If


aResult = aXmlSourceDoc.transformNode(aXslDoc.documentElement)

Dim aPropSet As MTConfigPropSet
'MsgBox (aResult)
Set aPropSet = mConfig.ReadConfigurationFromString(aResult, False)

Call AddDtdAndSchemaInfo(aPropSet, Ver, majorNum, MinorNum)

                                    
End Function


'----------------------------------------------------------------------------
'   Name: Translate
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Function UpgradeWithVerProp(ByRef aVersionSet As MTConfigPropSet, _
                                    ByRef Ver As VersionInfo)
                                    
                                      
  Dim aActionType As String
  Dim aActionBuffer As String
  Dim aMajor, aMinor As String
  
  aActionType = aVersionSet.NextStringWithName(gTranslationTag)
  aActionBuffer = aVersionSet.NextStringWithName(gActionTag)
  aMajor = aVersionSet.AttribSet.AttrValue("major")
  aMinor = aVersionSet.AttribSet.AttrValue("minor")
  
                                    
  Select Case aActionType
  Case "XSL"
    Call UpgradeWithXSL(aActionBuffer, Ver, aMajor, aMinor)
  Case "XSLT"
    Call UpgradeWithXSLT(aActionBuffer, Ver, aMajor, aMinor)
  Case "VBS"
    Call UpgradeWithVBS(aActionBuffer, Ver, aMajor, aMinor)
  Case Else
    Call Err.Raise(False, "UpgradeWithVerProp", "Unknown translation action type")
  End Select


End Function

'----------------------------------------------------------------------------
'   Name: Translate
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Function UpgradeFromPoint(aVersionSet As MTConfigPropSet, _
                                  aPropSet As MTConfigPropSet, _
                                  ByRef Ver As VersionInfo)
                                  
                                                                    
Dim bDone As Boolean
bDone = False
Do
  Call UpgradeWithVerProp(aVersionSet, Ver)
  
  Set aVersionSet = aPropSet.NextSetWithName(gVersionSetTag)
  If aVersionSet Is Nothing Then bDone = True
Loop Until bDone = True
                                                                    
                                  
                                  
End Function

'----------------------------------------------------------------------------
'   Name: Translate
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Function TranslateXml(ByRef Ver As VersionInfo, _
                            ByRef aPropSet As MTConfigPropSet) As Boolean
                            

' step 1: verify that the names match
Dim aAttribSet As MTConfigAttribSet
Set aAttribSet = aPropSet.AttribSet
Dim aVersionSet As MTConfigPropSet
Dim bDone As Boolean

If aAttribSet.AttrValue(gNameAttr) <> Ver.Name Then
  Call Err.Raise(False, "TranslateXml", "Name in version string does not match name in the XML file")
End If

bDone = False
While (Not bDone)
  Set aVersionSet = aPropSet.NextSetWithName(gVersionSetTag)
  If aVersionSet Is Nothing Then
    bDone = True
  Else
  
    If FindNewerVersion(aVersionSet.AttribSet, Ver) Then
      Call UpgradeFromPoint(aVersionSet, aPropSet, Ver)
      bDone = True
    End If
   
  End If
Wend

 TranslateXml = True
                            
End Function
                            


'----------------------------------------------------------------------------
'   Name: Translate
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Public Function TranslateToLatestVersion(Verstring1 As String, InputFile As String, OutputFile As String) As Boolean
  On Error GoTo ErrHandle
  Dim aVersionStruct As VersionInfo
  Dim aPropSet As MTConfigPropSet
  Dim aFileSystemObj As Object
  
  Call CrackVersionString(Verstring1, aVersionStruct)
  aVersionStruct.InputFile = InputFile
  aVersionStruct.OutputFile = OutputFile
  
  On Error GoTo ErrHandle
  Set aFileSystemObj = CreateObject("scripting.FileSystemObject")
  If aFileSystemObj.FileExists(aVersionStruct.TranslationFile) Then
    Set aPropSet = mConfig.ReadConfiguration(aVersionStruct.TranslationFile, False)
  Else
    ' succeed even if a translation file does not exist
     ' simply copy the input file to the output file
     If InputFile <> OutputFile Then
      Call aFileSystemObj.CopyFile(InputFile, OutputFile, True)
     End If
    TranslateToLatestVersion = True
    Exit Function
  End If
  
  On Error GoTo 0
  If Not aPropSet Is Nothing Then
    TranslateToLatestVersion = TranslateXml(aVersionStruct, aPropSet)
  Else
    Call mLogger.LogThis(LOG_ERROR, "Failed to read Migration file " & aVersionStruct.TranslationFile)
    TranslateToLatestVersion = False
  End If
  

Exit Function
ErrHandle:
  TranslateToLatestVersion = False
  Call Err.Raise(Err.Number, "TranslateToLatestVersion", Err.Description)

End Function

Public Function TranslateWithXmlFile(InputFile As String, OutputFile As String) As Boolean

Dim aPropSet As MTConfigPropSet
Dim aVersionString As String
aVersionString = ""
Dim aVersionStruct As VersionInfo

Set aPropSet = mConfig.ReadConfiguration(InputFile, False)
On Error Resume Next
aVersionString = aPropSet.AttribSet.AttrValue(gSchemaLocation)
On Error GoTo 0

If aVersionString <> "" Then
  Call CrackVersionString(aVersionString, aVersionStruct)
  aVersionStruct.InputFile = InputFile
  aVersionStruct.OutputFile = OutputFile
  TranslateWithXmlFile = TranslateToLatestVersion(aVersionString, InputFile, OutputFile)
Else
 Call mLogger.LogThis(LOG_ERROR, "Could not get schemalocation from XML file")
 TranslateWithXmlFile = False
End If

End Function

'----------------------------------------------------------------------------
'   Name: TranslationAvailable
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

', ByRef Major As Integer, ByRef Minor As Integer

Public Function TranslationAvailable(Verstring1 As String) As Boolean
  
  Dim aVersionStruct As VersionInfo
  
  Call CrackVersionString(Verstring1, aVersionStruct)

End Function
'----------------------------------------------------------------------------
'   Name: CurrentVersion
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------


Public Function CurrentVersion(Verstring1 As String, ByRef Major As Integer, ByRef Minor As Integer)

End Function





Private Sub Class_Initialize()
  Set mConfig = New MTConfig
  Set mLogger = New Logger
  Call mLogger.Init("logging\XmlTranslator", "[XMLtranslator]")
  mConfig.AutoEnumConversion = False
End Sub
