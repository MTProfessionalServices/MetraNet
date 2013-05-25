VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Dictionary"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399321D103BC"
'****************************************************************************************************************************************************
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
' MODIFIED      : $Date: 12/21/2001 1:40:35 PM$
' LAST AUTHOR   : $Author: Kevin Boucher$
' REVISION      : $Revision: 41$
' FILENAME      : $Workfile: dictionary.cls$
'
' ****************************************************************************
' CLASS         : Dictionary
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : Implement a general purpose dictionary (COM Collection of the class DictionaryEntry). A dictionary entry is a
'                 name and value (description field is optional).
'
'                 A dictionary can load MetraTech XML Dictionary Link Format
'
'                   <links id="Main" type='collection'>
'                       <link id="WELCOME_DIALOG">
'                           <value>/mam/Welcome.asp</value><description></description>
'                       </link>
'                   </links>
'
'                 A dictionary can load MetraTech XML Dictionary Text Format
'
'                   <texts id="Main" type='collection'>
'                       <text id='TEXT_SUMMURY_ACCOUNT_INFO_DIALOG'>
'                           <value>Summary</value><description></description>
'                       </text>
'                   </texts>
'
'                XML Dictionary text file are generally localized. XML Dictionary link file are
'                generally not localized. Once loaded there are no difference between link and text.
'                A dictionary object is used by the MDM HTML Renderer (Class MSIXHandler)!
'
'*****************************************************************************
Option Explicit

Public TRACE_ID As Long

Private mCol    As Collection
Public Id       As String
Public Version  As String
Public Description As String ' Description of the last xml dictionary file loaded.

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey              - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(vntKey As Variant) As DictionaryEntry
Attribute Item.VB_UserMemId = 0

   On Error GoTo ErrMgr
   If IsNumeric(vntKey) Then
        Set Item = mCol(vntKey)
   Else
        Set Item = mCol(UCase$(vntKey))
   End If
   Exit Property
ErrMgr:
    TRACE Replace(MTMSIX_ERROR_01057, "[ENTRY]", CStr(vntKey)), Me, "Item", LOG_ERROR
    RaiseError Replace(MTMSIX_ERROR_01057, "[ENTRY]", CStr(vntKey)), "MTMSIX.Dictionary", , LOG_APPLICATION_ERROR
     
    Set Item = Nothing
