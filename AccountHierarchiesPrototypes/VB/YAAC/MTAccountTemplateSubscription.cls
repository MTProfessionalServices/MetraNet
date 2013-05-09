VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAccountTemplateSubscription"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit



Public ProductOfferingID As Long
Public GroupSubscription As Boolean
Public GroupSubName As String
Public StartDate As Date
Public EndDate As Date

'hidden
Public Sub Initialize(aCTX As MTSecurityContext, Rs As MTSQLRowset)


    ProductOfferingID = Rs.Value("ID_PO")
    GroupSubscription = Rs.Value("B_GROUP") = "Y"
    GroupSubName = "" & Rs.Value("NM_GROUPSUBNAME")
    StartDate = "" & Rs.Value("VT_START")
    EndDate = "" & Rs.Value("VT_END")
End Sub


Public Function ToString() As String
    ToString = "ProductOfferingID=" & ProductOfferingID & "; GroupSubscription=" & GroupSubscription & "; StartDate=" & StartDate & "; EndDate=" & EndDate & "; GroupSubName=" & GroupSubName
End Function

Friend Function Save(ByVal lngTemplateID As Long) As Boolean

    Dim strSQL As String
    
    strSQL = "INSERT INTO t_acc_template_subs (id_po,id_acc_template,b_group,vt_start,vt_end,nm_groupsubname) values ([ID_PO],[TEMPLATE_ID],'[ISGROUP]',TO_DATE('[STARTDATE]','[DATABASE_DATE_TIME_FORMAT]'),TO_DATE('[ENDDATE]','[DATABASE_DATE_TIME_FORMAT]'),'[GROUPSUBNAME]')"
    strSQL = PreProcess(strSQL, "TEMPLATE_ID", lngTemplateID, "ID_PO", ProductOfferingID, "ISGROUP", IIf(Me.GroupSubscription, "Y", "N"), "STARTDATE", StartDate, "ENDDATE", EndDate, "GROUPSUBNAME", GroupSubName, "DATABASE_DATE_TIME_FORMAT", DATABASE_DATE_TIME_FORMAT)
    SQLExecute strSQL
    Save = True
    

End Function
