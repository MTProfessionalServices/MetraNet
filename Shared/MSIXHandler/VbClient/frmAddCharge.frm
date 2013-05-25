VERSION 5.00
Begin VB.Form frmAddCharge 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Additional Charge"
   ClientHeight    =   6015
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   7635
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6015
   ScaleWidth      =   7635
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.TextBox InternalComment 
      Height          =   735
      Left            =   1800
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   19
      Top             =   4680
      Width           =   5655
   End
   Begin VB.TextBox InvoiceComment 
      Height          =   735
      Left            =   1800
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   17
      Top             =   3840
      Width           =   5655
   End
   Begin VB.TextBox relatetopreviouscharge 
      Height          =   735
      Left            =   1800
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   15
      Top             =   3000
      Width           =   5655
   End
   Begin VB.TextBox Amount 
      Height          =   333
      Left            =   1800
      TabIndex        =   11
      Top             =   2640
      Width           =   2775
   End
   Begin VB.TextBox otherchargetypecomment 
      Enabled         =   0   'False
      Height          =   735
      Left            =   1800
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   9
      Top             =   1800
      Width           =   5655
   End
   Begin VB.ComboBox ChargeType 
      Height          =   315
      Left            =   1800
      Style           =   2  'Dropdown List
      TabIndex        =   5
      Top             =   1440
      Width           =   5655
   End
   Begin VB.CommandButton OK 
      Caption         =   "OK"
      Height          =   375
      Left            =   5040
      TabIndex        =   1
      Top             =   5520
      Width           =   1215
   End
   Begin VB.CommandButton CANCEL 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   6360
      TabIndex        =   0
      Top             =   5520
      Width           =   1215
   End
   Begin VB.Label Label9 
      Caption         =   "Internal Comment"
      Height          =   615
      Left            =   120
      TabIndex        =   18
      Top             =   4680
      Width           =   1575
   End
   Begin VB.Label Label8 
      Caption         =   "Invoice Comment"
      Height          =   615
      Left            =   120
      TabIndex        =   16
      Top             =   3840
      Width           =   1575
   End
   Begin VB.Label Label7 
      Caption         =   "Related To Previous Charge"
      Height          =   615
      Left            =   120
      TabIndex        =   14
      Top             =   3000
      Width           =   1575
   End
   Begin VB.Label Currency 
      Caption         =   "FRF"
      Height          =   255
      Left            =   1920
      TabIndex        =   13
      Top             =   960
      Width           =   1575
   End
   Begin VB.Label Label6 
      Caption         =   "Currency"
      Height          =   255
      Left            =   120
      TabIndex        =   12
      Top             =   960
      Width           =   1575
   End
   Begin VB.Label Label5 
      Caption         =   "Amount"
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   2640
      Width           =   1575
   End
   Begin VB.Label Label4 
      Caption         =   "Other"
      Height          =   255
      Left            =   120
      TabIndex        =   8
      Top             =   1800
      Width           =   1575
   End
   Begin VB.Label ChargeDate 
      Caption         =   "12/11/1964"
      Height          =   255
      Left            =   1920
      TabIndex        =   7
      Top             =   600
      Width           =   1575
   End
   Begin VB.Label Label3 
      Caption         =   "Charge Date"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   600
      Width           =   1575
   End
   Begin VB.Label Label2 
      Caption         =   "Charge Type"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   1440
      Width           =   1575
   End
   Begin VB.Label ACCOUNTID 
      Caption         =   "123456"
      Height          =   255
      Left            =   1920
      TabIndex        =   3
      Top             =   240
      Width           =   1575
   End
   Begin VB.Label Label1 
      Caption         =   "Account ID:"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   240
      Width           =   1575
   End
End
Attribute VB_Name = "frmAddCharge"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
    
Public Service      As New MSIXHandler
Public Properties   As MSIXProperties

Private Sub CANCEL_Click()
    Hide
    Unload Me
End Sub

Private Sub ChargeType_Click()

    Dim lngIndex As Long
    
    lngIndex = ChargeType.ItemData(ChargeType.ListIndex)
    
    otherchargetypecomment.Enabled = CBool(Properties("ChargeType").EnumType.Entries(lngIndex).Value = 1)
    
End Sub

