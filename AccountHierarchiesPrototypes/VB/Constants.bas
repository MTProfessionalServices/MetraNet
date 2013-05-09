Attribute VB_Name = "Globals"
' Public Const ConnectionString As String = "Data Source=eng-6;Initial Catalog=Netmeter;User ID=sa;Password=;pooling='false';"
Public Enum MTParameterType
  MTTYPE_SMALL_INT = 0
  MTTYPE_INTEGER = 1
  MTTYPE_FLOAT = 2
  MTTYPE_DOUBLE = 3
  MTTYPE_VARCHAR = 4
  MTTYPE_VARBINARY = 5
  MTTYPE_DATE = 6
  MTTYPE_NULL = 7
  MTTYPE_DECIMAL = 8
  MTTYPE_W_VARCHAR = 9
End Enum

Public Enum MTParameterDirection
  INPUT_PARAM = 0
  OUTPUT_PARAM = 1
  IN_OUT_PARAM = 2
  RETVAL_PARAM = 3

End Enum

Private Type GUID
  Data1 As Long
  Data2 As Integer
  Data3 As Integer
  Data4(7) As Byte
End Type


Private Declare Function CoCreateGuid Lib "OLE32.DLL" (pGuid As GUID) As Long
Public Declare Function GetUserName Lib "advapi32.dll" Alias "GetUserNameA" (ByVal lpBuffer As String, nSize As Long) As Long




Public Const COMKioskAuth = "COMKioskAuth.COMKioskAuth.1"
Public Const COMCredentials = "ComCredentials.ComCredentials.1"

Public AccountMetaDataCollection As New Collection
Public RoleMetaDataCollection As New Collection
Public PrincipalPolicyMetaDataCollection As New Collection


Public Function CreateGUID() As String
  Dim udtGUID As GUID

  If (CoCreateGuid(udtGUID) = 0) Then

    CreateGUID = _
    String(8 - Len(Hex$(udtGUID.Data1)), "0") & Hex$(udtGUID.Data1) & _
    String(4 - Len(Hex$(udtGUID.Data2)), "0") & Hex$(udtGUID.Data2) & _
    String(4 - Len(Hex$(udtGUID.Data3)), "0") & Hex$(udtGUID.Data3) & _
    IIf((udtGUID.Data4(0) < &H10), "0", "") & Hex$(udtGUID.Data4(0)) & _
    IIf((udtGUID.Data4(1) < &H10), "0", "") & Hex$(udtGUID.Data4(1)) & _
    IIf((udtGUID.Data4(2) < &H10), "0", "") & Hex$(udtGUID.Data4(2)) & _
    IIf((udtGUID.Data4(3) < &H10), "0", "") & Hex$(udtGUID.Data4(3)) & _
    IIf((udtGUID.Data4(4) < &H10), "0", "") & Hex$(udtGUID.Data4(4)) & _
    IIf((udtGUID.Data4(5) < &H10), "0", "") & Hex$(udtGUID.Data4(5)) & _
    IIf((udtGUID.Data4(6) < &H10), "0", "") & Hex$(udtGUID.Data4(6)) & _
    IIf((udtGUID.Data4(7) < &H10), "0", "") & Hex$(udtGUID.Data4(7))
  End If
End Function

'Stored Proc crap
'typedef enum
'{
'  INPUT_PARAM = 0x00,
'  OUTPUT_PARAM = 0x01,
'  IN_OUT_PARAM = 0x02,
'  RETVAL_PARAM = 0x03
'} MTParameterDirection;
'
'typedef enum
'{
'  MTTYPE_SMALL_INT = 0x00,
'  MTTYPE_INTEGER = 0x01,
'  MTTYPE_FLOAT = 0x02,
'  MTTYPE_DOUBLE = 0x03,
'  MTTYPE_VARCHAR = 0x04,
'  MTTYPE_VARBINARY = 0x05,
'  MTTYPE_DATE = 0x06,
'  MTTYPE_NULL = 0x07,
'  MTTYPE_DECIMAL = 0x08,
'  MTTYPE_W_VARCHAR = 0x09,
'} MTParameterType;
'





