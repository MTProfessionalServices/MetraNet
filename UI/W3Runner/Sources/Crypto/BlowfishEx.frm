VERSION 5.00
Begin VB.Form frmBlowfishEx 
   Caption         =   "BlowfishEx Testbed Demo"
   ClientHeight    =   7110
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   8550
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   7110
   ScaleWidth      =   8550
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtDecrypt 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      Height          =   315
      Left            =   1125
      TabIndex        =   38
      Top             =   6075
      Width           =   7320
   End
   Begin VB.TextBox txtPlainAsHex 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      Height          =   315
      Left            =   1125
      TabIndex        =   36
      Top             =   4200
      Width           =   7320
   End
   Begin VB.TextBox txtDecryptHex 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      Height          =   300
      Left            =   1125
      TabIndex        =   35
      Top             =   6450
      Width           =   7320
   End
   Begin VB.Frame Frame4 
      Caption         =   "Plain text format"
      Height          =   540
      Left            =   3075
      TabIndex        =   31
      Top             =   3600
      Width           =   2640
      Begin VB.OptionButton optPTHex 
         Caption         =   "Hex"
         Height          =   240
         Left            =   1200
         TabIndex        =   33
         Top             =   225
         Width           =   1365
      End
      Begin VB.OptionButton optPTAlpha 
         Caption         =   "Alpha"
         Height          =   240
         Left            =   150
         TabIndex        =   32
         Top             =   225
         Value           =   -1  'True
         Width           =   840
      End
   End
   Begin VB.TextBox txtIVAsString 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      Height          =   285
      Left            =   1125
      TabIndex        =   28
      Top             =   2925
      Width           =   7320
   End
   Begin VB.TextBox txtIV 
      Height          =   300
      Left            =   855
      TabIndex        =   3
      Top             =   1725
      Width           =   6120
   End
   Begin VB.Frame Frame3 
      Caption         =   "Paddin&g"
      Height          =   1065
      Left            =   3600
      TabIndex        =   25
      Top             =   150
      Width           =   1365
      Begin VB.OptionButton optNoPad 
         Caption         =   "None"
         Height          =   240
         Left            =   150
         TabIndex        =   27
         Top             =   600
         Width           =   915
      End
      Begin VB.OptionButton optPad 
         Caption         =   "RFC 2630"
         Height          =   240
         Left            =   150
         TabIndex        =   26
         Top             =   300
         Value           =   -1  'True
         Width           =   1065
      End
   End
   Begin VB.Frame grpMode 
      Caption         =   "&Mode"
      Height          =   1065
      Left            =   2250
      TabIndex        =   22
      Top             =   150
      Width           =   990
      Begin VB.OptionButton optModeCBC 
         Caption         =   "CBC"
         Height          =   195
         Left            =   150
         TabIndex        =   24
         Top             =   600
         Width           =   765
      End
      Begin VB.OptionButton optModeECB 
         Caption         =   "ECB"
         Height          =   240
         Left            =   150
         TabIndex        =   23
         Top             =   300
         Value           =   -1  'True
         Width           =   765
      End
   End
   Begin VB.TextBox txtCipher64 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      Height          =   300
      Left            =   1125
      Locked          =   -1  'True
      TabIndex        =   20
      Top             =   5325
      Width           =   7320
   End
   Begin VB.Frame grpKeyForm 
      Caption         =   "Key &format:"
      Height          =   840
      Left            =   7125
      TabIndex        =   17
      Top             =   1200
      Width           =   1305
      Begin VB.OptionButton optAlphaKey 
         Caption         =   "Alpha"
         Height          =   255
         Left            =   150
         TabIndex        =   19
         Top             =   525
         Width           =   960
      End
      Begin VB.OptionButton optHexKey 
         Caption         =   "Hex string"
         Height          =   255
         Left            =   150
         TabIndex        =   18
         Top             =   225
         Value           =   -1  'True
         Width           =   1065
      End
   End
   Begin VB.TextBox txtCipherHex 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      Height          =   300
      Left            =   1125
      Locked          =   -1  'True
      TabIndex        =   16
      Top             =   4950
      Width           =   7320
   End
   Begin VB.TextBox txtCipher 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      Height          =   300
      Left            =   1125
      TabIndex        =   7
      Top             =   4575
      Width           =   7320
   End
   Begin VB.CommandButton cmdDecrypt 
      Caption         =   "&Decrypt cipher text"
      Enabled         =   0   'False
      Height          =   345
      Left            =   1125
      TabIndex        =   12
      Top             =   5700
      Width           =   1695
   End
   Begin VB.TextBox txtKeyAsString 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      Height          =   300
      Left            =   1125
      Locked          =   -1  'True
      TabIndex        =   10
      Top             =   2550
      Width           =   7320
   End
   Begin VB.CommandButton cmdSetKey 
      Caption         =   "&Set Key"
      Height          =   390
      Left            =   900
      TabIndex        =   9
      Top             =   2100
      Width           =   990
   End
   Begin VB.CommandButton cmdEncrypt 
      Caption         =   "&Encrypt plain text"
      Enabled         =   0   'False
      Height          =   450
      Left            =   1125
      TabIndex        =   8
      Top             =   3675
      Width           =   1695
   End
   Begin VB.TextBox txtKey 
      Height          =   300
      Left            =   855
      TabIndex        =   1
      Text            =   "fedcba9876543210"
      Top             =   1320
      Width           =   6120
   End
   Begin VB.TextBox txtPlain 
      Height          =   300
      Left            =   1125
      TabIndex        =   5
      Top             =   3300
      Width           =   7320
   End
   Begin VB.Label Label12 
      Caption         =   "PT input:"
      Height          =   240
      Left            =   150
      TabIndex        =   37
      Top             =   4275
      Width           =   840
   End
   Begin VB.Label Label11 
      Caption         =   "Demonstration of Blowfish VB functions."
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00800000&
      Height          =   915
      Left            =   75
      TabIndex        =   34
      Top             =   150
      Width           =   1665
   End
   Begin VB.Label Label10 
      Caption         =   "(In hex):"
      Height          =   240
      Left            =   150
      TabIndex        =   30
      Top             =   6450
      Width           =   840
   End
   Begin VB.Label Label9 
      Caption         =   "Active IV:"
      Height          =   165
      Left            =   150
      TabIndex        =   29
      Top             =   2925
      Width           =   915
   End
   Begin VB.Label Label8 
      Caption         =   "I&V (hex):"
      Height          =   315
      Left            =   150
      TabIndex        =   2
      Top             =   1725
      Width           =   615
   End
   Begin VB.Label Label7 
      Caption         =   "(Radix64):"
      Height          =   375
      Left            =   165
      TabIndex        =   21
      Top             =   5280
      Width           =   855
   End
   Begin VB.Label Label6 
      Alignment       =   2  'Center
      Caption         =   "Copyright (C) 2001-2 DI Management Services Pty Ltd <www.di-mgt.com.au>. All rights reserved."
      ForeColor       =   &H00800000&
      Height          =   225
      Left            =   225
      TabIndex        =   15
      Top             =   6825
      Width           =   7380
   End
   Begin VB.Label Label2 
      Caption         =   "(In hex):"
      Height          =   255
      Index           =   1
      Left            =   165
      TabIndex        =   14
      Top             =   4950
      Width           =   975
   End
   Begin VB.Label Label5 
      Caption         =   "Deciphered:"
      Height          =   255
      Left            =   150
      TabIndex        =   13
      Top             =   6105
      Width           =   975
   End
   Begin VB.Label Label4 
      Caption         =   "Active key:"
      Height          =   255
      Left            =   150
      TabIndex        =   11
      Top             =   2550
      Width           =   855
   End
   Begin VB.Label Label3 
      Caption         =   "&Key:"
      Height          =   255
      Left            =   135
      TabIndex        =   0
      Top             =   1320
      Width           =   855
   End
   Begin VB.Label Label2 
      Caption         =   "&Cipher text:"
      Height          =   255
      Index           =   0
      Left            =   165
      TabIndex        =   6
      Top             =   4575
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "&Plain text:"
      Height          =   255
      Left            =   165
      TabIndex        =   4
      Top             =   3270
      Width           =   975
   End
