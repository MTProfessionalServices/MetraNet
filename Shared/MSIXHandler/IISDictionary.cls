VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IISDictionary"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
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
' MODIFIED      : $Date$
' LAST AUTHOR   : $Author$
' REVISION      : $Revision$
' FILENAME      : $Workfile$
'
' ****************************************************************************
' CLASS         : IISDictionary
' AUTHOR        : F.Torres
' CREATION DATE : 03/02/2001
' VERSION       : 1.0
' DESCRIPTION   :

'
'*****************************************************************************
Option Explicit


Public Id       As String

Public Description As String ' Description of the last xml dictionary file loaded.

Private m_MSDictionary As Scripting.Dictionary

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey              - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(vntKey As Variant) As String

   On Error GoTo ErrMgr
   
   Dim v As Variant
   v = m_MSDictionary.Item(UCase$(vntKey))
   If (IsEmpty(v)) Then
        Err.Raise 1057 + vbObjectError, App.EXEName, ""
   End If
    Item = v
   Exit Property
ErrMgr:
    TRACE Replace(MTMSIX_ERROR_01057, "[ENTRY]", vntKey), "IISDictionary.cls", "Item", LOG_ERROR
    RaiseError Replace(MTMSIX_ERROR_01057, "[ENTRY]", vntKey), "MTMSIX.Dictionary", , LOG_APPLICATION_ERROR
     
    
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Removes the item from the collection. The method is not case sensitive.
' RETURN        : Returns TRUE if Ok.
Public Function Remove(vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    m_MSDictionary.Remove UCase$(vntKey)
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
    Count = m_MSDictionary.Count
    Exit Property
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property



Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub


Private Sub Class_Terminate()

    On Error GoTo ErrMgr
        
    Set m_MSDictionary = Nothing
    
    TRACE "IISDictionary", "IISDictionary", "Class_Terminate", LOG_DEBUG
    
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
    
    TRACE MTMSIX_ERROR_01079, "IISDictionary.cls", "Clear", LOG_DEBUG
    m_MSDictionary.RemoveAll
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
Public Sub Add(ByVal strId As String, Optional ByVal varValue As Variant, Optional ByVal strDescription As String, Optional strEntryType As String)

    On Error GoTo ErrMgr
    
    If (Me.Exist(strId)) Then Me.Remove strId
    
    m_MSDictionary.Add UCase$(strId), varValue
    
    Exit Sub
ErrMgr:
    
End Sub

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr

    Dim i As Long
    Dim strS As String

    For i = 0 To m_MSDictionary.Count - 1
    
        strS = strS & "name=" & m_MSDictionary.Keys(i) & "; value=" & m_MSDictionary.Items(i) & ";" & vbNewLine
    Next
    ToString = strS

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "IISDictionary.cls", "ToString", LOG_ERROR
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
    
    objProfiler.Start MTMSIX_PROFILER_ON, "IISDictionary.cls", "LoadXMLFile", "XMLFileName=" & strXMLFileName
    
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
        TRACE strTrace, "IISDictionary.cls", "LoadXMLFile", IIf(booRetVal, LOG_WARNING, LOG_ERROR)
    End If
Return
    
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "IISDictionary.cls", "ToString", LOG_ERROR
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : Exist
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Returns TRUE if the item exist in the collection. The method is not case sensitive.
' RETURN        :
Public Function Exist(ByVal vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    
    Dim strItem As String
    
    Exist = m_MSDictionary.Exists(UCase$(vntKey))
    Exit Function
ErrMgr:
    Err.Clear
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadFolder
' PARAMETERS    :
' DESCRIPTION   : Load all XML link file, XML text file and ASP Const file contained in the directory
' RETURN        : TRUE if Ok.
Public Function LoadFolder(ByVal strDictionaryFolder As String) As Boolean

    On Error GoTo ErrMgr

    Dim objTextFile As New cTextFile
    Dim objFiles    As New CVariables
    Dim objFile     As New CVariable
        
    LoadFolder = True
    objFiles.Clear
    If (objTextFile.GetFilesList(strDictionaryFolder, WILDCARD_EXTENSION_XML, objFiles)) Then
    
        For Each objFile In objFiles
            
            If (Not Me.LoadXMLFile(objFile.Value)) Then
            
                TRACE Replace(MTMSIX_ERROR_01018, "[NAME]", objFile.Value), "IISDictionary.cls", "LoadFolder", LOG_ERROR
                LoadFolder = False
                Exit Function
            End If
        Next
    End If
    
 
    
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "IISDictionary.cls", "LoadFolder", LOG_ERROR
End Function

     

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PreProcess
' PARAMETERS    :
' DESCRIPTION   : Returns the string s after being pre processed with the values of the dictionary. The pre process consist of
'                 replacing the <DICTIONARY_ENTRY_NAME> tag with the DICTIONARY_ENTRY_VALUE.
' RETURN        :
Public Function PreProcess(ByVal s As String, Optional charStart As String = "[", Optional charEnd As String = "]") As String

    On Error GoTo ErrMgr

    Dim i As Long
    
    For i = 0 To m_MSDictionary.Count - 1
    
        s = Replace(s, charStart & m_MSDictionary.Keys(i) & charEnd, m_MSDictionary.Item(i))
    Next
    PreProcess = s

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "IISDictionary.cls", "PreProcess", LOG_ERROR
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
    Dim objTmpDictionary    As New MTMSIX.Dictionary
    Dim objTmpDictionaryEntry    As New MTMSIX.DictionaryEntry
    
    objProfiler.Start MTMSIX_PROFILER_ON, "IISDictionary.cls", "LoadXMLFileLink", "XMLFileName=" & strXMLFileName
        
    objTranslate.Add "links", "Dictionary"
    objTranslate.Add "link", "dictionaryentry"
    
    booRetVal = objOM.LoadObjectModelData(objTmpDictionary, strXMLFileName, objTranslate, "links")
    
    If (Not booRetVal) Then
        strTrace = MTMSIX_ERROR_01026
        strTrace = Replace(strTrace, "[FILE]", strXMLFileName)
        strTrace = Replace(strTrace, "[RESULT]", IIf(booRetVal, "SUCCEED", "FAILED"))
        strTrace = Replace(strTrace, "[ERRORTAG]", IIf(booRetVal, "WARNING", "ERROR"))
        TRACE strTrace, "IISDictionary.cls", "LoadXMLFileLink", IIf(booRetVal, LOG_WARNING, LOG_ERROR)
    Else
        For Each objTmpDictionaryEntry In objTmpDictionary
        
            Me.Add objTmpDictionaryEntry.Name, objTmpDictionaryEntry.Value
        Next
    End If
    LoadXMLFileLink = booRetVal
            
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "IISDictionary.cls", "Delete", LOG_ERROR
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
    Dim objTmpDictionary    As New MTMSIX.Dictionary
    Dim objTmpDictionaryEntry    As New MTMSIX.DictionaryEntry
    
    objProfiler.Start MTMSIX_PROFILER_ON, "IISDictionary.cls", "LoadXMLFileText", "XMLFileName=" & strXMLFileName
    
    objTranslate.Add "texts", "IISDictionary"
    objTranslate.Add "text", "dictionaryentry"
    
    booRetVal = objOM.LoadObjectModelData(objTmpDictionary, strXMLFileName, objTranslate, "texts")
    
    If (Not booRetVal) Then
    
        strTrace = MTMSIX_ERROR_01026
        strTrace = Replace(strTrace, "[FILE]", strXMLFileName)
        strTrace = Replace(strTrace, "[RESULT]", IIf(booRetVal, "SUCCEED", "FAILED"))
        strTrace = Replace(strTrace, "[ERRORTAG]", IIf(booRetVal, "WARNING", "ERROR"))
        TRACE strTrace, "IISDictionary.cls", "LoadXMLFileText", IIf(booRetVal, LOG_WARNING, LOG_ERROR)
    Else
        For Each objTmpDictionaryEntry In objTmpDictionary
        
            Me.Add objTmpDictionaryEntry.Name, objTmpDictionaryEntry.Value
        Next
    End If
    
    LoadXMLFileText = booRetVal

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "IISDictionary.cls", "Delete", LOG_ERROR
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
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "IISDictionary.cls", "IsALinkFile", LOG_ERROR
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
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "IISDictionary.cls", "IsATextFile", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Render() As Boolean

    On Error GoTo ErrMgr

    Dim i As Long

    For i = 0 To m_MSDictionary.Count - 1
    
        m_MSDictionary.Items(i) = Me.PreProcess(m_MSDictionary.Items(i))
    Next
    Render = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "IISDictionary.cls", "PreProcess", LOG_ERROR
End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetArray
' PARAMETERS    :
'                   strArrayName - The name of the array.
'                   objResult    - Where and how to return the result. This object must be allocated by the caller. We support 2 kind
'                                  of object MTMSIX.Dictionary or MTVBlib.CVariables.
'
' DESCRIPTION   : Returns an logical array of entries from the dictionary. a array is dictionary entry that have the same name
'                 but end with (x). Like Name(1), Name(2), Name(3).
' RETURN        :
Public Function GetArray(ByVal strArrayName As String, ByRef objResult As Variant) As Boolean

    On Error GoTo ErrMgr


    Dim objDictionaryEntry          As DictionaryEntry
    Dim objDicEntry                 As DictionaryEntry
    Dim booIsResultADictionary      As Boolean
    
    strArrayName = UCase$(strArrayName)
    booIsResultADictionary = UCase$(TypeName(objResult)) = "IISDictionary"

    For Each objDicEntry In Me
    
        If (UCase$(Mid$(objDicEntry.Name, 1, Len(strArrayName))) = strArrayName) Then ' array item found
        
            
            If (booIsResultADictionary) Then
            
                objResult.Add objDicEntry.Id, objDicEntry.Value, objDicEntry.Description
            Else
                objResult.Add objDicEntry.Id, objDicEntry.Value
            End If
        End If
    Next
    GetArray = True

    Exit Function
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "GetArray", "IISDictionary.cls", LOG_ERROR
End Function

Friend Property Get Collection() As Collection

    On Error GoTo ErrMgr
    
    

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "GetArray", "IISDictionary.cls", LOG_ERROR
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
    
        GetValue = Me.Item(vntKey)
    Else
        GetValue = varDefaultValue
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
    
    
    Dim i As Long

    For i = 0 To m_MSDictionary.Count - 1

    
        strXML = strXML & vbNewLine
        strXML = strXML & "    <[KEYWORD] id=""" & m_MSDictionary.Keys(i) & """>" & vbNewLine
        strXML = strXML & "        <value>" & m_MSDictionary.Item(i) & "</value>" & vbNewLine
        strXML = strXML & "        <description>" & "</description>" & vbNewLine
        strXML = strXML & "    </[KEYWORD]>" & vbNewLine
    Next

    strXML = strXML & "</[KEYWORD]s>" & vbNewLine
    strXML = Replace(strXML, "[KEYWORD]", strKeyWord)
    
    objTextFile.LogFile strXMLFileName, strXML, True
    
End Function



Public Function Initialize(objMSDictionary As Variant) As Boolean

    Set m_MSDictionary = objMSDictionary
    m_MSDictionary.CompareMode = BinaryCompare
    Initialize = True
End Function


