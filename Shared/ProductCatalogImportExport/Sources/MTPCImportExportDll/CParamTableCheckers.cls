VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CParamTableChks"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'****************************************************************************************************************************************************
'
' Copyright 1998-2002 by MetraTech Corporation
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
' ****************************************************************************
' CLASS         :
' AUTHOR        : F.Torres
' CREATION DATE : 07/25/2002
' VERSION       :
' DESCRIPTION   :
'*****************************************************************************
Option Explicit

Private mCol As Collection

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Item
' PARAMETERS    :
'                   vntKey - Item key name id or item long index, starting at 1.
' DESCRIPTION   : Returns an item in the collection. This method is the default method
'                 is not case sensitive. Returns <code>Nothing</code> if the item is not found.
' RETURN        :
Public Property Get Item(strName As String) As CParamTableChk
Attribute Item.VB_UserMemId = 0

   On Error GoTo ErrMgr
    Set Item = mCol(UCase$(strName))
   Exit Property
ErrMgr:
   Set Item = Nothing
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Remove
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Remove the item from the collection. The method is not case sensitive.
' RETURN        : Returns TRUE if OK
Public Function Remove(vntKey As Variant) As Boolean

    On Error GoTo ErrMgr
    mCol.Remove vntKey
    Remove = True
    Exit Function
ErrMgr:
'    Debug.Print Err.Description: Debug.Assert False
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
'    Debug.Print Err.Description: Debug.Assert False
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
'    Debug.Print Err.Description: Debug.Assert False
End Property

Private Sub Class_Initialize()

    On Error GoTo ErrMgr
    Set mCol = New Collection

    Exit Sub
ErrMgr:
'    Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Clear
    Set mCol = Nothing

    Exit Sub
ErrMgr:
'    Debug.Print Err.Description: Debug.Assert False
End Sub

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   : Remove all the items in the collection. If the item is no more referenced it is deleted and its destructor
'                 Class_Terminate event is raise.
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr
   

    Do While Count > 0
        Remove 1
    Loop
    Clear = True
    Exit Function
ErrMgr:
'    Debug.Print Err.Description: Debug.Assert False
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Add
' PARAMETERS    :
'                   data - can be the ParameterTableDefinition object or just a parameter table name
' DESCRIPTION   : Add a new item to the collection with the id strId and return and a reference of it.
'                 If the item already exist the function will fail!
' RETURN        : Returns an reference to the new item in the collection or nothing if the function failed
Public Function Add(objPT As MTParamTableDefinition) As CParamTableChk

    On Error GoTo ErrMgr
    
    Dim objParamTableChk As New CParamTableChk
    
    If (Not Me.Exist(objPT.Name)) Then
        objParamTableChk.Name = objPT.Name
        objParamTableChk.ID = objPT.ID
        mCol.Add objParamTableChk, UCase$(objPT.Name)
        Set Add = objParamTableChk
        
        objParamTableChk.LoadCheckSum
        
    Else
        Set Add = Me.Item(objPT.Name)
    End If
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function


' -------------------------------------------------------------------------------
' FUNCTION      : Exist
' PARAMETERS    :
'                   vntKey - Item name id or item long index, starting at 1.
' DESCRIPTION   : Returns TRUE if the item exist in the collection. The method is not case sensitive.
' RETURN        :
Public Function Exist(strName As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim objItem As Object
    Set objItem = mCol(UCase$(strName))
    Exist = True
    Exit Function
ErrMgr:
    Exist = False
    Err.Clear
End Function

Public Function GenerateXML() As Boolean

    Dim ParamTableChk As CParamTableChk
    
'    Debug.Assert 0
    XMLOutPutTag "integrity", XMLTAGTYPE_OPEN
    XMLOutPutTag "parametertables", XMLTAGTYPE_OPEN
    
    For Each ParamTableChk In Me
        XMLOutPutTag "parametertable", XMLTAGTYPE_OPEN, ParamTableChk.Name
        XMLOutPutTagValue "checksum", ParamTableChk.CheckSum
        XMLOutPutTagValue "ID", ParamTableChk.ID
        XMLOutPutTag "parametertable", XMLTAGTYPE_CLOSE
    Next
    XMLOutPutTag "parametertables", XMLTAGTYPE_CLOSE
    XMLOutPutTag "integrity", XMLTAGTYPE_CLOSE
    
    GenerateXML = True
    
End Function

Public Function CheckIntegrityOfXMLFile(strXMLFileName As String, ProductCatalog As MTProductCatalog) As Boolean

    Dim XMLIntegrity            As IXMLDOMNode
    Dim XMLParameterTable       As IXMLDOMNode
    Dim XMLParameterTables      As IXMLDOMNodeList
    Dim objParameterTable       As MTParamTableDefinition
    Dim objTMPParamTableCheck   As New CParamTableChks
    Dim strCurrentDBCheckSum    As String
    Dim strXMLCheckSum          As String
    Dim strParameterTableName   As String
    Dim booRetVal               As Boolean
    
'    Debug.Assert 0
    
    
    PrintConsole MTPCImportExport_MESSAGE_1015
    If Not XMLInputInitialize(strXMLFileName) Then Exit Function
    
    Set XMLIntegrity = XMLDom.selectSingleNode("xmlconfig/integrity")
    
    If IsValidObject(XMLIntegrity) Then
    
        Set XMLParameterTables = XMLDom.selectNodes("xmlconfig/integrity/parametertables/parametertable")
        
        booRetVal = True
        
        For Each XMLParameterTable In XMLParameterTables
            
            strParameterTableName = XMLParameterTable.Attributes.getNamedItem("name").Text
            
            Set objParameterTable = ProductCatalog.GetParamTableDefinitionByName(strParameterTableName)
            If IsValidObject(objParameterTable) Then
            
                objTMPParamTableCheck.Add objParameterTable
                
                strCurrentDBCheckSum = objTMPParamTableCheck.Item(strParameterTableName).CheckSum
                strXMLCheckSum = XMLParameterTable.selectSingleNode("checksum").Text
                
                If strCurrentDBCheckSum = strXMLCheckSum Then
                    INFOOBJECT Nothing, "."
                    MTGlobal_VB_MSG.TRACE PreProcess(MTPCImportExport_MESSAGE_1014, "PT", strParameterTableName, "XMLCHECKSUM", strXMLCheckSum, "SYSTEMCHECKSUM", strCurrentDBCheckSum), Me, "CheckIntegrityOfXMLFile", LOG_INFO
                Else
                    MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1026, "PT", strParameterTableName, "XMLCHECKSUM", strXMLCheckSum, "SYSTEMCHECKSUM", strCurrentDBCheckSum), Me, "CheckIntegrityOfXMLFile", LOG_ERROR
                    booRetVal = False
                    'Exit Function
                End If
            Else
                MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_ERROR_1031, "NAME", strParameterTableName), Me, "CheckIntegrityOfXMLFile", LOG_ERROR
                Exit Function
            End If
        Next
    Else
        MTPCImportExportModule.TRACE PreProcess(MTPCImportExport_WARNING_1013, "FILE", strXMLFileName), Me, "CheckIntegrityOfXMLFile", LOG_WARNING
        booRetVal = True
    End If
    
    CheckIntegrityOfXMLFile = booRetVal
End Function
