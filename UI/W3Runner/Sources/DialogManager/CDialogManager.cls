VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CDialogManager"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_objForm   As Form
Private m_objCOMObject As Object

Public TableName As String
Public IDColumnName As String


Public DateTimeFormat As String

Private m_objCurrentConfigIniFile As New cIniFile


Public Function Initialize(objForm As Form, objCOMObject As Object, ByVal strTableName As String) As Boolean

    Set m_objForm = objForm
    Set m_objCOMObject = objCOMObject
    TableName = strTableName
    Initialize = True
End Function

Public Function PopulateCOMObject() As Boolean
    Dim C As Control
    
    For Each C In m_objForm
    
        Select Case UCase(TypeName(C))
        
            Case "COMBOBOX":

                If COMPropertyExist(m_objCOMObject, C.Name) Then
                
                    If COMPropertyType(m_objCOMObject, C.Name) = vbString Then
                    
                        COMProperty(m_objCOMObject, C.Name) = C.Text
                    Else
                         COMProperty(m_objCOMObject, C.Name) = C.itemData(C.ListIndex)
                    End If
                End If
            Case "TEXTBOX":
            
                    If COMPropertyExist(m_objCOMObject, C.Name) Then COMProperty(m_objCOMObject, C.Name) = C.Text
                    
            Case "CHECKBOX": If COMPropertyExist(m_objCOMObject, C.Name) Then COMProperty(m_objCOMObject, C.Name) = C.Value = vbChecked
            Case "OPTIONBUTTON": If COMPropertyExist(m_objCOMObject, C.Name) Then If C.Value Then COMProperty(m_objCOMObject, C.Name) = C.Index
        End Select
    Next
    PopulateCOMObject = True
End Function

Public Function PopulateDialog() As Boolean

    Dim C As Control
    Dim b As Object
    
    On Error GoTo errmgr
    
    For Each C In m_objForm
    
        Debug.Print UCase(TypeName(C)) & " " & C.Name
        Select Case UCase(TypeName(C))
        
            Case "COMBOBOX":
                If COMPropertyExist(m_objCOMObject, C.Name) Then
                
                    If C.ListCount = 0 And m_objCOMObject.IsFK(C.Name) Then
                        
                        DBListManager.Item(m_objCOMObject.FKListName(C.Name)).PopulateBox C
                    End If
                    If COMPropertyType(m_objCOMObject, C.Name) = vbString Then
                    
                        If C.style = vbComboDropdownList Then
                            LB_SelectByText C, COMProperty(m_objCOMObject, C.Name)
                        Else
                            C.Text = COMProperty(m_objCOMObject, C.Name)
                        End If
                    Else
                        'If COMProperty(m_objCOMObject, C.Name) = -1 Then ' if no item selectionned select the first one
                         '   C.ListIndex = 0
                        'End If
                        
                        LB_SelectByItemData C, COMProperty(m_objCOMObject, C.Name)
                    End If
                End If
                    
            Case "TEXTBOX":  If COMPropertyExist(m_objCOMObject, C.Name) Then C.Text = COMProperty(m_objCOMObject, C.Name)
            
            Case "LABEL": If COMPropertyExist(m_objCOMObject, C.Name) Then C.Caption = COMProperty(m_objCOMObject, C.Name)
            
            Case "CHECKBOX": If COMPropertyExist(m_objCOMObject, C.Name) Then C.Value = IIf(COMProperty(m_objCOMObject, C.Name), vbChecked, vbUnchecked)
            
            Case "OPTIONBUTTON": If COMPropertyExist(m_objCOMObject, C.Name) Then If CLng(COMProperty(m_objCOMObject, C.Name)) = C.Index Then C.Value = True
        End Select
    Next
    PopulateDialog = True
    Exit Function
errmgr:

    If IsValidObject(C) Then
        FShowError PreProcess(DBDialogManager_ERROR_1001, "DETAILS", GetVBErrorString(), "FIELD", C.Name), Me, "PopulateDialog"
    Else
        FShowError PreProcess(DBDialogManager_ERROR_1002, "DETAILS", GetVBErrorString()), Me, "PopulateDialog"
    End If
