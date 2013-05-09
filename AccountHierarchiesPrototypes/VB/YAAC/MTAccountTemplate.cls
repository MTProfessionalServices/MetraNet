VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAccountTemplate"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private m_objCTX As MTSecurityContext

Public ID                           As Long
Public AccountID                    As Long
Public DateCrt                      As Date
Public Name                         As String
Public Description                  As String
Public ApplyDefaultSecurityPolicy   As Boolean
Public Properties                   As New MTAccountTemplateProperties

Private m_objMTAccountTemplateSubscriptions As MTAccountTemplateSubscriptions
    
Public Property Get Subscriptions() As MTAccountTemplateSubscriptions

    If Not IsValidObject(m_objMTAccountTemplateSubscriptions) Then
    
'        Debug.Assert 0
        Set m_objMTAccountTemplateSubscriptions = New MTAccountTemplateSubscriptions
    End If
    Set Subscriptions = m_objMTAccountTemplateSubscriptions
End Property

Friend Function Initialize(ByVal lngAccountID As Long, ByVal objCtx As MTSecurityContext) As Boolean

    Set m_objCTX = objCtx
    AccountID = lngAccountID
    Initialize = LoadMainMembers() ' we need to load the Template Id when we initialize the template
End Function

Public Function Save() As Boolean


    If Not SaveMainMember() Then Exit Function
    
    If Not SaveProperties() Then Exit Function

    If Not SaveSubscriptions() Then Exit Function
    Save = True
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error", TypeName(Me), "Save"
End Function

Private Function SaveProperties() As Boolean

    Dim strSQL          As String
    Dim objRowset       As MTSQLRowset
    Dim objProperty     As MTAccountTemplateProperty
    
    On Error GoTo ErrMgr
    
    strSQL = "delete from t_acc_template_props where id_acc_template=[TEMPLATE_ID]"
    strSQL = PreProcess(strSQL, "TEMPLATE_ID", Me.ID)
    SQLExecute strSQL
    
    For Each objProperty In Me.Properties
    
        strSQL = "INSERT INTO t_acc_template_props (id_prop,id_acc_template,nm_prop_class,nm_prop,nm_value) select seq_acctemplate.NextVal,[TEMPLATE_ID],'','[NAME]','[VALUE]' from dual"
        strSQL = PreProcess(strSQL, "TEMPLATE_ID", Me.ID, "NAME", objProperty.Name, "VALUE", objProperty.Value)
        SQLExecute strSQL
    Next
    SaveProperties = True
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error", TypeName(Me), "SaveProperties"
End Function

Private Function SaveMainMember() As Boolean

    Dim strSQL          As String
    Dim objRowset       As MTSQLRowset
    Dim objProperty     As MTAccountTemplateProperty
    Dim booNew          As Boolean
    
    On Error GoTo ErrMgr
    
    If Me.ID = 0 Then
    
        strSQL = "INSERT INTO t_acc_template (id_acc_template,id_folder,dt_crt,tx_name,tx_desc,b_applydefaultpolicy) select seq_acctemplate.NextVal,[ACCOUNT_ID],getutcdate(),'[NAME]','[DESCRIPTION]','[APPLYDEFAULTPOLICY]' from dual"
        booNew = True
    Else
        strSQL = "UPDATE t_acc_template Set dt_crt=getutcdate(),tx_name='[NAME]',tx_desc='[DESCRIPTION]',b_applydefaultpolicy='[APPLYDEFAULTPOLICY]' WHERE id_acc_template=[TEMPLATE_ID]"
    End If
    
    
    strSQL = PreProcess(strSQL, "NAME", Me.Name, "DESCRIPTION", Me.Description, "ACCOUNT_ID", Me.AccountID, "APPLYDEFAULTPOLICY", IIf(Me.ApplyDefaultSecurityPolicy, "Y", "N"), "TEMPLATE_ID", Me.ID)
    SQLExecute strSQL
    
    
    ' We need to reload the member value specially the ID so we can update the properties and subscriptions definitions
    If booNew Then LoadMainMembers
    
    SaveMainMember = True
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error", TypeName(Me), "SaveMember"
End Function

Private Function SaveSubscriptions() As Boolean

    Dim strSQL          As String
    Dim objRowset       As MTSQLRowset
    Dim objSubscription As MTAccountTemplateSubscription
    
    On Error GoTo ErrMgr
    
    
    strSQL = "delete from t_acc_template_subs where id_acc_template=[TEMPLATE_ID]"
    strSQL = PreProcess(strSQL, "TEMPLATE_ID", Me.ID)
    SQLExecute strSQL
    
    For Each objSubscription In Me.Subscriptions
    
        objSubscription.Save Me.ID
    Next
    SaveSubscriptions = True
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error", TypeName(Me), "SaveProperties"
End Function