End
Attribute VB_Name = "frmBlowfishEx"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Option Base 0

' frmBlowfishEx.frm
' A multi-function example to demonstrate some
' of the extended Blowfish functions.

' This is just a test-bed demo. It is not meant to be
' represesentative of good security code practices.
' There are no error handling facilities, either.

' Version 1. Published January 2002.
'************************* COPYRIGHT NOTICE*************************
' This code was originally written in Visual Basic by David Ireland
' and is copyright (c) 2000-2 D.I. Management Services Pty Limited,
' all rights reserved.

' You are free to use this code as part of your own applications
' provided you keep this copyright notice intact and acknowledge
' its authorship with the words:

'   "Contains cryptography software by David Ireland of
'   DI Management Services Pty Ltd <www.di-mgt.com.au>."

' If you use it as part of a web site, please include a link
' to our site in the form
' <A HREF="http://www.di-mgt.com.au/crypto.html">Cryptography
' Software Code</a>

' This code may only be used as part of an application. It may
' not be reproduced or distributed separately by any means without
' the express written permission of the author.

' David Ireland and DI Management Services Pty Limited make no
' representations concerning either the merchantability of this
' software or the suitability of this software for any particular
' purpose. It is provided "as is" without express or implied
' warranty of any kind.

' Please forward comments or bug reports to <code@di-mgt.com.au>.
' The latest version of this source code can be downloaded from
' www.di-mgt.com.au/crypto.html.
'****************** END OF COPYRIGHT NOTICE*************************

