VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Phone Cracker"
   ClientHeight    =   7275
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7380
   LinkTopic       =   "Form1"
   ScaleHeight     =   7275
   ScaleWidth      =   7380
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame2 
      Caption         =   "Input"
      Height          =   1455
      Left            =   480
      TabIndex        =   17
      Top             =   120
      Width           =   4575
      Begin VB.TextBox txtDialedNumber 
         Height          =   375
         Left            =   1680
         TabIndex        =   19
         Top             =   840
         Width           =   2175
      End
      Begin VB.ComboBox ctlBridge 
         Height          =   315
         Left            =   1680
         TabIndex        =   18
         Top             =   360
         Width           =   2655
      End
      Begin VB.Label Label1 
         Caption         =   "Dialed Number "
         Height          =   255
         Left            =   240
         TabIndex        =   21
         Top             =   840
         Width           =   1335
      End
      Begin VB.Label Label10 
         Caption         =   "Dialed from"
         Height          =   375
         Left            =   360
         TabIndex        =   20
         Top             =   360
         Width           =   855
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Results"
      Height          =   5295
      Left            =   480
      TabIndex        =   2
      Top             =   1680
      Width           =   5655
      Begin VB.TextBox txtExchangeCode 
         Height          =   375
         Left            =   2040
         TabIndex        =   23
         Top             =   4080
         Width           =   1215
      End
      Begin VB.TextBox txtTollFree 
         Height          =   375
         Left            =   2040
         TabIndex        =   9
         Top             =   1440
         Width           =   855
      End
      Begin VB.TextBox txtExchange 
         Height          =   375
         Left            =   2040
         TabIndex        =   8
         Top             =   4560
         Width           =   3135
      End
      Begin VB.TextBox txtInternational 
         Height          =   375
         Left            =   2040
         TabIndex        =   7
         Top             =   840
         Width           =   855
      End
      Begin VB.TextBox txtRegionDescription 
         Height          =   375
         Left            =   2040
         TabIndex        =   6
         Top             =   3480
         Width           =   3135
      End
      Begin VB.TextBox txtRegionCode 
         Height          =   375
         Left            =   2040
         TabIndex        =   5
         Top             =   2880
         Width           =   1095
      End
      Begin VB.TextBox txtCountryCode 
         Height          =   375
         Left            =   2040
         TabIndex        =   4
         Top             =   240
         Width           =   1095
      End
      Begin VB.TextBox txtCountry 
         Height          =   375
         Left            =   2040
         TabIndex        =   3
         Top             =   2160
         Width           =   3015
      End
      Begin VB.Label Label11 
         Caption         =   "Exchange Code"
         Height          =   255
         Left            =   480
         TabIndex        =   22
         Top             =   4200
         Width           =   1215
      End
      Begin VB.Label Label8 
         Caption         =   "Toll Free"
         Height          =   255
         Left            =   960
         TabIndex        =   16
         Top             =   1560
         Width           =   735
      End
      Begin VB.Label Label9 
         Caption         =   "Exchange"
         Height          =   375
         Left            =   840
         TabIndex        =   15
         Top             =   4680
         Width           =   735
      End
      Begin VB.Label Label7 
         Caption         =   "International"
         Height          =   255
         Left            =   720
         TabIndex        =   14
         Top             =   960
         Width           =   975
      End
      Begin VB.Label Label5 
         Caption         =   "Region Description"
         Height          =   255
         Left            =   360
         TabIndex        =   13
         Top             =   3480
         Width           =   1455
      End
      Begin VB.Label Label4 
         Caption         =   "Region Code"
         Height          =   255
         Left            =   600
         TabIndex        =   12
         Top             =   2880
         Width           =   1095
      End
      Begin VB.Label Label3 
         Caption         =   "Country Name"
         Height          =   255
         Left            =   600
         TabIndex        =   11
         Top             =   2280
         Width           =   1095
      End
      Begin VB.Label Label2 
         Caption         =   "Country Code"
         Height          =   255
         Left            =   600
         TabIndex        =   10
         Top             =   360
         Width           =   1215
      End
   End
   Begin VB.CommandButton Command1 
      Caption         =   "&Crack Number"
      Default         =   -1  'True
      Height          =   615
      Left            =   5280
      TabIndex        =   0
      Top             =   480
      Width           =   1815
   End
   Begin VB.Label Label6 
      Caption         =   "Label6"
      Height          =   375
      Left            =   2640
      TabIndex        =   1
      Top             =   4800
      Width           =   15
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim PhoneDB As New PhoneNumberParser
Dim Countries As New MTEnumCountries
Dim Devices As New MTEnumPhoneDevices
Dim Regions As New MTEnumRegions
'Dim Properties As MTConfigPropSet

Private Sub Command1_Click()
    On Error GoTo error_handle
    PhoneDB.DialedNumber = txtDialedNumber
    txtCountry = PhoneDB.CountryName
    txtCountryCode = PhoneDB.CountryCode
    txtRegionCode = PhoneDB.NationalCode
    txtRegionDescription = PhoneDB.RegionDescription
    txtInternational = PhoneDB.International
    txtTollFree = PhoneDB.TollFree
    txtExchange = PhoneDB.LocalityDescription
    txtExchangeCode = PhoneDB.LocalityCode
    Exit Sub
    
error_handle:
    MsgBox "Unable to process phone number - " & Err.Description
End Sub

Private Sub Command2_Click()
    Form2.Show vbModal, Me
End Sub

Private Sub ctlBridge_Click()
    Dim idx As Integer
    Dim Bridges As MTEnumPhoneDevices
    Dim bridge As MTPhoneDevice
    
    Set Bridges = PhoneDB.Bridges
    idx = ctlBridge.ListIndex
    Set bridge = Bridges(idx + 1)
    PhoneDB.SetEffectiveDevice bridge.Name
End Sub

Private Sub Form_Load()
    Dim Bridges As MTEnumPhoneDevices
    Dim Count As Integer
    Dim bridge As MTPhoneDevice
    Dim host As String
    
    host = InputBox("Enter hostname (blank for local)", "Config Host", "")
    PhoneDB.Read host, "PhoneLookup", "phonelookup.xml"
    Set Bridges = PhoneDB.Bridges
    Count = Bridges.Count
    For i = 1 To Count
        Set bridge = Bridges.Item(i)
        ctlBridge.AddItem bridge.Description
        If i = 1 Then
            PhoneDB.SetEffectiveDevice bridge.Name
            ctlBridge.Text = bridge.Description
        End If
    Next i
End Sub