End Function



Private Function GetFields() As Collection

   Dim C            As Control
   Dim objFields    As New Collection
   
   Set GetFields = objFields ' Set the result
    
    For Each C In m_objForm
    
        Select Case UCase(TypeName(C))
        
            Case "OPTIONBUTTON", "CHECKBOX", "LABEL", "TEXTBOX", "COMBOBOX":
            
                If COMPropertyExist(m_objCOMObject, C.Name) Then
                
                    On Error Resume Next
                    objFields.Add C.Name, C.Name
                    On Error GoTo 0
                End If
        End Select
    Next
    
End Function

Public Function UpdateSQLFromDialog(ByVal booInsert As String) As Boolean

    Dim strSQL          As String
    Dim objFields       As Collection
    Dim strFieldName    As Variant
    Dim strValue        As String
        
    If booInsert Then
        UpdateSQLFromDialog = InsertSQL()
        Exit Function
    End If
    
    strSQL = "update " & TableName & " set "
    
    Set objFields = GetFields()
    For Each strFieldName In objFields
    
        Select Case COMPropertyType(m_objCOMObject, strFieldName)
            Case vbString, vbDate
                strValue = "'" & Replace(COMProperty(m_objCOMObject, strFieldName), ",", Chr(1)) & "'"
                strValue = Replace(strValue, Chr(1), "''")
            Case Else
                strValue = COMProperty(m_objCOMObject, strFieldName)
        End Select
        
        strSQL = strSQL & strFieldName & "=" & strValue & ","
    Next
    strSQL = Mid(strSQL, 1, Len(strSQL) - 1)
    strSQL = strSQL & " where " & IDColumnName & "=" & COMProperty(m_objCOMObject, IDColumnName)
    UpdateSQLFromDialog = g_objDB.SqlRun(strSQL, Empty)
    
End Function

Public Function InsertSQL() As Boolean
    InsertSQL = True
End Function

Private Sub Class_Initialize()
    IDColumnName = "id"
    DateTimeFormat = "yyyy/mm/dd hh"
End Sub

Public Sub PopulateListBox(strSQL As String, lb As Variant, strFieldName As String, Optional strIndexFieldName As String, Optional booClear As Boolean = True)

    Dim objRST As Variant
    
    If booClear Then lb.Clear
    
    Set objRST = g_objDB.SqlRun(strSQL, g_objDB.NewRecordset())
    
    If IsValidObject(objRST) Then
    
        If Not objRST.BOF() Then
        
            Do While Not objRST.EOF()
            
                If Len("" & objRST.Fields(strFieldName).Value) Then
                
                    #If DM_DEBUG Then
                        lb.AddItem objRST.Fields(strIndexFieldName).Value & " " & objRST.Fields(strFieldName).Value
                    #Else
                        lb.AddItem objRST.Fields(strFieldName).Value
                    #End If
                    
                    If Len(strIndexFieldName) Then
                    
                        lb.itemData(lb.NewIndex) = objRST.Fields(strIndexFieldName).Value
                    End If
                End If
                objRST.MoveNext
            Loop
        End If
    End If
End Sub

Public Function LoadInstance(ByVal lngID As Long, Optional objRST As Variant) As Boolean

    Dim strSQL  As String
    Dim i       As Long
    
    If IsMissing(objRST) Then
    
        strSQL = PreProcess(CDialogManager_SQL_SELECT_RECORD_BY_ID, "TABLENAME", Me.TableName, "ID", lngID, "IDCOLUMN", IDColumnName)
        Set objRST = g_objDB.SqlRun(strSQL, g_objDB.NewRecordset())
    End If
    If IsValidObject(objRST) Then
    
        If objRST.RecordCount = 1 Then
        
            For i = 0 To objRST.Fields.Count - 1
            
                COMProperty(m_objCOMObject, objRST.Fields(i).Name) = objRST.Fields(i).Value
            Next
            LoadInstance = True
        End If
    End If