' The ascii values in these strings are used directly
Dim msPlain As String
Dim msCipher As String
Dim msDecrypt As String
' The key is stored as an array of bytes
Dim aKey() As Byte
' The initialisation vector (IV) is stored in hex format
Dim msHexIV As String

Private Sub cmdSetKey_Click()
    Call SetKey
    Call SetIV
End Sub
    
Private Sub SetKey()
' Get key bytes from user's string

    ' What format is it in
    If Me.optHexKey Then
        ' In hex format
        aKey() = cv_BytesFromHex(Me.txtKey)
    Else
        ' User has provided a plain alpha string
        aKey() = cv_BytesFromString(Me.txtKey)
    End If
    
    ' Show key
    Me.txtKeyAsString = cv_HexFromBytes(aKey())
    
    'Initialise key
    Call blf_KeyInit(aKey)
    
    ' Allow encrypt
    Me.cmdEncrypt.Enabled = True
    ' Put user in plaintext box
    Me.txtPlain.SetFocus
    
Done:

End Sub

Private Sub SetIV()
' Set IV
    Dim sHexIV As String
    Dim nBlkLen As Long
    Dim nPad As Long
    
    ' Check mode
    If Me.optModeECB Then
        msHexIV = ""
        GoTo Done
    Else
        msHexIV = Me.txtIV
    End If
    
    ' Now pad IV with zeroes up to required block length
    nBlkLen = GetBlockLen()
    
    nPad = nBlkLen * 2 - Len(msHexIV)
    If nPad > 0 Then
        msHexIV = msHexIV & String(nPad, "0")
    ElseIf nPad < 0 Then
        msHexIV = Left(msHexIV, nBlkLen)
    End If
    
    ' Show iv
    Me.txtIVAsString = msHexIV
    
Done:

End Sub

Private Sub cmdEncrypt_Click()
' Encrypt the plain text as required using hex strings
    Dim nBlkLen As Long
    Dim lngRet As Long
    Dim sMode As String
    
    ' Make sure key and IV are set
    Call SetKey
    Call SetIV
    
    ' Convert hex string into an ascii string if nec
    If Me.optPTAlpha Then
        msPlain = Me.txtPlain
    Else
        msPlain = cv_StringFromHex(Me.txtPlain)
    End If
    
    ' Then pad input if required
    nBlkLen = GetBlockLen()
    If Me.optPad Then
        msPlain = PadString(msPlain)
    ElseIf Len(msPlain) < nBlkLen Then
        MsgBox "Plain text is too short to encrypt without padding"
        GoTo Done
    End If
    
    ' Show input data as hex
    Me.txtPlainAsHex = cv_HexFromString(msPlain)
    
    ' Now encrypt as per mode
    If Me.optModeCBC Then
        msCipher = blf_StringEncRawCBC(msPlain, msHexIV)
    Else
        msCipher = blf_StringRaw(msPlain, bEncrypt:=True)
    End If
    
    ' Display results
    Me.txtCipher = msCipher
    Me.txtCipherHex = cv_HexFromString(msCipher)
    Me.txtCipher64 = EncodeStr64(msCipher)
    Me.cmdDecrypt.Enabled = True

Done:

End Sub

Private Sub cmdDecrypt_Click()
    Dim nblocklen As Long
    Dim lngRet As Long
    Dim sMode As String
    
    nblocklen = GetBlockLen()
    
    ' Now decrypt as per mode
    If Me.optModeCBC Then
        msDecrypt = blf_StringDecRawCBC(msCipher, msHexIV)
    Else
        msDecrypt = blf_StringRaw(msCipher, bEncrypt:=False)
    End If
    
    ' Strip padding if nec
    If Me.optPad Then
        msDecrypt = UnpadString(msDecrypt)
    End If
    
    ' Display output
    Me.txtDecryptHex = cv_HexFromString(msDecrypt)
    Me.txtDecrypt = msDecrypt
    
End Sub


Private Function GetBlockLen()
    GetBlockLen = 8
End Function