End Property



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Removes the item from the collection. The method is not case sensitive.
' RETURN        : Returns TRUE if Ok.
Public Function Remove(vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    mCol.Remove vntKey
    Remove = True
    Exit Function
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Count
' PARAMETERS    :
' DESCRIPTION   : Returns the number of items in the collection.
' RETURN        :
Public Property Get Count() As Long

    On Error GoTo ErrMgr
    Count = mCol.Count
    Exit Property
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : NewEnum
' PARAMETERS    :
' DESCRIPTION   : Implement the COM Enumerator. This function is used internally by visual basic in for each loop!
' RETURN        : IUnknown
Public Property Get NewEnum() As IUnknown ' Documented=no
Attribute NewEnum.VB_UserMemId = -4



    On Error GoTo ErrMgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property


Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    
'    'Debug.Assert 0
    
    Set mCol = New Collection
    Version = MDM_VERSION_13
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub


Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
 '   'Debug.Assert 0
    Clear
    Set mCol = Nothing
    
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   : Remove all the items in the collection. If the item is no more referenced it is deleted and its destructor
'                 Class_Terminate event is raise.
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr
    
    
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If

    Do While Count > 0
    
        Remove 1
    Loop
    Clear = True
    Exit Function
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
' DESCRIPTION   : Add a new item to the collection with the id strId and return and a reference of it.
'                 If the item already exist it is overwritten.
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function Add(ByVal strId As String, Optional ByVal varValue As Variant, Optional ByVal strDescription As String, Optional strEntryType As String) As DictionaryEntry

    On Error GoTo ErrMgr
    
    Dim objDictionaryEntry As New DictionaryEntry
        
    objDictionaryEntry.Id = strId
    
    
    If (Len(strId) = 0) Then
        mCol.Add objDictionaryEntry
    Else
        If (Me.Exist(strId)) Then Me.Remove strId
        
        mCol.Add objDictionaryEntry, UCase$(objDictionaryEntry.Id)
    End If
    
    If (Not IsMissing(varValue)) Then objDictionaryEntry.Value = varValue
    
    objDictionaryEntry.Description = strDescription
    objDictionaryEntry.EntryType = strEntryType
    
    Set Add = objDictionaryEntry
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr

    Dim clsNode As DictionaryEntry
    Dim strS    As String
    
    For Each clsNode In Me
        strS = strS & clsNode.ToString() & vbCrLf
    Next
    ToString = strS

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "ToString", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadXMLFile
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        : TRUE if Ok.
Function LoadXMLFile(ByVal strXMLFileName As String) As Boolean

    Dim objOM               As New XMLLoader
    Dim objFile             As New cTextFile
    Dim strHTMLFileName     As String
    Dim objTool             As New cTool
    Dim strHTML             As Variant
    Dim strTrace            As String
    Dim objProfiler         As New CProfiler
    Dim booRetVal           As Boolean
    
    'objProfiler.Start MTMSIX_PROFILER_ON, Me, "LoadXMLFile", "XMLFileName=" & strXMLFileName
    
    If (Me.IsALinkFile(strXMLFileName)) Then
    
        booRetVal = Me.LoadXMLFileLink(strXMLFileName)
        GoSub TraceInfo
    
    ElseIf Me.IsATextFile(strXMLFileName) Then
    
        booRetVal = Me.LoadXMLFileText(strXMLFileName)
        GoSub TraceInfo
        
    Else
        booRetVal = objOM.LoadObjectModelData(Me, strXMLFileName)
        GoSub TraceInfo
    End If
    LoadXMLFile = booRetVal
    Exit Function
    
TraceInfo:
    If (Not booRetVal) Then
        strTrace = MTMSIX_ERROR_01026
        strTrace = Replace(strTrace, "[FILE]", strXMLFileName)
        strTrace = Replace(strTrace, "[RESULT]", IIf(booRetVal, "SUCCEED", "FAILED"))
        strTrace = Replace(strTrace, "[ERRORTAG]", IIf(booRetVal, "WARNING", "ERROR"))
        TRACE strTrace, Me, "LoadXMLFile", IIf(booRetVal, LOG_WARNING, LOG_ERROR)
    End If
Return
    
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "ToString", LOG_ERROR
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : Exist
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Returns TRUE if the item exist in the collection. The method is not case sensitive.
' RETURN        :
Public Function Exist(ByVal vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    
    Dim objItem As Object
    
    If IsNumeric(vntKey) Then
        Set objItem = mCol(vntKey)
    Else
        Set objItem = mCol(UCase$(vntKey))
    End If
    Exist = True
    Exit Function
ErrMgr:
    Err.Clear
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadFolder
' PARAMETERS    :
'                 strDictionaryFolder - The path of the folder to read.
'                 booReadSubFoldersOneLevel - MDM V2
' DESCRIPTION   : Load all XML link file, XML text file and ASP Const file contained in the directory
' RETURN        : TRUE if Ok.
Public Function LoadFolder(ByVal strDictionaryFolder As String, Optional booReadSubFoldersOneLevel As Boolean = False) As Boolean

    On Error GoTo ErrMgr

    Dim objTextFile As New cTextFile
    Dim objFiles    As New CVariables
    Dim objFile     As New CVariable
    Dim objFolders   As New CVariables
    Dim objFolder    As New CVariable
    
    Debug.Print strDictionaryFolder
        
    LoadFolder = True
    objFiles.Clear
    If (objTextFile.GetFilesList(strDictionaryFolder, WILDCARD_EXTENSION_XML, objFiles)) Then
    
        For Each objFile In objFiles
            
            If (Not Me.LoadXMLFile(objFile.Value)) Then
            
                TRACE Replace(MTMSIX_ERROR_01018, "[NAME]", objFile.Value), Me, "LoadFolder", LOG_ERROR
                LoadFolder = False
                Exit Function
            End If
        Next
    End If
    
    objFiles.Clear
    If (objTextFile.GetFilesList(strDictionaryFolder, WILDCARD_EXTENSION_ASP, objFiles)) Then
    
        For Each objFile In objFiles
            
            If (Not Me.LoadASPFile(objFile.Value)) Then
            
                TRACE Replace(MTMSIX_ERROR_01018, "[NAME]", objFile.Value), Me, "LoadFolder", LOG_ERROR
                LoadFolder = False
                Exit Function
            End If
        Next
    End If
    
    ' Read as well the xml file contained in the sub folder level 1
    If (booReadSubFoldersOneLevel) Then
    
        objFolders.Clear
        If (objTextFile.GetFoldersList(strDictionaryFolder, "*.*", objFolders)) Then
        
            For Each objFolder In objFolders
                
                If (Not Me.LoadFolder(objFolder.Value)) Then
                
                    TRACE Replace(MTMSIX_ERROR_01018, "[NAME]", objFile.Value), Me, "LoadFolder", LOG_ERROR
                    LoadFolder = False
                    Exit Function
                End If
            Next
        End If
    End If
    
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "LoadFolder", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadASPFile
' PARAMETERS    :
' DESCRIPTION   : Not documented! Load all the const definition of an .asp file.
' RETURN        : TRUE if Ok.
Public Function LoadASPFile(strASPFile As String) As Boolean

    On Error GoTo ErrMgr

    Dim objTextFile As New cTextFile
    Dim objParser   As New CByteSyntaxAnalyser
    Dim strS        As String
    Dim strTok      As String
    Dim strName     As String
    Dim strValue    As String
    Dim objDicEntry As DictionaryEntry
    Dim booRetVal   As Boolean
    Dim strTrace    As String
        
    If (objTextFile.OpenFile(strASPFile)) Then
    
        Do While Not objTextFile.EOF()
        
            strS = objTextFile.ReadLn()
            objParser.Init strS
            
            If (objParser.GetIdentifier(strTok) = rSUCCEED) Then
            
                If (strTok = "CONST") Then
                    If (objParser.GetIdentifier(strName) = rFAILED) Then GoTo SyntaxError
                    If (objParser.GetChar("=") = rFAILED) Then GoTo SyntaxError
                    If (objParser.GetString(strValue) = rFAILED) Then GoTo SyntaxError
                    
                    Set objDicEntry = Me.Add(strName, strValue)
                End If
            End If
        Loop
        objTextFile.CloseFile
        booRetVal = True
        
        If (Not booRetVal) Then
        
            strTrace = MTMSIX_ERROR_01060
            strTrace = Replace(strTrace, "[FILE]", strASPFile)
            strTrace = Replace(strTrace, "[RESULT]", IIf(booRetVal, "SUCCEED", "FAILED"))
            strTrace = Replace(strTrace, "[ERRORTAG]", IIf(booRetVal, "WARNING", "ERROR"))
            TRACE strTrace, Me, "LoadASPFile", IIf(booRetVal, LOG_WARNING, LOG_ERROR)
        End If
        
        LoadASPFile = booRetVal

    End If
    Exit Function
SyntaxError:
    Dim strError As String
    strError = MTMSIX_ERROR_01019
    strError = Replace(strError, "[FILENAME]", strASPFile)
    strError = Replace(strError, "[LINE]", objTextFile.LinesRead)
    TRACE strError, Me, "LoadASPFile", LOG_ERROR

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "LoadASPFile", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PreProcess
' PARAMETERS    :
' DESCRIPTION   : Returns the string s after being pre processed with the values of the dictionary. The pre process consist of
'                 replacing the <DICTIONARY_ENTRY_NAME> tag with the DICTIONARY_ENTRY_VALUE.
' RETURN        :
Public Function PreProcess(ByVal s As String, Optional charStart As String = "[", Optional charEnd As String = "]") As String

    On Error GoTo ErrMgr

    Dim objVar As DictionaryEntry
    
    Dim tagName     As String
    Dim tagStart    As Long
    Dim tagEnd      As Long
    Dim pos         As Long
    pos = 1
    Do
        tagStart = InStr(pos, s, charStart)
        If tagStart Then

            tagEnd = InStr(tagStart + 1, s, charEnd)
            
            If tagEnd Then
            
                tagName = Mid(s, tagStart + 1, tagEnd - tagStart - 1)
                
                On Error Resume Next ' This is faster than calling FindItem()
                Set objVar = mCol(UCase$(tagName))
                If Err.Number = 0 Then
                    s = MTVBExtensionReplace.Replace(s, charStart & objVar.Name & charEnd, objVar.Value)
                    pos = tagStart
                Else
                    Err.Clear
                    pos = tagEnd
                End If
                On Error GoTo ErrMgr
            Else
                TRACE MTMSIX_ERROR_01104, Me, "PreProcess", LOG_WARNING
                Exit Do
            End If
        Else
            Exit Do ' good we are finished
        End If
    Loop
    PreProcess = s
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "PreProcess", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadXMLFileLink
' PARAMETERS    :
' DESCRIPTION   : Load the file as a XML dictionary links file!
' RETURN        : TRUE if Ok.
Function LoadXMLFileLink(ByVal strXMLFileName As String) As Boolean

    Dim objOM               As New XMLLoader
    Dim objFile             As New cTextFile
    Dim strHTMLFileName     As String
    Dim objTool             As New cTool
    Dim strHTML             As Variant
    Dim strTrace            As String
    Dim objProfiler         As New CProfiler
    Dim booRetVal           As Boolean
    Dim objTranslate        As New CVariables
    
    'objProfiler.Start MTMSIX_PROFILER_ON, Me, "LoadXMLFileLink", "XMLFileName=" & strXMLFileName
        
    objTranslate.Add "links", "dictionary"
    objTranslate.Add "link", "dictionaryentry"
    
    booRetVal = objOM.LoadObjectModelData(Me, strXMLFileName, objTranslate, "links")
    
    If (Not booRetVal) Then
        strTrace = MTMSIX_ERROR_01026
        strTrace = Replace(strTrace, "[FILE]", strXMLFileName)
        strTrace = Replace(strTrace, "[RESULT]", IIf(booRetVal, "SUCCEED", "FAILED"))
        strTrace = Replace(strTrace, "[ERRORTAG]", IIf(booRetVal, "WARNING", "ERROR"))
        TRACE strTrace, Me, "LoadXMLFileLink", IIf(booRetVal, LOG_WARNING, LOG_ERROR)
    End If
    LoadXMLFileLink = booRetVal
            
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "Delete", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadXMLFileText
' PARAMETERS    :
' DESCRIPTION   : Load the file as a XML dictionary texts file!
' RETURN        : TRUE if Ok.
Function LoadXMLFileText(ByVal strXMLFileName As String) As Boolean

    Dim objOM               As New XMLLoader
    Dim objFile             As New cTextFile
    Dim strHTMLFileName     As String
    Dim objTool             As New cTool
    Dim strHTML             As Variant
    Dim strTrace            As String
    Dim objProfiler         As New CProfiler
    Dim booRetVal           As Boolean
    Dim objTranslate        As New CVariables
    
    'objProfiler.Start MTMSIX_PROFILER_ON, Me, "LoadXMLFileText", "XMLFileName=" & strXMLFileName
    
    objTranslate.Add "texts", "dictionary"
    objTranslate.Add "text", "dictionaryentry"
    
 
    
    booRetVal = objOM.LoadObjectModelData(Me, strXMLFileName, objTranslate, "texts")
    
    If (Not booRetVal) Then
    
        strTrace = MTMSIX_ERROR_01026
        strTrace = Replace(strTrace, "[FILE]", strXMLFileName)
        strTrace = Replace(strTrace, "[RESULT]", IIf(booRetVal, "SUCCEED", "FAILED"))
        strTrace = Replace(strTrace, "[ERRORTAG]", IIf(booRetVal, "WARNING", "ERROR"))
        TRACE strTrace, Me, "LoadXMLFileText", IIf(booRetVal, LOG_WARNING, LOG_ERROR)
    End If
    
    LoadXMLFileText = booRetVal

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "Delete", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : IsALinkFile
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE if the file is an dictionary link file.
' RETURN        :
Public Function IsALinkFile(strXMLFileName As String) As Boolean

    On Error GoTo ErrMgr

    Dim objTextFile As New cTextFile
    
    IsALinkFile = InStr(UCase$(objTextFile.LoadFile(strXMLFileName)), "<LINKS")
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "IsALinkFile", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : IsATextFile
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE if the file is an dictionary texts file.
' RETURN        :
Public Function IsATextFile(strXMLFileName As String) As Boolean

    On Error GoTo ErrMgr

    Dim objTextFile As New cTextFile
    
    IsATextFile = InStr(UCase$(objTextFile.LoadFile(strXMLFileName)), "<TEXTS")
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "IsATextFile", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Render() As Boolean

    On Error GoTo ErrMgr

    Dim objVar As DictionaryEntry
    
    For Each objVar In Me
    
        objVar.Value = Me.PreProcess(objVar.Value)
    Next
    Render = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "PreProcess", LOG_ERROR
End Function




Friend Property Get Collection() As Collection

    On Error GoTo ErrMgr
    
    Set Collection = mCol

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "Collection", LOG_ERROR
End Property



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetValue
' PARAMETERS    :
'                   vntKey              - Item key name id or item long index, starting at 1.
'                   varDefaultValue     - If defined and if the item is not found the Item property will return a temparary instance DictionaryEntry
'                                         set with the name vntKey and the value varDefaultValue.
' DESCRIPTION   : Returns a value from one entry of the dictionary.
'                 The method is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Function GetValue(vntKey As Variant, Optional varDefaultValue As Variant) As Variant

    If (Me.Exist(vntKey)) Then
    
        GetValue = Me.Item(vntKey).Value
    Else
        GetValue = IIf(IsMissing(varDefaultValue), Empty, varDefaultValue)
    End If
End Function




' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function ASP2XMLDictionary(strFileName As String, strKeyWord As String) As Boolean ' Documented=no
    
    Dim objDictionary   As New Dictionary
    Dim objEntry        As DictionaryEntry
    Dim strXML          As String
    Dim objTextFile     As New cTextFile
    Dim strXMLFileName  As String
    
    strXMLFileName = Mid(strFileName, 1, Len(strFileName) - 3)
    strXMLFileName = strXMLFileName & "xml"
    
    If (objDictionary.LoadASPFile(strFileName)) Then
        
        For Each objEntry In Me
    
            objEntry.Value = Replace(objEntry.Value, "<", "&lt;")
            objEntry.Value = Replace(objEntry.Value, ">", "&gt;")
            objEntry.Value = Replace(objEntry.Value, "&", "&amp;")
        Next
        ASP2XMLDictionary = Save(strXMLFileName, strKeyWord)
    End If
    
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Save
' PARAMETERS    :
'                   strFileName - The XML destination file name.
'                   strKeyWord  - The XML dictionary tag. link or text in lowercase.
' DESCRIPTION   : Save the current dictionary into a file.
' RETURN        :
Public Function Save(strFileName As String, strKeyWord As String) As Boolean
    
    Dim objEntry        As DictionaryEntry
    Dim strXML          As String
    Dim objTextFile     As New cTextFile
    Dim strXMLFileName  As String
    
    strXMLFileName = strFileName
    
    strXML = strXML & "<?xml version=""1.0"" encoding=""UTF-8""?>" & vbNewLine
    strXML = strXML & "<[KEYWORD]s id=""Main"" type=""collection"">" & vbNewLine
    
    For Each objEntry In Me
    
        strXML = strXML & vbNewLine
        strXML = strXML & "    <[KEYWORD] id=""" & objEntry.Name & """>" & vbNewLine
        strXML = strXML & "        <value>" & objEntry.Value & "</value>" & vbNewLine
        strXML = strXML & "        <description>" & objEntry.Description & "</description>" & vbNewLine
        strXML = strXML & "    </[KEYWORD]>" & vbNewLine
    Next

    strXML = strXML & "</[KEYWORD]s>" & vbNewLine
    strXML = Replace(strXML, "[KEYWORD]", strKeyWord)
    
    objTextFile.LogFile strXMLFileName, strXML, True
End Function

Public Function GetCollectionAsCSVString(ByVal strName As String) As String
    Dim s           As String
    Dim objEntry    As DictionaryEntry
    
    For Each objEntry In GetCollection(strName)
        s = s & objEntry.Value & ","
    Next
    If Len(s) Then
        GetCollectionAsCSVString = Mid(s, 1, Len(s) - 1)
    End If
End Function

Public Function GetCollection(ByVal strName As String) As Dictionary

    Dim objEntry            As DictionaryEntry
    Dim i                   As Long
    Dim strTmpName          As String
    Dim objTmpDictionary    As New Dictionary
    
    On Error GoTo ErrMgr
        
    strName = UCase$(strName)
    i = 1
    Do
        strTmpName = strName & "(" & i & ")"
        If Me.Exist(strTmpName) Then
        
            Set objEntry = Me.Item(strTmpName)
            objTmpDictionary.Add objEntry.Name, objEntry.Value, objEntry.Description, objEntry.EntryType
        Else
            Exit Do
        End If
        i = i + 1
    Loop
    Set GetCollection = objTmpDictionary
Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), Me, "GetCollection", LOG_ERROR
End Function