Public Function Load() As Boolean

    On Error GoTo ErrMgr
    
    If Not LoadMainMembers() Then Exit Function
    If Not LoadProperties() Then Exit Function
    
'    Debug.Assert 0
    If Not LoadSubscription() Then Exit Function
    Load = True
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error", TypeName(Me), "Load"
End Function

Private Function LoadProperties() As Boolean

    On Error GoTo ErrMgr
    
    Dim strSQL          As String
    Dim objRowset       As MTSQLRowset
    Dim strPropertyName As String
    
    strSQL = "select * from t_acc_template_props where id_acc_template=[TEMPLATE_ID]"
    strSQL = PreProcess(strSQL, "TEMPLATE_ID", Me.ID)
    Set objRowset = SQLExecute(strSQL)
    
    Properties.Clear

    If IsValidObject(objRowset) Then

        If objRowset.RecordCount Then

            Do While Not objRowset.EOF
            
               Properties.Add objRowset.Value("nm_prop"), objRowset.Value("nm_value")
               objRowset.MoveNext
            Loop
        End If
        LoadProperties = True
    End If
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error", TypeName(Me), "LoadProperties"
End Function


Private Function LoadSubscription() As Boolean

    On Error GoTo ErrMgr
    
    Dim strSQL          As String
    Dim objRowset       As MTSQLRowset
    Dim strPropertyName As String
    Dim objSubscription As MTAccountTemplateSubscription
    
    strSQL = "select * from t_acc_template_subs where id_acc_template=[TEMPLATE_ID]"
    strSQL = PreProcess(strSQL, "TEMPLATE_ID", Me.ID)
    Set objRowset = SQLExecute(strSQL)
    
    Subscriptions.Clear

    If IsValidObject(objRowset) Then

        If objRowset.RecordCount Then

            Do While Not objRowset.EOF
            
               Set objSubscription = Me.Subscriptions.Add()
               objSubscription.Initialize m_objCTX, objRowset
               objRowset.MoveNext
            Loop
        End If
        LoadSubscription = True
    End If
    Exit Function
ErrMgr:

    TRACE App.EXEName & " Error", TypeName(Me), "LoadSubscription"
End Function

Private Function LoadMainMembers() As Boolean

    On Error GoTo ErrMgr
    
    Dim strSQL      As String
    Dim objRowset   As MTSQLRowset

    strSQL = "select * from t_acc_template where id_folder=[ACCOUNT_ID]"
    strSQL = PreProcess(strSQL, "ACCOUNT_ID", Me.AccountID)
    Set objRowset = SQLExecute(strSQL)

    If IsValidObject(objRowset) Then

        If objRowset.RecordCount Then

            ID = objRowset.Value("id_acc_template")
            DateCrt = "" & objRowset.Value("dt_crt")
            Name = "" & objRowset.Value("tx_name")
            Description = "" & objRowset.Value("tx_desc")
            ApplyDefaultSecurityPolicy = "" & UCase$(objRowset.Value("b_ApplyDefaultPolicy")) = "Y"
        End If
        LoadMainMembers = True
    End If
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error", TypeName(Me), "LoadMainMembers"
End Function


Public Function GetSuggestedSubscriptionsAsRowSet(ByVal lngAccountID As Long) As MTSQLRowset
    On Error GoTo ErrMgr
    
    ' -- Carl will write me a nice query
    ' -- For now return just a valid rowset
    Set GetSuggestedSubscriptionsAsRowSet = Me.GetSubscriptionsAsRowSet()
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error", TypeName(Me), "GetSuggestedSubscriptionsAsRowSet"
End Function

Public Function GetSubscriptionsAsRowSet() As MTSQLRowset

    Dim strSQL As String
    
    strSQL = "select * from t_acc_template_subs s, t_base_props p where s.id_acc_Template=[TEMPLATE_ID] and s.id_po=p.id_prop"
    Set GetSubscriptionsAsRowSet = SQLExecute(PreProcess(strSQL, "TEMPLATE_ID", ID))
    Exit Function
ErrMgr:
    TRACE App.EXEName & " Error", TypeName(Me), "GetSubscriptionsAsRowSet", LOG_ERROR
End Function

