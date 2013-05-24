VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CKey"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public CompanyName As String
Public Address As String
Public state As String
Public City As String
Public Zip As String
Public Country As String
Public email As String
Public KeyDate As String
Public KeySource As String
Public Key As String
Public LicenceID As String
Public LicenceCounter As String

Public Function InitFromDialog(f As Variant) As Boolean

    CompanyName = f.CompanyName
    Address = f.Address
    state = f.state
    City = f.City
    Zip = f.Zip
    email = f.email
    Country = Mid(f.Country.Text, 1, 2)
    KeyDate = f.KeyDate
    Me.LicenceID = f.LicenceID
End Function

Public Function Create() As Boolean

    Me.KeySource = ""
    Me.KeySource = Me.KeySource & Me.CompanyName & ";"
    'Me.KeySource = Me.KeySource & Me.Address & ";"
    'Me.KeySource = Me.KeySource & Me.state & ";"
    'Me.KeySource = Me.KeySource & Me.City & ";"
    Me.KeySource = Me.KeySource & Me.Zip & ";"
    Me.KeySource = Me.KeySource & Me.Country & ";"
    Me.KeySource = Me.KeySource & Me.email & ";"
    Me.KeySource = Me.KeySource & Me.LicenceID & ";"
    Me.KeySource = Me.KeySource & Me.LicenceCounter & ";"
    
    Me.KeySource = UCase(Me.KeySource) ' All upper case
    
    Create = Crypte()
End Function

Public Function ParseSourceCode() As Boolean

    Dim v As Variant
    
    v = Split(Me.KeySource, ";")
    
    Me.CompanyName = v(0)
'    Me.Address = v(1)
 '   Me.state = v(2)
  '  Me.City = v(3)
    Me.Zip = v(1)
    Me.Country = v(2)
    Me.email = v(3)
    Me.LicenceID = v(4)
    Me.LicenceCounter = v(5)
    
    ParseSourceCode = True
     
End Function


Public Function Crypte() As Boolean

    Dim i           As Long
    Dim bytChar     As Byte
    Dim lngCRC      As Long
    
    Me.Key = ""
    For i = 1 To Len(Me.KeySource)
    
        bytChar = Asc(Mid(Me.KeySource, i, 1))
        If (i Mod 2) = 0 Then ' pair
            bytChar = bytChar Xor (1 + 32)
        Else
            bytChar = bytChar Xor (2 + 64)
        End If
        If bytChar <= 15 Then
            Me.Key = Me.Key & "0" & Hex(bytChar)
        Else
            Me.Key = Me.Key & Hex(bytChar)
        End If
        lngCRC = lngCRC + bytChar 'Asc(Mid(Me.KeySource, i, 1))
    Next
    Me.Key = Format(Len(Me.KeySource) * 3, "0000") & "-" & Me.Key & "-" & lngCRC
    Crypte = True
End Function

Public Function ShowKeyToDialog(f As Variant) As Boolean
    f.Key = Me.Key
    f.KeySource = Me.KeySource
End Function

Public Function SaveForm(f As Form) As Boolean

    Dim objIniFile As New cIniFile
    objIniFile.Init App.path & "\dbkeys\" & CompanyName & ".key.ini"
    objIniFile.setForm f
End Function

Public Function DeCrypte() As Boolean

    Dim i           As Long
    Dim bytChar     As Byte
    Dim bytChar2    As Byte
    Dim lngCRC      As Long
    Dim lngPos      As Long
    Dim lngPos2     As Long
    Dim lngSourceKeyLen As Long
    Dim lngStrIndex As Long
    Dim lngKeyCRC As Long
    
    On Error GoTo errmgr
    
    
    
    
    lngPos = InStr(Key, "-")
    If lngPos = 0 Then Exit Function
    
    lngSourceKeyLen = CLng(Mid(Key, 1, lngPos - 1)) / 3
    
    lngPos2 = InStr(lngPos + 1, Key, "-")
    If lngPos = 0 Then Exit Function
    lngKeyCRC = CLng(Mid(Key, lngPos2 + 1))
    Me.KeySource = ""
    lngStrIndex = lngPos + 1
    
    For i = 1 To lngSourceKeyLen
    
        bytChar = CLng("&h" & Mid(Me.Key, lngStrIndex, 2))
        bytChar2 = bytChar
        If (i Mod 2) = 0 Then ' pair
            bytChar = bytChar Xor (1 + 32)
        Else
            bytChar = bytChar Xor (2 + 64)
        End If
        Me.KeySource = Me.KeySource & Chr(bytChar)
        lngCRC = lngCRC + bytChar2
        lngStrIndex = lngStrIndex + 2
    Next
    DeCrypte = CBool(lngCRC = lngKeyCRC) And CBool(lngKeyCRC > 0)
    
    ParseSourceCode
    
    Exit Function