End Function


Public Function SaveInstance(ByVal lngID As Long, Optional strPropertyName As String) As Boolean

    Dim strSQL          As String
    Dim strFields       As String
    Dim strValues       As String
    Dim objRST          As Variant
    
    If m_objCOMObject.ID = -1 Then
    
        GetInsertStringsFromCOMObject strFields, strValues
        strSQL = PreProcess(CDialogManager_SQL_INSERT_RECORD_BY_ID, "TABLENAME", Me.TableName, "ID", lngID, "IDCOLUMN", IDColumnName, "FIELDS", strFields, "VALUES", strValues)
        
        If g_objDB.SqlRun(strSQL, Empty) Then
        
            strSQL = PreProcess(CDialogManager_SQL_GET_NEW_ID, "TABLENAME", Me.TableName, "ID", lngID, "IDCOLUMN", IDColumnName, "FIELDS", strFields, "VALUES", strValues)
            Set objRST = g_objDB.SqlRun(strSQL, g_objDB.NewRecordset())
            
            If IsValidObject(objRST) Then
            
                If objRST.RecordCount Then
                
                    m_objCOMObject.ID = objRST.Fields(0).Value
                    SaveInstance = Me.LoadInstance(m_objCOMObject.ID)
                    Exit Function
                End If
            End If
            FShowError PreProcess(DBDialogManager_ERROR_1004), Me, "SaveInstance"
        End If
    Else
    
        strSQL = PreProcess(CDialogManager_SQL_UPDATE_RECORD_BY_ID, "TABLENAME", Me.TableName, "ID", lngID, "IDCOLUMN", IDColumnName, "FIELDS", GetSetStringFromCOMObject(strPropertyName))
        SaveInstance = g_objDB.SqlRun(strSQL, Empty)
    End If
    
    
    
    
    
End Function

Private Function GetSetStringFromCOMObject(Optional strPropertyName As String) As String
     
    Dim v             As Variant
    Dim arrProperties As Variant
    Dim strFields     As String
    Dim varValue      As Variant
    
    arrProperties = Split(m_objCOMObject.PropertiesList, ",")
    
    For Each v In arrProperties
    
        If LCase$(v) = LCase(strPropertyName) Or Len(strPropertyName) = 0 Then
    
            varValue = COMProperty(m_objCOMObject, v)
            
            If IsNull(varValue) Or Len(varValue) = 0 Then
            
                strFields = strFields & v & "=NULL,"
            Else
            
                Select Case COMPropertyType(m_objCOMObject, v)
                
                    Case vbString, vbDate
                        varValue = Replace(varValue, "'", Chr(1))
                        varValue = Replace(varValue, Chr(1), "''")
                        strFields = strFields & v & "='" & varValue & "',"
                    Case Else
                        strFields = strFields & v & "=" & varValue & ","
                End Select
            End If
        End If
    Next
    If Len(strFields) Then strFields = Mid(strFields, 1, Len(strFields) - 1)
    
    GetSetStringFromCOMObject = strFields
    
End Function


Private Function GetInsertStringsFromCOMObject(ByRef strFields As String, strValues As String) As Boolean
     
    Dim v             As Variant
    Dim arrProperties As Variant
    Dim varValue      As Variant
    
    arrProperties = Split(m_objCOMObject.PropertiesList, ",")
    
    For Each v In arrProperties
        
        strFields = strFields & v & ","
        varValue = COMProperty(m_objCOMObject, v)
        
        If IsNull(varValue) Or Len(varValue) = 0 Then
        
            strValues = strValues & "NULL,"
        Else
        
            Select Case COMPropertyType(m_objCOMObject, v)
            
                Case vbString, vbDate
                    strValues = strValues & "'" & varValue & "',"
                Case Else
                    strValues = strValues & "" & varValue & ","
            End Select
        End If
    Next
    If Len(strFields) Then strFields = Mid(strFields, 1, Len(strFields) - 1)
    If Len(strValues) Then strValues = Mid(strValues, 1, Len(strValues) - 1)
    
    GetInsertStringsFromCOMObject = True
    
