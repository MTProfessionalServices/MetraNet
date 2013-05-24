VERSION 5.00
Begin VB.Form Form2 
   Caption         =   "Form2"
   ClientHeight    =   4860
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7590
   LinkTopic       =   "Form2"
   ScaleHeight     =   4860
   ScaleWidth      =   7590
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Delete 
      Caption         =   "Delete"
      Height          =   615
      Left            =   5040
      TabIndex        =   12
      Top             =   3960
      Width           =   1695
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Next"
      Height          =   615
      Left            =   2400
      TabIndex        =   11
      Top             =   3960
      Width           =   1455
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Prev"
      Height          =   615
      Left            =   600
      TabIndex        =   10
      Top             =   3960
      Width           =   1335
   End
   Begin VB.ComboBox RegionCode 
      Height          =   315
      Left            =   1920
      TabIndex        =   9
      Top             =   3000
      Width           =   2535
   End
   Begin VB.ComboBox CountryCode 
      Height          =   315
      Left            =   1920
      TabIndex        =   8
      Top             =   2280
      Width           =   2535
   End
   Begin VB.TextBox txtLineAccess 
      Height          =   375
      Left            =   1920
      TabIndex        =   7
      Top             =   1560
      Width           =   1095
   End
   Begin VB.TextBox txtDescription 
      Height          =   375
      Left            =   1920
      TabIndex        =   6
      Top             =   960
      Width           =   2535
   End
   Begin VB.TextBox txtDevice 
      Height          =   375
      Left            =   1920
      TabIndex        =   5
      Top             =   360
      Width           =   1575
   End
   Begin VB.Label Label5 
      Caption         =   "Region Code"
      Height          =   375
      Left            =   120
      TabIndex        =   4
      Top             =   3120
      Width           =   1215
   End
   Begin VB.Label Label4 
      Caption         =   "Country  Code"
      Height          =   375
      Left            =   120
      TabIndex        =   3
      Top             =   2400
      Width           =   1335
   End
   Begin VB.Label Label3 
      Caption         =   "Line Access Code"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   1680
      Width           =   1335
   End
   Begin VB.Label Label2 
      Caption         =   "Description"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   1080
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "Device"
      Height          =   255
      Left            =   240
      TabIndex        =   0
      Top             =   360
      Width           =   1095
   End
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim Current As Long
Dim ItemCount As Long
Dim PhoneDB As New PhoneNumberParser
Dim Regions As MTEnumRegions
Dim Countries As MTEnumCountries
Dim bridge As MTPhoneDevice

Private Sub Command1_Click()
    If Current > 1 Then
        Current = Current - 1
    End If
    Fill_Form
End Sub

Private Sub Command2_Click()
    If Current < ItemCount Then
        Current = Current + 1
    End If
    Fill_Form
End Sub

Private Sub CountryCode_Change()
    
    Dim Devices As MTEnumPhoneDevices
    
    Set Devices = PhoneDB.Bridges
    Set bridge = Devices.Item(Current)
    bridge.CountryName = CountryCode.Text

End Sub

Private Sub CountryCode_Click()
    Dim Region As MTRegion
    
    If CountryCode.Text <> "" Then
        RegionCode.Clear
        Set Regions = Nothing
        Set Regions = PhoneDB.GetRegionsByCountryName(CountryCode.Text)
        'Regions.InitFromFile "c:\source\development\config\phonelookup\NANP.xml"
        For idx = 1 To Regions.Count
             Set Region = Regions.Item(idx)
             RegionCode.AddItem Region.DestinationCode
        Next idx
    End If
End Sub


Private Sub Delete_Click()
    Dim Devices As MTEnumPhoneDevices
    
    Set Devices = PhoneDB.Bridges
    Devices.Remove Current
    ItemCount = Devices.Count
End Sub

Private Sub Form_Load()
Dim idx As Long
Dim Country As MTCountry
Dim Devices As MTEnumPhoneDevices

    Current = 1
    PhoneDB.Read "", "phonelookup", "phonelookup.xml"
    Set Devices = PhoneDB.Bridges
    ItemCount = Devices.Count
    'Set Regions = PhoneDB.GetRegionsByCountryCode(CountryCode.Text)
    Fill_Form
    Set Countries = PhoneDB.Countries
    For idx = 1 To Countries.Count
        Set Country = Countries.Item(idx)
        CountryCode.AddItem Country.Name
        Set Country = Nothing
    Next idx

End Sub

Private Sub Fill_Form()
    Dim Region As MTRegion
    Dim Devices As MTEnumPhoneDevices
    
    Set Devices = PhoneDB.Bridges
    Set bridge = Devices.Item(Current)
    txtDevice.Text = bridge.Name
    txtDescription.Text = bridge.Description
    If bridge.LineAccessCode <> "" Then
        txtLineAccess.Text = bridge.LineAccessCode
    End If
    CountryCode.Text = bridge.CountryName
    
'    If Regions <> Empty Then
'    End If
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    PhoneDB.Write
End Sub

Private Sub txtDescription_Change()
        
    Dim Devices As MTEnumPhoneDevices
    
    Set Devices = PhoneDB.Bridges
    Set bridge = Devices.Item(Current)
    bridge.Description = txtDescription.Text
End Sub
