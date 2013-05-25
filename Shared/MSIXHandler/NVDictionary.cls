VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "NVDictionary"
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
' CLASS         : Dictionary
' AUTHOR        : F.Torres
' CREATION DATE : 3/3/2001
' VERSION       : 1.0
' DESCRIPTION   :
'*****************************************************************************
Option Explicit

Private m_varValues As Collection
Private m_strNames  As Collection

Public Id           As String
Public Description  As String ' Description of the last xml dictionary file loaded.

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey              - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(vntKey As Variant) As Variant
Attribute Item.VB_UserMemId = 0

   On Error GoTo ErrMgr
   If IsNumeric(vntKey) Then
        Item = m_varValues(vntKey)
   Else
        Item = m_varValues(UCase$(vntKey))
   End If
   Exit Property
ErrMgr:
    TRACE Replace(MTMSIX_ERROR_01057, "[ENTRY]", vntKey), "VNDictionary.cls", "Item", LOG_ERROR
    RaiseError Replace(MTMSIX_ERROR_01057, "[ENTRY]", vntKey), "MTMSIX.Dictionary", , LOG_APPLICATION_ERROR
End Property

Public Property Let Item(vntKey As Variant, varValue As Variant)

   On Error GoTo ErrMgr
   Add vntKey, varValue
   Exit Property
ErrMgr:
    TRACE Replace(MTMSIX_ERROR_01057, "[ENTRY]", vntKey), "VNDictionary.cls", "Item", LOG_ERROR
    RaiseError Replace(MTMSIX_ERROR_01057, "[ENTRY]", vntKey), "MTMSIX.Dictionary", , LOG_APPLICATION_ERROR
End Property

Public Property Get Items(lngIndex As Long) As Variant
    On Error GoTo ErrMgr

    Items = m_varValues(lngIndex)
    Exit Property
ErrMgr:
    TRACE Replace(MTMSIX_ERROR_01057, "[ENTRY]", "" & lngIndex), "VNDictionary.cls", "Items", LOG_ERROR
    RaiseError Replace(MTMSIX_ERROR_01057, "[ENTRY]", "" & lngIndex), "MTMSIX.Dictionary", , LOG_APPLICATION_ERROR
End Property

Public Property Get Names(lngIndex As Long) As String
    On Error GoTo ErrMgr

    Names = m_strNames(lngIndex)
    Exit Property
ErrMgr:
    TRACE Replace(MTMSIX_ERROR_01057, "[ENTRY]", "" & lngIndex), "VNDictionary.cls", "Items", LOG_ERROR
    RaiseError Replace(MTMSIX_ERROR_01057, "[ENTRY]", "" & lngIndex), "MTMSIX.Dictionary", , LOG_APPLICATION_ERROR
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Removes the item from the collection. The method is not case sensitive.
' RETURN        : Returns TRUE if Ok.
Public Function Remove(vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    m_varValues.Remove vntKey
    m_strNames.Remove vntKey
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
    Count = m_varValues.Count
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
    Set NewEnum = m_varValues.[_NewEnum]
    Exit Property
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Property


Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    Set m_varValues = New Collection
    Set m_strNames = New Collection
    Exit Sub
ErrMgr:
    'Debug.Print Err.Description: Debug.Assert False
End Sub


Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Clear
    Set m_varValues = Nothing
    Set m_strNames = Nothing
    
    TRACE "Dictionary", "Dictionary", "Class_Terminate", LOG_DEBUG
    
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
    
    TRACE MTMSIX_ERROR_01079, "VNDictionary.cls", "Clear", LOG_DEBUG

    Do While Count > 0
    
        m_varValues.Remove 1
        m_strNames.Remove 1
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
Public Function Add(ByVal strName As String, Optional ByVal varValue As Variant) As Variant

    On Error GoTo ErrMgr
    
    If (Me.Exist(strName)) Then Me.Remove strName
        
    If (IsMissing(varValue)) Then varValue = Empty
    
    m_varValues.Add varValue, UCase(strName)
    m_strNames.Add strName, UCase(strName)
  
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

    Dim i As Long
    Dim strS    As String
    
    For i = 1 To Count
        strS = strS & "name=" & m_strNames(i) & "; value=" & m_varValues(i) & vbCrLf
    Next
    ToString = strS

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "VNDictionary.cls", "ToString", LOG_ERROR
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
    
    objProfiler.Start MTMSIX_PROFILER_ON, "VNDictionary.cls", "LoadXMLFile", "XMLFileName=" & strXMLFileName
    
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
        TRACE strTrace, "VNDictionary.cls", "LoadXMLFile", IIf(booRetVal, LOG_WARNING, LOG_ERROR)
    End If
Return
    
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "VNDictionary.cls", "ToString", LOG_ERROR
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : Exist
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Returns TRUE if the item exist in the collection. The method is not case sensitive.
' RETURN        :
Public Function Exist(ByVal vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    
    Dim varItem As Variant
    
    If IsNumeric(vntKey) Then
        varItem = m_varValues(vntKey)
    Else
        varItem = m_varValues(UCase$(vntKey))
    End If
    Exist = True
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
            
                TRACE Replace(MTMSIX_ERROR_01018, "[NAME]", objFile.Value), "VNDictionary.cls", "LoadFolder", LOG_ERROR
                LoadFolder = False
                Exit Function
            End If
        Next
    End If
    
  
    
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "VNDictionary.cls", "LoadFolder", LOG_ERROR
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
    For i = 1 To Count
    
        s = Replace(s, charStart & m_strNames(i) & charEnd, m_varValues(i))
    Next
    PreProcess = s

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "VNDictionary.cls", "PreProcess", LOG_ERROR
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
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "VNDictionary.cls", "IsALinkFile", LOG_ERROR
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
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "VNDictionary.cls", "IsATextFile", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function Render() As Boolean

    On Error GoTo ErrMgr

    Dim i As Long
    
    For i = 1 To Count
    
        Item(m_strNames(i)) = Me.PreProcess(m_varValues(i))
    Next
    Render = True
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "VNDictionary.cls", "PreProcess", LOG_ERROR
End Function




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
        GetValue = varDefaultValue
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
    Dim i               As Long
        
    strXMLFileName = strFileName
    
    strXML = strXML & "<?xml version=""1.0"" encoding=""UTF-8""?>" & vbNewLine
    strXML = strXML & "<[KEYWORD]s id=""Main"" type=""collection"">" & vbNewLine
    
    For i = 1 To Count
    
        strXML = strXML & vbNewLine
        strXML = strXML & "    <[KEYWORD] id=""" & m_strNames(i) & """>" & vbNewLine
        strXML = strXML & "        <value>" & m_varValues(i) & "</value>" & vbNewLine
        strXML = strXML & "        <description></description>" & vbNewLine
        strXML = strXML & "    </[KEYWORD]>" & vbNewLine
    Next

    strXML = strXML & "</[KEYWORD]s>" & vbNewLine
    strXML = Replace(strXML, "[KEYWORD]", strKeyWord)
    
    objTextFile.LogFile strXMLFileName, strXML, True
    
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


