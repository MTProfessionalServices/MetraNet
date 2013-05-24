VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CCustomer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Const MDBFileName = "G:\PMSWEB\W3RunnerWeb.WriteAccess\w3runner.demo.mdb"

Public Function Add( _
ByVal strLastName As String, ByVal strFirstName As String, ByVal strMiddleName As String, _
ByVal strOwner As String, ByVal strAddress As String, ByVal strCity As String, ByVal strZipCode As String, _
ByVal strState As String, ByVal strType As String, ByVal strCountry As String, ByVal strEmail As String, ByVal booTaxExempt As Boolean _
) As Long
    
    Dim DB      As New CDB
    Dim strSQL  As String
    Dim objRST  As Object
    
    Debug.Assert 0
    
    strSQL = "insert into t_customer (CreationDate,LastName , FirstName, MiddleName, Address, City, Zip, State, Country, TaxExempt, CustomerType, Owner, EMail)values('[Now]','[LastName]' , '[FirstName]', '[MiddleName]', '[Address]', '[City]', '[Zip]', '[State]', '[Country]', '[TaxExempt]', '[CustomerType]', '[Owner]', '[EMail]') "
    strSQL = PreProcess(strSQL, "Now", Now(), "LastName", strLastName, "FirstName", strFirstName, "MiddleName", strMiddleName, "Address", strAddress, "City", strCity, "Zip", strZipCode, "State", strState, "Country", strCountry, "CustomerType", strType, "Owner", strOwner, "EMail", strEmail, "Now", Now(), "TaxExempt", Abs(booTaxExempt))
    
    'DB.Server = "."
    'DB.Database = "W3Runner"
    'DB.Login = "W3RunnerDemo"
    'DB.PassWord = "W3RunnerDemoDB1234"
    DB.MDBFileName = MDBFileName
    DB.OpenDB
    
    If Not DB.OpenDB() Then Exit Function

    If (DB.SqlRun(strSQL, Nothing)) Then
    
            strSQL = "select max(id) from t_customer"
            Set objRST = DB.SqlRun(strSQL, DB.NewRecordset())
            
            If Not objRST Is Nothing Then
            
                Add = objRST.Fields(0).Value
            End If
    End If
    DB.CloseDB
    
End Function

Public Function RaiseError(ByVal lngError As Long, ByVal strMessage As String) As Boolean
    If lngError = 0 Then
        RaiseError = True
    Else
        Err.Raise lngError, , strMessage
    End If
End Function