errmgr:
End Function

Public Function EmailText() As String
    Dim strText As String
    
    strText = strText & "Dear client thanks for purchasing W3Runner." & vbNewLine
    strText = strText & vbNewLine
    strText = strText & "Here is your Registration Information:" & vbNewLine
    strText = strText & vbNewLine
    strText = strText & Me.CompanyName & vbNewLine
    strText = strText & Me.Address & vbNewLine
    strText = strText & Me.City & ", " & Me.state & ", " & Me.Zip & vbNewLine
    strText = strText & Me.Country & vbNewLine
    strText = strText & Me.KeyDate & vbNewLine
    strText = strText & Me.LicenceID & vbNewLine
    strText = strText & vbNewLine
    strText = strText & "Registration Key : " & Me.Key & vbNewLine
    ClipBoard.Clear
    ClipBoard.SetText strText
    EmailText = strText

End Function

Public Function PopulateForm(f As Variant) As Boolean

    f.CompanyName = CompanyName
    f.Address = Address
    f.state = state
    f.City = City
    f.Zip = Zip
    f.email = email
    f.Country = Country
    f.KeyDate = KeyDate
    f.LicenceID = LicenceID

End Function


Public Function ToString() As String

    ToString = PreProcess("[COMPANYNAME][CRLF][EMAIL][CRLF][ADDRESS], [CITY], [STATE], [ZIP], [COUNTRY][CRLF]License ID [LICENCEID] - License Counter [LICENCECOUNTER]", "CRLF", vbNewLine, _
        "COMPANYNAME", Me.CompanyName, "EMAIL", Me.email, "ADDRESS", Me.Address, "CITY", Me.City, "STATE", Me.state, "ZIP", Me.Zip, "COUNTRY", Me.Country, "LICENCEID", Me.LicenceID, "LICENCECOUNTER", Me.LicenceCounter)
End Function


Public Function AboutBoxInfo() As String

    AboutBoxInfo = PreProcess("[COMPANYNAME][CRLF][EMAIL][CRLF][ZIP], [COUNTRY][CRLF]License ID [LICENCEID] - License Counter [LICENCECOUNTER]", "CRLF", vbNewLine, _
        "COMPANYNAME", Me.CompanyName, "EMAIL", Me.email, "ADDRESS", Me.Address, "CITY", Me.City, "STATE", Me.state, "ZIP", Me.Zip, "COUNTRY", Me.Country, "LICENCEID", Me.LicenceID, "LICENCECOUNTER", Me.LicenceCounter)
End Function


Private Sub Class_Initialize()
    Me.LicenceID = GetTickCount()
End Sub

Public Function Log(ByVal strFileName As String) As Boolean

    Dim strCSV As String
    
    strCSV = ""
    strCSV = strCSV & """" & Me.KeyDate & ""","
    strCSV = strCSV & """" & Me.CompanyName & ""","
    strCSV = strCSV & """" & Me.Address & ""","
    strCSV = strCSV & """" & Me.state & ""","
    strCSV = strCSV & """" & Me.City & ""","
    strCSV = strCSV & """" & Me.Zip & ""","
    strCSV = strCSV & """" & Me.Country & ""","
    strCSV = strCSV & """" & Me.email & ""","
    strCSV = strCSV & """" & Me.LicenceID & ""","
    strCSV = strCSV & """" & Me.LicenceCounter & ""","
    strCSV = strCSV & """" & Me.Key & ""","
    
    Dim objTextFile As New cTextFile
    Log = objTextFile.LogFile(strFileName, strCSV)
    
End Function