End Function



Public Function DeleteInstance(ByVal lngID As Long) As Boolean

    Dim strSQL          As String
    
    strSQL = PreProcess(CDialogManager_SQL_DELETE_RECORD_BY_ID, "TABLENAME", Me.TableName, "ID", lngID, "IDCOLUMN", IDColumnName)
    DeleteInstance = g_objDB.SqlRun(strSQL, Empty)
    
End Function


Public Function FillListView(objObject As Object, lv As ListView, strSQL As String, objDBListManager As CDBListManager, strIniFileConfigName As String, Optional arrIcons As Variant, Optional strIconColumnName As String) As Long

    Dim objRST          As Variant
    Dim objListItem     As ListItem
    Dim i               As Long
    Dim strListName     As String
    Dim lngColIndex     As Long
    Dim arrColOrder(0 To 128) As Long
    Dim lngTmpIndex     As Long
    Dim objDBListItem   As CDBListItem
    Dim strID           As String
    Dim strIcon         As String
    
    On Error GoTo errmgr

    lv.Enabled = False
    lv.Visible = False
    m_objCurrentConfigIniFile.Init App.path & "\" & strIniFileConfigName & ".config.ini"
    
    lv.Parent.Status DBDialogManager_MSG_1000
    
    Set objRST = g_objDB.SqlRun(strSQL, g_objDB.NewRecordset())
    
    
    TRACER.DebugOut strSQL, trcDEBUG, Me, "FillListView"
    TRACER.DebugOut "objRST.RecordCount=" & objRST.RecordCount, trcDEBUG, Me, "FillListView"
    
    lv.ListItems.Clear
    
    If IsValidObject(objRST) Then
    
        If Not objRST.EOF Then
        
            lv.Parent.Status DBDialogManager_MSG_1001
        
            lv.ColumnHeaders.Clear
            
            For i = 0 To objRST.Fields.Count - 1
            
                arrColOrder(i) = ListViewGetNextColumn(objRST, i + 1)
            Next
        
            For i = 0 To objRST.Fields.Count - 1
            
                If arrColOrder(i) <> 0 Then
                
                
                    lngTmpIndex = arrColOrder(i) - 1
                    lv.ColumnHeaders.Add , objRST.Fields(lngTmpIndex).Name, Config(objRST.Fields(lngTmpIndex).Name & ".Name", objRST.Fields(lngTmpIndex).Name)
                    GoSub SizeColumn
                End If
            Next
            Do While Not objRST.EOF
                
                ' -- columns id is mandatory --

                strID = objRST.Fields(IDColumnName).Value
'                Debug.Print strID

                If IsNumeric(strIconColumnName) Then
                    strIcon = arrIcons(strIconColumnName)
                Else
                    If Len(strIconColumnName) Then
                        strIcon = arrIcons(objRST.Fields(strIconColumnName).Value)
                    Else
                        strIcon = arrIcons(0)
                    End If
                End If

                Set objListItem = lv.ListItems.Add(, "id" & strID, strID, , strIcon)
                
                For i = 1 To objRST.Fields.Count - 1 ' skip the first column id
                
                    If arrColOrder(i) <> 0 Then

                        lngTmpIndex = arrColOrder(i) - 1

                        If objObject.IsFK(objRST.Fields(lngTmpIndex).Name) Then ' FK in a list

                            strListName = objObject.FKListName(objRST.Fields(lngTmpIndex).Name)

                            Set objDBListItem = objDBListManager.Item(strListName).ItemByID(objRST.Fields(lngTmpIndex).Value)
                            If IsValidObject(objDBListItem) Then
                            
                                #If DM_DEBUG Then
                                    objListItem.SubItems(i) = ReplaceCRLF("" & objDBListItem.ID & "-" & objDBListItem.Name)
                                #Else
                                    objListItem.SubItems(i) = ReplaceCRLF("" & objDBListItem.Name)
                                #End If
                            End If
                        Else
                            Select Case COMPropertyType(objObject, objRST.Fields(lngTmpIndex).Name)
                                Case vbDate
                                    objListItem.SubItems(i) = ReplaceCRLF(Format(objRST.Fields(lngTmpIndex).Value, Me.DateTimeFormat))
                                Case Else
                                    objListItem.SubItems(i) = ReplaceCRLF("" & objRST.Fields(lngTmpIndex).Value)
                            End Select
                        End If
                    End If
                Next
                objRST.MoveNext
            Loop
            FillListView = objRST.RecordCount
        End If
    End If
    
