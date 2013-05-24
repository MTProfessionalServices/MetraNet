VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CPoissonSuceur"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const POISSON_SUCEUR_KEY = "wP3oriusnsnoenrwS3urcuenunrn"
Private Const POISSON_SUCEUR_IV = "agertpnf$q895234"
Private aKey() As Byte

Public Function UnitTest() As Boolean
    Dim s1 As String
    Dim s2 As String
    Dim s3 As String
    s1 = "Rose are red!"
     Me.Crypte s1, s2
    Me.DeCrypte s2, s3
    UnitTest = s1 = s3
End Function

Public Function Crypte(strKeySource As String, ByRef strKeyCrypted As String) As Boolean
    
    Dim sCipher As String
        
    sCipher = blf_StringEncCBC(strKeySource & Chr$(0), POISSON_SUCEUR_IV)
    strKeyCrypted = cv_HexFromString(sCipher)
    Crypte = True
    
    ' Output results
    'Debug.Print "KY="; cv_HexFromBytes(aKey)
    'Debug.Print "CT="; cv_HexFromString(sCipher)
    
End Function

Public Function DeCrypte(ByVal strKeyCrypted As String, ByRef strKeyDest As String) As Boolean

    Dim strTmp As String
    Dim sCipher  As String
    
    
    
    sCipher = cv_StringFromHex(strKeyCrypted)
    strTmp = blf_StringDecCBC(sCipher, POISSON_SUCEUR_IV)
    strKeyDest = Mid(strTmp, 1, Len(strTmp) - 1)
    DeCrypte = True
End Function

Private Sub Class_Initialize()
    ' Load test key and initialise
    aKey() = cv_BytesFromHex(POISSON_SUCEUR_KEY)
    Call blf_KeyInit(aKey)
End Sub

Public Function CrypteFile(ByVal strInputFile As String, ByVal strOutPutFile As String) As Boolean

    Dim objTextFile As New cTextFile
    Dim strCryptedText As String

    If Me.Crypte(objTextFile.LoadFile(strInputFile), strCryptedText) Then
    
        CrypteFile = objTextFile.LogFile(strOutPutFile, strCryptedText, True)
    End If
End Function