Public Function GetCharFromBool(aBool As Boolean) As String

  If aBool = True Then
    GetCharFromBool = "Y"
  Else
    GetCharFromBool = "N"
  End If
End Function

Public Function GetBoolFromChar(aChar As String) As Boolean

  If UCase(aChar) = "Y" Then
    GetBoolFromChar = True
  Else
    GetBoolFromChar = False
  End If
End Function


Private Sub AddPropMeta(coll As Collection, nm As String, cn As String, tp As PropValType, isExtended As Boolean)
    Dim meta As New MTPropertyMetaData
    meta.Name = nm
    meta.DBColumnName = cn
    
    'workaround until sql rowset is fixed:
    If tp = PROP_TYPE_BOOLEAN Then
        tp = PROP_TYPE_STRING
    End If
      
    meta.DataType = tp
    If tp = PROP_TYPE_STRING Then
        meta.Length = 255
    Else
        meta.Length = 10
    End If
    
    meta.DefaultValue = defval
    meta.Extended = isExtended
    coll.Add meta
End Sub

Private Sub LoadMetaData()
  AddPropMeta AccountMetaDataCollection, "ID", "id_prop", PROP_TYPE_INTEGER, False
  AddPropMeta AccountMetaDataCollection, "Name", "tx_name", PROP_TYPE_STRING, False
  AddPropMeta AccountMetaDataCollection, "Description", "tx_desc", PROP_TYPE_STRING, False
  AddPropMeta AccountMetaDataCollection, "PrincipalType", "id_principal_type", PROP_TYPE_INTEGER, False
  
  AddPropMeta RoleMetaDataCollection, "ID", "id_prop", PROP_TYPE_INTEGER, False
  AddPropMeta RoleMetaDataCollection, "Name", "tx_name", PROP_TYPE_STRING, False
  AddPropMeta RoleMetaDataCollection, "Description", "tx_desc", PROP_TYPE_STRING, False
  AddPropMeta RoleMetaDataCollection, "CSRAssignable", "csr_assignable", PROP_TYPE_BOOLEAN, False
  AddPropMeta RoleMetaDataCollection, "SubscriberAssignable", "subscriber_assignable", PROP_TYPE_BOOLEAN, False
  AddPropMeta RoleMetaDataCollection, "PrincipalType", "id_principal_type", PROP_TYPE_INTEGER, False
  
  AddPropMeta PrincipalPolicyMetaDataCollection, "ID", "id_prop", PROP_TYPE_INTEGER, False
  AddPropMeta PrincipalPolicyMetaDataCollection, "Name", "tx_name", PROP_TYPE_STRING, False
  AddPropMeta PrincipalPolicyMetaDataCollection, "Description", "tx_desc", PROP_TYPE_STRING, False
  AddPropMeta PrincipalPolicyMetaDataCollection, "PolicyType", "id_policy_type", PROP_TYPE_INTEGER, False
  AddPropMeta PrincipalPolicyMetaDataCollection, "Principal", "", PROP_TYPE_OPAQUE, False
  AddPropMeta PrincipalPolicyMetaDataCollection, "Roles", "", PROP_TYPE_OPAQUE, False
  AddPropMeta PrincipalPolicyMetaDataCollection, "Capabilities", "", PROP_TYPE_OPAQUE, False
  
End Sub

Public Function HasID(obj As Object) As Boolean
  HasID = obj.ID > 0
End Function

Public Sub Main()
    LoadMetaData
End Sub


Public Function ConnectionString() As String
    
    If UCase$(UserName) = "BORIS" Then
        ConnectionString = "Provider=sqloledb;Data Source=eng-6;Initial Catalog=Netmeter;User Id=sa;Password=;pooling='false';"
    Else
        ConnectionString = "Provider=sqloledb;Data Source=.;Initial Catalog=Netmeter;User Id=sa;Password=;pooling='false';"
    End If
End Function


Public Function UserName() As String
    Dim s1 As String
    s1 = Space(512)
    GetUserName s1, Len(s1)
    If InStr(s1, Chr(0)) <> 0 Then
        s1 = Left(s1, InStr(s1, Chr(0)) - 1)
    End If
    UserName = Trim$(s1)
End Function

Public Function DebugStr(s As String) As String
    DebugStr = s
    Debug.Print s
End Function