'    objXService.Properties("_ACCOUNTID") = 123
'    objXService.Properties("chargetype") = "other" ' enum type
'    objXService.Properties("chargedate") = Now
'    objXService.Properties("otherchargetypecomment") = "No Other Comment"
'    objXService.Properties("_amount") = 123.456
'    objXService.Properties("_currency") = "FRF"
'    objXService.Properties("taxtype") = 1
'    objXService.Properties("issuer") = 125
'    objXService.Properties("relatetopreviouscharge") = "No Related To Previous Charge"
'    objXService.Properties("invoicecomment") = "Invoice Comment"
'    objXService.Properties("internalcomment") = "Internal Comment"

Private Sub Form_Load()

    If (Not Service.Initialize("metratech.com\addcharge.msixdef", , "US", App.Path)) Then
    
        MsgBox "cannot initialize service"
        Exit Sub
    End If
    
    Service.Properties("_ACCOUNTID") = 123
    Service.Properties("chargedate") = Now
    Service.Properties("_currency") = "FRF"
    Service.Properties("ChargeType") = 1
    Service.Properties("taxtype") = 1
    Service.Properties("issuer") = 125
    
    Service.Properties("relatetopreviouscharge") = "No Related To Previous Charge"
    Service.Properties("invoicecomment") = "Invoice Comment"
    Service.Properties("internalcomment") = "Internal Comment"
    
    Set Properties = Service.Properties
    
    PopulateForm Me
    
End Sub

Private Function PopulateForm(frmForm As Form) As Boolean

    Dim Ctl                 As Object
    Dim objProperty         As MSIXProperty
    Dim strPropertyName     As String
    Dim objVar              As MSIXEnumTypeEntry
    Dim i                   As Long
        
    For Each objProperty In Properties
        
            strPropertyName = objProperty.Name
            If (Mid(strPropertyName, 1, 1) = "_") Then  ' Remove the _ because VB Does not support it
            
                strPropertyName = Mid(strPropertyName, 2)
            End If
            Set Ctl = ControlExist(strPropertyName, Me)
            
            If (IsValidObject(Ctl)) Then
                
                Select Case UCase(TypeName(Ctl))
                
                   Case "TEXTBOX"
                        Ctl.Text = objProperty.Value
                        
                   Case "COMBOBOX"
                   
                        If (objProperty.IsEnumType()) Then
                        
                            Ctl.Clear
                            For i = 1 To objProperty.EnumType.Entries.Count
                            
                                Set objVar = objProperty.EnumType.Entries(i)
                                Ctl.AddItem objVar.Name
                                Ctl.ItemData(Ctl.NewIndex) = i
                                If (CStr(objVar.Value) = CStr(objProperty.Value)) Then
                                
                                    Ctl.ListIndex = Ctl.NewIndex
                                End If
                            Next
                        Else
                            ' Error not enum  type
                        End If
                        
                   Case "LABEL"
                        Ctl.Caption = objProperty.Value
                End Select
            End If
    Next
End Function

Function ControlExist(strControlName As String, objForm As Form) As Object
    On Error Resume Next
    
    Set ControlExist = Nothing
    Set ControlExist = objForm.Controls(strControlName)
    Err.Clear
End Function


Private Sub OK_Click()

    On Error GoTo ErrMgr
    
    Dim objMDMError As New MDMError
    
    If (PopulateMSIXHandler(Me)) Then
        If (Service.RequiredFieldsOK(objMDMError)) Then
        
            Service.Meter True
            MsgBox "Charge Sucessfully Added."
            Hide
            Unload Me
        Else
            MsgBox objMDMError.ToString()
        End If
    End If
    
    Exit Sub
ErrMgr:
    MsgBox GetVBErrorString()
    Hide
End Sub

Private Function PopulateMSIXHandler(frmForm As Form) As Boolean

    Dim Ctl                 As Object
    Dim objProperty         As MSIXProperty
    Dim strPropertyName     As String
    Dim objVar              As CVariable
    Dim lngIndex            As Long
        
    For Each objProperty In Properties
        
            strPropertyName = objProperty.Name
            If (Mid(strPropertyName, 1, 1) = "_") Then  ' Remove the _ because VB Does not support it
            
                strPropertyName = Mid(strPropertyName, 2)
            End If
            Set Ctl = ControlExist(strPropertyName, Me)
            
            If (IsValidObject(Ctl)) Then
                
                Select Case UCase(TypeName(Ctl))
                
                   Case "TEXTBOX"
                         objProperty.Value = Ctl.Text
                        
                   Case "COMBOBOX"
                        
                        lngIndex = ChargeType.ItemData(ChargeType.ListIndex)
                        objProperty.Value = Properties("ChargeType").EnumType.Entries(lngIndex).Value
                End Select
            End If
    Next
    PopulateMSIXHandler = True
End Function