TheExit:

    lv.Enabled = True
    lv.Visible = True
    Exit Function
    
SizeColumn:

    lv.ColumnHeaders.Item(i + 1).Width = Config(objRST.Fields(lngTmpIndex).Name & ".Size", lv.ColumnHeaders.Item(i + 1).Width)
Return
    
errmgr:

'    Debug.Assert 0
    MsgBox GetVBErrorString()
    GoTo TheExit
End Function


Private Function ListViewGetNextColumn(objRST As Variant, lngIndex As Long) As Long

    Dim i As Long
    
    ListViewGetNextColumn = 0
    
    For i = 0 To objRST.Fields.Count - 1
    
        'Debug.Print objRST.fields(i).Name & ".Visible=" & Config(objRST.fields(i).Name & ".Visible")
    
        If Config(objRST.Fields(i).Name & ".Visible") = "" & (lngIndex) Then  ' rowset are 0 based
        
            ListViewGetNextColumn = i + 1
            Exit Function
        End If
    Next
End Function



Public Property Get Config(strName As String, Optional ByVal defaultValue As Variant) As String

    Dim s As String
    
    s = m_objCurrentConfigIniFile.getVar("CONFIG", strName)
    
    If (Len(s)) Then
    
        Config = s
    Else
        If (IsMissing(defaultValue)) Then
            Config = ""
        Else
            Config = defaultValue
        End If
    End If
End Property


Public Function ClearInstance() As Boolean

    Dim v             As Variant
    Dim arrProperties As Variant
    Dim varValue      As Variant
    
    arrProperties = Split(m_objCOMObject.PropertiesList, ",")
    
    For Each v In arrProperties
    
        If m_objCOMObject.IsFK("" & v) Then
        
            COMProperty(m_objCOMObject, v) = -1
        Else
            
            Select Case COMPropertyType(m_objCOMObject, v)
            
                Case vbString, vbDate
                    COMProperty(m_objCOMObject, v) = ""
                Case Else
                    COMProperty(m_objCOMObject, v) = 0
            End Select
        End If
    Next
    m_objCOMObject.ID = -1
    ClearInstance = True
End Function


Public Function DeleteAllInstance() As Boolean

    Dim strSQL          As String

    strSQL = PreProcess(CDialogManager_SQL_DELETE_ALL_RECORD, "TABLENAME", Me.TableName)
    DeleteAllInstance = g_objDB.SqlRun(strSQL, Empty)
    
End Function

Public Function CheckRequiredProperties() As Boolean
    Dim v             As Variant
    Dim arrProperties As Variant
    Dim varValue      As Variant
    
    arrProperties = Split(m_objCOMObject.RequiredPropertiesList, ",")
    
    For Each v In arrProperties
        
        varValue = COMProperty(m_objCOMObject, v)
        If Len("" & varValue) = 0 Then
            FShowError PreProcess(DBDialogManager_ERROR_1003, "FIELD", v)
            Exit Function
        End If
    Next
    CheckRequiredProperties = True
End Function

Private Function ReplaceCRLF(ByVal s As String) As String
    
    s = Replace(s, vbCr, "<br>")
    ReplaceCRLF = Replace(s, vbLf, "")
End Function

Public Property Get DBListManager() As CDBListManager
   Set DBListManager = g_static_objDBListManager
End Property

